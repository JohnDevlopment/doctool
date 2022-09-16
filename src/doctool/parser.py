"""Parsers for reference JSON files."""

import json, re
from .utils import *
from .exceptions import InvalidDataError, MissingFieldWarning
#from abc import ABC, abstractmethod

class GDScriptObject:
    """Base class for all GDScript types."""

    __slots__ = ('verbose')

    # Regular expression to get the first line of a description.
    OnelineSentenceRe = re.compile(r'(?m)^#[ \t]*(.*?)\.?$')

    # Regular expression used to collapse multiple whitespaces into one.
    WhitespaceRe = re.compile(r'\n[ \t]*')

    def __init__(self, obj: dict, verbose=False):
        self.verbose = verbose
        name = obj['name']

    def fullname(self, override="") -> str:
        """Return the fully qualified name of the GDScript object."""
        if override:
            return override
        return self.name

    @classmethod
    def parse_description(cls, desc: str, err='') -> tuple:
        """
        Parse the description DESC.

        Returns a tuple with the first-line synopsis of the object and
        the rest of the description as a list.

        The long description of the object (we'll call it DESC) is stripped
        of leading and trailing whitespace before getting split into paragraphs,
        using the blank line as the separator. Lines within a paragraph are
        collapsed into one line.
        """
        # Get first line.
        m = cls.OnelineSentenceRe.search(desc.lstrip())
        if m is None:
            return '', ''
        briefDesc = m[1]
        if not briefDesc.endswith('.'):
            briefDesc += '.'

        # Split paragraphs
        temp = desc.strip()[m.end():].split("\n\n")
        newDesc = []

        # Collapse paragraphs into one line each
        for graff in temp:
            newDesc.append(cls.WhitespaceRe.sub(' ', graff.strip()))

        return briefDesc, newDesc

class GDScriptMetadata(GDScriptObject):
    """Name, description, and version of the reference."""

    def __init__(self, obj: dict, *args, **kw):
        """Construct a GDScriptMetadata from OBJ."""
        super().__init__(obj, *args, **kw)
        self._name = obj['name']
        self._description = obj['description']
        self._version = obj['version']

    @property
    def name(self):
        """Class reference name."""
        return self._name

    @property
    def description(self):
        """Class reference description."""
        return self._description

    @property
    def version(self):
        """Class reference version."""
        return self._version

    def fullname(self) -> str:
        """
        Return the fully qualified name of the GDScript object.

        This function should be overidden.
        """
        return self.name

class GDScriptClass(GDScriptObject):
    """
    An abstract representation of a GDScript class.

    Attributes:
        * name             = name of the class
        * path             = path to the file in the project
        * extends          = comma-separated list of this class' base classes
                             (if empty, see extends_file)
        * extends_file     = file this class extends (use this if extends is empty)
        * icon             = path to the icon file
        * signature        = signature for instancing the class
        * description      = class description
        * constants        = a list of constants
        * members          = a list of data members (properties)
        * signals          = a list of signals
        * methods          = a list of methods
        * static_functions = a list static functions
        * subclasses       = a list of this NAME's subclasses
    """

    __slots__ = ('name', 'path', 'extends', 'extends_file', 'icon',
                 'signature', 'brief', 'description', 'constants',
                 'members', 'signals', 'methods', 'static_functions',
                 'subclasses')

    def __init__(self, obj: dict, **kw):
        """Construct a GDScriptClass from the given object OBJ."""
        super().__init__(obj, **kw)
        self.name = obj.get('name', '').removesuffix('.gd')
        self.path = obj.get('path', '')
        self.extends = ', '.join(obj.get('extends_class', []))
        self.extends_file = obj.get('extends_file', '')
        self.icon = obj.get('icon', '')
        self.signature = obj.get('signature', '')

        # Parse description
        self.description = obj.get('description', '')
        self.brief, self.description = self.parse_description(self.description, self.name or self.path)
        if not self.brief.endswith('.'):
            self.brief += '.'

        self.subclasses = obj.get('sub_classes', [])
        self.constants = self.parse_list(obj.get('constants', []),
                                         GDScriptConstant, verbose=self.verbose)
        self.members = self.parse_list(obj.get('members', []),
                                       GDScriptDataMember, verbose=self.verbose)
        self.signals = self.parse_list(obj.get('signals', []),
                                       GDScriptSignal, verbose=self.verbose)
        self.methods = self.parse_list(obj.get('methods', []),
                                       GDScriptFunction,
                                       skip_hidden=True, verbose=self.verbose)
        self.static_functions =\
            self.parse_list(obj.get('static_functions', []),
                            GDScriptFunction,
                            static=True, skip_hidden=True, verbose=self.verbose)

    def parse_list(self, obj: list, cls, **kw) -> list:
        """
        Build a list of objects based on OBJ.

        Each element in OBJ should be a dictionary.
        It gets passed into the constructor of CLS,
        like thus:

            cls(obj, self, **kw)

        Also, CLS should be derived from GDScriptClassMember.

        **KW is a dictionary of keyword options which are
        forwarded to CLS except in the following cases:
            * skip_hidden
        """
        res = []
        err = None

        # skip_hidden (default: True)
        try:
            skipHidden = kw.pop('skip_hidden')
        except KeyError as exc:
            skipHidden = True

        assert isinstance(skipHidden, bool)

        for e in obj:
            inst = cls(e, self, **kw)
            if inst.name.startswith('_') and skipHidden: continue
            res.append(inst)

        return res

# Class members

class GDScriptClassMember(GDScriptObject):
    """
    Base class for members of GDScriptClass.

    Subclasses:
        * GDScriptConstant
        * GDScriptDataMember
        * GDScriptSignal
        * GDScriptFunction
    """

    __slots__ = ('parent',)

    def __init__(self, parent: GDScriptClass, *args, **kw):
        super().__init__(*args, **kw)
        self.parent = parent

    def fullname(self, _override="") -> str:
        return f"{self.parent.name}.{self.name}"

## Functions

class GDScriptFunction(GDScriptClassMember):
    """
    An abstract representation of a GDScript function, static or not.

    Attributes:
        * name        = name of the function
        * return_type = return type
        * signature   = signature
        * brief       = a brief description
        * description = the full description
        * arguments   = a list of arguments
        * static      = true if the function is static
        * virtual     = true if the function is virtual
        * const       = true if the function is constant (does not
                        modify the class)
    """

    __slots__ = ('name', 'return_type', 'brief', 'description', 'arguments',
                 'static', 'virtual', 'const', 'signature')

    def __init__(self, obj: dict, parent: GDScriptClass, *, static=False, **kw):
        """Initialize a function with OBJ and *ARGS."""
        super().__init__(parent, obj, **kw)
        for name in ['name', 'signature', 'return_type']:
            value = obj[name]
            if value == 'null': value = 'void'
            setattr(self, name, value)
        self.static = static
        self.brief, self.description = self.parse_description(obj['description'], self.name)
        self._tags()
        self.arguments = list( map(lambda argDict: (argDict['type'], argDict['name'], argDict.get('default_value')),
                                   obj['arguments'])  )

    def _tags(self):
        self.virtual = False
        self.const = False

        if self.static: return
        
        for m in re.finditer(r'@(const|virtual)\b', "\n".join(self.description)):
            setattr(self, m[1], True)
            if __debug__:
                if self.verbose:
                    print_error(f"DEBUG: {self.fullname()}: {m[1]}")

    def __str__(self) -> str:
        msg = f"{self.return_type} {self.name}"
        
        if self.static:
            msg = "static " + msg
        elif self.virtual:
            msg = "virtual " + msg

        # Comma-separated list of arguments
        args = []
        for arg in self.arguments:
            _type, name, default = arg
            arg = f"{_type} {name}"
            if default is not None:
                arg += " = " + str(default)
            args.append(arg)
        msg += "(%s)" % ", ".join(args)
        
        if self.const:
            msg += " const"
        
        return msg

#################

class GDScriptSignal(GDScriptClassMember):
    """
    An abstract representation of a GDScript class signal.

    Attributes:
        * name        = name of the signal
        * arguments   = a list of the signal's arguments;
                        each element is a tuple with the argument's
                        type followed by the name
        * signature   = the signature
        * brief       = a brief description
        * description = the full description
    """

    __slots__ = ('name', 'arguments', 'signature', 'brief', 'description')

    def __init__(self, obj: dict, parent, **kw):
        """Initialize a signal from OBJ."""
        super().__init__(parent, obj, **kw)
        self.name = obj['name']
        self.brief, self.description = \
            self.parse_description(obj['description'], self.name)
        self.arguments = self.parse_arguments(self.description,
                                              obj.get('arguments', []))
        self.signature = obj['signature']

    def __str__(self) -> str:
        return self.signature

    @staticmethod
    def parse_arguments(desc, args: list) -> list:
        """
        Return a list of arguments whose types are inferred from DESC.

        DESC is the description of the GDScript object, either as a list
        or a string. This looks for substrings matching the pattern
        "@type arg type", where 'arg' is the name of an argument
        and 'type' is its type.

        Returns a list wherein each element is a tuple of two strings,
        the type and the name of an argument, respectively.
        """
        argTypes = {}
        pattern = re.compile(r'(?m)^\s*@type\s*(\w+)\s*(\w+)')

        if __debug__:
            for arg in args:
                if isinstance(arg, dict):
                    raise TypeError("args key '%s' is dictionary" % arg)

        # Invalid type
        if not isinstance(desc, (str,list)):
            raise TypeError("description must be a string or list")
        
        # Join into string
        if isinstance(desc, list):
            desc = "\n".join(desc)

        # Find all @type tags
        temp = pattern.findall(desc)
        if temp:
            for e in temp:
                name, _type = e
                argTypes[name] = _type
            del e, temp

        return [(argTypes.get(arg, 'var'), arg) for arg in args]

class GDScriptDataMember(GDScriptClassMember):
    """
    An abstract representation of a GDScript class property.

    Attributes:
        * name          = data member's name
        * data_type     = type (e.g., float, int, string)
        * default_value = default value
        * setter        = setter function
        * getter        = getter function
        * export        = true if in the editor
        * signature     = signature
        * description   = description of the data member
    """

    def __init__(self, obj: dict, parent, **kw):
        """Initialize a data member from OBJ."""
        super().__init__(parent, obj, **kw)
        self.name = obj['name']
        self.data_type = obj['data_type']
        self.default_value = obj['default_value']
        self.setter = obj['setter']
        self.getter = obj['getter']
        self.export = obj['export']
        self.signature = obj['signature']
        description = self.parse_description(obj['description'], self.name)
        self.brief, self.description = description

    def __str__(self) -> str:
        return f"{self.data_type} {self.name} = {self.default_value or 'null'}"

class GDScriptConstant(GDScriptClassMember):
    """
    An abstract representation of a GDScript class constant.

    Attributes:
        * name        = name of the constant
        * value       = value of the constant
        * data_type   = type (e.g., float, int, string)
        * signature   = signature
        * description = description of the constant
    """

    def __init__(self, obj: dict, parent, **kw):
        """Initialize a constant from OBJ."""
        super().__init__(parent, obj, **kw)
        self.name = obj['name']
        self.value = obj['value']
        self.data_type = obj['data_type']
        self.signature = obj['signature']
        self.brief, self.description = self.parse_description(obj['description'], self.name)

    def __str__(self):
        return f"{self.data_type} {self.name} = {self.value}"

# Toplevel node

class GDScriptReference:
    """Toplevel node of the class reference tree."""

    def __init__(self, metadata: GDScriptMetadata, classes: list):
        """Initialize a CLASS object."""
        self._metadata = metadata
        self._classes = classes

    @property
    def metadata(self):
        """The metadata as a GDScriptMetadata."""
        return self._metadata

    @property
    def classes(self):
        """A list of the classes."""
        return self._classes

    def find_class(self, S: str) -> GDScriptClass:
        """
        Try to find the class named S.

        If S does not exist, None is returned.
        """
        for cls in self.classes:
            if cls.name == S:
                return cls
        return None

# Functions

def _compile_class_list(obj: dict, **kw) -> list:
    """
    Internal function.

    Returns a list of each class defined in the
    api reference.
    """
    if __debug__:
        fd = open('class-exceptions.log', 'w')

    classes = []
    for cls in obj['classes']:
        if 'name' not in cls:
            if __debug__:
                if self.verbose:
                    print_error("DEBUG: Skipping empty class")
            continue

        try:
            clsobj = GDScriptClass(cls, **kw)
        except KeyError as exc:
            if __debug__:
                print_exception(exc, file=fd)
            continue
        except Exception as exc:
            raise exc from None

        if clsobj is not None:
            classes.append(clsobj)

    if __debug__:
        fd.close()

    return classes

def parse(fp_or_s, *, verbose=False):
    """
    Read the contents of FP and deserialize it into a Python object.

    FP can either be a str, a bytes array, or a file-like object that
    has a read() method.
    """
    if isinstance(fp_or_s, (str,bytes)):
        data = json.loads(fp_or_s)
    else:
        data = json.load(fp_or_s)

    tree = GDScriptReference(GDScriptMetadata(data),
                             _compile_class_list(data, verbose=verbose))

    return tree

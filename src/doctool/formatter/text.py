"""Text formatting."""

from . import Formatter
from ..exceptions import InvalidArgumentError

class TextFormatter(Formatter):
    """Formats a GDScript tree in text format."""

    def format_description(self, desc: list, prefix: str, level: int) -> str:
        res = ""

        for e in desc:
            res += f"\n\n{prefix*level}{e}"

        return res

    def format(self, show_constants=True, show_properties=True,
               show_methods=True, show_signals=True, show_sfuncs=True,
               indent=4, show_hidden=False):
        """
        Returns a formatted string from TREE.

        TREE is a subclass of GDScriptObject that represents
        a GDScript object.
        """
        # Error-check INDENT
        if indent is None:
            indent = 0
        elif not isinstance(indent, int) or indent < 0:
            raise InvalidArgumentError('indent',
                                       "%s is invalid, must be an integer 1 or greater, or None" % indent)

        INDPREFIX = " " * max(indent, 0)

        tree = self.tree
        msgList = []

        # Extends
        extends = tree.extends or tree.extends_file
        msg = f"== {tree.name} ==\n\nExtends {extends}"
        del extends

        # Subclasses
        subclasses = tree.subclasses
        if subclasses:
            msg += "\n\nSubclasses: %s" % ", ".join(subclasses)
        del subclasses

        def _description(obj, prefix: str, level: int) -> bool:
            nonlocal msgList

            if obj.brief == '':
                msgList.append(prefix)
                return

            nonlocal INDPREFIX
            nonlocal self
            desc = f"\n{INDPREFIX * level}{obj.brief}"
            if obj.description:
                self.format_description( obj.description, INDPREFIX, level)
            msgList.append(prefix + desc.rstrip())

        # Description
        brief = tree.brief
        assert not brief.isspace() and len(brief) > 0, "empty string"
        sep = f"\n\n{INDPREFIX}"
        msg += f"\n\nDescription:\n{INDPREFIX}" + sep.join([brief, *tree.description])

        # Constants
        if tree.constants and show_constants:
            msg += "\n\nConstants:\n"
            msgList = []
            for const in tree.constants:
                # Skip this constant if it's private and show_hidden is false
                if const.name.startswith('_') and not show_hidden: continue

                _description(const, str(const), 2)

            if msgList:
                msg += "{prefix}{constants}".format(prefix=INDPREFIX,
                                                    constants=sep.join(msgList))
            del const

        # Data members
        if tree.members and show_properties:
            msg += "\n\nProperties:\n"
            msgList = []

            for member in tree.members:
                # Skip this member if it's private and show_hidden is false
                if member.name.startswith('_') and not show_hidden: continue

                memMsg = str(member)

                for name in ('setter', 'getter'):
                    _name = getattr(member, name, '')
                    if _name != '':
                        memMsg += f"\n{INDPREFIX*2}{name.capitalize()}: {_name}\n"

                _description(member, memMsg, 2)

            if msgList:
                msg += INDPREFIX + sep.join(msgList)

            del memMsg, member, name, _name

        # Signals
        if tree.signals:
            msg += "\n\nSignals:\n"
            msgList = []

            for signal in tree.signals:
                temp = ["%s %s" % arg for arg in signal.arguments]
                temp = ', '.join(temp)
                sigMsg = "%s(%s)" % (signal.name, temp)
                _description(signal, sigMsg, 2)

            if msgList:
                msg += INDPREFIX + sep.join(msgList)

            del signal, temp, sigMsg

        # Instance methods
        if tree.methods:
            msg += "\n\nMethods:\n"
            msgList = []

            for method in tree.methods:
                _description(method, str(method), 2)

            if msgList:
                msg += INDPREFIX + sep.join(msgList)

        # Static functions
        if tree.static_functions:
            msg += "\n\nStatic Functions:\n"
            msgList = []

            for function in tree.static_functions:
                _description(function, str(function), 2)

            if msgList:
                msg += INDPREFIX + sep.join(msgList)

        return msg

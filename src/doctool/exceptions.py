"""Module containing all the exceptions."""

class InputError(Exception):
    """
    Base class for errors with user input.

    Attributes:
        * input_name = indicates the user input the error is about
    """

    def __init__(self, input_name: str, *args, **kw):
        """
        Initialize InputError.

        INPUT_NAME is whatever input was needed.
        """
        super().__init__(*args, **kw)
        self.input_name = input_name
        self.args = args

    def __str__(self) -> str:
        msg = self.input_name
        if self.args:
            msg += " %s" % self.args
        return msg

class InvalidArgumentError(InputError):
    """Exception for invalid argument."""

    def __str__(self):
        msg = f"invalid argument '{self.input_name}': "
        if self.args:
            msg += " " + " ".join(self.args)
        return msg

class InvalidDataError(InputError):
    """Exception for invalid data."""

    def __init__(self, arg1, arg2=None, *args, **kw):
        super().__init__(arg1, *args, **kw)
        self.arg2 = arg2

    def __str__(self) -> str:
        if self.arg2:
            msg = "'%s' in %s" % (self.input_name, self.arg2)
        else:
            msg = self.input_name
        return ', '.join([msg, *self.args])

class MissingFieldError(RuntimeError):
    """"""
    pass

class MissingFieldWarning(Warning):
    """A warning form missing fields in various classes."""

    def __init__(self, field: str, base: str, *args, **kw):
        super().__init__(*args, **kw)
        self._field = field
        self._base = base

    def __str__(self):
        msg = f"'{self.field}' in {self.base}"
        baseMsg = super().__str__()
        if baseMsg != '':
            msg = msg + ": " + baseMsg
        return msg

    @property
    def field(self):
        """The missing field."""
        return self._field

    @property
    def base(self):
        """The field's base class."""
        return self._base

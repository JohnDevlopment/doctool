"""Formatting."""

from abc import ABC, ABCMeta, abstractmethod

#class FormatterBase(metaclass=ABCMeta):
#    pass

class Formatter(ABC):
    """
    Base class for formatting.

    This is an abstract class, meaning it cannot be instanced
    directly and must be subclassed. Further, it contains methods
    that require to be overriden.
    """

    __slots__ = ('tree',)

    def __init__(self, tree):
        """Initialize a formatter with the given GDScript tree TREE."""
        self.tree = tree

    @abstractmethod
    def format(self):
        """
        Return a formatted string based on `self.tree` attribute.

        This method *must* be overidden to work.
        """
        pass

    @abstractmethod
    def format_description(self, desc: list, prefix: str, level: int):
        """
        Format a description-string from a list.

        This method *must* be overidden to work.
        """
        pass

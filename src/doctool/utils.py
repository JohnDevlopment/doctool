"""Utility functions."""

import sys, traceback

_all__ = ['list2dict', 'print_error', 'print_exception']

def list2dict(l: list) -> dict:
    """
    Converts a list of into a dictionary.

    L is a list of even length, otherwise an
    ValueError is raised.
    """
    LEN = len(l)
    if LEN % 2:
        raise ValueError("argument has an odd number of elements")
    res = {}
    for i in range(0, LEN, 2):
        k, v = l[i:i+2]
        res[k] = v
    return res

def print_error(S: str, *args):
    """Prints a message to stderr"""
    print(S, *args, file=sys.stderr)

def print_exception(exc: Exception, file=sys.stderr, *, print_tb=True):
    """Prints the exception EXC."""
    print(exc, file=file)
    if print_tb:
        traceback.print_tb(exc.__traceback__, file=file)

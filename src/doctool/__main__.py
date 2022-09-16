# Main module

from .parser import parse
from .utils import print_error, list2dict
from .exceptions import InvalidArgumentError, MissingFieldWarning
from .formatter.text import TextFormatter
from pathlib import Path, PurePath
import sys, re

def _process_keyvalue_options(opts: list, err_prefix: str):
    res = []
    kvre = re.compile(r'(\w+)=(.+)')
    floatre = re.compile(r'^\d+(\.\d+)?$')
    for opt in opts:
        if (m := kvre.match(opt)) is None:
            raise InvalidArgumentError(err_prefix,
                                       "argument must be key=value format")
        k, v = m[1], m[2]
        m = floatre.search(v)
        if m is not None:
            if v.find('.') >= 0:
                # Has a decimal, so it's a floating point
                v = float(v)
            else:
                # It's an integer
                v = int(v)
        res.extend([k, v])

    return list2dict(res)

def _print_class(tree, opts: dict, _type='text'):
    if _type == 'text':
        formatter = TextFormatter(tree)

    output = formatter.format(**opts)
    print(output)

def main():
    import argparse

    # Parse commandline arguments
    parser = argparse.ArgumentParser(
        prog='doctool',
        description='Generate HTML documentation.'
    )

    parser.add_argument('-v', '--verbose', action='store_true',
                        help='print warnings and debug messages')
    
    parser.add_argument('--class', dest='doclass', metavar='CLASS',
                        help="print the contents of a class")

    group = parser.add_argument_group('formatting options',
                                      'These options affect the format of the output.')

    group.add_argument('-f', '--format', dest='format',
                       default='text', choices=['text', 'html'],
                       help='specifies the format of the output')

    group.add_argument('-F', '--formatter-option', dest='formatter_option',
                       action='append', default=[], metavar='OPTION',
                       help="specify an option to the formatter. It is "
                       "appended to a list. It must be in key=value syntax.")

    parser.add_argument('inputfile', metavar='INPUTFILE',
                        help="input file; must be in JSON format",
                        type=Path)

    args = parser.parse_args()

    # Get input file
    _file = args.inputfile.resolve()
    if not _file.exists():
        raise FileNotFoundError(_file)

    # Parse contents of file and make it into a tree
    with open(str(_file)) as fd:
        tree = parse(fd, verbose=args.verbose)

    if args.doclass is not None:
        cls = tree.find_class(args.doclass)
        if cls is None:
            raise InvalidArgumentError("--class", "'%s' was not found" % args.doclass)
        opts = _process_keyvalue_options(args.formatter_option, '-F')
        return _print_class(cls, opts, args.format)

if __name__ == '__main__':
    main()

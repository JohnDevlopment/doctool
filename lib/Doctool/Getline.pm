package Doctool::Getline;

use 5.016_000;
use strict;
use warnings;

use Exporter;
our $VERSION = v0.1;
our @ISA = qw(Exporter);
our @EXPORT = qw(nextline prevline getline);


# Usage: _nextline string index
sub nextline {
    use Doctool::Util 'min';
    my ($string,$index) = @_;
    my $end = length($string) - 1;
    my $i = index($string, "\n", $$index);
    if ($i < 0) {
        $$index = $end;
    } else {
        $$index = min($i + 1, $end);
    }
}

# Usage: _prevline string index
sub prevline {
    my ($string,$index) = @_;
    my $i = rindex($string, "\n", $$index);
    if (abs($i - $$index) == 1) {
        $i = rindex($string, "\n", $$index - 2);
    }
    $$index = $i + 1;
}

# Usage: _getline string index
sub getline {
    # $start is a reference to a scalar

    # String and starting index
    my ($string,$start) = @_;

    # End of line (or end of string in case of no newline)
    my $end = index($string, "\n", $$start);
    if ($end < 0) {
        $end = length($string);
    }

    my $result = substr($string, $$start, $end - $$start);
    $$start = $end + 1; # Advance index to the next line
    return $result;
}

1;

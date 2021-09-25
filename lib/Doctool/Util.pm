package Doctool::Util;

use 5.016_000;
use Exporter;
use strict;
use warnings;
use Carp;

# ABSTRACT: Utility subroutines for Doctool

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(append echo funcref max min printarray printerr printhash readfile str strextract);
our $VERSION = v0.10;

# Usage: append SCALAR $value
sub append (\$$) {
    my $ref = shift;
    my $value = shift;

    $$ref = $$ref . $value;

    return;
}

# Same as print but adds a newline automatically
sub echo {
    return if scalar(@_) == 0;
    my $text = join(' ', @_);
    print($text, "\n");
}

# If the function exists, returns a reference to it
sub funcref {
    no strict 'refs';
    my $funcname = shift;
    return \&{$funcname} if defined &{$funcname};
    return;
}

# Print the contents of an array
sub printarray {
    croak _invalid_call('printarray', 'LIST|ARRAYREF') if scalar(@_) == 0;

    if (ref $_[0] eq 'ARRAY') {
        croak _invalid_call('printarray', 'LIST|ARRAYREF') if scalar(@_) != 1;

        my $ar = shift; # Reference
        echo $ar;
        for my $i (0 .. $#$ar) {
            echo str("\t$i : ", $ar->[$i]);
        }
        return;
    }

    my @ar = @_;
    for my $i (0 .. $#ar) {
        echo str("\t$i : ", $ar[$i]);
    }
}

# Prints to STDERR
sub printerr {
    return if scalar(@_) == 0;
    my $text = join(' ', @_);
    print(STDERR $text, "\n");
}

# Print the contents of a hash
sub printhash {
    croak _invalid_call('printhash', 'HASH|HASHREF') if scalar(@_) != 1;

    if (ref $_[0] eq 'HASH') {
        my $hash = shift; # Is reference
        echo $hash;
        foreach my $key (keys %$hash) {
            echo "\t$key :", $hash->{$key};
        }
        return;
    }

    my %hash = @_;
    echo(%hash);
}

# Returns the greater of the two
sub max ($$) {
    my ($a,$b) = @_;
    return ($a > $b) ? $a : $b;
}

# Returns the lesser of the two
sub min ($$) {
    my ($a,$b) = @_;
    return ($a < $b) ? $a : $b;
}

# Reads a file and returns the text
sub readfile {
    croak _invalid_call('readfile', 'file') if scalar(@_) != 1;

    my $file = shift;
    open(IN, '<', $file) or croak $!;

    my $text = '';
    while (<IN>) {
        append($text, $_);
    }

    close(IN);

    return $text;
}

# Stringizes one or more arguments
sub str ($@) {
    my $result = '';
    do {
        $result = $result . shift;
    } while (scalar(@_));

    return $result;
}

# Extracts characters based on a pattern
# Usage: strextract PATTERN STRING [GROUPLIST]
sub strextract {
    croak _argc_error("strextract", "pattern string [grouplist]") if (scalar(@_) < 2);

    # Switch to internal subroutine if in list context
    if (wantarray) {
        goto &_strextract_list;
    }

    my $pattern = shift;
    my $string = shift;

    my $success = $string =~ m/$pattern/;

    my $group = shift;
    if ($group) {
        if ($success) {
            my $r_group;
            if (eval "\$r_group = \\\$$group") {
                return $$r_group;
            }
        }
    } #elsif ($success) {
    #    return $&;
    #}

    return $& if ($success);
    return '';
}

# Returns the type of a variable (must be an lvalue)
sub typeof (\[@$%&]) {
    my $ref = shift;
    return ref($ref);
}

# _argc_error FUNCTION PARAMS
sub _argc_error {
    my ($function,$params) = @_;
    return sprintf(q/Invalid call to %s: should be %s %s/, $function, $params);
}

# _strextract_list PATTERN STRING [GROUPLIST]
sub _strextract_list {
    my $pattern = shift;
    my $string = shift;

    my @results = ();

    my $success = $string =~ m/$pattern/;
    return if (! $success);

    # Return the whole matched pattern
    if (scalar(@_) == 0) {
        while ($string =~ m/$pattern/g) {
            push(@results, $&);
        }
        return ($#results >= 1) ? @results : undef;
    }

    # Make a reference to each group match variable:
    # \$1, \$2, and so on.
    foreach my $group (@_) {
        my $r_group;

        if (eval "\$r_group = \\\$$group") {
            push(@results, $$r_group);
        }
    }

    return @results;
}

sub _invalid_call {
    my $funcname = shift;
    return sprintf('Invalid call to Doctool::Util::%s : Usage is %s %s', $funcname, $funcname, $_[0]);
}

=pod

=head1 NAME

Doctool::Util - Utility subroutines for Doctool

=head1 VERSION

Version 0.10

=head1 SYNOPSIS

This module exports a number of subroutines that help with the functionality of Doctool.
Strictly speaking, these subroutines are not only useful for I<Doctool>; they can be used in
general practice.

=head1 EXPORT

The following subroutines are exported by this module.

=over 4

=item append( variable, value )

Appends I<value> to the end of I<variable> and returns a reference to it.
Accepts an array or a scalar.

=item echo( arg, ... )

Prints out one or more arguments using the C<print> function.
The difference is that echo automatically appends a newline character

=item funcref( funcname )

Returns a reference to the function I<funcname> if it exists, otherwise it returns
C<undef>.

Use this function to test for the existtence of a particular function.

=item max( a, b )

Returns the greater of the two parameters.

=item min( a, b )

Returns the lesser of the two parameters.

=item printarray( array )

=item printarray( arrayref )

Prints the contents of an array. The parameter can be any valid array or array reference.

=item printerr( ARG, ... )

Prints one or more arguments to STDERR.

=item printhash( hash )

=item printhash( hashref )

Prints the contents of a hash. The parameter can be any valid hash or hash reference.

=item str( arg, ... )

Concatenates the arguments into a string. Requires at least one argument.

=item strextract( PATTERN, STRING )

=item strextract( PATTERN, STRING, GROUPLIST )

Extracts a substring from I<STRING> according to I<PATTERN>, which is expected to be a precompiled
regular expression. Use the qr() function (documented in L<perlfunc/qrE<sol>STRINGE<sol>>) to make
I<PATTERN>.

In the first form, strextract() extracts the portion of I<STRING> that matches I<PATTERN>, or
an empty string in the case of failure.
If it is called in a scalar context, only the first match is returned.
But in a list context a list of all matching substrings are returned.

In the second form, strextract() returns one or matches of subexpressions in I<PATTERN>.
In a scalar context only the first match is returned.
In a list context all matches are returned as an array, and each element corresponds to a group
number parameter. For example, C<strextract(qr/(like).*(donuts)/, $string, 1, 2)> will return
a list of strings that correspond to $1 and $2, respectively.

If in any case the pattern fails to match, an empty string is returned in scalar context, and an
empty array is returned in list context.

In all examples, assume the following:

    my $string = "I like donuts";

Example 1 (returning a whole match):

    my $match = strextract(qr/donuts/, $string);
    echo $match; # prints "donuts"

Example 2 (returning a subgroup of a match):

    my $match = strextract(qr/do(nuts)/, $string, 1);
    echo $string, "I like", $match; # prints "I like donuts! I like nuts"

Example 3 (getting multiple subexpression matches):

    my @matches = strextract(qr/(like).*(donuts)/, $string, 1, 2);
    echo @matches; # prints "like donuts"

=back

=cut

1;

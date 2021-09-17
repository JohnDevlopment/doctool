package Doctool::Util;

require Exporter;
use v5.10;
use strict;
use warnings;
use Carp;

# ABSTRACT: Utility subroutines for Doctool

our @ISA = qw(Exporter);
#our @EXPORT = qw();
our @EXPORT_OK = qw(append echo funcref max min printarray printhash push_back str);
#our @EXPORT_TAGS = ('all' => [@EXPORT, @EXPORT_OK]);
our $VERSION = v0.10;

# Usage: append array/scalar $value
sub append (\[@$]$) {
    my $ref = shift;
    my $type = ref($ref);
    my $value = shift;

    if ($type eq 'ARRAY') {
        my $count = scalar @$ref;
        $ref->[$count] = $value;
    } elsif ($type eq 'SCALAR') {
        $$ref = $$ref . $value;
    }

    return $ref;
}

# push_back ARRAY, VALUE
sub push_back (\@$) {
    my $ref = shift;
    my $value = shift;

    my $count = scalar @$ref;
    $ref->[$count] = $value;

    return $ref;
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

# Stringizes one or more arguments
sub str ($@) {
    my $result = '';
    do {
        $result = $result . shift;
    } while (scalar(@_));

    return $result;
}

# Returns the type of a variable
sub typeof (\[@$%&]) {
    my $ref = shift;
    return ref($ref);
}

sub _invalid_call ($$) {
    my $funcname = shift;
    return sprintf('Invalid call to Doctool::Util::%s : Usage is %s %s', $funcname, $funcname, $_[0]);
}

1;
__END__

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

Prints out one or more arguments using the C<print> function. The difference is
that echo automatically appends a newline character

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

=item printhash( hash )

=item printhash( hashref )

Prints the contents of a hash. The parameter can be any valid hash or hash reference.

=item str( arg, ... )

Concatenates the arguments into a string. Requires at least one argument.

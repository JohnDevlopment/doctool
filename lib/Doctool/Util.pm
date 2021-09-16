package Doctool::Util;

require Exporter;
use v5.10;
use strict;
use warnings;
use Carp;

# ABSTRACT: Utility subroutines for Doctool

our @ISA = qw(Exporter);
our @EXPORT = qw(append echo funcref max min printarray printhash str);
our @EXPORT_OK = ();
our @EXPORT_TAGS = ('all' => [@EXPORT, @EXPORT_OK]);
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
    croak _invalid_call('printarray', 'array|arrayref') if scalar(@_) == 0;

    if (ref $_[0] eq 'ARRAY') {
        croak _invalid_call('printarray', 'array|arrayref') if scalar(@_) != 1;

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
    croak _invalid_call('printhash', 'hash|hashref') if scalar(@_) != 1;

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

=back

=head1 AUTHOR

John Russell, C<< <john at cpan.org> >>

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Doctool-Util>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Doctool-Util>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Doctool-Util>

=item * Search CPAN

L<http://search.cpan.org/dist/Doctool-Util/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2021 John Russell.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package Doctool::Property;

use v5.10;
use strict;
use warnings;
use Exporter;
use Carp;

# ABSTRACT: Data container for GDScript properties

our $VERSION = v0.1;

# Construct a new object
sub new {
    my $class = shift;

    my $self = {
        name => 'property',
        type => 'int',
        default => '',
        brief => '',
        description => ''
    };
    bless $self, $class;

    return $self;
}

# Set a brief one-line description
sub brief {
    my $self = shift;
    my $argc = @_;

    if ($argc > 1) {
        croak _print_arg_error('brief', '[value]');
    }

    return $self->_set_get_attribute('brief', ($argc == 1) ? $_[0] : undef);
}

# Set the default value
sub default {
    my $self = shift;
    my $argc = @_;

    if ($argc > 1) {
        croak _print_arg_error('default', '[value]');
    }

    my $value = ($argc == 1) ? $_[0] : undef;

    # Type is String and value defined
    if ($self->type() eq 'String') {
        if ( defined($_[0]) ) {
            $value = qq/"$value"/;
        }
    }

    return $self->_set_get_attribute('default', $value);
}

# Set the full description
sub description {
    my $self = shift;

    if (scalar(@_) == 0) {
        return $self->{'description'};
    }

    if ( ref($_[0]) eq 'ARRAY' ) {
        $self->{'description'} = shift;
        return;
    }

    my @array = @_;
    $self->{'description'} = \@array;
}

# Get or set the name of the property
sub name {
    my $self = shift;
    my $argc = @_;

    if ($argc > 1) {
        croak _print_arg_error('name', '[value]');
    }

    return $self->_set_get_attribute('name', ($argc == 1) ? $_[0] : undef);
}

# Get or set the property's type
sub type {
    my $self = shift;
    my $argc = @_;

    if ($argc > 1) {
        croak _print_arg_error('type', '[value]');
    }

    return $self->_set_get_attribute('type', ($argc == 1) ? $_[0] : undef);
}

# Instanced internal functions

# Usage: _set_get_attribute attribute value
sub _set_get_attribute {
    my $self = shift;
    my $attribute = shift;
    my $value = shift;

    # Return or set the attribute
    if (! defined($value)) {
        return $self->{$attribute};
    }

    $self->{$attribute} = $value;

    return;
}

# Static internal functions

sub _print_arg_error {
    my ($funcname,$params) = @_;
    return sprintf('Invalid call to Doctool::Property::%s: usage is %s %s', $funcname, $funcname, $params);
}

=pod

=head1 NAME

Doctool::Property - The great new Doctool::Property!

=head1 VERSION

Version 0.1

=head1 SYNOPSIS

Manages objects that represent properties/variables in GDScript.

Perhaps a little code snippet.

    use Doctool::Property;

    my $foo = Doctool::Property->new();

Setting attributes:

    $foo->name("title");
    $foo->type("int");
    $foo->default(0);

Getting attributes:

    $foo->name(); # returns "title"
    $foo->type(); # returns "int"
    $foo->default(); # returns 0

=head1 METHODS

=over 4

=item new()

Constructs a Doctool::Property object.
All attributes are set to their default values.

=item brief( [value] )

Call this function to set or get the property's brief description. If a value is provided, that
value becomes the brief description of this property. But if no argument is provided, then the
current description is returned.

=item default( [value] )

Call this function to set or get the property's default value. If no arguments are present, returns
the current value. If an argument is provided, that becomes the property's default value.

=item description( ... )

Call this function to set or get the property's full description. Returns an array. If one or more
arguments are provided, they are combined into a list and set as the property's description.

=item name( [name] )

If called with no parameters, returns the current name of the property.
If called with a parameter, sets the new name of the property to NAME.

=item type( [type] )

Call this function to set or get the property's type. If no arguments are present, returns
the current type; otherwise sets the type of the parameter.

=back

=head1 AUTHOR

John Russell, C<< <john at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-doctool-property at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Doctool-Property>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Doctool::Property

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Doctool-Property>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Doctool-Property>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Doctool-Property>

=item * Search CPAN

L<http://search.cpan.org/dist/Doctool-Property/>

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

package Doctool::Property;

use 5.016_000;
use strict;
use warnings;
use Exporter;
use Carp;

our @ATTRIBUTES = qw(brief default description getter name setter type);

=head1 NAME

Doctool::Property - Data container for GDScript exported properties

=head1 METHODS

=over 4

=item new(  )

Constructs a C<Doctool::Property> object and returns a reference to it.

=cut

# Construct a new object
sub new {
    my $class = shift;

    my $self = {
        name => 'property',
        type => 'int',
        default => '',
        brief => '',
        description => [],
        getter => '',
        setter => ''
    };
    bless $self, $class;

    return $self;
}

=item get( ATTR )

Obtains the value associated with I<ATTR>.
I<ATTR> must be one of the attributes defined in L</ATTRIBUTES>.

=cut

sub get {
    my $self = shift;

    croak _print_arg_error('get', 'arg') if scalar(@_) != 1;

    my $param = shift;
    _check_attribute_exists($param);

    return $self->{$param};
}

=item set( ATTR, VALUE )

Sets the value associated with I<ATTR>.
I<ATTR> must be one of the attributes defined in L</ATTRIBUTES>.

=back

=cut

# Usage: set $arg $value
sub set {
    my $self = shift;

    croak _print_arg_error('set', 'arg value') if scalar(@_) != 2;

    my $param = shift;
    _check_attribute_exists($param);

    $self->{$param} = shift;
}

=head1 ATTRIBUTES

These are the attributes which are recognized by set() and get().

=over 4

=item brief

A brief one-line description of the property.

=item default

The property's default value.

=item description

Full description of the property.

=item getter

The property's getter function.

=item name

The name of the property.

=item setter

The property's setter function.

=item type

The property's type.

=back

=cut

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

# Usage: _print_arg_error $funcname $paramstring
sub _print_arg_error {
    my ($funcname,$params) = @_;
    return sprintf('Invalid call to Doctool::Property::%s: usage is %s %s', $funcname, $funcname, $params);
}

# Usage: _check_attribute_exists $string
sub _check_attribute_exists {
    no warnings 'experimental::smartmatch';
    my $attr = shift;

    if ( ! ($attr ~~ @ATTRIBUTES) ) {
        croak qq/Invalid attribute "$attr": must be one of / . join(', ', @ATTRIBUTES);
    }
}

1;

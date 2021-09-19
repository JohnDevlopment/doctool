package Doctool::Arg;

use v5.10;
use strict;
use warnings;
use Carp;

our @ATTRIBUTES = qw(name type default description);

sub new {
    my $class = shift;
    croak 'No arguments accepted' if scalar(@_) != 0;

    my $self = {
        type => 'example',
        name => '',
        default => '',
        description => ''
    };
    bless $self, $class;

    return $self;
}

# Usage: get $arg
sub get {
    my $self = shift;

    croak _print_arg_error('get', 'arg') if scalar(@_) != 1;

    my $param = shift;
    _check_attribute_exists($param);

    #croak qq/Invalid parameter "$param": must be a non-reference scalar/ if ref($param) ne '';

    return $self->{$param};
}

# Usage: set $arg $value
sub set {
    my $self = shift;

    croak _print_arg_error('set', 'arg value') if scalar(@_) != 2;

    my $param = shift;
    _check_attribute_exists($param);

    #croak qq/Invalid parameter "$param": must be a non-reference scalar/ if ref($param) ne '';

    $self->{$param} = defined($_[0]) ? $_[0] : '';
}

sub _check_attribute_exists {
    no warnings 'experimental::smartmatch';
    my $attr = shift;

    if ( ! ($attr ~~ @ATTRIBUTES) ) {
        croak qq/Invalid attribute "$attr": must be one of / . join(', ', @ATTRIBUTES);
    }
}

# Usage: _print_arg_error funcname, paramstring
sub _print_arg_error {
    my $funcname = shift;
    my $params = shift;

    return sprintf('Invalid call to Doctool::Arg::%s: usage is %s %s', $funcname, $funcname, $params);
}

=pod

=head1 NAME

Arg - Data container for generic typed arguments

=head1 METHODS

The following methods are exposed:

=over 4

=item get( PARAM )

Retrieves the value of an attribute. For a list of valid attributes, check L</ATTRIBUTES>

=item set( PARAM, VALUE )

Sets an attribute to b<VALUE>. For a list of valid attributes, check L</ATTRIBUTES>

=back

=head1 ATTRIBUTES

Valid attrutes are: default, description, name, type

=cut

1;

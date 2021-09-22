package Doctool::Arg;

use v5.10;
use strict;
use warnings;
use Carp;

our @ATTRIBUTES = qw(default name type);

=head1 NAME

Doctool::Arg - Data container for generic typed arguments

=head1 METHODS

=over 4

=item new(  )

Constructs a C<Doctool::Arg> object and returns a reference to it.

=cut

sub new {
    my $class = shift;
    croak 'No arguments accepted' if scalar(@_) != 0;

    my $self = {
        type => 'Variant',
        name => '',
        default => '',
        description => 'A variant type'
    };
    bless $self, $class;

    return $self;
}

=item as_text(  )

Returns a string which describes the argument.
Without a default value the string will look something like this: C<int example>.
But with a default value the string can look like this: C<int example = 0>.

=cut

sub as_text {
    my $self = shift;

    croak _print_arg_error('as_text', '') if scalar(@_) != 0;

    my $text = $self->{'type'} . ' ' . $self->{'name'};
    if ($self->{'default'}) {
        $text = $text . ' = ' . $self->{'default'};
    }
    return $text;
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

=item set( PARAM, VALUE )

Sets the value associated with I<ATTR>.
I<ATTR> must be one of the attributes defined in L</ATTRIBUTES>.

=cut

sub set {
    my $self = shift;

    croak _print_arg_error('set', 'arg value') if scalar(@_) != 2;

    my $param = shift;
    _check_attribute_exists($param);

    $self->{$param} = defined($_[0]) ? $_[0] : '';
}

=back

=head1 ATTRIBUTES

These are the attributes which are recognized by set() and get().

=over 4

=item default

The default value.

=item name

The name of the argument.

=item type

Argument type.

=back

=cut

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

1;

package Doctool::Signal;

use v5.10;
use strict;
use warnings;
use Carp;

our @ATTRIBUTES = qw(args brief description name);

=pod

=head1 NAME

Doctool::Signal - Data container for GDScript signals

=head1 METHODS

=over 4

=item new(  )

Constructs a C<Doctool::Signal> object and returns a reference to it.

=cut

sub new {
    my $class = shift;
    die 'No arguments accepted' if scalar(@_) != 0;

    my $self = {
        name => 'example',
        args => [],
        brief => '',
        description => ''
    };
    bless $self, $class;

    return $self;
}

=item add_arg( ARG )

Adds I<ARG> to the list of method arguments.
I<ARG> must be a C<Doctool::Arg> object.

=cut

# Usage: add_arg $arg
sub add_arg {
    my $self = shift;

    croak _print_arg_error('add_arg', 'arg') if scalar(@_) != 1;

    my $arg = shift;
    _check_is_arg_obj($arg);

    push($self->{'args'}->@*, $arg);
}

=item as_text(  )

Returns a string representation of the signal.
Supposing we have a signal named "test" with two arguments, one C<int> named 'a' and one C<bool>
named 'b', the output would be C<test(int a, bool b)>.

=cut

sub as_text {
    my $self = shift;

    croak _print_arg_error('as_text', '') if scalar(@_) != 0;

    my $arg_text = '';

    my $args = $self->{'args'};
    foreach my $a (@$args) {
        my $text = sprintf('%s %s', $a->get('type'), $a->get('name'));
        if ( $a->get('default') ne '' ) {
            $text = $text . ' = ' . $a->get('default');
        }
        $arg_text = $arg_text . $text . ', ';
    }
    $arg_text =~ s/,\s*$//;

    return sprintf('%s(%s)', $self->{'name'}, $arg_text);
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

    $self->{$param} = shift;
}

=item set_arg( INDEX, ARG )

Replaces the argument at I<INDEX> with I<ARG>.
I<ARG> must be a C<Doctool::Arg> object.

=back

=cut

# Usage: set_arg $index, $value
sub set_arg {
    use Scalar::Util 'blessed';
    my $self = shift;

    croak _print_arg_error('set_arg', 'index value') if scalar(@_) != 2;

    my ($index,$value) = @_;

    # Error checks
    croak "Invalid index $index" if ( $index > $self->{'args'}->$#* );
    _check_is_arg_obj($value);

    $self->{'args'}->[$index] = $value;
}

# _check_is_arg $value
sub _check_is_arg_obj {
    use Scalar::Util 'blessed';
    my $arg = shift;

    my $class = blessed($arg);
    if ( defined($class) && $class eq 'Doctool::Arg' ) {
        return 1;
    }

    croak "Argument needs to be an object of class Doctool::Arg";
}

# Usage: _check_attribute_exists $string
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

    return sprintf('Invalid call to Doctool::Signal::%s: usage is %s %s', $funcname, $funcname, $params);
}

=head1 ATTRIBUTES

These are the attributes which are recognized by set() and get().

=over 4

=item args

A list of C<Doctool::Arg> objects which specify the parameters for the signal.
Do not set this directly through set(). Instead use add_arg() or set_arg().

=item brief

A brief one-line description of the signal.

=item description

A full description of the signal.

=item name

The name of the signal.

=back

=cut

1;

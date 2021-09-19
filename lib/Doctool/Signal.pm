package Doctool::Signal;

use v5.10;
use strict;
use warnings;
use Carp;

our @ATTRIBUTES = qw(name args brief description);

sub new () {
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

# Usage: add_arg $name $type
sub add_arg {
    my $self = shift;

    croak _print_arg_error('get', 'arg') if scalar(@_) != 1;

    my $arg = shift;
    _check_is_arg_obj($arg);

    _push_back($self->{'args'}, $arg);
}

sub as_text {
    my $self = shift;

    croak _print_arg_error('get', '') if scalar(@_) != 0;

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

# Usage: get $arg
sub get {
    my $self = shift;

    croak _print_arg_error('get', 'arg') if scalar(@_) != 1;

    my $param = shift;
    _check_attribute_exists($param);

    return $self->{$param};
}

# Usage: set $arg $value
sub set {
    my $self = shift;

    croak _print_arg_error('set', 'arg value') if scalar(@_) != 2;

    my $param = shift;
    _check_attribute_exists($param);

    $self->{$param} = shift;
}

# Usage: set_arg $index, $value
sub set_arg {
    use Scalar::Util 'blessed';
    my $self = shift;

    croak _print_arg_error('set', 'arg index value') if scalar(@_) != 2;

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

# push_back \$array, $value
sub _push_back {
    my $ref = shift;
    die 'Not an array reference' if ref($ref) ne 'ARRAY';

    my $value = shift;

    my $index = scalar @$ref;
    $ref->[$index] = $value;

    foreach (@_) {
        $ref->[++$index] = $_;
    }

    return;
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

    return sprintf('Invalid call to Doctool::Signal::%s: usage is %s %s', $funcname, $funcname, $params);
}

=pod

=head1 NAME

Signal - Data container for Godot signals

=head1 METHODS

These are the methods you can use.

=over 4

=item add_arg( ARG )

Adds an argument to the signal. It is appened to the back of the list.

Example:

    $arg = Doctool::Arg->new();
    $arg->set('name', 'example');
    $arg->set('type', 'int');
    $arg->set('default', 0);

    $sig->add_arg($arg);

=item as_text(  )

Returns a string with the signal definition.

=item get( PARAM )

Retrieves the value of an attribute. For a list of valid attributes, check L</ATTRIBUTES>

=item set( PARAM, VALUE )

Sets an attribute to B<VALUE>. For a list of valid attributes, check L</ATTRIBUTES>

=item set_arg( INDEX, ARG )

Sets the specified index of 'arg' (see L</ATTRIBUTES>) to I<ARG>. I<ARG> must be an object of Doctool::Arg.
Also, I<INDEX> must be valid; it cannot refer to an arg that doesn't exist.

=back

=head1 ATTRIBUTES

These are the attributes which are recognized by set() and get().

=over 4

=item args

A list of Doctool::Arg objects which specify the parameters for the signal.
Do not set this directly through set(). Instead use add_arg() or set_arg().

=item brief

A brief one-line description of the signal.

=item description

A full description of the signal.

=item name

The name of the signal

=back

=cut

1;

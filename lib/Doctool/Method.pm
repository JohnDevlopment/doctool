package Doctool::Method;

use 5.016_000;
use strict;
use warnings;
use Carp;

our @ATTRIBUTES = qw(args brief const description name returntype returnvalue virtual);

=head1 NAME

Doctool::Method - Data container for GDScript methods

=head1 METHODS

=over 4

=item new(  )

Constructs a C<Doctool::Method> object and returns a reference to it.

=cut

sub new {
    my $class = shift;
    die 'No arguments accepted' if scalar(@_) != 0;

    my $self = {
        name => 'example',
        args => [],
        brief => '',
        description => [],
        returntype => '',
        returnvalue => '',
        virtual => 0,
        const => 0
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

    croak _print_arg_error('add_arg', 'arg') if (scalar(@_) != 1);

    my $arg = shift;
    _check_is_arg_obj($arg);

    push($self->{'args'}->@*, $arg);
}

=item as_text(  )

Returns a string describing the method.
An example would be C<int max(int a, int b)>.
The string also factors in default values, so the following could come out:
C<bool open(String file, int mode = 0)>.

If the C<const> attribute is set, "const" is appended to the end of the string output.
For example, with the C<const> attribute the output could look like this:
C<int size() const>.

If the C<virtual> attribute is set, "virtual" is prepended to the beginning of the string output.
For example, with the C<virtual> attribute the output could look like this:
C<virtual int size()>.

=cut

# Usage: as_text
sub as_text {
    my $self = shift;

    croak _print_arg_error('as_text', '') if scalar(@_) != 0;

    my $arg_text = '';
    my $args = $self->{'args'};
    foreach my $a (@$args) {
        $arg_text = $arg_text . $a->as_text() . ', ';
    }
    $arg_text =~ s/,\s*$//;

    my $sig;
    {
        my $return_type = $self->{'returntype'};
        $sig = sprintf('%s %s(%s)', ($return_type) ? $return_type : 'void', $self->{'name'}, $arg_text);

        my $virtual = $self->{'virtual'};
        if ($virtual) {
            $sig = 'virtual ' . $sig;
        }

        my $const = $self->{'const'};
        if ($const) {
            $sig = $sig . ' const';
        }
    }

    return $sig;
}

=item clear_args(  )

Clears the list of arguments, making array empty.

=cut

sub clear_args {
    my $self = shift;

    croak _print_arg_error('clear_args', '') if scalar(@_) != 0;

    my $r_args = $self->{'args'};
    splice @$r_args;
}

=item find_arg( FIELD, PATTERN )

Attempts to find the argument with the given I<FIELD> that matches I<PATTERN>.

If the pattern matches, then the C<Doctool::Arg> object that matches is returned.
Only the first match is returned.

=cut

sub find_arg {
    no warnings 'experimental::smartmatch';
    my $self = shift;

    croak _print_arg_error('find_arg', 'field pattern') if scalar(@_) != 2;

    my ($attribute,$pattern) = @_;

    foreach my $arg ( $self->{'args'}->@* ) {
        if ( $arg->get($attribute) ~~ $pattern ) {
            return $arg;
        }
    }
    return;
}

=item get( ATTR )

Obtains the value associated with I<ATTR>.
I<ATTR> must be one of the attributes defined in L</ATTRIBUTES>.

=cut

# Usage: get $attr
sub get {
    my $self = shift;

    croak _print_arg_error('get', 'attr') if scalar(@_) != 1;

    my $param = shift;
    _check_attribute_exists($param);

    return $self->{$param};
}

=item set( PARAM, VALUE )

Sets the value associated with I<ATTR>.
I<ATTR> must be one of the attributes defined in L</ATTRIBUTES>.

=cut

# Usage: set $arg $value
sub set {
    my $self = shift;

    croak _print_arg_error('set', 'arg value') if scalar(@_) != 2;

    # TODO: don't allow to set 'args' directly

    my $param = shift;
    _check_attribute_exists($param);

    my $value = shift;
    $self->{$param} = defined($value) ? $value : '';
}

=item remove_arg( INDEX )

Removes the argument specified by I<INDEX> from the list.

Internally, this method uses splice() to remove the specified index from an array.

=cut

sub remove_arg {
    my $self = shift;

    croak _print_arg_error('remove_arg', 'index') if scalar(@_) != 1;

    my $index = shift;
    croak "Invalid index $index" if ( $index > $self->{'args'}->$#* );

    my $r_args = $self->{'args'};
    splice @$r_args, $index, 1;
}

=item set_arg( INDEX, VALUE )

Sets the method argument at I<INDEX> to I<VALUE>.
I<VALUE> must be an object of C<Doctool::Arg>.

=cut

sub set_arg {
    my $self = shift;

    croak _print_arg_error('set_arg', 'index value') if scalar(@_) != 2;

    my ($index,$value) = @_;

    croak "Invalid index $index" if ( $index > $self->{'args'}->$#* );

    #if ( ! defined($value) ) {
    #    $self->{'args'}->[$index] = undef;
    #}

    _check_is_arg_obj($value) if defined($value);

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

=back

=head1 ATTRIBUTES

=over 4

=item args

A list of the function arguments.
Each element must be an object of L<Doctool::Arg>.
Do not attempt to set this attribute directly through set(). Instead, use set_arg() and
add_arg() to manipulate the argument list.

=item brief

A brief one-line description of the method.

=item const

A boolean to describe whether the method is const (doesn't modify class variables).

=item description

A full description of the method.

=item name

The name of the method.

=item returntype

The return type of the method.

=item returnvalue

A description of the return value.

=item virtual

A boolean to describe whether the method is virtual.

=back

=cut

1;

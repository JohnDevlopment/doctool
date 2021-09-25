package Doctool::Enum;

use 5.016_000;
use strict;
use warnings;
use Carp;

our @ATTRIBUTES = qw(brief name members);

=head1 NAME

Doctool::Enum - Data container for GDScript enumerations

=head1 METHODS

=over 4

=item new( ... )

Constructs a C<Doctool::Enum> object and returns a reference to it.
The user can optionally provide a list of flags that set the attributes of the object.
Said attributes are the ones listed in L</ATTRIBUTES>.

=cut

sub new {
    my $class = shift;

    my $self = {};

    # arguments are key/value pairs
    my $argc = @_;
    if ($argc) {
        croak "need an even number of arguments" if ( $argc % 2 );
        my %defaults = (name => '', brief => '', members => []);
        my %opts = (@_);

        foreach my $attr (@ATTRIBUTES) {
            if (exists $opts{$attr}) {
                $self->{$attr} = $opts{$attr};
            } else {
                $self->{$attr} = $defaults{$attr};
            }
        }
    } else {
        $self = {
            brief => '',
            name => '',
            members => []
        };
    }

    return bless $self, $class;
}

=item add_constant( NAME, VALUE, BRIEF )

Adds a constant to the enumeration with the specified I<NAME>, I<VALUE>, and I<BRIEF>.
The enumeration is added to the end of the list.

=cut

# add_constant NAME, VALUE, BRIEF
sub add_constant {
    my $self = shift;

    croak _argc_error('add_constant', 'name value brief') if scalar(@_) != 3;

    my %constant = ();
    $constant{'name'} = shift;
    $constant{'value'} = shift;
    $constant{'brief'} = shift;

    push($self->{'members'}->@*, \%constant);

    return;
}

=item clear_constants(  )

Clears the list of constants in the enumeration.

=cut

# clear_constants
sub clear_constants {
    my $self = shift;

    croak _argc_error('add_constant', '') if scalar(@_) != 0;

    splice $self->{'members'}->@*;
}

=item get( ATTR )

Obtains the value associated with I<ATTR>.
I<ATTR> must be one of the attributes defined in L</ATTRIBUTES>.

=cut

# get ATTR
sub get {
    my $self = shift;

    croak _argc_error('get', 'arg') if scalar(@_) != 1;

    my $param = shift;
    _check_attribute_exists($param);

    return $self->{$param};
}

=item set( ATTR, VALUE )

Sets the value associated with I<ATTR>.
I<ATTR> must be one of the attributes defined in L</ATTRIBUTES>.

=back

=cut

# set ATTR, VALUE
sub set {
    my $self = shift;

    croak _argc_error('set', 'arg value') if scalar(@_) != 2;

    my $param = shift;
    _check_attribute_exists($param);

    $self->{$param} = shift;
}

sub _array_search (\@$) {
    no warnings 'experimental::smartmatch';

    my ($r_array,$param) = @_;
    foreach my $i (0 .. $r_array->$#*) {
        if ($param ~~ $r_array->[$i]) {
            return $i;
        }
    }
    return -1;
}

=head1 ATTRIBUTES

These are the attributes which are recognized by set() and get().

=over 4

=item brief

A brief one-line description of the enumeration.

=item members

A list of constants that belong to the enumeration.
Each constant is a hash reference with the fields 'name', 'brief', and 'value'.

=back

=cut

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

sub _check_attribute_exists {
    no warnings 'experimental::smartmatch';
    my $attr = shift;

    if ( ! ($attr ~~ @ATTRIBUTES) ) {
        croak qq/Invalid attribute "$attr": must be one of / . join(', ', @ATTRIBUTES);
    }
}

# _argc_error FUNCTION, PARAMS
sub _argc_error {
    my ($function,$params) = @_;
    return sprintf(q/Invalid call to %s: should be %s %s/, $function, $function, $params);
}

1;

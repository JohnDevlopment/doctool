package Doctool::Property;

use v5.10;
use strict;
use warnings;
use Exporter;
use Carp;

# Construct a new object
sub new {
    my $class = shift;

    my $self = {
        name => 'property',
        type => 'int',
        default => '',
        brief => '',
        description => '',
        getter => '',
        setter => ''
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

    return $self->_set_get_attribute('default', ($argc == 1) ? $_[0] : undef);
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

# Set or get the name of a getter function
sub getter {
    my $self = shift;
    my $argc = @_;

    if ($argc > 1) {
        croak _print_arg_error('getter', '[funcname]');
    }

    return $self->_set_get_attribute('getter', ($argc == 1) ? $_[0] : undef);
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

# Set or get the name of a setter function
sub setter {
    my $self = shift;
    my $argc = @_;

    if ($argc > 1) {
        croak _print_arg_error('setter', '[funcname]');
    }

    return $self->_set_get_attribute('setter', ($argc == 1) ? $_[0] : undef);
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

1;

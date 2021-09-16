#!/usr/bin/perl

use Doctool::Property;
use Doctool::Util qw(append echo funcref str);
#no warnings;

my $prop = Doctool::Property->new();

#echo "Name is:", $prop->name;

$prop->name('Hello');

echo "Name is:", $prop->name;

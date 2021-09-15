#!/usr/bin/perl

#use Doctool::Property;
use Doctool::Util qw(append echo funcref str);
#no warnings;

my $text = '<table>';
echo $text;
append($text, '</table>');
echo $text;

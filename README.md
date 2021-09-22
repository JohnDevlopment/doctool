Doctool
=======

* [Doctool](#doctool)
* [Installation](#installation)
    * [Dependencies](#dependencies)
        * [Perl Modules](#perl-modules)
        * [Installing Perl Modules](#installing-perl-modules)

Doctool is a Perl-based program I've written for the sole purpose of generating doc files for my custom classes, written in GDScript.

As of right now, the following goals are met:

- [X] Create "header" section with the class name and description
- [X] Create "properties" section with a list of exported properties
- [X] Create "signals" section with a list of defined signals
- [X] Create "methods" section with a list of exposed methods

There is more work to do with polishing and debugging this script, but the skeleton is complete.

Installation
============

Simply extract this repository into its own directory and run `class_doc_tool`.
It runs on Perl, so you need a Perl interpreter.
Minimum version is 5.10.

## Dependencies

### Perl Modules

* String::Util
* Readonly

### Installing Perl Modules

But official channels recommend this method instead:

    cpanm MODULENAME

The method I use is to go into the cpan shell with `cpan`. From there type the following:

    install MODULENAME

Either way, replace "MODULENAME" with the name of a Perl module. The required modules are
listed above in the section [#perl-modules]

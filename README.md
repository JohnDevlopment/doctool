# Doctool

**Doctool** is a Perl-based program I've written for the sole purpose of generating doc files for my
custom classes, written in GDScript.

## Version History

Version 1.2 beta. This is safe to use in production, but the use of the experimental `@img` tag is
not recommended.

## Installation

Simply extract the contents of the archive into its own directory. Or clone this repository for the same effect.

### Dependencies

* Perl version 5.10 or later
* Perl modules
    * String::Util
    * Readonly

You can install Perl modules from the commandline, and there are two ways to do so.

#### Method 1

The method I use is to go into the cpan shell by typing `cpan`.
You will see a line that says `cpan[1]>` or something similar---that is the command prompt.

From the command prompt, you type the following:

    install MODULENAME

Replacing "MODULENAME" with the actual name of the module you want to install
(see [Dependencies](#dependencies)).

However, the Perl developers and module creators seem to recommend method 2.

#### Method 2

Type this into the console:

    cpanm MODULENAME

This is a slightly quicker (less typing) way of installing a module.
If you do not have cpanm installed, you can do method 1 above or install a package named "cpanminus"
using your package manager.

## Usage

	class_doctool FILE

Doctool reads from a file written in GDScript and prints HTML to standard output. Doctool uses [template.html](template.html) as a template for the final HTML output. You can read it to see how it works.

## Documentation

Read the [documentation guide](https://github.com/JohnDevlopment/doctool/wiki/Documentation-Guide) to learn how to create documentations for Godot scripts.

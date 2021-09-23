Doctool
=======

* [Doctool](#doctool)
* [Installation](#installation)
    * [Dependencies](#dependencies)
        * [Installing Dependencies](#installing-dependencies)
            * [Method 1](#method-1)
            * [Method 2](#method-2)
* [Usage](#usage)
    * [Class Documentation Syntax](#class-documentation-syntax)
        * [Terminology](#terminology)
    * [Class Documentation Structure](#class-documentation-structure)
        * [Universal Tags](#universal-tags)
            * [Section Tags](#section-tags)
            * [Formatting Tags](#formatting-tags)
            * [Data Tags](#data-tags)
        * [Class](#class)
        * [Properties](#properties)
            * [Data Tags](#data-tags)
        * [Signals](#signals)
            * [Data Tags](#data-tags)
        * [Methods](#methods)

**Doctool** is a Perl-based program I've written for the sole purpose of generating doc files for my
custom classes, written in GDScript.

As of right now, the following goals are met:

- [X] Create "header" section with the class name and description
- [X] Create "properties" section with a list of exported properties
- [X] Create "signals" section with a list of defined signals
- [X] Create "methods" section with a list of exposed methods
- [ ] Create "constants" section with a list of defined constants
- [ ] Create "enums" section with a list of defined enumerations

Installation
============

Simply extract the files in this repository into their own directory.

## Dependencies

* Perl version 5.10 or later
* Perl modules
    * String::Util
    * Readonly

### Installing Dependencies

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

Usage
=====

Doctool reads GDScript files and generates HTML files based off of a template.
To use it, the commandline is `class_doctool file`, where "file" is a path to the GDScript file
you want to process.

## Class Documentation Syntax

In Doctool, all documentations start with a comment line beginning with two pounds (#), an optional
space, and an optional brief description of the documented entity:

    ## Container and controller of states
    # @desc  A StateMachine controls the state of an object, referred internally as the persistent state.
    #        Any child that is a @class State will be added to an internal array of states.
    #        The first child that is a @class State will be the first index in said array, and so on.
    #
    #        To change which state is currently active, call @function change_state.
    class_name StateMachine
    extends Node

### Terminology

For the purposes of this README, the terms listed below have specific meanings:

&bullet; tag  
A tag is identified by an at-sign followed a word.
An example of one would be `@desc`.
There are three types of tags, differentiated by how they're parsed: section tags, data tags, and
formatting tags.

&bullet; tag-parameter  
For tags that take parameters, said parameters are called *tag-parameters*.
This is to distinguish between tag-parameters and, for example, parameters to a method being documented.

## Class Documentation Structure

The following headers describe the sections of the header and the tags they support.
It should be noted that there tags which are supported across all sections.
Such tags are described under [Universal Tags](#universal-tags).

### Universal Tags

#### Section Tags

&bullet; `desc`  
Starts a section of the documented entity for the description.
Currently this is the only section tag that Doctool supports.
This may change in future versions.

#### Formatting Tags

Formatting tags have the following syntax, of which there are two variations:

    @tag text
    @tag{multiword text}

In the first form, a tag modifies a single word; non-word characters such as '@' or puncutation
characters do not match.
But in the second form, which uses curly braces, more than one word can be enclosed at once.

&bullet; `a`  
Used to denote an argument, either to a function or a signal.
Italicizes the tag-parameter.

&bullet; `b`  
Emboldens the tag-parameter.

&bullet; `class`  
Encloses the tag-parameter in HTML `<code="class">` tags, which has different formatting than
generic `<code>` tags.

&bullet; `code`  
Encloses the tag-parameter in HTML `<code>` tags.

&bullet; `function`  
Encloses the tag-parameter in HTML `<code="function">` tags, which has different formatting than
generic `<code>` tags.

#### Data Tags

Data tags are specific to different sections of the documentation structure, so they will be
described therein.

### Class

In order for Doctool to start processing a file, it needs first to document the class itself.
This section is the only mandatory section in the documentation.

The way you start a class documentation is to start a comment block at the very top of the file,
like this:

    ## Container and controller of states
    # @desc  A StateMachine controls the state of an object, referred internally as the persistent state.
    #        Any child that is a @class State will be added to an internal array of states.
    #        The first child that is a @class State will be the first index in said array, and so on.
    #
    #        To change which state is currently active, call @function change_state.
    class_name StateMachine
    extends Node

Notice the inclusion of `class_name` and `extends`.
Both of those declarations are neccessary in order for Doctool to process this file.

### Properties

Godot has exported properties, which are visible in the editor and can be considered the "parameters"
of the object.
Such properties are documented in their own section of the documentation.

This is a real-life example of an exported property from one of my own classes.

    ## The node being manipulated by the states
    # @type  NodePath
    # @desc  This path refers to a @class Node which acts as the persistent state of the
    #        machine. Basically, it is the parent of all the states, the main state from which
    #        the other states are working.
    export(NodePath) var root_node: NodePath

Doctool reads the property definition to get the name of the property, so there is no need for a tag
that specifies the name.

Doctool is looking for *exported* properties, which means that the `export` keyword should be there;
however, Doctool doesn't require the `export` keyword in order to document the property.
Consequently, all of the following lines are permitted.

    # With 'export'
    export(String) var file = ""
    export var file: String = ""
    export var file := ""
    # Without
    var file = ""
    var file: String = ""
    var file := ""

Why does Doctool now require `export` for exported properties?
Because there are properties that can be exported through the `_get_property_list` method.
As a matter of fact, I do that for some of my own classes, which is why I made it this way.

#### Data Tags

Unless otherwise noted, these tags are optional.

&bullet; default  
Syntax: `@default VALUE`  
Indicates that *VALUE* is this property's default value.

&bullet; getter  
Syntax: `@getter FUNCTION`  
Indicates that *FUNCTION* is this property's registered getter function.

&bullet; setter  
Syntax: `@setter FUNCTION`  
Indicates that *FUNCTION* is this property's registered setter function.

&bullet; type (required)  
Syntax: `@type TYPE`  
Describes the type of the property---this tag is *required* for Doctool to accept this property.

### Signals

Here is a signal that I defined for one of my classes.

    ## Indicates that the state should be changed.
    # @arg  int  new_state  An integer denoting the desired state
    # @desc                 The @class StateMachine reacts to this signal and
    #                       changes to the state indiciated by @i new_state.
    signal state_change_request(new_state)

Like with properties, Doctool gets the name of the signal by reading the signal definition.
In this example the name of the signal is "state_change_request".

#### Data Tags

Unless otherwise noted, these tags are optional.

&bullet; arg  
Syntax: `@arg TYPE NAME BRIEF`  
This tag describes one of the signal's parameters and causes it to be included in the signal documentation.
The tag-parameters are, in order: the type of the signal argument, its name, and a brief description of it.
If all three tag-parameters are not provided, then *NAME* will be excluded from the documentation.

### Methods

Methods are easily the most complicated part of this yet.
Here is an example of what I mean:

    ## Change to a different state
    # @desc  Call this function to switch to a different state in the machine.
    #        If @arg next_state exists, then the state machine switches to that state immediately.
    #
    #        Before switching to a new state, the old state's @function cleanup method is invoked.
    #        Then after switching to the new state, its @function setup method is invoked.
    func change_state(next_state: int) -> int:
        ...

Unlike the other sections, Doctool completely relies on reading the function signature to get
things like the name, parameters, and the return type.
As you can see, the example function returns `int`.
But if no return type is specified for this method, Doctool just lists it as `Variant`.

# Doctool

A GDScript documentation tool written in Python.

This project uses two files from GDQuest's [gdscript docs maker]:
`ReferenceCollector.gd` and `ReferenceCollectorCLI.gd`.

# Dependencies

Python3.7 or newer.

# Version

2.0 prealpha

# Testing

I test `doctool` with the following steps:

Clone this repository and switch to its directory: `cd doctool`.

Next, start a virtual environment and setup the Python files:

``` sh
source .venv/bin/activate
python3 -m venv .venv
ln -s -T $(realpath src/doctool) .venv/lib/python3.10/site-packages/doctool
```

If you don't have Python 3.10 installed,
the subfolder will say `pythonX`,
where *X* is the version of Python on your system.

Now run `python -m doctool` to test whether or not `doctool` was properly installed in your virtual environment.
The output should look like this:

	usage: doctool [-h] [-v] [--class CLASS] [-f {text,html}] [-F OPTION] INPUTFILE
	doctool: error: the following arguments are required: INPUTFILE

[gdscript docs maker]: https://github.com/GDQuest/gdscript-docs-maker

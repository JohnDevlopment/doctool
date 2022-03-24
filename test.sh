#!/bin/bash

new=1
update=0
display=1
debug=0
test=0

declare -r RED="\033[;31m"
declare -r RESET="\033[0m"

read -d "\0" -s usage <<EOF
Usage: test.sh [-dtDT] class/file
       test.sh -h

Options:
  -h        Display this help message.
  -d        Debug the doctool script.
  -t        Test the HTML output by displaying the temp file in browser.
  -T        Test the HTML output but do not display the temp file in browser.
            Implicitly passes the -D option.
  -D        Do not open the HTML output in browser.
EOF

printcolor() {
    echo -e "$@"
}

onexit() {
    test -f "$tmpfile" && rm -v "$tmpfile"
}

openfile() {
    local file=${1:?no file}
    brave-browser "$file"
    sleep 1
    exit
}

catfile() {
    local file=${1:?no file}
    local text=$(cat "$file")

    if [ $? -eq 0 ]; then
        echo -e "output:\n\"\n$text\n\""
        printcolor "${RED}done catting $tmpfile$RESET"
    fi

    exit
}

while getopts ':dDtTh' OPTOPT; do
    case ${OPTOPT} in
        d)
            debug=1
            ;;
        D)
            display=0
            ;;
        T)
            display=0
            test=1
            update=0
            new=0
            debug=0
            ;;
        t)
            test=1
            update=0
            new=0
            debug=0
            display=1
            ;;
        h)
            echo "$usage"
            exit 1;
            ;;
        *)
            ;;
    esac

    shift
done

# Class name or file path (full or relative)
param="$1"

# Missing or empty parameter
if [ -z "$param" ]; then
    echo 'Missing argument: class name' >&2
    echo "$usage"
    exit 1
fi

# $param is a file:
if [ -f "$param" ]; then
    infile="$param"
    temp=$(basename "$infile")
    out=html/${temp%.*}.html
else
    # Class name
    infile="$param.gd"
    out=html/$param.html
fi

# Is it a new file?
test -f $out && new=0

# Debugging perl if flag set
if [ $debug -ne 0 ]; then
    printcolor "${RED}debugging class_doctool${RESET}"
    exec perl -d ./class_doctool "$infile"
fi

# Create temp file
temp=$(basename "${param%.*}")
tmpfile=$(mktemp ${temp}XXX.html)
./class_doctool "$infile" > $tmpfile && echo "HTML written to $tmpfile"

trap onexit EXIT

# Open the temp file before deleting it
if [ $test -ne 0 ]; then
    if [ $display -ne 0 ]; then
        openfile $tmpfile
    else
        catfile $tmpfile
    fi
fi

# Target file exists: check differences between it and the temp file
if [ $new -eq 0 ]; then
    diff $tmpfile $out > /dev/null
    test $? -eq 1 && update=1
else
    update=1
fi

# Update the target file
if [ $update -ne 0 ]; then
    mv --force --verbose $tmpfile $out
fi

# If the file is to be displayed
if [ $display -ne 0 ]; then
    openfile $out
fi

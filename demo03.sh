#!/bin/sh

# simple plagiarism checker, similar to lecture example 
# originally written by Andrew Taylor 2020
# https://cgi.cse.unsw.edu.au/~cs2041/20T2/code/shell/plagiarism_detection.simple_diff.sh 

# Run as plagiarism_detection.simple_diff.sh <files>

# Report if any of the files are copies of each other
# will report twice, as there is no 'break' implemented in sheeple

for file1 in "$@"
do
    for file2 in "$@"
    do
        diff=`diff -i -w "$file1" "$file2"`
        if test "$file1" = "$file2"
        then
            echo "skip, file is itself"
        elif test -z $diff
        then
            echo "$file1 is a copy of $file2"
        fi
    done
done
#!/bin/sh

# code written for lab02 echon.sh, by Giuliana De Bellis z5309331

# given two args, and an int and a string
# print string n times

i=0

if test "$#" -ne 2
then
    echo "Usage: $0 <number of lines> <string>"
    exit 64
fi

while test $i -lt "$1"
do 
    echo $2
    i=$((i + 1))
done
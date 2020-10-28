#!/bin/sh

# script I used to run all my test files and compare output

for file in test0*.sh
do
    echo $file
    ./sheeple.pl $file > tmp.pl
    perl tmp.pl "$@" > out
    ./$file "$@" > exp
    diff=$(diff -w "exp" "out")

    if test "$diff"
    then
        echo "Expected output vs actual output"
        echo "-------------------------------"
        echo "$diff"
    fi

    if test ! "$diff"
    then
        echo "Expected output matches actual output"
    fi

    echo '
    '

done
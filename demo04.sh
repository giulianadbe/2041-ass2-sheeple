#!/bin/sh

# test whether the specified integer is prime

# tutorial question from week 3
# my solution matches tutorial solution for is_prime.sh
# found at https://cgi.cse.unsw.edu.au/~cs2041/20T2/tut/03/answers

if test $# -ne 1
then
    echo "Usage: $0 <number>"
    exit 1
fi

n=$1

i=2
while test $i -lt $n
do
    result=`expr $n % $i`
    if test $result -eq 0
    then
        echo "$n is not prime"
        exit 1
    fi
    i=`expr $i + 1`
done
echo "$n is prime"
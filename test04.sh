#!/bin/dash

# testing of system calls with `` and $()

test00=`cat test00.sh`
echo "$test00"

test01=$(cat test01.sh)
echo "$test01"

exit 0
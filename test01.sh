#!/bin/dash

# test various for loops with non-standard data

echo "loop 1"
for var in "$@"
do
    echo "$var"
done

echo "loop 2"
for var in "$*"
do
    echo "$var"
done

echo "loop 4"
for var in *.[ch]
do
    echo "$var"
done

echo "loop 4"
for var in *.c
do
    echo "$var"
done

echo "loop 5"
for var in *
do
    echo "$var"
done

echo "loop 6"
for var in $@
do
    echo "$var"
done

echo "loop 7"
for var in $*
do
    echo "$var"
done

echo "loop 8"
for var in $#
do
    echo "$var"
done

echo "loop 9"
for var in "$#"
do
    echo "$var"
done

echo "loop 10"
for var in "$1"
do
    echo "$var"
done

echo "loop 11"
for var in $1
do
    echo "$var"
done

echo "loop 12"
for var in test0?.c
do
    echo "$var"
done

echo "loop 13"
for animal in "dog cat 'fruit bat' elephant"
do 
    echo "I want a $animal for a pet"
done

echo "loop 14"
for animal in dog cat 'fruit bat' elephant
do
    echo "I want a $animal for a pet"
done
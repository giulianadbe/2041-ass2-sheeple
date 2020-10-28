#!/bin/dash

# test while loops with interesting conditions

echo "loop 1"
x=1
while [ $x -le 3 ]
do
    echo "Num $x"
    x=$(( $x + 1 ))
done

echo "loop 2"
counter=5
factorial=1
while [ $counter -gt 0 ]
do
   factorial=$(( $factorial * $counter ))
   counter=$(( $counter - 1 ))
done
echo $factorial

# echo "loop 3"
# while read line
# do
#     echo $line
# done
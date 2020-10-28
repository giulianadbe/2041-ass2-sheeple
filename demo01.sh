#!/bin/sh
#
# code from lab02, written by Giuliana De Bellis z5309331
# seq.sh -- print out a seqence of integers to the screen
# 

start=1
step=1
finish=10

if [ $# -eq 1 ]
then
    start=1
    step=1
    finish=$1   #the first arg we were passed
elif [ $# -eq 2 ]
then
    start=$1
    step=1
    finish=$2
elif [ $# -eq 3 ]
then
    start=$1
    step=$3
    finish=$2
else
    echo "usage: $0 <start> <finish> <step>"   #print an error message (send to stderr)
    #$0 is the name of the file
    exit 64 # EX_USAGE, error code
fi

i=$start
while [ $i -le $finish ]
do
    echo $i
    $i=$(( i + step )) # or $(expr $i + 1)

done
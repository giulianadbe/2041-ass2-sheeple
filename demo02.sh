#!/bin/sh

# code from lab02 file_sizes.sh, altered to count amount of files
# written by Giuliana De Bellis z5309331

# names of files in directiory plit into three categories:
# small (< 10 lines), medium-sized (< 100 lines) and large

small=0
medium=0
large=0

for file in *
do 
    lines=$(cat $file | wc -l)
    if [ $lines -lt 10 ]
    then
        small=`expr $small + 1`
    elif [ $lines -lt 100 ]
    then
        medium=`expr $medium + 1`
    else
        large=`expr $large + 1`
    fi
done

echo "Small files:$small"
echo "Medium-sized files:$medium"
echo "Large files:$large"
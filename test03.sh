#!/bin/dash

# test if statements with interesting conditions

factorial=1000

if [ $factorial -lt 1000 ]
then
    echo "Picked a small number"
fi

status="working"
another="working"
if [ $status = 'working' ]
then
    echo "yay"
fi

if [ $status = $another ]
then
    echo "yay"
fi

if [ 'working' = 'working' ]
then
    echo "yay"
fi

if [ 'more' != $status ]
then
    echo "yay"
fi

if [ 0 -lt $factorial ]
then
    echo "Picked a small number"
fi

if test 'hello' = 'goodbye'
then
    echo "shouldn't print 1"
elif test $another = 'working'
then
    echo "true"
    exit 0
else
    echo "shouldn't print 2"
fi

# check $() inside while / if
# check strings '' vs variables in while/if
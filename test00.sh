#!/bin/sh

# test echo
# test variables
# test quotations "" and ''

hi=Hello
num=12

echo "Hello World"

echo 'Hello World'

echo Hello World

echo 12345

echo "1 2 3 4 5"

echo '     Hi'

echo "     Hi"

echo '   hi   '

echo "   hi    "

echo "$num"

echo '$1'

echo "$hi '$num'"

echo "A line with apostrophe's"

echo -n No newline

echo -n "Another missing newline"

echo -n 'and another'

echo "end of test00"
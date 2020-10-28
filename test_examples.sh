for subset in "examples/*"
do
    for file in $subset/*.sh
    do
        name=$(echo "$file" | sed 's/.sh//')
        echo $name

        ./sheeple.pl $name.sh > tmp.pl
        perl tmp.pl > out
        $name.pl > exp
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
done
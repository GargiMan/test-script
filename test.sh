#!/bin/sh
#---------------------------------INFO-AND-SETUP---------------------------------------------------------------

# Testing for IAL homeworks (Make, Memory check, Basic tests)
# by Gargi

# put in folder with homework directories which contain files for testing
# using make and valgrind, install them
# makefile should have clean
# if you changed (upgraded) basic tests , ignore output compare

# ./test.sh             => run all tests with all directories
# ./test.sh [name]      => run tests with inserted directory name
# ./test.sh -clean      => delete all generated files by this script (cxxx-my.output file and  run make clean)
# to redirect output from script to file use ./test.sh >file

# homework directory names (split with space)
export DIRS="c201 c203 c206"

# skip output compare ("yes" for skip , anything for not)
SKIPOUT="no"

#--------------------------------------SCRIPT------------------------------------------------------------------
for FILE in $DIRS; do
    if [ "$1" = "-clean" ]; then
        cd "$FILE" 2>/dev/null || echo "Directory '$FILE' doesn't exist or you don't have permissions"
        if [ ! -f "Makefile" ]; then continue; fi
        printf "\n"
        echo "==================-$FILE-============================================================="
		
        echo "-------------------clean------------------"
        make clean >/dev/null
        rm -f "$FILE"-my.output 
        echo "Files deleted ok"
		
        cd ..
        printf "\n"
        continue
    fi

    if [ -z "$1" ] || [ "$FILE" = "$1" ]; then
        cd "$FILE" 2>/dev/null || echo "Directory $PWD '$FILE' doesn't exist or you don't have permissions"
        if [ ! -f "Makefile" ]; then continue; fi
        printf "\n"
        echo "==================-$FILE-============================================================="
		
        echo "-------------------make-------------------"
        make clean >/dev/null
        make >/dev/null
        if [ ! -f "$FILE-test" ]; then 
            cd ..; 
            continue; 
        else
            echo "Executable file exist ok"
        fi
		
        echo "--------------valgrind-check--------------"
        valgrind -q ./"$FILE"-test 2>&1 | grep -v 'error calling PR_SET_PTRACER, vgdb might block' | 
			grep '==[0-9][0-9][0-9][0-9]==' || echo "Malloc and memory access ok"
        valgrind ./"$FILE"-test 2>&1 | grep 'All heap blocks were freed -- no leaks are possible' >/dev/null &&
			echo "Memory all free ok" || valgrind ./"$FILE"-test 2>&1 | awk '/HEAP/,/suppressed: .+ blocks$/'

        if [ "$SKIPOUT" = "yes" ]; then
            cd ..;
            continue;
        fi

        echo "---------------tests-compare--------------"
        ./"$FILE"-test >"$FILE"-my.output
        diff -su "$FILE"*.output | grep -v "identical" || echo "Output files same ok"
		
        cd ..
        printf "\n"
        if [ "$FILE" = "$1" ]; then exit; fi
        continue
    fi

    echo "$DIRS" | grep -vc "$1" >/dev/null;
    if [ $? -eq 0 ]; then echo "Directory '$1' is not listed"; exit; fi
done
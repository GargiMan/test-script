#!/bin/sh
#---------------------------------------INFO-------------------------------------------------------------------

# Script for project testing
# Help: ./test.sh --help
# by Gargi

# User options:

COLOR=1                 #colors 0-off X-on
EXECSUFFIX="-test"      #executable files suffix
EXECEXT=""              #executable files extension
OUTEXT=".output"        #output files extension
MYSUFFIX="-my"          #my output suffix
MAKEOPT=""              #makefile options or dependencies

#--------------------------------------SCRIPT------------------------------------------------------------------

SKIP=0
CLEAN=0
DIRFIND="$PWD"
DIRARG=""
CODE=0

color() {
    if [ "$COLOR" -eq 0 ]; then return; fi
    if [ -z $1 ]; then printf "\e[0;39m"; return; fi

    if [ "$1" = "red" ]; then printf "\e[1;91m"
    elif [ "$1" = "yellow" ]; then printf "\e[1;93m"
    elif [ "$1" = "green" ]; then printf "\e[1;92m" 
    elif [ "$1" = "cyan" ]; then printf "\e[1;96m"
    fi
}

errorexit() {
    color "red"
    printf "Error: %s\n" "$*" >&2
    color
    exit $CODE
}

while [ $# -gt 0 ]; do
    case $1 in
        --help)
            printf "Script for project testing ~ by Gargi\n"
            printf "Usage: ./test.sh [OPTION]... [NAME]\n\n"
            printf "Basic operations make, memory, tests for projects testing.\n"
            printf "Executing without any options script run tests in all directories in current directory.\n"
            printf "With NAME passed in arguments, script will run tests only once in 'NAME' directory.\n"
            printf "Directory NAME must be same as executable file (without suffix and extension) made by Makefile.\n"
            printf "Custom file suffix, extensions or other options can be modified at beginning of script file.\n\n"
            printf "Options list:\n"
            printf "  --clean\t clean files with 'make clean' and delete files created by this script (in NAME directory)\n"
            printf "  --dir [DIR]\t directory where to look for directories for testing\n"
            printf "  \t\t   without this option, current directory will be used\n"
            printf "  --skip\t skip output compare\n"
            printf "  --help\t display this help and exit\n\n" 
            printf "Exit status:\n"
            printf " 0 if OK\n"
            printf " 1 if problems with script options or directory\n\n"
            printf "Color output: (can be disabled in script file)\n"
            color "cyan"
            printf "cyan"
            color
            printf "\tdirectory name\n"
            color "green"
            printf "green"
            color
            printf "\tcorrect test\n"
            color "yellow"
            printf "yellow"
            color
            printf "\tmaybe incorrect test\n"
            color "red"
            printf "red"
            color
            printf "\tincorrect test\n\n"
            printf "Packages used: make, valgrind, grep, awk\n"
            exit $CODE
            ;;
        --clean)
            if [ $CLEAN -eq 1 ]; then
                CODE=1
                errorexit "Option '$1' was already set"
            fi
            CLEAN=1
            shift
            ;;
        --skip)
            if [ $SKIP -eq 1 ]; then
                CODE=1
                errorexit "Option '$1' was already set"
            fi
            SKIP=1
            shift
            ;;
        --dir)
            if [ "$DIRFIND" != "$PWD" ]; then
                CODE=1
                errorexit "Option '$1' was already set"
            elif [ "$2" = "--help" ]; then
                shift
                continue
            elif [ -z "$2" ] || [ "$2" = "--clean" ] || [ "$2" = "--skip" ]; then
                CODE=1
                errorexit "Option '$1' requires an argument"
            elif [ ! -d "$2" ]; then
                CODE=1
                errorexit "Directory '$2' does not exist"
            fi
            DIRFIND=$2
            cd "$DIRFIND" || CODE=1 | errorexit "You do not have permissions to enter '$DIRFIND' directory"
            shift
            shift
            ;;
        *)
            if [ -n "$DIRARG" ]; then
                CODE=1
                errorexit "Option '$1' does not exist or test directory was already set to '$DIRARG'"
            elif [ "$1" = "--clear" ]; then
                CODE=1
                errorexit "Option '$1' does not exist, correct alternative is option '--clean"
            fi
            DIRARG=$(basename "$1") 
            shift
            ;;
    esac
done

DIRS=$(find * -maxdepth 0 -type d 2>/dev/null)
if [ -n "$DIRARG" ] && [ ! -d "$DIRARG" ]; then errorexit "Test directory '$DIRARG' does not exist"; fi
if [ -z "$DIRS" ]; then errorexit "No test directories found in '$DIRFIND'"; fi

echo "$DIRS" | while IFS= read -r DIR; do 

    if [ -z "$DIRARG" ] || [ "$DIR" = "$DIRARG" ]; then

        printf "\n"
        echo "======================================================================"
        printf "Directory: "
        color "cyan"
        printf "$DIR\n"
        color

        cd "$DIR" 2>/dev/null 
        EXTCODE=$?
        if [ "$EXTCODE" -ne 0 ]; then
            color "yellow"
            printf "You do not have permissions to enter '$DIR' directory" >&2
            color
            continue
        fi

        echo "-------------------make-------------------"

        if [ ! -f "Makefile" ]; then 
            color "yellow"
            printf "Directory does not contain Makefile\n" >&2
            color
            cd ..
            continue
        fi

        make clean >/dev/null
        EXTCODE=$?
        if [ "$EXTCODE" -eq 0 ]; then 
            printf "Make clean: "
            color "green"
            printf "ok\n"
            color
        elif [ "$EXTCODE" -eq 2 ]; then
            printf "Make clean: "
            color "yellow"
            printf "missing\n"
            color
        else 
            printf "Make clean: "
            color "red"
            printf "error\n"
            color
        fi

        if [ "$CLEAN" -eq 1 ]; then

            echo "--------------------rm--------------------"

            if [ -f "$DIR""$MYSUFFIX""$OUTEXT" ]; then
                rm -f "$DIR""$MYSUFFIX""$OUTEXT" 
                printf "Delete $DIR$MYSUFFIX$OUTEXT: "
                color "green"
                printf "ok\n"
                color
            else 
                printf "Delete $DIR$MYSUFFIX$OUTEXT: "
                color "yellow"
                printf "not found\n"
                color
            fi

            cd ..
            if [ -n "$DIRARG" ]; then break; fi
            continue
        fi 

        if [ -z "$MAKEOPT" ]; then
            make >/dev/null
            EXTCODE=$?
        else 
            make "$MAKEOPT" >/dev/null
            EXTCODE=$?
        fi
        
        if [ "$EXTCODE" -eq 0 ]; then
            printf "Make executable file: " 
            color "green"
            printf "ok\n"
            color
        else
            printf "\n"
            printf "Make executable file: "
            color "red"
            printf "error\n"
            color
            cd ..
            continue
        fi

        if [ ! -f "$DIR""$EXECSUFFIX""$EXECEXT" ]; then 
            color "red"
            printf "Executive file '$DIR$EXECSUFFIX$EXECEXT' does not exist\n" >&2
            color
            cd ..
            continue
        fi
		
        echo "-----------------valgrind-----------------"

        valgrind -q ./"$DIR""$EXECSUFFIX""$EXECEXT" 2>&1 | grep -v 'error calling PR_SET_PTRACER, vgdb might block' | grep '==[0-9][0-9][0-9][0-9]=='
        EXTCODE=$?
        if [ "$EXTCODE" -eq 1 ]; then
            printf "Memory access (alloc): "
            color "green"
            printf "ok\n"
            color
        else 
            printf "Memory access (alloc): "
            color "red"
            printf "error\n"
            color
        fi

        valgrind ./"$DIR""$EXECSUFFIX""$EXECEXT" 2>&1 | grep 'All heap blocks were freed -- no leaks are possible' >/dev/null
        EXTCODE=$?
        if [ "$EXTCODE" -eq 0 ]; then
        	printf "Memory leaks (free): "
            color "green"
            printf "ok\n"
            color
        else
            valgrind ./"$DIR""$EXECSUFFIX""$EXECEXT" 2>&1 | awk '/HEAP/,/suppressed: .+ blocks$/'
            printf "Memory leaks (free): "
            color "red"
            printf "error\n"
            color
        fi

        echo "-------------------test-------------------"

        if [ "$SKIP" -eq 1 ]; then
            printf "Output files: "
            color "yellow"
            printf "skipped\n"
            color
        else 
            ./"$DIR""$EXECSUFFIX""$EXECEXT" >"$DIR""$MYSUFFIX""$OUTEXT"

		    diff -q "$DIR"*"$OUTEXT" >/dev/null 2>&1
            EXTCODE=$?
            if [ "$EXTCODE" -eq 0 ]; then
                printf "Output files: "
                color "green"
                printf "ok\n"
                color
            else 
                diff -u "$DIR"*"$OUTEXT"
                printf "Output files: "
                color "red"
                printf "not same\n"
                color
            fi
        fi

        cd ..
        if [ -n "$DIRARG" ]; then break; fi
        continue
    fi
done

printf "\n"
exit "$CODE"
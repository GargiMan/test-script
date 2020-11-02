```
Script for project testing ~ by Gargi
Usage: ./test.sh [OPTION]... [NAME]

Basic operations make, memory, tests for projects testing.
Executing without any options script run tests in all directories in current directory.
With NAME passed in arguments, script will run tests only once in 'NAME' directory.
Directory NAME must be same as executable file (without suffix and extension) made by Makefile.
Custom file suffix, extensions or options can be modified at start of script file.

Options list:
  --clean	      clean files with 'make clean' and delete files created by this script (in NAME directory)
  --dir [DIR]	  directory where to look for directories for testing
  		            without this option, current directory will be used
  --skip	      skip output compare
  --help	      display this help and exit

Exit status:
 0 if OK
 1 if problems with script options or directory

Color output:
 cyan	    directory name
 green	    correct test
 yellow	  maybe incorrect test
 red     	incorrect test

Packages used: make, valgrind, grep, awk
```

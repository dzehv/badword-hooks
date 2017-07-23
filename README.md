# Pre commit hook
Must be placed to local git repo: cp <pre-commit.pl> </path/to/.git/hooks/pre-commit>

./lib folder with SwearingChecker.pm has to be rehardcoded in 'use lib' of pre-commit script

TODO: Place SwearingChecker.pm and swearing_words.txt to known folder because of 'use lib' full path...
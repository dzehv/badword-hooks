#!/usr/bin/env perl

# Pre commit hook: must be placed to local git repo: .git/hooks/pre-commit

use strict;
use warnings;
use Data::Dumper;

$Data::Dumper::Terse = 1;

my $cached = qx(git diff --cached --name-status | awk '{ print \$2 }');
my @files = split("\n", $cached);
print "Diff files at index are:\n" . Dumper \@files;

# Non zero condition to prevent commit
if (1) {
    exit 1;
}

#!/usr/bin/env perl

# Pre commit hook: must be placed to local git repo: .git/hooks/pre-commit

use strict;
use warnings;
use Data::Dumper;

$Data::Dumper::Terse = 1;

use lib '%s';
use BadwordChecker;
my $dicts_dir = '%s';

# Find diff files for this commit
my $cached = qx(git --no-pager diff --cached --name-status | awk '{ print \$2 }');
my @files = split("\n", $cached);

# If nothing to check
unless (scalar @files) {
    _log("No files to check on pre-commit");
    exit 0;
}

_log("You're going to commit files:\n" . Dumper \@files);

my $checker = BadwordChecker->new(
    dicts => $dicts_dir,
);
$checker->get_search_line();

# Scan diff files
for my $file (@files) {
    $checker->scan_file($file);
}

# Print exit message and exit
_log($checker->{'exit_msg'});
exit $checker->{'exit_code'};

sub _log {
    my $str = shift;

    return unless $str;

    my $prefix = '[BADWORD CHECKER]: ';
    print $prefix . $str . "\n";
}

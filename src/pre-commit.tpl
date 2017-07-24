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
my @cached = split("\n", $cached);

# Grep only plain files
# TODO: add grep by mime types
my @files = grep {
    my $mtype = `file --mime-type $_` or die "Could not check file mime-type for [$_]: $!";
    my $types = qr{\:\s+\w*\/?(?:text|message|multipart|x-pkcs|xml|json|javascript|postscript|x-tex|x-empty)};
    my $grep = (-f $_ && $mtype =~ $types ? 1 : 0);
    _log("File [$_] has not a plain mime type, skipping") unless $grep;
    $grep
} @cached;

# If nothing to check
unless (scalar @files) {
    _log("No files to check on pre-commit");
    exit 0;
}

_log("Have to check files:\n" . Dumper \@files);

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

package BadwordChecker;

use strict;
use warnings;
use File::Find qw(find);
use Data::Dumper;

our $VERSION = 0.0.1;

# Push dictionary files to @dicts key
sub new {
    my ($class, %params) = @_;

    my $self = {
        dicts => '',
        check_all => 1,
        exit_msg => '',
        exit_code => 0,
    };
    $self->{$_} = $params{$_} for keys %params;

    bless $self => $class;

    return $self;
}

sub get_search_line {
    my $self = shift;

    my $search_line = '(?:^|\W|_)(';

    my @files = _search_files($self->{'dicts'});
    die "No dictionaries to read: exiting" unless scalar @files;

    for my $dict (@files) {
        open my $fh, '<', $dict or die "Could not open dictionary file [$dict]: $!";
        while (my $word = <$fh>) {
            chomp $word;

            # Replace '*' with '\w*'
            $word =~ s/\*/\\w\*/g;

            # Escaping of special symbols
            $word =~ s/(\$|\()/\\${1}/g;

            # Replace space symbol with \s*
            $word =~ s/ /\\s\*/g;

            # Concatenation for regex match
            $search_line .= $word . '|';
        }
        close $fh;
    }

    chop $search_line;
    $search_line .= ')(?:\W|_)';

    $self->{'search_line'} = $search_line;
}

sub scan_file {
    my ($self, $file) = @_;

    my $fh;
    unless (open $fh, '<', $file) {
        $self->{'exit_msg'} = "Can't read file [$file]: $!";
        return;
    }

    my @lines = <$fh>;
    close $fh;
    my $line_number = 0;
    for my $sig (@lines) {
        $line_number++;
        if ($sig =~ /$self->{'search_line'}/) {
            # Set non zero exit code if as least one match found
            $self->{'exit_code'} = 1;
            $self->{'exit_msg'} .= "\n========== Detected Swearing Word!!! ==========\n";
            $self->{'exit_msg'} .= "Swearing word: $1\n";
            $self->{'exit_msg'} .= "File: $file\n";
            $self->{'exit_msg'} .= "String number: $line_number\n";
            $self->{'exit_msg'} .= "================================================\n";
            unless ($self->{'check_all'}) {
                # Don't check every file from diff
                last;
            }
        }
    }
}

sub _search_files {
    my @files;
    find(
        {
            wanted => sub {
                s{\(}{\\(};
                s{\)}{\\)};
                push @files, $_ if (-f $_ && -s _);
            },
            no_chdir => 1
        },
        @_
    );

    return @files;
}

1;

use v5.14;
package Sleepr;

# ABSTRACT: For giving your computer a good sleep routine

use YAML;
use Data::Dump qw{ dump };
use parent qw{ Exporter };
our @EXPORT_OK = qw{ loop within config };

our $DEFAULTS = {
    execute     => 'shutdown -h now',
    at          => [qw{ 22 00 }],
    check_every => 30
};

our $CONFIG_FILE = do {
    my $f = "/etc/sleepr";
    unless ( -e $f ) {
        say "No configuration found creating new file at '$f'";
        open my $fh, ">", $f or die "cannot write to $f";
        print $fh YAML::Dump($DEFAULTS);
        close $fh;
    }
    $f;
};

sub loop(&) {
    my ($blk) = @_;

    while (1) {
        my $CMD      =   config('execute')     or $DEFAULTS->{execute};
        my @EXE_TIME = @{config('at')          or $DEFAULTS->{at}};
        my $INTERVAL =   config('check_every') or $DEFAULTS->{check_every};
    
        $blk->($CMD, @EXE_TIME);

        sleep $INTERVAL;
    }
}

sub config($) {
    my ($key) = @_;
    
    $config = YAML::LoadFile($CONFIG_FILE);

    $config->{$key};
}

sub within($&) {
    my ($term, $blk) = @_;

    $term =~ /(\d+)(min|minutes|hours|hr|hrs)/;
    my $magnitude = $1;
    my $vector    = $2;

    my $minutes = do {
        given ( $vector ) {
            when (/min|minutes/)  { $magnitude }
            when (/hr|hrs|hours/) { $magnitude * 60 }
        }
    };

    if ( (my $diff = &time_diff) <= $minutes ) {
        $blk->($diff);
    }
}

sub time_diff {
    my ($h1, $m1) = @{config('at')};
    my ($h2, $m2) = do {
        my ($sec, $min, $hr) = localtime;
        ($hr, $min);
    };

    my $t1 = $h1 * 60 + $m1;
    my $t2 = $h2 * 60 + $m2;

    $t1 - $t2;
}

1;

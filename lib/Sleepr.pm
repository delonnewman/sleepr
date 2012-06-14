use v5.14;
package Sleepr;

# ABSTRACT: Stop hacking and get some sleep

use YAML;
use POSIX;
use Data::Dump qw{ dump };
use parent qw{ Exporter };
our @EXPORT_OK = qw{ loop within before config now format_time plural };

our $DEFAULTS = {
    execute     => 'shutdown -h now',
    begin       => [qw{ 22 00 }],
    end         => [qw{ 05 00 }],
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

{
    my $config;
    sub config($) {
        my ($key) = @_;
    
        $config //= YAML::LoadFile($CONFIG_FILE);
    
        $config->{$key};
    }
    
    sub loop(&) {
        my ($blk) = @_;
    
        while (1) {
            my $CMD      =   config('execute')     or $DEFAULTS->{execute};
            my @EXE_TIME = @{config('begin')       or $DEFAULTS->{begin}};
            my @END_TIME = @{config('end')         or $DEFAULTS->{end}};
            my $INTERVAL =   config('check_every') or $DEFAULTS->{check_every};
        
            $blk->($CMD, \@EXE_TIME, \@END_TIME);
    
            $config = undef; # reset config
            sleep $INTERVAL;
        }
    }
}

sub before($&) {
    my ($term, $blk) = @_;

    $term =~ /(\d+)(min|minutes|hours|hr|hrs|sec|seconds)/;
    my $magnitude = $1;
    my $vector    = $2;

    my $minutes = do {
        given ( $vector ) {
            when (/sec|seconds/)  { $magnitude / 60 }
            when (/min|minutes/)  { $magnitude }
            when (/hr|hrs|hours/) { $magnitude * 60 }
            default               { $magnitude }
        }
    };

    if ( (my $b = til('begin')) <= $minutes && (my $e = til('end')) >= 0 ) {
        $blk->($b, $e);
    }
}

sub within(&) {
    my ($blk) = @_;
    &before('0min', $blk);
}

sub format_time {
    my ($minutes, $prefix) = @_; # assume minutes

    $prefix && ($prefix .= ' ');

    if ( $minutes > 59 ) {
        plural(POSIX::ceil($minutes / 60), "${prefix}hour");
    } else {
        plural($minutes, "${prefix}minute");
    }
}

sub plural {
    my ($number, $unit) = @_;

    if ( $number == 1 ) { "$number $unit" }
    else {
        "$number " . ($unit =~ /s$/ ? "${unit}es" : "${unit}s");
    }
}

sub now {
    my ($sec, $min, $hr) = localtime;

    if ( wantarray ) { ($hr, $min, $sec) }
    else             { POSIX::strftime('%T', localtime) }
}

sub til {
    my ($when) = @_;

    time_diff(@{config($when)})
}

sub time_diff {
    my ($h1, $m1) = @_;
    my ($h2, $m2) = now;

    my $offset = $h1 < $h2 ? 24 : 0;

    my $t1 = ($h1 + $offset) * 60 + $m1;
    my $t2 = $h2 * 60 + $m2;

    $t1 - $t2;
}

1;

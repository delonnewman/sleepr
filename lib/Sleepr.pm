use v5.14;
package Sleepr;

# ABSTRACT: Stop hacking and get some sleep

use YAML;
use POSIX;
use DateTime;
use DateTime::Format::DateParse;
use Data::Dump qw{ dump };
use parent qw{ Exporter };
our @EXPORT_OK = qw{ loop within before config now format_time plural };

our $DEFAULTS = {
    begin       => '10:00 PM',
    end         => '5:00 AM',
    check_every => 30
};

# alias
sub DateParser () { DateTime::Format::DateParse }

our $CONFIG_FILE = do {
    my $f = "$ENV{HOME}/.sleepr";
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
    
        my $now = now();
        $config //= do {
            # log time
            my $c = YAML::LoadFile($CONFIG_FILE);
            my %c = %$c;
            $c{begin} = parse_time($c->{begin}, $now);
            $c{end}   = parse_time($c->{end}, $now);
            \%c;
        };

        $config->{begin}         // die "'begin' must be specified in ~/.sleepr";
        $config->{end}           // die "'end' must be specified in ~/.sleepr";
        $config->{check_every}   // die "'check_every' must be specified in ~/.sleepr";

        if ( $key eq 'begin' || $key eq 'end' ) {
            my ($b, $e) = ($config->{begin}, $config->{end});
            if ( $b && $e && $b > $e ) {
                $e->add(days => 1) if $e->can('add');
            }
        }

        $config->{$key};
    }
    
    sub loop(&) {
        my ($blk) = @_;
    
        while (1) {
            my $begin    = config('begin');
            my $end      = config('end');
            my $interval = config('check_every');
        
            $blk->($begin, $end);
    
            $config = undef; # reset config
            sleep $interval;
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
        plural(POSIX::floor($minutes / 60), "${prefix}hour");
    }
    else {
        plural($minutes, "${prefix}minute");
    }
}

sub parse_time {
    my ($str, $now) = @_;

    my $d = DateParser->parse_datetime($str);
    $d->set_time_zone('UTC');

    if ( $now ) {
        $d->set(year => $now->year, month => $now->month, day => $now->day);
    }

    $d;
}

sub plural {
    my ($number, $unit) = @_;

    if ( $number == 1 ) { "$number $unit" }
    else {
        "$number " . ($unit =~ /s$/ ? "${unit}es" : "${unit}s");
    }
}

sub til {
    my ($when) = @_;

    my $d = config($when) - now();
    
    return $d->minutes * -1 if $d->is_negative;
    return $d->minutes;
}

sub now {
    DateTime->now(time_zone => 'local')->set_time_zone('UTC');
}

1;

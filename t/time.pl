#!/usr/bin/env perl 
use v5.14;
use Data::Dump qw{ dump };
use DateTime::Format::DateParse;

sub DateParser () { DateTime::Format::DateParse }

my $b = DateParser->parse_datetime('10:00 PM');
$b->set(year => 2012, month => 6, day => 26);
$b->set_time_zone('floating');

my $e = DateParser->parse_datetime('5:00 AM');
$e->set(year => 2012, month => 6, day => 26);
$e->set_time_zone('floating');

if ( $e < $b ) {
    say "The end time is greater than the begining time";
    $e->add(days => 1);
}

say "$b to $e";

dump(DateTime->now(time_zone => 'local')->set_time_zone('floating') - $b);

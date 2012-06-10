use v5.14;
package Sleepr::Notify;
use Gtk2::Notify qw{ -init Sleepr };

use parent qw{ Exporter };
our @EXPORT_OK = qw{ notify };

sub notify($@) {
    my ($_, $title, @rest) = $_[0] eq 'title' ? @_ : (undef, undef, @_);

    Gtk2::Notify->new($title || 'Sleepr', join('', @rest))->show;

    !!1;
}

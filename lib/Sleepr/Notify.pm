use v5.14;
package Sleepr::Notify;
use parent qw{ Exporter };
our @EXPORT_OK qw{ notify };
use Gtk2::Notify qw{ -init Sleepr };

sub notify($@) {
    Gtk2::Notify->new('Sleepr', join('', @_))->show;
    1;
}

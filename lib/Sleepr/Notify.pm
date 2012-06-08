use v5.14;
package Sleepr::Notify;
use Gtk2::Notify qw{ -init Sleepr };

use parent qw{ Exporter };
our @EXPORT_OK = qw{ notify };

sub notify($@) {
    Gtk2::Notify->new('Sleepr', join('', @_))->show;
    1;
}

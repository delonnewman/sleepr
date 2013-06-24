package Sleepr::System {
    use Net::DBus;

    my $manager = do {
        Net::DBus->system
          ->get_service('org.freedesktop.ConsoleKit')
          ->get_object('/org/freedesktop/ConsoleKit/Manager', 'org.freedesktop.ConsoleKit.Manager');
    };

    my $power = do {
        Net::DBus->system
          ->get_service('org.freedesktop.UPower')
          ->get_object('/org/freedesktop/UPower/Manager', 'org.freedesktop.UPower.Manager');
    };

    sub shutdown { $manager->Stop }
    sub restart { $manager->Restart }

    sub hibernate { $power->Hibernate }
    sub suspend { $power->Suspend }
}

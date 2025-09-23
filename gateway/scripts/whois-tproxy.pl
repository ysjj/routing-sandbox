#!/usr/bin/perl
use strict;
use Socket qw(:DEFAULT IPPROTO_IP IPPROTO_TCP);

use constant SO_ORIGINAL_DST => 80;

sub query {
    STDIN->blocking(0);
    my $i = 0;
    my $q = <STDIN>;
    while (substr($q, -2) != "\r\n") {
        select(undef, undef, undef, 0.1);
        $q .= <STDIN>;
        last unless ($i += 1 < 10);
    }
    return $q;
}

sub original_destination {
    my $optval = getsockopt(\*STDIN, IPPROTO_IP, SO_ORIGINAL_DST) or die "failed to getsockopt: $!";
    my $sin = substr($optval, 0, 16);
    my ($port, $addr) = unpack_sockaddr_in($sin);
    print STDERR "whois-tproxy:original[",join(".",unpack("C4",$addr)),":$port]\n";
    return $sin;
}

sub relay {
    socket(my $remote, PF_INET, SOCK_STREAM, IPPROTO_TCP) or die "failed to create remote socket: $!";
    connect($remote, original_destination) or die "failed to connect remote: $!";

    my $q = query;

    print STDERR "whois-tproxy:query[$q]\n";
    print $remote $q;
    $remote->flush();

    my $a = "";
    $a .= $_ while (<$remote>);
    close($remote);

    print STDERR "whois-tproxy:answer[---\n$a\n----]\n";
    print $a;
}

relay;

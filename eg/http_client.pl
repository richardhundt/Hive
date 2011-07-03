#!/usr/bin/perl

use strict;
use warnings;

use Errno;

$SIG{PIPE} = 'IGNORE';

my $HOST = $ARGV[0] || 'localhost';
my $PORT = $ARGV[1] || 80;
my $PATH = $ARGV[2] || '/testfile.txt';

use HTTP::Request;
my $req = HTTP::Request->new( 'PUT' => $PATH );
$req->protocol('HTTP/1.0');
$req->header( Host =>  "$HOST:$PORT" );
#$req->header( Connection => 'close' );
$req->header( Connection => 'keep-alive' );
$req->header( Keep_Alive => 300 );
$req->content("too short...");
#$req->content_length( length($req->content) );
$req->content_length( 65537 );

=pod
my $req = HTTP::Request->new( 'GET' => $PATH );
$req->protocol('HTTP/1.0');
$req->header( Host =>  "$HOST:$PORT" );
$req->header( Connection => 'keep-alive' );
$req->header( Keep_Alive => 300 );
=cut

my $req_str = $req->as_string("\r\n");
warn 'REQ: '.$req_str;

use IO::Socket;

my $count = 0;
my $start = time;
my $socket = IO::Socket::INET->new(
    PeerAddr => $HOST,
    PeerPort => $PORT,
    Proto    => 'tcp',
    Blocking => 0,
);

my $rbits = '';
my $wbits = '';
vec($rbits, fileno($socket), 1) = 1;
vec($wbits, fileno($socket), 1) = 1;

die $! unless $socket;
my $len = 65537;
while ( $len > 0 ) {
    select(undef, $wbits, undef, 100);
    my $put = syswrite( $socket, $req_str );
    last unless defined $put;
    $len -= $put;
    syswrite( $socket, "tick\n" );
    print("tick\n");
    sleep(1);
}
print "done writing...\n";

my $data;
while (1) {
    my $buf = '';
    my $got;
    select($rbits, undef, undef, 100);
    $got = sysread( $socket, $buf, 128 );
    last unless defined $got;
    last if $got == 0 && !($!{EAGAIN} || $!{EWOULDBLOCK});
    $data .= $buf;
}
print("data: $data");
$socket->close;
print $data;


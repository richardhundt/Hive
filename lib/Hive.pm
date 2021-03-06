package Hive;

use strict;
use warnings;

use Coro;
use Coro::Event;

use Hive::Node;

our $VERSION = '0.01';

use base qw/Exporter/;

our @EXPORT = qw/ cede async current terminate /;

1;

=head1 NAME

Hive - Flow-based programming for Perl

=head1 SYNOPSIS

    package My::Echo::Server;
    use strict;
 
    use Coro::Socket;
    use Hive::Read;
    use Hive::Write;
 
    use base qw/Hive::Node/;
 
    sub execute {
        my $self = shift;
        my $listen = Coro::Socket->new(
            LocalHost => 'localhost',
            LocalPort => 12345,
            ReuseAddr => 'yes please',
            Proto     => 'tcp',
            Listen    => 1,
        );
        while ( my $socket = $listen->accept ) {
            my $reader = Hive::Read->new;
            my $writer = Hive::Write->new;
            $reader->handle->put( $socket );
            $writer->handle->put( $socket );
            $reader->output->to( $writer->intake );
        }
    }
 
    my $server = My::Echo::Server->new;
    $server->join;

=head1 DESCRIPTION

This module implements experimental Flow-Based Programming (FBP) for Perl.
FBP is component oriented, where "off the shelf" components can be connected
together using ports. Conceptually data enters the system at one end
(the source) and leaves via the other (the sink), while in between various
transformations are applied to the data stream.

Each component represents a symmetric coroutine with input/output channels
with which a component communicates with its upstream and downstream peers.

=head1 AUTHOR

 Richard Hundt

=head1 LICENSE

 Artistic

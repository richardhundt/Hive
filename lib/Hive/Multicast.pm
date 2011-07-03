package Hive::Multicast;

use strict;
use base qw/Hive::Node/;

sub intake : In;
sub output : OutArray;

sub execute {
    my $self = shift;
    my $data;
    while ( ) {
        $data = $self->intake->get;
        last unless defined $data;
        $self->output->put( $data );
    }
}

1;

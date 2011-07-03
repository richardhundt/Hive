package Hive::Sink;

use strict;

use base qw/Hive::Node/;

sub intake : In;

sub execute {
    my $self = shift;
    while ( ) {
        last unless defined $self->intake->get;
    }
}

1;

package Hive::Demultiplex;

use strict;
use base qw/Hive::Node/;

sub intake : In;
sub seqctl : In;
sub output : OutArray;

sub execute {
    my $self = shift;
    my ( $data, $indx );
    while ( ) {
        $indx = $self->seqctl->get;
        $data = $self->intake->get;
        last unless defined $data;
        $self->output->at( $indx )->put( $data );
    }
    $self->output->put( undef );
}

1;

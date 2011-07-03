package Hive::Multiplex;

use strict;
use base qw/Hive::Node/;

sub output : Out;
sub seqout : Out;
sub intake : InArray;

sub execute {
    my ( $self ) = @_;
    while ( ) {
        my ( $port, $indx ) = $self->intake->choose;
        my $data = $port->get();
        if ( defined $data ) {
            $self->seqout->put( $indx );
            $self->output->put( $data );
        }
        else {
            $self->intake->remove( $port );
        }
        last unless $self->intake->count;
    }
}

1;

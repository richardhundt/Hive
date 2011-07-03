package Hive::Valve;

use strict;
use base qw/Hive::Node/;

sub intake  : In;
sub output  : Out;
sub control : In;

sub execute {
    my ( $self ) = @_;
    my ( $ctrl, $data );
    while ( ) {
        $ctrl = $self->control->get;
        $data = $self->intake->get;
        last unless defined $ctrl;
        last unless defined $data;
        $self->output->put( $data );
    };
    $self->output->put( undef );
}

1;

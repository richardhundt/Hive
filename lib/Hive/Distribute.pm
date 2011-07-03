package Hive::Distribute;

use strict;
use base qw/Hive::Node/;

sub intake : In;
sub output : OutArray;

sub execute {
    my $self = shift;
    my $data;
    my $size;
    my $iter = 0;
    while ( ) {
        $size = $self->output->count;
        $data = $self->intake->get;
        last unless defined $data;
        $self->output->at( $iter++ % $size )->put( $data );
    }
    $self->output->put( undef );
}

1;

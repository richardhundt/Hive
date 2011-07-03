package Hive::Collect;

use strict;

use base qw/Hive::Node/;

sub intake : InArray;
sub output : Out;

sub execute {
    my $self = shift;
    my $data;
    while ( $self->intake->count ) {
        for my $inp ( @{ $self->intake->children } ) {
            $data = $inp->get;
            unless ( defined $data ) {
                $self->intake->remove( $inp );
                next;
            }
            $self->output->put( $data );
        }
    }
    $self->output->put( undef );
}

1;

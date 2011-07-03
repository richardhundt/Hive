package Hive::Generate;

use strict;

use base qw/Hive::Node/;

sub output : Out;

sub execute {
    my ( $self, $limit ) = @_;
    my $iter = 0;
    while ( defined $limit ? $iter < $limit : 1 ) {
        $self->output->put( $iter++ );
    }
}

1;

package Hive::Range;

use strict;

use base qw/Hive::Node/;

sub output : Out;

sub execute {
    my ( $self, $from, $last ) = @_;
    $self->output->put( $_ ) for $from .. $last;
    $self->output->put( undef );
}

1;

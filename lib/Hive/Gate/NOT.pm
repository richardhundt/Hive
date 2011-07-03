package Hive::Gate::NOT;

use strict;
use base qw/Hive::Node/;

sub intake : In;
sub output : Out;

sub execute {
    my $self = shift;
    while ( ) {
        my $in = $self->intake->get;
        last unless defined $in;
        $self->output->put( not $in );
    }
    $self->output->put( undef );
}

1;

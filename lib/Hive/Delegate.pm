package Hive::Delegate;

use strict;

use base qw/Hive::Node/;

sub intake : In;
sub output : Out;

sub execute {
    my ( $self, $delg, $meth ) = @_;

    my $data;
    while ( ) {
        $data = $self->intake->get;
        last unless defined $data;
        $self->output->put( scalar $delg->$meth( $data ) );
    }
    $self->output->put( undef );
}

1;

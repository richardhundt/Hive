package Hive::Filter;
use strict;

use base qw/Hive::Node/;

sub intake : In;
sub output : Out;

sub execute {
    my ( $self, $test ) = @_;
    $test ||= sub { 1 };
    my $data;
    while ( ) {
        $data = $self->intake->get;
        last unless defined $data;
        $self->output->put( $data ) if $test->( $self, $data );
    }
    $self->output->put( undef );
}

1;

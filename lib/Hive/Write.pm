package Hive::Write;

use strict;

use Coro::Handle ();

use base qw/Hive::Node/;

sub handle : In;
sub intake : In;

sub execute {
    my $self = shift;
    my $file = $self->handle->get;
    unless ( UNIVERSAL::isa( $file, 'Coro::Handle' ) ) {
        $file = Coro::Handle::unblock( $file );
    }
    my $data;
    while ( ) {
        $data = $self->intake->get;
        last unless defined $data;
        $file->print( $data );
    }
}

1;

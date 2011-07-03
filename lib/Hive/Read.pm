package Hive::Read;

use strict;

use Coro::Handle ();

use base qw/Hive::Node/;

sub handle : In;
sub output : Out;

sub execute {
    my $self = shift;
    my $term = scalar @_ ? shift : $/;
    my $file = $self->handle->get;
    unless ( UNIVERSAL::isa( $file, 'Coro::Handle' ) ) {
        $file = Coro::Handle::unblock( $file );
    }
    my $line;
    while ( ) {
        $line = $file->readline( $term );
        $self->output->put( $line );
        last unless defined $line;
    }
    $self->output->put( undef );
}

1;


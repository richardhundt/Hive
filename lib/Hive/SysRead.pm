package Hive::SysRead;

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
    my $rfh = $file->fh;
    my $buf = \$file->rbuf;
    my $got;
    while ( ) {
        $file->readable;
        $got = sysread( $rfh, $$buf, 65536, length($$buf) );
        $self->output->put( substr( $$buf, 0, length( $$buf ), '') );
        last unless defined $got;
    }

    $self->output->put( undef );
}

1;


use lib './lib';

use strict;

{
    package My::Echo::Server;
    use strict;

    use Coro::Socket;
    use Hive::Read;
    use Hive::Write;

    use base qw/Hive::Node/;

    sub execute {
        my $self = shift;
        my $listen = Coro::Socket->new(
            LocalHost => 'localhost',
            LocalPort => 12345,
            ReuseAddr => 'yes please',
            Proto     => 'tcp',
            Listen    => 1,
        );
        while ( my $socket = $listen->accept ) {
            my $reader = Hive::Read->new;
            my $writer = Hive::Write->new;
            $reader->handle->put( $socket );
            $writer->handle->put( $socket );
            $reader->output->to( $writer->intake );
        }
    }
}

my $server = My::Echo::Server->new;
$server->join;


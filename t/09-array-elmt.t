use lib './lib';

use strict;
no warnings 'void';

use Test::More tests => 30;

use Coro;
use Hive;

{
    package Generator;
    use strict;
    use base qw/Hive::Node/;

    sub output : OutArray;

    sub execute {
	my $self = shift;
        for ( 0 .. 9 ) {
            $self->output->at(0)->put( "tick $_" );
            $self->output->at(1)->put( "tick $_" );
            $self->output->at(2)->put( "tick $_" );
        }
        $self->output->put( undef );
    }
}
{
    package Logger;
    use strict;
    use base qw/Hive::Node/;

    sub intake : InArray;

    sub execute {
        my $self = shift;
	while ( $self->intake->count ) {
            my ( $port, $indx ) = $self->intake->choose;
            my $data = $port->get();
            if ( defined $data ) {
                Test::More::ok( $data, $data );
            }
            else {
                $self->intake->remove( $port );
            }
	}
    }
}

my $gen = Generator->new();
my $log = Logger->new;

$gen->output->at(0)->to( $log->intake->at(0) );
$gen->output->at(1)->to( $log->intake->at(1) );
$gen->output->at(2)->to( $log->intake->at(2) );

$gen->join;
$log->join;


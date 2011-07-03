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

    sub output : Out;
    sub intake : In;

    sub execute {
        my $self = shift;
	my $limit = shift;
        my $count = 0;
	my $name  = $self->intake->get;
        while ( ) {
            $self->output->put( "$name: tick $count" );
            last if ++$count == $limit;
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
            unless ( defined $data ) {
                $self->intake->remove( $port );
            }
            else {
                Test::More::ok( $data, "$data at $indx" );
            }
	}
    }
}

my $gen0 = Generator->new(5);
my $gen1 = Generator->new(10);
my $gen2 = Generator->new(15);

my $log = Logger->new;

$gen0->output->to( $log->intake->at(0) );
$gen1->output->to( $log->intake->at(1) );
$gen2->output->to( $log->intake->at(2) );

$gen0->intake->put( "nul" );
$gen1->intake->put( "one" );
$gen2->intake->put( "too" );

$log->join;

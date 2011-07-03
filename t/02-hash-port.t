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
    sub execute {
        my $self = shift;
        my $count = 0;
        while ( ) {
            $self->output->put( "tick $count" );
            last if ++$count == 10;
        }
        $self->output->put( undef );
    }
}
{
    package Logger;
    use strict;
    use base qw/Hive::Node/;

    sub intake : InHash;

    sub execute {
        my $self = shift;
	while ( $self->intake->count ) {
	    my ( $port, $name ) = $self->intake->choose;
            my $data = $port->get();
            unless ( defined $data ) {
                $self->intake->remove( $port );
            }
            else {
                Test::More::ok( $data, "$name => ".$data );
            }
	}
    }
}

my $gen0 = Generator->new;
my $gen1 = Generator->new;
my $gen2 = Generator->new;

my $log = Logger->new;

$gen0->output->to( $log->intake->at('nul') );
$gen1->output->to( $log->intake->at('one') );
$gen2->output->to( $log->intake->at('two') );

$log->join;


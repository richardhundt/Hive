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
    package MultiGenerator;
    use strict;
    use base qw/Hive::Node/;

    sub output : OutHash;

    sub execute {
	my $self = shift;
	my @gens;
	for ( 0 .. 2 ) {
	    my $gen = Generator->new();
	    $gen->output->to( $self->output->at("gen $_") );
	    push @gens, $gen;
	}
	$_->join for @gens;
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
            if ( defined $data ) {
	        Test::More::ok( $name, $data );
            }
            else {
                $self->intake->remove( $port );
            }
	}
    }
}

my $gen = MultiGenerator->new();
my $log = Logger->new;

$gen->output->to( $log->intake );
$gen->join;
$log->join;

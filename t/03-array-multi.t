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
	my $name = shift;
        my $count = 0;
        while ( ) {
            $self->output->put( "$name: tick $count" );
            last if ++$count == 10;
        }
        $self->output->put( undef );
    }
}
{
    package MultiGenerator;
    use strict;
    use base qw/Hive::Node/;

    sub output : OutArray;

    sub execute {
	my $self = shift;
	my @gens;
	for ( 0 .. 2 ) {
	    my $gen = Generator->new("gen $_");
            $gen->output->to( $self->output->at($_) );
	    push @gens, $gen;
	}
	$_->join for @gens;
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

my $gen = MultiGenerator->new();
my $log = Logger->new;

$gen->output->to( $log->intake );
$gen->join;
$log->join;


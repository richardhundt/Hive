use lib './lib';
use strict;
use warnings;

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
    package NestedLogger;
    use strict;
    use base qw/Hive::Node/;

    sub intake : InArray;

    sub execute {
	my $self = shift;
        my $log = Logger->new();
        $self->intake->to( $log->intake );
        $log->join;
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

my $gen0 = Generator->new("gen0");
my $gen1 = Generator->new("gen1");
my $gen2 = Generator->new("gen2");
my $log = NestedLogger->new;

$gen0->output->to( $log->intake->at(0) );
$gen1->output->to( $log->intake->at(1) );
$gen2->output->to( $log->intake->at(2) );
$_->join for ( $gen0, $gen1, $gen2, $log );


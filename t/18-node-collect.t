use lib './lib';
use strict;
use warnings;

use Test::More tests => 9;

use IO::Scalar;
use Hive::Collect;

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

my $coll = Hive::Collect->new;
my $gen0 = Generator->new(3);
my $gen1 = Generator->new(3);
my $gen2 = Generator->new(3);

$gen0->intake->put('gen 0');
$gen1->intake->put('gen 1');
$gen2->intake->put('gen 2');

$gen0->output->to( $coll->intake->at(0) );
$gen1->output->to( $coll->intake->at(1) );
$gen2->output->to( $coll->intake->at(2) );

my $count = 0;
my $expect = 0;
while ( ) {
    my $data = $coll->output->get;
    last unless defined $data;
    my $test = "gen ".($count % 3).": tick ".$expect;
    Test::More::is( $data, $test );
    ++$expect unless ++$count % 3;
}

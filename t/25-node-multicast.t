use lib './lib';
use strict;
use warnings;

use Test::More tests => 6;

use Hive::Multicast;
use Hive::Gate::NAND;

my $weld = Hive::Multicast->new;
my $gnot = Hive::Gate::NAND->new;

# make a NOT gate out of a NAND
$weld->output->at(0)->to( $gnot->intake_0 );
$weld->output->at(1)->to( $gnot->intake_1 );

$weld->intake->put(0);
is( $gnot->output->get, 1 );

$weld->intake->put(1);
ok( not $gnot->output->get );

$weld->intake->put(0);
is( $gnot->output->get, 1 );

$weld->intake->put(0);
is( $gnot->output->get, 1 );

$weld->intake->put(1);
ok( not $gnot->output->get );

$weld->intake->put(1);
ok( not $gnot->output->get );

use lib './lib';
use strict;
use warnings;

use Test::More tests => 10;

use Hive::Range;
use Hive::Filter;
use Hive::Distribute;

my $ngen = Hive::Range->new( 0, 9 );
my $dist = Hive::Distribute->new;

my $flt0 = Hive::Filter->new(sub {
    my ( $self, $data ) = @_;
    is( $data % 3, 0 );
    0;
});

my $flt1 = Hive::Filter->new(sub {
    my ( $self, $data ) = @_;
    is( $data % 3, 1 );
    0;
});

my $flt2 = Hive::Filter->new(sub {
    my ( $self, $data ) = @_;
    is( $data % 3, 2 );
    0;
});

$ngen->output->to( $dist->intake );

$dist->output->at(0)->to( $flt0->intake );
$dist->output->at(1)->to( $flt1->intake );
$dist->output->at(2)->to( $flt2->intake );

$_->join for ( $flt0, $flt1, $flt2 );

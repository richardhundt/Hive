use lib './lib';
use strict;
use warnings;

use Test::More tests => 16;

use Hive::Filter;
use Hive::Demultiplex;

my ( $seen0, $seen1, $seen2 );
my $flt0 = Hive::Filter->new(sub {
    my ( $self, $data ) = @_;
    Test::More::is( $data, 'data 0', $data );
    $seen0++;
    0;
});

my $flt1 = Hive::Filter->new(sub {
    my ( $self, $data ) = @_;
    Test::More::is( $data, 'data 1', $data );
    $seen1++;
    0;
});

my $flt2 = Hive::Filter->new(sub {
    my ( $self, $data ) = @_;
    Test::More::is( $data, 'data 2', $data );
    $seen2++;
    0;
});

my $dmux = Hive::Demultiplex->new;

$dmux->output->at(0)->to( $flt0->intake );
$dmux->output->at(1)->to( $flt1->intake );
$dmux->output->at(2)->to( $flt2->intake );

for ( 0 .. 2 ) {
    my $indx = $_;
    $dmux->seqctl->put($indx);
    $dmux->intake->put( "data $indx" );
}

for ( 0 .. 9 ) {
    my $indx = int(rand(3));
    $dmux->seqctl->put($indx);
    $dmux->intake->put( "data $indx" );
}

$dmux->seqctl->put( undef );
$dmux->intake->put( undef );
$dmux->join;
$_->join for ( $flt0, $flt1, $flt2 );

ok( $seen0 );
ok( $seen1 );
ok( $seen2 );

use lib './lib';
use strict;
use warnings;

use Test::More tests => 3;

use Hive::Filter;
use Hive::Delegate;

{
    package Foo;
    use strict;
    sub new { bless { }, $_[0] }
}

my $filt = Hive::Filter->new(sub {
    my ( $self, $data ) = @_;
    Test::More::isa_ok( $data, 'Foo' );
    0;
});

my $delg = Hive::Delegate->new('Foo', 'new');
$delg->output->to( $filt->intake );
$delg->intake->put( 3 );
$delg->intake->put( 3 );
$delg->intake->put( 3 );
$delg->intake->put( undef );

$filt->join;

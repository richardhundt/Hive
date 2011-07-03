use lib './lib';
use strict;
use warnings;

use Test::More tests => 1;

use IO::File;
use Hive::Write;
use Hive::CharGen;

my $num = 10;
my $gen = Hive::CharGen->new();
my $wrt = Hive::Write->new;
my $out = IO::File->new_tmpfile;

$gen->output->to( $wrt->intake );
$wrt->handle->put( $out );

$gen->intake->put( $num );
$gen->intake->put( undef );
$gen->join;

$out->seek(0, 0);
my @lines = <$out>;
ok(scalar @lines == $num, "got $num lines from CharGen");


use lib './lib';
use strict;
use warnings;

use Test::More tests => 3;

use Hive::Read;

my $read = Hive::Read->new;
open( my $file, './t/test-read.txt' ) or die "$!";
$read->handle->put( $file );

while ( my $line = $read->output->get ) {
    chomp( $line );
    last unless $line;
    ok( $line, "got $line" );
}


use lib './lib';
use strict;
use warnings;

use Test::More tests => 3;

use IO::File;
use Hive::Write;

my $data = <<TXT;
line 0
line 1
line 2
TXT

my $file = IO::File->new_tmpfile;
my $write = Hive::Write->new;

$write->handle->put( $file );
$write->intake->put( $data );
$write->intake->put( undef );
$write->join;

$file->seek(0, 0);
while ( my $line = <$file> ) {
    chomp( $line );
    last unless $line;
    ok( $line, "got $line" );
}



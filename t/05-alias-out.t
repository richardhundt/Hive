use lib './lib';
use strict;
use warnings;

use Test::More tests => 10;
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
    package NestedGenerator;
    use strict;
    use base qw/Hive::Node/;

    sub output : Out;

    sub execute {
	my $self = shift;
        my $gen = Generator->new("gen");
        $gen->output->to( $self->output );
	$gen->join;
    }
}
{
    package Logger;
    use strict;
    use base qw/Hive::Node/;

    sub intake : In;

    sub execute {
        my $self = shift;
	while ( ) {
	    my $data = $self->intake->get;
            last unless defined $data;
            Test::More::ok($data, $data);
	}
    }
}

my $gen = NestedGenerator->new();
my $log = Logger->new;

$gen->output->to( $log->intake );
$gen->join;
$log->join;


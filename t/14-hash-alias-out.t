use lib './lib';
use strict;
use warnings;

use Test::More qw/no_plan/;
use Coro;
use Hive;

{
    package NestedGenerator;
    use strict;
    use base qw/Hive::Node/;

    sub output : OutHash;

    sub execute {
        my $self = shift;
        my $count = 0;

        do {
            $self->output->at('key 0')->put( "tick $count" );
            $self->output->at('key 1')->put( "tick $count" );
            $self->output->at('key 2')->put( "tick $count" );
        } while ++$count < 10;

        $self->output->put( undef );
    }
}
{
    package Generator;
    use strict;
    use base qw/Hive::Node/;

    sub output : OutHash;

    sub execute {
	my $self = shift;
        my $gen = NestedGenerator->new("gen");
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

my $log0 = Logger->new;
my $log1 = Logger->new;
my $log2 = Logger->new;
my $gen = Generator->new();

$gen->output->at('key 0')->to( $log0->intake );
$gen->output->at('key 1')->to( $log1->intake );
$gen->output->at('key 2')->to( $log2->intake );

$_->join for ( $gen, $log0, $log1, $log2 );

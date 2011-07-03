use lib './lib';
use strict;
no warnings 'void';

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
        my $count = 0;
	    my $output = $self->output;

        do {
            $output->put("tick $count");
        } while ++$count < 10;

        $output->put( undef );
    }
}
{
    package Logger;
    use strict;
    use base qw/Hive::Node/;

    sub intake : In;

    sub execute {
        my $self = shift;
        my $intake = $self->intake;
        while ( ) {
            my $mesg = $intake->get;
            last unless defined $mesg;
            Test::More::ok( $mesg =~ /tick \d+/, $mesg );
        }
    }
}

my $gen = Generator->new;
my $log = Logger->new;

$gen->output->to( $log->intake );
$log->join;


package Hive::Gate::NAND;

use strict;
use base qw/Hive::Node/;

sub intake_0 : In;
sub intake_1 : In;
sub output : Out;

sub execute {
    my $self = shift;
    while ( ) {
        my $in0 = $self->intake_0->get;
        my $in1 = $self->intake_1->get;
        last unless defined $in0 and defined $in1;
        $self->output->put( not ( $in0 and $in1 ) );
    }
    $self->output->put( undef );
}

1;

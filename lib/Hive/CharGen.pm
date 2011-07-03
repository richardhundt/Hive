package Hive::CharGen;

use strict;
use base qw/Hive::Node/;

our @SEQ = split //,
    '0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^'.
    '_`abcdefghijklmnopqrstuvwxyz{|}~ !"#$%&\'()*+,-./';

sub intake : In;
sub output : Out;

sub execute {
    my $self = shift;
    my $line = 0;
    my $offs;
    my @char = ( @SEQ, @SEQ, @SEQ );
    while ( ) {
        my $reps = $self->intake->get();
        last unless defined $reps;
        my $buff = "";
        for ( 1 .. $reps ) {
            $offs = $line++ % 95;
            $buff .= join( '', @char[ $offs .. $offs + 71 ] ).$/;
        }
        $self->output->put( $buff );
    }
    $self->output->put( undef );
}

1;

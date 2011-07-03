package Hive::Muldex;

use strict;
use base qw/Hive::Node/;

use Hive::Multiplex;
use Hive::Demultiplex;

sub mux_intake { $_[0]{muxor}->intake }
sub mux_output { $_[0]{demux}->output }

sub output { $_[0]{muxor}->output }
sub intake { $_[0]{demux}->intake }

sub init {
    my ( $self ) = @_;
    my $muxor = Hive::Multiplex->new;
    my $demux = Hive::Demultiplex->new;
    $self->{muxor} = $muxor;
    $self->{demux} = $demux;
    $muxor->seqout->to( $demux->seqctl );
}

sub execute {
    my $self = shift;
    while ( ) {
        my $data = $self->{muxor}->output->get();
        my $indx = $self->{muxor}->seqout->get();
        $self->{demux}->seqctl->put( $indx );
        $self->{demux}->intake->put( $data );
    }
}

1;

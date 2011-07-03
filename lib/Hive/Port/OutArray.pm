package Hive::Port::OutArray;

use strict;
use Scalar::Util ();
use Hive::Port::Out;

sub KIDS () { 0 }
sub MXSZ () { 1 }

sub new { bless [ [ ], $_[1] ] }

sub count {
    my ( $self ) = @_;
    scalar @{ $self->[KIDS] };
}

sub at {
    my ( $self, $indx ) = @_;
    $self->[KIDS][$indx] ||= Hive::Port::Out->new( $self->[MXSZ] );
}

sub put {
    my ( $self, $data ) = @_;
    $_->put( $data ) for @{ $self->[KIDS] };
}

sub to {
    my ( $self, $peer ) = @_;
    Scalar::Util::weaken( $self->[KIDS] = $peer->[KIDS] );
}

1;

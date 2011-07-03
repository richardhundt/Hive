package Hive::Port::OutHash;

use strict;
use Scalar::Util ();
use Hive::Port::Out;

sub KIDS () { 0 }
sub MXSZ () { 1 }

sub new { bless [ { }, $_[1] ] }

sub count {
    my ( $self ) = @_;
    scalar keys %{ $self->[KIDS] };
}

sub at {
    my ( $self, $name ) = @_;
    $self->[KIDS]{$name} ||= Hive::Port::Out->new( $self->[MXSZ] );
}

sub put {
    my ( $self, $data ) = @_;
    $_->put( $data ) for values %{ $self->[KIDS] };
}

sub to {
    my ( $self, $peer ) = @_;
    Scalar::Util::weaken($self->[KIDS] = $peer->[KIDS]);
}

1;

package Hive::Port::InArray;

use strict;
use Hive::Port::In;

sub KIDS () { 0 }
sub MXSZ () { 1 }

sub new { bless [ [ ], $_[1] ] }

sub at {
    my ( $self, $indx ) = @_;
    $self->[KIDS][$indx] ||= Hive::Port::In->new( $self->[MXSZ] );
}
sub to {
    my ( $self, $peer ) = @_;
    $peer->[KIDS] = $self->[KIDS];
}
sub count {
    my ( $self ) = @_;
    scalar( @{ $self->[KIDS] } );
}
sub children { $_[0][KIDS] }

sub choose {
    my ( $self ) = @_;
    my $curr = $Coro::current;
    my $indx;
    my $port;
    my $i = 0;
    for my $chld ( @{ $self->[KIDS] } ) {
        my $thnk = [ $i++, $chld ];
        Coro::Semaphore::wait($chld->[0][1], sub {
            ( $indx, $port ) = @$thnk;
            $curr->ready if defined $curr;
            undef $curr;
        });
    }
    &Coro::schedule while $curr;
    return $port, $indx;
}

sub remove {
    my ( $self, $port ) = @_;
    for ( 0 .. $#{ $self->[KIDS] } ) {
        if ( $self->[KIDS][$_] == $port ) {
            return splice ( @{ $self->[KIDS] }, $_, 1 );
        }
    }
}

sub remove_at {
    my ( $self, $indx ) = @_;
    return splice ( @{ $self->[KIDS] }, $indx, 1 );
}

1;

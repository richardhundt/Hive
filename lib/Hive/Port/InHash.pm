package Hive::Port::InHash;

use strict;
use Hive::Port::In;

sub KIDS () { 0 }
sub MXSZ () { 1 }

sub new { bless [ { }, $_[1] ] }

sub at {
    my ( $self, $name ) = @_;
    $self->[KIDS]{$name} ||= Hive::Port::In->new( $self->[MXSZ] );
}

sub to {
    my ( $self, $peer ) = @_;
    $peer->[KIDS] = $self->[KIDS];
}

sub count {
    my ( $self ) = @_;
    scalar( keys %{ $self->[KIDS] } );
}

sub children { $_[0][KIDS] }

sub choose {
    my ( $self ) = @_;
    my $curr = $Coro::current;
    my ( $port, $name );
    for my $key ( keys %{ $self->[KIDS] } ) {
        my $chld = $self->[KIDS]{$key};
        my $thnk = [ $key, $chld ];
        Coro::Semaphore::wait($chld->[0][1], sub {
            ( $name, $port ) = @$thnk;
            $curr->ready if defined $curr;
            undef $curr;
        });
    }
    &Coro::schedule while $curr;
    return $port, $name;
}

sub remove {
    my ( $self, $port ) = @_;
    for ( keys %{ $self->[KIDS] } ) {
        if ( $self->[KIDS]{$_} == $port ) {
            return delete $self->[KIDS]{$_};
        }
    }
}

sub remove_at {
    my ( $self, $name ) = @_;
    return delete $self->[KIDS]{$name};
}

1;

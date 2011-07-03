package Hive::Port::Out;

use strict;
use Scalar::Util ();
use Coro::Channel;

sub CHAN () { 0 }

sub new { bless [ Coro::Channel->new($_[1]) ] }

sub to {
    my ( $self, $peer ) = @_;
    Scalar::Util::weaken($self->[CHAN] = $peer->[CHAN]);
}

sub put { Coro::Channel::put($_[0][CHAN], $_[1]) }
sub get { Coro::Channel::get($_[0][CHAN]) }

1;

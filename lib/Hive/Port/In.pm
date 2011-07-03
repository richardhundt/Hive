package Hive::Port::In;

use strict;
use Coro::Channel;

sub CHAN () { 0 }

sub new { bless [ Coro::Channel->new($_[1]) ] }

sub put { Coro::Channel::put($_[0][CHAN], $_[1]) }
sub get { Coro::Channel::get($_[0][CHAN]) }

sub to {
    my ( $self, $peer ) = @_;
    $peer->[CHAN] = $self->[CHAN];
}

1;

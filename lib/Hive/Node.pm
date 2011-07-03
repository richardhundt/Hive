package Hive::Node;

use strict;

use Coro ();
use Scalar::Util ();

use Hive::Port::In;
use Hive::Port::InHash;
use Hive::Port::InArray;
use Hive::Port::Out;
use Hive::Port::OutHash;
use Hive::Port::OutArray;

use Attribute::Handlers;

use base qw/Coro/;

sub new {
    my $class = shift;

    my $exec = $class->can( 'execute' );
    my $wrap = sub {
        unshift @_, $Coro::current;
        &$exec;
    };

    my $self = bless Coro->new( $wrap, @_ ), $class;

    $self->desc( "$self" );
    $self->init( @_ );
    $self->ready;

    return $self;
}

sub In : ATTR(CODE) {
    my ( $class, $glob, $code, $attr, $data ) = @_;
    no strict 'refs';
    no warnings 'redefine';
    my $name = *{ $glob }{NAME};
    *{ $class.'::'.$name } = sub {
        $_[0]{$name} ||= Hive::Port::In->new( @$data );
    };
}

sub InArray : ATTR(CODE) {
    my ( $class, $glob, $code, $attr, $data ) = @_;
    no strict 'refs';
    no warnings 'redefine';
    my $name = *{ $glob }{NAME};
    *{ $class.'::'.$name } = sub {
        $_[0]{$name} ||= Hive::Port::InArray->new( @$data );
    };
}

sub InHash : ATTR(CODE) {
    my ( $class, $glob, $code, $attr, $data ) = @_;
    no strict 'refs';
    no warnings 'redefine';
    my $name = *{ $glob }{NAME};
    *{ $class.'::'.$name } = sub {
        $_[0]{$name} ||= Hive::Port::InHash->new( @$data );
    };
}

sub Out : ATTR(CODE) {
    my ( $class, $glob, $code, $attr, $data ) = @_;
    no strict 'refs';
    no warnings 'redefine';
    my $name = *{ $glob }{NAME};
    *{ $class.'::'.$name } = sub {
        $_[0]{$name} ||= Hive::Port::Out->new( @$data );
    };
}

sub OutArray : ATTR(CODE) {
    my ( $class, $glob, $code, $attr, $data ) = @_;
    no strict 'refs';
    no warnings 'redefine';
    my $name = *{ $glob }{NAME};
    *{ $class.'::'.$name } = sub {
        $_[0]{$name} ||= Hive::Port::OutArray->new( @$data );
    };
}

sub OutHash : ATTR(CODE) {
    my ( $class, $glob, $code, $attr, $data ) = @_;
    no strict 'refs';
    no warnings 'redefine';
    my $name = *{ $glob }{NAME};
    *{ $class.'::'.$name } = sub {
        $_[0]{$name} ||= Hive::Port::OutHash->new( @$data );
    };
}

sub init { }
sub execute { die "abstract" }

1;

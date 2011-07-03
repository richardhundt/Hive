package Hive::Select;

use strict;

use Carp ();

use base qw/Hive::Node/;

sub intake : In;
sub accept : Out;
sub reject : Out;

sub execute {
    my $self = shift;
    my $test = shift || Carp::croak( "need a test code reference" );
    my $data;
    while ( ) {
        $data = $self->intake->get;
        last unless defined $data;
        if ( $test->( $data ) ) {
            $self->accept->put( $data );
        } else {
            $self->reject->put( $data );
        }
    }
    $self->accept->put( undef );
    $self->reject->put( undef );
}

1;

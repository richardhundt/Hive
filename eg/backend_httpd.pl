use lib './lib';

use strict;
use warnings;

use Coro;

my $PORT = $ARGV[0] || 8188;

{
    package My::Parser;
    use strict;
    use HTTP::Request;
    use base qw/Hive::Node/;

    sub intake : In;
    sub output : Out;
    sub execute {
        my $self = shift;
        my $intake = $self->intake;
        my $output = $self->output;
        while ( ) {
            my $buff = '';
            my $line = $intake->get;
            last unless defined $line;
            while ( ) {
                last unless defined $line;
                $buff .= $line;
                last if $line eq "\r\n";
                $line = $intake->get;
            }
            if ( $buff ) {
                $output->put( HTTP::Request->parse( $buff ) );
            } else {
                last;
            }
        }
        $self->output->put( undef );
    }
}

{
    package My::Strify;

    use strict;
    use base qw/Hive::Node/;

    sub intake : In;
    sub output : Out;
    sub execute {
        my $self = shift;
        my $intake = $self->intake;
        my $output = $self->output;
        while ( ) {
            my $resp = $intake->get;
            last unless defined $resp;
            $resp->content_length( length( $resp->content ) );
            $output->put( $resp->as_string("\r\n") );
        }
        $self->output->put( undef );
    }
}

{
    package My::Write;

    use strict;

    use Errno;
    use Coro::Event;
    use Coro::Handle ();

    use base qw/Hive::Node/;

    sub handle : In;
    sub intake : In;

    sub execute {
        my $self = shift;
        my $file = $self->handle->get;
        unless ( UNIVERSAL::isa( $file, 'Coro::Handle' ) ) {
            $file = Coro::Handle::unblock( $file );
        }
        my $data;
        while ( ) {
            $data = $self->intake->get;
            last unless defined $data;
            $file->print( $data );
        }
        $file->close;
    }
}


{
    package My::WebApp;

    use strict;

    use HTTP::Response;

    use base qw/Hive::Node/;
    sub intake : In;
    sub output : Out;
    sub execute {
        my $self = shift;
        my $socket = shift;
        my $intake = $self->intake;
        my $output = $self->output;
        while ( ) {
            my $req = $intake->get;
            last unless defined $req;
            warn "got request: ".$req->as_string();

            my $len = $req->header('Content-Length');
            my $got;
            if ( $len ) {
                my $buf = '';
                while ($len > 0) {
                    $got = $socket->read($buf, $len);
                    last unless defined $got;
                    $len -= $got;
                }
            }
            warn "done reading: got => '$got', len => '$len'";
            
            my $rsp = HTTP::Response->new;
            $rsp->code( 201 );
            $rsp->protocol( 'HTTP/1.0' );
            $rsp->header( Connection => 'keep-alive' );
            $output->put( $rsp );
        }
        $self->output->put( undef );
    }
}

{
    package My::HTTPD;
    use strict;

    use Coro;
    use Coro::Event;
    use Coro::Socket;
    use Hive::Read;
    use Hive::Write;
    use Hive::Muldex;

    use base qw/Hive::Node/;

    sub output : Out;
    sub intake : In;

    sub execute {
        my ( $self, %opts ) = @_;
        my $listen = Coro::Socket->new(
            LocalHost => 'localhost',
            LocalPort => $PORT,
            ReuseAddr => 1,
            Listen    => 1024,
        ) or die $!;

        while ( ) {
            my $socket = $listen->accept;
            next unless $socket;
            my $reader = Hive::Read->new( "\r\n" );
            my $writer = My::Write->new;

            my $webapp = My::WebApp->new( $socket );
            my $parser = My::Parser->new;
            my $strify = My::Strify->new;

            $reader->handle->put( $socket );
            $writer->handle->put( $socket );

            $reader->output->to( $parser->intake );
            $parser->output->to( $webapp->intake );
            $webapp->output->to( $strify->intake );
            $strify->output->to( $writer->intake );
        }
    }
}

my $httpd = My::HTTPD->new;
$httpd->join;

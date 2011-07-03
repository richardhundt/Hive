use lib './lib';

use strict;
use warnings;

use Coro;

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
            $output->put( $resp->as_string("\r\n") );
        }
        $self->output->put( undef );
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
        my $count = 0;
        my $intake = $self->intake;
        my $output = $self->output;
        my $uri_1  = 'http://localhost:8188/file_1.txt';
        my $uri_2  = 'http://localhost:8288/file_2.txt';
        my $cb_uri = 'http://localhost:8088/done';
        while ( ) {
            my $req = $intake->get;
            last unless defined $req;
            warn "REQ: ".$req->as_string;
            my $rsp = HTTP::Response->new;
            $rsp->protocol( 'HTTP/1.0' );
            #$rsp->header( Connection => 'keep-alive' );
            $rsp->header( Connection => 'close' );
            if ( $req->method eq 'PUT' ) {
                if ( $req->uri =~ /done/ ) {
                    warn "doing DONE";
                    $rsp->code( 201 );
                    $rsp->content_length(0);
                }
                else {
                    warn "doing PUT";
                    $rsp->code( 200 );
                    $rsp->header( 'X-REPROXY-URL' => encode_uri($uri_1).' '.encode_uri($uri_2) );
                    $rsp->header( 'X-REPROXY-FINISHED-URL' => encode_uri($cb_uri) );
                }
            }
            elsif ( $req->method eq 'GET' ) {
                warn "doing GET";
                $rsp->code( 200 );
                $rsp->header( 'X-REPROXY-URL' => encode_uri($uri_1).' '.encode_uri($uri_2) );
                $rsp->content_length( 65536 );
            }
            else {
                # OPTIONS
                $rsp->code( 200 );
                $rsp->header('Allow' => join(',', "PUT","GET","OPTIONS","HEAD"));
                $rsp->header('DAV'   => '1,<http://apache.org/dav/propset/fs/1>');
                $rsp->header('Accept-Ranges' => 'bytes');
                $rsp->header('MS-Author-Via' => 'DAV');
                $rsp->header('Keep-Alive' => 'timeout=15, max=96');
            }

            $output->put( $rsp );
            $count++;
        }
        $self->output->put( undef );
    }
    sub encode_uri {
        my $a = $_[0];
        $a =~ s/([^a-zA-Z0-9_\,\-.\/\\\: ])/uc sprintf("%%%02x",ord($1))/eg;
        $a =~ tr/ /+/;
        return $a;
    }
}

{
    package My::HTTPD;
    use strict;

    use Coro;
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
            LocalPort => 8088,
            ReuseAddr => 1,
            Listen    => 1024,
        ) or die $!;

        while ( ) {
            my $socket = $listen->accept;
            next unless $socket;
            my $reader = Hive::Read->new( "\r\n" );
            my $writer = Hive::Write->new;

            my $webapp = My::WebApp->new;
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

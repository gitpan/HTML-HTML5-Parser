use 5.010;
use strict;
use lib 'lib';
use lib 't/lib';

use Test::More;
use HTML::HTML5::Parser;
use HTML::HTML5::Parser::UA;
use URI::file;

{
	package Test::HTTP::Server::Request;
	sub doc1 {
		shift->{out_headers}{content_type} = 'text/html';
		q{<!doctype html>
		<title>Test!</title>
		<p>Test!</p>
		};
	}
}

eval { require Test::HTTP::Server; 1; }
	or plan skip_all => "Could not use Test::HTTP::Server: $@";

plan tests => 3;

my $server  = Test::HTTP::Server->new();
my $baseuri = $server->uri;

$HTML::HTML5::Parser::UA::NO_LWP = 1
	if $HTML::HTML5::Parser::UA::NO_LWP eq '0';

my $file_response = HTML::HTML5::Parser::UA->get(URI::file->new_abs("t/01basic.t"));

is(
	$file_response->{status},
	200,
	"simple file response - status 200",
);

my $http_response = HTML::HTML5::Parser::UA->get($baseuri . 'doc1');

is(
	$file_response->{status},
	200,
	"simple HTTP response - status 200",
);

my $dom = HTML::HTML5::Parser->load_html(location => $baseuri.'doc1');
is(
	$dom->getElementsByTagName('title')->shift->textContent,
	'Test!',
	'UA usage by parser'
)


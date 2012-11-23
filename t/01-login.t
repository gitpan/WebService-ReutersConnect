#!perl -w
use strict;
use warnings;
use Test::More ;
use Log::Log4perl qw/:easy/;
Log::Log4perl->easy_init($DEBUG);

use WebService::ReutersConnect qw/:demo/;

ok( my $reuters = WebService::ReutersConnect->new( { username => 'john', password => 'doe' }), "Ok build a reuter");
ok( ! $reuters->authToken() , "Ok cannot get an auth token from these credentials");
## try connecting with real credentials.
ok( $reuters = WebService::ReutersConnect->new({ username => $ENV{REUTERS_USERNAME} // REUTERS_DEMOUSER,
                                                     password => $ENV{REUTERS_PASSWORD} // REUTERS_DEMOPASSWORD }), "Ok build API");
ok( $reuters->authToken() , "Ok we have an authToken");


done_testing();

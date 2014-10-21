#!perl -w
use strict;
use warnings;
use Test::More ;
use Log::Log4perl qw/:easy/;
Log::Log4perl->easy_init($DEBUG);

use WebService::ReutersConnect qw/:demo/;

my $FRESH_TOKEN;
ok( my $reuters = WebService::ReutersConnect->new({ username => $ENV{REUTERS_USERNAME} // REUTERS_DEMOUSER,
                                                    password => $ENV{REUTERS_PASSWORD} // REUTERS_DEMOPASSWORD,
                                                    refresh_token => 1,
                                                    after_refresh_token => sub{
                                                      my ($t) = @_;
                                                      $FRESH_TOKEN = $t;
                                                    }
                                                  }), "Ok build API");
ok( $reuters->authToken() , "Ok we have an authToken");

## Replace the token by some silly thing and watch it go bang.
$reuters->authToken('someSillyToken');

my @items = $reuters->search();
foreach my $item ( @items ){
  diag("Got item ".$item->headline());
}

cmp_ok( $FRESH_TOKEN , 'eq' , $reuters->authToken() , "Ok the callback has worked");
done_testing();

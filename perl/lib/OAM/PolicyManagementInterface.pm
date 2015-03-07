#!/usr/bin/perl

# WARNING: I don't know what the heck I'm doing
# and I haven't written Perl code in like 15+ years
# so I have no idea if any of this is the right way to write a Perl module

package OAM::PolicyManagementInterface;

use strict;

use JSON;
use REST::Client;
use MIME::Base64;
use Data::Dumper;
use URI::Escape;
#use URI::Encode;

my $OAM_USERNAME = undef;
my $OAM_PASSWORD = undef;
my $OAM_SERVER_URL="http://localhost:7001";

my $client = undef;
my $headers = undef;
my $debug = 0;

sub new
{
    my $class = shift;
    my %args = @_;

	# load the class variables from the arguments
    $debug = $args{'debug'} if exists $args{'debug'};
	$OAM_USERNAME = $args{'username'} if exists $args{'username'};
	$OAM_PASSWORD = $args{'password'} if exists $args{'password'};
	$OAM_SERVER_URL = $args{'serverurl'} if exists $args{'serverurl'};
	
	if ( $debug ) {
		print "Debug: $debug\n";
		print "URL: $OAM_SERVER_URL\n";
		print "USERNAME: $OAM_USERNAME\n";
		print "PASSWORD: $OAM_PASSWORD\n";
	}
	
	$client = REST::Client->new({
		host    => $OAM_SERVER_URL,
	    timeout => 10,
	    follow  => 1,
	});

	my $authheader = 'Basic ' . encode_base64($OAM_USERNAME . ':' . $OAM_PASSWORD);
	$authheader =~ s/\n//;

	$headers = {
	               Accept => 'application/json',
	               Authorization => $authheader,
	            };
	print "HTTP headers:\n=============\n" . Dumper( $headers ) . "\n" if $debug;

    return bless \%args, $class;
}

# cribbed from somewhere
sub is_array {
  my ($ref) = @_;
  # Firstly arrays need to be references, throw
  #  out non-references early.
  return 0 unless ref $ref;

  # Now try and eval a bit of code to treat the
  #  reference as an array.  If it complains
  #  in the 'Not an ARRAY reference' then we're
  #  sure it's not an array, otherwise it was.
  eval {
    my $a = @$ref;
  };
  if ($@=~/^Not an ARRAY reference/) {
    return 0;
  } elsif ($@) {
    die "Unexpected error in eval: $@\n";
  } else {
    return 1;
  }
}



sub getPolicyDomainResources
{
    my $class = shift;
    my $domainname = shift;
    
    print "Getting resources for domain name: $domainname...\n\n" if $debug;
    
    my $uri = '/oam/services/rest/11.1.2.0.0/ssa/policyadmin/resource?appdomain=' . uri_escape($domainname);
     
    $client->GET($uri, $headers);
    
    print "RESPONSE (raw data):\n====================\n" . $client->responseContent() ."\n\n" if $debug;
    
    my $jsondata = from_json($client->responseContent()); 
    
    if ( $debug ) {
        my $json = JSON->new->allow_nonref;
        print "RESPONSE as pretty printed JSON:\n================================\n" . $json->pretty->encode( $jsondata ) . "\n\n";
    
        print "RESPONSE JSON converted to Perl object:\n=======================================\n" . Dumper($jsondata) . "\n";
    }
    
    # then we just want the resources
    my $temp = $jsondata->{'Resource'};
    
    my @resources;
    
    if ( is_array( $temp )) {
        #@resources = @{ $jsondata->{'Resource'} };
        @resources = @{ $temp };
    }
    else {
        @resources = [ $temp ];
    }
    
    print "\nResources (as array):\n=====================\n" . Dumper( @resources ) . "\n" if $debug;
    
    return $jsondata;
}

1;

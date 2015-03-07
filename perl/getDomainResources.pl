#!/usr/bin/perl
use lib 'lib';

use strict;
use OAM::PolicyManagementInterface;
use Data::Dumper;

my $domainname = "IAM Suite";

my $num_args = $#ARGV + 1;
if ($num_args == 1) {
    $domainname = $ARGV[0];
}

my $pmapi = OAM::PolicyManagementInterface->new(
	serverurl   => 'http://oim1admin.example.com:7001',
	username    => 'weblogic',
	password    => 'weblogic1',
#	debug       => 1,
);

my @resources = $pmapi->getPolicyDomainResources( $domainname );


print "\nResources:\n==========\n" . Dumper( @resources ) . "\n";

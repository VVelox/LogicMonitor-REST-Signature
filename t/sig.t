#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'LogicMonitor::REST::Signature' );
}

my $company='foo';
my $accessKey='some key';
my $accessID='some ID';

# make sure it errors when undef or missing values
my $worked=0;
my $lmsig_helper;
eval{
	$lmsig_helper=LogicMonitor::REST::Signature->new({
					});
	$worked=1
};
ok( $worked eq '0', 'init') or diag("Iinitated with missing values");

$worked=0;
eval{
	$lmsig_helper=LogicMonitor::REST::Signature->new({
					company=>$company,
					accessKey=>$accessKey,
					accessID=>$accessID,
				});
	$worked=1
};
ok( $worked eq '1', 'init') or diag("Failed to init the object... ".$@);


#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

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

# make sure we init it
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

# make sure it can generate a known one, which requires a time stamp
$worked=0;
eval{
	my $sig=$lmsig_helper->signature({
					HTTPverb=>'GET',
					path=>'/foo',
					data=>'',
					timestamp=>'1',
				});
	if ( $sig ne 'e0bb5OESDeQdMvtJy1Nr6Nju7Nd9axVXHUhMQjjA3f4=' ){
		die 'Got "'.$sig.'" but was expecting "e0bb5OESDeQdMvtJy1Nr6Nju7Nd9axVXHUhMQjjA3f4="';
	}
	$worked=1
};
ok( $worked eq '1', 'signature 0') or diag("Failed to create the expected signature... ".$@);

# make sure it can generate a known one, which requires a time stamp
$worked=0;
eval{
	my $sig=$lmsig_helper->signature({
					HTTPverb=>'GET',
					path=>'/foo',
					data=>'',
				});
	if (! defined ( $sig ) ){
		die( 'Got a return of undef' );
	}
	$worked=1
};
ok( $worked eq '1', 'signature 1') or diag("Failed to create the a signature when auto generating a timestamp... ".$@);

done_testing(5);

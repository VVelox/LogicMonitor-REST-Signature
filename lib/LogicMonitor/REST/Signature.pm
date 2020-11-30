package LogicMonitor::REST::Signature;

use 5.006;
use strict;
use warnings;
use Time::HiRes qw( gettimeofday );
use Crypt::Mac::HMAC qw( hmac_b64 );

=head1 NAME

LogicMonitor::REST::Signature - The great new LogicMonitor::REST::Signature!

=head1 VERSION

Version 0.0.1

=cut

our $VERSION = '0.0.1';

=head1 SYNOPSIS

	use LogicMonitor::REST::Signature;
    
	my $company   = 'someCompany';
	my $accessKey = 'some key';
	my $accessID  = 'some id';
    
	my $lmsig_helper;
	eval {
		$lmsig_helper = LogicMonitor::REST::Signature->new(
			{
				company   => $company,
				accessID  => $accessID,
				accessKey => $accessKey,
			}
		);
	} if ( !defined($lmsig_helper) ) {
		die( "Failed to initial the module... " . $@ );
	}
    
    my $sig;
    eval{
        $sig=$lmsig_helper->signature({
                                       HTTPverb=>'GET',
                                       path=>/foo/bar',
                                       data=>'foo foo',
                                      });
    };
    if (!defined($sig)){
        die("Failed to generate the signature... ".$@);
    }

=head1 VARIABLES

This is a basic explanation of various variables used in this doc.

=head2 accessID

This is the accessID for the key.

=head2 accessKey

This is the API key.

=head2 company

This is the company name as shown in the URL.

=head2 HTTPverb

This is the HTTP verb for the request in question... so either GET or PUT.

=head2 path

This is the path and any variables in the URL.

    'https://' . $company . '.logicmonitor.com/santaba/rest' . $path

=head2 data

The body of the HTTP request. Can be '', if doing like a GET.

=head2 timestamp

Milliseconds since epoc.

	use Time::HiRes qw( gettimeofday );
	my $timestamp = gettimeofday * 1000;
	$timestamp = int($timestamp);

=head1 METHODS

=head2 new

This requires a hash ref with the following three variables.

    company
    accessID
    accessKey

Example...

	my $lmsig_helper;
	eval {
		$lmsig_helper = LogicMonitor::REST::Signature->new(
			{
				company   => $company,
				accessID  => $accessID,
				accessKey => $accessKey,
			}
		);
	} if ( !defined($lmsig_helper) ) {
		die( "Failed to initial the module... " . $@ );
	}

=cut

sub new {
	my %args;
	if ( defined( $_[1] ) ) {
		%args = { $_[1] };
	}
	else {
		die('No argument hash ref passed');
	}

	# list of required keys
	my $args_valid_keys = {
		company   => 1,
		accessID  => 1,
		accessKey => 1,
	};

	#make sure all the keys required are present
	foreach my $args_key ( keys(%args) ) {
		if ( !defiend( $args{$args_key} ) ) {
			die( 'The key "' . $args_key . '" is not present in the args hash ref' );
		}
	}

	my $self = {
		company   => $args{company},
		accessID  => $args{accessID},
		accessKey => $args{accessKey},
	};
	bless $self;

	return $self;

}

=head2 signature

This generates the signature for a request.

This requires variables below.

    HTTPverb
    path

The value below is optional and will be automatically generated if not
specified, or in the case of data set to ''.

    timestamp
    data

Example...

    my $sig;
    eval{
        $sig=$lmsig_helper->signature({
                                       HTTPverb=>'GET',
                                       path=>/foo/bar',
                                       data=>'foo foo',
                                      });
    };
    if (!defined($sig)){
        die("Failed to generate the signature... ".$@);
    }

Example with timestamp...

    my $sig;
    eval{
        $sig=$lmsig_helper->signature({
                                       HTTPverb=>'GET',
                                       path=>/foo/bar',
                                       timestamp=>'1234',
                                      });
    };
    if (!defined($sig)){
        die("Failed to generate the signature... ".$@);
    }

=cut

sub signature {
	my $self = $_[0];
	my %args;
	if ( defined( $_[1] ) ) {
		%args = { $_[1] };
	}
	else {
		die('No argument hash ref passed');
	}

	# a list of all required keys
	my $args_valid_keys = {
		HTTPverb => 1,
		path     => 1,
	};

	# make sure are the required variables are present
	foreach my $args_key ( keys(%args) ) {
		if ( !defined( $args{$args_key} ) ) {
			die( 'The key "' . $args_key . '" is not present in the args hash ref' );
		}
	}

	# If not specified, assume it is a request it is not needed for and set it to blank.
	if ( !defined( $args{data} ) ) {
		$args{data} = '';
	}

	# generate the timestamp if needed
	# gettimeofday returns microseconds... convert to milliseconds
	if ( !defined( $args{timestmp} ) ) {

		# gettimeofday returns microseconds... convert to milliseconds
		$args{timestamp} = gettimeofday * 1000;

		# appears to only want the integer portion based on their examples
		# https://www.logicmonitor.com/support/rest-api-developers-guide/v1/rest-api-v1-examples
		$args{timestamp} = int( $args{timestamp} );
	}

	# put together the string that will be used for the signature
	# https://www.logicmonitor.com/support/rest-api-developers-guide/overview/using-logicmonitors-rest-api#ss-header-24
	my $string = $args{HTTPverb} . $args{timestamp} . $args{data} . $args{path};

	# create the signature and return it
	my $sig;
	eval {
		$sig = hmac_b64( 'SHA256', $self->{accessKey}, $string );
		if ( !defined($sig) ) {
			die('hmac_b64 returned undef');
		}
	};
	if ($@) {
		die( 'Failed to generate the signature... ' . $@ );
	}

	return $self;
}

=head1 AUTHOR

Zane C. Bowers-Hadley, C<< <vvelox at vvelox.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-logicmonitor-rest-signature at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=LogicMonitor-REST-Signature>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc LogicMonitor::REST::Signature


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=LogicMonitor-REST-Signature>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/LogicMonitor-REST-Signature>

=item * Search CPAN

L<https://metacpan.org/release/LogicMonitor-REST-Signature>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2020 by Zane C. Bowers-Hadley.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1;    # End of LogicMonitor::REST::Signature

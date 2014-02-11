package LCP::Agent;

use 5.008008;

use strict;
use warnings;
use Carp;
# Importing Lib WWW Perl
use LWP;
# Importing Lib WWW Perl's UserAgent module
use LWP::UserAgent;
# Importing Lib CIM Perl's XML query generating module
use LCP::Query;
# Importing Lib CIM Perl's Simple XML parsing module
# WARNING: This behavior may change in the future as more parsers are developed.
use LCP::SimpleParser;
# Importing Lib CIM Perl's Session management module
use LCP::Session;
# Importing the Lib CIM Perl's XML write module which is mostly used by LCP::Query to generate XML snippets; however in the future may be used for low level CIM subset specific implementations
use LCP::XMLWriter;
# Defining the module version number
our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# this is the constructor method
# it expects to be accessed as an OO method so the first input field is not input by the developer using the module and will instead become the instance handle
# the second parameter is the hostname of the CIM server
# the third is a hash reference which may contain several keys defining various options used by any modules this instance is tied too.
sub new{
    # defining the instance of the method
    my $class=shift;
    # defining a host which we instance will attach too.
    my $host=shift;
    # defining any additional options for any connections generated by the instance
    my $options=shift;
    # checking that a host name or IP has been defined
    unless(defined $host){
	# warring the user
	carp "No host defined\n";
	# exiting with failure
	return 0;
    }
    # creating self hash with LWP Agent and hostname
    my $self={
	# unless the user has defined a custom user agent calling Lib WWW Perls and adding it to the agent hash key which will be blessed into the instance latter
        'agent' => $options->{'useragent'} || LWP::UserAgent->new(),
	# defining the host name or IP address as a hash key which will be blessed into the instance of the class later
        'host' => $host,
    };
    # checking if the user set a preference for HTTP or HTTPS transport
    if (defined $options->{'protocol'} and $options->{'protocol'}){
	# checking if the users input was a valid option
        if ($options->{'protocol'}=~/^(http|https)$/i){
	    # if it was valid set it as the protocol hash key which will be blessed into the instance of the class later
            $self->{'protocol'}=$options->{'protocol'};
        }
        else{
	    # warning the user if they specified an invalid transport protocol
	    carp "\"$options->{'protocol'}\"is not a valid protocol please use http or https\n";
	    # exiting with failure
	    return 0;
        }
        
    }
    else{
	#If the user didn't specify a protocol default to HTTPS
        $self->{'protocol'}='https';
    }
    # check if the user specified a port number
    if (defined $options->{'port'} and $options->{'port'}){
	# ensure the port number is a number not just random data
        if ($options->{'port'}=~/^\d+$/){
	    # if it was valid set it as the port hash key which will be blessed into the instance of the class later
            $self->{'port'}=$options->{'port'};
        }
        else{
	    # if its not valid warn the user
            carp "\"$options->{'port'}\" is not a valid port number";
	    # exit in failure
            return 0;
        }
        
    }
    # if the user didn't specify the port set one
    else{
	# if the transport protocol is http
        if ($self->{'protocol'}=~/^http$/i){
	    # Set it to the default HTTP port for WBEM servers
            $self->{'port'}=5988;
        }
	# if the transport protocol is http
        elsif ($self->{'protocol'}=~/^https$/i){
	    # Set it to the default HTTPS port for WBEM servers
	    $self->{'port'}=5989; 
        }
    }
    # Adding authentication info
    # This will change latter when I have time to look into getting things like GSSAPI to work
    if (defined $options->{'username'} and defined $options->{'password'}){
        $self->{'username'}=$options->{'username'};
	$self->{'password'}=$options->{'password'};
    }
    # checking if the version of Lib CIM Perl can do digest auth
    if ($LWP::VERSION >='6.00'){
	# if so setting a hash key which is used latter in the code 
	$self->{'digest_auth_capable'}=1;
    }
    # this didn't work the way I wanted it to I'm open to ideas if any one has one.
    #if(exists LWP::Authen::Digest::new){
	#
    #}
    # creating a hash key containing the full URI for the WBEM server which will be blessed into the instance of the class latter
    $self->{'uri'}=$self->{'protocol'} . '://' . $self->{'host'} . ':' . $self->{port} . '/cimom';
    # WBEM servers support HTTP(S) POST and or the protocol specific M-POST (Method Post) unfortunately not allWBEM servers are created equal.
    # Some handle one better than the other and others only support POST
    # The protocol specification wants clients to use M-POST to be the primary the POST to be the fall back
    # In Lib CIM Perl AUTO is the default and is intended to produce the behavior per the DSP specification; however it doesn't work yet so its currently a synonym for M-POST
    # the user can also hard set it as well
    # here I am checking if the user specified what they want to use
    if (defined $options->{'Method'} and $options->{'Method'}){
	# checking if the users input is valid
	if ($options->{'Method'}=~/^(AUTO|POST|M-POST)$/i){
	    # if the users input is valid setting it to the Method hash key which will latter be blessed into the instance of the class
	    $self->{'Method'}=$options->{'Method'};
	}
	else{
	    # if the users input is not valid let them know
	    carp ("Invalid posting method \"$options->{'Method'}\" Please choose AUTO, POST or MPOST");
	    # exit in failure but don't kill the script.
	    return 0;
	}
    }
    # if the user doesn't specify the method use AUTO
    else {
	$self->{'Method'}='AUTO';
    }
    # checking if time out was specified by the user and its a valid integer
    if (defined $options->{'Timeout'} and $options->{'Timeout'}=~/^\d+$/){
	$self->{'Timeout'}=$options->{'Timeout'};
    }
    # if its has been set and its not a valid integer warn the user and set it to 60 seconds
    elsif(defined $options->{'Timeout'}){
	# notifying the user of the problem.
	carp "WARNING: \"$options->{'Timeout'}\" is not a valid Timeout setting it to the default of 60 seconds\n";
	# Setting the Timeout to the default.
	$self->{'Timeout'}='60';
    }
    # if the user has not specified a timeout set it to 60 seconds
    else{
	$self->{'Timeout'}='60';
    }
    # Check if the user has specified a valid Interop name space
    if (defined $options->{'Interop'} and $options->{'Interop'}=~/\w+(\/\w+)*/){
	# Setting it to the user specified setting
	$self->{'Interop'}=$options->{'Interop'};
    }
    # If the user has specified a namespace but the formatting is invalid warn the user and set it to root/interop
    # This may change to just interop in the future
    elsif(defined $options->{'Interop'}){
	# warning the user with the line number of the calling script
	carp "WARNING: \"$options->{'Interop'}\" does not match the pattern for CIM namespace setting the namespace to root/interop instead\n";
	# more forcefully warning the user with the line number in my module in case I need to re-evaluate my matching pattern 
	warn "ERROR: Overriding the Interop namespace specified for this agent because it failed the format validation check\n";
	$self->{'Interop'}='root/interop';
    }
    # if the user has not specified one set it to root/interop as a best guess
    else{
	$self->{'Interop'}='root/interop';
    }
    # blessing tall of the parsed options
    bless ($self, $class);
    # returning it as an accessor for the user
    return $self;
}

# Returning 1 for success like any Perl module does.
1;


 __END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LCP::Agent - Lib CIM (Common Information Model) Perl

=head1 SYNOPSIS

  use LCP;
  # setting the options for the agent
  my $options={
	'username'=>'someuser',
	'password'=>'somepassword',
	'protocol'=>'http',
	'Method'=>'POST'
  };
  # initializing the agent
  my $agent=LCP::Agent->new('localhost',$options);
  #Creating a session
  my $session=LCP::Session->new($agent);
  # creating a new query
  my $query=LCP::Query->new();
  # Constructing a simple Enumerate classes query against root/cimv2
  $query->EnumerateClasses('root/cimv2');
  # Posting the query
  my $post=LCP::Post->new($session,$query);
  my $tree;
  # Parse if the query executed properly
  if (defined $post and $post->success){
    print "post executed\n";
    #Parsing the query
    my $parser=LCP::SimpleParser->new($post->get_raw_xml);
    # returning a multi dimensional hash of the results
    my $tree=$parser->buildtree;
  }

=head1 DESCRIPTION

LCP::Agent is a class to configure a basic user agent with a set of default options for connecting to a WBEM server. 

=head2 EXPORT

This is an OO Class and as such exports nothing.

=head1 Methods

=over 1

=item new

    $agent=LCP::Agent->new('hostname',%{ 'protocol' =>'https', 'port' => 5989, 'Method'=>'M-POST', username=>'someuser', 'password'=>'somepassword', 'Timeout'=>180, 'useragent' => $optionalUserAgent  });

This class only has one method however its important to set the default information for several of the other classes.
There is one required parameter the hostname or IP address of the WBEM server.
there are 5 optional perimeters defined in a hash that are as follows

=over 2

=item 1 protocol

Protocol is defined as http or https the default if not specified is https

=item 2 port

The port number the WBEM server is listening on. the default if not specified it 5989 for https and 5988 for http.

=item 3 Method

The post method used may be POST, M-POST, or AUTO. if it is not specified the default is AUTO.
POST is the standard http post used by web servers and most API's that utilize http and https
M-POST or Method POST is the DMTF preferred method for Common Information Model it utilizes different headers than the standard POST method however it is not supported by all WBEM servers yet and can be buggy in some others.
AUTO attempts to utilizes M-POST first then fails back to POST if the WBEM server reports it is not supported or if there is a null response.

Unfortunately the fail back for AUTO has not been implemented yet; however it will be in the future so users are encouraged to use it in the mean time for future API compatibility.
The safest choice is POST. Currently not every WBEM server supports M-POST and even some of the ones that do occasionally malfunction and as a result cause the AIP to hang for a few seconds before returning an error or more often a null response.

=item 4 username

The username to use for authentication to the WBEM server

=item 5 password

The password to use for authentication to the WBEM server

=item 6 Timeout

How long to wait in seconds for a query to return results before timing out.

=back

=back

=head1 Advanced Tuning Notes

LCP::Agent uses LWP::UserAgent for a large part of its non CIM specific functionality. The LWP::UserAgent instance can be accessed via the Agent hashref key of the accessor created by the new method.
Advanced developers who are familiar with LWP may utilize this to further tune their settings however this is not advisable for most, and eventually may go away as this module evolves.

If you wish to pass in a mock user agent for testing or for other reasons, the options key to use is 'useragent'.

=head1 SEE ALSO

LCP::Session
LCP::Query
LCP::Post
LCP::SimpleParser
LWP::UserAgent

=head1 AUTHOR

Paul Robert Marino, E<lt>code@TheMarino.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut

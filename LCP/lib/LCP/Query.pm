package LCP::Query;
use strict;
use warnings;
use Carp;
use LCP::XMLWriter;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>


sub new {
    my $class = shift;
    my $xmlwriter=LCP::XMLWriter->new();
    my $self = bless {
                        writer => $xmlwriter
                      }, $class;
    return $self;
}

# Starting Intrinsic CIM Methods
sub GetClass($$$;\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $options=shift;
    my $propertylist=shift;
    $self->{'last_method'}='GetClass';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'LocalOnly'=>1,
        'IncludeQualifiers'=>1,
        'IncludeClassOrigin'=>0,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    my $rawquery={
        namespace=>$namespace,
        classname=>$cimclass,
        options=>$options,
    };
    if (defined $propertylist) {
        $rawquery->{'propertylist'}=$propertylist
    };
    my $method=$self->{'writer'}->mkmethodcall('GetClass');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($rawquery->{'namespace'});
    $namespacetwig->paste( 'first_child' => $method);
    for my $option ($self->{'writer'}->mkbool($rawquery->{'options'})){
        $option->paste('last_child' => $method);
    }
    my $classname=$self->{'writer'}->mkclassname($rawquery->{'classname'});
    $classname->paste('last_child' => $method);
    if (defined $rawquery->{'propertylist'}){
        my $propertylist=$self->{'writer'}->mkpropertylist($rawquery->{'propertylist'});
        $propertylist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
    
}


sub GetInstance($$$$;\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $instanceid=shift;
    my $options=shift;
    my $propertylist=shift;
    $self->{'last_method'}='GetInstance';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'LocalOnly'=>0,
        'IncludeQualifiers'=>0,
        'IncludeClassOrigin'=>0,
    };
    my $optionsconstraints={
	'LocalOnly'=>'boolean',
	'IncludeQualifiers'=>'boolean',
        'IncludeClassOrigin'=>'boolean',
    };
    my $resultoptions=$self->{'writer'}->comparedefaults($defaultoptions,$options,$optionsconstraints);
    my $method=$self->{'writer'}->mkmethodcall('GetInstance',$namespace);
    for my $option ($self->{'writer'}->mkbool($resultoptions)){
        $option->paste('last_child' => $method);
    }
    my $iparam=$self->{'writer'}->mkmethodcall('InstanceName');
    $iparam->paste('last_child' => $method);
    my $instancename=$self->{'writer'}->mkinstancename($cimclass);
    $instancename->paste('last_child' => $iparam);
    for my $option ($self->{'writer'}->mkkeybinding($instanceid)){
        $option->paste('last_child' => $instancename);
    }
    #my $keybindings=$self->mkkeybindingxml($instanceid);
    if (defined $propertylist){
        my $proplist=$self->{'writer'}->mkpropertylist($propertylist);
        $proplist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);

}



# Untested
sub DeleteClass($$$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    $self->{'last_method'}='DeleteClass';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('DeleteClass');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    my $classname=$self->{'writer'}->mkclassname($cimclass);
    $classname->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub DeleteInstance{
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $properties=shift;
    $self->{'last_method'}='DeleteInstance';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('DeleteInstance');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste('last_child' => $method);
    my $instance=$self->{'writer'}->mkdelinstance($cimclass,$properties);
    $instance->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}


# need a better understanding before I'll attempt it
sub CreateClass{
    carp "CreateClass not implemented yet\n";
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $cimsuperclass=shift;
    $self->{'last_method'}='CreateClass';
    $self->{'last_namespace'}=$namespace;
    return 0;
}

sub CreateInstance($$$\%){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $properties=shift;
    $self->{'last_method'}='CreateInstance';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('CreateInstance');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste('last_child' => $method);
    my $newinstance=$self->{'writer'}->mknewinstance($cimclass,$properties);
    $newinstance->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}

#not implemented yet
sub ModifyClass {
	carp "ModifyClass not implemented yet\n";
	return 0;
}

#not implemented yet
sub ModifyInstance{
	carp "ModifyInstance not implemented yet\n";
	return 0;
}

sub EnumerateClasses($$;$\%){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $options=shift;
    $self->{'last_method'}='EnumerateClasses';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'LocalOnly'=>1,
        'DeepInheritance'=>0,
        'IncludeQualifiers'=>1,
        'IncludeClassOrigin'=>0,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    my $method=$self->{'writer'}->mkmethodcall('EnumerateClasses');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }

    if ($cimclass and $cimclass !~ /^NULL$/i){
        my $classname=$self->{'writer'}->mkclassname($cimclass);
        $classname->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
    
}

# DeepInheritance is good here even though it violates spec
sub EnumerateClassNames($$;$\%){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $options=shift;
    $self->{'last_method'}='EnumerateClassNames';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'DeepInheritance'=>0,
    };
    my $optionsconstraints={
	'DeepInheritance'=>'boolean',
    };
    my $resultoptions=$self->{'writer'}->comparedefaults($defaultoptions,$options,$optionsconstraints);
    my $method=$self->{'writer'}->mkmethodcall('EnumerateClassNames');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    for my $option ($self->{'writer'}->mkbool($resultoptions)){
        $option->paste('last_child' => $method);
    }
    if (defined $cimclass and $cimclass !~ /^NULL$/i){
        my $classname=$self->{'writer'}->mkclassname($cimclass);
        $classname->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub EnumerateInstances($$$;\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $options=shift;
    my $propertylist=shift;
    $self->{'last_method'}='EnumerateInstances';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
        'LocalOnly'=>0,
        'DeepInheritance'=>1,
        'IncludeQualifiers'=>0,
        'IncludeClassOrigin'=>0,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    my $method=$self->{'writer'}->mkmethodcall('EnumerateInstances');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    my $classname=$self->{'writer'}->mkclassname($cimclass);
    $classname->paste('last_child' => $method);
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }
    #my $classname=$self->{'writer'}->mkclassname($cimclass);
    #$classname->paste('last_child' => $method);
    if (defined $propertylist){
        my $proplist=$self->{'writer'}->mkpropertylist($propertylist);
        $proplist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub EnumerateInstanceNames($$$\%){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $options=shift;
    my $defaultoptions={
        'DeepInheritance'=>1,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    $self->{'last_method'}='EnumerateInstanceNames';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('EnumerateInstanceNames');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    my $classname=$self->{'writer'}->mkclassname($cimclass);
    $classname->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub ExecQuery{
    carp "ExecQuery not implemented yet\n";
    return 0;
}
   
sub Associators($$$;\%$$$$\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $rawobjectname=shift;
    my $associatedclass=shift;
    my $resultclass=shift;
    my $role=shift;
    my $resultrole=shift;
    my $options=shift;
    my $propertylist=shift;
    $self->{'last_method'}='Associators';
    $self->{'last_namespace'}=$namespace;
    my $defaultoptions={
	'IncludeQualifiers'=>0,
	'IncludeClassOrigin'=>0,
    };
    for my $key (keys %{$defaultoptions}){
	unless (defined $options->{$key}){
	    $options->{$key}=$defaultoptions->{$key};
	}
    }
    my $method=$self->{'writer'}->mkmethodcall('Associators');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }
    if ($rawobjectname){
	my $keybindings=$self->{'writer'}->mkkeybinding($rawobjectname);
	my $objectname=$self->{'writer'}->mkobjectname($cimclass,$keybindings);
	$objectname->paste('last_child' => $method);
    }
    else{
	my $objectname=$self->{'writer'}->mkobjectname($cimclass);
	$objectname->paste('last_child' => $method);
    }
    if (defined $associatedclass and $associatedclass !~ /^NULL$/i){
        my $assocclass=$self->{'writer'}->mkassocclass($associatedclass);
        $assocclass->paste('last_child' => $method);
    }
    if (defined $resultclass and $resultclass !~ /^NULL$/i){
        my $resclass=$self->{'writer'}->mkresultclass($associatedclass);
        $resclass->paste('last_child' => $method);
    }
    if(defined $role and $role !~ /^NULL$/i){
        my $rolevalue=$self->{'writer'}->mkrole($role);
        $rolevalue->paste('last_child' => $method);
    }
    if(defined $resultrole and $resultrole !~ /^NULL$/i){
        my $resrole=$self->{'writer'}->mkresultrole($role);
        $resrole->paste('last_child' => $method);
    }
    if (defined $propertylist){
        my $proplist=$self->{'writer'}->mkpropertylist($propertylist);
        $proplist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub AssociatorNames($$$;\%$$$$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $rawobjectname=shift;
    my $associatedclass=shift;
    my $resultclass=shift;
    my $role=shift;
    my $resultrole=shift;
    $self->{'last_method'}='AssociatorNames';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('AssociatorNames');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    if ($rawobjectname){
	my $keybindings=$self->{'writer'}->mkkeybinding($rawobjectname);
	my $objectname=$self->{'writer'}->mkobjectname($cimclass,$keybindings);
	$objectname->paste('last_child' => $method);
    }
    else{
	my $objectname=$self->{'writer'}->mkobjectname($cimclass);
	$objectname->paste('last_child' => $method);
    }
    if (defined $associatedclass and $associatedclass !~ /^NULL$/i){
        my $assocclass=$self->{'writer'}->mkassocclass($associatedclass);
        $assocclass->paste('last_child' => $method);
    }
    if (defined $resultclass and $resultclass !~ /^NULL$/i){
        my $resclass=$self->{'writer'}->mkresultclass($resultclass);
        $resclass->paste('last_child' => $method);
    }
    if(defined $role and $role !~ /^NULL$/i){
        my $rolevalue=$self->{'writer'}->mkrole($role);
        $rolevalue->paste('last_child' => $method);
    }
    if(defined $resultrole and $resultrole !~ /^NULL$/i){
       my $resrole=$self->{'writer'}->mkresultrole($role);
        $resrole->paste('last_child' => $method); 
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}


sub References($$$;\%$$\%\@){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $rawobjectname=shift;
    my $resultclass=shift;
    my $role=shift;
    my $options=shift;
    my $propertylist=shift;
    my $defaultoptions={
        'IncludeQualifiers'=>0,
        'IncludeClassOrigin'=>0,
    };
    for my $key (keys %{$defaultoptions}){
            unless (defined $options->{$key}){
                $options->{$key}=$defaultoptions->{$key};
            }
        
    }
    $self->{'last_method'}='References';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('References');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    if ($rawobjectname){
	my $keybindings=$self->{'writer'}->mkkeybinding($rawobjectname);
	my $objectname=$self->{'writer'}->mkobjectname($cimclass,$keybindings);
	$objectname->paste('last_child' => $method);
    }
    else{
	my $objectname=$self->{'writer'}->mkobjectname($cimclass);
	$objectname->paste('last_child' => $method);
    }
    if (defined $resultclass and $resultclass !~ /^NULL$/i){
        my $resclass=$self->{'writer'}->mkresultclass($resultclass);
        $resclass->paste('last_child' => $method);
    }
    if(defined $role and $role !~ /^NULL$/i){
        my $rolevalue=$self->{'writer'}->mkrole($role);
        $rolevalue->paste('last_child' => $method);
    }
    for my $option ($self->{'writer'}->mkbool($options)){
        $option->paste('last_child' => $method);
    }
    if (defined $propertylist){
        my $proplist=$self->{'writer'}->mkpropertylist($propertylist);
        $proplist->paste('last_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub ReferenceNames($$$\%;$$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $rawobjectname=shift;
    my $resultclass=shift;
    my $role=shift;
        $self->{'last_method'}='ReferenceNames';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('ReferenceNames');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    if ($rawobjectname){
	my $keybindings=$self->{'writer'}->mkkeybinding($rawobjectname);
	my $objectname=$self->{'writer'}->mkobjectname($cimclass,$keybindings);
	$objectname->paste('last_child' => $method);
    }
    else{
	my $objectname=$self->{'writer'}->mkobjectname($cimclass);
	$objectname->paste('last_child' => $method);
        if (defined $resultclass and $resultclass !~ /^NULL$/i){
	    my $resclass=$self->{'writer'}->mkresultclass($resultclass);
	    $resclass->paste('last_child' => $method);
	}
	if(defined $role and $role !~ /^NULL$/i){
	    my $rolevalue=$self->{'writer'}->mkrole($role);
	    $rolevalue->paste('last_child' => $method);
	}
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}

sub GetProperty($$$\%$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $filter=shift;
    my $property=shift;
    $self->{'last_method'}='GetProperty';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('GetProperty');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    my $keybindings=$self->{'writer'}->mkkeybinding($filter);
    my $instancename=$self->{'writer'}->mkinstancename($cimclass,$keybindings);
    $instancename->paste( 'first_child' => $method);
    if($property){
        my $propname=$self->{'writer'}->mkpropertyname($property);
        $propname->paste( 'first_child' => $method);
    }
    push(@{$self->{'writer'}->{'query'}},$method);
}


sub SetProperty($$$\%$$){
    my $self=shift;
    my $namespace=shift;
    my $cimclass=shift;
    my $instance=shift;
    my $properety=shift;
    my $value=shift;
    $self->{'last_method'}='SetProperty';
    $self->{'last_namespace'}=$namespace;
    my $method=$self->{'writer'}->mkmethodcall('SetProperty');
    my $namespacetwig=$self->{'writer'}->mklocalnamespace($namespace);
    $namespacetwig->paste( 'first_child' => $method);
    my $propname=$self->{'writer'}->mkpropertyname($properety);
    $propname->paste('last_child' => $method);
    my $propvalue=$self->{'writer'}->mkpropertyvalue($value);
    $propvalue->paste('last_child' => $method);
    my $instancename=$self->{'writer'}->mkinstancename($cimclass,$self->{'writer'}->mkkeybinding($instance));
    $instancename->paste('last_child' => $method);
    push(@{$self->{'writer'}->{'query'}},$method);
}

#not implemented yet
sub GetQualifier{
	carp "GetQualifier not implemented yet\n";
    return 0;
}

#not implemented yet
sub SetQualifier{
	carp "SetQualifier not implemented yet\n";
    return 0;
}

#not implemented yet
sub DeleteQualifier{
	carp "DeleteQualifier not implemented yet\n";
    return 0;
}

1;

__END__


=head1 NAME

LCP::Query - Lib CIM (Common Information Model) Perl Query Costructor

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
    # returning a multi dimentional hash reference of the results
    my $tree=$parser->buildtree;
  }

E<10>

=head1 DESCRIPTION

=over 4

=item Constructs a CIM query based on the Intrinsic CIM methods as defined in DSP0200

=back

=head2 EXPORT

=over 4

=item This is an OO Class and as such exports nothing

=back

=head1 FIELD FORMATS

=head2 FIELD VALUE Constraints

=head3 CIMType constraint

=over 4

=item The CIMType constraint is a common constraint used in two contexts. The first is as a value of a field defining a constraint on a second field. The second is defining a restricting the contents of a field.

=item The possible typs of constraints supported by the CIMType constraints are as follows.

=item boolean, string, char16, uint8, sint8, uint16, sint16, uint32, sint32, uint64, sint64, datetime, real32, or real64

=back

=head2 B<Specialy Formated Fields>



=head3 B<Keybinding>

=over 4



=item Keyindings are a complex key value paring construct that includes a name, value or value reference, valuetype description, and type description.

=item

=item Stucturally each key in a keybinding contains the following elements.

=item

=item NAME

The NAME field is a requiered field containing a string that defines the name of the key

=item VALUE.REFERENCE or VALUE

Next you must define either the VALUE.REFERENCE or VALUE

B<WARNING:> Creation of a VALUE.REFERENCE is not currently supported by this API yet but will be in the future.

The VALUE field is a field containing a string, boolean, or numeric data. If you define the VALUE field you can define the VALUETYPE, and TYPE fields.

=item VALUETYPE

The VALUETYPE field describes the type of data contained in the VALUE field. The VALUETYPE may be defined as string, boolean, or numeric.

If the VALUE field is defined and VALUETYPE is not defined it will default to "string"

=item TYPE

The TYPE field is an extended description of the content of the VALUE field which may be defined as any one of the types defined in the "CIMType constraint". the default is undefind but implied by the VALUETYPE field.

B<WARNING:> Not all implementions of CIM-XML and WBEM handle the TYPE filed in a key binding properly and some even tools consider it to be invalid despite the fact that it is clearly included in the specification, so defining it may break things. At this time I advise users not to set this field unless you are trying to QA test other implementations CIM-XML or your WBEM servers.

=item LCP supports defining a key binding in 4 different formats

=back

=head4 Simple hash
    C<<< %hash=(
      'key1'=>'value1',
      'key2'=>'35',
      'key3'=>$value_ref_object
    ); >>>

E<10>

=over 4

=item In the simple hash format all VALUETYPE fields are set to string unless the value is a VALUE.REFERENCE object 

=back

=head4 Complex hash
    C<<< %hash=(
	'key1'=>{
	    'VALUE'=>'value1',
	    'VALUETYPE'=>'string'
	},
	'key2'=>{
	    'VALUE'=>'35',
	    'VALUETYPE'=>'numeric',
	    'TYPE'=>'uint8',
	}
	'key3'=>{
	    'VALUE.REFERENCE'=>$value_ref_object
	}
    ); >>>

E<10>

=over 4

=item The name of the top level key is the name of the keybinding

=item The supported fields for the child hash are as follows

=item 1) B<VALUE>

The VALUE field is requiered unless a VALUE.REFERENCE is defined. It should contain the value of the keybinding

=item 2) B<VALUE.REFERENCE>

The VALUE.REFERENCE is only valid and required if the VALUE field has not been defined. It shoud contain and reference to a VALUE.REFERENCE object.

B<Caviot:> LCP does not support the creation of VALUE.REFERENCE objects yet but will in the future.

=item 3) B<VALUETYPE>

The VALUETYPE field is only valid if the VALUE field is defined. The contents may be defined as 'string', 'boolean', or 'numeric', and should describe the contents of the VALUE field. If the VALUETYPE is not defined then it defaults to string which is safe in most but not all cases.

=item 4) B<TYPE>

The TYPE field is an optional field which is only valid if the VALUE field is defined. Its contains should be any one of the values described in the "CIMType constraint", and should be a more percise description of the data contained in the VALUE field. If the TYPE is not specified it is left undefined in the key binding, and the standard considers it to be implied by the VALUETYPE feild

B<WARNING:> Implementation of the TYPE filed in a keybinding is inconsistant and some CIM implementations break when you define it. As such I advise users not to define it unless absolutly nessisary or you want to QA test other CIM implementations.

=item Each Key must contain a hash with either a VALUE or a VALUE.REFERENCE defined.

=item If both a VALUE and a VALUE.REFERENCE are defined the VALUE.REFERENCE will be ignored.

=item If the default for VALUETYPE is "string" if a VALUE is specified and the VALUETYPE has not been defined.

=back

=head4 Mixed Hash
    C<<< %hash=(
	'key1'=>'value1',
	'key2'=>{
	    'VALUE'=>'35',
	    'VALUETYPE'=>'numeric',
	    'TYPE'=>'uint8'
	}
	'key3'=>$value_ref_object
    ); >>>

E<10>

=over 4

=item You may use both the simple and complex format in a single hash mixed hash if you find it more convinient each key will function in accordent to the rules of the simple or complex format as apropriate

=back

=head4 Array of Hashes
    C<<< @array(
	{
	    'NAME'=>'key1',
	    'VALUE'=>'value1'
	},
	{
	    'NAME'=>'key2',
	    'VALUE'=>'35',
	    'VALUETYPE'=>'numeric',
	    'TYPE'=>'uint8'
	},
	{
	    'NAME'=>'key3'
	    'VALUE.REFERENCE'=>$value_ref_object
        },
    ); >>>

E<10>

=over 4

=item Defining a keybinding has one major advantage it preserves the order of the keys where as the other methods do not.

=item This method is an array containing hahs references in a complex format containing no less than 2 and up to 5 fields.

=item The keys are as follows.

=item 1) B<NAME>

The NAME field is a requierd field containing the name of the key

=item 2) B<VALUE>

The VALUE field is requiered unless a VALUE.REFERENCE is defined. It should contain the value of the keybinding

=item 3) B<VALUE.REFERENCE>

The VALUE.REFERENCE is only valid and required if the VALUE field has not been defined. It shoud contain and referent to a VALUE.REFERENCE object.

B<Caviot:> LCP does not support the creation of VALUE.REFERENCE objects yet but will in the future

=item 3) B<VALUETYPE>

The VALUETYPE field is only valid if the VALUE field is defined. The contents may be defined as 'string', 'boolean', or 'numeric', and should describe the contents of the VALUE field. If the VALUETYPE is not defined then it defaults to string which is safe in most but not all cases.

=item 5) B<TYPE>

The TYPE field is an optional field which is only valid if the VALUE field is defined. Its contains should be any one of the values described in the "CIMType constraint", and should be a more percise description of the data contained in the VALUE field. If the TYPE is not specified it is left undefined in the key binding, and the standard considers it to be implied by the VALUETYPE feild

B<WARNING:> Implementation of the TYPE filed in a keybinding is inconsistant and some CIM implementations break when you define it. As such I advise users not to define it unless absolutly nessisary or you want to QA test other CIM implementations.

=back

=head1 Basic Methods

=head2 new
  C<<< $query=LCP::Query->new(); >>>

=over 4
    
=item Creates an accessor for a new query.

=back

=head1 Using The Intrinsic Methods

E<10>

=over 4

=item Each intrisic method is a Perl style version of a method spesified in DTMF DSP0200. All WBEM servers tested with this class thus far support simple queries which means you can use one intrinsic method per instance of the class. If your WBEM server supports it multipart queries may also be generated by simply calling multiple intrinsic methods against a single instance of the class. 

=back


=head2 Intrinsic Methods

E<10>

=head3 GetClass
    C<<< $query->GetClass('Name/Space','ClassName',{ 'LocalOnly'=>1, 'IncludeQualifiers'=>1, IncludeClassOrigin=>0},['property1','property2']);
    $query->GetClass('Name/Space','ClassName',{ 'LocalOnly'=>1, 'IncludeQualifiers'=>1, IncludeClassOrigin=>0},['property1','property2']);
    $query->GetClass('name/space','ClassName',{ 'LocalOnly'=>0, 'IncludeQualifiers'=>1, IncludeClassOrigin=>0});
    $query->GetClass('name/space','ClassName',{},['property1','property2']);
    $query->GetClass('name/space','ClassName'); >>>

E<10>

=over 4

=item The GetClass method retrievs the structural information about a CIM class, this is information that describes the fields, if they are required or optional, the type of data the fields may contain, and in most cases any relivant documentation about how the Class is inteded to be used.

=item The LCP::Query's GetClass method requiers 2 fields and has 2 optional fields described as follows.

=item B<1) Name/Space>

The CIM namespace you want to query

This field is requiered

=item B<<< 2) <ClassName> >>>>

The name of the CIM class you want information about

This field is requiered

=item 3) Query Modifiers

An optional hash reference containing any combination of the following query modifiers

=back

=over 6

B<3.1) LocalOnly>

=back

=over 8

If set to 1 (True) local only will instruct the WBEM server to only return elements which have been added to or overriden in the class from its original defaults.

If set to 0 (False) it will return all elements of the class

Defaults to 1 (True)

=back

=over 6

B<3.2) IncludeQualifiers>

=back

=over 8

If set to 1 (True) all qualifiers will be includer in the results

If set to 0 (False) no qualifiers will be included in the result

Defaults to 1 (True)

=back

=over 6

B<3.3) IncludeClassOrigin>

=back

=over 8

If set to 1 (True) the name of origin class from which the class you are querying inherits from will be included.

If set to 0 (False) the name of the origin class will not be included in the results.

Defaults to 0 (False)

=back

=over 4

=item 4) Propperty Array Reference

['property1','property2']

An optional array reference containing a list of specific properties names you want to know about instead of retuning every thing.

=item See DSP0200 Version 1.3.1 section 5.3.2.1 for details

=back

=head3 GetInstance
    C<<< $query->GetInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format,{ 'LocalOnly'=>1, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0},['property1','property2']);
    $query->GetInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format,{ 'LocalOnly'=>1, 'IncludeQualifiers' =>1, IncludeClassOrigin=> 0});
    $query->GetInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format,{},['property1','property2']);
    $query->GetInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format); >>>

=over 4

=item GetInstance retrieves the contents of a specific instance of a CIM class.

=item The LCP::Query's GetInstance method requiers 3 fields and has 2 optional fields described as follows.

=item B<1) name/space>

The CIM namespace you want to query

This field is requiered

=item B<2) ClassName>

The name of the CIM class you want information about

This field is requiered

=item B<3) InstanceName>

A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specialy Formated Fields" section.

This field is requiered

=item B<4) Query Modifiers>

An optional hash reference containing any combination of the following query modifiers 

=back

=over 6

B<4.1) LocalOnly>

=back

=over 8

If set to 1 (True) the behavior varies base on which version of the standard the WBEM server supports.

=back

=over 10

In versions prior to 1.1 of the standard this modifier to 1 (True) returns only the elements that differ from the defaults of the class or differ from the defaults of the parent classes for elements which are inherited from other classes.

In version 1.1 or higher of the standard setting this modifier to 1 (True) only returns the elements in the instance that are different from the defaults for class will be returned but not any elements inherited from a parent class unless their defaults in the class you are querieing differ from the parent class. Any elements of the instance that have been altered which were inherited from the parent class are not included in the results.

=back

=over 8

If set to 0 (False) all elements of the instance except those filterd out by other options will be returned.

B<WARNING: This modifier is deprecated in the standard for the GetInstance method and will be removed from a future version of the standard. In the mean time the DMTF advises you to set it to 0 (False), furthermore some WBEM servers now ignore this modifier and act as though it set to 0 (False) regardles of what you set it to.>

See DSP0200 Version 1.3.1 section ANNEX B "LocalOnly Parameter Discussion" for details

=back

=over 6

=item Defaults to 0 (False)


B<4.2) IncludeQualifiers>

=back

=over 8

If set to 1 (True) includes the qualifiers for the instance will be returned in the results.

If set to 0 (False) no qualifiers will be included in the results.

B<WARNING: This modifier is deprecated and will be removed in a future version of the standard. In the meen time the DMTF advises you to set it to 0 (False), in addition WBEM servers are nolonger requierd to honer it if you set it to 1 (True). The prefered menthod to get the qualifiers is to use the GetClass method instead.>

Defaults to 0 (False)

=back

=over 6

B<4.3) IncludeClassOrigin>

=back

=over 8

If set to 1 (True) all of the elements which were inherited from a parent class will include an CLASSORIGIN element discribing which class it was inherited from.

If set to 0 (False) the no CLASSORIGIN tags will be included.

Defaults to 0 (False)

=back

=over 4

=item B<5) ['property1','property2']>

An optional array reference containing a list of specific properties you want the values of instead of retuning all of the properties in the instance.

=item See DSP0200 Version 1.3.1 section 5.3.2.2 for details

=back

=head3 DeleteClass
C<<< $query->DeleteClass('name/space','ClassName') >>>

DeleteClass deletes a CIM Class from a namespace.
The LCP::Query's DeleteClass method requiers 2 fields described as follows

1) name/space
The CIM namespace you want to delet the class from
This field is requiered
2) ClassName
The name of the CIM class you want delete
This field is requiered


WARNING: This method has not been tested yet

See DSP0200 Version 1.3.1 section 5.3.2.3 for details


=head3 DeleteInstance
    C<<<	$query->DeleteInstance ('name/space','ClassName',$InstanceName_reference_in_keybinding_format); >>>

=over 4

=item DeleteInstance deletes a specific instance of a CIM class from a namespace.

=item The LCP::Query's DeleteInstance method requiers 3 fields described as follows.

=item B<1) name/space>

The CIM namespace you want to delete the instance from.

This field is requiered

=item B<2) ClassName>

The name of the CIM class you want delete an intance of.

This field is requiered

=item B<3) InstanceName> 

A hash or array reference matching a valid keybinding format which describes the instance of the class you want to delete. Please see the Keybinding field format described in the "Specialy Formated Fields" section.

This field is requiered

=item B<WARNING: This method has not been tested yet>

=item See DSP0200 Version 1.3.1 section 5.3.2.4 for details

=back

=head3 CreateClass

=over 4

=item Not implemented yet

=back

=head3 CreateInstance
    C<<< $query->CreateInstance('name/space','ClassName',$InstanceName_reference_in_keybinding_format); >>>

=over 4

=item CreateInstance creates specific uniqe instance of a CIM class in a namespace.

=item The LCP::Query's CreateInstance method requiers 3 fields described as follows.

=item B<1) name/space>

The CIM namespace you want to create the instance of the class in

This field is requiered

=item B<2) ClassName>

The name of the CIM class you want create an intance of.

This field is requiered

=item 3) InstanceName

A hash or array reference matching a valid keybinding format which describes the instance including all of its properties of the class you want to create. Please see the Keybinding field format described in the "Specialy Formated Fields" section. The exact keys allowed are CIM class specific.

=item See DSP0200 Version 1.3.1 section 5.3.2.6 for details

=back

=head3 ModifyClass

=over 4

=item Not implemented yet

=back

=head3 ModifyInstance

=over 4

=item Not implemented yet

=back


=head3 EnumerateClasses
    C<<< $query->EnumerateClasses('name/space','ClassName', { 'DeepInheritance' = 0, 'LocalOnly' = 1, 'IncludeQualifiers' = 1, 'IncludeClassOrigin' = 1});
    $query->EnumerateClasses('name/space','ClassName');
    $query->EnumerateClasses('name/space','NULL', { 'DeepInheritance' = 0, 'LocalOnly' = 1, 'IncludeQualifiers' = 1, 'IncludeClassOrigin' = 1});
    $query->EnumerateClasses('name/space',, { 'DeepInheritance' = 0, 'LocalOnly' = 1, 'IncludeQualifiers' = 1, 'IncludeClassOrigin' = 1});
    $query->EnumerateClasses('name/space'); >>>

E<10>

=over 4

=item EnumerateClasses outputs the structure of a class and any of its subclasses the results are nearly identical to that of doing multiple GetClass operations; however if any classes inherit from the class specified in the ClassName field they will be included in the results as well.

=item The LCP::Query's EnumerateClasses method requiers 1 fields and has 2 optional fields described as follows.

E<10>

=item B<1) name/space>

The CIM namespace you want to enumerate the classes from

This field is requiered

=item B<2) ClassName>

The name of the CIM class you want information about.

This field is optional. If you dont wish to specify a value but wish to specify the next field you may leave it empty or set it to 'NULL'

=item B<3) Query Modifiers>

An optional hash reference containing any combination of the following query modifiers 

=back

=over 6

B<3.1) DeepInheritance>

=back

=over 8

If this modifier is set to 1 (True) and you have specified a class in the ClassName field then all subclasses that inherit directly or indirectly from that class will be returned.

If this modifier is set to 1 (True) and no class has been specified in the ClassName field or the ClassName field has explicitly been set to NULL then all classes in the namespace will be returned.

If this modifier is set to 0 (False) and you have specified a class in the ClassName field then only the classes that directly inherit from the class specified will be returned.

If this modifier is set to 0 (False) and no class has been specified in the ClassName field or the ClassName field has explicitly been set to NULL then only the base classes in the namespace will be returned.

Defaults to 0 (False)

=back

=over 6

B<3.2) LocalOnly>

=back

=over 8

If set to 1 (True) only elements modified or defined specificly in the ClassName field will be included in the result, but not any elements inheitered from the origin class which havent been overriden.

If set to 0 (False) all elements will be included in the results.

Defaults to 1 (True)

=back

=over 6

B<3.2) IncludeQualifiers>

=back

=over 8

If set to 1 (True) includes the qualifiers for the instance will be returned in the results.

If set to 0 (False) no qualifiers will be included in the results.

Defaults to 1 (True)

=back

=over 6

3.3) IncludeClassOrigin

=back

=over 8

If set to 1 (True) all elements inherited from a parent class will include a CLASSORIGIN field specifying what class it was inhrited from

If set to 0 (True) no elements will include the CLASSORIGIN field.

Setting this field to 1 (True) only makes sence if you set LocalOnly to 0 (False)

Defaults to 0 (False)

=back

=over 4

=item See DSP0200 Version 1.3.1 section 5.3.2.9 for details

=back

=head3 EnumerateClassNames
    C<<< $query->EnumerateClassNames ('name/space','ClassName', { 'DeepInheritance' = 0});
    $query->EnumerateClassNames ('name/space',, { 'DeepInheritance' = 0});
    $query->EnumerateClassNames ('name/space','NULL', { 'DeepInheritance' = 0});
    $query->EnumerateClassNames ('name/space','ClassName');
    $query->EnumerateClassNames ('name/space'); >>>

=over 4

=item The EnumerateClassNames method returns the names of any CIM classes that inherit from the CIM class name specified in the ClassName or if the ClassName filed is not specified the it returns the names of all of the base CIM classes in the name space specified in the name/space field.

=item The LCP::Query's EnumerateClassNames method requiers 1 fields and has 2 optional fields described as follows.


=item B<1) name/space>

The CIM namespace you want to enumerate the class names from

This field is requiered

=item B<2) ClassName>

The name of the CIM class you want to enumerate the class names of

This field is optional.

If you dont wish to specify a value but wish to specify the next field you may leave it empty or sete it to 'NULL'

B<Note:> this may not sound like it make sence but it does especialy when you enable the Deepinheritence modifier

=item B<3) Query Modifiers>

An optional hash reference containing any combination of the following query modifiers 


=back

=over 6

B<3.1) DeepInheritance>

=back

=over 8

If this modifier is set to 1 (True) and you have specified a class in the ClassName field then all of the names of any of subclasses that inherit directly or indirectly from that class will be returned as well.

If this modifier is set to 1 (True) and no class has been specified in the ClassName field or the ClassName field has explicitly been set to NULL then the names of all classes in the namespace will be returned.

If this modifier is set to 0 (False) and you have specified a class in the ClassName field then only the names of the classes which directly inherit from the one specified will be returned

If this modifier is set to 0 (False) and no class has been specified in the ClassName field or the ClassName field has explicitly been set to NULL then only the names of the base classes in the namespace will be returned.

Defaults to 0 (False)

=back

=over 4

=item B<Implementation Note:>

One of the common complaints about SMI-S is that the class names are not standardized from one vendor to the next; but this is a half truth.

SMI-S allows a vendor to create their own CIM subclasses of the CIM classes named the standard. This allows the vendor to add fields for their one propriatary features and in some cases remove optional fields that do not apply to their devices. By using the EnumerateClassNames CIM Intrinsic method with DeepInheritance enabled you can usually figure out very quickly what the vendor specific CIM class names are, or if youre in doubt just assume they all are.

For example if I wanted to know the name of the vendor specific version of CIM_ComputerSystem on a Fedora Linux box with SBLIM and TOG_OpenPegasus installed I would execute the following query

here is the query I might create.

=back

=over 6

C<<< $query->EnumerateClassNames ('name/space','CIM_ComputerSystem', { 'DeepInheritance' = 1}); >>>

=back

=over 4

Once the query was posted and the results parsed results were either of the following two results depending on the value of DeepInheritance.

With DeepInheritence set to 0 (False) it returns

=back

=over 6

C<"CIM_Cluster", "CIM_VirtualComputerSystem", "CIM_UnitaryComputerSystem", "Linux_ComputerSystem", "Xen_ComputerSystem", "KVM_ComputerSystem", "LXC_ComputerSystem">

=back

=over 4

With DeepInheritence set to 1 (True) it returns

=back

=over 6

C<"CIM_Cluster", "PG_ComputerSystem", "CIM_VirtualComputerSystem", "CIM_UnitaryComputerSystem", "Linux_ComputerSystem", "Xen_ComputerSystem", "KVM_ComputerSystem", "LXC_ComputerSystem">

=back

=over 4

Notice with DeepInheritence set to 1 (True) and additional CIM class name PG_ComputerSystem is included in the results, this is because the super class for PG_ComputerSystem is CIM_UnitaryComputerSystem and the super class for CIM_UnitaryComputerSystem is CIM_ComputerSystem

Here is the relivant portions of the raw XML from a GetClass against the two classes that illistrates it.

from the PG_ComputerSystem CIM Class

=back

=over 6

C<<< <CLASS NAME="PG_ComputerSystem"  SUPERCLASS="CIM_UnitaryComputerSystem" > >>>

=back

=over 4

=item From the CIM_UnitaryComputerSystem Class

C<<< <CLASS NAME="CIM_UnitaryComputerSystem"  SUPERCLASS="CIM_ComputerSystem" > >>>

=item The great thing about this is it works for standard CIM, SMI-S, WMI, WMWare, etc.. Any standard or API based on CIM is structured in this manner so the class name discovery process works the same way for all of them.

=item See DSP0200 Version 1.3.1 section 5.3.2.10 for details

=back

=head3 EnumerateInstances
    C<<< $query->EnumerateInstances('name/space','ClassName',{ 'LocalOnly' = 1, 'DeepInheritance' = 1, 'IncludeQualifiers' = 0, 'IncludeClassOrigin' = 0 }, ['property1','property2']);
    $query->EnumerateInstances('name/space','ClassName',{ }, ['property1','property2']);
    $query->EnumerateInstances('name/space','ClassName',{ 'LocalOnly' = 1, 'DeepInheritance' = 1, 'IncludeQualifiers' = 0, 'IncludeClassOrigin' = 0 });
    $query->EnumerateInstances('name/space','ClassName'); >>>

=over 4

=item The EnumerateInstances method returns the content of every instance of the CIM class specified in the ClassName and all of the sub classes that it inherits fields from within the namespace specified in the name/space field.

=item B<1) name/space>

The CIM namespace you want to enumerate the instances of the class from.

This field is requiered

=item B<2) ClassName>

The name of the CIM class you want to enumerate the instances of.

This field is required.

If you dont wish to specify a value but wish to specify a latter field next field you may leave it empty or sete it to 'NULL'

=item B<3) Query Modifiers>

An optional hash reference containing any combination of the following query modifiers.

If you wish to use the defaults for the modifiers and want to specify a latter field you may define the field as {}

=back

=over 6

B<3.1) LocalOnly>

=back

=over 8

If set to 1 (True) the behavior varies base on which version of the standard the WBEM server supports.

In versions prior to 1.1 of the standard this modifier to 1 (True) returns only the elements that differ from the defaults of the class or differ from the defaults of the parent classes for elements which are inherited from other classes.

In version 1.1 or higher of the standard setting this modifier to 1 (True) only returns the elements in each instance that are different from the defaults for class will be returned but not any elements inherited from a parent class unless their defaults in the class you are querieing differ from the parent class. Any elements of each instance that have been altered which were inherited from the parent class are not included in the results.

If set to 0 (False) all elements of each instance except those filterd out by other options will be returned.

WARNING: This modifier is deprecated in the standard for the EnumerateInstances method and will be removed from a future version of the standard. In the mean time the DMTF advises you to set it to 0 (False), furthermore some WBEM servers now ignore this modifier and act as though it set to 0 (False) regardles of what you set it to .

See DSP0200 Version 1.3.1 section ANNEX B "LocalOnly Parameter Discussion" for details

Defaults to 1 (True)

=back

=over 6

B<3.2) DeepInheritance>

=back

=over 8

If set to 1 (True) then all instances of the CIM class specified in the ClassName properties, and all of the instances of all class that the CIM class specified inherits fields from will be returned

If set to 0 (False) the only instances of the CIM class specified in the ClassName properties will be returned.

Defaults to 1 (True)

=back

=over 6

B<3.3) IncludeQualifiers>

=back

=over 8

If set to 1 (True) the qualifiers for each instance will be returned in the results.

If set to 0 (False) no qualifiers will be included in the results.

WARNING: This modifier is deprecated and will be removed in a future version of the standard. In the meen time the DMTF advises you to set it to 0 (False), in addition WBEM servers are nolonger requierd to honer it if you set it to 1 (True). The prefered menthod to get the qualifiers is to use the GetClass method instead.

Defaults to 0 (False)

=back

=over 6

B<3.4) IncludeClassOrigin>

=back

=over 8

If set to 1 (True) all of the elements which were inherited from a parent class will include an CLASSORIGIN element discribing which class it was inherited from.

If set to 0 (False) the no CLASSORIGIN tags will be included.

Defaults to 0 (False)

=back

=over 4

=item B<4) Property List>

An array reference containing a list of the specific elements of the instances you want to return, all other elements will not be included in the results. 

=item See DSP0200 Version 1.3.1 section 5.3.2.11 for details

=back

=head3 EnumerateInstanceNames
    C<<<$query-> EnumerateInstanceNames ('name/space','ClassName'); >>>

=over 4

=item B<1) name/space>

The CIM namespace you want to enumerate the instances name of the classes from

This field is requiered

=item B<2) ClassName>

The name of the CIM class you want to enumerate the intance names of.

This field is required.

=item See DSP0200 Version 1.3.1 section 5.3.2.12 for details

=back

=head3 ExecQuery

=over 4

=item Not implemented yet

=back

=head3 Associators
    C<<< $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0});
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole',{ }, ['property1','property2'] );
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','Role','ResultRole');
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass',);
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'NULL','NULL','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'','','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'AssocClass','ResultClass','','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2']);
    $query->Associators ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'NULL','ResultClass','NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] ); >>>

=over 4

=item The Associators operation enumerates CIM objects (classes or instances) associated with a particular source CIM class or instance. 


=item B<1) name/space>

The CIM namespace you want to enumerate the class instances from

This field is requiered

=item B<2) ClassName>

The name of the CIM class you want to enumerate the instances of

This field is required.

=item B<3) InstanceName>

A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specialy Formated Fields" section.

This field is optional and may be left blank

=item B<4) AssocClass>

The name of a class for which the resulting enumerated classes must be accociated to the original CIM class or instance of the CIM Class via the CIM class sepcified here or a sub class of the CIM class specified here.

This field is optional and may be left blank or explicitly specified as 'NULL'

=item B<5) ResultClass>

The name of a class for which the resulting enumerated classes must be an instance of the CIM class named here or one of its sub classes

This field is optional and may be left blank or explicitly specified as 'NULL'

=item B<6) Role>

The name of a property in the source CIM class that is the source of the association betwaen the source class or instance and the resulting enumerated instaces

This field is optional and may be left blank or explicitly specified as 'NULL'

=item B<7) Result Role>

The name of a property in the resulting CIM class instances that is the source of the association betwaen the source class or instance and the resulting enumerated instaces

This field is optional and may be left blank or explicitly specified as 'NULL'

=item B<8) Query Modifiers>

A hash reference containing any combination of the following query modifiers.

This field is optional and may be left blank

=item B<8.1) IncludeQualifiers>

If set to 1 (True) all of the elements which were inherited from a parent class will include an CLASSORIGIN element discribing which class it was inherited from.

If set to 0 (False) the no CLASSORIGIN tags will be included.

WARNING: This modifier is deprecated and will be removed in a future version of the standard. In the meen time the DMTF advises you to set it to 0 (False), in addition WBEM servers are nolonger requierd to honer it if you set it to 1 (True). The prefered menthod to get the qualifiers is to use the GetClass method instead.

Defailts to 0 (False)

=item B<8.2) IncludeClassOrigin>

If set to 1 (True) all of the elements which were inherited from a parent class will include an CLASSORIGIN element discribing which class it was inherited from.

If set to 0 (False) the no CLASSORIGIN tags will be included.

Defaults to 0 (False)

=item B<9) Property List>

An optional array reference containing a list of the specific properties of the enumerated instances you want to get

=item See DSP0200 Version 1.3.1 section 5.3.2.14 for details

=back

=head3 AssociatorNames
    C<<< $query->AssociatorNames('name/space','ClassName', {} , 'AssocClass', 'ResultClass', 'Role','ResultRole');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'NULL', 'NULL', 'NULL','NULL');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'AssocClass', 'NULL', 'Role','ResultRole');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'NULL', 'ResultClass', 'NULL','ResultRole');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, '', 'ResultClass', '','ResultRole');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'NULL', 'ResultClass');
    $query->AssociatorNames('name/space','ClassName', $InstanceName_reference_in_keybinding_format); >>>

=over 4

=item The AssociatorNames operation enumerates the names of CIM objects (classes or instances) associated with a particular source CIM class or instance. 

=item B<1) name/space>

The CIM namespace you want to enumerate the classes or instances from

This field is requiered

=item B<2) ClassName>

The name of the CIM class you want to enumerate the instances of

This field is required.

=item B<3) InstanceName>

A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specialy Formated Fields" section.

This field is optional and may be left blank

=item B<4) AssocClass>

The name of a class for which the resulting enumerated classes must be accociated to the original CIM class or instance of the CIM Class via the CIM class sepcified here or a sub class of the CIM class specified here.

This field is optional and may be left blank or explicitly specified as 'NULL'

=item B<5) ResultClass>

The name of a class for which the resulting enumerated classes must be an instance of the CIM class named here or one of its sub classes

This field is optional and may be left blank or explicitly specified as 'NULL'

=item B<6) Role>

The name of a property in the source CIM class that is the source of the association betwaen the source class or instance and the resulting enumerated instaces

This field is optional and may be left blank or explicitly specified as 'NULL'

=item B<7) Result Role>

The name of a property in the resulting CIM class instances that is the source of the association betwaen the source class or instance and the resulting enumerated instaces

This field is optional and may be left blank or explicitly specified as 'NULL'

=item See DSP0200 Version 1.3.1 section 5.3.2.15 for details

=back

=head3 References
    C<<< $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0});
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role',{ }, ['property1','property2'] );
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','Role');
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format);
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'NULL','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] );
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2']);
    $query->References ('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'ResultClass','NULL',{'IncludeQualifiers' => 0, 'IncludeClassOrigin' => 0}, ['property1','property2'] ); >>>

=over 4

=item References enumerates the instances or CIM classes that reference a a specifec CIM class or instance

=item B<1) name/space>

The CIM namespace you want to enumerate the classes or instances from

This field is requiered

=item B<2) ClassName>

The name of the CIM class that the classes you want to enumerate reference

This field is required.

=item B<3) InstanceName>

A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specialy Formated Fields" section.

This field is optional and may be left blank

=item B<4) ResultClass>

The name of a class for which the resulting enumerated classes must be an instance of the CIM class named here or one of its sub classes

This field is optional and may be left blank or explicitly specified as 'NULL'

=item B<5) Role>

The name of a property in the CIM class named in the ClassName field that is the source of the association betwean the source class or instance and the resulting enumerated instaces

This field is optional and may be left blank or explicitly specified as 'NULL'

=item B<6) Query Modifiers>

A hash reference containing any combination of the following query modifiers.

This field is optional and may be left blank

=back

=over 6

B<6.1) IncludeQualifiers>

=back

=over 8

If set to 1 (True) the qualifiers for each property in each instance will be returned in the results.

If set to 0 (False) no qualifiers will be included in the results.

WARNING: This modifier is deprecated and will be removed in a future version of the standard. In the meen time the DMTF advises you to set it to 0 (False), in addition WBEM servers are nolonger requierd to honer it if you set it to 1 (True). The prefered menthod to get the qualifiers is to use the GetClass method instead.

Defailts to 0 (False)

=back

=over 6

B<6.2) IncludeClassOrigin>

=back

=over 8

If set to 1 (True) all of the elements which were inherited from a parent class will include an CLASSORIGIN element discribing which class it was inherited from.

If set to 0 (False) the no CLASSORIGIN tags will be included.

Defaults to 0 (False)

=back

=over 4

=item B<7) Property List>

An optional array reference containing a list of the specific properties of the enumerated instances you want to get

=item See DSP0200 Version 1.3.1 section 5.3.2.16 for details

=back

=head3 ReferenceNames

=over 4

=item Not implemented yet

=back

=head3 GetProperty
    C<<< $query->GetProperty ( 'name/space','ClassName', $InstanceName_reference_in_keybinding_format, 'PropertyName'); >>>

=over 4

=item GetProperty returns only a specific property from an instance of a class

=item It requiers 4 paramiters

=item B<1) name/space>

A string containing the namespace that the instance of the class can be found in a common example is 'root/cimv2' or 'root/interop'

=item B<2) ClassName>

A string containing the name of the class you want to query

=item B<3) InstanceName>

A hash or array reference matching a valid keybinding format which describes the instance of the class you want to query. Please see the Keybinding field format described in the "Specialy Formated Fields" section.

=item B<4) PropertyName>

The name of the property you wisht to extrace.

=item See DSP0200 Version 1.3.1 section 5.3.2.18 for details

=back

=head3 SetProperty
    C<<< $query->SetProperty('name/space','ClassName',$InstanceName_reference_in_keybinding_format,'PropertyName','VALUE'); >>>

=over 4

=item See DSP0200 Version 1.3.1 section 5.3.2.19 for details

=back

=head3 GetQualifier

=over 4

=item Not implemented yet

=back

=head3 SetQualifier

=over 4

=item Not implemented yet

=back

=head3 DeleteQualifier

=over 4

=item Not implemented yet

=back

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Paul Robert Marino, E<lt>code@TheMarino.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul Robert Marino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut

package WebService::ReutersConnect::XMLDocument;
use Moose;
use XML::LibXML;
use Log::Log4perl;
my $LOGGER = Log::Log4perl->get_logger();

has 'xml_document' => ( is => 'ro', required => 1 , handles => qr/.*/, isa => 'XML::LibXML::Document' );
has 'reuters' => ( is => 'ro', required => 1 , weak_ref => 1 , isa => 'WebService::ReutersConnect' );

has 'xml_namespaces' => ( is => 'ro', lazy_build => 1, required => 1 );
has 'xml_xpath' => ( is => 'ro', lazy_build => 1 , required => 1 );

=head1 NAME

WebService::ReutersConnect::XMLDocument - A decoration of XML::LibXML::Document with extra gizmos

=head1 SYNOPSIS

This basically acts as an L<XML::LibXML::Document> execpts it has the following extra attributes:

=head2 xml_namespaces

Returns a Array Ref list of all L<XML::LibXML::Namespace> included in this document. This is mainly for internal use.

usage:

 foreach my $ns_node ( @{$this->xml_namespaces() ){
    ## Print some stuff.
 }

=head2 xml_xpath

A ready to serve instance of <XML::LibXML::XPathContext> with the namespaces preregistered.

NOTE: The default namespace is 'rcx' (rEUTERS cONNECT xML).

Usage:

  print( $this->xml_xpath->findvalue('//rcx::headline') );
  print( $this->xml_xpath->findvalue('//rcx::description') );

=cut

sub _build_xml_namespaces{
  my ($self) = @_;

  my %nss = ();

  ## Find default namespace.
  my ( $default_ns ) = $self->xml_document->findnodes('/*/namespace::*[name()=\'\']');
  $nss{''} = $default_ns;

  ## Find other namespace nodes.
  my @ns_nodes = $self->xml_document->findnodes('/*/namespace::*[name()!=\'\']');
  foreach my $ns_node ( @ns_nodes ){
    $nss{$ns_node->getLocalName()} //= $ns_node;
  }

  my @namespaces = values %nss;
  return \@namespaces;
}

sub _build_xml_xpath{
  my ($self) = @_;
  my $xc = XML::LibXML::XPathContext->new( $self->xml_document() );
  foreach my $ns_node ( @{$self->xml_namespaces()} ){
    my $localname = $ns_node->getLocalName() // 'rcx';
    $LOGGER->info("Registering namespace $localname:".$ns_node->declaredURI());
    $xc->registerNs( $localname , $ns_node->declaredURI() );
  }
  return $xc;
}

__PACKAGE__->meta->make_immutable();
1;

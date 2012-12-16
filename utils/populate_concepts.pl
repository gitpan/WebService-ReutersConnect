#! /usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Log::Log4perl qw/:easy/;
Log::Log4perl->easy_init($INFO);

use WebService::ReutersConnect;
use XML::LibXML;


sub usage{
  die "Usage: $0 <XML Concetps File>\n";
}

## binmode STDOUT , ':utf8';

## Read the XML file and fill up the DB.
my $xml_file = shift || usage();


my $reuters = WebService::ReutersConnect->new({ authToken => 'irrelevant',
                                                db_file => 'share/concepts.db'
                                              });

my $schema = $reuters->schema();

my $concepts = $schema->resultset('Concept');

my $xml_doc = XML::LibXML->load_xml( location => $xml_file );
my $xc = XML::LibXML::XPathContext->new( $xml_doc );

$xc->registerNs( 'default' , "http://iptc.org/std/nar/2006-10-01/");

my $n_concepts = 0;

my $stuff = sub{
  INFO "We have ".$concepts->count()." concepts in DB. Wiping them out\n";
  $concepts->delete();
  INFO( "Done. Now adding Concepts from XML file");

  my @concept_nodes = $xc->findnodes('//default:concept');
  foreach my $concept_node ( @concept_nodes ){
    $n_concepts++;
    ## print "Dealing with concept node $concept_node\n";

    my $create_args = {};

    my ( $id_node ) = $xc->findnodes('default:conceptId' , $concept_node);
    my $id = $id_node->getAttribute('qcode');
    DEBUG "ID: $id\n";

    $create_args->{id} = $id;

    ##<name role="nameRole:main" xml:lang="en">All</name>
    my $main_name = $xc->findvalue('default:name[@role=\'nameRole:main\']' , $concept_node);
    DEBUG "Main name : ".$main_name."\n";

    $create_args->{name_main} = $main_name;

    #<name role="nameRole:mnemonic" xml:lang="en">MINMTL</name>
    #<definition role="defRole:main" xml:lang="en">Uncommon and scarce metals such as arsenic, cadmium, cobalt, uranium.</definition>

    my $mnemonic = $xc->findvalue('default:name[@role=\'nameRole:mnemonic\']' , $concept_node);
    if( $mnemonic ){
      DEBUG "Mnemonic: $mnemonic\n";
    }
    $create_args->{name_mnemonic} = $mnemonic;

    my $definition = $xc->findvalue('default:definition[@role=\'defRole:main\']', $concept_node);
    if( $definition ){
      $create_args->{definition} = $definition;
      DEBUG "Definition: ".$definition."\n";
    }

    my $c_row = $concepts->create($create_args);

    my @alias_nodes = $xc->findnodes('default:sameAs' , $concept_node);
    foreach my $alias_node ( @alias_nodes ){
      my $alias_id = $alias_node->getAttribute('qcode');
      DEBUG "ALIAS: ".$alias_id."\n";
      if( my $already =  $schema->resultset('ConceptAlias')->find({ alias_id =>  $alias_id }) ){
        WARN("THis alias $alias_id IS already used for concept ".$already->concept_id()." SKIPPING");
      }else{
        $c_row->add_to_concept_aliases({ alias_id => $alias_id });
      }
    }
  }
};

$schema->txn_do($stuff);

INFO "$n_concepts Concepts added\n";

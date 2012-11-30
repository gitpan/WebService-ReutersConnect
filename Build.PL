use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WebService::ReutersConnect',
    license             => 'perl',
    dist_author         => q{Jerome Eteve <jerome@eteve.net>},
    dist_version_from   => 'lib/WebService/ReutersConnect.pm',
    build_requires => {
        'Test::More' => 0,
        'Test::Fatal' => 0.008,
        'LWP::UserAgent::Mockable' => 1.10,
    },
    requires => {
        'perl' => 5.006,

        'DateTime' => 0.70,
        'DateTime::Format::ISO8601' => 0.07,
        'HTTP::Request' => 6.00,
        'HTTP::Response' => 6.01,
        'Log::Log4perl' => 1.29,
        'LWP::UserAgent' => 6.03,
        'Moose' => 2.0401,
        'URI::Escape' => 3.31,
        'XML::LibXML' => 1.89,
    },
    add_to_cleanup      => [ 'WebService-ReutersConnect-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();

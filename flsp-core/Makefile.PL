use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    NAME             => "FindLocalShows-Core",
    VERSION          => "0.0.1",
    AUTHOR           => q{David <dgravesdev@gmail.com>},
    ABSTRACT         => "Background service for updating FindLocalShows database with new shows.",
    LICENSE          => "artistic_2",
    MIN_PERL_VERSION => "5.014",
    CONFIGURE_REQUIRES => {
        "ExtUtils::MakeMaker" => "0",
    },
    PREREQ_PM => {
        "Data::Dumper" => "0",
        "DBD::Pg" => "0",
        "DBI" => "0",
        "JSON::XS" => "0",
        "Log::Log4perl" => "0",
        "LWP::Protocol::https" => "0",
        "LWP::UserAgent" => "0",
        "URL::Encode" => "0",
    },
    dist  => { COMPRESS => "gzip -9f", SUFFIX => "gz", },
    clean => { FILES => "*.tar.gz" },
    test => { TESTS => "t/*.t" },
);

# Compatibility with old versions of ExtUtils::MakeMaker
unless (eval { ExtUtils::MakeMaker->VERSION("6.64"); 1 }) {
    my $test_requires = delete $WriteMakefileArgs{TEST_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$test_requires} = values %$test_requires;
}

unless (eval { ExtUtils::MakeMaker->VERSION("6.55_03"); 1 }) {
    my $build_requires = delete $WriteMakefileArgs{BUILD_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$build_requires} = values %$build_requires;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION("6.52"); 1 };
delete $WriteMakefileArgs{MIN_PERL_VERSION}
    unless eval { ExtUtils::MakeMaker->VERSION("6.48"); 1 };
delete $WriteMakefileArgs{LICENSE}
    unless eval { ExtUtils::MakeMaker->VERSION("6.31"); 1 };

WriteMakefile(%WriteMakefileArgs);

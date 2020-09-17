package FindLocalShows::Model::Regions;

use 5.032;
use strict;
use warnings;
use experimental qw(signatures);

use Mojo::Util qw(secure_compare);
use Data::Dumper;

sub new ( $class, $dbh ) {
    my $hash = { dbh => $dbh };
    return bless $hash, $class;
}

sub get_supported_regions ($self) {
    my $rows = $self->{dbh}->selectall_arrayref(
        "SELECT region FROM supported_regions ORDER BY id ASC"
    );
    my @regions;
    for my $r (@$rows) {
        push @regions, $$r[0];
    }
    return @regions;
}

1;

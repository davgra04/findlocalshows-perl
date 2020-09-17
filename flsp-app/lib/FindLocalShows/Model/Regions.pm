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

sub get_default_region ($self) {
    my $row = $self->{dbh}->selectrow_arrayref(
        "SELECT region FROM users INNER JOIN supported_regions ON users.default_region = supported_regions.id  LIMIT 1"
    );
    return $$row[0];
}

sub set_default_region ($self, $region) {
    my $ins_stmt = $self->{dbh}->prepare(
        "UPDATE users SET default_region = (SELECT id FROM supported_regions WHERE region = ?)"
    );
    $ins_stmt->execute( $region );
}

1;

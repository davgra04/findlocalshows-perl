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

__END__

=head1 NAME

FindLocalShows::Model::Regions - Model object for regions

=head1 DESCRIPTION

This model handles reading and writing region data.

=head2 Methods

=over 12

=item C<new>

Creates a new regions model object.

=item C<get_supported_regions>

Returns a list of regions supported by the app.

=item C<get_default_region>

Returns the default region.

=item C<set_default_region>

Sets the default region.

=back

=head1 LICENSE

This is released under the Artistic License 2.0. See L<perlartistic>.

=head1 AUTHOR

davgra04 - L<https://github.com/davgra04>

=cut

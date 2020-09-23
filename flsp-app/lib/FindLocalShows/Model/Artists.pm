package FindLocalShows::Model::Artists;

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

sub add_artist ( $self, $artist ) {

    # check if entry already exists
    my $sel_stmt = $self->{dbh}->prepare(
        "SELECT id FROM followed_artists WHERE name = ?"
    );
    $sel_stmt->execute($artist);
    my @row = $sel_stmt->fetchrow_array();

    if (@row) {

        # undelete if present
        my $upd_stmt = $self->{dbh}->prepare(
            "UPDATE followed_artists SET deleted = FALSE WHERE id = ?"
        );
        $upd_stmt->execute( $row[0] );
    }
    else {
        # insert new if not present
        my $ins_stmt = $self->{dbh}->prepare(
            "INSERT INTO followed_artists (name, first_query_complete, deleted) VALUES (?, ?, ?)"
        );
        $ins_stmt->execute( $artist, 0, 0 );
    }
}

sub get_artists ($self) {
    my $rows = $self->{dbh}->selectall_arrayref(
        "SELECT id, name FROM followed_artists WHERE deleted IS NOT TRUE ORDER BY name ASC"
    );
    my @artists;
    for my $r (@$rows) {
        push @artists, { id => $$r[0], name => $$r[1] };
    }
    return @artists;
}

sub get_count ($self) {
    my $row = $self->{dbh}->selectrow_arrayref(
        "SELECT COUNT(*) FROM followed_artists WHERE deleted IS NOT TRUE");
    return $row->[0];
}

sub get_artist_info ($self, $artist_id) {
    my $sel_artist = $self->{dbh}->prepare(
        "SELECT id, name, bit_id, url, image_url, thumb_url, facebook_page_url, mbid, updated FROM artists WHERE bit_id = ?"
    );
    $sel_artist->execute($artist_id);
    my $row = $sel_artist->fetchrow_arrayref;
    return undef unless defined($row);

    my ($id, $name, $bit_id, $url, $image_url, $thumb_url, $facebook_page_url, $mbid, $updated) = @$row;
    return {
        id => $id,
        name => $name,
        bit_id => $bit_id,
        url => $url,
        image_url => $image_url,
        thumb_url => $thumb_url,
        facebook_page_url => $facebook_page_url,
        mbid => $mbid,
        updated => $updated,
    };
}

sub remove_artist ( $self, $id ) {

    # check if entry exists
    my $sel_stmt = $self->{dbh}->prepare("SELECT name FROM followed_artists WHERE id = ?");
    $sel_stmt->execute($id);
    my $row = $sel_stmt->fetchrow_arrayref();

    if ($row) {

        # delete
        my $upd_stmt = $self->{dbh}->prepare(
            "UPDATE followed_artists SET deleted = TRUE WHERE id = ?"
        );
        $upd_stmt->execute($id);
        return $row->[0];
    }

    return undef;
}

1;

__END__

=head1 NAME

FindLocalShows::Model::Artists - Model object for artists

=head1 DESCRIPTION

This model handles reading and writing artist data.

=head2 Methods

=over 12

=item C<new>

Creates a new artists model object.

=item C<add_artist>

Adds an artist to the followed artists table

=item C<get_artists>

Returns a list of followed artists.

=item C<get_count>

Returns a count of followed artists.

=item C<get_artist_info>

Returns saved bandsintown artist data for an artist.

=item C<remove_artist>

Deletes an artist from the followed artists table.

=back

=head1 LICENSE

This is released under the Artistic License 2.0. See L<perlartistic>.

=head1 AUTHOR

davgra04 - L<https://github.com/davgra04>

=cut

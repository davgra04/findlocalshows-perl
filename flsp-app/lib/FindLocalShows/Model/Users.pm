package FindLocalShows::Model::Users;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::Util qw(secure_compare);
use Data::Dumper;

sub new ( $class, $dbh ) {
    my $hash = { dbh => $dbh };
    return bless $hash, $class;
}

sub add_user ( $self, $user, $encrypted_pass ) {
    # insert into DB
    my $ins_stmt = $self->{dbh}->prepare("INSERT INTO users (username, password, default_region) VALUES (?, ?, ?)");
    $ins_stmt->execute( $user, $encrypted_pass, 44 );
}

sub get_password_from_db ( $self, $user ) {
    my $sel_stmt = $self->{dbh}->prepare("SELECT password FROM users WHERE username = ?");
    $sel_stmt->execute($user);
    my ($encrypted_pass) = $sel_stmt->fetchrow();
    return $encrypted_pass;
}

# has_admin_user returns true if FindLocalShows has already been initialized with
# a user and a password. Returns false otherwise.
sub has_admin_user ($self) {
    my @row = $self->{dbh}->selectrow_array("SELECT COUNT(*) FROM users");
    return 1 if $row[0];
    return undef;
}

1;


__END__

=head1 NAME

FindLocalShows::Model::Users - Model object for users

=head1 DESCRIPTION

This model handles reading and writing user data.

=head2 Methods

=over 12

=item C<new>

Creates a new users model object.

=item C<add_user>

Adds a user given a username and password.

=item C<get_password_from_db>

Returns hashed password from database for main user.

=item C<has_admin_user>

Returns 1 if FindLocalShows has been initialized with a user and password, returns
undef otherwise.

=back

=head1 LICENSE

This is released under the Artistic License 2.0. See L<perlartistic>.

=head1 AUTHOR

davgra04 - L<https://github.com/davgra04>

=cut

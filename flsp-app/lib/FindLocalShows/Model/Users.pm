package FindLocalShows::Model::Users;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::Util qw(secure_compare);
use Data::Dumper;


sub new($class, $dbh) {
    my $hash = {dbh => $dbh};
    return bless $hash, $class;
}


sub add_user ($self, $user, $encrypted_pass) {
    # insert into DB
    my $ins_stmt = $self->{dbh}->prepare("INSERT INTO users (username, password) VALUES (?, ?)");
    $ins_stmt->execute($user, $encrypted_pass);
}


sub get_password_from_db ($self, $user) {
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

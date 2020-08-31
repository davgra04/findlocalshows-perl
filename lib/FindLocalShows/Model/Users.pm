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


sub add_user ($self, $user, $pass) {
	my $ins_stmt = $self->{dbh}->prepare("INSERT INTO users (username, password) VALUES (?, ?)");
	$ins_stmt->execute($user, $pass);
}


sub check_password ($self, $user, $pass) {

	my $sel_stmt = $self->{dbh}->prepare("SELECT password FROM users WHERE username = ?");
	$sel_stmt->execute($user);

	my ($saved_pass) = $sel_stmt->fetchrow();
	# my @row = $sel_stmt->selectrow_array;
	print "IN check_password RIGHT NOW";
	print "\$saved_pass: " . Dumper($saved_pass);

	# Success
	return 1 if $saved_pass && secure_compare $saved_pass, $pass;

	# Fail
	return undef;
}

# has_admin_user returns true if FindLocalShows has already been initialized with
# a user and a password. Returns false otherwise.
sub has_admin_user ($self) {
	my @row = $self->{dbh}->selectrow_array("SELECT COUNT(*) FROM users");
	# print Dumper(@row);

	if ( $row[0] ) {
		return 1;
	}
	return undef;
}

1;

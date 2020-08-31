package FindLocalShows::Model::Shows;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::Util qw(secure_compare);

my @SHOWLIST = (
    {date => "2020/09/20 19:00:00", artist => "Tame Impala", venue => "White Oak Music Hall", location => "Houston, TX"},
    {date => "2020/09/20 19:00:00", artist => "Unknown Mortal Orchestra", venue => "White Oak Music Hall", location => "Houston, TX"},
    {date => "2020/09/20 19:00:00", artist => "King Gizzard and the Lizard Wizard", venue => "White Oak Music Hall", location => "Houston, TX"},
    {date => "2020/09/20 19:00:00", artist => "LCD Soundsystem", venue => "White Oak Music Hall", location => "Houston, TX"},
    {date => "2020/09/20 19:00:00", artist => "Mildlife", venue => "White Oak Music Hall", location => "Houston, TX"},
);

sub new($class, $dbh) {
	my $hash = {dbh => $dbh};
	return bless $hash, $class;
}

sub get_upcoming_shows ($self) {
	return \@SHOWLIST;
}

1;

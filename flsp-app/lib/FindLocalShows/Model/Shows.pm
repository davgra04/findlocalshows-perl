package FindLocalShows::Model::Shows;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::Util qw(secure_compare);
use Data::Dumper;

my $SHOWINFO = {
    num_shows => 5,
    num_artists => 5,
    shows => [
        {date => { month => "Sep", day => 14, dow => "Fri" }, artist => "Tame Impala", venue => "White Oak Music Hall", location => "Houston, TX"},
        {date => { month => "Sep", day => 14, dow => "Fri" }, artist => "Unknown Mortal Orchestra", venue => "A Cool Club", location => "Austin, TX"},
        {date => { month => "Sep", day => 14, dow => "Fri" }, artist => "King Gizzard and the Lizard Wizard", venue => "An Intimate Venue", location => "San Antonio, TX"},
        {date => { month => "Sep", day => 14, dow => "Fri" }, artist => "LCD Soundsystem", venue => "Some Festival", location => "El Paso, TX"},
        {date => { month => "Sep", day => 14, dow => "Fri" }, artist => "Mildlife", venue => "Toyota Center", location => "Houston, TX"},
    ]
};

# my $SHOWINFO = {
#     num_shows => 5,
#     num_artists => 5,
#     shows => [
#         {artist => "Tame Impala"},
#         {artist => "LCD Soundsystem"},
#         {artist => "The Beatles"},
#     ]
# };


(
);

sub new($class, $dbh) {
	my $hash = {dbh => $dbh};
	return bless $hash, $class;
}

sub get_upcoming_shows ($self, $region) {
    print Dumper($SHOWINFO);
	return $SHOWINFO;
}

1;

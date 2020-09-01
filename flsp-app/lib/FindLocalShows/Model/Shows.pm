package FindLocalShows::Model::Shows;

use strict;
use warnings;
use experimental qw(signatures);
use feature qw(say);

use Mojo::Util qw(secure_compare);
use Data::Dumper;
use JSON::XS;
use DateTime;
use DateTime::Format::Strptime;

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


sub new($class, $dbh) {

	my $hash = {
        dbh => $dbh, 
        strp => DateTime::Format::Strptime->new(
            pattern => "%Y-%m-%dT%H:%M:%S",
            locale => "en_US",
            time_zone => "America/Chicago",
        )
    };
	return bless $hash, $class;
}

sub get_upcoming_shows ($self, $region) {
    # print Dumper($SHOWINFO);

    my $showinfo = { shows => [] };

    # obtain artist names
    my $artist_names_array = $self->{dbh}->selectall_arrayref("SELECT bit_id, name FROM artists");
    my %artist_names;
    for my $row ( @$artist_names_array ) {
        $artist_names{$row->[0]} = $row->[1];
    }


    # obtain artist ids
    my $artist_ids_array = $self->{dbh}->selectcol_arrayref("SELECT artist_id FROM followed_artists WHERE deleted IS FALSE AND first_query_complete IS TRUE");
    my %artist_ids;
    map { $artist_ids{$_} = 0 } @$artist_ids_array;

    # obtain list of all upcoming shows
    my $dt_now = DateTime->now;
    my $dt_now_str = $dt_now->strftime("%Y-%m-%dT%H:%M:%S");

    my $sel_shows = $self->{dbh}->prepare("SELECT artist_id, datetime, venue, region, city FROM events WHERE datetime > ? AND region = ? AND country = ? ORDER BY datetime ASC");
    my $rv = $sel_shows->execute($dt_now_str, $region, "United States");

    my @shows;
    while ( my @row = $sel_shows->fetchrow() ) {
        my ($id, $datetime, $venue_json, $show_region, $city) = @row;

        if ( exists $artist_ids{$id} ) {
            $artist_ids{$id}++;

            my $venue = decode_json $venue_json;
            my $name = $artist_names{$id};
            my $show_dt = $self->{strp}->parse_datetime($datetime);

            push(@shows, {
                date => { 
                    year => $show_dt->strftime("%Y"),
                    month => $show_dt->strftime("%b"),
                    day => $show_dt->strftime("%d"), 
                    dow => $show_dt->strftime("%a"), 
                },
                artist => $name,
                venue => $venue->{name},
                location => "$city, $show_region",
            });

        }
    }

    $showinfo->{shows} = \@shows;

    # get artist count
    my $artist_count = 0;
    for my $a ( keys %artist_ids ) {
        if ( $artist_ids{$a} ) {
            $artist_count++;
        }
    }
    $showinfo->{num_artists} = $artist_count;

    # get show count
    $showinfo->{num_shows} = scalar @shows;

    # say("shows: ".Dumper(@shows));
    # say("showinfo: ".Dumper($showinfo));
    # say("artist_ids: ".Dumper(%artist_ids));

	# return $SHOWINFO;
    return $showinfo;
}

1;

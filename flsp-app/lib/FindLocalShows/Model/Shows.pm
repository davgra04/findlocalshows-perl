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

sub new ( $class, $dbh ) {

    my $hash = {
        dbh  => $dbh,
        strp => DateTime::Format::Strptime->new(
            pattern   => "%Y-%m-%dT%H:%M:%S",
            locale    => "en_US",
            time_zone => "America/Chicago",
        )
    };
    return bless $hash, $class;
}

sub get_upcoming_shows ( $self, $region ) {

    my $showinfo = { shows => [] };

    # obtain artist names
    my $artist_names_array = $self->{dbh}->selectall_arrayref("SELECT bit_id, name FROM artists");
    my %artist_names;
    for my $row (@$artist_names_array) {
        $artist_names{ $row->[0] } = $row->[1];
    }

    # obtain artist ids
    my $artist_ids_array = $self->{dbh}->selectcol_arrayref(
        "SELECT artist_id FROM followed_artists WHERE deleted IS FALSE AND first_query_complete IS TRUE"
    );
    my %artist_ids;
    map { $artist_ids{$_} = 0 } @$artist_ids_array;

    # obtain list of all upcoming shows
    my $dt_now     = DateTime->now;
    my $dt_now_str = $dt_now->strftime("%Y-%m-%dT%H:%M:%S");

    my $sel_shows = $self->{dbh}->prepare(
        "SELECT artist_id, datetime, venue, region, city FROM events WHERE datetime > ? AND region = ? AND country = ? ORDER BY datetime ASC"
    );
    my $rv = $sel_shows->execute( $dt_now_str, $region, "United States" );

    my @shows;
    while ( my @row = $sel_shows->fetchrow() ) {
        my ( $id, $datetime, $venue_json, $show_region, $city ) = @row;

        if ( exists $artist_ids{$id} ) {
            $artist_ids{$id}++;

            my $venue   = decode_json $venue_json;
            my $name    = $artist_names{$id};
            my $show_dt = $self->{strp}->parse_datetime($datetime);

            push(
                @shows,
                {
                    date => {
                        year  => $show_dt->strftime("%Y"),
                        month => $show_dt->strftime("%b"),
                        day   => $show_dt->strftime("%d"),
                        dow   => $show_dt->strftime("%a"),
                    },
                    artist   => $name,
                    venue    => $venue->{name},
                    location => "$city, $show_region",
                }
            );

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

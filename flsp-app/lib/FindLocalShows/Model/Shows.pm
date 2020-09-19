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
        "SELECT artist_id, event_id, datetime, venue, region, city FROM events WHERE datetime > ? AND region = ? AND country = ? ORDER BY datetime ASC"
    );
    my $rv = $sel_shows->execute( $dt_now_str, $region, "United States" );

    my @shows;
    while ( my @row = $sel_shows->fetchrow() ) {
        my ( $id, $event_id, $datetime, $venue_json, $show_region, $city ) = @row;

        if ( exists $artist_ids{$id} ) {
            $artist_ids{$id}++;

            my $venue   = decode_json $venue_json;
            my $name    = $artist_names{$id};
            my $show_dt = $self->{strp}->parse_datetime($datetime);
            my $location = "$city, $show_region";
            $location = "Virtual" if ( $show_region eq "Virtual" );

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
                    location => $location,
                    event_id => $event_id
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

    return $showinfo;
}

sub get_show_info( $self, $event_id ) {

    my $sel_event = $self->{dbh}->prepare(
        "SELECT id, artist_id, url, on_sale_datetime, datetime, description, title, venue, virtual, country, region, city, lineup, added FROM events WHERE event_id = ?"
    );
    $sel_event->execute( $event_id );
    my $row = $sel_event->fetchrow_arrayref;
    return undef unless defined($row);

    my ($id, $artist_id, $url, $on_sale_datetime, $datetime, $description, $title, $venue_json, $virtual, $country, $region, $city, $lineup_json, $added) = @$row;

    my $venue   = decode_json $venue_json;

    $lineup_json =~ s/{/[/g;
    $lineup_json =~ s/}/]/g;
    my $lineup   = decode_json $lineup_json;

    my $show_dt = $self->{strp}->parse_datetime($datetime);
    my $fmt_datetime = $show_dt->strftime("%A %B %d, %Y");

    return {
        id => $id,
        artist_id => $artist_id,
        url => $url,
        on_sale_datetime => $on_sale_datetime,
        datetime => $datetime,
        fmt_datetime => $fmt_datetime,
        description => $description,
        title => $title,
        venue => $venue,
        virtual => $virtual,
        country => $country,
        region => $region,
        city => $city,
        lineup => $lineup,
        added => $added,
    };
}

1;

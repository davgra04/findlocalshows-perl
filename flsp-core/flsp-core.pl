#!/usr/bin/env perl

use 5.032;
use warnings;
use autodie;
use feature qw(signatures);

use Data::Dumper;
use DBI;
use JSON::XS;
use Log::Log4perl qw(:easy);
use LWP::UserAgent;
use URL::Encode qw(url_encode_utf8);

Log::Log4perl->easy_init($DEBUG);
my ($bit_api_key, $ua);

################################################################################
# bandsintown query functions
################################################################################

sub query_bandsintown_artist($artist) {
    my $url_encoded_artist = url_encode_utf8($artist);
    my $url = "https://rest.bandsintown.com/artists/$url_encoded_artist?app_id=$bit_api_key";

    my $req = HTTP::Request->new(GET => $url);
    $req->content_type("application/json");

    my $res = $ua->request($req);
    if ( $res->is_success ) {
        # INFO("    artist request succeeded");
        my $json = $res->content;
        my $artist_info = decode_json($json);
        return $artist_info;
    }

    ERROR("    artist request not successful");
    ERROR(Dumper($res));
    return undef;
}

sub query_bandsintown_shows($artist) {
    my $url_encoded_artist = url_encode_utf8($artist);
    my $url = "https://rest.bandsintown.com/artists/$url_encoded_artist/events?app_id=$bit_api_key";

    my $req = HTTP::Request->new(GET => $url);
    $req->content_type("application/json");

    my $res = $ua->request($req);
    if ( $res->is_success ) {
        # INFO("    shows request succeeded");
        my $json = $res->content;
        my $shows_info = decode_json($json);
        return $shows_info;
    }

    ERROR("    shows request not successful");
    ERROR(Dumper($res));
    return undef;
}


################################################################################
# flsp-db update functions
################################################################################

sub update_artist($dbh, $id, $artist, $artist_info) {
        ### start transaction
        $dbh->begin_work;
        my $rv;

        ### insert artist details
        my $ins_stmt = $dbh->prepare("INSERT INTO artists (name, bit_id, url, image_url, thumb_url, facebook_page_url, mbid, updated) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())");
        $rv = $ins_stmt->execute(
            $artist_info->{name},
            $artist_info->{id},
            $artist_info->{url},
            $artist_info->{image_url},
            $artist_info->{thumb_url},
            $artist_info->{facebook_page_url},
            $artist_info->{mbid},
        );
        unless ( $rv ) {
            ERROR("problem inserting artist details: " . $ins_stmt->errstr);
            $dbh->rollback;
            next
        }

        ### get id of inserted row
        my ($artists_table_id) = $dbh->last_insert_id(undef, undef, "artists", undef);

        ### mark artist as initialized
		my $upd_stmt = $dbh->prepare("UPDATE followed_artists SET first_query_complete = TRUE, artist_id = ? WHERE id = ?");
		$rv = $upd_stmt->execute($artist_info->{id}, $id);
        unless ( $rv ) {
            ERROR("problem marking artist as initialized: " . $upd_stmt->errstr);
            $dbh->rollback;
            next
        }

        ### finalize transaction
        $dbh->commit;
}


sub update_showlist($dbh, $shows) {

    # get ids of existing events
    my $event_ids_array = $dbh->selectcol_arrayref("SELECT event_id FROM events");
    my %event_ids;
    map { $event_ids{$_}++ } @$event_ids_array;
    # INFO("#"x80);
    # INFO("event_ids: ". Dumper(%event_ids));
    # INFO("event_ids_array: @$event_ids_array");
    # INFO("#"x80);

    my $shows_added = 0;

    # check shows array for new shows
    for my $show ( @$shows ) {

        next if $event_ids{$show->{id}};

        my $ins_stmt = $dbh->prepare("INSERT INTO events (artist_id, event_id, url, on_sale_datetime, datetime, description, title, venue, country, region, city, lineup, added) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW() )");
        my $rv = $ins_stmt->execute(
            $show->{artist_id},
            $show->{id},
            $show->{url},
            $show->{on_sale_datetime},
            $show->{datetime},
            $show->{description},
            $show->{title},
            encode_json($show->{venue}),
            $show->{venue}->{country},
            $show->{venue}->{region},
            $show->{venue}->{city},
            $show->{lineup},
        );

        $shows_added++;

    }

    return $shows_added;
}

################################################################################
# flsp-core check functions
################################################################################

sub check_new_artists($dbh) {
    INFO("Checking for new artists");
    my $rows = $dbh->selectall_arrayref("SELECT id, name FROM followed_artists WHERE first_query_complete IS FALSE AND deleted IS FALSE");

    for my $r ( @$rows ) {
        my ($id, $artist) = @$r;
        INFO("  added new artist $artist");

        # query bands in town
        my $artist_info = query_bandsintown_artist($artist);
        # INFO(Dumper($artist_info));
        next unless $artist_info;   # next if no data

        # update flsp database
        update_artist($dbh, $id, $artist, $artist_info);

        # check for shows
        my $shows = query_bandsintown_shows($artist);
        # INFO(Dumper($shows));

        # update shows
        my $shows_added = update_showlist($dbh, $shows);
        INFO("    added $shows_added new shows for $artist") if $shows_added;
    }

}


sub query_all_artists($dbh) {
    INFO("Querying all artists for new shows");
    my $rows = $dbh->selectall_arrayref("SELECT artist_id FROM followed_artists WHERE first_query_complete IS TRUE AND deleted IS FALSE");

    # INFO("#"x80);
    # INFO(Dumper($rows));
    # INFO("#"x80);


    for my $r ( @$rows ) {
        my ($id) = @$r;

        # get artist name
        my $sel_stmt = $dbh->prepare("SELECT name FROM artists WHERE bit_id = ?");
        $sel_stmt->execute($id);
        my @name_row = $sel_stmt->fetchrow_array();
        unless ( @name_row ) {
            ERROR("Could not find name for artist_id $id in artists table");
            next;
        }
        my $artist = $name_row[0];

        # query shows
        my $shows = query_bandsintown_shows($artist);
        # INFO(Dumper($shows));

        # update shows
        my $shows_added = update_showlist($dbh, $shows);
        INFO("  added $shows_added new shows for $artist") if $shows_added;
    }
}

################################################################################
# pull configuration from ENV
################################################################################

my $dbhost = $ENV{"FLSDB_HOST"} || "localhost";
my $query_all_period = $ENV{"QUERY_ALL_PERIOD"} || 3600;
my $query_new_artist_period = $ENV{"QUERY_NEW_ARTIST_PERIOD"} || 60;
$bit_api_key = $ENV{"BANDSINTOWN_API_KEY"} || die "Must define BANDSINTOWN_API_KEY env var!";

################################################################################
# prepare user agent for HTTP requests
################################################################################

$ua = LWP::UserAgent->new;

################################################################################
# connect to db
################################################################################

my $dbh;

INFO("connecting to database on host $dbhost");

for (my $i=0; $i<5; $i++) {
    $dbh = DBI->connect("dbi:Pg:dbname=flsdb;host=$dbhost;port=5432",
        "fls",
        "fls",
        {AutoCommit => 1, RaiseError => 0}
        );
    last if $dbh;
    sleep 5;
    INFO("  retrying...");
}
die $DBI::errstr unless $dbh;
INFO("database connection acquired");

################################################################################
# main loop
################################################################################

my $ts_last_full_query = 0;
my $ts_last_new_artist_check = 0;

while (1) {

    # check for new artists to query
    if ( time - $ts_last_new_artist_check > $query_new_artist_period ) {
        $ts_last_new_artist_check = time;
        check_new_artists($dbh);
    }

    # check if need to do full query
    if ( time - $ts_last_full_query > $query_all_period ) {
        $ts_last_full_query = time;
        query_all_artists($dbh);
    }

    # sleep
    sleep(3);

}

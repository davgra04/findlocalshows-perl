package FindLocalShows;
use Mojo::Base "Mojolicious", -signatures;
use Mojolicious::Plugin::Bcrypt;

use FindLocalShows::Model::Artists;
use FindLocalShows::Model::Regions;
use FindLocalShows::Model::Shows;
use FindLocalShows::Model::Users;

use DBI;
use Data::Dumper

our $VERSION = '0.0.1';

# connect_to_database connects to the database and returns the database handle.
# Will die if there is an error connecting.
sub connect_to_database ( $self ) {

    my $dbh;
    my $dbhost = $ENV{"FLSDB_HOST"} // "localhost";
    $self->app->log->debug("connecting to database on host $dbhost");

    for ( my $i = 0 ; $i < 5 ; $i++ ) {
        $dbh = DBI->connect(
            "dbi:Pg:dbname=flsdb;host=$dbhost;port=5432",
            "fls",
            "fls",
            { AutoCommit => 1, RaiseError => 0 }
        );
        last if $dbh;
        sleep 5;
        $self->app->log->debug("  retrying...");
    }

    die $DBI::errstr unless $dbh;
    $self->app->log->debug("database connection acquired");
    return $dbh;

}

# get_secret will try to obtain the application secret from the database, then
# from the environment configuration, and die if niether provide it
sub get_secret ( $self, $dbh ) {

    # try to obtain secret from database
    my $row = $dbh->selectrow_arrayref("SELECT secret FROM settings ORDER BY id ASC LIMIT 1");
    die $dbh->errstr if ( defined $dbh->errstr );   # encountered database error
    if ( defined $row ) {
        $self->app->log->debug("using flsp-app secret from database");
        return $row->[0];
    }

    # try to obtain secret from environment
    $self->app->log->debug("using flsp-app secret from environment");
    my $secret = $ENV{"FLSAPP_SECRET"};
    # $self->app->log->debug("Here's \%ENV: ".Dumper(%ENV));

    die "Must provide FLSAPP_SECRET environment variable!"
      unless defined($secret);

    # add secret to database
    my $sth = $dbh->prepare("INSERT INTO settings (secret) VALUES (?)");
    my $rv = $sth->execute($secret) or die $sth->errstr;
    return $secret;

}

sub startup ($self) {

    # load dbh from test configuration
    my $test_config = $self->plugin("Config", {default => {}});
    my $dbh = $test_config->{dbh};

    # connect to db
    if ( defined($dbh) ) {
        $self->app->log->debug("using testing database");
    } else {
        $dbh = $self->connect_to_database() unless( defined($dbh) );
    }

    # set secret
    my $secret = $self->get_secret($dbh);
    $self->secrets( [$secret] );

    # initialize bcrypt plugin
    $self->plugin( "bcrypt", { cost => 8 } );

    # prepare helpers
    $self->helper(
        users => sub { state $users = FindLocalShows::Model::Users->new($dbh) },
    );
    $self->helper(
        shows => sub { state $shows = FindLocalShows::Model::Shows->new($dbh) },
    );
    $self->helper(
        regions => sub { state $regions = FindLocalShows::Model::Regions->new($dbh) },
    );
    $self->helper(
        artists => sub { state $artists = FindLocalShows::Model::Artists->new($dbh) },
    );

    # set up middlewares
    my $r = $self->routes;

    # middleware to check if fls is initialized
    my $is_initialized = $r->under("/")->to("init#is_initialized");

    # middleware to check if logged in, redirect if not
    my $logged_in = $is_initialized->under("/")->to("login#logged_in");

    # middleware to check if logged in, set value in stash
    my $logged_in_nb = $is_initialized->under("/")->to("login#logged_in_nonblock");

    # set up routes
    $r->any("/init")->to("init#init_fls")->name("init");
    $logged_in_nb->any("/")->to("show_list#show_list")->name("show_list");
    $logged_in_nb->any("/event/:event_id")->to("event_page#event_page")->name("event_page");
    $is_initialized->any("/login")->to("login#login")->name("login");
    $is_initialized->get("/logout")->to("login#logout");
    $logged_in->any("/settings")->to("settings#settings");

}

1;

__END__

=head1 NAME

FindLocalShows - The FindLocalShows Mojolicious web app

=head1 SYNOPSIS

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use Mojo::File qw(curfile);
    use lib curfile->dirname->sibling("lib")->to_string;
    use Mojolicious::Commands;

    # start command line interface for application
    Mojolicious::Commands->start_app("FindLocalShows");

=head1 DESCRIPTION

This web application lets you specify a list of bands and artists to follow, and
queries the bandsintown.com API to provide a list of upcoming shows by state.

=head2 Methods

=over 12

=item C<connect_to_database>

Connects to the database and returns the database handle. Will die if there is 
an error connecting.

=item C<get_secret>

Will try to obtain the application secret from the database, then from the 
environment configuration, and die if niether provide it.

=item C<startup>

Main Mojolicious startup subroutine. Configures app, sets plugins, helpers, and
routes. 

=back

=head1 LICENSE

This is released under the Artistic License 2.0. See L<perlartistic>.

=head1 AUTHOR

davgra04 - L<https://github.com/davgra04>

=cut

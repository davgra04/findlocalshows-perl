package FindLocalShows;
use Mojo::Base "Mojolicious", -signatures;
use Mojolicious::Plugin::Bcrypt;

use FindLocalShows::Model::Artists;
use FindLocalShows::Model::Shows;
use FindLocalShows::Model::Users;
use DBI;

our $VERSION = '0.0.1';

sub startup ($self) {

	# set secret
	$self->secrets(["bada bing bada boom"]);

	# initialize bcrypt plugin
	$self->plugin("bcrypt", { cost => 8 });

	# connect to db
	my $dbh;
	my $dbhost = $ENV{"FLSDB_HOST"} || "localhost";

	$self->app->log->debug("connecting to database on host $dbhost");

	for (my $i=0; $i<5; $i++) {
		$dbh = DBI->connect("dbi:Pg:dbname=flsdb;host=$dbhost;port=5432",
			"fls",
			"fls",
			{AutoCommit => 1, RaiseError => 0}
			);
		last if $dbh;
		sleep 5;
		$self->app->log->debug("  retrying...");
	}
	die $DBI::errstr unless $dbh;
	$self->app->log->debug("database connection acquired");

	# prepare helpers
	$self->helper(db => sub { $dbh });
	$self->helper(users => sub { state $users = FindLocalShows::Model::Users->new($dbh) });
	$self->helper(shows => sub { state $shows = FindLocalShows::Model::Shows->new($dbh) });
	$self->helper(artists => sub { state $artists = FindLocalShows::Model::Artists->new($dbh) });

	# set up routes
	my $r = $self->routes;


	# middleware to check if fls is initialized
	my $is_initialized = $r->under("/")->to("init#is_initialized");
	# middleware to check if logged in, redirect if not
	my $logged_in = $is_initialized->under("/")->to("login#logged_in");
	# middleware to check if logged in, set value in stash
	my $logged_in_nb = $is_initialized->under("/")->to("login#logged_in_nonblock");

	$r->any("/init")->to("init#init_fls")->name("init");
	$logged_in_nb->any("/")->to("show_list#index")->name("index");
	$is_initialized->any("/login")->to("login#login")->name("login");
	$is_initialized->get("/logout")->to("login#logout");
	$logged_in->any("/settings")->to("settings#settings");

}

1;

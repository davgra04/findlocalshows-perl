package FindLocalShows;
use Mojo::Base "Mojolicious", -signatures;

use FindLocalShows::Model::Shows;
use FindLocalShows::Model::Users;
use DBI;

sub startup ($self) {

	# set secret
	$self->secrets(["bada bing bada boom"]);

	# connect to db
	$self->app->log->debug("connecting to database.");
	my $dbh = DBI->connect("dbi:Pg:dbname=flsdb;host=localhost;port=5432",
		"fls",
		"fls",
		{AutoCommit => 1, RaiseError => 1}
		) or die $DBI::errstr;

	# prepare helpers
	$self->helper(db => sub { $dbh });
	$self->helper(users => sub { state $users = FindLocalShows::Model::Users->new($dbh) });
	$self->helper(shows => sub { state $shows = FindLocalShows::Model::Shows->new });

	# set up routes
	my $r = $self->routes;

	$r->any("/init")->to("init#init_fls")->name("init");

	# middleware to check if fls is initialized
	my $is_initialized = $r->under("/")->to("init#is_initialized");
	# middleware to check if logged in, redirect if not
	my $logged_in = $is_initialized->under("/")->to("login#logged_in");
	# middleware to check if logged in, set value in stash
	my $logged_in_nb = $is_initialized->under("/")->to("login#logged_in_nonblock");

	$logged_in_nb->any("/")->to("show_list#index")->name("index");
	$is_initialized->any("/login")->to("login#login")->name("login");
	$is_initialized->get("/logout")->to("login#logout");
	$logged_in->get("/settings")->to("settings#settings");

}

1;

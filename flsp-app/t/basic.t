use Mojo::Base -strict;

use Test::Mojo;
use Test::More;

use DBI;
use Test::PostgreSQL;
# use Test::More;

################################################################################
# test setup
################################################################################

# prepare minimal database
my $pgsql = Test::PostgreSQL->new() or die $Test::PostgreSQL::errstr;
my $dbh = DBI->connect($pgsql->dsn);

my $init_sql = "
CREATE TABLE supported_regions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    region TEXT
);

CREATE TABLE users (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username TEXT,
    password TEXT,
    default_region INT REFERENCES supported_regions(id)
);

CREATE TABLE settings (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    secret TEXT NOT NULL
);

INSERT INTO supported_regions (region) VALUES ('Virtual'), ('AL'), ('AK'), ('AZ'),
    ('AR'), ('CA'), ('CO'), ('CT'), ('DE'), ('FL'), ('GA'), ('HI'), ('ID'), ('IL'),
    ('IN'), ('IA'), ('KS'), ('KY'), ('LA'), ('ME'), ('MD'), ('MA'), ('MI'), ('MN'),
    ('MS'), ('MO'), ('MT'), ('NE'), ('NV'), ('NH'), ('NJ'), ('NM'), ('NY'), ('NC'),
    ('ND'), ('OH'), ('OK'), ('OR'), ('PA'), ('RI'), ('SC'), ('SD'), ('TN'), ('TX'),
    ('UT'), ('VT'), ('VA'), ('WA'), ('WV'), ('WI'), ('WY');
";

$dbh->do($init_sql);

# set FLSAPP_SECRET
$ENV{FLSAPP_SECRET} = "testsecret";

# start up FindLocalShows
my $t = Test::Mojo->new("FindLocalShows", {dbh => $dbh});

################################################################################
# uninitialized app should redirect all pages to /init
################################################################################

# init page works
$t->get_ok("/init");

# all other pages redirect to /init
$t->get_ok("/")
    ->status_is(302)
    ->header_is(Location => "/init");

$t->get_ok("/settings")
    ->status_is(302)
    ->header_is(Location => "/init");

$t->get_ok("/login")
    ->status_is(302)
    ->header_is(Location => "/init");

################################################################################
# initialized app without having logged in
################################################################################

# initialize findlocalshows
$t->post_ok("/init" => form => { user => "testuser", pass => "testpass" })
    ->status_is(302)
    ->header_is(Location => "/");

# showlist page works and shows appropriate flash message
$t->get_ok("/")
    ->status_is(200)
    ->content_like(qr{FindLocalShows initialized! Please log in to add artists.});

# login page is accessible
$t->get_ok("/login")
    ->status_is(200);

# redirects work appropriately
$t->get_ok("/init")
    ->status_is(302)
    ->header_is(Location => "/");

$t->get_ok("/settings")
    ->status_is(302)
    ->header_is(Location => "/login");

################################################################################
# initialized app after logging in
################################################################################

# login with incorrect credentials
$t->post_ok("/login" => form => { user => "baduser", pass => "badpass" })
    ->status_is(200);

$t->get_ok("/login")
    ->status_is(200)
    ->content_like(qr{Invalid username or password.});

# login with correct credentials
$t->post_ok("/login" => form => { user => "testuser", pass => "testpass" })
    ->status_is(302)
    ->header_is(Location => "/");

$t->get_ok("/")
    ->status_is(200)
    ->content_like(qr{Welcome back testuser.});

# settings page now accessible
$t->get_ok("/settings")
    ->status_is(200);

################################################################################
# initialized app after logging out
################################################################################

$t->get_ok("/logout")
    ->status_is(302)
    ->header_is(Location => "/");

# redirects work appropriately
$t->get_ok("/init")
    ->status_is(302)
    ->header_is(Location => "/");

$t->get_ok("/settings")
    ->status_is(302)
    ->header_is(Location => "/login");

done_testing();

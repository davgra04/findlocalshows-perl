#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

get "/" => sub ($c) {
    $c->render(text => "Heyo boyo!");
};

get "/agent" => sub ($c) {
    my $host = $c->req->url->to_abs->host;
    my $ua = $c->req->headers->user_agent;
    my @lines = (
        "heyo boyo",
        "user agent: $ua",
        "host: $host",
    );
    $c->render(text => join("<br>", @lines));
};

put "/reverse" => sub ($c) {
    my $hash = $c->req->json;
    $hash->{message} = reverse $hash->{message};
    $c->render(json => $hash);
};

# Not found (404)
get '/missing' => sub ($c) {
  $c->render(template => 'does_not_exist');
};

# Exception (500)
get '/dies' => sub { die 'Intentional error' };

app->start;

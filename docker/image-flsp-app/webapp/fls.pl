#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

get "/" => sub ($c) {
    $c->render(text => "Heyo boyo!");
};

app->start;

package FindLocalShows::Controller::ShowList;
use Mojo::Base "Mojolicious::Controller", -signatures;


sub index ($self) {
	my $region = $self->param("region") // "TX";
	$self->stash(region => $region);
    $self->app->log->debug("hit index");
}

1;

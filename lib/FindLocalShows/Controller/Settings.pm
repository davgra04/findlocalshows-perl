package FindLocalShows::Controller::Settings;
use Mojo::Base "Mojolicious::Controller", -signatures;


sub index ($self) {
    $self->app->log->debug("hit settings");
}

1;

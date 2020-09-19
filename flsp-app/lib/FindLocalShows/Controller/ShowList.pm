package FindLocalShows::Controller::ShowList;
use Mojo::Base "Mojolicious::Controller", -signatures;

sub show_list ($self) {
    my $region = $self->param("region") // $self->app->regions->get_default_region();
    $self->stash( region => $region );
    $self->app->log->debug("hit show_list");
}

1;

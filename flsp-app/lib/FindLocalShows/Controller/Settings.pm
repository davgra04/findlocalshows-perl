package FindLocalShows::Controller::Settings;
use Mojo::Base "Mojolicious::Controller", -signatures;

sub settings ($self) {

    my $remove_id  = $self->req->body_params->param("remove-id");
    my $new_artist = $self->req->body_params->param("new-artist");

    if ($remove_id) {
        $self->app->log->debug("REMOVING ARTIST");
        $self->app->log->debug("\$remove_id: $remove_id");
        my $name = $self->app->artists->remove_artist($remove_id);
        if ($name) {
            $self->flash( message => "Removed $name." );
        }
        else {
            $self->flash( message => "Followed Artist ID not found." );
        }
        $self->redirect_to("settings");
    }
    elsif ($new_artist) {
        $self->app->log->debug("ADDING ARTIST");
        $self->app->log->debug("\$new_artist: $new_artist");
        $self->app->artists->add_artist($new_artist);
        $self->flash( message => "Added $new_artist." );
        $self->redirect_to("settings");
    }

    $self->app->log->debug("hit settings");
}

1;

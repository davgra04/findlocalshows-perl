package FindLocalShows::Controller::EventPage;
use Mojo::Base "Mojolicious::Controller", -signatures;

use Data::Dumper;

sub event_page ($self) {
    my $event_id = $self->stash->{event_id};
    $self->redirect_to("show_list") unless $event_id =~ /\d+/;

    $self->app->log->debug("hit event page for event $event_id");

    my $show = $self->app->shows->get_show_info($event_id);
    $self->redirect_to("show_list") unless defined $show;

    my $artist_info = $self->app->artists->get_artist_info($show->{artist_id});
    $show->{artist_info} = $artist_info;
    $self->stash->{show} = $show;

    $self->render;
}

1;

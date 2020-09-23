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

__END__

=head1 NAME

FindLocalShows::Controller::EventPage - Controller object for the event page

=head1 DESCRIPTION

This controller produces an event details page for a single event, specified by
an event id located in the URL path.

=head2 Methods

=over 12

=item C<event_page>

Mojolicious action subroutine that produces the event details page.

=back

=head1 LICENSE

This is released under the Artistic License 2.0. See L<perlartistic>.

=head1 AUTHOR

davgra04 - L<https://github.com/davgra04>

=cut

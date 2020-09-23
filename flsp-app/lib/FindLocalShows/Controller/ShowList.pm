package FindLocalShows::Controller::ShowList;
use Mojo::Base "Mojolicious::Controller", -signatures;

sub show_list ($self) {
    my $region = $self->param("region") // $self->app->regions->get_default_region();
    $self->stash( region => $region );
    $self->app->log->debug("hit show_list");
}

1;

__END__

=head1 NAME

FindLocalShows::Controller::ShowList - Controller object for the show list page

=head1 DESCRIPTION

This controller produces an upcoming shows list page using the provided region
parameter or using the saved default region.

=head2 Methods

=over 12

=item C<show_list>

Mojolicious action subroutine for the shows list page, see DESCRIPTION.

=back

=head1 LICENSE

This is released under the Artistic License 2.0. See L<perlartistic>.

=head1 AUTHOR

davgra04 - L<https://github.com/davgra04>

=cut

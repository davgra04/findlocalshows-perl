package FindLocalShows::Controller::Init;
use Mojo::Base "Mojolicious::Controller", -signatures;

sub init_fls ($self) {
    my $user = $self->req->body_params->param("user") // "";
    my $pass = $self->req->body_params->param("pass") // "";

    # redirect to / if fls already initialized
    $self->redirect_to("show_list") if $self->app->users->has_admin_user;

    # render init page if no POST params provided
    return $self->render if ( $user eq "" or $pass eq "" );

    # encrypt password with bcrypt
    my $encrypted_pass = $self->bcrypt($pass);

    # add user to DB
    $self->users->add_user( $user, $encrypted_pass );
    $self->app->log->debug("added admin user $user");

    $self->flash( message =>
          "FindLocalShows initialized! Please log in to add artists." );
    $self->redirect_to("show_list");
}

sub is_initialized ($self) {
    return 1 if $self->app->users->has_admin_user;
    $self->redirect_to("init");
    return undef;
}

1;

__END__

=head1 NAME

FindLocalShows::Controller::Init - Controller object for the init page

=head1 DESCRIPTION

This controller handles the initialization page where a primary username and
password are prompted for, and also recieves them via POST request to save in
the database.

=head2 Methods

=over 12

=item C<init_fls>

Mojolicious action subroutine that produces the init page for GET requests, and
saves the user/pass combination in the database for POST requests.

=item C<is_initialized>

Returns 1 if FindLocalShows has been initialized with a user/pass. Returns undef
otherwise.

=back

=head1 LICENSE

This is released under the Artistic License 2.0. See L<perlartistic>.

=head1 AUTHOR

davgra04 - L<https://github.com/davgra04>

=cut

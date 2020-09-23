package FindLocalShows::Controller::Login;
use Mojo::Base "Mojolicious::Controller", -signatures;

sub login ($self) {
    my $user         = $self->req->body_params->param("user") // "";
    my $entered_pass = $self->req->body_params->param("pass") // "";
    my $stored_pass  = $self->users->get_password_from_db($user);

    unless ( $stored_pass && $self->bcrypt_validate( $entered_pass, $stored_pass ) ) {
        $self->flash( message => "Invalid username or password." );
        return $self->render;
    }

    $self->session( user => $user );
    $self->flash( message => "Welcome back $user." );
    $self->redirect_to("show_list");
}

sub logged_in ($self) {
    return 1 if $self->session("user");
    $self->redirect_to("login");
    return undef;
}

sub logged_in_nonblock ($self) {
    if ( $self->session("user") ) {
        $self->stash( logged_in => 1 );
    }
    else {
        $self->stash( logged_in => 0 );
    }

    return 1;
}

sub logout ($self) {
    $self->session( expires => 1 );
    $self->redirect_to("show_list");
}

1;

__END__

=head1 NAME

FindLocalShows::Controller::Login - Controller object for the login page

=head1 DESCRIPTION

This controller produces a login page on GET requests, and authorizes the client
on a POST request with valid credentials

=head2 Methods

=over 12

=item C<login>

Mojolicious action subroutine that produces a login page on GET requests, and 
authorizes the client on a POST request with valid credentials.

=item C<logged_in>

Returns 1 if user has authenticated session, otherwise redirects to /login and
returns undef.

=item C<logged_in_nonblock>

Adds value to stash indicatign whether the user is logged on.

=item C<logout>

Expires the current user's session and redirects to the show list.

=back

=head1 LICENSE

This is released under the Artistic License 2.0. See L<perlartistic>.

=head1 AUTHOR

davgra04 - L<https://github.com/davgra04>

=cut

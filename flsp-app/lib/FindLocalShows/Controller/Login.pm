package FindLocalShows::Controller::Login;
use Mojo::Base "Mojolicious::Controller", -signatures;


sub login ($self) {
	my $user = $self->req->body_params->param("user") || "";
	my $entered_pass = $self->req->body_params->param("pass") || "";
	my $stored_pass = $self->users->get_password_from_db($user);

	unless ( $stored_pass && $self->bcrypt_validate( $entered_pass, $stored_pass ) ) {
		$self->flash(message => "Invalid username or password.");
		return $self->render;
	}

	$self->session(user => $user);
	$self->flash(message => "Welcome back $user.");
	$self->redirect_to("index");
}


sub logged_in ($self) {
	return 1 if $self->session("user");
	$self->redirect_to("login");
	return undef;
}


sub logged_in_nonblock ($self) {
	if ( $self->session("user") ) {
		$self->stash(logged_in => 1);
	} else {
		$self->stash(logged_in => 0);
	}

	return 1;
}


sub logout ($self) {
	$self->session(expires => 1);
	$self->redirect_to("index");
}

1;

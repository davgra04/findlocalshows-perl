package FindLocalShows::Controller::Login;
use Mojo::Base "Mojolicious::Controller", -signatures;


sub login ($self) {
	my $user = $self->req->body_params->param("user") || "";
	my $pass = $self->req->body_params->param("pass") || "";
	return $self->render unless $self->users->check_password($user, $pass);

	$self->session(user => $user);
	$self->flash(message => "Thanks for logging in bruh.");
	$self->redirect_to("protected");
}


sub logged_in ($self) {
	return 1 if $self->session("user");
	$self->redirect_to("login");
	return undef;
}


sub logout ($self) {
	$self->session(expires => 1);
	$self->redirect_to("index");
}

1;

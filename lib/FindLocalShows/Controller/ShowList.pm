package FindLocalShows::Controller::ShowList;
use Mojo::Base "Mojolicious::Controller", -signatures;


sub index ($self) {
	# my $user = $self->param("user") || "";
	# my $pass = $self->param("pass") || "";
	# return $self->render unless $self->users->check($user, $pass);

	# $self->session(user => $user);
	# $self->flash(message => "Thanks for logging in bruh.");
	# $self->redirect_to("protected");

    $self->app->log->debug("hit index");
}

1;

package FindLocalShows::Controller::Init;
use Mojo::Base "Mojolicious::Controller", -signatures;


sub init_fls ($self) {
	my $user = $self->req->body_params->param("user") || "";
	my $pass = $self->req->body_params->param("pass") || "";

    # redirect to / if fls already initialized
    $self->redirect_to("index") if $self->app->users->has_admin_user;

    # render init page if no POST params provided
    return $self->render if ($user eq "" or $pass eq "");

    $self->app->log->debug("added admin user $user");
    $self->users->add_user($user, $pass);
    $self->redirect_to("index");
}

sub is_initialized ($self) {
    return 1 if $self->app->users->has_admin_user;
    $self->redirect_to("init");
    return undef;
}

1;
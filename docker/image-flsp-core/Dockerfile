FROM perl:5.32

# install perl dependencies
RUN cpan Data::Dumper
RUN cpan Log::Log4perl
RUN cpan DBI
RUN cpan DBD::Pg
RUN cpan LWP::UserAgent
RUN cpan LWP::Protocol::https
RUN cpan URL::Encode
RUN cpan JSON::XS

# make sure bash is latest
RUN apt-get update
RUN apt-get upgrade -y bash

# copy fls to image
COPY ./flsp-core /usr/src/flsp-core
WORKDIR /usr/src/flsp-core

# run server
CMD [ "bash", "run-flsp-core.sh" ]

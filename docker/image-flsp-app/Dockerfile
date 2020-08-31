FROM perl:5.32

# install perl dependencies
RUN cpan Data::Dumper
RUN cpan Mojolicious
RUN cpan DBI
RUN cpan DBD::Pg
RUN cpan DateTime
RUN cpan DateTime::Format::Strptime
RUN cpan JSON::XS


# copy fls to image
COPY ./flsp-app /usr/src/flsp-app
WORKDIR /usr/src/flsp-app

# run server
CMD [ "./script/find_local_shows", "daemon" ]

FROM perl:5.32

# install perl dependencies
RUN cpan Mojolicious
RUN cpan DBI
RUN cpan DBD::Pg

# copy fls to image
COPY ./findlocalshows-perl /usr/src/findlocalshows-perl
WORKDIR /usr/src/findlocalshows-perl

# run server
CMD [ "./script/find_local_shows", "daemon" ]

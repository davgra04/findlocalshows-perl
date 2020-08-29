FROM perl:5.32

# install perl dependencies
RUN cpan Mojolicious

# copy fls to image
COPY ./webapp /usr/src/webapp
WORKDIR /usr/src/webapp

# run server
CMD [ "perl", "./fls.pl", "daemon" ]

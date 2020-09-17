FROM perl:5.32

# install perl dependencies
ARG ROOT="/usr/src/flsp-app"

WORKDIR $ROOT
COPY Makefile.PL .
# COPY lib/FindLocalShows.pm ./lib/FindLocalShows.pm

RUN perl Makefile.PL \
  && cpanm --no-wget --installdeps --notest . \
  && make distclean \
  && rm -rfv ~/.cpanm /usr/local/share/man/ "$ROOT/t" "$ROOT/Makefile.PL";

COPY . .

CMD [ "./script/find_local_shows", "daemon" ]

LABEL version="1.0" \
  description="FindLocalShows"

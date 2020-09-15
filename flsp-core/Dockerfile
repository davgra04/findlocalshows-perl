FROM perl:5.32

# install perl dependencies
ARG ROOT="/usr/src/flsp-core"

WORKDIR $ROOT
COPY Makefile.PL .

RUN perl Makefile.PL \
  && cpanm --no-wget --installdeps --notest . \
  && make distclean \
  && rm -rfv ~/.cpanm /usr/local/share/man/ "$ROOT/t" "$ROOT/Makefile.PL";

COPY . .

CMD [ "bash", "run-flsp-core.sh" ]

LABEL version="0.0.1" \
  description="FindLocalShows-Core"

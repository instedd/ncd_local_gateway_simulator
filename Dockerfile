FROM crystallang/crystal

ADD . /src
RUN \
  cd /src && \
  shards build --release --no-debug && \
  mv bin/lgwsim /usr/bin/lgwsim

ENV HOST=***
ENV PORT=443
ENV TLS=true
ENV ACCOUNT=***
ENV CHANNEL_NAME=***
ENV CHANNEL_PASSWORD=***
ENV SLEEP_SECONDS=10
ENV NO_REPLY_PERCENT=0.2
ENV DELAY_REPLY_PERCENT=0.2
ENV DELAY_REPLY_MAX_SECONDS=60
ENV INCORRECT_REPLY_PERECENT=0.2
ENV STICKY_RESPONDENTS=true

CMD /usr/bin/lgwsim

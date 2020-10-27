FROM crystallang/crystal:0.35.1

ADD . /src
RUN \
  cd /src && \
  shards build --release --no-debug && \
  mv bin/lgwsim /usr/bin/lgwsim

ENV HOST=*** \
  PORT=443 \
  TLS=true \
  ACCOUNT=*** \
  CHANNEL_NAME=*** \
  CHANNEL_PASSWORD=*** \
  SLEEP_SECONDS=10 \
  NO_REPLY_PERCENT=0.2 \
  DELAY_REPLY_PERCENT=0.2 \
  DELAY_REPLY_MIN_SECONDS=0 \
  DELAY_REPLY_MAX_SECONDS=60 \
  INCORRECT_REPLY_PERCENT=0.2 \
  STICKY_RESPONDENTS=true

CMD /usr/bin/lgwsim

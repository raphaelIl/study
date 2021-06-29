FROM alpine:3.14

LABEL maintainer='raphael9292'
ENV SLACK_WEBHOOK=''
ENV AWS_ACCESS_KEY_ID=''
ENV AWS_SECRET_ACCESS_KEY=''

USER root

COPY test.sh /0619/test.sh
RUN apk --update upgrade && \
  apk add --no-cache jq curl bash python3 py3-pip && \
  pip3 install --upgrade pip && \
  pip3 install awscli && \
  rm -rf /var/cache/apk/* && \
  chmod +x /0619/*

WORKDIR /0619

ENTRYPOINT ["./test.sh"]

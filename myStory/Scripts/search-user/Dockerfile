FROM centos:7.9.2009

LABEL maintainer='raphael9292'
ENV SLACK_WEBHOOK=''
ENV AWS_ACCESS_KEY_ID=''
ENV AWS_SECRET_ACCESS_KEY=''

USER root

COPY test.sh /0619/test.sh
RUN yum install -y epel-release && \
  yum install -y jq curl awscli && \
  chmod +x /0619/*

WORKDIR /0619

ENTRYPOINT ["./test.sh"]

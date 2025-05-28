FROM alpine:3.19

RUN apk add --no-cache \
    aws-cli \
    curl \
    bind-tools \
    iputils \
    bash \
    netcat-openbsd \
    && rm -rf /var/cache/apk/*

WORKDIR /root

CMD ["/bin/bash"]

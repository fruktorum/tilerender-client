FROM alpine:3.13
CMD [ "sh", "-c", "websockify $WEBSOCKET_LISTENER_HOST:$WEBSOCKET_LISTENER_PORT $TCP_SERVER_HOST:$TCP_SERVER_PORT" ]

ENV WEBSOCKET_LISTENER_HOST=0.0.0.0
ENV WEBSOCKET_LISTENER_PORT=3300

RUN apk --no-cache add \
      build-base \
      gcc \
      gfortran \
      git \
      python3 \
      python3-dev \
      py3-pip && \
    \
    pip3 install --upgrade pip && \
    \
    mkdir /sources && \
    git clone https://github.com/novnc/websockify.git /sources/websockify && \
    cd /sources/websockify && \
      pip3 install setuptools wheel numpy && \
      python3 setup.py install && \
    \
    apk del build-base gcc gfortran git python3-dev && \
    cd / && rm -rf /sources /tmp/*

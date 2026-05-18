FROM alpine:3.23.4
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
      py3-setuptools \
      py3-wheel \
      py3-numpy && \
    \
    mkdir /sources && \
    git clone https://github.com/novnc/websockify.git /sources/websockify && \
    cd /sources/websockify && python3 setup.py install && \
    \
    apk del build-base gcc gfortran git && \
    cd / && rm -rf /sources /tmp/*

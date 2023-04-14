FROM crystallang/crystal:1.8.0-alpine AS build
WORKDIR /app
CMD [ "sh" ]

RUN echo -e "http://dl-cdn.alpinelinux.org/alpine/v3.16/main\nhttp://dl-cdn.alpinelinux.org/alpine/v3.16/community" > /etc/apk/repositories && \
    apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add npm && \
    npm i -g npm && npm i -g yarn

COPY shard.* package.json yarn.lock ./
RUN mkdir -p /build assets/scripts/js && \
    yarn install && shards install

FROM build AS release
COPY . .
RUN yarn run compile-production && \
    crystal build --no-debug --release --static --stats -D preview_mt -o /build/app src/tilerender-client.cr

FROM scratch
CMD [ "/app" ]
COPY --from=release /app/assets/fonts /fonts
COPY --from=release /build/app /app

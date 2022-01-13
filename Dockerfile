FROM crystallang/crystal:1.3.0-alpine AS build
WORKDIR /app
CMD [ "sh" ]

RUN apk --no-cache add npm

COPY shard.* package*.json ./
RUN mkdir -p /build assets/scripts/js && \
    npm i -g npm && npm i && npm audit fix && \
    shards install

FROM build AS release
COPY . .
RUN npm run build && \
    npm run uglify && \
    crystal build --no-debug --release --static --stats -D preview_mt -o /build/app src/tilerender-client.cr

FROM scratch
CMD [ "/app" ]
COPY --from=release /app/assets/fonts /fonts
COPY --from=release /build/app /app

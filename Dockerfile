FROM crystallang/crystal:1.13.1-alpine AS build
WORKDIR /app
CMD [ "sh" ]

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add npm && \
    npm i -gf npm && npm i -g pnpm

COPY shard.* package.json pnpm-lock.yaml ./
RUN mkdir -p /build assets/scripts/js && \
    pnpm install && shards install

FROM build AS release
COPY . .
RUN pnpm compile-production && \
    crystal build --no-debug --release --static --stats -D preview_mt -o /build/app src/tilerender-client.cr

FROM scratch
CMD [ "/app" ]
COPY --from=release /app/assets/fonts /fonts
COPY --from=release /build/app /app

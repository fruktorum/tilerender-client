# TileRender Web Client — Agent Guide

## Project overview

Dual-stack: **Crystal** HTTP server + **CoffeeScript** frontend rendered to `<canvas>` via WebSocket binary commands.

## Entrypoints

- Crystal server: `src/tilerender-client.cr` (listens on port 80 inside container, mapped to **9000** externally)
- Frontend: `assets/scripts/coffee/main.coffee` (webpack entry)
- WebSocket proxy: `websockify/Dockerfile` (listens on **3300**, bridges browser WS → external TCP server)

## Developer commands

### Docker (primary workflow)

```bash
docker-compose build app wsproxy   # first-time build
docker-compose up -d app           # production mode
docker-compose up -d dev           # dev mode (hot-recompile on each request)
docker-compose stop app            # or dev — never run both simultaneously
```

### Frontend compilation (manual, outside Docker)

```bash
pnpm install          # install JS deps (uses pnpm-lock.yaml)
pnpm compile          # dev build → assets/scripts/js/main.js
pnpm compile-production  # prod build → assets/scripts/js/main.min.js (obfuscated + terser)
```

### Crystal

```bash
shards install                              # install Crystal deps
crystal build --no-debug --release --static --stats -D preview_mt -o /build/app src/tilerender-client.cr
```

### Tests

```bash
crystal spec   # specs exist but are currently empty stubs
```

## Architecture notes

- **CoffeeScript only** — the dev server compiles `.coffee` sources on each request; native `.js` files in `assets/scripts/coffee/` are ignored.
- `assets/scripts/js/` is **generated and gitignored**. Never edit files there.
- Dev mode runs `yarn run compile` per-request (note: the dev server invokes yarn directly, regardless of pnpm being used for project dependencies).
- Production mode embeds `main.min.js` directly into the Crystal binary at compile time via `{{ read_file }}` macro.
- The Crystal server serves only `/` (HTML) and `/fonts/*`. Everything else → 404.
- `window.Config` is injected with `{wsPort, production}` — frontend reads this for WS connection.

## Environment variables

| Variable | Required | Purpose |
|---|---|---|
| `TCP_SERVER_HOST` | yes | External TCP rendering server host (wsproxy upstream) |
| `TCP_SERVER_PORT` | yes | External TCP rendering server port |
| `WS_PORT` | no (default: 3300) | WebSocket port the browser connects to |

Copy `.env.sample` → `.env` and fill in `TCP_SERVER_HOST`/`TCP_SERVER_PORT`.

## Key constraints

- **Never run `app` and `dev` services simultaneously** — they both bind port 9000.
- `wsproxy` requires the `websockify-proxy` Docker network. External TCP servers must be attached to this network to communicate.
- Crystal build uses `-D preview_mt` (multi-threading preview flag).
- Webpack production build applies `webpack-obfuscator` with `browser-no-eval` target + `mangled-shuffled` identifiers.

## Project map

See [project-map.md](project-map.md) for the full directory tree and file descriptions.

## Directory ownership

```
src/              → Crystal server code
assets/scripts/coffee/ → Frontend source (CoffeeScript)
assets/scripts/js/     → Generated JS (gitignored)
assets/fonts/          → Static fonts served by Crystal
websockify/            → WebSocket proxy Dockerfile
spec/                  → Crystal specs (empty stubs)
```

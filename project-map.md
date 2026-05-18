# TileRender Web Client — Project Map

```
web_client/
├── src/
│   ├── tilerender-client.cr      # Crystal HTTP server entrypoint (port 80 → 9000)
│   └── version.cr                # Version constant
├── assets/
│   ├── fonts/
│   │   ├── victormono.woff2      # Victor Mono font (woff2)
│   │   └── victormono.woff       # Victor Mono font (woff)
│   └── scripts/
│       ├── coffee/               # Frontend source (CoffeeScript only)
│       │   ├── main.coffee       # Webpack entry, WS connection, bootstrap
│       │   ├── buffer.coffee     # Binary command buffer/parser
│       │   ├── controller.coffee # WebSocket message dispatcher
│       │   ├── field.coffee      # Canvas rendering logic
│       │   └── text.coffee       # Console/log overlay UI
│       └── js/                   # Generated output (gitignored, never edit)
│           ├── main.js           # Dev build
│           └── main.min.js       # Production build (obfuscated + terser)
├── spec/
│   ├── spec_helper.cr            # Crystal spec bootstrap
│   └── socket_canvas_spec.cr     # Empty spec stub
├── websockify/
│   └── Dockerfile                # WebSocket proxy image (wsproxy service)
├── Dockerfile                    # Multi-stage Crystal build (build → release → scratch)
├── docker-compose.yml            # Three services: app, dev, wsproxy
├── webpack.config.js             # Frontend bundler (dev + production with obfuscator)
├── package.json                  # JS deps + pnpm scripts
├── pnpm-lock.yaml                # JS lockfile
├── shard.yml                     # Crystal package manifest
├── shard.lock                    # Crystal lockfile
├── .env.sample                   # Required env vars template (TCP_SERVER_HOST/PORT)
├── .env                          # Actual env vars (gitignored)
├── .gitignore                    # Excludes generated JS, node_modules, shards, .env
├── .dockerignore                 # Docker build context exclusions
├── AGENTS.md                     # AI agent guide (commands, quirks, constraints)
├── README.md                     # Human-facing documentation
└── LICENSE                       # MIT
```

## Key files at a glance

| File | Purpose |
|---|---|
| `src/tilerender-client.cr` | Serves HTML on `/`, fonts on `/fonts/*`, 404 elsewhere. Embeds `main.min.js` in release mode via macro. |
| `assets/scripts/coffee/main.coffee` | Frontend entry — connects to WS, initializes canvas. |
| `webpack.config.js` | Compiles CoffeeScript → JS. Production adds obfuscator + terser. |
| `docker-compose.yml` | `app` (prod), `dev` (hot-recompile), `wsproxy` (WS bridge). Never run `app` + `dev` together. |
| `websockify/Dockerfile` | WebSocket-to-TCP proxy. Bridges browser → external rendering server. |

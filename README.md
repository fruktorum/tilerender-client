# Socket Graphics - Client-Side

Renders graphics based on websocket binary commands into the canvas.

## Installation

1. Install Docker, Docker Compose
2. `docker-compose build app wsproxy`

## Usage

Websocket connection uses proxy to connect to backend logic. There are no problems if it is launched in Docker.<br/>
The one thing is to connect `wsproxy` service with native socket server. Docker compose uses specific network for this. Assign this network with external socket server (create it if it is not existed).

1. Be sure that `TCP_SERVER_HOST` and `TCP_SERVER_PORT` is configured properly for wsproxy and connects to host and port of external socket server
2. Please be sure that `dev` service is turned off (`docker-compose stop dev`)
3. `docker-compose up -d app` - starts the service and listens on **9000** port

Do not start `app` and `dev` services simultaneously, they are interchangeable.

Please keep in mind that:

1. Websocket Proxy's **binding** host and port configures via environment variables in `docker-compose.yml` and is called `TCP_SERVER_HOST` and `TCP_SERVER_PORT`; there are no defaults for it
2. Websocket Proxy's **listening** host and port configures via environment variables in `docker-compose.yml` and is called `WEBSOCKET_LISTENER_HOST` and `WEBSOCKET_LISTENER_PORT`; defaults are: `0.0.0.0`, `3300`

## Development

### Launch in dev mode

1. Please be sure that `app` service is turned off (`docker-compose stop app`)
2.
   1. If needed only the development of frontend coffee sources: `docker-compose up -d dev` - starts the service and listens on **9000** port
   2. If needed the development of internal HTML or server sources itself: `docker-compose run --rm --service-ports dev sh` - launches the container session

Do not start `app` and `dev` services simultaneously, they are interchangeable.

### How it looks

1. Front sources are placed into [coffee](assets/scripts/coffee) folder
2. It is not needed to restart the server to update files
3. On each request all `coffee` sources concatenates into the single file, compiles it to js and loads on the page
4. Native js files are not supported, the engine handles only `coffee` sources
5. Production mode (the `app` service) uses minified version of sources statically compiled into Crystal web server itself

## Contributing

1. Clone it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Merge Request

## Contributors

- [SlayerShadow](https://github.com/SlayerShadow) - creator and maintainer

# Socket Graphics - Client-Side

Renders graphics based on websocket binary commands into the canvas.

## Installation

1. Install Docker, Docker Compose
2. `docker-compose build`

## Usage

To work properly it needs to be launched server-side engine on specific (currently **3300**) port on the same workstation.

1. Please be sure that `dev` service is turned off (`docker-compose stop dev`)
2. `docker-compose up -d app` - starts the service and listens on **9000** port
3. Do not start `app` and `dev` services simultaneously, they are interchangeable

Web server port and remote websocket host/port are configurable through environment variables in `docker-compose.yml`.

## Development

### Launch in dev mode

1. Please be sure that `app` service is turned off (`docker-compose stop app`)
2. `docker-compose up -d dev` - starts the service and listens on **9000** port
3. Do not start `app` and `dev` services simultaneously, they are interchangeable

### How it looks

1. Front sources are placed into [coffee](assets/scripts/coffee) folder
2. It is not needed to restart the server to update files
3. Before each request all coffee sources concatenates into the single file, compiles it and loads on the page
4. Native js files are not supported, the engine handles only coffee sources
5. Production mode (`app` service launch) uses minified version of sources statically compiled into web server itself

## Contributing

1. Clone it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Merge Request

## Contributors

- [SlayerShadow](https://github.com/SlayerShadow) - creator and maintainer

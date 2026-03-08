# CS:GO Dedicated Server Docker

Counter-Strike: Global Offensive dedicated server running in Docker with automated builds and releases.

<img src="https://1000logos.net/wp-content/uploads/2017/12/CSGO-Logo.png" alt="logo" width="300"/></img>

## Quick Start

```bash
docker run -d --net=host --name=csgo-server \
  -e SRCDS_TOKEN={YOUR_TOKEN} \
  ghcr.io/w1tsky/csgo:latest
```

**`SRCDS_TOKEN` is required for your server to be listed & reachable.**  
Generate one here (AppID `730`): [Steam Game Server Account Management](https://steamcommunity.com/dev/managegameservers)

## Usage

### Host networking (recommended)

```bash
docker run -d --net=host --name=csgo-server \
  -e SRCDS_TOKEN={YOUR_TOKEN} \
  ghcr.io/w1tsky/csgo:latest
```

### With persistent data

```bash
mkdir -p $(pwd)/csgo-data
chmod 777 $(pwd)/csgo-data
docker run -d --net=host \
  -v $(pwd)/csgo-data:/home/steam/csgo-dedicated/ \
  --name=csgo-server \
  -e SRCDS_TOKEN={YOUR_TOKEN} \
  ghcr.io/w1tsky/csgo:latest
```

### Multiple instances

```bash
docker run -d --net=host --name=csgo-server-2 \
  -e SRCDS_PORT=27016 \
  -e SRCDS_TV_PORT=27021 \
  -e SRCDS_TOKEN={YOUR_TOKEN} \
  ghcr.io/w1tsky/csgo:latest
```

### Using Docker Compose

```bash
docker-compose up -d
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SRCDS_TOKEN` | `0` | Steam Game Server Login Token (required for public servers) |
| `SRCDS_RCONPW` | `changeme` | RCON password |
| `SRCDS_PW` | `changeme` | Server password |
| `SRCDS_PORT` | `27015` | Game port |
| `SRCDS_TV_PORT` | `27020` | SourceTV port |
| `SRCDS_CLIENT_PORT` | `27005` | Client port |
| `SRCDS_NET_PUBLIC_ADDRESS` | `0` | Public IP (useful for NAT setups) |
| `SRCDS_IP` | `0` | Local IP to bind |
| `SRCDS_LAN` | `0` | LAN mode |
| `SRCDS_FPSMAX` | `300` | Max FPS |
| `SRCDS_TICKRATE` | `128` | Server tickrate |
| `SRCDS_MAXPLAYERS` | `14` | Max players |
| `SRCDS_STARTMAP` | `de_dust2` | Starting map |
| `SRCDS_REGION` | `3` | Server region |
| `SRCDS_MAPGROUP` | `mg_active` | Map group |
| `SRCDS_GAMETYPE` | `0` | Game type |
| `SRCDS_GAMEMODE` | `1` | Game mode |
| `SRCDS_HOSTNAME` | `New csgo Server` | Server hostname |
| `SRCDS_WORKSHOP_START_MAP` | `0` | Workshop map ID to start |
| `SRCDS_HOST_WORKSHOP_COLLECTION` | `0` | Workshop collection ID |
| `SRCDS_WORKSHOP_AUTHKEY` | `` | Steam API key for workshop |
| `SRCDS_ADDITIONAL_ARGS` | `` | Additional launch arguments |

## Image Variants

| Image | Description |
|-------|-------------|
| `ghcr.io/w1tsky/csgo:latest` | Base CS:GO server |
| `ghcr.io/w1tsky/csgo:metamod` | With [Metamod:Source](https://www.sourcemm.net) |
| `ghcr.io/w1tsky/csgo:sourcemod` | With Metamod + [SourceMod](https://www.sourcemod.net) |

## Configuration

The image includes ESL config files. Edit server config:

```bash
docker exec -it csgo-server nano /home/steam/csgo-dedicated/csgo/cfg/server.cfg
```

See [Valve's documentation](https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers#Advanced_Configuration) for advanced configuration.

## Building

```bash
# Build steamcmd base
docker build -t steamcmd:latest ./steamcmd

# Build CS:GO server
docker build -t csgo:latest --build-arg BASE_IMAGE=steamcmd:latest .
```

## Credits

Based on [CM2Walki/CSGO](https://github.com/CM2Walki/CSGO).

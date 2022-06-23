# tModLoader Docker ![tMod Version] ![Terraria Version]  [![Docker Pulls]][0]

[tModLoader] dedicated server  

Terraria server 1.4.3.6 with tModLoader v0.11.8.8.

Supports graceful shutdown (saves when the container receives a stop command) and also supports autosaving every 10 minutes (configurable, see [Environment Variables] below).

## Quick Start

    docker run -d --name tmod -p 7777:7777 -v /etc/localtime:/etc/localtime:ro rfvgyhn/tmodloader

# Adding worlds

    docker run -d --name tmod -p 7777:7777 -v /etc/localtime:/etc/localtime:ro -v $(pwd)/data:/terraria rfvgyhn/tmodloader

# Server Config File

You can mount a config file. This allows you to specify server and world settings. If you don't specify one, a [default] will be used. See [wiki] for file format details.

    docker run -d --name tmod -p 7777:7777 -v /etc/localtime:/etc/localtime:ro -v $(pwd)/data:/terraria -v $(pwd)/config.txt:/terraria-server/config.txt rfvgyhn/tmodloader

# Initial Setup

If you want to use the server's mod browser to install and enable mods, run an interactive container with the `setup` parameter appended to the end.

    docker run -it --rm -v $(pwd)/data:/terraria rfvgyhn/tmodloader setup

After setting up your mods, and optionally setting up a world, press `Ctrl+C` to exit the container. Then you can use the normal docker command to run your server. Note that you'll see the mods and the `enabled.json` files appear in your mods folder on the host.

You can also skip this step and [directly] download your mods. Place the mod files in your `data/ModLoader/Mods` folder and make sure to enable them in the `data/ModLoader/Mods/enabled.json` file.

# Sending Commands to the Server

This container is designed to be run in headless mode. This means you you can't manually type [commands] like you would on a normal Terraria server.
You can inject [commands] from the host machine though. For example, assuming your container is named _tmod_:

    docker exec tmod inject "kick player1"
    docker exec tmod inject "say NOT THE BEEES!!!"

# Environment Variables

Name                     | Default Value  | |
-------------------------|----------------|-
TMOD_SHUTDOWN_MSG        | Shutting Down! | Message that appears when server is shutting down
TMOD_AUTOSAVE_INTERVAL   | */10 * * * *   | Cron expression that specifies how often to save the world. Default is every 10 minutes.
TMOD_IDLE_CHECK_INTERVAL | Disabled       | Cron expression that specifies how often to check if no players are online. If none are online, the server will save the world and exit. This can be useful if your server costs are based on CPU usage. Pairs well with [game-manager].
TMOD_IDLE_CHECK_OFFSET   | 0              | This allows for sub-minute resolution if the idle check interval is specified

    docker run -d --name tmod \
               -e TMOD_SHUTDOWN_MSG="Goodbye" \
               -e TMOD_AUTOSAVE_INTERVAL="*/15 * * * *" \
               -e TMOD_IDLE_CHECK_INTERVAL="*/1 * * * *" \
               -e TMOD_IDLE_CHECK_OFFSET=10 \
               -p 7777:7777 \
               -v /etc/localtime:/etc/localtime:ro \
               rfvgyhn/tmodloader

# Sample Docker Compose

    version: '3'
    services:
        tmod:
            image: 'rfvgyhn/tmodloader:latest'
            container_name: 'tmod'
            ports:
                - '7777:7777'
            volumes:
                - /etc/localtime:/etc/localtime:ro
                - ./data:/terraria
                - ./config.txt:/terraria-server/config.txt
            environment:
                - TMOD_SHUTDOWN_MSG="See ya!"

[tModLoader]: https://www.tmodloader.net/
[wiki]: https://terraria.gamepedia.com/Server#Server_config_file
[commands]: https://terraria.gamepedia.com/Server#List_of_console_commands
[tMod Version]: https://img.shields.io/badge/tMod-0.11.8.8-blue
[Terraria Version]: https://img.shields.io/badge/Terraria-1.4.3.6-blue
[Docker Stars]: https://img.shields.io/docker/stars/rfvgyhn/tmodloader.svg
[Docker Pulls]: https://img.shields.io/docker/pulls/rfvgyhn/tmodloader.svg
[default]: https://github.com/Rfvgyhn/tmodloader-docker/blob/master/config.txt
[directly]: https://github.com/tModLoader/tModLoader/wiki/Mod-Browser#direct-download
[Environment Variables]: #environment-variables
[game-manager]: https://hub.docker.com/r/rfvgyhn/game-manager/
[0]: https://hub.docker.com/r/rfvgyhn/tmodloader

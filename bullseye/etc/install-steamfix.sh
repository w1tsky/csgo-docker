#!/bin/bash
# CS:GO Steam Fix Installer (SourceMod Extension + Plugins)
# Patches the engine to allow archived CS:GO clients (AppID 4465480) to connect
# Source: https://github.com/eonexdev/csgo-sv-fix-engine

set -e

STEAMAPPDIR="${1:-/home/steam/csgo-dedicated}"
STEAMFIX_EXT="${STEAMAPPDIR}/csgo/addons/sourcemod/extensions/csgo_steamfix.ext.so"
STEAMFIX_URL="https://github.com/eonexdev/csgo-sv-fix-engine/raw/main/csgo_steamfix.ext.so"
NOLOBBY_SMX="${STEAMAPPDIR}/csgo/addons/sourcemod/plugins/NoLobbyReservation.smx"
NOLOBBY_ZIP_URL="https://github.com/nuxencs/NoLobbyReservation/releases/download/v0.0.1/NoLobbyReservation.zip"

# Check if SourceMod is installed
if [ ! -d "${STEAMAPPDIR}/csgo/addons/sourcemod" ]; then
    echo "[steamfix] SourceMod not installed, skipping"
    exit 0
fi

# Download steamfix extension if not exists
if [ ! -f "${STEAMFIX_EXT}" ]; then
    echo "[steamfix] Downloading csgo_steamfix.ext.so..."
    mkdir -p "${STEAMAPPDIR}/csgo/addons/sourcemod/extensions"
    curl -sL -o "${STEAMFIX_EXT}" "${STEAMFIX_URL}"
    touch "${STEAMAPPDIR}/csgo/addons/sourcemod/extensions/csgo_steamfix.autoload"
    echo "[steamfix] Installed"
else
    echo "[steamfix] Already installed"
fi

# Download NoLobbyReservation plugin if not exists
if [ ! -f "${NOLOBBY_SMX}" ]; then
    echo "[nolobby] Downloading NoLobbyReservation..."
    curl -sL "${NOLOBBY_ZIP_URL}" -o /tmp/nolobby.zip
    unzip -o /tmp/nolobby.zip -d "${STEAMAPPDIR}/csgo/"
    rm /tmp/nolobby.zip
    echo "[nolobby] Installed"
else
    echo "[nolobby] Already installed"
fi

#!/bin/bash
# CS:GO Steam Fix Installer (SourceMod Extension)
# Patches the engine to allow archived CS:GO clients (AppID 4465480) to connect
# Source: https://github.com/eonexdev/csgo-sv-fix-engine

set -e

STEAMAPPDIR="${1:-/home/steam/csgo-dedicated}"
STEAMFIX_EXT="${STEAMAPPDIR}/csgo/addons/sourcemod/extensions/csgo_steamfix.ext.so"
STEAMFIX_URL="https://github.com/eonexdev/csgo-sv-fix-engine/raw/main/csgo_steamfix.ext.so"

# Check if SourceMod is installed
if [ ! -d "${STEAMAPPDIR}/csgo/addons/sourcemod" ]; then
    echo "[steamfix] SourceMod not installed, skipping"
    exit 0
fi

# Download if not exists
if [ ! -f "${STEAMFIX_EXT}" ]; then
    echo "[steamfix] Downloading csgo_steamfix.ext.so..."
    mkdir -p "${STEAMAPPDIR}/csgo/addons/sourcemod/extensions"
    curl -sL -o "${STEAMFIX_EXT}" "${STEAMFIX_URL}"
    touch "${STEAMAPPDIR}/csgo/addons/sourcemod/extensions/csgo_steamfix.autoload"
    echo "[steamfix] Installed"
else
    echo "[steamfix] Already installed"
fi

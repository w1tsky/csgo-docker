#!/bin/bash
echo "========================================"
echo "[ENTRY] Starting CS server entry script"
echo "[ENTRY] STEAMAPPID=${STEAMAPPID}"
echo "[ENTRY] STEAMAPPDIR=${STEAMAPPDIR}"
echo "[ENTRY] STEAMAPP=${STEAMAPP}"
echo "========================================"

echo "[STEP 1/7] Creating app directory: ${STEAMAPPDIR}"
mkdir -p "${STEAMAPPDIR}" || true  

echo "[STEP 2/7] Running steamcmd update for app ${STEAMAPPID}..."
bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
				+login anonymous \
				+app_update "${STEAMAPPID}" \
				+quit
echo "[STEP 2/7] steamcmd update finished (exit code: $?)"

# Create steamcmd update script for autoupdate if it doesn't exist
UPDATE_TXT="${HOMEDIR}/${STEAMAPP}_update.txt"
if [ ! -f "${UPDATE_TXT}" ]; then
	echo "[STEP 2.5/7] Creating ${UPDATE_TXT} for autoupdate..."
	{
		echo '@ShutdownOnFailedCommand 1'
		echo '@NoPromptForPassword 1'
		echo "force_install_dir ${STEAMAPPDIR}"
		echo "login anonymous"
		echo "app_update ${STEAMAPPID}"
		echo 'quit'
	} > "${UPDATE_TXT}"
else
	echo "[STEP 2.5/7] ${UPDATE_TXT} already exists, skipping"
fi

# Patch steam.inf to use the legacy standalone appID
STEAM_INF="${STEAMAPPDIR}/${STEAMAPP}/steam.inf"
if [ -f "${STEAM_INF}" ]; then
	echo "[STEP 2.6/7] Patching ${STEAM_INF}: appID=730 -> appID=4465480"
	sed -i 's/^appID=730/appID=4465480/' "${STEAM_INF}"
else
	echo "[STEP 2.6/7] ${STEAM_INF} not found, skipping patch"
fi


# Are we in a metamod container and is the metamod folder missing?
echo "[STEP 3/7] Checking for MetaMod (METAMOD_VERSION=${METAMOD_VERSION:-not set})..."
if  [ ! -z "$METAMOD_VERSION" ] && [ ! -d "${STEAMAPPDIR}/${STEAMAPP}/addons/metamod" ]; then
	echo "[STEP 3/7] Installing MetaMod ${METAMOD_VERSION}..."
	LATESTMM=$(wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/mmsource-latest-linux)
	wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/"${LATESTMM}" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
else
	echo "[STEP 3/7] MetaMod skipped"
fi

# Are we in a sourcemod container and is the sourcemod folder missing?
echo "[STEP 4/7] Checking for SourceMod (SOURCEMOD_VERSION=${SOURCEMOD_VERSION:-not set})..."
if  [ ! -z "$SOURCEMOD_VERSION" ] && [ ! -d "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod" ]; then
	echo "[STEP 4/7] Installing SourceMod ${SOURCEMOD_VERSION}..."
	LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/sourcemod-latest-linux)
	wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
else
	echo "[STEP 4/7] SourceMod skipped"
fi

# Install csgo_steamfix for AppID 4465480 compatibility
echo "[STEP 5/7] Installing csgo_steamfix..."
source /etc/install-steamfix.sh "${STEAMAPPDIR}"

# Is the config missing?
echo "[STEP 6/7] Checking for server.cfg at ${STEAMAPPDIR}/${STEAMAPP}/cfg/server.cfg..."
if [ ! -f "${STEAMAPPDIR}/${STEAMAPP}/cfg/server.cfg" ]; then
	echo "[STEP 6/7] server.cfg not found, copying baked-in configs..."
	cp -r /etc/csgo/* "${STEAMAPPDIR}/${STEAMAPP}/cfg"
	echo "[STEP 6/7] Configs copied"
else
	echo "[STEP 6/7] server.cfg already exists, skipping copy"
fi

# Believe it or not, if you don't do this srcds_run shits itself
cd "${STEAMAPPDIR}"

echo "[STEP 7/7] Launching srcds_run..."
echo "----------------------------"

LAUNCH_ARGS=(
    -game "${STEAMAPP}"
	-usercon
    -console
    -autoupdate
    -steam_dir "${STEAMCMDDIR}"
    -steamcmd_script "${HOMEDIR}/${STEAMAPP}_update.txt"
    +fps_max "${SRCDS_FPSMAX}"
    -tickrate "${SRCDS_TICKRATE}"
    -port "${SRCDS_PORT}"
    +tv_port "${SRCDS_TV_PORT}"
    +clientport "${SRCDS_CLIENT_PORT}"
    -maxplayers_override "${SRCDS_MAXPLAYERS}"
    +game_type "${SRCDS_GAMETYPE}"
    +game_mode "${SRCDS_GAMEMODE}"
    +mapgroup "${SRCDS_MAPGROUP}"
    +map "${SRCDS_STARTMAP}"
    +sv_setsteamaccount "${SRCDS_TOKEN}"
    +sv_region "${SRCDS_REGION}"
    +sv_lan "${SRCDS_LAN}"
    +hostname "${SRCDS_HOSTNAME}"
)

# Add optional arguments only if they are not empty/zero
[[ -n "${SRCDS_RCONPW}" ]] && LAUNCH_ARGS+=(+rcon_password "${SRCDS_RCONPW}")
[[ -n "${SRCDS_PW}" ]] && LAUNCH_ARGS+=(+sv_password "${SRCDS_PW}")
[[ -n "${SRCDS_NET_PUBLIC_ADDRESS}" && "${SRCDS_NET_PUBLIC_ADDRESS}" != "0" ]] && LAUNCH_ARGS+=(+net_public_adr "${SRCDS_NET_PUBLIC_ADDRESS}")
[[ -n "${SRCDS_IP}" && "${SRCDS_IP}" != "0" ]] && LAUNCH_ARGS+=(-ip "${SRCDS_IP}")
[[ -n "${SRCDS_WORKSHOP_AUTHKEY}" && "${SRCDS_WORKSHOP_AUTHKEY}" != "0" ]] && LAUNCH_ARGS+=(-authkey "${SRCDS_WORKSHOP_AUTHKEY}")
[[ -n "${SRCDS_HOST_WORKSHOP_COLLECTION}" && "${SRCDS_HOST_WORKSHOP_COLLECTION}" != "0" ]] && LAUNCH_ARGS+=(+host_workshop_collection "${SRCDS_HOST_WORKSHOP_COLLECTION}")
[[ -n "${SRCDS_WORKSHOP_START_MAP}" && "${SRCDS_WORKSHOP_START_MAP}" != "0" ]] && LAUNCH_ARGS+=(+workshop_start_map "${SRCDS_WORKSHOP_START_MAP}")

if [[ -n "${SRCDS_ADDITIONAL_ARGS}" ]]; then
    for arg in ${SRCDS_ADDITIONAL_ARGS}; do LAUNCH_ARGS+=("$arg"); done
fi

echo "  Command: srcds_run ${LAUNCH_ARGS[*]}"
echo "----------------------------"

exec bash "${STEAMAPPDIR}/srcds_run" "${LAUNCH_ARGS[@]}"

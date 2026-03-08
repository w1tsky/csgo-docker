FROM ghcr.io/w1tsky/steamcmd:latest

ENV STEAMAPPID=740 \
	STEAMAPP=csgo \
	STEAMAPPDIR="${HOMEDIR}/csgo-dedicated" \
	SRCDS_FPSMAX=300 \
	SRCDS_TICKRATE=128 \
	SRCDS_PORT=27015 \
	SRCDS_TV_PORT=27020 \
	SRCDS_CLIENT_PORT=27005 \
	SRCDS_NET_PUBLIC_ADDRESS="0" \
	SRCDS_IP="0" \
	SRCDS_LAN="0" \
	SRCDS_MAXPLAYERS=14 \
	SRCDS_TOKEN=0 \
	SRCDS_RCONPW="changeme" \
	SRCDS_PW="changeme" \
	SRCDS_STARTMAP="de_dust2" \
	SRCDS_REGION=3 \
	SRCDS_MAPGROUP="mg_active" \
	SRCDS_GAMETYPE=0 \
	SRCDS_GAMEMODE=1 \
	SRCDS_HOSTNAME="CS:GO Server" \
	SRCDS_WORKSHOP_START_MAP=0 \
	SRCDS_HOST_WORKSHOP_COLLECTION=0 \
	SRCDS_WORKSHOP_AUTHKEY="" \
	SRCDS_ADDITIONAL_ARGS=""

RUN apt-get update && apt-get install -y --no-install-recommends \
	wget ca-certificates lib32z1 curl \
	&& rm -rf /var/lib/apt/lists/*

COPY bullseye/etc/entry.sh "${HOMEDIR}/entry.sh"
COPY bullseye/etc/csgo "/etc/csgo"

RUN chmod +x "${HOMEDIR}/entry.sh" && chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh"

USER ${USER}
WORKDIR ${HOMEDIR}

EXPOSE 27015/tcp 27015/udp 27020/udp

CMD ["bash", "entry.sh"]

#!/usr/bin/env bash
set -e

cd /usr/share/drawio-desktop

export DRAWIO_DISABLE_UPDATE=true

ELECTRON_ARGS=()

if [[ $# -ne 0 ]]; then
	ABSPATH="$(realpath \"$1\")"
	ELECTRON_ARGS+=(
		. "${ABSPATH}"
	)
fi

ELECTRON_ARGS+=(
	--version="@DD_VER@"
	--name="draw.io"
	--description="draw.io desktop"
)

if [[ "${EUID}" -eq 0 ]]; then
   ELECTRON_ARGS+=(
	   --no-sandbox
   )
fi

exec ./node_modules/.bin/electron "${ELECTRON_ARGS[@]}" ./src/main/electron.js

#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <host> [--user USER] [--port PORT] [--proxyjump HOST]

Creates per-host SSH key and config under ~/.ssh/config.d/<host>.conf
and adds the key to the agent. Prints the public key path.
EOF
}

[ $# -lt 1 ] && { usage; exit 1; }

HOST="$1"; shift || true
USER=""; PORT=""; PJ=""
while [ $# -gt 0 ]; do
  case "$1" in
    --user) USER="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    --proxyjump) PJ="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

SSH_DIR="$HOME/.ssh"
CONF_DIR="$SSH_DIR/config.d"
KEY_FILE="$SSH_DIR/id_ed25519_$HOST"

mkdir -p "$CONF_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$KEY_FILE" ]; then
  ssh-keygen -t ed25519 -C "$HOST" -f "$KEY_FILE" -N ""
fi

if [[ "$OSTYPE" == darwin* ]]; then
  eval "$(ssh-agent -s)" >/dev/null
  ssh-add --apple-use-keychain "$KEY_FILE" || ssh-add "$KEY_FILE"
else
  eval "$(ssh-agent -s)" >/dev/null
  ssh-add "$KEY_FILE"
fi

CONF_FILE="$CONF_DIR/$HOST.conf"
{
  echo "Host $HOST"
  [ -n "$USER" ] && echo "  User $USER"
  [ -n "$PORT" ] && echo "  Port $PORT"
  [ -n "$PJ" ] && echo "  ProxyJump $PJ"
  echo "  IdentitiesOnly yes"
  echo "  IdentityFile $KEY_FILE"
} > "$CONF_FILE"

chmod 600 "$CONF_FILE"
echo "[ssh-host] Configured $HOST. Public key:" && echo && cat "$KEY_FILE.pub" && echo


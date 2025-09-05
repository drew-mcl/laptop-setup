#!/usr/bin/env bash
set -euo pipefail

PREFERRED_PROVIDER="${JDK_PROVIDER:-oracle}"

if ! command -v jenv >/dev/null 2>&1; then
  echo "[java-setup] jenv not found. Run 'make brew-core' first."
  exit 1
fi

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)" >/dev/null

echo "[java-setup] Enabling jenv export plugin..."
jenv enable-plugin export || true

echo "[java-setup] Discovering installed JDKs..."
ADDED=0
add_jdk() {
  local dir="$1"
  if [ -d "$dir" ] && [ -x "$dir/bin/java" ]; then
    jenv add "$dir" && ADDED=1 || true
  fi
}

# Common install locations on macOS
for base in \
  "/Library/Java/JavaVirtualMachines" \
  "$HOME/Library/Java/JavaVirtualMachines" \
  "$(brew --prefix 2>/dev/null)/opt" \
  "/opt/homebrew/opt" \
  "/usr/local/opt"
do
  [ -d "$base" ] || continue
  while IFS= read -r -d '' jdk; do
    # Oracle, Temurin, etc., all end in Contents/Home
    add_jdk "$jdk/Contents/Home"
  done < <(find "$base" -maxdepth 3 -type d -name "*.jdk" -print0 2>/dev/null || true)
done

# Fallback to java_home enumerations
/usr/libexec/java_home -V 2>/dev/null | awk '/\/(Library|Users)\/.*\/Home/ {print $NF}' | while read -r home; do
  add_jdk "$home"
done

echo "[java-setup] jenv versions:"
jenv versions || true

choose_preferred() {
  # Prefer Oracle if requested; fall back to highest version
  local chosen
  if [ "$PREFERRED_PROVIDER" = "oracle" ]; then
    chosen=$(jenv versions --bare 2>/dev/null | grep -E "^([0-9]+\.)+[0-9]+\.?" | grep -i oracle || true)
    if [ -z "$chosen" ]; then
      chosen=$(jenv versions --bare 2>/dev/null | grep -E "^([0-9]+\.)+[0-9]+\.?" | sort -Vr | head -n1)
    fi
  else
    chosen=$(jenv versions --bare 2>/dev/null | grep -E "^([0-9]+\.)+[0-9]+\.?" | sort -Vr | head -n1)
  fi
  echo "$chosen"
}

CHOSEN=$(choose_preferred)
if [ -n "$CHOSEN" ]; then
  echo "[java-setup] Setting jenv global to: $CHOSEN"
  jenv global "$CHOSEN"
else
  echo "[java-setup] No JDKs found by jenv. Install Oracle JDKs and rerun."
fi

echo "[java-setup] JAVA_HOME: $(jenv prefix 2>/dev/null || echo unset)"


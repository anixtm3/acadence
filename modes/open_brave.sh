#!/bin/bash

# Open Brave in a specific profile in a way Acadence can verify.
# This script intentionally adds an extra flag (--acadence-profile=...)
# so the mode watchdog can tell "allowed" Brave apart from arbitrary Brave.

PROFILE="$1"
if [ -z "$PROFILE" ]; then
  echo "Usage: $0 \"Profile Name\""
  exit 2
fi

if ! command -v brave >/dev/null 2>&1 && ! command -v brave-browser >/dev/null 2>&1; then
  echo "Brave not found on PATH."
  exit 1
fi

# Prefer `brave` if present, otherwise `brave-browser`.
BRAVE_BIN="brave"
command -v brave >/dev/null 2>&1 || BRAVE_BIN="brave-browser"

exec "$BRAVE_BIN" \
  --profile-directory="$PROFILE" \
  "--acadence-profile=$PROFILE"


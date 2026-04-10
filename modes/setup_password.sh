#!/bin/bash
# Run once to set your exit password securely.
# Usage: bash setup_password.sh
# Stores a SHA256 hash in config/.exit_hash — never the plaintext.

ACADENCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ACADENCE_ROOT/config"
HASH_FILE="$CONFIG_DIR/.exit_hash"

mkdir -p "$CONFIG_DIR"

echo -n "Set Acadence exit password: "
read -rs PASSWORD
echo

if [ -z "$PASSWORD" ]; then
    echo "Error: password cannot be empty."
    exit 1
fi

echo -n "$PASSWORD" | sha256sum | cut -d' ' -f1 > "$HASH_FILE"
chmod 600 "$HASH_FILE"

echo "Password set. Hash stored at $HASH_FILE"

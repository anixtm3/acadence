#!/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# Focus mode inherits whitelist enforcement and PATH-based blockers from common.sh.
acadence_start_mode "FOCUS" "🔴 Focus Mode" "true"

#!/bin/bash
# Acadence watchdog — whitelist enforcer for user-launched applications.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

MODE="$(acadence_normalize_mode "${1:-}")"
ALLOWED_SERIALIZED="${2:-}"
HEARTBEAT_FILE="/tmp/acadence_watchdog_heartbeat"
SELF_PID="$$"
SELF_PPID="$PPID"
CURRENT_USER="${USER:-$(id -un)}"

mapfile -t MODE_ALLOWED_APPS < <(printf '%s' "$ALLOWED_SERIALIZED" | tr ':' '\n' | sed '/^$/d')

PROTECTED_PROCESSES=(
    bash
    sh
    zsh
    dash
    fish
    sleep
    ps
    pgrep
    pkill
    kill
    cat
    sed
    nohup
    systemd
    dbus-daemon
    dbus-broker
    gnome-shell
    Xorg
    Xwayland
    wayland
    wayland-sessio
    notify-send
    zenity
    gsettings
)

is_protected_process() {
    local process_name="$1"
    acadence_is_allowed_process "$process_name" "${PROTECTED_PROCESSES[@]}"
}

is_acadence_runtime_process() {
    local process_name="$1"
    local process_args="$2"

    case "$process_name" in
        python|python3|electron|node)
            case "$process_args" in
                *"$ACADENCE_ROOT"*) return 0 ;;
            esac
            ;;
    esac

    return 1
}

is_desktop_session_process() {
    local process_args="$1"

    case "$process_args" in
        *gnome-session*|*gnome-shell*|*gsd-*|*dbus-daemon*|*dbus-broker*|*pipewire*|*wireplumber*|*xdg-desktop-portal*|*xdg-document-portal*|*gvfsd*|*ibus*|*at-spi*|*polkit*|*goa-daemon*|*dconf-service*|*tracker-*|*evolution-source-registry*|*ssh-agent*|*mutter*|*Xorg*|*Xwayland*)
            return 0
            ;;
    esac

    return 1
}

kill_if_disallowed() {
    local pid="$1"
    local process_name="$2"
    local process_args="$3"

    if is_protected_process "$process_name"; then
        return 0
    fi

    if is_acadence_runtime_process "$process_name" "$process_args"; then
        return 0
    fi

    if is_desktop_session_process "$process_args"; then
        return 0
    fi

    if acadence_is_allowed_process "$process_name" "${MODE_ALLOWED_APPS[@]}"; then
        return 0
    fi

    kill -9 "$pid" 2>/dev/null
}

echo "$SELF_PID" > "$WATCHDOG_FILE"

while true; do
    printf '%s\n' "$(date +%s)" > "$HEARTBEAT_FILE"

    mapfile -t user_pids < <(pgrep -u "$CURRENT_USER")

    for pid in "${user_pids[@]}"; do
        [ "$pid" = "$SELF_PID" ] && continue
        [ "$pid" = "$SELF_PPID" ] && continue

        process_name=$(ps -p "$pid" -o comm= 2>/dev/null | tr -d ' ')
        [ -z "$process_name" ] && continue

        process_args=$(ps -p "$pid" -o args= 2>/dev/null)
        [ -z "$process_args" ] && continue

        kill_if_disallowed "$pid" "$process_name" "$process_args"
    done

    sleep 1
done
#!/bin/bash

# Caffeine: manual idle/suspend inhibitor.
# Holds a systemd-logind inhibitor lock. Hypridle honors it, so dim, lock,
# dpms, and suspend are all paused while active. Released on logout/reboot.
#
# Usage: caffeine.sh toggle|on|off|status
#   status prints wayle custom-module JSON when active. It prints nothing
#   when inactive, which hides the bar module (hide-if-empty).

PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/caffeine.pid"

is_on() {
    [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

caffeine_on() {
    is_on && return
    # setsid makes it a process-group leader so caffeine_off can kill the
    # whole group (systemd-inhibit + its sleep child) in one shot.
    setsid systemd-inhibit --what=idle:sleep --who=caffeine \
        --why="manual caffeine toggle" --mode=block \
        sleep infinity >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
}

caffeine_off() {
    is_on && kill -- -"$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
}

case "${1:-status}" in
toggle) if is_on; then caffeine_off; else caffeine_on; fi ;;
on)     caffeine_on ;;
off)    caffeine_off ;;
status) is_on && printf '{"tooltip": "Caffeine on: idle and suspend inhibited"}\n' ;;
esac

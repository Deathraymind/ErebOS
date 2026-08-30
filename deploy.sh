#!/usr/bin/env bash
#
# deploy.sh — rebuild erebos NixOS hosts over SSH
#
# Usage:
#   ./deploy.sh                 # rebuild every host, in ORDER below
#   ./deploy.sh teleport caddy  # rebuild just these, in the order given
#   ./deploy.sh -n              # dry-activate (build + show the diff, no switch)
#   ./deploy.sh -n coredns      # dry-activate a single host
#
# Env toggles:
#   FLAKE=/etc/nixos ./deploy.sh      # point at a different flake (default: cwd)
#   FAIL_FAST=1 ./deploy.sh           # stop at the first host that fails
#
# Assumes the flake attribute name == host name (edit HOSTS if not), and that
# `deathraymind` can SSH in and sudo on each box.

set -uo pipefail

# --- config ------------------------------------------------------------------

SSH_USER="deathraymind"
FLAKE="${FLAKE:-.}"
FAIL_FAST="${FAIL_FAST:-0}"
ACTION="switch" # flipped to dry-activate by -n

# flake-attr  ->  IP
declare -A HOSTS=(
        [coredns]="192.168.1.15"
        [caddy]="192.168.1.10"
        [teleport]="192.168.1.11"
        [pelican]="192.168.1.50"
        ["pelican-wings"]="192.168.1.51"
        [vaultwarden]="192.168.1.53"
)

# default order when no hosts are named on the CLI.
# coredns first (name resolution current), edge/access next, app hosts last.
ORDER=(coredns caddy teleport pelican pelican-wings vaultwarden)

# flags passed to every rebuild — mirrors your manual command.
COMMON_FLAGS=(--use-remote-sudo --ask-sudo-password --show-trace)
# If this machine can't build a target's arch, build ON the target instead:
#   COMMON_FLAGS+=(--build-host "${SSH_USER}@<that-host-ip>")

# --- arg parsing -------------------------------------------------------------

targets=()
for arg in "$@"; do
        case "$arg" in
        -n | --dry) ACTION="dry-activate" ;;
        -h | --help)
                grep '^#' "$0" | sed 's/^#\{1,\} \{0,1\}//' | head -n 18
                exit 0
                ;;
        -*)
                echo "unknown flag: $arg" >&2
                exit 2
                ;;
        *)
                if [[ -z "${HOSTS[$arg]+x}" ]]; then
                        echo "unknown host: $arg" >&2
                        echo "known hosts: ${!HOSTS[*]}" >&2
                        exit 2
                fi
                targets+=("$arg")
                ;;
        esac
done
[[ ${#targets[@]} -eq 0 ]] && targets=("${ORDER[@]}")

# --- run ---------------------------------------------------------------------

declare -A RESULT
overall=0

for host in "${targets[@]}"; do
        ip="${HOSTS[$host]}"
        echo
        echo "======================================================================"
        echo ">>> ${host}  (${ip})  —  nixos-rebuild ${ACTION}"
        echo "======================================================================"

        if nixos-rebuild "${ACTION}" \
                --flake "${FLAKE}#${host}" \
                --target-host "${SSH_USER}@${ip}" \
                "${COMMON_FLAGS[@]}"; then
                RESULT[$host]="ok"
        else
                RESULT[$host]="FAILED"
                overall=1
                if [[ "$FAIL_FAST" == "1" ]]; then
                        echo "!!! ${host} failed — stopping (FAIL_FAST=1)" >&2
                        break
                fi
        fi
done

# --- summary -----------------------------------------------------------------

echo
echo "============================ summary ============================"
for host in "${targets[@]}"; do
        printf '  %-16s %s\n' "$host" "${RESULT[$host]:-skipped}"
done
echo "================================================================"
exit "$overall"

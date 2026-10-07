#!/bin/bash

# ==========================================
# CREATE RESTRICTED USER WITH RBASH (v2)
# Restricted Linux user with rbash — corrected version
#
# Author:   Charles Josiah (https://github.com/charles-josiah)
# Co-author: Fabio Ferreira (https://github.com/cwbffm)
# ==========================================

set -euo pipefail

# --- Helpers ---------------------------------------------------------------

log()  { printf '\033[1;32m%s\033[0m\n' "$*"; }
err()  { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
step() { printf '\n\033[1;36m[%s]\033[0m %s\n' "$1" "$2"; }

cleanup_on_fail() {
    local exit_code=$?
    if [ "${USER_CREATED:-0}" = "1" ]; then
        err "Failure during execution. Removing user '$USERNAME' to avoid an inconsistent state..."
        pkill -u "$USERNAME" 2>/dev/null || true
        userdel -r "$USERNAME" 2>/dev/null || true
        err "User removed. Fix the problem and run the script again."
    fi
    exit "$exit_code"
}
trap cleanup_on_fail EXIT

# --- Initial checks --------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    err "Run this script as root or with sudo."
    exit 1
fi

read -rp "Username: " USERNAME

# Validate username format (POSIX + hyphen)
if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    err "Invalid username. Use only lowercase letters, numbers, '_' or '-'."
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    err "User '$USERNAME' already exists."
    exit 1
fi

# --- User creation ---------------------------------------------------------

USER_CREATED=0

step "1/7" "Creating user..."
useradd -m -s /bin/rbash "$USERNAME"
USER_CREATED=1

echo
step "2/7" "Set the user password:"
if ! passwd "$USERNAME"; then
    err "Failed to set the password."
    exit 1
fi

HOME_DIR="/home/$USERNAME"
BIN_DIR="$HOME_DIR/bin"

# --- Restricted environment ------------------------------------------------

step "3/7" "Creating restricted environment..."

mkdir -p "$BIN_DIR"
chown "$USERNAME:$USERNAME" "$BIN_DIR"
chmod 755 "$BIN_DIR"

# --- Allowed commands ------------------------------------------------------
# NOTE: 'less' and 'more' are intentionally removed — both allow shell
#       escape via '!command' (e.g. less -> !/bin/sh).

ALLOWED_COMMANDS=(
    ls
    cat
    grep
    tail
    head
    date
    uptime
    df
    du
    free
    hostname
    whoami
    id
)

step "4/7" "Enabling commands..."

for CMD in "${ALLOWED_COMMANDS[@]}"; do
    CMD_PATH=$(command -v "$CMD" 2>/dev/null || true)

    if [ -n "$CMD_PATH" ]; then
        # Copy binaries instead of symlinks — prevents target swapping
        # and ensures the binary does not depend on an external PATH.
        cp -f "$CMD_PATH" "$BIN_DIR/$CMD"
        chown root:root "$BIN_DIR/$CMD"
        chmod 755 "$BIN_DIR/$CMD"
        log "  Allowed: $CMD -> $CMD_PATH"
    else
        err "  Not found: $CMD"
    fi
done

# --- RBASH configuration ---------------------------------------------------

step "5/7" "Configuring restricted shell..."

cat > "$HOME_DIR/.bash_profile" <<'EOF'
# Restricted environment — not editable by the user
PATH="$HOME/bin"
export PATH
readonly PATH

HISTFILE="$HOME/.bash_history"
export HISTFILE
readonly HISTFILE
HISTSIZE=500
export HISTSIZE

unset ENV
unset BASH_ENV

# Clear the terminal and show the banner only at login
clear
echo "======================================"
echo " Restricted Linux Environment"
echo "======================================"
echo
echo "Available commands:"
ls "$HOME/bin"
echo
EOF

cat > "$HOME_DIR/.bashrc" <<'EOF'
PATH="$HOME/bin"
export PATH
readonly PATH

HISTFILE="$HOME/.bash_history"
export HISTFILE
readonly HISTFILE

unset ENV
unset BASH_ENV
EOF

# --- Security permissions --------------------------------------------------
# The home directory must NOT be writable by the user, otherwise they could
# delete and recreate .bash_profile/.bashrc with arbitrary content
# (which would void the whole protection).

chown root:root "$HOME_DIR"
chmod 755 "$HOME_DIR"

chown root:root "$HOME_DIR/.bash_profile" "$HOME_DIR/.bashrc"
chmod 444 "$HOME_DIR/.bash_profile" "$HOME_DIR/.bashrc"

# The history lives in its own file, writable by the user.
touch "$HOME_DIR/.bash_history"
chown "$USERNAME:$USERNAME" "$HOME_DIR/.bash_history"
chmod 600 "$HOME_DIR/.bash_history"

# --- /etc/shells -------------------------------------------------------------

step "6/7" "Checking shell..."

touch /etc/shells 2>/dev/null || true
if ! grep -qx "/bin/rbash" /etc/shells 2>/dev/null; then
    echo "/bin/rbash" >> /etc/shells
fi

# --- Automatic test ----------------------------------------------------------

step "7/7" "Testing access..."

if su - "$USERNAME" -c 'ls "$HOME/bin" >/dev/null 2>&1'; then
    log "  Test OK: restricted login working."
else
    err "  Test FAILED."
    exit 1
fi

# Success — disable the rollback
USER_CREATED=0

# --- Final report -------------------------------------------------------------

echo
echo "======================================"
echo " USER CREATED"
echo "======================================"
echo
echo "User    : $USERNAME"
echo "Home    : $HOME_DIR  (root:root 755 — not writable by the user)"
echo "Shell   : /bin/rbash"
echo "PATH    : $BIN_DIR"
echo
echo "Allowed commands:"
ls -1 "$BIN_DIR"
echo
echo "Manual test:"
echo "  su - $USERNAME"
echo
echo "To remove later (if needed):"
echo "  userdel -r $USERNAME"

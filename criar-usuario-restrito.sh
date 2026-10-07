#!/bin/bash

# ==========================================
# CRIAR USUÁRIO RESTRITO COM RBASH (v2)
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
        err "Falha durante a execução. Removendo usuário '$USERNAME' para evitar estado inconsistente..."
        pkill -u "$USERNAME" 2>/dev/null || true
        userdel -r "$USERNAME" 2>/dev/null || true
        err "Usuário removido. Corrija o problema e execute novamente."
    fi
    exit "$exit_code"
}
trap cleanup_on_fail EXIT

# --- Verificações iniciais -------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    err "Execute como root ou usando sudo."
    exit 1
fi

read -rp "Nome do usuário: " USERNAME

# Valida formato do nome (POSIX + hífen)
if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    err "Nome de usuário inválido. Use apenas letras minúsculas, números, '_' ou '-'."
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    err "Usuário '$USERNAME' já existe."
    exit 1
fi

# --- Criação do usuário ----------------------------------------------------

USER_CREATED=0

step "1/7" "Criando usuário..."
useradd -m -s /bin/rbash "$USERNAME"
USER_CREATED=1

echo
step "2/7" "Defina a senha do usuário:"
if ! passwd "$USERNAME"; then
    err "Falha ao definir a senha."
    exit 1
fi

HOME_DIR="/home/$USERNAME"
BIN_DIR="$HOME_DIR/bin"

# --- Ambiente restrito -----------------------------------------------------

step "3/7" "Criando ambiente restrito..."

mkdir -p "$BIN_DIR"
chown "$USERNAME:$USERNAME" "$BIN_DIR"
chmod 755 "$BIN_DIR"

# --- Comandos permitidos ---------------------------------------------------
# ATENÇÃO: removidos 'less' e 'more' — ambos permitem escape para shell
#          via '!comando' (ex.: less -> !/bin/sh).

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

step "4/7" "Liberando comandos..."

for CMD in "${ALLOWED_COMMANDS[@]}"; do
    CMD_PATH=$(command -v "$CMD" 2>/dev/null || true)

    if [ -n "$CMD_PATH" ]; then
        # Copia os binários em vez de symlink — impede troca do alvo
        # e garante que o binário não dependa de PATH externo.
        cp -f "$CMD_PATH" "$BIN_DIR/$CMD"
        chown root:root "$BIN_DIR/$CMD"
        chmod 755 "$BIN_DIR/$CMD"
        log "  Liberado: $CMD -> $CMD_PATH"
    else
        err "  Não encontrado: $CMD"
    fi
done

# --- Configuração do RBASH -------------------------------------------------

step "5/7" "Configurando shell restrito..."

cat > "$HOME_DIR/.bash_profile" <<'EOF'
# Ambiente restrito — não editável pelo usuário
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

# Limpa o terminal e mostra o banner apenas no login
clear
echo "======================================"
echo " Ambiente Linux Restrito"
echo "======================================"
echo
echo "Comandos disponíveis:"
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

# --- Permissões de segurança ----------------------------------------------
# O diretório home NÃO pode ser gravável pelo usuário, senão ele apaga
# e recria .bash_profile/.bashrc com conteúdo livre (anula a proteção).

chown root:root "$HOME_DIR"
chmod 755 "$HOME_DIR"

chown root:root "$HOME_DIR/.bash_profile" "$HOME_DIR/.bashrc"
chmod 444 "$HOME_DIR/.bash_profile" "$HOME_DIR/.bashrc"

# O histórico fica em arquivo próprio, gravável pelo usuário.
touch "$HOME_DIR/.bash_history"
chown "$USERNAME:$USERNAME" "$HOME_DIR/.bash_history"
chmod 600 "$HOME_DIR/.bash_history"

# --- /etc/shells ------------------------------------------------------------

step "6/7" "Verificando shell..."

touch /etc/shells 2>/dev/null || true
if ! grep -qx "/bin/rbash" /etc/shells 2>/dev/null; then
    echo "/bin/rbash" >> /etc/shells
fi

# --- Teste automático -------------------------------------------------------

step "7/7" "Testando acesso..."

if su - "$USERNAME" -c 'ls "$HOME/bin" >/dev/null 2>&1'; then
    log "  Teste OK: login restrito funcionando."
else
    err "  Teste FALHOU."
    exit 1
fi

# Sucesso — desativa o rollback
USER_CREATED=0

# --- Relatório final -------------------------------------------------------

echo
echo "======================================"
echo " USUÁRIO CRIADO"
echo "======================================"
echo
echo "Usuário : $USERNAME"
echo "Home    : $HOME_DIR  (root:root 755 — não gravável pelo usuário)"
echo "Shell   : /bin/rbash"
echo "PATH    : $BIN_DIR"
echo
echo "Comandos permitidos:"
ls -1 "$BIN_DIR"
echo
echo "Teste manual:"
echo "  su - $USERNAME"
echo
echo "Remover depois (se necessário):"
echo "  userdel -r $USERNAME"

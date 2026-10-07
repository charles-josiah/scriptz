# criar-usuario-restrito.sh

> Cria um usuário Linux com shell restrito (`rbash`), expondo **somente** uma lista branca de comandos de leitura/monitoramento — ideal para kiosks, ambientes de suporte, acesso temporário de fornecedores e auditores.
>
> **Developed by** [Charles Josiah](https://github.com/charles-josiah) **in collaboration with** [Fabio Ferreira](https://github.com/cwbffm).

---

## 📋 Índice

- [Visão geral](#-visão-geral)
- [Requisitos](#-requisitos)
- [Uso](#-uso)
- [O que o script faz](#-o-que-o-script-faz)
- [Comandos permitidos](#-comandos-permitidos)
- [Modelo de segurança](#-modelo-de-segurança)
- [Melhorias sobre a versão original](#-melhorias-sobre-a-versão-original)
- [Limitações conhecidas](#-limitações-conhecidas)
- [Remover o usuário](#-remover-o-usuário)
- [Licença](#-licença)

---

## 🧭 Visão geral

O script automatiza a criação de um usuário **restrito** no Linux:

| Item | Valor |
|------|-------|
| Shell | `/bin/rbash` (restricted bash) |
| Home | `/home/<usuário>` — **não gravável** pelo usuário (`root:root 755`) |
| PATH | `$HOME/bin` — apenas comandos da lista branca, `readonly` |
| Binários | **cópias reais** (não symlinks), pertencentes a `root` |
| Config | `.bash_profile` / `.bashrc` → `root:root 444` |
| Rollback | automático em caso de falha (trap `EXIT`) |

---

## ⚙️ Requisitos

- Linux com `bash`, `useradd`, `passwd` (qualquer distro RHEL/Debian/Ubuntu com ajustes mínimos)
- Execução como **root** ou via `sudo`
- `rbash` disponível — normalmente vem como link do `bash`:
  ```bash
  # Verificar / habilitar (Fedora/RHEL/CentOS)
  ln -sf /bin/bash /bin/rbash   # caso não exista
  ```

---

## 🚀 Uso

```bash
git clone https://github.com/charles-josiah/scriptz.git
cd scriptz
chmod +x criar-usuario-restrito.sh
sudo ./criar-usuario-restrito.sh
```

Saída esperada:

```text
Nome do usuário: suporte01

[1/7] Criando usuário...
[2/7] Defina a senha do usuário:
New password: ********
Retype new password: ********
passwd: password updated successfully

[3/7] Criando ambiente restrito...
[4/7] Liberando comandos...
  Liberado: ls -> /usr/bin/ls
  Liberado: cat -> /usr/bin/cat
  ...

[7/7] Testando acesso...
  Teste OK: login restrito funcionando.

======================================
 USUÁRIO CRIADO
======================================
```

Entrar no usuário:

```bash
su - suporte01
```

---

## 🧩 O que o script faz

1. **Valida** execução como root e formato do nome de usuário (regex POSIX).
2. **Cria** o usuário com `useradd -m -s /bin/rbash`.
3. **Define** a senha interativamente (`passwd`).
4. **Monta** `$HOME/bin` com cópias dos binários permitidos (`cp`, não symlink).
5. **Instala** `.bash_profile` e `.bashrc` com `PATH` somente-leitura e limpeza de variáveis de ambiente perigosas (`ENV`, `BASH_ENV`).
6. **Trava** permissões: home e configs pertencem a `root` e não podem ser alterados pelo usuário.
7. **Registra** `/bin/rbash` em `/etc/shells` e **testa** o login automaticamente.
8. Em caso de **qualquer falha**, o script **remove o usuário** criado (rollback via `trap`).

---

## 📦 Comandos permitidos

Por padrão, a lista branca é:

| Comando | Uso |
|---------|-----|
| `ls` | Listar arquivos |
| `cat` | Exibir conteúdo de arquivos |
| `grep` | Buscar padrões |
| `tail` / `head` | Início/fim de arquivos |
| `date` | Data e hora |
| `uptime` | Tempo ligado e carga |
| `df` | Espaço em disco |
| `du` | Tamanho de diretórios |
| `free` | Memória |
| `hostname` | Nome do host |
| `whoami` | Usuário atual |
| `id` | UID/GID/grupos |

Para **adicionar ou remover** comandos, edite o array `ALLOWED_COMMANDS` no script:

```bash
ALLOWED_COMMANDS=(
    ls
    cat
    grep
    # ... adicione aqui
)
```

> ⚠️ Veja [Limitações conhecidas](#-limitações-conhecidas) antes de adicionar qualquer coisa.

---

## 🔒 Modelo de segurança

```text
Usuário (rbash)
   │
   ├── PATH = $HOME/bin (readonly)
   │      └── cópias root-owned dos binários permitidos
   │
   ├── Home = root:root 755  → usuário NÃO pode alterar configs
   │      ├── .bash_profile  (root:root 444)
   │      ├── .bashrc        (root:root 444)
   │      └── .bash_history  (user:user 600 — apenas histórico)
   │
   └── Variáveis de escape removidas: ENV, BASH_ENV
```

**Princípios aplicados:**

- **Menor privilégio** — só o estritamente necessário.
- **Defesa em profundidade** — `rbash` + PATH travado + configs imutáveis + binários root-owned.
- **Falha segura** — rollback automático evita usuários meio-configurados.
- **Teste obrigatório** — o script só reporta sucesso após validar o login.

---

## ✅ Melhorias sobre a versão original

| # | Problema original | Correção |
|---|-------------------|----------|
| 1 | Home `750 user:user` permitia apagar/recriar `.bash_profile` e anular toda a proteção | Home agora é `root:root 755` (não gravável pelo usuário) |
| 2 | `less`/`more` na lista — ambos permitem escape para shell via `!comando` | Removidos da lista branca |
| 3 | Symlinks podiam ser alvo de troca | Cópias reais dos binários, `chown root:root` |
| 4 | Sem validação do nome de usuário | Regex `^[a-z_][a-z0-9_-]{0,31}$` |
| 5 | Falha em `passwd` deixava usuário meio-criado | `trap EXIT` com rollback automático |
| 6 | `/etc/shells` inexistente derrubava o script (`set -e`) | `touch` + `grep 2>/dev/null` |
| 7 | `HISTFILE` declarado `readonly` sem valor definido | Definido, exportado e com `HISTSIZE=500` |
| 8 | Sem validação do resultado | Teste automático de login ao final |

---

## ⚠️ Limitações conhecidas

`rbash` é uma **barreira leve**, não um sandbox. Leia antes de usar em produção:

- **Nunca adicione** comandos com capacidade de executar shell: `awk` (com `system()`), `sed` com flag `e`, `find -exec`, `xargs`, `man`, `vi/vim`, `python`, `perl`, `less`, `more`, `ssh`, `scp`.
- **Escalada via kernel**: falhas de kernel (Dirty Pipe, etc.) ignoram qualquer restrição de shell.
- **Ataques físicos/console**: se o usuário tem acesso à consola, `Ctrl+C`/`Ctrl+Z` e signal handling em `rbash` têm comportamento limitado mas não invulnerável.
- **Para isolamento real**, use uma das opções abaixo (em ordem de preferência):
  1. **Container** (Docker/Podman) com user namespace e read-only rootfs;
  2. **`chroot`** para um filesystem mínimo;
  3. **`sudo` com allowlist** (`sudo -l`) em vez de shell restrito;
  4. Contas de serviço com **chave SSH forçada** + `ForceCommand`.

---

## 🧹 Remover o usuário

```bash
sudo userdel -r suporte01
```

Se o usuário estiver logado, encerre as sessões antes:

```bash
sudo pkill -u suporte01
sudo userdel -r suporte01
```

---

## 👥 Authors and contributors

| Role | Person | GitHub |
|------|--------|--------|
| Author | Charles Josiah | [@charles-josiah](https://github.com/charles-josiah) |
| Co-author / development contributor | **Fabio Ferreira** | [@cwbffm](https://github.com/cwbffm) |

> Special thanks to **Fabio Ferreira** ([github.com/cwbffm](https://github.com/cwbffm)) for co-developing this script.

---

## 📄 Licença

Distribuído sob os termos do repositório **[scriptz](https://github.com/charles-josiah/scriptz)**.
Fornecido para fins de referência — **teste em ambiente não-produção antes de usar em produção.**

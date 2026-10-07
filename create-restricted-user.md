# create-restricted-user.sh

> Creates a Linux user with a restricted shell (`rbash`), exposing **only** a whitelisted set of read-only/monitoring commands — ideal for kiosks, support environments, and temporary vendor/auditor access.
>
> **Developed by** [Charles Josiah](https://github.com/charles-josiah) **in collaboration with** [Fabio Ferreira](https://github.com/cwbffm).

---

## 📋 Table of contents

- [Overview](#-overview)
- [Requirements](#-requirements)
- [Usage](#-usage)
- [What the script does](#-what-the-script-does)
- [Allowed commands](#-allowed-commands)
- [Security model](#-security-model)
- [Improvements over the original version](#-improvements-over-the-original-version)
- [Known limitations](#-known-limitations)
- [Removing the user](#-removing-the-user)
- [Authors and contributors](#-authors-and-contributors)
- [License](#-license)

---

## 🧭 Overview

The script automates the creation of a **restricted** Linux user:

| Item | Value |
|------|-------|
| Shell | `/bin/rbash` (restricted bash) |
| Home | `/home/<user>` — **not writable** by the user (`root:root 755`) |
| PATH | `$HOME/bin` — whitelist commands only, `readonly` |
| Binaries | **real copies** (not symlinks), owned by `root` |
| Config | `.bash_profile` / `.bashrc` → `root:root 444` |
| Rollback | automatic on any failure (trap `EXIT`) |

---

## ⚙️ Requirements

- Linux with `bash`, `useradd`, `passwd` (any RHEL/Debian/Ubuntu distro with minimal adjustments)
- Must run as **root** or via `sudo`
- `rbash` available — usually shipped as a symlink to `bash`:
  ```bash
  # Check / enable (Fedora/RHEL/CentOS)
  ln -sf /bin/bash /bin/rbash   # if it does not exist
  ```

---

## 🚀 Usage

```bash
git clone https://github.com/charles-josiah/scriptz.git
cd scriptz
chmod +x create-restricted-user.sh
sudo ./create-restricted-user.sh
```

Expected output:

```text
Username: suporte01

[1/7] Creating user...
[2/7] Set the user password:
New password: ********
Retype new password: ********
passwd: password updated successfully

[3/7] Creating restricted environment...
[4/7] Enabling commands...
  Allowed: ls -> /usr/bin/ls
  Allowed: cat -> /usr/bin/cat
  ...

[7/7] Testing access...
  Test OK: restricted login working.

======================================
 USER CREATED
======================================
```

Log in as the new user:

```bash
su - suporte01
```

---

## 🧩 What the script does

1. **Validates** that it is running as root and that the username format is valid (POSIX regex).
2. **Creates** the user with `useradd -m -s /bin/rbash`.
3. **Sets** the password interactively (`passwd`).
4. **Builds** `$HOME/bin` with copies of the allowed binaries (`cp`, not symlinks).
5. **Installs** `.bash_profile` and `.bashrc` with a read-only `PATH` and dangerous environment variables cleared (`ENV`, `BASH_ENV`).
6. **Locks down** permissions: home and configs are owned by `root` and cannot be changed by the user.
7. **Registers** `/bin/rbash` in `/etc/shells` and **tests** the login automatically.
8. On **any failure**, the script **removes the created user** (rollback via `trap`).

---

## 📦 Allowed commands

By default, the whitelist is:

| Command | Purpose |
|---------|---------|
| `ls` | List files |
| `cat` | Show file contents |
| `grep` | Search patterns |
| `tail` / `head` | Start/end of files |
| `date` | Date and time |
| `uptime` | Uptime and load average |
| `df` | Disk space |
| `du` | Directory sizes |
| `free` | Memory usage |
| `hostname` | Host name |
| `whoami` | Current user |
| `id` | UID/GID/groups |

To **add or remove** commands, edit the `ALLOWED_COMMANDS` array in the script:

```bash
ALLOWED_COMMANDS=(
    ls
    cat
    grep
    # ... add here
)
```

> ⚠️ See [Known limitations](#-known-limitations) before adding anything.

---

## 🔒 Security model

```text
User (rbash)
   │
   ├── PATH = $HOME/bin (readonly)
   │      └── root-owned copies of allowed binaries
   │
   ├── Home = root:root 755  → user CANNOT change configs
   │      ├── .bash_profile  (root:root 444)
   │      ├── .bashrc        (root:root 444)
   │      └── .bash_history  (user:user 600 — history only)
   │
   └── Escape variables removed: ENV, BASH_ENV
```

**Principles applied:**

- **Least privilege** — only what is strictly necessary.
- **Defense in depth** — `rbash` + locked PATH + immutable configs + root-owned binaries.
- **Fail-safe** — automatic rollback prevents half-configured users.
- **Mandatory test** — the script only reports success after validating the login.

---

## ✅ Improvements over the original version

| # | Original problem | Fix |
|---|------------------|-----|
| 1 | Home `750 user:user` allowed deleting/recreating `.bash_profile`, voiding all protection | Home is now `root:root 755` (not writable by the user) |
| 2 | `less`/`more` on the list — both allow shell escape via `!command` | Removed from the whitelist |
| 3 | Symlinks could be swapped | Real copies of the binaries, `chown root:root` |
| 4 | No username validation | Regex `^[a-z_][a-z0-9_-]{0,31}$` |
| 5 | `passwd` failure left a half-created user | `trap EXIT` with automatic rollback |
| 6 | Missing `/etc/shells` crashed the script (`set -e`) | `touch` + `grep 2>/dev/null` |
| 7 | `HISTFILE` declared `readonly` without a value | Defined, exported, with `HISTSIZE=500` |
| 8 | No result validation | Automatic login test at the end |

---

## ⚠️ Known limitations

`rbash` is a **light barrier**, not a sandbox. Read this before using it in production:

- **Never add** commands capable of running a shell: `awk` (with `system()`), `sed` with the `e` flag, `find -exec`, `xargs`, `man`, `vi/vim`, `python`, `perl`, `less`, `more`, `ssh`, `scp`.
- **Kernel escalation**: kernel vulnerabilities (Dirty Pipe, etc.) bypass any shell restriction.
- **Physical/console attacks**: if the user has console access, `Ctrl+C`/`Ctrl+Z` and signal handling in `rbash` are limited but not invulnerable.
- **For real isolation**, use one of the options below (in order of preference):
  1. **Container** (Docker/Podman) with user namespace and read-only rootfs;
  2. **`chroot`** into a minimal filesystem;
  3. **`sudo` with an allowlist** (`sudo -l`) instead of a restricted shell;
  4. Service accounts with **forced SSH keys** + `ForceCommand`.

---

## 🧹 Removing the user

```bash
sudo userdel -r suporte01
```

If the user is logged in, end the sessions first:

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

## 📄 License

Distributed under the terms of the **[scriptz](https://github.com/charles-josiah/scriptz)** repository.
Provided for reference purposes only — **test in a non-production environment before using in production.**

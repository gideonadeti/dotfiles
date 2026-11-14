# dotfiles

[![ci](https://github.com/gideonadeti/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/gideonadeti/dotfiles/actions/workflows/ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

My shell, tmux, git, and SSH configuration, kept in one place and installed with
symlinks. A new machine goes from bare to familiar in two commands.

## Quick start

```bash
git clone https://github.com/gideonadeti/dotfiles.git ~/dotfiles
cd ~/dotfiles

./bootstrap.sh      # install packages, oh-my-zsh, and plugins
./install.sh        # back up existing files, then symlink these in
exec zsh
```

Preview before changing anything:

```bash
./install.sh --dry-run
```

Roll back:

```bash
./install.sh --uninstall
```

## What is in here

```
zsh/
  .zshrc              tiny loader; sources the modules in order
  00-omz.zsh          oh-my-zsh theme and plugins
  10-aliases.zsh      personal aliases
  20-env.zsh          PATH and tool integrations
  30-functions.zsh    marco/polo, mkcd, newest, pidwait
  90-local.zsh        machine-specific overrides (gitignored)
bash/
  .bashrc
  .bash_profile
profile/
  .profile
tmux/
  .tmux.conf
git/
  .gitconfig
  ignore
  hooks/
    pre-commit
ssh/
  config              template; includes config.local
bin/
  retry               run a command until it fails
  waitport            wait for a TCP port to open
install.sh
bootstrap.sh
tests/
  install-test.sh
```

The shell config is split into modules so that each piece has one job. The loader
is intentionally boring: it resolves the repository path from its own symlink and
sources `zsh/*.zsh` in filename order. `90-local.zsh` always loads last, so
machine-specific settings win.

## Safety model

Dotfiles installers are dangerous because they write to your home directory.
This one follows three rules.

**Nothing is deleted.** An existing real file is moved into
`~/.dotfiles-backup-<timestamp>/` before the symlink is created. `--uninstall`
restores the most recent backup.

**Nothing happens silently.** `--dry-run` prints every action and changes
nothing. The installer is idempotent, so running it twice is harmless.

**Secrets stay out of git.** Machine-specific shell settings belong in
`zsh/90-local.zsh`; real SSH hosts belong in `~/.ssh/config.local`. Both are
gitignored, and the installer creates them if they are missing.

## Secret scanning

A pre-commit hook (`git/hooks/pre-commit`, installed globally through
`core.hooksPath`) blocks staged changes that look like credentials: AWS keys,
GitHub and Slack tokens, Stripe live keys, private keys, and generic
`token = "..."` / `password = "..."` assignments.

It prints the file and line, never the value. To bypass it for one commit:

```bash
SKIP_SECRET_SCAN=1 git commit -m "..."
```

Secrets still belong in `zsh/90-local.zsh`, `~/.ssh/config.local`, or an
untracked `.env`, not in a tracked file.

## SSH

The tracked `ssh/config` is a template:

```
Include ~/.ssh/config.local

Host *
    AddKeysToAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Your real hosts go in `~/.ssh/config.local`. The installer migrates an existing
`~/.ssh/config` there before linking the template, so nothing is lost.

## Requirements

- `bash` for the installer and bootstrap
- `zsh` for the shell configuration
- `git` and `curl` for the bootstrap
- `dnf`, `apt-get`, or Homebrew, depending on the machine

`bootstrap.sh` installs `git`, `zsh`, `tmux`, `fzf`, `ripgrep`, `fd`, `jq`,
`curl`, `htop`, and `shellcheck`, then installs oh-my-zsh and the custom plugins
this config uses (`alias-tips` and `pnpm`). The optional tool integrations in
`20-env.zsh` (NVM, pnpm, Google Cloud SDK) are guarded, so a missing tool does
not break the shell.

## Test

The installer is tested against a throwaway `$HOME`:

```bash
./tests/install-test.sh
```

It checks the dry run, the symlinks, SSH host migration, idempotency, shell
startup, and rollback. CI runs the same test plus ShellCheck on every push.

## License

MIT — see [LICENSE](LICENSE).

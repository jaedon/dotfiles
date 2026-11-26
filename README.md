# dotfiles

Chezmoi source for macOS (Apple Silicon) and Linux devcontainers. It manages shell, Git, mise, SSH, OpenCode, and Homebrew packages.

## Bootstrap

Bootstrap directly from GitHub. The installer installs chezmoi and applies the `jaedon/dotfiles` repo:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply jaedon
```

For unattended setup, set identity values explicitly:

```sh
DOTFILES_NAME="Jaedon Shin" DOTFILES_EMAIL="jaedon.shin@gmail.com" \
  sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply jaedon
```

- In VS Code, open the repository in the provided devcontainer; `postCreateCommand` runs the init/apply automatically.
- Apply needs network access for zsh plugin archives and tool installs.
- Homebrew packages are macOS-only; Linux tools come from mise.

## Layout

- `dot_*`, `private_*`, and `*.tmpl`: rendered targets under `$HOME` (for example, `dot_zshrc.tmpl` → `~/.zshrc`).
- `.chezmoidata.toml` and `.chezmoidata/packages.yaml`: zsh plugin versions and macOS package lists.
- `.chezmoiexternal.toml.tmpl`: zsh plugin archives.
- `.chezmoiignore`: keeps source-only docs out of `$HOME` when applying.
- `.chezmoiscripts/`: apply hooks, ordered by filename prefix.
- `dot_config/`: Git, mise, and OpenCode config.
- `.devcontainer/`: Ubuntu 24.04 Linux environment.

## Apply flow

`chezmoi apply` installs mise first, then installs changed Homebrew packages (macOS) and mise tools, then regenerates zsh completions and refreshes `zcompdump`. See `AGENTS.md` for ordering details and gotchas.

## Verify

```sh
chezmoi doctor
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi verify --exclude scripts
chezmoi cat dot_zshrc.tmpl
```

Use `--exclude scripts` with `verify` because `run_after_*` hooks are always pending.

## Configuration

- `DOTFILES_NAME` and `DOTFILES_EMAIL` set Git identity. See `AGENTS.md` for template precedence.
- `DOTFILES_LMSTUDIO_URL` sets the LM Studio base URL used by OpenCode. It defaults to `http://127.0.0.1:1234/v1` on macOS and `http://mac.lan:1234/v1` elsewhere.
- Tool versions are declared in `dot_config/mise/config.toml`. Set `MISE_VERSION` to skip mise self-update.
- Keep host-specific SSH hosts and keys in untracked `~/.ssh/config.d/*.conf`. Store secrets outside the repo.

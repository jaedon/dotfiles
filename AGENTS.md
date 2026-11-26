# AGENTS.md

## Repo model
- This repo is a chezmoi source tree. Treat files under `$HOME` as generated output and edit only this source tree.
- `AGENTS.md` and `README.md` stay source-only through `.chezmoiignore`.
- Verification is chezmoi-only: `chezmoi diff`, `chezmoi apply --dry-run --verbose`, `chezmoi cat <source-file>`, `chezmoi doctor`.
- Use `chezmoi verify --exclude scripts`; plain `verify` fails while `run_after_*` scripts are pending. `--dry-run` previews scripts without running them.
- Scripts are excluded from `diff` and `status`; inspect `.chezmoiscripts/` directly. Check rendered syntax with `chezmoi execute-template -f .chezmoiscripts/<script> | bash -n`.
- Test the config template with `chezmoi execute-template --init ... < .chezmoi.toml.tmpl`. After changing it, run `chezmoi init` to regenerate `~/.config/chezmoi/chezmoi.toml`.

## Inputs
- `.chezmoi.toml.tmpl`: `DOTFILES_NAME` / `DOTFILES_EMAIL` > stored config > TTY prompt > defaults. Set the env vars for noninteractive `chezmoi init`.
- `DOTFILES_LMSTUDIO_URL` sets the OpenCode LM Studio base URL; it never prompts and defaults to `http://127.0.0.1:1234/v1` on macOS, `http://mac.lan:1234/v1` elsewhere.
- Templates branch on `.chezmoi.os`. Keep macOS-only logic guarded; check the Linux path in `.devcontainer`.

## Apply flow
- `chezmoi apply` runs `.chezmoiscripts/` in filename order: mise bootstrap, on-change installs, completion generation, zcompdump refresh. Read the target script before changing any step; its header records the gotchas.

## Conventions
- Change macOS packages in `.chezmoidata/packages.yaml` and plugin pins in `.chezmoidata.toml`.
- Store host-specific SSH hosts and keys in untracked `~/.ssh/config.d/*.conf`.
- GitHub credentials use `mise exec gh -- gh auth git-credential`. `git cleanup` previews only; removal is `git clean -fxd`.
- Commit with Conventional Commits.

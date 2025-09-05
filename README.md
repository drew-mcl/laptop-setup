# Laptop Setup & Dotfiles

Opinionated, idempotent laptop setup with GNU Stow–managed dotfiles and a Makefile-driven workflow. Targets macOS with Homebrew, but keeps pieces modular.

Highlights
- Dotfiles for: git, ssh, zsh (oh-my-zsh), curl, gradle
- Pre‑brew bootstrap to configure git/curl before using Homebrew (corp-friendly)
- Brew-managed CLI tools and apps (terraform, consul, Ghostty, Obsidian, IntelliJ, VS Code, JDKs, Go, Python, draw.io)
- SSH key setup helper and sensible SSH defaults
- Dev directories bootstrap (repos/...)
- Custom hooks for per‑laptop/internal tooling
 - GitLab CLI (glab) with helpful aliases

Quick Start
1) Ensure Homebrew is installed (your internal tool). Then:

   - Copy `.env.example` to `.env` and adjust values.
   - Run: `make bootstrap-prebrew` to set git/curl and basic dirs.
   - Run: `make brew-core` then `make brew-dev` (or `make brew-all`).
   - Run: `make stow` to link dotfiles.
   - Optional: `make oh-my-zsh`, `make ssh`, `make macos`.
   - Or run end-to-end: `bash scripts/bootstrap.sh` then `make install`.

Make Targets
- `bootstrap`: Full setup: pre-brew, brew-all, stow, VS Code, jenv.
- `bootstrap-prebrew`: Configure git and curl before using brew; create dev dirs.
- `brew-core`: Install core CLI (stow, git-delta, jq, ripgrep, etc.).
- `brew-dev`: Install dev tools/apps (terraform, consul, Ghostty, Obsidian, IntelliJ, VS Code, JDKs, Go, Python, draw.io).
- `brew-all`: Core + Dev.
- `stow`: Symlink dotfiles from `dotfiles/` into `$HOME`.
- `oh-my-zsh`: Install oh-my-zsh without changing your shell automatically.
- `ssh`: Generate ed25519 key, add to agent, print pubkey.
- `macos`: Apply opinionated macOS defaults (safe/standard tweaks).
- `custom`: Run optional custom scripts for other laptops.
 - `install`: Core + Dev + stow + VS Code extensions + jenv setup.
 - `refresh`: Update brew packages and restow.
 - `vscode`: Install the curated extensions list.
 - `java-setup`: Add installed JDKs to jenv and set global.
 - `git-monorepo REPO=/path`: Apply repo-local performance tuning for huge repos.

Java JDKs
- Always uses Oracle JDKs.
- Brewfiles:
  - `brew/Brewfile.base` for core CLI/tooling (adds ansible, kubectl, helm).
  - `brew/Brewfile.langs` for runtimes and Oracle JDKs.
  - `brew/Brewfile.apps` for GUI apps.

Stow Packages
- `git`, `ssh`, `zsh`, `curl`, `gradle`, `ghostty`, `vscode`, `glab` (each a folder in `dotfiles/`).

Customizations
- Put laptop/company‑specific steps in `custom/` and invoke with `make custom`.

Safety & Re-runs
- Scripts are idempotent. Re-run targets safely to reconcile state.

GitLab
- CLI: `glab` is installed via brew. Authenticate with `glab auth login`.
- Zsh aliases (if `glab` present):
  - `gmr`: create MR from current branch (`--fill --remove-source-branch`).
  - `gml`: list MRs assigned to you.
  - `gms`: MR status.
  - `gci`: view CI pipeline.

Git Workflow Helpers
- `git diverge [remote]`: Show Ahead/Behind vs default branch of remote (default `origin`).
- `git prep-merge [remote]`: Ensure clean tree, show divergence, and open an interactive rebase onto the default branch (squash to one commit before merge).
- `git sync-default [remote]`: Fetch and rebase onto the default branch.

VS Code
- Settings are stowed to `~/Library/Application Support/Code/User/settings.json` (macOS).
- `make vscode` creates a user-writable `code` CLI symlink and installs extensions in `vscode/extensions.txt`.

Ghostty
- Config is stowed to `~/.config/ghostty/config`.

Quality-of-Life Helpers
- `code-dotfiles`: Opens this repo in VS Code (auto-detects path or use `DOTFILES_REPO_DIR`).
- `sshx`: FZF SSH host picker based on `~/.ssh/config*` entries.
- `ssh-host <host> [--user u] [--port p] [--proxyjump j]`: Generates per-host key and `config.d/<host>.conf`.
- `repo`: Fuzzy browse + clone GitHub/GitLab repos into `~/repos/{work,personal}` and cd.
- `aa`: FZF alias browser, inserts the chosen alias expansion into your prompt.
- `m`: Run `make` from the nearest parent with a Makefile.
- `mt`: FZF-choose `make` target from the nearest Makefile, then run it.
- `gpm1`: Non-interactive squash of your branch to one commit onto default branch.

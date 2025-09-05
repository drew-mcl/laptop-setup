SHELL := /bin/bash
.DEFAULT_GOAL := help

DOTFILES_DIR := $(CURDIR)/dotfiles
STOW_PACKAGES := git zsh ssh curl gradle ghostty vscode glab

BREW := brew
BREW_DIR := $(CURDIR)/brew
BREWFILE_BASE := $(BREW_DIR)/Brewfile.base
BREWFILE_APPS := $(BREW_DIR)/Brewfile.apps
BREWFILE_LANGS := $(BREW_DIR)/Brewfile.langs

.PHONY: help bootstrap bootstrap-prebrew brew-core brew-dev brew-all install dotfiles refresh vscode java-setup git-monorepo stow unstow oh-my-zsh dirs ssh macos custom doctor

help:
	@echo "Targets:"
	@echo "  bootstrap          - Full setup: pre-brew, brew-all, stow, vscode, java"
	@echo "  bootstrap-prebrew  - Configure git/curl before using brew; create dirs"
	@echo "  brew-core          - Install core CLI (stow, delta, jq, rg, etc.)"
	@echo "  brew-dev           - Install dev toolchain and apps (JDKs, terraform, etc.)"
	@echo "  brew-all           - Core + Dev"
	@echo "  stow               - Symlink dotfiles into \\$$HOME"
	@echo "  unstow             - Remove symlinks for all stow packages"
	@echo "  oh-my-zsh          - Install oh-my-zsh (non-interactive)"
	@echo "  dirs               - Create dev directories (repos/...)"
	@echo "  ssh                - Setup SSH key and agent"
	@echo "  macos              - Apply macOS defaults (safe tweaks)"
	@echo "  custom             - Run optional custom scripts in custom/"
	@echo "  install            - Brew core+dev, stow dotfiles, oh-my-zsh, vscode, java"
	@echo "  dotfiles           - Alias for stow"
	@echo "  refresh            - Update brew packages and restow"
	@echo "  vscode             - Install VS Code extensions"
	@echo "  java-setup         - Configure jenv with installed JDKs (Oracle preferred)"
	@echo "  git-monorepo       - Optimize a large monorepo (REPO=/path/to/repo)"
	@echo "  doctor             - Print environment diagnostics"

bootstrap:
	@bash ./scripts/bootstrap.sh
	@command -v $(BREW) >/dev/null 2>&1 || { echo "brew missing. Install it via internal tool, then re-run 'make bootstrap'."; exit 1; }
	@$(MAKE) install

bootstrap-prebrew:
	@bash ./scripts/bootstrap-prebrew.sh

brew-core:
	@command -v $(BREW) >/dev/null 2>&1 || { echo "brew not found. Install via your internal tool."; exit 1; }
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_BASE)
	@# Post-install fzf key-bindings
	@if [ -d "$$($(BREW) --prefix)/opt/fzf" ]; then "$$($(BREW) --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc; fi

brew-dev:
	@command -v $(BREW) >/dev/null 2>&1 || { echo "brew not found. Install via your internal tool."; exit 1; }
	@echo "Using Oracle JDKs (via Brewfile.langs)"
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_LANGS) || true
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_APPS) || true

brew-all: brew-core brew-dev

install: brew-all stow oh-my-zsh vscode java-setup
	@echo "Install complete. Consider: make ssh && make macos"

dotfiles: stow

refresh:
	@command -v brew >/dev/null 2>&1 && brew update && brew upgrade || true
	@$(MAKE) stow

vscode:
	@bash ./scripts/vscode-setup.sh

java-setup:
	@bash ./scripts/java-setup.sh

git-monorepo:
	@bash ./scripts/git-monorepo.sh "$(REPO)"

stow:
	@command -v stow >/dev/null 2>&1 || { echo "stow not found. Run 'make brew-core' first."; exit 1; }
	@for pkg in $(STOW_PACKAGES); do \
		printf "Stowing %s...\n" $$pkg; \
		stow --no-folding -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done

unstow:
	@command -v stow >/dev/null 2>&1 || { echo "stow not found."; exit 1; }
	@for pkg in $(STOW_PACKAGES); do \
		printf "Unstowing %s...\n" $$pkg; \
		stow -D -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done

oh-my-zsh:
	@bash ./scripts/install-oh-my-zsh.sh

dirs:
	@bash ./scripts/dirs.sh

ssh:
	@bash ./scripts/ssh-setup.sh

macos:
	@bash ./scripts/macos-defaults.sh

custom:
	@bash ./scripts/run-custom.sh

doctor:
	@echo "Shell: $$SHELL" && echo
	@echo "Home: $$HOME" && echo
	@echo "brew: $$(command -v brew || echo missing)" && brew --version 2>/dev/null || true
	@echo && echo "git: $$(command -v git || echo missing)" && git --version 2>/dev/null || true
	@echo && echo "stow: $$(command -v stow || echo missing)" && stow --version 2>/dev/null || true
	@echo && echo "zsh: $$(command -v zsh || echo missing)" && zsh --version 2>/dev/null || true
	@echo && echo "python: $$(command -v python3 || echo missing)" && python3 --version 2>/dev/null || true
	@echo && echo "go: $$(command -v go || echo missing)" && go version 2>/dev/null || true
	@echo && echo "glab: $$(command -v glab || echo missing)" && glab --version 2>/dev/null || true
	@echo && echo "JAVA: $$(/usr/libexec/java_home -V 2>/dev/null || echo none)" || true

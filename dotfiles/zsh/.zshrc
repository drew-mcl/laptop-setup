# Prefer Homebrew environment if available
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
# Enable zsh command correction (spell-check for commands)
export ENABLE_CORRECTION="true"
setopt correct
plugins=(git fzf z)

if [ -d "$ZSH" ]; then
  # shellcheck disable=SC1090
  source "$ZSH/oh-my-zsh.sh"
fi

# Brew-based plugins (if installed)
if command -v brew >/dev/null 2>&1; then
  ASUGG="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -f "$ASUGG" ] && source "$ASUGG"
  SYNHL="$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [ -f "$SYNHL" ] && source "$SYNHL"
  # fzf keybindings and completion
  FZF_DIR="$(brew --prefix)/opt/fzf"
  [ -f "$FZF_DIR/shell/key-bindings.zsh" ] && source "$FZF_DIR/shell/key-bindings.zsh"
  [ -f "$FZF_DIR/shell/completion.zsh" ] && source "$FZF_DIR/shell/completion.zsh"
fi

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS HIST_FIND_NO_DUPS EXTENDED_GLOB AUTO_CD

# Useful bindings
bindkey -e

# Spell-correction prompt (on typo suggestions)
export SPROMPT='zsh: correct %F{yellow}%R%f to %F{green}%r%f [nyae]? '

# Prompt tweaks
export PROMPT='%n@%m %1~ %# '

# direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# jenv (Java version manager)
if command -v jenv >/dev/null 2>&1; then
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
fi

# GOPATH/GOBIN if Go present
if command -v go >/dev/null 2>&1; then
  export GOPATH="$HOME/go"
  export GOBIN="$GOPATH/bin"
  export PATH="$GOBIN:$PATH"
fi

# Aliases
alias ll='eza -lah --git --group-directories-first' 2>/dev/null || alias ll='ls -lah'
alias gs='git status -sb'
alias gco='git checkout'
alias gb='git branch -vv'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gp='git pull --ff-only && git push'

# GitLab CLI helpers (if glab is installed)
if command -v glab >/dev/null 2>&1; then
  alias gmr='glab mr create --fill --remove-source-branch'
  alias gml='glab mr list --mine'
  alias gms='glab mr status'
  alias gci='glab ci view'
  # Checkout MR via fzf
  gmco() {
    command -v glab >/dev/null 2>&1 || { echo "glab not found"; return 1; }
    local line id
    line=$(glab mr list --state opened --no-headers -n 100 2>/dev/null | fzf --ansi --prompt='MR> ' --height=60%) || return 1
    id=$(echo "$line" | awk '{print $1}')
    [ -n "$id" ] && glab mr checkout "$id"
  }
fi

# Shortcut to prepare branch for merge (interactive squash onto default)
alias gpm='git prep-merge'
alias gpm1='git prep-merge-squash'

# Make anywhere: find nearest Makefile
m() {
  local dir="$PWD"
  while [[ "$dir" != "/" && ! -f "$dir/Makefile" ]]; do dir="${dir:h}"; done
  [[ -f "$dir/Makefile" ]] || { echo "No Makefile found"; return 1; }
  (cd "$dir" && make "$@")
}

# Make target picker with fzf
mt() {
  local dir="$PWD"; while [[ "$dir" != "/" && ! -f "$dir/Makefile" ]]; do dir="${dir:h}"; done
  [[ -f "$dir/Makefile" ]] || { echo "No Makefile found"; return 1; }
  local tgt
  tgt=$(make -qp -C "$dir" 2>/dev/null | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/{print $1}' | sort -u | fzf --prompt='make> ' --height=60%) || return 1
  (cd "$dir" && make "$tgt")
}

# Alias browser: pick and paste to command line
aa() {
  local choice name body
  choice=$(alias | sed 's/^alias \([^=]*\)=\(.*\)$/\1\t\2/' | column -t -s $'\t' | fzf --prompt='alias> ' --preview 'echo {}' --height=60%) || return 1
  name=${choice%% *}
  body=$(alias "$name" | sed 's/^alias [^=]*=//')
  # Strip leading and trailing quotes
  body=${body#\'}; body=${body%\'}; body=${body#\"}; body=${body%\"}
  print -z -- "$body"
}

# SSH: fzf host picker reading from ~/.ssh/config and config.d
sshx() {
  local hosts
  hosts=$(awk '/^Host /{for(i=2;i<=NF;i++) if ($i !~ /[\*\?]/) print $i}' "$HOME/.ssh/config" "$HOME/.ssh/config.d"/* 2>/dev/null | sort -u) || true
  [[ -n "$hosts" ]] || { echo "No SSH hosts found"; return 1; }
  local h
  h=$(echo "$hosts" | fzf --prompt='ssh> ' --height=60%) || return 1
  [ -n "$h" ] && ssh "$h"
}

# SSH: create per-host config + key
ssh-host() { bash "$HOME/laptop-setup/scripts/ssh-host.sh" "$@" 2>/dev/null || bash "$PWD/scripts/ssh-host.sh" "$@"; }

# Open this laptop-setup repo in VS Code quickly
code-dotfiles() {
  local repo="${DOTFILES_REPO_DIR:-}"
  if [[ -z "$repo" && -L "$HOME/.zshrc" ]]; then
    local target=$(readlink "$HOME/.zshrc")
    [[ "$target" != /* ]] && target="$HOME/$target"
    repo=$(dirname "$(dirname "$(dirname "$target")")")
  fi
  if [[ -z "$repo" ]]; then
    for cand in "$HOME/repos/work/laptop-setup" "$HOME/repos/personal/laptop-setup" "$HOME/laptop-setup"; do
      [[ -d "$cand/.git" ]] && repo="$cand" && break
    done
  fi
  [[ -n "$repo" ]] || { echo "Set DOTFILES_REPO_DIR or place repo under ~/repos/{work,personal}"; return 1; }
  command -v code >/dev/null 2>&1 || { echo "VS Code CLI 'code' not found. Run: make vscode"; return 1; }
  code "$repo"
}

# Fuzzy browse and clone repos from GitHub/GitLab, then cd
repo() {
  local rows tmp src name url sel dest_base dest_dir
  rows=()
  if command -v gh >/dev/null 2>&1; then
    while IFS=$'\t' read -r n u; do rows+=("github\t$n\t$u"); done < <(gh repo list --limit 500 --json nameWithOwner,sshUrl 2>/dev/null | jq -r '.[]|[.nameWithOwner,.sshUrl]|@tsv')
  fi
  if command -v glab >/dev/null 2>&1; then
    # Best-effort: glab repo list (format may vary). Assume path owner/name.
    while read -r line; do
      local p=$(echo "$line" | awk '{print $1}')
      [[ -z "$p" ]] && continue
      rows+=("gitlab\t$p\tgit@gitlab.com:$p.git")
    done < <(glab repo list --no-headers -n 200 2>/dev/null || true)
  fi
  [[ ${#rows[@]} -gt 0 ]] || { echo "No repos found via gh or glab"; return 1; }
  sel=$(printf '%s\n' "${rows[@]}" | column -t -s $'\t' | fzf --ansi --prompt='repo> ' --height=80% --preview 'echo {1} {2}\n{3}') || return 1
  src=$(echo "$sel" | awk '{print $1}')
  name=$(echo "$sel" | awk '{print $2}')
  url=$(echo "$sel" | awk '{print $3}')
  local answer
  vared -p "Destination [w]ork/[p]ersonal: " -c answer
  case "${answer:l}" in
    p|personal) dest_base="$HOME/repos/personal";;
    *) dest_base="$HOME/repos/work";;
  esac
  mkdir -p "$dest_base"
  dest_dir="$dest_base/${name##*/}"
  if [[ -d "$dest_dir/.git" ]]; then
    echo "Exists: $dest_dir"; cd "$dest_dir"; return
  fi
  git clone "$url" "$dest_dir" && cd "$dest_dir"
}

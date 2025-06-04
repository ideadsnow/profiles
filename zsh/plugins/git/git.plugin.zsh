#!/usr/bin/env zsh

# Git Plugin for Warp Terminal + Starship
# Modified from oh-my-zsh git plugin for standalone usage

# Git version checking
autoload -Uz is-at-least 2>/dev/null || {
  # Fallback is-at-least function if not available
  is-at-least() {
    local target=$1
    local current=$2
    # Simple version comparison - works for most cases
    [[ $current == $target ]] || [[ $current > $target ]]
  }
}

git_version="${${(As: :)$(git version 2>/dev/null)}[3]}"

#
# Core Functions
#

# Get current branch - core function needed by many aliases
function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

# The name of the current branch
# Back-compatibility wrapper
function current_branch() {
  git_current_branch
}

# Check for develop and similarly named branches
function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel develop development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return 0
    fi
  done

  echo develop
  return 1
}

# Check if main exists and use instead of master
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  # If no main branch was found, fall back to master but return error
  echo master
  return 1
}

function grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 old_branch new_branch"
    return 1
  fi

  # Rename branch locally
  git branch -m "$1" "$2"
  # Rename branch in origin remote
  if git push origin :"$1"; then
    git push --set-upstream origin "$2"
  fi
}

#
# Work in Progress (WIP) Functions
#

# Similar to `gunwip` but recursive "Unwips" all recent `--wip--` commits not just the last one
function gunwipall() {
  local _commit=$(git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H)

  # Check if a commit without "--wip--" was found and it's not the same as HEAD
  if [[ "$_commit" != "$(git rev-parse HEAD)" ]]; then
    git reset $_commit || return 1
  fi
}

# Warn if the current branch is a WIP
function work_in_progress() {
  command git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- "--wip--" && echo "WIP!!"
}

#
# Helper Functions
#

# Delete merged branches (compatible with both main and develop)
function gbda() {
  git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2>/dev/null
}

# Delete squash-merged branches
function gbds() {
  local default_branch=$(git_main_branch)
  (( ! $? )) || default_branch=$(git_develop_branch)

  git for-each-ref refs/heads/ "--format=%(refname:short)" | \
    while read branch; do
      local merge_base=$(git merge-base $default_branch $branch 2>/dev/null)
      if [[ -n "$merge_base" ]] && [[ $(git cherry $default_branch $(git commit-tree $(git rev-parse $branch\^{tree}) -p $merge_base -m _) 2>/dev/null) = -* ]]; then
        git branch -D $branch
      fi
    done
}

# Git clone and cd into directory
function gccd() {
  setopt localoptions extendedglob 2>/dev/null || true

  # get repo URI from args based on valid formats
  local repo="${${@[(r)(ssh://*|git://*|ftp(s)#://*|http(s)#://*|*@*)(.git/#)#]}:-$_}"

  # clone repository and exit if it fails
  command git clone --recurse-submodules "$@" || return

  # if last arg passed was a directory, that's where the repo was cloned
  # otherwise parse the repo URI and use the last part as the directory
  [[ -d "$_" ]] && cd "$_" || cd "${${repo:t}%.git/#}"
}

# Git diff with viewer
function gdv() { git diff -w "$@" | view - }

# Git diff excluding lock files
function gdnolock() {
  git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}

# Git pull with rebase for current or specified branch
function ggu() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git pull --rebase origin "${b:=$1}"
}

# Git pull origin for current or specified branch
function ggl() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git pull origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git pull origin "${b:=$1}"
  fi
}

# Git push force for current or specified branch
function ggf() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git push --force origin "${b:=$1}"
}

# Git push force with lease for current or specified branch
function ggfl() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git push --force-with-lease origin "${b:=$1}"
}

# Git push for current or specified branch
function ggp() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git push origin "${b:=$1}"
  fi
}

# Git pull and push (pull then push)
function ggpnp() {
  if [[ "$#" == 0 ]]; then
    ggl && ggp
  else
    ggl "${*}" && ggp "${*}"
  fi
}

# Pretty log messages
function _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty=$1
  fi
}

# Git tag list with pattern matching
function gtl() {
  git tag --sort=-v:refname -n --list "${1}*"
}

#
# Aliases
# (sorted alphabetically by command)
#

# Git root
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'

# Basic git
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'

# Git am
alias gam='git am'
alias gama='git am --abort'
alias gamc='git am --continue'
alias gamscp='git am --show-current-patch'
alias gams='git am --skip'

# Git apply
alias gap='git apply'
alias gapt='git apply --3way'

# Git bisect
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsn='git bisect new'
alias gbso='git bisect old'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

# Git blame
alias gbl='git blame -w'

# Git branch
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbgd='LANG=C git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '"'"'{print $1}'"'"' | xargs git branch -d'
alias gbgD='LANG=C git branch --no-color -vv | grep ": gone\]" | cut -c 3- | awk '"'"'{print $1}'"'"' | xargs git branch -D'
alias gbm='git branch --move'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias gbg='LANG=C git branch -vv | grep ": gone\]"'

# Git checkout
alias gco='git checkout'
alias gcor='git checkout --recurse-submodules'
alias gcb='git checkout -b'
alias gcB='git checkout -B'
alias gcd='git checkout $(git_develop_branch)'
alias gcm='git checkout $(git_main_branch)'

# Git cherry-pick
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

# Git clean
alias gclean='git clean --interactive -d'

# Git clone
alias gcl='git clone --recurse-submodules'
alias gclf='git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules'

# Git commit
alias gcam='git commit --all --message'
alias gcas='git commit --all --signoff'
alias gcasm='git commit --all --signoff --message'
alias gcs='git commit --gpg-sign'
alias gcss='git commit --gpg-sign --signoff'
alias gcssm='git commit --gpg-sign --signoff --message'
alias gcmsg='git commit --message'
alias gcsm='git commit --signoff --message'
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gca!='git commit --verbose --all --amend'
alias gcan!='git commit --verbose --all --no-edit --amend'
alias gcans!='git commit --verbose --all --signoff --no-edit --amend'
alias gcann!='git commit --verbose --all --date=now --no-edit --amend'
alias gc!='git commit --verbose --amend'
alias gcn='git commit --verbose --no-edit'
alias gcn!='git commit --verbose --no-edit --amend'

# Git config
alias gcf='git config --list'
alias gcfu='git commit --fixup'

# Git describe
alias gdct='git describe --tags $(git rev-list --tags --max-count=1)'

# Git diff
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gdup='git diff @{upstream}'
alias gdt='git diff-tree --no-commit-id --name-only -r'

# Git fetch
alias gf='git fetch'
# --jobs=<n> was added in git 2.8
if is-at-least 2.8 "$git_version"; then
  alias gfa='git fetch --all --tags --prune --jobs=10'
else
  alias gfa='git fetch --all --tags --prune'
fi
alias gfo='git fetch origin'

# Git GUI
alias gg='git gui citool'
alias gga='git gui citool --amend'

# Git help
alias ghh='git help'

# Git log
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glods='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
alias glod='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias glols='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glp='_git_log_prettily'
alias glg='git log --stat'
alias glgp='git log --stat --patch'

# Git ls-files
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias gfg='git ls-files | grep'

# Git merge
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms="git merge --squash"
alias gmff="git merge --ff-only"
alias gmom='git merge origin/$(git_main_branch)'
alias gmum='git merge upstream/$(git_main_branch)'
alias gmtl='git mergetool --no-prompt'
alias gmtlvim='git mergetool --no-prompt --tool=vimdiff'

# Git pull
alias gl='git pull'
alias gpr='git pull --rebase'
alias gprv='git pull --rebase -v'
alias gpra='git pull --rebase --autostash'
alias gprav='git pull --rebase --autostash -v'
alias gprom='git pull --rebase origin $(git_main_branch)'
alias gpromi='git pull --rebase=interactive origin $(git_main_branch)'
alias gprum='git pull --rebase upstream $(git_main_branch)'
alias gprumi='git pull --rebase=interactive upstream $(git_main_branch)'
alias ggpull='git pull origin "$(git_current_branch)"'
alias gluc='git pull upstream $(git_current_branch)'
alias glum='git pull upstream $(git_main_branch)'
alias ggpur='ggu'

# Git push
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf!='git push --force'
if is-at-least 2.30 "$git_version"; then
  alias gpf='git push --force-with-lease --force-if-includes'
  alias gpsupf='git push --set-upstream origin $(git_current_branch) --force-with-lease --force-if-includes'
else
  alias gpf='git push --force-with-lease'
  alias gpsupf='git push --set-upstream origin $(git_current_branch) --force-with-lease'
fi
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gpv='git push --verbose'
alias gpoat='git push origin --all && git push origin --tags'
alias gpod='git push origin --delete'
alias ggpush='git push origin "$(git_current_branch)"'
alias gpu='git push upstream'

# Git rebase
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias grbd='git rebase $(git_develop_branch)'
alias grbm='git rebase $(git_main_branch)'
alias grbom='git rebase origin/$(git_main_branch)'
alias grbum='git rebase upstream/$(git_main_branch)'

# Git reflog
alias grf='git reflog'

# Git remote
alias gr='git remote'
alias grv='git remote --verbose'
alias gra='git remote add'
alias grrm='git remote remove'
alias grmv='git remote rename'
alias grset='git remote set-url'
alias grup='git remote update'

# Git reset
alias grh='git reset'
alias gru='git reset --'
alias grhh='git reset --hard'
alias grhk='git reset --keep'
alias grhs='git reset --soft'
alias gpristine='git reset --hard && git clean --force -dfx'
alias gwipe='git reset --hard && git clean --force -df'
alias groh='git reset origin/$(git_current_branch) --hard'

# Git restore
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'

# Git revert
alias gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
alias grev='git revert'
alias greva='git revert --abort'
alias grevc='git revert --continue'

# Git rm
alias grm='git rm'
alias grmc='git rm --cached'

# Git shortlog
alias gcount='git shortlog --summary --numbered'

# Git show
alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'

# Git stash
alias gstall='git stash --all'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
# use the default stash push on git 2.13 and newer
if is-at-least 2.13 "$git_version"; then
  alias gsta='git stash push'
else
  alias gsta='git stash save'
fi
alias gsts='git stash show --patch'
alias gstu='gsta --include-untracked'

# Git status
alias gst='git status'
alias gss='git status --short'
alias gsb='git status --short --branch'

# Git submodule
alias gsi='git submodule init'
alias gsu='git submodule update'

# Git svn
alias gsd='git svn dcommit'
alias git-svn-dcommit-push='git svn dcommit && git push github $(git_main_branch):svntrunk'
alias gsr='git svn rebase'

# Git switch
alias gsw='git switch'
alias gswc='git switch --create'
alias gswd='git switch $(git_develop_branch)'
alias gswm='git switch $(git_main_branch)'

# Git tag
alias gta='git tag --annotate'
alias gts='git tag --sign'
alias gtv='git tag | sort -V'

# Git update-index
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'

# Git whatchanged
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'

# Git worktree
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtmv='git worktree move'
alias gwtrm='git worktree remove'

# Gitk - Modified for better compatibility
if command -v gitk > /dev/null 2>&1; then
  alias gk='gitk --all --branches &!'
  alias gke='gitk --all $(git log --walk-reflogs --pretty=%h) &!'
else
  # Fallback to git log if gitk is not available
  alias gk='git log --graph --all --branches --oneline'
  alias gke='git log --graph --all --walk-reflogs --oneline'
fi

# Clean up
unset git_version

# Deprecated aliases with warnings (for backward compatibility)
local old_alias new_alias
for old_alias new_alias in \
  gup gpr \
  gupv gprv \
  gupa gpra \
  gupav gprav \
  gupom gprom \
  gupomi gpromi; do
  
  # Only create alias if not already defined
  if ! alias "$old_alias" > /dev/null 2>&1; then
    alias "$old_alias"="echo \"[git-plugin] '$old_alias' is deprecated, use '$new_alias' instead\"; $new_alias"
  fi
done
unset old_alias new_alias

# Completion setup for Warp/Starship (if available)
if [[ -n "${WARP_TERMINAL}" ]] || command -v starship > /dev/null 2>&1; then
  # Set up basic completion for functions if compdef is available
  if command -v compdef > /dev/null 2>&1; then
    compdef _git ggpnp=git-checkout 2>/dev/null || true
    compdef _git gccd=git-clone 2>/dev/null || true
    compdef _git gdv=git-diff 2>/dev/null || true
    compdef _git gdnolock=git-diff 2>/dev/null || true
    compdef _git ggu=git-checkout 2>/dev/null || true
    compdef _git ggl=git-checkout 2>/dev/null || true
    compdef _git ggf=git-checkout 2>/dev/null || true
    compdef _git ggfl=git-checkout 2>/dev/null || true
    compdef _git ggp=git-checkout 2>/dev/null || true
    compdef _git _git_log_prettily=git-log 2>/dev/null || true
  fi
fi

# Success message
# echo "Git plugin loaded successfully for Warp + Starship environment"

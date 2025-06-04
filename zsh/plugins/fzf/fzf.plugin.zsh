# -------------------------
# fzf 默认配置（美化）
# -------------------------
export FZF_DEFAULT_OPTS='
  --height=40%
  --layout=reverse
  --border
  --preview-window=right:60%
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8
  --color=fg+:#ffffff,bg+:#45475a,hl+:#a6e3a1
  --color=info:#89dceb,prompt:#f9e2af,pointer:#f38ba8
'

# -------------------------
# 快捷键绑定（如果未自动加载）
# -------------------------
if [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

# -------------------------
# fzf 交互功能
# -------------------------

# 1. 查找文件并打开（支持预览）
alias fopen='fzf --preview "bat --style=numbers --color=always --line-range :500 {}" | xargs nvim'

# 2. 查找目录并跳转
fcd() {
  local dir
  dir=$(fd --type d . ~ | fzf --preview "eza -T --icons --level=2 {}") && cd "$dir"
}

# 3. 查找 Git 分支并切换
fbr() {
  local branch
  branch=$(git branch --all | grep -v HEAD | sed 's/.* //' | fzf --height 40%) &&
  git checkout "$branch"
}

# 4. 全文搜索文件内容并预览（结合 rg）
frg() {
  local file
  file=$(rg --files | fzf --preview "bat --style=numbers --color=always {}") && nvim "$file"
}

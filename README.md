# 🛠️ Personal Configuration Files

这是一个个人的终端配置文件仓库，主要包含 ZSH 和 Starship 的配置，专为现代终端环境（特别是 Warp Terminal）优化

## 📁 项目结构

```
profiles/
├── install.sh          # 自动安装脚本
├── LICENSE             # MIT 许可证
├── starship/           # Starship 终端美化配置
│   └── starship.toml   # Starship 主题配置文件
└── zsh/                # ZSH 配置目录
    ├── aliases         # 自定义命令别名
    ├── zshrc          # ZSH 主配置文件
    └── plugins/       # ZSH 插件
        ├── fzf/       # 模糊查找工具配置
        └── git/       # Git 增强插件
```

## ✨ 主要特性

### 🐚 ZSH 配置
- **智能插件系统**: 自动加载 plugins 目录下的所有 `.zsh` 文件
- **丰富的别名**: 包含 Git、文件操作、导航等常用别名
- **macOS 兼容**: 专门针对 macOS 环境优化
- **性能优化**: 延迟加载 NVM 等工具，提升启动速度

### 🎨 Starship 美化
- **现代化提示符**: 使用 Nerd Fonts 图标（需要安装 Nerd 字体）
- **多语言支持**: 支持 50+ 编程语言和工具的识别
- **Git 集成**: 智能显示 Git 分支和状态
- **云服务集成**: 支持 AWS、GCP 等云平台状态显示

### 🔧 插件功能

#### FZF 插件
- **美化界面**: Catppuccin 主题配色
- **文件搜索**: `fopen` - 搜索并打开文件（支持预览）
- **目录跳转**: `fcd` - 快速跳转到目录
- **Git 分支**: `fbr` - 交互式切换 Git 分支
- **内容搜索**: `frg` - 全文搜索文件内容

#### Git 插件
- **完整的 Git 别名**: 200+ 个 Git 命令别名
- **智能分支检测**: 自动识别 main/master 和 develop 分支
- **WIP 功能**: 快速保存和恢复工作进度
- **分支管理**: 删除已合并分支、清理废弃分支
- **Warp 终端优化**: 专门为 Warp + Starship 环境优化

## 🚀 一键安装

```bash
# 克隆仓库
git clone https://github.com/your-username/profiles.git ~/profiles

# 运行自动安装脚本
cd ~/profiles
./install.sh

# 重新加载 ZSH 配置
source ~/.zshrc
```

### 安装脚本功能

自动安装脚本 `install.sh` 会完成以下操作：

1. **创建配置目录**：自动创建 `~/.config` 目录
2. **创建符号链接**：
   - 链接 ZSH 配置：`~/profiles/zsh` → `~/.config/zsh`
   - 链接 Starship 配置：`~/profiles/starship/starship.toml` → `~/.config/starship.toml`
3. **配置 ~/.zshrc**：
   - 智能检测现有配置，避免重复添加
   - 安全地追加配置到 `~/.zshrc` 文件末尾
   - 不会覆盖或删除你的现有配置

> 💡 **安全提示**：安装脚本会保护你现有的 `.zshrc` 配置，只会在必要时追加我们的配置内容

## 📋 依赖要求

### 必需依赖
- **ZSH**: 作为默认 shell
- **Starship**: 终端提示符美化
  ```bash
  # macOS
  brew install starship
  ```

### 推荐依赖
- **FZF**: 模糊查找工具
  ```bash
  brew install fzf
  ```
- **Zoxide**: 智能目录跳转
  ```bash
  brew install zoxide
  ```
- **Eza**: 现代化的 ls 替代品
  ```bash
  brew install eza
  ```
- **Bat**: 语法高亮的 cat 替代品
  ```bash
  brew install bat
  ```
- **Ripgrep**: 快速文本搜索
  ```bash
  brew install ripgrep
  ```
- **Fd**: 快速文件查找
  ```bash
  brew install fd
  ```

## 🎯 使用指南

### 常用别名

#### 文件操作
```bash
ls, l, ll, la    # 使用 eza 的各种列表格式
tree            # 树形目录显示
vi, vim         # 使用 nvim
.., ...         # 快速向上导航
```

#### Git 操作（与 Oh My Zsh 的 [Git 插件](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/README.md)一致）
```bash
g               # git
ga              # git add
gaa             # git add --all
gcmsg           # git commit --message
gst             # git status
gco             # git checkout
gcb             # git checkout -b
gl              # git pull
gp              # git push
```

#### 工具函数
```bash
proxy on/off    # 代理开关
nvm             # 延迟加载的 NVM
fopen           # FZF 文件搜索并打开
fcd             # FZF 目录跳转
fbr             # FZF Git 分支切换
```

### 环境变量

项目会自动设置以下环境变量：
- `ZSH_CONFIG_DIR`: ZSH 配置目录路径
- `FZF_DEFAULT_OPTS`: FZF 美化选项

## 🎨 自定义配置

### 添加自定义别名
编辑 `zsh/aliases` 文件，添加你的自定义别名

### 添加新插件
在 `zsh/plugins/` 目录下创建新的子目录，并添加 `.zsh` 文件，系统会自动加载

### 修改 Starship 主题
编辑 `starship/starship.toml` 文件来自定义提示符样式

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个配置！

## 📄 许可证

本项目使用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- [Starship](https://starship.rs/) - 美丽的跨平台终端提示符
- [FZF](https://github.com/junegunn/fzf) - 命令行模糊查找器
- [Oh My Zsh](https://ohmyz.sh/) - Git 插件参考
- [Catppuccin](https://github.com/catppuccin/catppuccin) - 配色方案灵感

#!/bin/bash

set -e

PROFILES_DIR="$HOME/profiles"
ZSHRC_FILE="$HOME/.zshrc"
ZSH_CONFIG_BLOCK="\n# Personal ZSH Configuration\nexport ZSH_CONFIG_DIR=\$HOME/.config/zsh\nif [ -f \$ZSH_CONFIG_DIR/zshrc ]; then\n  source \$ZSH_CONFIG_DIR/zshrc\nfi"

# 创建必要的目录
mkdir -p "$HOME/.config"

echo "🔗 Linking zsh configs..."
ln -sf "$PROFILES_DIR/zsh" "$HOME/.config/zsh"

echo "📝 Configuring ~/.zshrc..."
if [ -f "$ZSHRC_FILE" ]; then
    # 检查是否已经存在我们的配置
    if grep -q "ZSH_CONFIG_DIR=\$HOME/.config/zsh" "$ZSHRC_FILE"; then
        echo "✨ ~/.zshrc already configured, skipping..."
    else
        # 安全地追加配置
        echo "" >> "$ZSHRC_FILE"
        echo "$ZSH_CONFIG_BLOCK" >> "$ZSHRC_FILE"
        echo "✅ Configuration added to existing ~/.zshrc"
    fi
else
    # 创建新的 .zshrc 文件
    echo "$ZSH_CONFIG_BLOCK" > "$ZSHRC_FILE"
    echo "✅ Created ~/.zshrc with configuration"
fi

echo "🔗 Linking starship config..."
ln -sf "$PROFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

echo ""
echo "🎉 Installation completed successfully!"
echo "📢 Please run: source ~/.zshrc"
echo "💡 Or restart your terminal to apply changes"

# Git Plugin

这个 Git 插件基于 Oh My Zsh 的 Git 插件进行了修改，专为 Warp Terminal + Starship 环境优化

## 主要功能

- 200+ Git 别名命令
- 智能分支检测（main/master, develop）
- WIP（Work in Progress）功能
- 分支管理工具
- 兼容现代 Git 版本的特性

## 常用别名

| 别名 | 命令 | 说明 |
|------|------|------|
| g | git | Git 基础命令 |
| ga | git add | 添加文件 |
| gaa | git add --all | 添加所有文件 |
| gcmsg | git commit --message | 提交消息 |
| gst | git status | 查看状态 |
| gco | git checkout | 切换分支 |
| gcb | git checkout -b | 创建并切换分支 |
| gl | git pull | 拉取代码 |
| gp | git push | 推送代码 |
| glog | git log --oneline --decorate --graph | 图形化日志 |

完整的别名列表请参考插件源码

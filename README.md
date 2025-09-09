# QQ音乐 Wine 版本

基于 Wine 的 QQ音乐客户端 Arch Linux 软件包，提供安全沙箱化运行环境。

## 功能特性

- **完整的 QQ音乐体验**: 运行官方 Windows 客户端，保持完整功能
- **中文字体支持**: 自动配置微软雅黑字体，解决中文显示问题
- **音频优化**: 配置 48kHz/24-bit 高质量音频输出
- **安全沙箱**: 使用 bubblewrap 隔离运行环境，限制文件系统访问
- **用户配置分离**: 每用户独立配置，不影响系统环境

## 依赖要求

### 必需依赖
- `wine-staging` - Wine 暂存版本（与普通 wine 冲突）
- `winetricks` - Wine 辅助工具
- `wine-gecko` - HTML 渲染引擎
- `bubblewrap` - 沙箱容器

### 可选依赖
- `lib32-pulse` - 音频支持
- `lib32-mesa` - 图形支持  
- `lib32-vulkan-icd-loader` - DXVK Vulkan 支持

## 安装方法

1. **使用 makepkg 构建安装**:
   ```bash
   makepkg -si
   ```

2. **启动 QQ音乐**:
   ```bash
   qqmusic
   ```
   或从应用程序菜单启动

## 技术架构

### Wine 环境
- **架构**: 64位 Wine 环境 (WINEARCH=win64)
- **Wine 版本**: wine-staging（优化版本）
- **安装位置**: `/opt/qqmusic-wine/wineprefix/`（系统模板）
- **用户配置**: `~/.config/qqmusic-wine/wineprefix/`（运行时）

### Windows 组件
自动安装以下 Windows 运行库：
- `vcrun2015` - Visual C++ 2015 运行库
- `gdiplus` - GDI+ 图形库  
- `quartz` - 媒体播放框架
- `riched20` - 富文本控件
- `dxvk` - DirectX 支持

### 字体系统
- **字体文件**: 微软雅黑 (msyh.ttc) 和粗体版本 (msyhbd.ttc)
- **配置文件**: `font-config.reg` 注册表配置
- **字体替换**: 自动将系统字体映射到中文字体

### 安全沙箱
使用 bubblewrap 提供安全隔离：
- **命名空间隔离**: 除网络外的所有命名空间
- **只读系统**: 系统目录只读挂载
- **选择性访问**: 仅必要目录可访问
- **音频支持**: PulseAudio 套接字绑定

## 故障排除

### 常见问题

1. **中文显示乱码**
   ```bash
   # 重新配置字体
   rm ~/.config/qqmusic-wine/wineprefix/font_configured
   qqmusic
   ```

2. **音频无声音**
   ```bash
   # 检查 PulseAudio
   pulseaudio --check
   
   # 重启 PulseAudio
   pulseaudio -k && pulseaudio --start
   ```

3. **启动失败**
   ```bash
   # 重置配置
   rm -rf ~/.config/qqmusic-wine
   qqmusic
   ```

### 调试模式

- **完整 Wine 调试**:
  ```bash
  WINEDEBUG=+all qqmusic
  ```

- **禁用 DXVK**:
  ```bash
  WINEDLLOVERRIDES="d3d11,dxgi=builtin" qqmusic
  ```

- **沙箱调试**:
  ```bash
  strace -f qqmusic 2>&1 | grep bwrap
  ```

## 文件结构

```
/opt/qqmusic-wine/
├── wineprefix/              # Wine 环境模板
├── font-config.reg          # 字体注册表配置

~/.config/qqmusic-wine/
└── wineprefix/              # 用户 Wine 环境
    ├── drive_c/
    │   ├── Program Files/Tencent/QQMusic/
    │   └── windows/Fonts/   # 中文字体
    └── font_configured      # 字体配置标记

/usr/bin/qqmusic             # 启动脚本
/usr/share/applications/qqmusic.desktop  # 桌面文件
```

## 环境变量

关键环境变量：
- `WINEPREFIX` - Wine 前缀路径
- `STAGING_SHARED_MEMORY=1` - Wine-staging 优化
- `DXVK_LOG_LEVEL=warn` - DXVK 日志级别
- `DXVK_HUD=fps,memory` - 性能监控显示

## 贡献指南

1. Fork 本仓库
2. 创建功能分支
3. 提交更改
4. 发起 Pull Request

## 许可证

自定义许可证 - 详见 PKGBUILD

## 版本信息

- **QQ音乐版本**: 19.71
- **包版本**: 1
- **架构**: x86_64

---

**注意**: 本软件包仅用于个人学习和研究目的，请遵守相关法律法规和软件许可协议。
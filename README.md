# QQ音乐 Wine 版本

在 Linux 上通过 Wine 运行腾讯QQ音乐的 Arch Linux 软件包集合。

## 两个版本

### qqmusic-installer (安装包版本)
- 使用官方QQ音乐安装包
- 构建时自动下载并运行安装程序
- 包含完整安装流程

### qqmusic-bin (二进制版本) 
- 使用预提取的程序文件
- 更快的安装过程
- 避免安装程序交互问题
- **推荐使用**

## 安装方式

### 推荐：使用 qqmusic-bin
```bash
cd qqmusic-bin
makepkg -si
```

### 或者：使用 qqmusic-installer
```bash
cd qqmusic-installer  
makepkg -si
```

## 使用

```bash
qqmusic-wine
```

## 系统要求

### 必需依赖
- wine-staging
- winetricks  
- wine-gecko

### 可选依赖
- lib32-pulse: 音频支持
- lib32-mesa: 图形支持
- lib32-vulkan-icd-loader: DXVK Vulkan 支持

## 特性

- ✅ 预配置 Wine 环境，Windows 7 兼容模式
- ✅ 中文字体支持（微软雅黑）
- ✅ 优化音频设置（48kHz, 24-bit）
- ✅ 用户独立配置目录
- ✅ DXVK 支持，提升图形性能
- ✅ 完整的运行时库支持

## 故障排除

### 重置配置
```bash
rm -rf ~/.config/qqmusic-wine
```

### 调试模式
```bash
WINEDEBUG=+all qqmusic-wine
```

### 禁用 DXVK
```bash
WINEDLLOVERRIDES="d3d11,dxgi=builtin" qqmusic-wine
```

### 中文字体问题
```bash
# 检查字体文件
ls ~/.config/qqmusic-wine/wineprefix/drive_c/windows/Fonts/msyh*

# 重新配置字体
rm ~/.config/qqmusic-wine/wineprefix/font_configured
```


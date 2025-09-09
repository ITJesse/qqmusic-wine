# qqmusic-wine

基于 Wine 的 QQ 音乐 Arch Linux 软件包。

## 安装

```bash
makepkg -si
```

## 使用

```bash
qqmusic-wine
```

## 依赖

- wine-staging
- winetricks
- wine-gecko

## 可选依赖

- lib32-pulse: 音频支持
- lib32-mesa: 图形支持
- lib32-vulkan-icd-loader: DXVK Vulkan 支持

## 特性

- 预配置 Wine 环境，Windows 7 兼容模式
- 中文字体支持（微软雅黑）
- 优化音频设置（48kHz, 24-bit）
- 用户独立配置

## 故障排除

重置配置：
```bash
rm -rf ~/.config/qqmusic-wine
```

调试模式：
```bash
WINEDEBUG=+all qqmusic-wine
```

禁用 DXVK：
```bash
WINEDLLOVERRIDES="d3d11,dxvk=builtin" qqmusic-wine
```
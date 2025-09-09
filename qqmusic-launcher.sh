#!/bin/bash

# QQ音乐 Wine 启动脚本

# 确保使用 wine-staging
export PATH="/opt/wine-staging/bin:$PATH"

# wine-staging 环境变量
export STAGING_SHARED_MEMORY=1
export STAGING_RT_PRIORITY_SERVER=1

# DXVK 配置（针对音乐软件优化）
export DXVK_LOG_LEVEL=warn
export DXVK_HUD=fps,memory

# 用户配置目录
USER_CONFIG_DIR="$HOME/.config/qqmusic-wine"

# 初始化用户配置
if [ ! -d "$USER_CONFIG_DIR" ]; then
    echo "正在初始化 QQ音乐 用户配置..."
    mkdir -p "$USER_CONFIG_DIR"
    cp -r "/opt/qqmusic-wine/wineprefix" "$USER_CONFIG_DIR/"
    
    export WINEPREFIX="$USER_CONFIG_DIR/wineprefix"
    
    # 检查并重新应用字体配置（如果字体文件存在但注册表配置丢失）
    if [ -f "$WINEPREFIX/drive_c/windows/Fonts/msyh.ttc" ] && [ ! -f "$WINEPREFIX/font_configured" ]; then
        echo "正在重新配置中文字体..."
        
        # 注册字体
        wine regedit "/opt/qqmusic-wine/font-config.reg"
        
        # 标记字体已配置
        touch "$WINEPREFIX/font_configured"
        
        echo "字体配置完成"
    fi
    
    # 为音频播放优化设置 (48kHz, 24-bit)
    wine reg add "HKEY_CURRENT_USER\Software\Wine\DirectSound" /v MaxShadowSize /t REG_DWORD /d 8
    wine reg add "HKEY_CURRENT_USER\Software\Wine\DirectSound" /v DefaultSampleRate /t REG_DWORD /d 48000
    wine reg add "HKEY_CURRENT_USER\Software\Wine\DirectSound" /v DefaultBitsPerSample /t REG_DWORD /d 24
    
    echo "配置完成！"
fi

export WINEPREFIX="$USER_CONFIG_DIR/wineprefix"

# 查找 QQ音乐 可执行文件
QQMUSIC_PATH=""
if [ -f "$WINEPREFIX/drive_c/Program Files/Tencent/QQMusic/QQMusic.exe" ]; then
    QQMUSIC_PATH="$WINEPREFIX/drive_c/Program Files/Tencent/QQMusic"
elif [ -f "$WINEPREFIX/drive_c/Program Files (x86)/Tencent/QQMusic/QQMusic.exe" ]; then
    QQMUSIC_PATH="$WINEPREFIX/drive_c/Program Files (x86)/Tencent/QQMusic"
else
    echo "错误：找不到 QQ音乐 安装目录"
    echo "请检查安装是否成功"
    exit 1
fi

echo "正在启动 QQ音乐..."

# 使用 bubblewrap 沙箱启动
exec bwrap \
    --unshare-all \
    --share-net \
    --die-with-parent \
    --new-session \
    --ro-bind /usr /usr \
    --ro-bind /lib /lib \
    --ro-bind /lib64 /lib64 \
    --ro-bind /bin /bin \
    --ro-bind /sbin /sbin \
    --ro-bind /opt/wine-staging /opt/wine-staging \
    --ro-bind /opt/qqmusic-wine /opt/qqmusic-wine \
    --bind "$USER_CONFIG_DIR" "$USER_CONFIG_DIR" \
    --bind "$HOME/.config/pulse" "$HOME/.config/pulse" 2>/dev/null || true \
    --bind "$HOME/.local/share/applications" "$HOME/.local/share/applications" 2>/dev/null || true \
    --ro-bind "$HOME/.Xauthority" "$HOME/.Xauthority" 2>/dev/null || true \
    --tmpfs /tmp \
    --proc /proc \
    --dev /dev \
    --tmpfs /run \
    --bind /run/user/"$(id -u)"/pulse /run/user/"$(id -u)"/pulse 2>/dev/null || true \
    --setenv WINEPREFIX "$USER_CONFIG_DIR/wineprefix" \
    --setenv PATH "/opt/wine-staging/bin:/usr/bin:/bin" \
    --setenv STAGING_SHARED_MEMORY "1" \
    --setenv STAGING_RT_PRIORITY_SERVER "1" \
    --setenv DXVK_LOG_LEVEL "warn" \
    --setenv DXVK_HUD "fps,memory" \
    --setenv DISPLAY "$DISPLAY" \
    --setenv XDG_RUNTIME_DIR "/run/user/$(id -u)" \
    --chdir "$QQMUSIC_PATH" \
    wine "QQMusic.exe" "$@"

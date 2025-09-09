# Maintainer: Your Name <your.email@example.com>
pkgname=qqmusic-wine
pkgver=19.71
pkgrel=1
pkgdesc="QQ音乐客户端，通过 Wine 运行"
arch=('x86_64')
url="https://y.qq.com/"
license=('custom')
depends=('wine-staging' 'winetricks' 'wine-gecko')
makedepends=('wine-staging' 'winetricks')
optdepends=('lib32-pulse: 音频支持'
            'lib32-mesa: 图形支持'
            'lib32-vulkan-icd-loader: DXVK Vulkan 支持')
source=("QQMusic_YQQWinPCDL.exe"
        "msyh.ttc::https://files.exefiles.com/initial/m/msyh-ttc/d9adc6d2c21171c0f0b8dfbaec764b83/msyh.ttc"
        "msyhbd.ttc::https://files.exefiles.com/initial/m/msyhbd-ttc/db132f98d50f02f0ddb4ce4a5d847c97/msyhbd.ttc"
        "qqmusic-launcher.sh"
        "qqmusic.desktop"
)
sha256sums=('efbb432421975c97d61d947c2bb0e1581026c1c3ad842d9881ff14b0a61e9d57'
            'd6a1a92bfd1249eccdd18a657189ed1f66704db429053b6d6c93b296eb9ef074'
            '0887451fa52c4685137a6df87720e607098ba81f14e7dd6f3d9c5319a558d59b'
            'e6017cdc7d7c1a28a14409ace6cc4c0f18f8e7cfeabef01b593825dc156cf1b7'
            '32573a27a2c820ae94bf537897ea23193a95cd7c0306a679d445e88e7ace996a')

prepare() {
    # 设置 Wine prefix
    export WINEPREFIX="$srcdir/wineprefix"
    export WINEARCH=win64
    # wine-staging 已安装在系统标准路径
    
    echo "正在初始化 Wine 环境..."
    wineboot --init
    
    # 等待 Wine 完全初始化
    sleep 3
    
    echo "正在安装必需组件..."
    # 按顺序安装您指定的组件
    winetricks -q vcrun2015
    winetricks -q gdiplus
    winetricks -q quartz
    winetricks -q riched20
    winetricks -q dxvk
    
    echo "正在配置中文字体..."
    # 复制微软雅黑字体到 Wine 字体目录
    cp "$srcdir/msyh.ttc" "$WINEPREFIX/drive_c/windows/Fonts/"
    cp "$srcdir/msyhbd.ttc" "$WINEPREFIX/drive_c/windows/Fonts/"
    
    # 创建字体注册表文件
    cat > "$WINEPREFIX/font.reg" << 'EOF2'
REGEDIT4

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes]
"MS Shell Dlg"="msyh"
"MS Shell Dlg 2"="msyh"

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink]
"Lucida Sans Unicode"="msyh.ttc"
"Microsoft Sans Serif"="msyh.ttc"
"MS Sans Serif"="msyh.ttc"
"Tahoma"="msyh.ttc"
"Tahoma Bold"="msyhbd.ttc"
"msyh"="msyh.ttc"
"Arial"="msyh.ttc"
"Arial Black"="msyh.ttc"
EOF2

    # 注册字体到 Wine
    wine regedit "$WINEPREFIX/font.reg"
    
    # 设置 Windows 版本为 Windows 7
    wine reg add "HKEY_CURRENT_USER\Software\Wine" /v Version /t REG_SZ /d win7
    
    # 配置 DPI 设置 (默认 96 DPI)
    wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v LogPixels /t REG_DWORD /d 96
    wine reg add "HKEY_CURRENT_USER\Software\Wine\X11 Driver" /v ClientSideGraphics /t REG_SZ /d N
    wine reg add "HKEY_CURRENT_USER\Software\Wine\X11 Driver" /v ScreenDepth /t REG_DWORD /d 24
    
    # 为音频播放优化设置 (48kHz, 24-bit)
    wine reg add "HKEY_CURRENT_USER\Software\Wine\DirectSound" /v MaxShadowSize /t REG_DWORD /d 8
    wine reg add "HKEY_CURRENT_USER\Software\Wine\DirectSound" /v DefaultSampleRate /t REG_DWORD /d 48000
    wine reg add "HKEY_CURRENT_USER\Software\Wine\DirectSound" /v DefaultBitsPerSample /t REG_DWORD /d 24
    
    echo "中文字体配置完成"
    echo "系统配置完成"
    echo "Wine 环境配置完成"
}

build() {
    export WINEPREFIX="$srcdir/wineprefix"
    # wine-staging 已安装在系统标准路径
    
    echo "正在安装 QQ音乐..."
    cd "$srcdir"
    
    # QQ音乐安装程序通常支持静默安装
    wine "QQMusic_YQQWinPCDL.exe" /S
    
    # 如果上面不工作，尝试其他参数
    # wine "QQMusic_YQQWinPCDL.exe" /VERYSILENT /NORESTART
}

package() {
    # 清理临时文件
    rm -rf "$srcdir/wineprefix/drive_c/users/$USER/AppData/Local/Temp"/*
    rm -rf "$srcdir/wineprefix/drive_c/users/$USER/AppData/Roaming/Microsoft/Windows/Recent"/*
    rm -rf "$srcdir/wineprefix/drive_c/windows/temp"/*
    
    # 安装 Wine prefix
    install -dm755 "$pkgdir/opt/$pkgname"
    cp -r "$srcdir/wineprefix" "$pkgdir/opt/$pkgname/"
    
    # 安装启动脚本
    install -Dm755 "$srcdir/qqmusic-launcher.sh" "$pkgdir/usr/bin/qqmusic-wine"
    
    # 安装桌面文件
    install -Dm644 "$srcdir/qqmusic.desktop" \
        "$pkgdir/usr/share/applications/qqmusic-wine.desktop"
    
    
    # 创建文档
    install -dm755 "$pkgdir/usr/share/doc/$pkgname"
    cat > "$pkgdir/usr/share/doc/$pkgname/README.md" << 'EOF2'
# QQ音乐 Wine 版本

## 已安装组件
- riched20: 富文本控件
- quartz: 媒体播放框架
- dxvk: DirectX 支持
- vcrun2015: Visual C++ 2015 运行库
- gdiplus: GDI+ 图形库
- wine-gecko: HTML 渲染引擎
- 微软雅黑字体: 解决中文显示问题

## 字体配置
已自动配置微软雅黑字体解决中文乱码问题。字体文件位置：
- msyh.ttc: 微软雅黑常规字体
- msyhbd.ttc: 微软雅黑粗体字体

## 启动方式
命令行: qqmusic-wine
桌面: 在应用程序菜单中找到 "QQ音乐"

## 故障排除
如果遇到问题，可以尝试：
1. 重新初始化配置目录: rm -rf ~/.config/qqmusic-wine
2. 查看详细日志: WINEDEBUG=+all qqmusic-wine
3. 禁用 DXVK: WINEDLLOVERRIDES="d3d11,dxgi=builtin" qqmusic-wine
4. 如果中文显示异常: 
   - 检查字体文件: ls ~/.config/qqmusic-wine/wineprefix/drive_c/windows/Fonts/msyh*
   - 重新配置字体: rm ~/.config/qqmusic-wine/wineprefix/font_configured && qqmusic-wine
EOF2
    
    # 设置权限
    chmod -R 755 "$pkgdir/opt/$pkgname"
}

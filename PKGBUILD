# Maintainer: Your Name <your.email@example.com>
pkgname=qqmusic-wine
pkgver=19.71
pkgrel=1
pkgdesc="QQ音乐客户端，通过 Wine 运行"
arch=('x86_64')
url="https://y.qq.com/"
license=('custom')
depends=('wine-staging' 'winetricks' 'wine-gecko' 'bubblewrap')
makedepends=('wine-staging' 'winetricks')
optdepends=('lib32-pulse: 音频支持'
            'lib32-mesa: 图形支持'
            'lib32-vulkan-icd-loader: DXVK Vulkan 支持')
conflicts=('wine')
source=("QQMusic_YQQWinPCDL.exe::https://dldir.y.qq.com/music/clntupate/QQMusic_YQQWinPCDL.exe?sign=1757381507-EGbYzfSyKpn6BWR2-0-e2aa04ee9774adb1c83e7ce63c67cffa"
        "msyh.ttc::https://files.exefiles.com/initial/m/msyh-ttc/d9adc6d2c21171c0f0b8dfbaec764b83/msyh.ttc"
        "msyhbd.ttc::https://files.exefiles.com/initial/m/msyhbd-ttc/db132f98d50f02f0ddb4ce4a5d847c97/msyhbd.ttc"
        "qqmusic-launcher.sh"
        "qqmusic.desktop"
        "font-config.reg")
sha256sums=('efbb432421975c97d61d947c2bb0e1581026c1c3ad842d9881ff14b0a61e9d57'
            'd6a1a92bfd1249eccdd18a657189ed1f66704db429053b6d6c93b296eb9ef074'
            '0887451fa52c4685137a6df87720e607098ba81f14e7dd6f3d9c5319a558d59b'
            'f387e99ef3b39e450e90d2e1a9f02b9ae94827a681aa1c7284775093f23d572a'
            '5448186b1bbdfb232317a89557540ccc4cc17cf59600bea225af7e02680b2449'
            '402f3fe7289bf7f17ae7c82606542ce28932427079f4273a0f554e2b210483fa')

prepare() {
    # 设置 Wine prefix
    export WINEPREFIX="$srcdir/wineprefix"
    export WINEARCH=win64
    export PATH="/opt/wine-staging/bin:$PATH"
    
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
    
    # 注册字体到 Wine
    wine regedit "$srcdir/font-config.reg"
    
    echo "中文字体配置完成"
    echo "Wine 环境配置完成"
}

build() {
    export WINEPREFIX="$srcdir/wineprefix"
    export PATH="/opt/wine-staging/bin:$PATH"
    
    echo "正在安装 QQ音乐..."
    cd "$srcdir"
    
    # QQ音乐安装程序通常支持静默安装
    wine "QQMusic_YQQWinPCDL.exe" /S
    
    # 如果上面不工作，尝试其他参数
    # wine "QQMusic_YQQWinPCDL.exe" /VERYSILENT /NORESTART
}

package() {
    # 安装 Wine prefix
    install -dm755 "$pkgdir/opt/$pkgname"
    cp -r "$srcdir/wineprefix" "$pkgdir/opt/$pkgname/"
    
    # 安装启动脚本
    install -Dm755 "$srcdir/qqmusic-launcher.sh" "$pkgdir/usr/bin/qqmusic"
    
    # 安装桌面文件
    install -Dm644 "$srcdir/qqmusic.desktop" \
        "$pkgdir/usr/share/applications/qqmusic.desktop"
    
    # 安装字体配置文件
    install -Dm644 "$srcdir/font-config.reg" "$pkgdir/opt/$pkgname/font-config.reg"
    
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
命令行: qqmusic
桌面: 在应用程序菜单中找到 "QQ音乐"

## 故障排除
如果遇到问题，可以尝试：
1. 重新初始化配置目录: rm -rf ~/.config/qqmusic-wine
2. 查看详细日志: WINEDEBUG=+all qqmusic
3. 禁用 DXVK: WINEDLLOVERRIDES="d3d11,dxgi=builtin" qqmusic
4. 如果中文显示异常: 
   - 检查字体文件: ls ~/.config/qqmusic-wine/wineprefix/drive_c/windows/Fonts/msyh*
   - 重新配置字体: rm ~/.config/qqmusic-wine/wineprefix/font_configured && qqmusic
EOF2
    
    # 设置权限
    chmod -R 755 "$pkgdir/opt/$pkgname"
}

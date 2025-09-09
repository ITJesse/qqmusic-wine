# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Two Arch Linux packages for running Tencent QQ Music on Linux through Wine:

### qqmusic-installer/
- Uses official QQ Music installer
- Downloads and runs installer during build

### qqmusic-bin/ (Recommended)
- Uses pre-extracted program files  
- Faster build, smaller size (89MB)

Both use command: `qqmusic-wine`

Both packages include Wine environment setup, Chinese fonts, and runtime libraries.

## Architecture

### Wine Environment Setup
- Uses `wine-staging` (conflicts with regular `wine`)  
- Requires 64-bit Wine architecture (`WINEARCH=win64`)
- Wine prefix location: `~/.config/qqmusic-wine/wineprefix` (user-specific)

### Dependencies and Components
**Core dependencies:** `wine-staging`, `winetricks`, `wine-gecko`
**Installed Windows components:** `vcrun2015`, `gdiplus`, `quartz`, `riched20`, `dxvk`
**Chinese font support:** Downloads and configures Microsoft YaHei fonts (`msyh.ttc`, `msyhbd.ttc`)

### Key Design Patterns
1. **System vs User Separation**: Package installs template Wine prefix to `/opt/qqmusic-wine/`, launcher copies to user directory on first run
2. **Font Handling**: Separate `font-config.reg` file provides Windows registry configuration for Chinese font substitution to solve character display issues
3. **Audio Optimization**: DirectSound registry settings for music playback quality (48kHz, 24-bit)
4. **Security Sandboxing**: Uses bubblewrap to isolate QQ Music in a restricted environment with minimal filesystem access

## Common Development Commands

### Building the Package
```bash
makepkg -si          # Build and install package
makepkg -f           # Force rebuild (if already built)
```

### Testing and Debugging
```bash
WINEDEBUG=+all qqmusic              # Full Wine debug output
WINEDLLOVERRIDES="d3d11,dxgi=builtin" qqmusic  # Disable DXVK for testing
strace -f qqmusic 2>&1 | grep bwrap # Debug bubblewrap sandboxing
```

### Configuration Reset
```bash
rm -rf ~/.config/qqmusic-wine       # Reset user configuration
rm ~/.config/qqmusic-wine/wineprefix/font_configured  # Reset font config only
```

## File Locations

- **Package template**: `/opt/qqmusic-wine/wineprefix/`
- **User runtime**: `~/.config/qqmusic-wine/wineprefix/`
- **QQ Music executable**: `[prefix]/drive_c/Program Files/Tencent/QQMusic/QQMusic.exe`
- **Fonts**: `[prefix]/drive_c/windows/Fonts/msyh*.ttc`
- **Font registry config**: `/opt/qqmusic-wine/font-config.reg`

## Environment Variables

Key environment variables used by the launcher:
- `WINEPREFIX`: Points to user-specific Wine prefix
- `STAGING_SHARED_MEMORY=1`: Wine-staging optimization
- `DXVK_LOG_LEVEL=warn`: DXVK logging level
- `PATH="/opt/wine-staging/bin:$PATH"`: Ensure wine-staging is used

## Troubleshooting Architecture

The launcher includes built-in diagnostics:
1. Checks for QQ Music installation in both Program Files locations
2. Auto-reconfigures fonts if registry settings are missing
3. Provides clear error messages for missing components
4. Graceful handling of missing audio/X11 directories in bubblewrap sandbox

## Security Features

- **Namespace isolation**: Unshares all namespaces except network
- **Read-only system**: System directories mounted read-only
- **Restricted filesystem**: Only essential directories accessible
- **Session isolation**: Runs in separate session with parent death cleanup
- **Audio access**: Selective PulseAudio socket binding for music playback
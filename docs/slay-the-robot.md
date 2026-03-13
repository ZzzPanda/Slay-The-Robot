# Slay-The-Robot 项目 Memory

## 项目信息

- **位置**: `~/openclaw/workspace/game/Slay-The-Robot/`
- **引擎**: Godot 4.6.1
- **远程**: https://github.com/ZzzPanda/Slay-The-Robot
- **分支**: main

## 问题记录

### Android 资源加载问题

**现象**: Android APK 中蓝色/绿色角色图片不显示

**根因**: `FileLoader.gd` 在 Android 上使用了错误的路径逻辑
- 原代码：检测到 "exported" 特性后，使用 exe 目录路径
- Android：资源在 APK 内部，不是 exe 旁边

**修复方案**:
```gdscript
# autoload/FileLoader.gd _ready() 中添加
elif OS.get_name() == "Android":
    _EXTERNAL_FILE_PREFIX = "res://"
```

**PR**: https://github.com/ZzzPanda/Slay-The-Robot/pull/6

## 打包相关

### 手动打包流程（解决 Godot headless 导出报错）

```bash
# 1. 导出 pck
cd ~/openclaw/workspace/game/Slay-The-Robot
godot --headless --export-pack "Android" "builds/android/game.pck"

# 2. 解压导出模板
cd builds/android
mkdir tmp_apk
cd tmp_apk
unzip -q ~/.local/share/godot/export_templates/4.6.1.stable/android_release.apk

# 3. 替换 pck
cp ../game.pck assets/game.pck

# 4. 打包
zip -r ../game.apk .

# 5. 签名
~/Library/Android/sdk/build-tools/33.0.1/apksigner sign \
  --ks ~/.android/debug.keystore \
  --ks-key-alias androiddebugkey \
  --ks-pass pass:android \
  --key-pass pass:android \
  --out Slay-the-robot-{date}-{time}.apk \
  game.apk

# 6. 清理
rm -rf tmp_apk game.pck game.apk
```

### APK 签名密钥

- keystore: `~/.android/debug.keystore`
- alias: `androiddebugkey`
- password: `android`

### 最新 APK

- `android_debug_20260313_1638.apk` (98MB) - 包含 SDK 修复

## 打包命令（已验证可用）

### 方式一：手动打包（推荐，解决 headless 导出报错）

```bash
cd ~/openclaw/workspace/game/Slay-The-Robot

# 设置 Android SDK
export ANDROID_HOME=/Users/roger/Android
export ANDROID_SDK_ROOT=/Users/roger/Android

# 1. 导出 pck
godot --headless --export-pack "Android" "builds/android/game.pck"

# 2. 手动组装 APK
cd builds/android
mkdir -p tmp_apk && cd tmp_apk
unzip -q ~/.local/share/godot/export_templates/4.6.1.stable/android_release.apk
cp ../game.pck assets/game.pck
zip -rq ../game.apk .

# 3. 签名（带时间戳）
TIMESTAMP=$(date +%Y%m%d_%H%M)
~/Library/Android/sdk/build-tools/33.0.1/apksigner sign \
  --ks ~/.android/debug.keystore \
  --ks-key-alias androiddebugkey \
  --ks-pass pass:android \
  --key-pass pass:android \
  --out "Slay-the-robot-${TIMESTAMP}.apk" \
  ../game.apk

# 4. 清理并复制到 Google Drive
rm -rf tmp_apk game.pck game.apk
cp "Slay-the-robot-${TIMESTAMP}.apk" "/Users/roger/Google 云端硬盘/apk/Slay-The-Robot/android_debug_${TIMESTAMP}.apk"
```

## 待办

- [ ] 合并 PR 后重新用 Godot 导出测试
- [ ] 调查 Godot headless 导出报错原因（可能是 adb daemon 或配置问题）

# Slay The Robot APK 打包流程

## 当前方案（已验证可用）

```mermaid
flowchart TB
    subgraph Step1 ["步骤1: 导出 PCK"]
        A["Godot 项目代码"] --> B["godot --export-pack\ngame.pck"]
    end

    subgraph Step2 ["步骤2: 替换到旧 APK"]
        C["旧 APK 模板\n(android_debug.apk)"] --> D["unzip 解压"]
        B --> E["替换 assets/game.pck"]
        D --> E
    end

    subgraph Step3 ["步骤3: 重新打包"]
        E --> F["zip 打包\n(保留原始签名)"]
    end

    G["最终 APK\nandroid_debug_YYYYMMDD_HHMM.apk"]

    F --> G

    style G fill:#90EE90,stroke:#228B22
    style B fill:#FFE4B5,stroke:#FF8C00
    style F fill:#FFE4B5,stroke:#FF8C00
```

## 关键步骤

### 1. 导出 PCK
```bash
cd ~/openclaw/workspace/game/Slay-The-Robot
godot --headless --export-pack "Android" "builds/android/game.pck"
```

### 2. 替换到旧 APK（保留签名）
```bash
cd builds/android

# 复制旧 APK 并解压
cp "/Users/roger/Google 云端硬盘/apk/Slay-The-Robot/android_debug.apk" old.apk
unzip -q old.apk -d extracted

# 替换 game.pck
cp game.pck extracted/assets/game.pck

# 重新打包（保留 META-INF 签名）
cd extracted
zip -rq ../final.apk .
```

### 3. 关键发现

| 方法 | 结果 |
|------|------|
| `apksigner sign` | ❌ 签名变成 Android Debug |
| `zip` 直接打包 | ✅ 保留原始 Godot 签名 |

## 一键脚本

```bash
# scripts/build_android_manual.sh
```

## 问题排查

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 安装失败 | 签名不一致 | 用旧 APK 保留原始 Godot 签名 |
| pck 位置错误 | 模板结构 | game.pck 放到 `assets/` 文件夹 |
| Manifest 错误 | 用了模板默认 | 从旧 APK 提取 AndroidManifest.xml |

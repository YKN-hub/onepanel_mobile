# 1Panel Client - GitHub Actions 构建指南

## 快速开始

### 1. Fork 仓库 (推荐)

1. 点击页面右上角 **Fork** 按钮
2. 等待 Fork 完成
3. 克隆你的 Fork:
```bash
git clone https://github.com/YOUR_USERNAME/onepanel_mobile.git
cd onepanel_mobile
```

### 2. 直接使用 (如果你有仓库权限)

```bash
git clone https://github.com/YOUR_USERNAME/onepanel_mobile.git
cd onepanel_mobile
```

---

## GitHub Actions 工作流

项目已配置以下工作流:

| 工作流 | 文件 | 触发条件 | 功能 |
|--------|------|----------|------|
| **Build iOS** | `.github/workflows/build-ios.yml` | push/tag | 构建 iOS 和 Android |
| **CI** | `.github/workflows/ci.yml` | push/PR | 多平台构建 |
| **Test** | `.github/workflows/test.yml` | push/PR | 测试和代码分析 |
| **Quality** | `.github/workflows/quality.yml` | push/PR | 代码质量检查 |
| **Setup** | `.github/workflows/setup.yml` | manual | 开发环境设置 |

---

## 手动触发构建

### 方法 1: GitHub Actions 页面

1. 打开 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择 **Build iOS** 工作流
4. 点击 **Run workflow**
5. 选择构建类型 (debug/release/archive)

### 方法 2: GitHub CLI

```bash
# 安装 GitHub CLI
# https://cli.github.com/

# 触发工作流
gh workflow run build-ios.yml --ref main

# 查看运行状态
gh run list --workflow=build-ios.yml
```

### 方法 3: 创建标签

```bash
# 创建标签触发构建
git tag v0.1.0
git push origin v0.1.0
```

---

## 构建产物

构建完成后，产物会作为 **Artifacts** 下载:

### iOS 产物
- `build/ios/iphoneos/Runner.app` - iOS 应用
- `build/ios/iphoneos/Runner.dSYM` - 调试符号

### Android 产物
- `build/app/outputs/apk/release/app-release.apk` - Android APK
- `build/app/outputs/bundle/release/app-release.aab` - Android App Bundle

### 下载产物

1. 进入 Actions 页面
2. 点击完成的运行
3. 在 **Artifacts** 部分下载

---

## 真机测试 iOS

### 方法 1: 使用模拟器 (推荐)

```bash
# 在 Mac 上
flutter run
```

### 方法 2: 使用 TestFlight

1. 在 Apple Developer 创建 App ID
2. 创建 Provisioning Profile
3. 在 Xcode 中配置签名
4. 构建 archive
5. 上传到 App Store Connect
6. 通过 TestFlight 测试

### 方法 3: 直接安装到设备

```bash
# 在 Mac 上
flutter run --release
```

---

## 环境要求

### GitHub Actions Runner

| Runner | 操作系统 | Xcode | Flutter |
|--------|----------|-------|---------|
| `macos-latest` | macOS 14 | 15.2 | 3.16.0 |
| `ubuntu-latest` | Ubuntu 22.04 | - | 3.16.0 |
| `windows-latest` | Windows 2022 | - | 3.16.0 |

### 本地开发

- **Flutter**: 3.16.0+
- **Dart**: 3.6+
- **Xcode**: 15.2+ (iOS)
- **CocoaPods**: 1.12+ (iOS)

---

## 自定义构建

### 修改 Flutter 版本

编辑 `.github/workflows/build-ios.yml`:
```yaml
env:
  FLUTTER_VERSION: '3.16.0'  # 修改此值
```

### 修改 Xcode 版本

编辑 `.github/workflows/build-ios.yml`:
```yaml
env:
  XCODE_VERSION: '15.2'  # 修改此值
```

### 添加环境变量

在 `build-ios.yml` 中添加:
```yaml
env:
  FLUTTER_VERSION: '3.16.0'
  APP_NAME: '1Panel Client'
  BUNDLE_ID: 'com.example.onepanel'
```

---

## 常见问题

### 1. CocoaPods 安装失败

```yaml
# 在 build-ios.yml 中添加
- name: Install CocoaPods
  run: |
    sudo gem install cocoapods
    pod setup
```

### 2. iOS 签名问题

GitHub Actions 使用 `--no-codesign` 参数，不会进行签名。

如需签名，需要:
1. 在 Apple Developer 创建证书
2. 添加 Provisioning Profile 到 GitHub Secrets
3. 配置签名脚本

### 3. 构建超时

默认超时 6 小时。如需修改:
```yaml
jobs:
  build-ios:
    timeout-minutes: 120  # 2小时
```

### 4. 依赖下载失败

添加缓存:
```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v4
  with:
    path: pubspec.lock
    key: ${{ runner.os }}-flutter-${{ hashFiles('pubspec.lock') }}
```

---

## 发布新版本

### 使用 release.sh 脚本

```bash
# 在 Mac/Linux 上
chmod +x scripts/release.sh
./scripts/release.sh 0.1.0
```

### 手动发布

```bash
# 1. 确保在 main 分支
git checkout main

# 2. 拉取最新代码
git pull

# 3. 创建标签
git tag -a v0.1.0 -m "Release v0.1.0"

# 4. 推送到 GitHub
git push origin main
git push origin v0.1.0
```

---

## 监控构建

### GitHub 通知

1. 进入仓库 **Settings** > **Notifications**
2. 配置通知方式 (Email, Slack, 等)

### 使用 GitHub CLI

```bash
# 查看运行状态
gh run list

# 查看运行日志
gh run view <run_id>

# 下载产物
gh run download <run_id> -n ios-build
```

---

## 下一步

1. **Fork 仓库**
2. **修改代码**
3. **提交更改**
4. **触发构建**
5. **下载产物**
6. **测试应用**

---

## 需要帮助？

- GitHub Actions 文档: https://docs.github.com/en/actions
- Flutter 文档: https://flutter.dev/docs
- 1Panel API 文档: https://1panel.pro/docs/v1/dev_manual/api_manual/

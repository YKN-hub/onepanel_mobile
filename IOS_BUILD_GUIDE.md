# 1Panel Client iOS 构建指南

## 前置条件

在 Mac 上构建 iOS 应用需要：

1. **macOS 系统** (10.15 或更高)
2. **Xcode** (14 或更高) - 从 App Store 安装
3. **Flutter SDK** (3.16+)
4. **CocoaPods** (用于 iOS 依赖管理)

---

## 步骤 1: 安装 Flutter

```bash
# 下载 Flutter SDK
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# 添加到 PATH
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 验证安装
flutter doctor
```

---

## 步骤 2: 安装 Xcode

1. 从 Mac App Store 安装 **Xcode**
2. 安装完成后，打开 Xcode 并接受许可协议
3. 安装命令行工具：
```bash
xcode-select --install
```

---

## 步骤 3: 安装 CocoaPods

```bash
sudo gem install cocoapods
```

---

## 步骤 4: 配置 Flutter iOS 工具链

```bash
# 检查 Flutter 环境
flutter doctor

# 确保 iOS 工具链已配置
flutter doctor --android-licenses  # 如果不需要 Android 可跳过
```

---

## 步骤 5: 下载项目并构建

```bash
# 克隆或下载项目
cd ~
unzip onepanel_mobile.zip  # 如果你下载了压缩包
cd onepanel_mobile

# 获取依赖
flutter pub get

# 检查 iOS 配置
flutter build ios --help
```

---

## 步骤 6: 在模拟器运行

```bash
# 启动 iOS 模拟器
open -a Simulator

# 或从命令行启动
xcrun simctl list devices  # 查看可用设备
xcrun simctl boot "iPhone 15"  # 启动特定设备

# 运行应用
flutter run
```

---

## 步骤 7: 构建 iOS 应用

### 调试版本
```bash
flutter build ios --debug
```

### 发布版本
```bash
flutter build ios --release
```

### 构建 .xcarchive (用于 TestFlight/App Store)
```bash
flutter build ios --release --no-codesign
```

---

## 步骤 8: 在 Xcode 中打开

```bash
# 打开 iOS 项目
open ios/Runner.xcworkspace
```

在 Xcode 中：
1. 选择目标设备 (模拟器或真机)
2. 选择 Team (用于真机调试)
3. 点击 Run 按钮构建

---

## 真机调试

### 配置开发证书

1. 打开 Xcode
2. 选择 `ios/Runner.xcworkspace`
3. 选择 Runner 项目
4. 在 Signing & Capabilities 中：
   - 选择你的 Apple ID 作为 Team
   - 自动管理签名

### 信任开发者证书

在 iPhone 上：
1. 设置 → 通用 → VPN 与设备管理
2. 信任你的开发者证书

### 运行到真机

```bash
# 连接 iPhone 到 Mac
flutter devices  # 查看已连接设备
flutter run  # 运行到连接的设备
```

---

## 常见问题

### 1. CocoaPods 错误

```bash
# 删除 Podfile.lock 和 Pods 目录后重新安装
rm -rf ios/Pods ios/Podfile.lock
cd ios
pod install --repo-update
```

### 2. 签名错误

在 Xcode 中：
- 选择正确的 Team
- 确保 Bundle Identifier 唯一
- 自动管理签名

### 3. 模拟器架构问题

```bash
# 确保模拟器是 64 位 (iPhone 5s 及以上)
flutter run --debug
```

### 4. 网络权限

Info.plist 已配置：
- `NSAllowsArbitraryLoads` = true (允许 HTTP 请求)
- `NSAllowsLocalNetworking` = true (允许本地网络)

---

## 项目文件位置

```
onepanel_mobile/
├── lib/           # Flutter 源代码
├── ios/           # iOS 原生配置
├── android/       # Android 原生配置
├── pubspec.yaml   # 依赖配置
└── README.md      # 项目文档
```

---

## 快速开始命令

```bash
# 完整流程
cd onepanel_mobile
flutter pub get
flutter run
```

---

## 注意事项

1. **iOS 开发必须使用 Mac** - Windows 无法构建 iOS 应用
2. **真机测试需要 Apple 开发者账号** - 免费账号即可
3. **模拟器不需要开发者账号** - 可直接运行
4. **首次运行需要下载 iOS 依赖** - 可能需要几分钟

---

## 需要帮助？

- Flutter 官方文档: https://flutter.dev/docs
- iOS 开发文档: https://developer.apple.com/documentation/
- 1Panel API 文档: https://1panel.pro/docs/v1/dev_manual/api_manual/

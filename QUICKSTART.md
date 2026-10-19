# 1Panel Client - 快速开始指南

## 5 分钟快速开始

### 1. 安装必要工具

```bash
# Windows
# 1. 安装 Git: https://git-scm.com/download/win
# 2. 安装 Flutter: https://flutter.dev/docs/get-started/install/windows

# Mac
# 1. 安装 Xcode: App Store
# 2. 安装 Flutter: brew install flutter
```

### 2. 下载项目

```bash
# 方法 1: 下载 ZIP
# 从 Windows 文件管理器复制 onepanel_mobile 文件夹到 Mac

# 方法 2: 克隆 GitHub 仓库
git clone https://github.com/YOUR_USERNAME/onepanel_mobile.git
cd onepanel_mobile
```

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 配置 1Panel 服务器

在 1Panel 面板中:
1. 进入 **面板设置** → **API 接口**
2. 开启 API 开关
3. 复制 API Key
4. 添加 IP 白名单 (移动端可设置 `0.0.0.0/0`)

### 5. 运行应用

```bash
# 在 Mac 上
flutter run

# 或构建 iOS
flutter build ios --release
```

---

## GitHub Actions 自动化

### 推送代码触发构建

```bash
# 配置 Git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# 初始化仓库
cd onepanel_mobile
git init
git add -A
git commit -m "Initial commit"

# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/onepanel_mobile.git

# 推送
git branch -M main
git push -u origin main
```

### 查看构建状态

1. 打开 https://github.com/YOUR_USERNAME/onepanel_mobile
2. 点击 **Actions** 标签
3. 选择 **Build iOS** 工作流
4. 查看构建日志和下载产物

---

## 项目结构

```
onepanel_mobile/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── core/                  # 核心层
│   ├── data/                  # 数据层
│   ├── api/                   # API 层
│   ├── pages/                 # 11 个页面
│   └── widgets/               # 小部件
├── ios/                       # iOS 配置
├── android/                   # Android 配置
├── .github/workflows/         # GitHub Actions
├── scripts/                   # 构建脚本
├── setup.sh                   # 一键设置
├── setup.bat                  # Windows 设置
├── README.md                  # 项目文档
├── GITHUB_ACTIONS_GUIDE.md    # GitHub Actions 指南
├── GITHUB_PUSH_GUIDE.md       # 推送指南
└── IOS_BUILD_GUIDE.md         # iOS 构建指南
```

---

## 功能模块

| 模块 | 状态 | 说明 |
|------|------|------|
| 仪表盘 | ✅ | 服务器概览、资源使用率 |
| 服务器管理 | ✅ | 多服务器、SSL 支持 |
| 容器管理 | ✅ | 启停/重启/日志 |
| 网站管理 | ✅ | 启停/域名信息 |
| 数据库管理 | ✅ | MySQL/PostgreSQL/Redis |
| 文件管理 | ✅ | 浏览/创建/删除/重命名 |
| 监控 | ✅ | CPU/内存/网络图表 |
| 设置 | ✅ | 系统信息/重启/关机 |

---

## 常见问题

### Q: iOS 构建失败？

A: 确保在 Mac 上使用 Xcode 15.2+ 构建

### Q: 如何测试 API 连接？

A: 在应用中添加服务器时，点击"测试连接"按钮

### Q: 支持哪些数据库？

A: MySQL, MariaDB, PostgreSQL, Redis, MongoDB

### Q: 如何添加新功能？

A: 1. 创建新分支 2. 修改代码 3. 提交 PR 4. 合并到 main

---

## 下一步

1. **推送代码到 GitHub**
2. **触发 GitHub Actions 构建**
3. **下载 iOS 构建产物**
4. **在 iPhone 上测试**

---

## 需要帮助？

- 项目文档: README.md
- GitHub 指南: GITHUB_ACTIONS_GUIDE.md
- 推送指南: GITHUB_PUSH_GUIDE.md
- iOS 构建: IOS_BUILD_GUIDE.md

# 1Panel Client - 推送完成指南

## ✅ 推送成功！

如果脚本运行成功，你的代码已推送到 GitHub。

---

## 🚀 触发 GitHub Actions 构建

### 方法 1: 在 GitHub 网站操作

1. 打开: https://github.com/YKN-hub/onepanel_mobile
2. 点击 **Actions** 标签
3. 选择 **Build iOS** 工作流
4. 点击 **Run workflow**
5. 选择构建类型: `debug` 或 `release`
6. 等待构建完成

### 方法 2: 创建标签触发

```bash
git tag v0.1.0
git push origin v0.1.0
```

---

## 📥 下载构建产物

1. 进入 **Actions** 页面
2. 点击完成的运行
3. 在 **Artifacts** 部分下载:
   - `ios-build` - iOS 应用
   - `android-build` - Android 应用

---

## ⚠️ 安全提醒

**请立即撤销此 Token！**

1. 打开: https://github.com/settings/tokens
2. 找到 `1Panel Client` 这个 token
3. 点击 **Delete** 或 **Revoke**

---

## 📱 在 iPhone 上测试

### 方法 1: 使用 TestFlight

1. 在 Xcode 中配置签名
2. 构建 archive
3. 上传到 App Store Connect
4. 通过 TestFlight 测试

### 方法 2: 直接安装

在 Mac 上:
```bash
git clone https://github.com/YKN-hub/onepanel_mobile.git
cd onepanel_mobile
flutter run
```

---

## 📞 需要帮助？

- 项目文档: README.md
- GitHub 指南: GITHUB_ACTIONS_GUIDE.md
- 推送指南: GITHUB_PUSH_GUIDE.md

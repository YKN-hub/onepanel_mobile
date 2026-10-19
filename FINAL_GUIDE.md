# 1Panel Client - 最终推送指南

## 🎯 最简单的方法：在 GitHub 网站操作

### 第 1 步：创建仓库

1. 打开：https://github.com/new
2. 填入：
   - Repository name: `onepanel_mobile`
   - 选择 **Public**
   - 点击 **Create repository**

### 第 2 步：上传文件

1. 进入仓库页面
2. 点击 **Uploading existing files**
3. 选择 `C:\Users\Administrator\codearts\2026-10-19-10-39-29\onepanel_mobile` 文件夹中的所有文件
4. 拖拽或点击选择文件
5. 点击 **Commit changes**

### 第 3 步：触发构建

1. 点击 **Actions** 标签
2. 选择 **Build iOS** 工作流
3. 点击 **Run workflow**

---

## 📦 项目文件位置

```
C:\Users\Administrator\codearts\2026-10-19-10-39-29\onepanel_mobile
```

### 需要上传的文件

| 文件/文件夹 | 说明 |
|-------------|------|
| `lib/` | 源代码 (必须) |
| `ios/` | iOS 配置 (必须) |
| `android/` | Android 配置 (可选) |
| `pubspec.yaml` | 依赖配置 (必须) |
| `pubspec.lock` | 依赖锁定 (必须) |
| `README.md` | 项目说明 (可选) |

### 不需要上传的文件

- `push_*.bat` - 推送脚本
- `push_*.ps1` - 推送脚本
- `*.json` - 临时文件
- `*.md` - 文档 (可选)

---

## ⚠️ 安全提醒

**请立即撤销此 Token！**

1. 打开：https://github.com/settings/tokens
2. 找到 `1Panel Client` 这个 token
3. 点击 **Delete** 或 **Revoke**

---

## 🚀 如果脚本运行成功

双击运行：
```
C:\Users\Administrator\codearts\2026-10-19-10-39-29\onepanel_mobile\push_final.bat
```

---

## 📞 需要帮助？

- 如果上传失败，请告诉我具体错误信息
- 如果构建失败，请查看 Actions 日志
- 如果需要修改代码，请告诉我具体需求

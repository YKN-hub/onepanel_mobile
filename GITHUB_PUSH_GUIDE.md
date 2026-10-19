# 1Panel Client - GitHub 推送指南

## 第一步: 安装 Git

### Windows 安装 Git

1. 下载 Git for Windows: https://git-scm.com/download/win
2. 运行安装程序，使用默认设置
3. 打开 Git Bash 或 PowerShell

### 验证安装

```bash
git --version
```

---

## 第二步: 配置 Git

```bash
# 设置用户名
git config --global user.name "Your Name"

# 设置邮箱
git config --global user.email "your-email@example.com"

# 检查配置
git config --list
```

---

## 第三步: 创建 GitHub 仓库

### 方法 1: GitHub 网站

1. 登录 GitHub: https://github.com
2. 点击右上角 **+** 号，选择 **New repository**
3. 填写信息:
   - Repository name: `onepanel_mobile`
   - Description: `1Panel Client - 1Panel 第三方全平台客户端`
   - 选择 **Public**
   - **不要** 勾选 "Add a README file" (已有)
   - **不要** 添加 .gitignore (已有)
   - **不要** 添加 license (已有)
4. 点击 **Create repository**

### 方法 2: GitHub CLI

```bash
# 安装 GitHub CLI
# https://cli.github.com/

# 登录
gh auth login

# 创建仓库
gh repo create onepanel_mobile --public --description "1Panel Client"
```

---

## 第四步: 推送代码

### 在 Windows 上 (PowerShell)

```powershell
# 1. 进入项目目录
cd C:\Users\Administrator\codearts\2026-10-19-10-39-29\onepanel_mobile

# 2. 初始化 Git (如果未初始化)
git init

# 3. 添加远程仓库
# 替换 YOUR_USERNAME 为你的 GitHub 用户名
git remote add origin https://github.com/YOUR_USERNAME/onepanel_mobile.git

# 4. 添加所有文件
git add -A

# 5. 提交
git commit -m "Initial commit: 1Panel Client iOS app

- 完整仪表盘、服务器、容器、网站、数据库、文件、监控模块
- 60+ 数据模型
- GitHub Actions iOS/Android 构建工作流
- 中英文国际化支持
- 多服务器管理"

# 6. 推送到 GitHub
git branch -M main
git push -u origin main
```

### 在 Mac/Linux 上

```bash
# 1. 进入项目目录
cd /path/to/onepanel_mobile

# 2. 初始化 Git (如果未初始化)
git init

# 3. 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/onepanel_mobile.git

# 4. 添加所有文件
git add -A

# 5. 提交
git commit -m "Initial commit: 1Panel Client iOS app"

# 6. 推送到 GitHub
git branch -M main
git push -u origin main
```

---

## 第五步: 触发 GitHub Actions 构建

### 方法 1: 推送代码后自动触发

```bash
# 推送到 main 分支
git push origin main

# 或推送到 develop 分支
git push origin develop
```

### 方法 2: 创建标签触发发布构建

```bash
# 创建版本标签
git tag v0.1.0

# 推送标签
git push origin v0.1.0
```

### 方法 3: 手动触发

1. 打开 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择 **Build iOS** 工作流
4. 点击 **Run workflow**

---

## 第六步: 下载构建产物

1. 进入 **Actions** 页面
2. 点击完成的运行
3. 在 **Artifacts** 部分下载:
   - `ios-build` - iOS 应用
   - `android-build` - Android 应用
   - `test-coverage` - 测试覆盖率

---

## 快速命令参考

```bash
# 查看状态
git status

# 查看提交历史
git log --oneline

# 查看远程仓库
git remote -v

# 拉取最新代码
git pull origin main

# 添加新文件
git add <file>

# 提交
git commit -m "message"

# 推送
git push origin main

# 创建分支
git checkout -b feature/new-feature

# 切换分支
git checkout main

# 合并分支
git merge feature/new-feature

# 删除分支
git branch -d feature/new-feature
```

---

## 常见问题

### 1. 推送失败: "Permission denied"

```bash
# 检查 SSH 密钥
ssh -T git@github.com

# 或使用 HTTPS
git remote set-url origin https://github.com/YOUR_USERNAME/onepanel_mobile.git
```

### 2. 推送失败: "Updates were rejected"

```bash
# 拉取远程代码并合并
git pull origin main --rebase

# 再次推送
git push origin main
```

### 3. 忘记添加远程仓库

```bash
# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/onepanel_mobile.git

# 设置上游分支
git branch -M main
git push -u origin main
```

### 4. 提交错误

```bash
# 修改最后一次提交
git commit --amend -m "New message"

# 取消暂存
git reset HEAD <file>

# 完全撤销提交 (保留更改)
git reset --soft HEAD~1

# 完全撤销提交 (丢弃更改)
git reset --hard HEAD~1
```

---

## 下一步

1. **推送代码到 GitHub**
2. **在 Actions 页面查看构建状态**
3. **下载 iOS 构建产物**
4. **在 Mac 上测试应用**

---

## 需要帮助？

- Git 文档: https://git-scm.com/doc
- GitHub 文档: https://docs.github.com
- GitHub CLI: https://cli.github.com

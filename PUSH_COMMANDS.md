# 1Panel Client 推送命令

# ============================================================
# 在 Windows PowerShell 中执行以下命令
# 替换 YOUR_USERNAME 为你的 GitHub 用户名
# ============================================================

# 1. 进入项目目录
Set-Location "C:\Users\Administrator\codearts\2026-10-19-10-39-29\onepanel_mobile"

# 2. 初始化 Git 仓库
git init

# 3. 添加所有文件
git add -A

# 4. 提交
git commit -m "Initial commit: 1Panel Client iOS app`n`n- 完整仪表盘、服务器、容器、网站、数据库、文件、监控模块`n- 60+ 数据模型`n- GitHub Actions iOS/Android 构建工作流`n- 中英文国际化支持`n- 多服务器管理"

# 5. 添加远程仓库 (替换 YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/onepanel_mobile.git

# 6. 设置主分支
git branch -M main

# 7. 推送到 GitHub
git push -u origin main

# ============================================================
# 推送完成后，触发 GitHub Actions 构建
# ============================================================

# 方法 1: 创建标签触发发布构建
git tag v0.1.0
git push origin v0.1.0

# 方法 2: 在 GitHub 网站手动触发
# 1. 打开 https://github.com/YOUR_USERNAME/onepanel_mobile
# 2. 点击 Actions 标签
# 3. 选择 Build iOS 工作流
# 4. 点击 Run workflow

# ============================================================
# 查看构建产物
# ============================================================

# 1. 进入 Actions 页面
# 2. 点击完成的运行
# 3. 在 Artifacts 部分下载:
#    - ios-build (iOS 应用)
#    - android-build (Android 应用)

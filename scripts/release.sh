#!/bin/bash

# 1Panel Client - GitHub 发布脚本
# 使用方法: ./scripts/release.sh [version]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查参数
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供版本号${NC}"
    echo "使用方法: $0 [version]"
    echo "示例: $0 0.1.0"
    exit 1
fi

VERSION=$1

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  1Panel Client 发布脚本${NC}"
echo -e "${GREEN}  版本: $VERSION${NC}"
echo -e "${GREEN}======================================${NC}"

# 检查 Git 状态
echo -e "\n${YELLOW}1. 检查 Git 状态...${NC}"
if ! git diff --quiet; then
    echo -e "${RED}错误: 有未提交的更改${NC}"
    git status
    exit 1
fi

# 检查当前分支
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}警告: 当前在 $CURRENT_BRANCH 分支，建议在 main 分支发布${NC}"
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 拉取最新代码
echo -e "\n${YELLOW}2. 拉取最新代码...${NC}"
git pull origin main

# 安装依赖
echo -e "\n${YELLOW}3. 安装依赖...${NC}"
flutter pub get

# 运行测试
echo -e "\n${YELLOW}4. 运行测试...${NC}"
flutter test || {
    echo -e "${RED}测试失败，请修复后再发布${NC}"
    exit 1
}

# 代码分析
echo -e "\n${YELLOW}5. 代码分析...${NC}"
flutter analyze || {
    echo -e "${RED}代码分析失败，请修复后再发布${NC}"
    exit 1
}

# 创建标签
echo -e "\n${YELLOW}6. 创建 Git 标签 v$VERSION...${NC}"
git tag -a "v$VERSION" -m "Release v$VERSION"

# 推送到 GitHub
echo -e "\n${YELLOW}7. 推送到 GitHub...${NC}"
git push origin main
git push origin "v$VERSION"

echo -e "\n${GREEN}======================================${NC}"
echo -e "${GREEN}  发布成功!${NC}"
echo -e "${GREEN}======================================${NC}"
echo -e "\n已创建标签: v$VERSION"
echo -e "已推送到: https://github.com/YOUR_USERNAME/onepanel_mobile"
echo -e "\nGitHub Actions 将自动构建 iOS 和 Android 应用"
echo -e "\n${YELLOW}下一步:${NC}"
echo "1. 访问 GitHub 仓库查看构建状态"
echo "2. 在 Releases 页面下载构建产物"
echo "3. 或使用 TestFlight 分发 iOS 应用"

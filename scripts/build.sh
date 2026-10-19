#!/bin/bash

# 1Panel Client - 本地构建脚本
# 使用方法: ./scripts/build.sh [platform]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 默认平台
PLATFORM="${1:-all}"

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  1Panel Client 构建脚本${NC}"
echo -e "${GREEN}  平台: $PLATFORM${NC}"
echo -e "${GREEN}======================================${NC}"

# 安装依赖
echo -e "\n${YELLOW}1. 安装依赖...${NC}"
flutter pub get

# 运行测试
echo -e "\n${YELLOW}2. 运行测试...${NC}"
flutter test || {
    echo -e "${RED}测试失败${NC}"
    exit 1
}

# 代码分析
echo -e "\n${YELLOW}3. 代码分析...${NC}"
flutter analyze || {
    echo -e "${RED}代码分析失败${NC}"
    exit 1
}

# 根据平台构建
case "$PLATFORM" in
    ios)
        echo -e "\n${YELLOW}4. 构建 iOS...${NC}"
        flutter build ios --release
        ;;
    android)
        echo -e "\n${YELLOW}4. 构建 Android...${NC}"
        flutter build apk --release
        flutter build appbundle --release
        ;;
    web)
        echo -e "\n${YELLOW}4. 构建 Web...${NC}"
        flutter build web --release
        ;;
    linux)
        echo -e "\n${YELLOW}4. 构建 Linux...${NC}"
        flutter build linux --release
        ;;
    windows)
        echo -e "\n${YELLOW}4. 构建 Windows...${NC}"
        flutter build windows --release
        ;;
    all)
        echo -e "\n${YELLOW}4. 构建所有平台...${NC}"
        flutter build web --release
        flutter build apk --release
        flutter build appbundle --release
        ;;
    *)
        echo -e "${RED}未知平台: $PLATFORM${NC}"
        echo "可用平台: ios, android, web, linux, windows, all"
        exit 1
        ;;
esac

echo -e "\n${GREEN}======================================${NC}"
echo -e "${GREEN}  构建完成!${NC}"
echo -e "${GREEN}======================================${NC}"

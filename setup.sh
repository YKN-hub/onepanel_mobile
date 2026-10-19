#!/bin/bash

# 1Panel Client - 一键设置脚本
# 使用方法: ./setup.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 打印带颜色的消息
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 打印标题
print_header() {
    echo -e "\n${GREEN}======================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}======================================${NC}\n"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 未安装"
        return 1
    fi
    print_success "$1 已安装"
    return 0
}

# 主函数
main() {
    print_header "1Panel Client 设置脚本"
    
    # 1. 检查 Flutter
    print_info "检查 Flutter..."
    if ! check_command flutter; then
        print_warning "请先安装 Flutter: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    # 2. 检查 Flutter 版本
    print_info "检查 Flutter 版本..."
    FLUTTER_VERSION=$(flutter --version --machine | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    print_success "Flutter 版本: $FLUTTER_VERSION"
    
    # 3. 检查 Git
    print_info "检查 Git..."
    if ! check_command git; then
        print_error "Git 未安装"
        exit 1
    fi
    
    # 4. 安装依赖
    print_info "安装 Flutter 依赖..."
    flutter pub get
    print_success "依赖安装完成"
    
    # 5. 运行测试
    print_info "运行测试..."
    if flutter test; then
        print_success "测试通过"
    else
        print_warning "测试失败，继续构建..."
    fi
    
    # 6. 代码分析
    print_info "代码分析..."
    if flutter analyze; then
        print_success "代码分析通过"
    else
        print_warning "代码分析发现问题"
    fi
    
    # 7. 检查 iOS 环境
    print_info "检查 iOS 环境..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if xcodebuild -version &> /dev/null; then
            XCODE_VERSION=$(xcodebuild -version | head -n 1)
            print_success "Xcode: $XCODE_VERSION"
        else
            print_warning "Xcode 未安装"
        fi
        
        if command -v pod &> /dev/null; then
            print_success "CocoaPods 已安装"
        else
            print_warning "CocoaPods 未安装，运行: sudo gem install cocoapods"
        fi
    else
        print_info "当前系统: $OSTYPE (非 macOS)"
        print_warning "iOS 构建需要在 macOS 上进行"
    fi
    
    # 8. 显示帮助
    print_header "下一步"
    echo -e "${YELLOW}1. 配置 1Panel 服务器:${NC}"
    echo "   在 1Panel 面板中启用 API 接口，获取 API Key"
    echo ""
    echo -e "${YELLOW}2. 运行应用:${NC}"
    echo "   flutter run"
    echo ""
    echo -e "${YELLOW}3. 构建应用:${NC}"
    echo "   flutter build ios --release    # iOS"
    echo "   flutter build apk --release    # Android"
    echo "   flutter build web --release    # Web"
    echo ""
    echo -e "${YELLOW}4. 使用 GitHub Actions:${NC}"
    echo "   访问 GitHub 仓库的 Actions 页面"
    echo "   或运行: ./scripts/release.sh 0.1.0"
    echo ""
    
    print_header "完成"
    print_success "设置完成！"
}

# 运行主函数
main "$@"

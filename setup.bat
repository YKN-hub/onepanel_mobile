@echo off
REM 1Panel Client - Windows 一键设置脚本
REM 使用方法: setup.bat

echo ========================================
echo   1Panel Client 设置脚本
echo ========================================
echo.

REM 检查 Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter 未安装
    echo 请先安装 Flutter: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo [INFO] Flutter 版本:
flutter --version

REM 检查 Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git 未安装
    echo 请先安装 Git: https://git-scm.com/
    pause
    exit /b 1
)

echo [INFO] Git 版本:
git --version

echo.
echo [INFO] 安装 Flutter 依赖...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] 依赖安装失败
    pause
    exit /b 1
)

echo.
echo [INFO] 运行测试...
flutter test
if %errorlevel% neq 0 (
    echo [WARNING] 测试失败
)

echo.
echo [INFO] 代码分析...
flutter analyze
if %errorlevel% neq 0 (
    echo [WARNING] 代码分析发现问题
)

echo.
echo ========================================
echo   设置完成!
echo ========================================
echo.
echo 下一步:
echo 1. 配置 1Panel 服务器 (启用 API 接口)
echo 2. 运行: flutter run
echo 3. 构建: flutter build apk --release
echo.
pause

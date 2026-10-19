@echo off
REM 1Panel Client - Windows 构建脚本
REM 使用方法: build.bat [platform]

setlocal enabledelayedexpansion

set PLATFORM=%1
if "%PLATFORM%"=="" set PLATFORM=all

echo ======================================
echo   1Panel Client 构建脚本
echo   平台: %PLATFORM%
echo ======================================
echo.

REM 安装依赖
echo [1/3] 安装依赖...
flutter pub get
if errorlevel 1 (
    echo 依赖安装失败
    exit /b 1
)

REM 运行测试
echo [2/3] 运行测试...
flutter test
if errorlevel 1 (
    echo 测试失败
    exit /b 1
)

REM 代码分析
echo [3/3] 代码分析...
flutter analyze
if errorlevel 1 (
    echo 代码分析失败
    exit /b 1
)

REM 构建
echo.
echo 构建中...

if /i "%PLATFORM%"=="android" (
    flutter build apk --release
) else if /i "%PLATFORM%"=="web" (
    flutter build web --release
) else if /i "%PLATFORM%"=="windows" (
    flutter build windows --release
) else if /i "%PLATFORM%"=="all" (
    flutter build web --release
    flutter build apk --release
) else (
    echo 未知平台: %PLATFORM%
    echo 可用平台: android, web, windows, all
    exit /b 1
)

echo.
echo ======================================
echo   构建完成!
echo ======================================

# 1Panel Client - 1Panel 第三方客户端

📱 1Panel 第三方客户端 (Flutter) - iOS/Android/

## 功能特性

- 🖥️ **平台支持**: iOS / Android / 
- 💰 **免费多机管理**: 无需付费即可管理多个 1Panel 实例
- 📱 **移动端优化**: 专为竖屏手机设计
- ✅ **完整 API 支持**: 425+ 1Panel V2 API 端点
- 🔓 **完全开源**: GPL-3.0 协议

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 构建 iOS
flutter build ios --release

# 构建 Android
flutter build apk --release
```

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── core/                        # 核心层
│   ├── config/                  # 配置
│   ├── network/                 # 网络层
│   ├── services/                # 服务
│   └── i18n/                    # 国际化
├── data/models/                 # 数据模型
├── api/v2/api_client.dart       # API 客户端
├── pages/                       # 页面
└── widgets/                     # 小部件
```

## 开源协议

GPL-3.0

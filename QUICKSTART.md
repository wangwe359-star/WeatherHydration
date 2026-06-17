# 快速开始与打包指南

## 前置条件

1. **安装 Flutter 与 Android Studio**（参考 Flutter 官方文档）
2. **配置 Android SDK 环境变量**（ANDROID_SDK_ROOT）
3. **验证环境**: 运行 `flutter doctor` 确保无缺失项

## 开发流程

### 1. 配置 API Key

编辑以下两个文件，将 `REPLACE_WITH_YOUR_OPENWEATHERMAP_KEY` 替换为你的 API Key：

- `lib/main.dart` - 第 11 行
- `lib/worker.dart` - 第 5 行

获取 API Key: https://openweathermap.org/api (免费 API)

### 2. 运行开发版本

```bash
# 在项目根目录运行
flutter pub get
flutter run
```

或指定设备：
```bash
flutter devices                    # 列出可用设备
flutter run -d <device-id>        # 运行到指定设备
```

### 3. 构建无签名 Release APK（快速测试）

```bash
flutter build apk --release
```

产物位置: `build/app/outputs/flutter-apk/app-release.apk`

安装到设备:
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## 发布流程（带签名）

若要上传到 Google Play 或分发给他人，需要签名 APK。详见 `android/gradle_signing_config.md`。

## 常见问题

### Q: `flutter doctor` 报错
**A**: 根据提示逐一修复，通常是缺少 SDK 或许可未接受。运行 `flutter doctor --android-licenses` 接受所有许可。

### Q: 构建失败 (Gradle 错误)
**A**: 
- 清理缓存: `flutter clean`
- 重新下载依赖: `flutter pub get`
- 检查 Java 版本是否匹配（通常需要 JDK 11+）

### Q: 定位权限被拒绝
**A**: 在 Android 设备或模拟器的设置中授予应用定位权限。

### Q: 推送通知不显示
**A**: 确保：
- Android 8+ 已创建通知渠道（代码中已实现）
- 应用已获得通知权限（AndroidManifest.xml 中已声明）
- 检查设备通知设置是否启用此应用

## 相关文件

- `android/gradle_signing_config.md` - 详细签名步骤
- `android_instructions.md` - Android 权限与后台任务配置
- `README.md` - 项目概述

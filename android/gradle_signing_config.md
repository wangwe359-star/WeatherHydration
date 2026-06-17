# Android 签名配置说明

本文件为 `android/app/build.gradle` 中需要添加的签名配置片段示例。

## 步骤 1: 生成 keystore 文件

在项目根目录（`android/` 同级）运行：

```bash
keytool -genkey -v -keystore user-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias weather_hydration_key
```

按提示输入密码和证书信息。生成的 `user-release-key.jks` 文件将保存在项目根。

## 步骤 2: 复制并填写密钥配置

将 `key.properties.example` 复制为 `key.properties`（`android/` 目录内）：

```bash
cp android/key.properties.example android/key.properties
```

编辑 `android/key.properties`，填入你在步骤 1 中设置的密码和别名：

```
storePassword=你的_keystore_密码
keyPassword=你的_key_密码
keyAlias=weather_hydration_key
storeFile=../user-release-key.jks
```

**注意**: `key.properties` 和 `user-release-key.jks` 不应上传到公开仓库。已在 `.gitignore` 中配置忽略。

## 步骤 3: 在 build.gradle 中添加签名配置

编辑 `android/app/build.gradle`，在 `android { ... }` 块内添加以下内容：

```gradle
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

android {
  ...
  signingConfigs {
    release {
      keyAlias keystoreProperties['keyAlias']
      keyPassword keystoreProperties['keyPassword']
      storeFile file(keystoreProperties['storeFile'])
      storePassword keystoreProperties['storePassword']
    }
  }

  buildTypes {
    release {
      signingConfig signingConfigs.release
      minifyEnabled false
    }
  }
}
```

## 步骤 4: 构建签名 APK

在项目根运行：

```bash
flutter build apk --release
```

生成的签名 APK 位于：`build/app/outputs/flutter-apk/app-release.apk`

## 步骤 5: 安装到设备

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

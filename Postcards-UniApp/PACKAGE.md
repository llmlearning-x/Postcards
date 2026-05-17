# 旅行邮箱 Android APK 打包指南

## 打包材料清单（已准备完毕）

| 材料 | 路径 | 状态 |
|------|------|------|
| 构建资源 | `dist/build/app/` | 已生成 |
| 签名证书 | `postcards.keystore` | 本地保存，不提交 Git |
| 应用图标 | `src/static/logo.png` | 已生成 (1024x1024) |
| 应用配置 | `manifest.json` | 已配置 |

---

## 签名证书信息

| 项目 | 值 |
|------|-----|
| 证书文件 | `postcards.keystore`（本地保存，不提交 Git） |
| 别名 (Alias) | 使用本地签名证书的 alias |
| 密钥库密码 | 使用本地安全记录中的密码 |
| 私钥密码 | 使用本地安全记录中的密码 |
| 算法 | SHA256withRSA |
| 有效期 | 100 年 |
| 指纹 (SHA256) | 以本地证书实际输出为准 |

> 请妥善保存证书文件和密码，升级 APK 必须使用同一证书。

---

## HBuilderX 云打包步骤

### 1. 下载 HBuilderX
- 官网：https://www.dcloud.io/hbuilderx.html
- 下载对应系统版本（Windows/Mac）

### 2. 打开项目
```
文件 → 打开目录 → 选择 Postcards-UniApp 文件夹
```

### 3. 配置签名
```
菜单： manifest.json → 源码视图 → app-plus → distribute → android
```

填入以下信息：
```json
{
  "android": {
    "packagename": "com.postcards.app",
    "permissions": [...],
    "abiFilters": ["armeabi-v7a", "arm64-v8a"],
    "keystore": "postcards.keystore",
    "storepassword": "<keystore-password>",
    "alias": "<key-alias>",
    "keypassword": "<key-password>"
  }
}
```

或者使用 HBuilderX 的图形界面配置：
```
manifest.json → App 图标配置 → 选择 src/static/logo.png
manifest.json → App 模块配置 → 勾选 相机、相册、定位
manifest.json → App 权限配置 → 保持默认已勾选
```

### 4. 发起云打包
```
菜单：发行 → 原生App-云打包
```

配置选项：
- [x] Android (apk)
- [ ] 打自定义调试基座（首次测试可勾选）
- [x] 使用 DCloud 公共测试证书（仅测试）/ 使用自有证书（正式发布）

如使用自有证书：
- 证书文件：点击浏览，选择项目根目录的 `postcards.keystore`
- 证书别名：填写本地签名证书 alias
- 证书私钥密码：填写本地安全记录中的密码
- 证书文件密码：填写本地安全记录中的密码

### 5. 等待打包完成
- 点击「打包」
- 等待 DCloud 云服务器编译（约 2-5 分钟）
- 下载生成的 APK 文件

---

## 常见问题

### Q1: 云打包提示"证书错误"
确保证书路径正确，密码无误。可在终端验证：
```bash
keytool -list -v -keystore postcards.keystore -storepass <keystore-password>
```

### Q2: 应用图标未生效
HBuilderX 云打包会自动裁剪 `logo.png` 生成各尺寸图标。确保 `src/static/logo.png` 存在且为 1024x1024。

### Q3: 如何生成不同包名的 APK？
修改 `manifest.json` 中的 `id` 字段（如 `__UNI__POSTCARDS` → `com.yourcompany.postcards`），但需注意包名一旦发布不可更改。

### Q4: 升级 APK 需要重新生成证书吗？
不需要。Android 要求同一应用的所有版本使用同一证书签名。请永久保存 `postcards.keystore` 文件和密码。

---

## 应用信息

| 项目 | 值 |
|------|-----|
| 应用名称 | 旅行邮箱 |
| 应用 ID | `__UNI__POSTCARDS` |
| 版本号 | 1.0.0 (100) |
| 描述 | 记录旅途，寄往远方 |
| 支持平台 | Android (armeabi-v7a, arm64-v8a) |
| 所需权限 | 网络、定位、相机、存储读写 |

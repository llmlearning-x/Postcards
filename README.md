<p align="center">
  <img src="docs/assets/app-icon.png" width="120" alt="旅行邮箱 App Icon">
</p>

<h1 align="center">旅行邮箱</h1>

<p align="center">
  <img src="docs/assets/brand-logo.png" width="400" alt="旅行邮箱 Brand Logo">
</p>

> 记录旅途，寄往远方。一款旅行明信片记录应用。

旅行邮箱是一款基于旅行场景的明信片记录与社交应用。用户可以记录旅行足迹、创建个性化明信片、收集各地特色邮票，并通过"寄送"功能将明信片分享给好友。

## 多平台支持

| 平台 | 状态 | 说明 |
|------|------|------|
| H5 | ✅ 已上线 | [http://115.190.7.207](http://115.190.7.207) |
| Android App | ✅ 已发布 | [下载 APK](https://github.com/llmlearning-x/Postcards/releases/download/v1.0.0/default.apk) |

<p align="center">
  <img src="docs/assets/android-preview.png" width="280" alt="Android 桌面预览">
  <img src="docs/assets/android-icon-mask.png" width="380" alt="Android 自适应图标">
</p>
| 微信小程序 | 🚧 计划中 | — |
| iOS App | 🚧 计划中 | — |
| HarmonyOS | 🚧 计划中 | — |

## 项目结构

本仓库采用多平台 monorepo 结构：

```
Postcards/
├── Postcards-UniApp/      # UniApp 跨端项目（H5 + 小程序 + App）
├── Postcards-Server/      # Node.js 后端 API
├── Postcards-iOS/         # iOS 原生项目
├── Postcards-Android/     # Android 原生项目
├── Postcards-Harmony/     # HarmonyOS 项目
└── docs/                  # 产品手册（GitHub Pages）
```

## 快速开始

### H5 开发

```bash
cd Postcards-UniApp
npm install
npm run dev:h5
```

### 后端开发

```bash
cd Postcards-Server
npm install
npm run dev
```

### 构建

```bash
# H5
cd Postcards-UniApp && npm run build:h5

# 微信小程序
cd Postcards-UniApp && npm run build:mp-weixin

# Android App
cd Postcards-UniApp && npm run build:app-android
```

## 产品手册

完整的产品使用及设计说明手册已发布：

- 📖 **在线浏览**：[https://llmlearning-x.github.io/Postcards/](https://llmlearning-x.github.io/Postcards/)
- 📄 **PDF 下载**：[manual.pdf](https://llmlearning-x.github.io/Postcards/manual/manual.pdf)

手册包含 27 张移动端截图、功能架构图、使用指南与设计说明。

## 相关链接

- **H5 生产环境**：http://115.190.7.207
- **GitHub Release**：[v1.0.0](https://github.com/llmlearning-x/Postcards/releases/tag/v1.0.0)
- **APK 下载**：[旅行邮箱.apk](https://github.com/llmlearning-x/Postcards/releases/download/v1.0.0/default.apk)

## 技术栈

- **前端**：UniApp + Vue 3 + TypeScript + Pinia
- **后端**：Node.js + Express + TypeScript
- **数据库**：MySQL + Redis
- **部署**：Nginx + PM2 + GitHub Actions

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0.0 | 2026-05-18 | 初始版本，核心功能上线 |

---

© 2026 旅行邮箱

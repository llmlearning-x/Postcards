# 旅行邮箱 UniApp

旅行邮箱是一个旅行明信片记录应用，使用 UniApp、Vue 3、TypeScript 和 Pinia 开发。项目可从同一套代码构建 H5、微信小程序、Android 和 iOS 版本。

## 功能概览

- 旅行、明信片、邮票与寄送记录管理
- 自定义导航栏与跨端页面布局
- 本地存储与 API 服务两套数据访问能力
- H5、微信小程序、Android、iOS 多端构建脚本

## 开发

```bash
npm install
npm run dev:h5
```

## 构建

```bash
npm run build:h5
npm run build:mp-weixin
npm run build:app-android
npm run build:app-ios
```

## 项目结构

- `src/pages/`：UniApp 页面
- `src/components/`：通用组件
- `src/stores/`：Pinia 状态管理
- `src/services/`：API 请求封装
- `src/styles/`：全局样式与 SCSS 变量
- `scripts/`：图标等构建辅助脚本

## 打包说明

Android 云打包需要本地签名证书和 HBuilderX，具体流程见 `PACKAGE.md`。签名证书和密码不要提交到 Git。

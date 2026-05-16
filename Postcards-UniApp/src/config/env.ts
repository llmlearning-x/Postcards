/**
 * 环境配置
 *
 * API_BASE_URL 通过 uni/vite 环境变量注入：
 *   VITE_API_BASE_URL=http://localhost:3000/api
 *
 * 生产构建前必须在 .env.production 中配置正确的 HTTPS 域名。
 */

// Vite statically replaces import.meta.env.VITE_API_BASE_URL with the literal string at build time.
// Do NOT use `typeof import.meta` — Vite compiles that into a `new URL()` shim that crashes
// in the Android native JS engine (URL is not defined in JSCore).
// @ts-ignore — uni-app vite environment, import.meta.env may not be typed
const rawUrl: string = (import.meta.env.VITE_API_BASE_URL as string) || ''

// 在 App 原生环境中，相对路径无法解析，必须使用绝对地址
// #ifndef H5
export const API_BASE_URL: string = rawUrl.startsWith('http')
  ? rawUrl
  : `http://115.175.15.145${rawUrl}`
// #endif
// #ifdef H5
export const API_BASE_URL: string = rawUrl
// #endif

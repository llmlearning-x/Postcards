// 使用 __API_BASE_URL__ / __STAMPS_BASE_URL__ 全局变量（vite.config.ts define 注入）
// uni-app alpha 版 import.meta.env 替换有 bug，改用此方式

declare const __API_BASE_URL__: string

const rawUrl: string = (typeof __API_BASE_URL__ !== 'undefined' ? __API_BASE_URL__ : '') || ''

// #ifndef H5
export const API_BASE_URL: string = rawUrl.startsWith('http')
  ? rawUrl
  : `http://115.190.7.207${rawUrl}`
// #endif
// #ifdef H5
export const API_BASE_URL: string = rawUrl
// #endif

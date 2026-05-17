/**
 * 环境配置
 *
 * 构建时通过 .env 文件注入 VITE_ 前缀变量。
 * H5 使用相对路径 /api，由 nginx 反向代理。
 * App 使用完整 URL，通过 .env.production / .env.test 切换。
 */

// Vite statically replaces import.meta.env.VITE_API_BASE_URL with the literal string at build time.
// @ts-ignore — uni-app vite environment
const rawUrl: string = (import.meta.env.VITE_API_BASE_URL as string) || ''
const rawStamps: string = (import.meta.env.VITE_STAMPS_BASE_URL as string) || ''

export const API_BASE_URL: string = rawUrl
export const STAMPS_BASE_URL: string = rawStamps

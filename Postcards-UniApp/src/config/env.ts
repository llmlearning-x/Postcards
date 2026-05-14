/**
 * 环境配置
 *
 * API_BASE_URL 通过 uni/vite 环境变量注入：
 *   VITE_API_BASE_URL=http://localhost:3000/api
 *
 * 生产构建前必须在 .env.production 中配置正确的 HTTPS 域名。
 */

// @ts-ignore — uni-app vite environment, import.meta.env may not be typed
const env = (typeof import.meta !== 'undefined' && (import.meta as any).env) || {}

export const API_BASE_URL: string = (env.VITE_API_BASE_URL as string) || ''

if (!API_BASE_URL && typeof window !== 'undefined') {
  console.warn('[env] VITE_API_BASE_URL 未配置，API 请求将使用开发回退地址')
}

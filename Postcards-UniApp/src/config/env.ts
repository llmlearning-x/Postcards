/**
 * 环境配置
 *
 * USE_REMOTE_API = false → 纯本地 localStorage 模式（当前默认）
 * USE_REMOTE_API = true  → 调用后端 REST API（需后端服务上线后开启）
 *
 * API_BASE_URL 通过 uni/vite 环境变量注入，本地开发可在 .env.development 中配置：
 *   VITE_API_BASE_URL=http://localhost:3000/api
 */

// @ts-ignore — uni-app vite environment, import.meta.env may not be typed
const env = (typeof import.meta !== 'undefined' && (import.meta as any).env) || {}

export const USE_REMOTE_API: boolean = env.VITE_USE_REMOTE_API === 'true'

export const API_BASE_URL: string = (env.VITE_API_BASE_URL as string) || 'http://localhost:3000/api'

import { StampDesigns } from '@/config/app'
import { useAuthStore } from '@/stores/auth'

let STAMPS_BASE = 'http://115.190.7.207/stamps'
try {
  const envUrl = (import.meta as any).env?.VITE_STAMPS_BASE_URL
  if (envUrl) STAMPS_BASE = envUrl
} catch {
  // App 端 import.meta 可能不存在，使用默认地址
}

/** 格式化时间戳为 月·日（如 05·15） */
export function formatDotDate(ts: number): string {
  const d = new Date(ts)
  return `${String(d.getMonth() + 1).padStart(2, '0')}·${String(d.getDate()).padStart(2, '0')}`
}

/** 数字左侧补零 */
export function padNumber(n: number, len = 2): string {
  return String(n).padStart(len, '0')
}

/** 根据邮票 ID 获取颜色 */
export function getStampColor(id: string): string {
  return StampDesigns.find(s => s.id === id)?.color ?? '#8E8775'
}

/** 根据邮票 ID 获取名称 */
export function getStampName(id: string): string {
  return StampDesigns.find(s => s.id === id)?.name ?? '经典'
}

/** 根据邮票 ID 获取系列编号 */
export function getStampSeries(id: string): string {
  return StampDesigns.find(s => s.id === id)?.series ?? 'I'
}

/** 根据邮票 ID 获取系列名称 */
export function getStampSeriesName(id: string): string {
  return StampDesigns.find(s => s.id === id)?.seriesName ?? '旅行'
}

/**
 * 根据邮票 ID 返回图片完整 URL。
 * 优先使用服务端返回的 imageUrl（与商店同源），找不到时回退到本地路径。
 */
export function getStampImageUrl(id: string): string {
  try {
    const auth = useAuthStore()
    const entry = auth.allStampUrls.find(s => s.id === id)
    if (entry?.imageUrl) return entry.imageUrl
  } catch {}
  const design = StampDesigns.find(s => s.id === id)
  if (!design?.imagePath) return ''
  const base = STAMPS_BASE.replace(/\/$/, '')
  return `${base}/${design.imagePath}`
}

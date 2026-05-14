import { StampDesigns } from '@/config/app'

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

/** 邮票图片统一由后端 STAMPS_BASE_URL 提供，前端直接使用 stamp.imageUrl */

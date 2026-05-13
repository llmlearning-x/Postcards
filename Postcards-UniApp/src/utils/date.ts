// 日期工具函数
export class DateUtil {
  /**
   * 格式化日期为 年/月/日
   */
  static formatDate(timestamp: number): string {
    const date = new Date(timestamp)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}年${month}月${day}日`
  }

  /**
   * 格式化日期为简短格式
   */
  static formatShortDate(timestamp: number): string {
    const date = new Date(timestamp)
    const month = String(date.getMonth() + 1)
    const day = String(date.getDate())
    return `${month}/${day}`
  }

  /**
   * 格式化日期时间
   */
  static formatDateTime(timestamp: number): string {
    const date = new Date(timestamp)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    return `${year}-${month}-${day} ${hours}:${minutes}`
  }

  /**
   * 获取相对时间描述
   */
  static getRelativeTime(timestamp: number): string {
    const now = Date.now()
    const diff = now - timestamp
    const minute = 60 * 1000
    const hour = 60 * minute
    const day = 24 * hour
    const week = 7 * day
    const month = 30 * day

    if (diff < minute) {
      return '刚刚'
    } else if (diff < hour) {
      return `${Math.floor(diff / minute)}分钟前`
    } else if (diff < day) {
      return `${Math.floor(diff / hour)}小时前`
    } else if (diff < week) {
      return `${Math.floor(diff / day)}天前`
    } else if (diff < month) {
      return `${Math.floor(diff / week)}周前`
    } else {
      return this.formatDate(timestamp)
    }
  }

  /**
   * 计算日期差（天数）
   */
  static getDaysDiff(start: number, end: number): number {
    const startDate = new Date(start)
    const endDate = new Date(end)
    const diffTime = Math.abs(endDate.getTime() - startDate.getTime())
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  }

  /**
   * 获取今天开始的时间戳
   */
  static getTodayStart(): number {
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    return today.getTime()
  }
}

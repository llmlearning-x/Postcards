// 本地存储工具
export class StorageUtil {
  /**
   * 获取存储数据
   */
  static get<T>(key: string, defaultValue: T): T {
    try {
      const data = uni.getStorageSync(key)
      if (data === '' || data === null || data === undefined) {
        return defaultValue
      }
      return JSON.parse(data) as T
    } catch (error) {
      console.error('Storage get error:', error)
      return defaultValue
    }
  }

  /**
   * 设置存储数据
   */
  static set(key: string, value: any): boolean {
    try {
      uni.setStorageSync(key, JSON.stringify(value))
      return true
    } catch (error) {
      console.error('Storage set error:', error)
      return false
    }
  }

  /**
   * 删除存储数据
   */
  static remove(key: string): boolean {
    try {
      uni.removeStorageSync(key)
      return true
    } catch (error) {
      console.error('Storage remove error:', error)
      return false
    }
  }

  /**
   * 清空所有存储
   */
  static clear(): boolean {
    try {
      uni.clearStorageSync()
      return true
    } catch (error) {
      console.error('Storage clear error:', error)
      return false
    }
  }
}

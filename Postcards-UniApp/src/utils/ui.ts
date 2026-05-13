// UI 工具函数
export class UIUtil {
  /**
   * 显示成功提示
   */
  static showSuccess(title: string = '操作成功'): void {
    uni.showToast({
      title,
      icon: 'success',
      duration: 2000,
    })
  }

  /**
   * 显示错误提示
   */
  static showError(title: string = '操作失败'): void {
    uni.showToast({
      title,
      icon: 'none',
      duration: 2500,
    })
  }

  /**
   * 显示加载中
   */
  static showLoading(title: string = '加载中...'): void {
    uni.showLoading({
      title,
      mask: true,
    })
  }

  /**
   * 隐藏加载
   */
  static hideLoading(): void {
    uni.hideLoading()
  }

  /**
   * 显示确认对话框
   */
  static showConfirm(
    title: string = '提示',
    content: string = '确定执行此操作吗？',
    options?: {
      confirmText?: string
      cancelText?: string
    }
  ): Promise<boolean> {
    return new Promise((resolve) => {
      uni.showModal({
        title,
        content,
        confirmText: options?.confirmText || '确定',
        cancelText: options?.cancelText || '取消',
        success: (res) => {
          resolve(res.confirm)
        },
      })
    })
  }

  /**
   * 显示操作菜单
   */
  static showActionSheet(itemList: string[]): Promise<number | null> {
    return new Promise((resolve) => {
      uni.showActionSheet({
        itemList,
        success: (res) => {
          resolve(res.tapIndex)
        },
        fail: () => {
          resolve(null)
        },
      })
    })
  }

  /**
   * 设置导航栏标题
   */
  static setNavigationBarTitle(title: string): void {
    uni.setNavigationBarTitle({ title })
  }

  /**
   * 导航到页面
   */
  static navigateTo(url: string): void {
    uni.navigateTo({ url })
  }

  /**
   * 返回上一页
   */
  static navigateBack(delta: number = 1): void {
    uni.navigateBack({ delta })
  }

  /**
   * 跳转到 tabBar 页面
   */
  static switchTab(url: string): void {
    uni.switchTab({ url })
  }
}

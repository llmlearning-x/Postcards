const TAB_PAGES = new Set([
  '/pages/home/home',
  '/pages/timeline/timeline',
  '/pages/record/record',
  '/pages/map/map',
  '/pages/profile/profile',
])

export function safeBack(fallbackUrl = '/pages/home/home', delta = 1): void {
  uni.navigateBack({
    delta,
    fail: () => {
      if (TAB_PAGES.has(fallbackUrl)) {
        uni.switchTab({ url: fallbackUrl })
      } else {
        uni.redirectTo({
          url: fallbackUrl,
          fail: () => uni.reLaunch({ url: fallbackUrl }),
        })
      }
    },
  })
}

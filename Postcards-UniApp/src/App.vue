<script setup lang="ts">
import { onLaunch, onShow, onHide } from '@dcloudio/uni-app'
import { useAuthStore } from '@/stores/auth'
import { StampApi } from '@/services/api'
import { getStampImageUrl } from '@/utils/stamp'

onLaunch(async () => {
  const auth = useAuthStore()
  if (auth.isLoggedIn) {
    try {
      const stamps = await StampApi.all()
      auth.setAllStampUrls(stamps)
    } catch {}
  }
  
  // 预加载邮票图片到本地缓存（提升后续页面渲染速度）
  preloadStamps()
})

function preloadStamps() {
  // #ifdef APP-PLUS
  const stampIds = [
    'classic', 'nature', 'culture', 'city', 'ocean', 'sunset',
    'heritage', 'art', 'music', 'poetry', 'tea', 'silk',
    'spring-cherry', 'summer-lotus', 'autumn-maple', 'winter-snow',
    'solar-beginning', 'solar-rain', 'solar-awakening', 'solar-vernal',
    'snow-mountain', 'desert', 'island', 'grassland'
  ]
  stampIds.forEach(id => {
    const url = getStampImageUrl(id)
    if (url) uni.downloadFile({ url, success: () => {} })
  })
  // #endif
}

onShow(() => {})
onHide(() => {})
</script>

<style lang="scss">
@use './styles/global.scss' as *;
</style>

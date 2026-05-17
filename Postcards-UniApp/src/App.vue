<script setup lang="ts">
import { onLaunch, onShow, onHide } from '@dcloudio/uni-app'
import { useAuthStore } from '@/stores/auth'
import { StampApi } from '@/services/api'

onLaunch(async () => {
  const auth = useAuthStore()
  if (auth.isLoggedIn) {
    try {
      const stamps = await StampApi.all()
      auth.setAllStampUrls(stamps)
    } catch {}
  }
})

onShow(() => {})
onHide(() => {})
</script>

<style lang="scss">
@use './styles/global.scss' as *;
</style>

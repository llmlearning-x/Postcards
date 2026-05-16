<template>
  <view class="postal-header">
    <view class="header-perf"></view>

    <view v-if="showBack" class="nav-back" @click="handleBack">
      <IconBack :size="18" color="rgba(255,255,255,0.9)" />
    </view>

    <view v-if="$slots.right" class="header-right">
      <slot name="right"></slot>
    </view>

    <text class="header-kicker">{{ kicker }}</text>
    <view class="header-title-row">
      <text class="header-title">{{ title }}</text>
      <slot name="title-extra"></slot>
    </view>
    <text v-if="subtitle" class="header-subtitle">{{ subtitle }}</text>
  </view>
</template>

<script setup lang="ts">
import { IconBack } from '@/components/icons'
import { safeBack } from '@/utils/navigation'

const props = withDefaults(defineProps<{
  kicker: string
  title: string
  subtitle?: string
  showBack?: boolean
  fallbackUrl?: string
}>(), {
  showBack: true,
  fallbackUrl: '/pages/home/home',
})

const emit = defineEmits<{
  (e: 'back'): void
}>()

function handleBack() {
  emit('back')
  safeBack(props.fallbackUrl)
}
</script>

<style lang="scss" scoped>
.postal-header {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: calc(72rpx + env(safe-area-inset-top)) 48rpx 22rpx;
  position: relative;
  flex-shrink: 0;
}

.header-perf {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 6rpx;
  background: repeating-linear-gradient(
    -45deg,
    #B8312A 0,
    #B8312A 5rpx,
    #ffffff 5rpx,
    #ffffff 10rpx,
    #1C3A72 10rpx,
    #1C3A72 15rpx,
    #ffffff 15rpx,
    #ffffff 20rpx
  );
}

.nav-back,
.header-right {
  position: absolute;
  top: calc(28rpx + env(safe-area-inset-top));
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-back {
  left: 40rpx;
}

.header-right {
  right: 40rpx;
}

.nav-back:active,
.header-right:active {
  opacity: 0.65;
}

.header-kicker {
  display: block;
  font-family: $font-family-code;
  font-size: 24rpx;
  letter-spacing: 1rpx;
  color: rgba(255,255,255,0.65);
  margin-bottom: 12rpx;
}

.header-title-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  min-width: 0;
}

.header-title {
  display: block;
  font-family: $font-family-body;
  font-size: 46rpx;
  font-weight: 700;
  color: rgba(255,255,255,0.95);
  line-height: 1.15;
  letter-spacing: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.header-subtitle {
  display: block;
  margin-top: 8rpx;
  font-family: $font-family-body;
  font-size: 26rpx;
  color: rgba(255,255,255,0.68);
}
</style>

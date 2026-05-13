<template>
  <view class="splash-container">
    <view class="splash-content">
      <view class="logo-wrapper">
        <view class="logo-circle">
          <IconMailbox :size="72" color="#2E7D58" />
        </view>
      </view>
      <view class="brand-section">
        <text class="brand-title">远方邮政</text>
        <text class="brand-subtitle">CHINA POST</text>
      </view>
      <text class="slogan">记录旅途 · 寄往远方</text>
    </view>
    <view class="splash-footer">
      <text class="version">v1.0.0</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { IconMailbox } from '@/components/icons'

onMounted(() => {
  setTimeout(() => {
    uni.switchTab({
      url: '/pages/home/home'
    })
  }, 2000)
})
</script>

<style lang="scss" scoped>
.splash-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #2E7D58 0%, #2E6E49 100%);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.splash-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 32rpx;
}

.logo-wrapper {
  animation: bounce 1.5s ease-in-out infinite;
}

.logo-circle {
  width: 160rpx;
  height: 160rpx;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 12rpx 40rpx rgba(0, 0, 0, 0.15);
}

.logo-text {
  font-size: 72rpx;
}

.brand-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
}

.brand-title {
  font-size: 56rpx;
  font-weight: 700;
  color: #fff;
  font-family: 'Georgia', serif;
  letter-spacing: 8rpx;
}

.brand-subtitle {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.85);
  letter-spacing: 4rpx;
}

.slogan {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.9);
  margin-top: 24rpx;
  letter-spacing: 4rpx;
}

.splash-footer {
  position: absolute;
  bottom: 80rpx;
}

.version {
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.6);
}

@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-16rpx);
  }
}
</style>

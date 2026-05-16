<template>
  <view class="splash">
    <view class="airmail-top"></view>
    <view class="airmail-bottom"></view>

    <view class="center-block">
      <view class="stamp-frame">
        <view class="stamp-inner">
          <view class="stamp-scene">
            <view class="stamp-circle-outer"></view>
            <view class="stamp-circle-inner"></view>
            <text class="stamp-char">邮</text>
          </view>
          <text class="stamp-series">CLASSIC · SERIES I</text>
        </view>
        <view class="stamp-perf top-perf"></view>
        <view class="stamp-perf bottom-perf"></view>
        <view class="stamp-perf left-perf"></view>
        <view class="stamp-perf right-perf"></view>
      </view>

      <text class="brand-title">旅行邮局</text>
      <text class="brand-kicker">· TRAVEL POST ·</text>
    </view>

    <view class="footer-block">
      <text class="slogan">写一张笺 · 寄向远方</text>
      <view class="loader-track">
        <view class="loader-bar"></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { usePostcardStore } from '@/stores/postcard'
import { StampApi } from '@/services/api'

const _dummy = ref(0)

onMounted(async () => {
  const authStore = useAuthStore()
  const postcardStore = usePostcardStore()

  await new Promise(r => setTimeout(r, 1500))

  if (authStore.isLoggedIn) {
    postcardStore.syncFromServer().catch(() => {})
    StampApi.my().then(stamps => authStore.setOwnedStamps(stamps.map(s => s.id))).catch(() => {})
    uni.switchTab({ url: '/pages/home/home' })
  } else {
    uni.navigateTo({ url: '/pages/auth/login' })
  }
})
</script>

<style lang="scss" scoped>
.splash {
  min-height: 100vh;
  background: $page-background;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.airmail-top,
.airmail-bottom {
  position: absolute;
  left: 0;
  right: 0;
  height: 16rpx;
  background: repeating-linear-gradient(
    45deg,
    $stamp-red 0,
    $stamp-red 12rpx,
    transparent 12rpx,
    transparent 24rpx,
    #1F4B66 24rpx,
    #1F4B66 36rpx,
    transparent 36rpx,
    transparent 48rpx
  );
}
.airmail-top { top: 0; }
.airmail-bottom { bottom: 0; }

.center-block {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0;
}

.stamp-frame {
  position: relative;
  width: 264rpx;
  height: 322rpx;
  margin-bottom: 88rpx;
}

.stamp-inner {
  position: absolute;
  inset: 16rpx;
  background: $stamp-red;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16rpx;
}

.stamp-scene {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 120rpx;
  height: 120rpx;
}

.stamp-circle-outer {
  position: absolute;
  width: 120rpx;
  height: 120rpx;
  border-radius: 50%;
  border: 2rpx solid rgba(244, 239, 229, 0.7);
}

.stamp-circle-inner {
  position: absolute;
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  border: 1rpx solid rgba(244, 239, 229, 0.45);
}

.stamp-char {
  font-family: $font-family-serif;
  font-size: 52rpx;
  font-weight: 500;
  color: $paper-beige;
  position: relative;
  z-index: 1;
}

.stamp-series {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: rgba(244, 239, 229, 0.7);
}

.stamp-perf {
  position: absolute;
  background: repeating-linear-gradient(
    90deg,
    $page-background 0,
    $page-background 12rpx,
    transparent 12rpx,
    transparent 24rpx
  );
}

.top-perf,
.bottom-perf {
  left: 8rpx;
  right: 8rpx;
  height: 14rpx;
}
.top-perf { top: 0; }
.bottom-perf { bottom: 0; }

.left-perf,
.right-perf {
  top: 8rpx;
  bottom: 8rpx;
  width: 14rpx;
  background: repeating-linear-gradient(
    180deg,
    $page-background 0,
    $page-background 12rpx,
    transparent 12rpx,
    transparent 24rpx
  );
}
.left-perf { left: 0; }
.right-perf { right: 0; }

.brand-title {
  font-family: $font-family-serif;
  font-weight: 400;
  font-size: 104rpx;
  letter-spacing: 32rpx;
  color: $ink-black;
  padding-left: 32rpx;
  line-height: 1;
}

.brand-kicker {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 16rpx;
  color: $travel-blue;
  margin-top: 28rpx;
  padding-left: 16rpx;
}

.footer-block {
  position: absolute;
  bottom: 90rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 36rpx;
}

.slogan {
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 28rpx;
  color: $body-text;
  letter-spacing: 2rpx;
}

.loader-track {
  width: 160rpx;
  height: 3rpx;
  background: $line-sepia;
  position: relative;
  overflow: hidden;
  border-radius: 9999rpx;
}

.loader-bar {
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 40%;
  background: $travel-blue;
  border-radius: 9999rpx;
  animation: slide 1.6s ease-in-out infinite;
}

@keyframes slide {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(350%); }
}
</style>

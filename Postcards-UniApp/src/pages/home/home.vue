<template>
  <view class="page-container">
    <view class="header">
      <view class="header-content">
        <text class="header-title">远方邮政</text>
        <text class="header-subtitle">记录旅途的美好时光</text>
      </view>
    </view>

    <scroll-view class="content" scroll-y>
      <view class="stats-section">
        <view class="stats-card">
          <view class="stat-item">
            <IconStampClassic :size="36" color="#2E7D58" />
            <text class="stat-value">{{ travels.length }}</text>
            <text class="stat-label">旅程</text>
          </view>
          <view class="stat-divider"></view>
          <view class="stat-item">
            <IconImage :size="36" color="#2E7D58" />
            <text class="stat-value">{{ postcards.length }}</text>
            <text class="stat-label">明信片</text>
          </view>
          <view class="stat-divider"></view>
          <view class="stat-item">
            <IconStampCity :size="36" color="#2E7D58" />
            <text class="stat-value">{{ favoritesCount }}</text>
            <text class="stat-label">收藏</text>
          </view>
          <view class="stat-divider"></view>
          <view class="stat-item">
            <IconLocation :size="36" color="#2E7D58" />
            <text class="stat-value">{{ cityCount }}</text>
            <text class="stat-label">城市</text>
          </view>
        </view>
      </view>

      <view v-if="currentTravel" class="current-travel">
        <view class="travel-card">
          <view class="travel-header">
            <view class="travel-status">
              <view class="status-dot"></view>
              <text class="status-text">进行中</text>
            </view>
            <text class="travel-days">第 {{ travelDays }} 天</text>
          </view>
          <text class="travel-title">{{ currentTravel.title }}</text>
          <text class="travel-destination">{{ currentTravel.destination }}</text>
          <view class="travel-progress">
            <view class="progress-bar">
              <view class="progress-fill" :style="{ width: progressPercent + '%' }"></view>
            </view>
            <text class="progress-text">预计 {{ remainingDays }} 天后完成</text>
          </view>
        </view>
      </view>

      <view class="section">
        <view class="section-header">
          <text class="section-title">最近明信片</text>
          <view class="section-more" @click="goToTimeline">
            <text class="more-text">查看全部</text>
            <text class="more-arrow">›</text>
          </view>
        </view>

        <view v-if="recentPostcards.length > 0" class="postcard-list">
          <view
            v-for="card in recentPostcards"
            :key="card.id"
            class="postcard-item"
            @click="viewPostcard(card)"
          >
            <view class="postcard-image">
              <image v-if="card.photoUrl" :src="card.photoUrl" class="postcard-image-src" mode="aspectFill" />
              <IconImage v-else :size="48" color="#999" />
            </view>
            <view class="postcard-info">
              <text class="postcard-location">{{ card.locationName }}</text>
              <text class="postcard-city">{{ card.city }}</text>
              <text class="postcard-note">{{ card.note }}</text>
            </view>
            <view class="postcard-favorite" @click.stop="toggleFavorite(card.id)">
              <IconFavorite :size="32" :color="card.isFavorite ? '#FF4757' : '#CCC'" />
            </view>
          </view>
        </view>

        <view v-else class="empty-state">
          <IconImage :size="64" color="#CCC" />
          <text class="empty-text">还没有明信片</text>
          <text class="empty-hint">去记录你的第一张明信片吧</text>
        </view>
      </view>

      <view class="bottom-space"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { usePostcardStore } from '@/stores/postcard'
import type { Postcard } from '@/model/Postcard'
import {
  IconStampClassic,
  IconImage,
  IconStampCity,
  IconLocation,
  IconFavorite
} from '@/components/icons'

const store = usePostcardStore()

const travels = computed(() => store.sortedTravels)
const postcards = computed(() => store.sortedPostcards)
const currentTravel = computed(() => store.currentTravel)

const recentPostcards = computed(() => postcards.value.slice(0, 5))

const favoritesCount = computed(() => postcards.value.filter(p => p.isFavorite).length)

const cityCount = computed(() => {
  const cities = new Set(postcards.value.map(p => p.city).filter(c => c))
  return cities.size
})

const travelDays = computed(() => {
  if (!currentTravel.value) return 0
  const diff = Date.now() - currentTravel.value.startDate
  return Math.floor(diff / (24 * 60 * 60 * 1000)) + 1
})

const remainingDays = computed(() => {
  if (!currentTravel.value) return 0
  const diff = currentTravel.value.endDate - Date.now()
  return Math.max(0, Math.ceil(diff / (24 * 60 * 60 * 1000)))
})

const progressPercent = computed(() => {
  if (!currentTravel.value) return 0
  const total = currentTravel.value.endDate - currentTravel.value.startDate
  const elapsed = Date.now() - currentTravel.value.startDate
  return Math.min(100, Math.max(0, (elapsed / total) * 100))
})

function goToTimeline() {
  uni.switchTab({ url: '/pages/timeline/timeline' })
}

function viewPostcard(card: Postcard) {
  uni.navigateTo({
    url: `/pages/detail/detail?id=${card.id}`,
  })
}

function toggleFavorite(id: string) {
  store.toggleFavorite(id)
  uni.showToast({
    title: '收藏已更新',
    icon: 'success'
  })
}

onMounted(() => {
  store.initData()
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: #FAF7F2;
}

.header {
  background: linear-gradient(135deg, #2E7D58 0%, #2E6E49 100%);
  padding: 120rpx 40rpx 60rpx;
  border-radius: 0 0 48rpx 48rpx;
}

.header-content {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.header-title {
  font-size: 48rpx;
  font-weight: 700;
  color: #fff;
  font-family: 'Georgia', serif;
}

.header-subtitle {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.85);
}

.content {
  height: calc(100vh - 280rpx);
  padding: 24rpx;
  box-sizing: border-box;
  width: 100%;
}

.stats-section {
  margin-bottom: 24rpx;
}

.stats-card {
  display: flex;
  background: #fff;
  border-radius: 24rpx;
  padding: 32rpx 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
}

.stat-value {
  font-size: 44rpx;
  font-weight: 700;
  color: #2E7D58;
  font-family: 'Georgia', serif;
}

.stat-label {
  font-size: 22rpx;
  color: #999;
}

.stat-divider {
  width: 2rpx;
  background: #E0D5C0;
  margin: 0 12rpx;
}

.current-travel {
  margin-bottom: 24rpx;
}

.travel-card {
  background: #fff;
  border-radius: 24rpx;
  padding: 32rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
  border: 2rpx solid #B2DFDB;
}

.travel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}

.travel-status {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.status-dot {
  width: 16rpx;
  height: 16rpx;
  background: #22C55E;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

.status-text {
  font-size: 24rpx;
  font-weight: 600;
  color: #22C55E;
}

.travel-days {
  font-size: 24rpx;
  color: #999;
}

.travel-title {
  font-size: 36rpx;
  font-weight: 700;
  color: #2C2C2C;
  margin-bottom: 8rpx;
}

.travel-destination {
  font-size: 28rpx;
  color: #666;
  margin-bottom: 24rpx;
}

.travel-progress {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.progress-bar {
  height: 12rpx;
  background: #F5F5DC;
  border-radius: 6rpx;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #2E7D58 0%, #22C55E 100%);
  border-radius: 6rpx;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 22rpx;
  color: #999;
  text-align: right;
}

.section {
  margin-bottom: 24rpx;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2C2C2C;
}

.section-more {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.more-text {
  font-size: 26rpx;
  color: #2E7D58;
}

.more-arrow {
  font-size: 28rpx;
  color: #2E7D58;
}

.postcard-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.postcard-item {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 20rpx;
  padding: 20rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.04);
}

.postcard-image {
  width: 120rpx;
  height: 120rpx;
  background: #F5F5DC;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20rpx;
  overflow: hidden;
}

.postcard-image-src {
  width: 100%;
  height: 100%;
}

.postcard-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.postcard-location {
  font-size: 28rpx;
  font-weight: 600;
  color: #2C2C2C;
}

.postcard-city {
  font-size: 24rpx;
  color: #999;
}

.postcard-note {
  font-size: 22rpx;
  color: #666;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.postcard-favorite {
  padding: 12rpx;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60rpx 0;
  background: #fff;
  border-radius: 20rpx;
}

.empty-text {
  font-size: 28rpx;
  color: #666;
  margin-bottom: 8rpx;
  margin-top: 16rpx;
}

.empty-hint {
  font-size: 24rpx;
  color: #999;
}

.bottom-space {
  height: 120rpx;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}
</style>
<template>
  <view class="page-container">
    <view class="header">
      <text class="header-title">时间轴</text>
      <text class="header-subtitle">回顾旅途的点点滴滴</text>
    </view>

    <scroll-view class="content" scroll-y>
      <view v-if="groupedPostcards.length > 0">
        <view v-for="group in groupedPostcards" :key="group.date" class="timeline-group">
          <view class="group-header">
            <text class="group-date">{{ group.date }}</text>
            <text class="group-count">{{ group.items.length }} 张明信片</text>
          </view>

          <view class="timeline-list">
            <view
              v-for="(card, index) in group.items"
              :key="card.id"
              class="timeline-item"
            >
              <view class="timeline-connector">
                <view class="connector-dot" :class="{ first: index === 0 }"></view>
                <view v-if="index < group.items.length - 1" class="connector-line"></view>
              </view>

              <view class="timeline-card" @click="viewPostcard(card)">
                <view class="card-image">
                  <image v-if="card.photoUrl" :src="card.photoUrl" class="card-image-src" mode="aspectFill" />
                  <IconImage v-else :size="40" color="#999" />
                </view>
                <view class="card-content">
                  <text class="card-location">{{ card.locationName }}</text>
                  <text class="card-city">{{ card.city }}</text>
                  <text class="card-note">{{ card.note }}</text>
                </view>
                <view class="card-favorite" @click.stop="toggleFavorite(card.id)">
                  <IconFavorite :size="28" :color="card.isFavorite ? '#FF4757' : '#CCC'" />
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>

      <view v-else class="empty-state">
        <IconImage :size="96" color="#CCC" />
        <text class="empty-text">还没有明信片</text>
        <text class="empty-hint">去记录你的第一张明信片吧</text>
        <view class="empty-action" @click="goToRecord">
          <text class="action-text">立即记录</text>
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
import { IconImage, IconFavorite } from '@/components/icons'

const store = usePostcardStore()

const postcards = computed(() => store.sortedPostcards)

interface GroupedPostcard {
  date: string
  items: Postcard[]
}

const groupedPostcards = computed(() => {
  const groups: { [key: string]: Postcard[] } = {}

  postcards.value.forEach(card => {
    const date = formatDate(card.recordedAt)
    if (!groups[date]) {
      groups[date] = []
    }
    groups[date].push(card)
  })

  return Object.entries(groups).map(([date, items]) => ({
    date,
    items
  }))
})

function formatDate(timestamp: number): string {
  const date = new Date(timestamp)
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${year}年${month}月${day}日`
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

function goToRecord() {
  uni.switchTab({ url: '/pages/record/record' })
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
  padding: 120rpx 40rpx 40rpx;
}

.header-title {
  font-size: 44rpx;
  font-weight: 700;
  color: #fff;
  font-family: 'Georgia', serif;
  display: block;
  margin-bottom: 8rpx;
}

.header-subtitle {
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.85);
}

.content {
  height: calc(100vh - 220rpx);
  padding: 24rpx;
  box-sizing: border-box;
  width: 100%;
}

.timeline-group {
  margin-bottom: 32rpx;
}

.group-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
  padding: 0 16rpx;
}

.group-date {
  font-size: 28rpx;
  font-weight: 700;
  color: #2C2C2C;
}

.group-count {
  font-size: 24rpx;
  color: #999;
}

.timeline-list {
  padding-left: 24rpx;
}

.timeline-item {
  display: flex;
  gap: 16rpx;
}

.timeline-connector {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 24rpx;
  flex-shrink: 0;
}

.connector-dot {
  width: 16rpx;
  height: 16rpx;
  background: #2E7D58;
  border-radius: 50%;
  border: 4rpx solid #fff;
  box-shadow: 0 2rpx 8rpx rgba(46, 125, 88, 0.3);

  &.first {
    background: #22C55E;
    box-shadow: 0 0 0 8rpx rgba(34, 197, 94, 0.2);
  }
}

.connector-line {
  width: 2rpx;
  flex: 1;
  background: #E0D5C0;
  margin: 8rpx 0;
}

.timeline-card {
  flex: 1;
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 20rpx;
  padding: 20rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.04);
}

.card-image {
  width: 100rpx;
  height: 100rpx;
  background: #F5F5DC;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16rpx;
  overflow: hidden;
}

.card-image-src {
  width: 100%;
  height: 100%;
}

.card-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.card-location {
  font-size: 28rpx;
  font-weight: 600;
  color: #2C2C2C;
}

.card-city {
  font-size: 22rpx;
  color: #999;
}

.card-note {
  font-size: 22rpx;
  color: #666;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-top: 4rpx;
}

.card-favorite {
  padding: 8rpx;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 100rpx 40rpx;
}

.empty-text {
  font-size: 32rpx;
  color: #666;
  margin-bottom: 8rpx;
  margin-top: 24rpx;
}

.empty-hint {
  font-size: 26rpx;
  color: #999;
  margin-bottom: 32rpx;
}

.empty-action {
  background: #2E7D58;
  padding: 20rpx 60rpx;
  border-radius: 999rpx;
}

.action-text {
  font-size: 28rpx;
  color: #fff;
  font-weight: 600;
}

.bottom-space {
  height: 120rpx;
}
</style>
<template>
  <view class="page-container">
    <view class="header">
      <text class="header-title">收藏邮票</text>
      <text class="header-subtitle">珍藏旅途中的美好</text>
    </view>

    <scroll-view class="content" scroll-y>
      <view class="stats-section">
        <view class="stats-card">
          <view class="stat-item">
            <IconImage :size="36" color="#2E7D58" />
            <text class="stat-value">{{ postcards.length }}</text>
            <text class="stat-label">明信片</text>
          </view>
          <view class="stat-divider"></view>
          <view class="stat-item">
            <IconStampClassic :size="36" color="#2E7D58" />
            <text class="stat-value">{{ favorites.length }}</text>
            <text class="stat-label">邮票</text>
          </view>
          <view class="stat-divider"></view>
          <view class="stat-item">
            <IconBookOpen :size="36" color="#2E7D58" />
            <text class="stat-value">{{ albumCount }}</text>
            <text class="stat-label">邮册</text>
          </view>
        </view>
      </view>

      <view class="section">
        <view class="section-header">
          <text class="section-title">我的邮票</text>
          <text class="section-count">{{ favorites.length }} 枚</text>
        </view>

        <view v-if="favorites.length > 0" class="stamp-grid">
          <view
            v-for="card in favorites"
            :key="card.id"
            class="stamp-item"
            @click="viewPostcard(card)"
          >
            <view class="stamp-card">
              <view class="stamp-perforation">
                <view class="stamp-image">
                  <image v-if="card.photoUrl" :src="card.photoUrl" class="stamp-image-src" mode="aspectFill" />
                  <IconImage v-else :size="48" color="#999" />
                </view>
              </view>
              <text class="stamp-location">{{ card.locationName }}</text>
              <text class="stamp-city">{{ card.city }}</text>
              <view class="stamp-favorite" @click.stop="toggleFavorite(card.id)">
                <IconFavorite :size="28" color="#FF4757" />
              </view>
            </view>
          </view>
        </view>

        <view v-else class="empty-state">
          <IconStampClassic :size="64" color="#CCC" />
          <text class="empty-text">还没有收藏邮票</text>
          <text class="empty-hint">点击明信片上的心形图标即可收藏</text>
        </view>
      </view>

      <view class="section">
        <view class="section-header">
          <text class="section-title">所有明信片</text>
          <text class="section-count">{{ postcards.length }} 张</text>
        </view>

        <view v-if="postcards.length > 0" class="postcard-list">
          <view
            v-for="card in postcards"
            :key="card.id"
            class="postcard-item"
            @click="viewPostcard(card)"
          >
            <view class="postcard-image">
              <image v-if="card.photoUrl" :src="card.photoUrl" class="postcard-image-src" mode="aspectFill" />
              <IconImage v-else :size="40" color="#999" />
            </view>
            <view class="postcard-info">
              <text class="postcard-location">{{ card.locationName }}</text>
              <text class="postcard-city">{{ card.city }}</text>
              <text class="postcard-note">{{ card.note }}</text>
            </view>
            <view class="postcard-favorite" @click.stop="toggleFavorite(card.id)">
              <IconFavorite :size="28" :color="card.isFavorite ? '#FF4757' : '#CCC'" />
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
  IconImage,
  IconStampClassic,
  IconBookOpen,
  IconFavorite
} from '@/components/icons'

const store = usePostcardStore()

const postcards = computed(() => store.sortedPostcards)

const favorites = computed(() => postcards.value.filter(p => p.isFavorite))

const albumCount = computed(() => {
  const years = new Set(postcards.value.map(p => new Date(p.recordedAt).getFullYear()))
  return Math.max(1, years.size)
})

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

.stats-section {
  margin-bottom: 32rpx;
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

.section {
  margin-bottom: 32rpx;
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

.section-count {
  font-size: 24rpx;
  color: #999;
}

.stamp-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16rpx;
}

.stamp-item {
  background: #fff;
  border-radius: 20rpx;
  overflow: hidden;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.04);
}

.stamp-card {
  padding: 16rpx;
}

.stamp-perforation {
  position: relative;
  margin-bottom: 12rpx;
}

.stamp-image {
  width: 100%;
  height: 160rpx;
  background: #F5F5DC;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.stamp-image-src {
  width: 100%;
  height: 100%;
}

.stamp-location {
  font-size: 26rpx;
  font-weight: 600;
  color: #2C2C2C;
  display: block;
  margin-bottom: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.stamp-city {
  font-size: 22rpx;
  color: #999;
  display: block;
  margin-bottom: 12rpx;
}

.stamp-favorite {
  display: flex;
  justify-content: flex-end;
}

.postcard-list {
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.postcard-item {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 16rpx;
  padding: 16rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.04);
}

.postcard-image {
  width: 80rpx;
  height: 80rpx;
  background: #F5F5DC;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16rpx;
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
  gap: 4rpx;
}

.postcard-location {
  font-size: 26rpx;
  font-weight: 600;
  color: #2C2C2C;
}

.postcard-city {
  font-size: 22rpx;
  color: #999;
}

.postcard-note {
  font-size: 20rpx;
  color: #666;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.postcard-favorite {
  padding: 8rpx;
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
</style>
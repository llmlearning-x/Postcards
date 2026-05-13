<template>
  <view class="page-container">
    <view class="custom-header" v-if="postcard">
      <view class="header-left" @click="goBack">
        <IconBack :size="28" color="#fff" />
      </view>
      <text class="header-title">明信片详情</text>
      <view class="header-right" @click="showMoreOptions">
        <IconMore :size="28" color="#fff" />
      </view>
    </view>

    <view class="loading-overlay" v-if="store.isLoading">
      <view class="loading-content">
        <view class="loading-spinner"></view>
        <text class="loading-text">加载中...</text>
      </view>
    </view>

    <view class="content" v-else-if="postcard">
      <scroll-view scroll-y class="scroll-content">
        <view class="card-detail">
          <view class="card-image-wrapper">
            <image 
              v-if="postcard.photoUrl" 
              :src="postcard.photoUrl" 
              class="card-image"
              mode="aspectFill"
              @click="previewImage"
            />
            <view v-else class="card-image-placeholder">
              <IconImage :size="64" color="#999" />
            </view>
          </view>

          <view class="card-info">
            <view class="info-row">
              <IconLocation :size="24" color="#2E7D58" />
              <text class="location-text">{{ postcard.locationName }}</text>
            </view>
            <view class="info-row">
              <IconMap :size="24" color="#666" />
              <text class="city-text">{{ postcard.city }} · {{ postcard.country }}</text>
            </view>
            <view class="info-row">
              <IconClock :size="24" color="#666" />
              <text class="date-text">{{ formatDate(postcard.recordedAt) }}</text>
            </view>
          </view>

          <view class="card-note">
            <IconEdit :size="24" color="#2E7D58" />
            <text class="note-text">{{ postcard.note }}</text>
          </view>

          <view class="card-stamp">
            <text class="stamp-label">邮票样式</text>
            <view class="stamp-display">
              <component :is="getStampComponent(postcard.stampDesign)" :size="48" :color="getStampColor(postcard.stampDesign)" />
              <text class="stamp-name">{{ getStampName(postcard.stampDesign) }}</text>
            </view>
          </view>
        </view>

        <view class="actions-section">
          <view 
            class="action-btn favorite-btn" 
            :class="{ active: postcard.isFavorite }"
            @click="toggleFavorite"
          >
            <IconFavorite :size="32" :color="postcard.isFavorite ? '#FF4757' : '#666'" />
            <text class="action-text">{{ postcard.isFavorite ? '已收藏' : '收藏' }}</text>
          </view>
          <view class="action-btn edit-btn" @click="goToEdit">
            <IconEdit :size="32" color="#2E7D58" />
            <text class="action-text">编辑</text>
          </view>
          <view class="action-btn share-btn" @click="sharePostcard">
            <IconShare :size="32" color="#2E7D58" />
            <text class="action-text">分享</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <view class="empty-state" v-else>
      <IconImage :size="80" color="#ccc" />
      <text class="empty-text">明信片不存在</text>
      <view class="empty-btn" @click="goBack">
        <text class="empty-btn-text">返回首页</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, markRaw } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { UIUtil } from '@/utils/ui'
import { ToastMessages, StampDesigns } from '@/config/app'
import { DateUtil } from '@/utils/date'
import type { Postcard } from '@/model/Postcard'
import {
  IconBack,
  IconMore,
  IconLocation,
  IconMap,
  IconClock,
  IconEdit,
  IconImage,
  IconFavorite,
  IconShare,
  IconStampClassic,
  IconStampNature,
  IconStampCulture,
  IconStampCity,
  IconStampSea,
  IconStampSunset
} from '@/components/icons'

const store = usePostcardStore()

const postcard = ref<Postcard | null>(null)
const postcardId = ref('')

const stampComponents: Record<string, any> = {
  classic: markRaw(IconStampClassic),
  nature: markRaw(IconStampNature),
  culture: markRaw(IconStampCulture),
  city: markRaw(IconStampCity),
  sea: markRaw(IconStampSea),
  sunset: markRaw(IconStampSunset),
}

function getStampComponent(stampId: string) {
  return stampComponents[stampId] || IconStampClassic
}

function getStampColor(stampId: string): string {
  const stamp = StampDesigns.find(s => s.id === stampId)
  return stamp?.color || '#333'
}

function getStampName(stampId: string): string {
  const stamp = StampDesigns.find(s => s.id === stampId)
  return stamp?.name || '经典'
}

function formatDate(timestamp: number): string {
  return DateUtil.formatDateTime(timestamp)
}

function goBack() {
  uni.navigateBack({
    fail: () => {
      uni.switchTab({ url: '/pages/home/home' })
    }
  })
}

function previewImage() {
  if (postcard.value?.photoUrl) {
    uni.previewImage({
      urls: [postcard.value.photoUrl],
      current: postcard.value.photoUrl
    })
  }
}

function toggleFavorite() {
  if (postcard.value) {
    store.toggleFavorite(postcard.value.id)
    UIUtil.showSuccess(ToastMessages.success.favorite)
  }
}

function goToEdit() {
  if (postcard.value) {
    uni.navigateTo({
      url: `/pages/edit/edit?id=${postcard.value.id}`
    })
  }
}

function sharePostcard() {
  uni.showActionSheet({
    itemList: ['分享给好友', '生成图片'],
    success: (res) => {
      if (res.tapIndex === 0) {
        uni.showToast({
          title: '分享功能开发中',
          icon: 'none'
        })
      } else {
        uni.showToast({
          title: '生成图片功能开发中',
          icon: 'none'
        })
      }
    }
  })
}

function showMoreOptions() {
  uni.showActionSheet({
    itemList: ['编辑', '删除'],
    success: (res) => {
      if (res.tapIndex === 0) {
        goToEdit()
      } else {
        confirmDelete()
      }
    }
  })
}

function confirmDelete() {
  uni.showModal({
    title: '确认删除',
    content: ToastMessages.confirm.delete,
    success: (res) => {
      if (res.confirm && postcard.value) {
        store.deletePostcard(postcard.value.id)
        UIUtil.showSuccess(ToastMessages.success.delete)
        setTimeout(() => {
          uni.switchTab({ url: '/pages/home/home' })
        }, 1500)
      }
    }
  })
}

function loadPostcard() {
  if (postcardId.value) {
    postcard.value = store.getPostcardById(postcardId.value) || null
  }
}

onLoad((options) => {
  if (options?.id) {
    postcardId.value = options.id
  }
})

onMounted(() => {
  store.initData()
  loadPostcard()
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: #FAF7F2;
}

.custom-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 88rpx;
  padding-top: 44px;
  background: linear-gradient(135deg, #2E7D58 0%, #2E6E49 100%);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-left: 24rpx;
  padding-right: 24rpx;
  z-index: 100;
  box-sizing: border-box;
}

.header-left, .header-right {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.header-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #fff;
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
}

.loading-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.loading-spinner {
  width: 48rpx;
  height: 48rpx;
  border: 4rpx solid #F3F3F3;
  border-top: 4rpx solid #2E7D58;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-text {
  font-size: 26rpx;
  color: #666;
}

.content {
  padding-top: calc(88rpx + 44px);
}

.scroll-content {
  height: calc(100vh - 88rpx - 44px);
}

.card-detail {
  margin: 24rpx;
  background: #fff;
  border-radius: 24rpx;
  overflow: hidden;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
}

.card-image-wrapper {
  width: 100%;
  height: 400rpx;
}

.card-image {
  width: 100%;
  height: 100%;
}

.card-image-placeholder {
  width: 100%;
  height: 100%;
  background: #F5F5DC;
  display: flex;
  align-items: center;
  justify-content: center;
}

.card-info {
  padding: 24rpx;
  display: flex;
  flex-direction: column;
  gap: 16rpx;
  border-bottom: 1rpx solid #F0F0F0;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.location-text {
  font-size: 30rpx;
  font-weight: 600;
  color: #2C2C2C;
}

.city-text, .date-text {
  font-size: 26rpx;
  color: #666;
}

.card-note {
  padding: 24rpx;
  display: flex;
  flex-direction: column;
  gap: 12rpx;
  border-bottom: 1rpx solid #F0F0F0;
}

.note-text {
  font-size: 28rpx;
  color: #444;
  line-height: 1.6;
}

.card-stamp {
  padding: 24rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.stamp-label {
  font-size: 26rpx;
  color: #666;
}

.stamp-display {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.stamp-name {
  font-size: 26rpx;
  color: #2C2C2C;
}

.actions-section {
  margin: 24rpx;
  display: flex;
  gap: 24rpx;
}

.action-btn {
  flex: 1;
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.04);
}

.action-btn.active {
  background: rgba(255, 71, 87, 0.1);
}

.action-text {
  font-size: 24rpx;
  color: #666;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120rpx 40rpx;
}

.empty-text {
  font-size: 30rpx;
  color: #999;
  margin-top: 24rpx;
}

.empty-btn {
  margin-top: 40rpx;
  background: linear-gradient(135deg, #2E7D58 0%, #2E6E49 100%);
  padding: 24rpx 64rpx;
  border-radius: 999rpx;
}

.empty-btn-text {
  font-size: 28rpx;
  color: #fff;
  font-weight: 600;
}
</style>
<template>
  <view class="page-container">
    <view class="header">
      <text class="header-title">旅行地图</text>
      <text class="header-subtitle">探索去过的地方</text>
    </view>

    <scroll-view class="content" scroll-y>
      <view class="map-section">
        <view class="map-card">
          <view class="map-header">
            <text class="map-title">我的足迹</text>
            <text class="map-count">{{ cityCount }} 座城市</text>
          </view>
          
          <view class="route-container">
            <view class="route-line"></view>
            <view class="route-cities">
              <view
                v-for="(city, index) in cityList"
                :key="city"
                class="route-city"
              >
                <view class="city-dot" :class="{ start: index === 0, end: index === cityList.length - 1 }">
                  <text class="dot-number">{{ index + 1 }}</text>
                </view>
                <text class="city-name">{{ city }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <view class="stats-section">
        <view class="section-header">
          <text class="section-title">旅行统计</text>
        </view>

        <view class="stats-grid">
          <view class="stat-card">
            <IconGlobe :size="36" color="#2E7D58" />
            <text class="stat-value">{{ countryCount }}</text>
            <text class="stat-label">国家</text>
          </view>
          <view class="stat-card">
            <IconLocation :size="36" color="#2E7D58" />
            <text class="stat-value">{{ cityCount }}</text>
            <text class="stat-label">城市</text>
          </view>
          <view class="stat-card">
            <IconImage :size="36" color="#2E7D58" />
            <text class="stat-value">{{ postcards.length }}</text>
            <text class="stat-label">明信片</text>
          </view>
          <view class="stat-card">
            <IconStampClassic :size="36" color="#2E7D58" />
            <text class="stat-value">{{ travels.length }}</text>
            <text class="stat-label">旅程</text>
          </view>
        </view>
      </view>

      <view class="travels-section">
        <view class="section-header">
          <text class="section-title">旅程路线</text>
        </view>

        <view v-if="travels.length > 0" class="travel-list">
          <view v-for="travel in travels" :key="travel.id" class="travel-card">
            <view class="travel-icon">
              <component :is="getTravelIcon(travel.status)" :size="36" :color="getTravelIconColor(travel.status)" />
            </view>
            <view class="travel-info">
              <text class="travel-title">{{ travel.title }}</text>
              <text class="travel-destination">{{ travel.destination }}</text>
              <text class="travel-date">{{ formatTravelDate(travel) }}</text>
            </view>
            <view class="travel-status-badge" :class="travel.status">
              <text class="badge-text">{{ getStatusText(travel.status) }}</text>
            </view>
          </view>
        </view>
      </view>

      <view class="bottom-space"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { computed, onMounted, markRaw } from 'vue'
import { usePostcardStore } from '@/stores/postcard'
import { TravelStatus } from '@/model/Travel'
import type { Travel } from '@/model/Travel'
import {
  IconGlobe,
  IconLocation,
  IconImage,
  IconStampClassic,
  IconRocket,
  IconCheckCircle,
  IconClipboardList,
  IconMapPin
} from '@/components/icons'

const store = usePostcardStore()

const travels = computed(() => store.sortedTravels)
const postcards = computed(() => store.sortedPostcards)

const cityList = computed(() => {
  const cities = new Set(postcards.value.map(p => p.city).filter(c => c))
  return Array.from(cities)
})

const cityCount = computed(() => cityList.value.length)

const countryCount = computed(() => {
  const countries = new Set(postcards.value.map(p => p.country).filter(c => c))
  return countries.size
})

function getTravelIcon(status: string) {
  switch (status) {
    case TravelStatus.ONGOING:
      return markRaw(IconRocket)
    case TravelStatus.COMPLETED:
      return markRaw(IconCheckCircle)
    case TravelStatus.PLANNED:
      return markRaw(IconClipboardList)
    default:
      return markRaw(IconMapPin)
  }
}

function getTravelIconColor(status: string): string {
  switch (status) {
    case TravelStatus.ONGOING:
      return '#22C55E'
    case TravelStatus.COMPLETED:
      return '#6B7280'
    case TravelStatus.PLANNED:
      return '#3B82F6'
    default:
      return '#2E7D58'
  }
}

function getStatusText(status: string): string {
  switch (status) {
    case TravelStatus.ONGOING:
      return '进行中'
    case TravelStatus.COMPLETED:
      return '已完成'
    case TravelStatus.PLANNED:
      return '待出发'
    case TravelStatus.CANCELLED:
      return '已取消'
    default:
      return '未知'
  }
}

function formatTravelDate(travel: Travel): string {
  const start = new Date(travel.startDate)
  const end = new Date(travel.endDate)
  return `${start.getMonth() + 1}/${start.getDate()} - ${end.getMonth() + 1}/${end.getDate()}`
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

.map-section {
  margin-bottom: 32rpx;
}

.map-card {
  background: #fff;
  border-radius: 24rpx;
  padding: 32rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
}

.map-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32rpx;
}

.map-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2C2C2C;
}

.map-count {
  font-size: 24rpx;
  color: #999;
}

.route-container {
  position: relative;
  padding: 20rpx 0;
}

.route-line {
  position: absolute;
  top: 24rpx;
  left: 24rpx;
  right: 0;
  height: 4rpx;
  background: linear-gradient(90deg, #2E7D58 0%, #B2DFDB 100%);
  border-radius: 2rpx;
}

.route-cities {
  display: flex;
  justify-content: space-between;
}

.route-city {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  position: relative;
  z-index: 1;
}

.city-dot {
  width: 48rpx;
  height: 48rpx;
  background: #2E7D58;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 4rpx solid #fff;
  box-shadow: 0 4rpx 12rpx rgba(46, 125, 88, 0.3);

  &.start {
    background: #C41E3A;
    box-shadow: 0 0 0 8rpx rgba(196, 30, 58, 0.2);
  }

  &.end {
    background: #22C55E;
    box-shadow: 0 0 0 8rpx rgba(34, 197, 94, 0.2);
  }
}

.dot-number {
  font-size: 20rpx;
  color: #fff;
  font-weight: 600;
}

.city-name {
  font-size: 22rpx;
  color: #666;
  white-space: nowrap;
}

.stats-section {
  margin-bottom: 32rpx;
}

.section-header {
  margin-bottom: 20rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2C2C2C;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16rpx;
}

.stat-card {
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.04);
}

.stat-value {
  font-size: 36rpx;
  font-weight: 700;
  color: #2E7D58;
  font-family: 'Georgia', serif;
}

.stat-label {
  font-size: 20rpx;
  color: #999;
}

.travels-section {
  margin-bottom: 32rpx;
}

.travel-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.travel-card {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.04);
}

.travel-icon {
  width: 80rpx;
  height: 80rpx;
  background: #F5F5DC;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20rpx;
}

.travel-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.travel-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #2C2C2C;
}

.travel-destination {
  font-size: 24rpx;
  color: #666;
}

.travel-date {
  font-size: 22rpx;
  color: #999;
}

.travel-status-badge {
  padding: 8rpx 16rpx;
  border-radius: 999rpx;

  &.ongoing {
    background: rgba(34, 197, 94, 0.1);
    .badge-text {
      color: #22C55E;
    }
  }

  &.completed {
    background: rgba(107, 114, 128, 0.1);
    .badge-text {
      color: #6B7280;
    }
  }

  &.planned {
    background: rgba(59, 130, 246, 0.1);
    .badge-text {
      color: #3B82F6;
    }
  }

  &.cancelled {
    background: rgba(239, 68, 68, 0.1);
    .badge-text {
      color: #EF4444;
    }
  }
}

.badge-text {
  font-size: 22rpx;
  font-weight: 600;
}

.bottom-space {
  height: 120rpx;
}
</style>
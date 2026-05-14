<template>
  <view class="page-container">
    <view class="postal-header">
      <view class="header-perf"></view>
      <text class="header-kicker">ATLAS · 旅行足迹</text>
      <text class="header-title">走过的远方</text>
      <text class="header-subtitle">{{ countryCount }} 个国家 · {{ cityCount }} 座城市</text>
    </view>

    <scroll-view class="content" scroll-y>
      <!-- Route card -->
      <view class="route-card">
        <view class="route-card-hd">
          <text class="route-card-title">城市足迹</text>
          <text class="route-card-count">{{ String(cityList.length).padStart(2, '0') }} 站</text>
        </view>
        <view v-if="cityList.length > 0" class="route-track">
          <view class="route-path-line"></view>
          <view class="route-cities">
            <view
              v-for="(city, idx) in cityList"
              :key="city"
              class="route-stop"
            >
              <view
                class="stop-dot"
                :class="{
                  'stop-dot-first': idx === 0,
                  'stop-dot-last': idx === cityList.length - 1
                }"
              >
                <text class="stop-num">{{ idx + 1 }}</text>
              </view>
              <text class="stop-name">{{ city }}</text>
            </view>
          </view>
        </view>
        <view v-else class="route-empty">
          <text class="route-empty-txt">尚无足迹记录</text>
        </view>
      </view>

      <!-- Stats 2×2 grid -->
      <view class="stat-grid">
        <view class="stat-cell">
          <view class="stat-icon-ring">
            <IconGlobe :size="28" :color="$travel_blue" />
          </view>
          <text class="stat-num">{{ countryCount }}</text>
          <text class="stat-lbl">COUNTRIES</text>
        </view>
        <view class="stat-cell">
          <view class="stat-icon-ring">
            <IconLocation :size="28" :color="$travel_blue" />
          </view>
          <text class="stat-num">{{ cityCount }}</text>
          <text class="stat-lbl">CITIES</text>
        </view>
        <view class="stat-cell">
          <view class="stat-icon-ring">
            <IconImage :size="28" :color="$travel_blue" />
          </view>
          <text class="stat-num">{{ postcards.length }}</text>
          <text class="stat-lbl">POSTCARDS</text>
        </view>
        <view class="stat-cell">
          <view class="stat-icon-ring">
            <IconStampClassic :size="28" :color="$travel_blue" />
          </view>
          <text class="stat-num">{{ travels.length }}</text>
          <text class="stat-lbl">JOURNEYS</text>
        </view>
      </view>

      <!-- Journey list -->
      <view class="section-block">
        <view class="section-hd">
          <view class="section-hd-top">
            <text class="section-kicker">JOURNEYS · 旅程路线</text>
            <view class="new-journey-btn" @click="goCreateTravel">
              <text class="new-journey-txt">+ 新建旅程</text>
            </view>
          </view>
          <view class="section-rule"></view>
        </view>

        <view v-if="travels.length > 0" class="journey-list">
          <view
            v-for="(travel, idx) in travels"
            :key="travel.id"
            class="journey-row"
          >
            <view v-if="idx > 0" class="journey-divider"></view>
            <view class="journey-inner" @click="goEditTravel(travel.id)">
              <view class="journey-status-col">
                <view class="journey-status-dot" :class="`status-${travel.status}`"></view>
                <view v-if="travel.isCurrent" class="journey-current-ring"></view>
              </view>
              <view class="journey-body">
                <view class="journey-title-row">
                  <text class="journey-title">{{ travel.title }}</text>
                  <text v-if="travel.isCurrent" class="journey-active-tag">当前</text>
                </view>
                <text class="journey-dest">{{ travel.destination.toUpperCase() }}</text>
                <text class="journey-date">{{ formatTravelDate(travel) }}</text>
              </view>
              <view class="journey-badge" :class="`badge-${travel.status}`">
                <text class="journey-badge-txt">{{ getStatusText(travel.status) }}</text>
              </view>
            </view>
          </view>
        </view>

        <view v-else class="journey-empty" @click="goCreateTravel">
          <text class="journey-empty-txt">暂无旅程 · 点击新建</text>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { TravelStatus } from '@/model/Travel'
import type { Travel } from '@/model/Travel'
import {
  IconGlobe,
  IconLocation,
  IconImage,
  IconStampClassic,
} from '@/components/icons'

const store = usePostcardStore()
const travels = computed(() => store.sortedTravels)
const postcards = computed(() => store.sortedPostcards)

// Expose color as a computed prop workaround for inline binding
const $travel_blue = '#3C604D'

const cityList = computed(() => {
  const cities = new Set(postcards.value.map(p => p.city).filter(c => c))
  return Array.from(cities)
})
const cityCount = computed(() => cityList.value.length)
const countryCount = computed(() => {
  const countries = new Set(postcards.value.map(p => p.country).filter(c => c))
  return countries.size
})

function getStatusText(status: string): string {
  switch (status) {
    case TravelStatus.ONGOING:    return '进行中'
    case TravelStatus.COMPLETED:  return '已完成'
    case TravelStatus.PLANNED:    return '待出发'
    case TravelStatus.CANCELLED:  return '已取消'
    default:                      return '未知'
  }
}

function formatTravelDate(travel: Travel): string {
  const s = new Date(travel.startDate)
  const e = new Date(travel.endDate)
  return `${s.getMonth() + 1}·${String(s.getDate()).padStart(2,'0')} — ${e.getMonth() + 1}·${String(e.getDate()).padStart(2,'0')}`
}

function goCreateTravel() {
  uni.navigateTo({ url: '/pages/travel/travel' })
}

function goEditTravel(id: string) {
  uni.navigateTo({ url: `/pages/travel/travel?id=${id}` })
}

onMounted(() => store.initData())
onShow(() => { if (store.travels.length > 0) store.initData() })
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $page-background;
}

// ─── Header ───
.postal-header {
  background: $page-background;
  padding: 100rpx 48rpx 40rpx;
  border-bottom: 1rpx solid $line-sepia;
  position: relative;
  flex-shrink: 0;
}

.header-perf {
  position: absolute;
  top: 90rpx;
  left: 0;
  right: 0;
  height: 2rpx;
  background-image: repeating-linear-gradient(
    90deg,
    $line-sepia 0,
    $line-sepia 8rpx,
    transparent 8rpx,
    transparent 16rpx
  );
}

.header-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 4rpx;
  color: $travel-blue;
  margin-bottom: 22rpx;
}

.header-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 58rpx;
  font-weight: 400;
  color: $ink-black;
  line-height: 1.15;
  letter-spacing: -1rpx;
}

.header-subtitle {
  display: block;
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $body-text;
  margin-top: 18rpx;
}

.content {
  flex: 1;
  overflow: hidden;
}

// ─── Route card ───
.route-card {
  margin: 40rpx 40rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 28rpx 28rpx 24rpx;
}

.route-card-hd {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 28rpx;
}

.route-card-title {
  font-family: $font-family-serif;
  font-size: 30rpx;
  font-weight: 500;
  color: $ink-black;
}

.route-card-count {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

.route-track {
  position: relative;
  padding-bottom: 8rpx;
}

.route-path-line {
  position: absolute;
  top: 24rpx;
  left: 24rpx;
  right: 24rpx;
  height: 1rpx;
  background: $line-sepia;
}

.route-cities {
  display: flex;
  justify-content: space-between;
  position: relative;
}

.route-stop {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
}

.stop-dot {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background: $page-background;
  border: 2rpx solid $line-sepia;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1;
}

.stop-dot-first {
  background: $stamp-red;
  border-color: $stamp-red;
  box-shadow: 0 0 0 8rpx rgba(164, 59, 45, 0.12);
}

.stop-dot-last {
  background: $travel-blue;
  border-color: $travel-blue;
  box-shadow: 0 0 0 8rpx $green-soft;
}

.stop-num {
  font-family: $font-family-mono;
  font-size: 18rpx;
  color: $card-bg;
  font-weight: 600;
}

.stop-dot:not(.stop-dot-first):not(.stop-dot-last) .stop-num {
  color: $mute-text;
}

.stop-name {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: $body-text;
  white-space: nowrap;
}

.route-empty {
  padding: 32rpx 0;
  text-align: center;
}

.route-empty-txt {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $whisper;
}

// ─── Stat grid ───
.stat-grid {
  display: flex;
  gap: 0;
  margin: 32rpx 40rpx 0;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
  background: $card-bg;
  flex-wrap: wrap;
}

.stat-cell {
  flex: 1 1 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 32rpx 16rpx 28rpx;
  gap: 10rpx;
  border-right: 1rpx solid $line-sepia;
  border-bottom: 1rpx solid $line-sepia;
  box-sizing: border-box;

  &:nth-child(2n) { border-right: none; }
  &:nth-child(3),
  &:nth-child(4) { border-bottom: none; }
}

.stat-icon-ring {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  border: 1rpx solid $line-sepia;
  display: flex;
  align-items: center;
  justify-content: center;
  background: $page-background;
}

.stat-num {
  font-family: $font-family-serif;
  font-size: 52rpx;
  font-weight: 400;
  color: $ink-black;
  line-height: 1;
  letter-spacing: -1rpx;
}

.stat-lbl {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

// ─── Journey section ───
.section-block {
  margin: 40rpx 40rpx 0;
}

.section-hd { margin-bottom: 20rpx; }

.section-hd-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14rpx;
}

.section-kicker {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  white-space: nowrap;
}

.new-journey-btn {
  border: 1rpx solid rgba(60, 96, 77, 0.4);
  border-radius: 100rpx;
  padding: 8rpx 24rpx;
  background: rgba(60, 96, 77, 0.06);
}
.new-journey-txt {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.section-rule {
  height: 1rpx;
  background: $line-sepia;
}

.journey-list {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
}

.journey-divider {
  height: 1rpx;
  background: $line-sepia;
  margin: 0 24rpx;
}

.journey-inner {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx 24rpx;
}

.journey-status-col {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36rpx;
}

.journey-status-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  position: relative;

  &.status-ongoing   { background: $alive-green; }
  &.status-completed { background: $mute-text; }
  &.status-planned   { background: #1F4B66; }
  &.status-cancelled { background: $stamp-red; opacity: 0.5; }
}

.journey-current-ring {
  position: absolute;
  top: -6rpx;
  left: -6rpx;
  width: 28rpx;
  height: 28rpx;
  border-radius: 50%;
  border: 1rpx solid $alive-green;
  animation: pulse-out 1.8s ease-out infinite;
}

.journey-title-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 6rpx;
}

.journey-active-tag {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 2rpx;
  color: $alive-green;
  border: 1rpx solid rgba(94, 140, 79, 0.4);
  padding: 2rpx 10rpx;
  border-radius: 999rpx;
}

.journey-body {
  flex: 1;
  min-width: 0;
}

.journey-title {
  font-family: $font-family-serif;
  font-size: 28rpx;
  font-weight: 500;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
  min-width: 0;
}

.journey-dest {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  margin-bottom: 4rpx;
}

.journey-date {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  color: $whisper;
  letter-spacing: 1rpx;
}

.journey-badge {
  flex-shrink: 0;
  padding: 6rpx 18rpx;
  border-radius: 999rpx;
  border: 1rpx solid currentColor;

  &.badge-ongoing   { color: $alive-green; background: rgba(94, 140, 79, 0.08); }
  &.badge-completed { color: $mute-text;   background: rgba(142, 135, 117, 0.08); }
  &.badge-planned   { color: #1F4B66;      background: rgba(31, 75, 102, 0.08); }
  &.badge-cancelled { color: $stamp-red;   background: rgba(164, 59, 45, 0.08); }
}

.journey-badge-txt {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
}

.journey-empty {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 60rpx 0;
  text-align: center;
}

.journey-empty-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $whisper;
}

.btm-gap { height: 120rpx; }
</style>

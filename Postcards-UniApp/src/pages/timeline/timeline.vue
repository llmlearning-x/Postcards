<template>
  <view class="page-container">
    <view class="postal-header">
      <view class="header-perf"></view>
      <text class="header-kicker">TIMELINE · 时间轴</text>
      <text class="header-title">回顾旅途</text>
      <text class="header-subtitle">按日期倒序 · 共 {{ postcards.length }} 张明信片</text>
    </view>

    <scroll-view class="content" scroll-y>
      <view v-if="groupedPostcards.length > 0" class="groups-wrap">
        <view v-for="group in groupedPostcards" :key="group.dateKey" class="timeline-group">
          <!-- Date group header -->
          <view class="group-hd">
            <view class="group-date-block">
              <text class="group-date-n">{{ group.dayNum }}</text>
              <view>
                <text class="group-month-lbl">{{ group.monthLbl }}</text>
                <text class="group-weekday">{{ group.weekday }}</text>
              </view>
            </view>
            <view class="group-rule"></view>
            <text class="group-count-lbl">{{ String(group.items.length).padStart(2, '0') }} 张</text>
          </view>

          <!-- Cards with timeline rail -->
          <view class="rail-wrap">
            <view class="rail-line"></view>
            <view class="cards-col">
              <view
                v-for="(card, idx) in group.items"
                :key="card.id"
                class="rail-item"
              >
                <view
                  class="rail-dot"
                  :class="{ 'rail-dot-first': idx === 0 && groupedPostcards[0] === group }"
                ></view>
                <view class="letter-row" @click="viewPostcard(card)">
                  <view class="row-thumb">
                    <image v-if="card.photoUrl" :src="card.photoUrl" class="row-thumb-img" mode="aspectFill" />
                    <view v-else class="row-thumb-grad"></view>
                  </view>
                  <view class="row-body">
                    <text class="row-meta">{{ card.city.toUpperCase() }} · {{ formatDotDate(card.recordedAt) }}</text>
                    <text class="row-loc">{{ card.locationName }}</text>
                    <text class="row-note">"{{ card.note }}"</text>
                  </view>
                  <view class="row-trail">
                    <view @click.stop="toggleFavorite(card.id)">
                      <IconFavorite :size="28" :color="card.isFavorite ? '#A43B2D' : '#B5AE9B'" />
                    </view>
                    <view class="stamp-badge" :style="{ 'border-color': getStampColor(card.stampDesign) }">
                      <text class="stamp-dot" :style="{ color: getStampColor(card.stampDesign) }">✦</text>
                    </view>
                  </view>
                </view>
              </view>
            </view>
          </view>
        </view>

        <text class="timeline-end">— · 旅程开始 · —</text>
      </view>

      <view v-else class="empty-state">
        <IconImage :size="96" color="#B5AE9B" />
        <text class="empty-main">还没有明信片</text>
        <text class="empty-sub">去记录你的第一张明信片吧</text>
        <view class="empty-btn" @click="goToRecord">
          <text class="empty-btn-txt">立即记录</text>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { usePostcardStore } from '@/stores/postcard'
import { StampDesigns } from '@/config/app'
import type { Postcard } from '@/model/Postcard'
import { IconImage, IconFavorite } from '@/components/icons'
import { formatDotDate, getStampColor } from '@/utils/stamp'

const store = usePostcardStore()
const postcards = computed(() => store.sortedPostcards)

const WEEKDAYS = ['日', '一', '二', '三', '四', '五', '六']
const MONTHS = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']

interface GroupedPostcard {
  dateKey: string
  dayNum: string
  monthLbl: string
  weekday: string
  items: Postcard[]
}

const groupedPostcards = computed<GroupedPostcard[]>(() => {
  const map: Record<string, Postcard[]> = {}
  postcards.value.forEach(card => {
    const d = new Date(card.recordedAt)
    const key = `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`
    if (!map[key]) map[key] = []
    map[key].push(card)
  })
  return Object.entries(map).map(([key, items]) => {
    const d = new Date(items[0].recordedAt)
    return {
      dateKey: key,
      dayNum: String(d.getDate()).padStart(2, '0'),
      monthLbl: MONTHS[d.getMonth()],
      weekday: '星期' + WEEKDAYS[d.getDay()],
      items,
    }
  })
})

function viewPostcard(card: Postcard) {
  uni.navigateTo({ url: `/pages/detail/detail?id=${card.id}` })
}

function toggleFavorite(id: string) {
  store.toggleFavorite(id)
  uni.showToast({ title: '收藏已更新', icon: 'success' })
}

function goToRecord() {
  uni.switchTab({ url: '/pages/record/record' })
}

onMounted(() => store.initData())
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $page-background;
}

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

.groups-wrap {
  padding: 40rpx 40rpx 0;
}

// ─── Timeline group ───
.timeline-group {
  margin-bottom: 44rpx;
}

.group-hd {
  display: flex;
  align-items: baseline;
  gap: 24rpx;
  margin-bottom: 24rpx;
}

.group-date-block {
  display: flex;
  align-items: baseline;
  gap: 12rpx;
  flex-shrink: 0;
}

.group-date-n {
  font-family: $font-family-serif;
  font-size: 52rpx;
  font-weight: 400;
  color: $ink-black;
  line-height: 1;
  letter-spacing: -1rpx;
}

.group-month-lbl {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

.group-weekday {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 2rpx;
  color: $whisper;
}

.group-rule {
  flex: 1;
  height: 1rpx;
  background: $line-sepia;
}

.group-count-lbl {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
  flex-shrink: 0;
}

// ─── Timeline rail ───
.rail-wrap {
  position: relative;
  padding-left: 36rpx;
}

.rail-line {
  position: absolute;
  left: 4rpx;
  top: 24rpx;
  bottom: 24rpx;
  width: 2rpx;
  background: $line-sepia;
}

.cards-col {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.rail-item {
  position: relative;
}

.rail-dot {
  position: absolute;
  left: -38rpx;
  top: 48rpx;
  width: 18rpx;
  height: 18rpx;
  border-radius: 50%;
  background: $page-background;
  border: 3rpx solid $travel-blue;
  z-index: 1;
}

.rail-dot-first {
  background: $travel-blue;
  box-shadow: 0 0 0 8rpx $green-soft;
}

// ─── Letter row card ───
.letter-row {
  display: flex;
  gap: 24rpx;
  padding: 24rpx;
  background: $card-bg;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  align-items: stretch;
}

.row-thumb {
  width: 136rpx;
  height: 136rpx;
  border-radius: 6rpx;
  overflow: hidden;
  flex-shrink: 0;
}

.row-thumb-img { width: 100%; height: 100%; }

.row-thumb-grad {
  width: 100%;
  height: 100%;
  background: linear-gradient(180deg, #C9D2B6 0%, #6E8862 100%);
}

.row-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-width: 0;
  gap: 8rpx;
}

.row-meta {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

.row-loc {
  font-family: $font-family-serif;
  font-size: 30rpx;
  font-weight: 500;
  color: $ink-black;
  line-height: 1.1;
}

.row-note {
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 24rpx;
  color: $body-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.row-trail {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  justify-content: space-between;
  padding-left: 8rpx;
}

.stamp-badge {
  width: 44rpx;
  height: 54rpx;
  border: 1rpx dashed currentColor;
  background: $paper-beige;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 2rpx;
}

.stamp-dot { font-size: 20rpx; }

// ─── Timeline end ───
.timeline-end {
  display: block;
  text-align: center;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 6rpx;
  color: $whisper;
  padding: 24rpx 0 40rpx;
}

// ─── Empty state ───
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 100rpx 40rpx;
}

.empty-main {
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: $body-text;
  margin-top: 28rpx;
  margin-bottom: 8rpx;
}

.empty-sub {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $mute-text;
  margin-bottom: 40rpx;
}

.empty-btn {
  background: $travel-blue;
  padding: 20rpx 60rpx;
  border-radius: 6rpx;
}

.empty-btn-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $card-bg;
  letter-spacing: 4rpx;
}

.btm-gap { height: 120rpx; }
</style>

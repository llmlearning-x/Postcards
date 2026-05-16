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
                  <!-- Full-width photo -->
                  <view class="row-photo">
                    <image v-if="card.photoUrl" :src="card.photoUrl" class="row-photo-img" mode="aspectFill" />
                    <view v-else class="row-photo-grad"></view>
                    <!-- Postmark overlay -->
                    <view class="row-postmark">
                      <text class="row-pm-city">{{ card.city.toUpperCase() }}</text>
                      <text class="row-pm-date">{{ formatDotDate(card.recordedAt) }}</text>
                    </view>
                    <!-- Stamp badge -->
                    <view class="row-stamp" :style="{ 'border-color': getStampColor(card.stampDesign) }">
                      <image v-if="getStampImageUrl(card.stampDesign)" :src="getStampImageUrl(card.stampDesign)" class="row-stamp-img" mode="aspectFill" />
                      <text v-else class="row-stamp-dot" :style="{ color: getStampColor(card.stampDesign) }">✦</text>
                    </view>
                  </view>
                  <!-- Text body -->
                  <view class="row-body">
                    <view class="row-body-main">
                      <text class="row-loc">{{ card.locationName }}</text>
                      <text class="row-note" v-if="card.note">"{{ card.note }}"</text>
                    </view>
                    <view class="row-fav" @click.stop="toggleFavorite(card.id)">
                      <IconFavorite :size="32" :color="card.isFavorite ? '#A43B2D' : '#C8C0B0'" />
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

  <PostcardFlipModal :postcard="activeCard" @close="activeCard = null" />
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { usePostcardStore } from '@/stores/postcard'
import { StampDesigns } from '@/config/app'
import type { Postcard } from '@/model/Postcard'
import { IconImage, IconFavorite } from '@/components/icons'
import { formatDotDate, getStampColor, getStampImageUrl } from '@/utils/stamp'
import PostcardFlipModal from '@/components/PostcardFlipModal.vue'

const store = usePostcardStore()
const postcards = computed(() => store.sortedPostcards)
const activeCard = ref<Postcard | null>(null)

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
  activeCard.value = card
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
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 56rpx 48rpx 20rpx;
  position: relative;
  flex-shrink: 0;
}

.header-perf {
  position: absolute; bottom: 0; left: 0; right: 0; height: 6rpx;
  background: repeating-linear-gradient(-45deg, #B8312A 0, #B8312A 5rpx, #ffffff 5rpx, #ffffff 10rpx, #1C3A72 10rpx, #1C3A72 15rpx, #ffffff 15rpx, #ffffff 20rpx);
}

.header-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 4rpx;
  color: rgba(255,255,255,0.65);
  margin-bottom: 12rpx;
}

.header-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 46rpx;
  font-weight: 400;
  color: rgba(255,255,255,0.95);
  line-height: 1.15;
  letter-spacing: -1rpx;
}

.header-subtitle {
  display: block;
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: rgba(255,255,255,0.7);
  margin-top: 10rpx;
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
  background: $card-bg;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  overflow: hidden;
}

// ─── Full-width photo ───
.row-photo {
  width: 100%;
  height: 320rpx;
  position: relative;
  overflow: hidden;
}

.row-photo-img { width: 100%; height: 100%; }

.row-photo-grad {
  width: 100%;
  height: 100%;
  background: linear-gradient(160deg, #C9D2B6 0%, #6E8862 100%);
}

// Postmark overlay (bottom-left of photo)
.row-postmark {
  position: absolute;
  bottom: 20rpx;
  left: 20rpx;
  background: rgba(20, 15, 10, 0.45);
  border: 1rpx solid rgba(244, 239, 229, 0.3);
  border-radius: 4rpx;
  padding: 8rpx 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2rpx;
}

.row-pm-city {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: rgba(244, 239, 229, 0.85);
}

.row-pm-date {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: rgba(244, 239, 229, 0.95);
  line-height: 1.1;
}

// Stamp badge (top-right of photo)
.row-stamp {
  position: absolute;
  top: 16rpx;
  right: 16rpx;
  width: 56rpx;
  height: 70rpx;
  border: 1rpx dashed currentColor;
  background: rgba(251, 248, 241, 0.85);
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 3rpx;
}

.row-stamp-img { width: 48rpx; height: 48rpx; border-radius: 2rpx; }
.row-stamp-dot { font-size: 24rpx; }

// ─── Text body below photo ───
.row-body {
  display: flex;
  align-items: center;
  padding: 20rpx 24rpx;
  gap: 16rpx;
}

.row-body-main {
  flex: 1;
  min-width: 0;
}

.row-loc {
  display: block;
  font-family: $font-family-serif;
  font-size: 32rpx;
  font-weight: 500;
  color: $ink-black;
  margin-bottom: 6rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.row-note {
  display: block;
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 24rpx;
  color: $body-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.row-fav { flex-shrink: 0; padding: 8rpx; }

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

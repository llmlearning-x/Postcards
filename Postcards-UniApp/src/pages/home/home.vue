<template>
  <view class="page-container">
    <!-- Paper editorial header -->
    <view class="postal-header">
      <view class="header-perf"></view>
      <text class="header-kicker">INBOX · 旅笺 · 收件箱</text>
      <text class="header-title">今日 {{ padNum(postcards.length) }} 张</text>
      <text class="header-title">来自远方的笺</text>
      <text class="header-subtitle">{{ postcards.length }} 张明信片 · {{ travels.length }} 段旅程 · 一个仍在路上的你</text>
    </view>

    <scroll-view class="content" scroll-y>
      <!-- Today's letter — envelope hero -->
      <view v-if="latestPostcard" class="section-pad">
        <view class="today-meta">
          <text class="section-kicker">TODAY · 今日邮件</text>
          <view class="par-avion">
            <text class="par-avion-txt">par avion · VIA AIR MAIL</text>
          </view>
        </view>
        <view class="envelope-card" :class="{ 'env-opening': isOpeningEnvelope }" @click="openEnvelope(latestPostcard)">
          <view class="env-tear-line"></view>
          <view class="airmail-stripe"></view>
          <view class="envelope-body">
            <view class="env-photo-wrap">
              <image
                v-if="latestPostcard.photoUrl"
                :src="latestPostcard.photoUrl"
                class="env-photo"
                mode="aspectFill"
              />
              <view v-else class="env-photo-grad"></view>
              <text class="env-photo-label">{{ latestPostcard.locationName }}</text>
            </view>
            <view class="env-address">
              <view class="addr-row">
                <text class="addr-label">FROM</text>
                <view class="addr-detail">
                  <text class="addr-main">{{ latestPostcard.locationName }}</text>
                  <text class="addr-sub">{{ latestPostcard.city }} · 中国</text>
                </view>
              </view>
              <view class="addr-row">
                <text class="addr-label">TO</text>
                <view class="addr-detail">
                  <text class="addr-main">未来的我</text>
                </view>
              </view>
              <view class="postmark">
                <text class="pm-city">{{ latestPostcard.city.substring(0, 2) }}</text>
                <text class="pm-date">{{ dotDate(latestPostcard.recordedAt) }}</text>
                <text class="pm-year">2024</text>
              </view>
            </view>
          </view>
          <view class="airmail-stripe"></view>
        </view>
        <text class="tap-hint">点击 · 拆开这封信</text>
      </view>

      <!-- Stats row -->
      <view class="section-pad">
        <view class="stats-row">
          <view class="stat-pill">
            <text class="stat-n">{{ padNum(travels.length) }}</text>
            <text class="stat-lbl">JOURNEYS</text>
          </view>
          <view class="stat-pill">
            <text class="stat-n">{{ padNum(postcards.length) }}</text>
            <text class="stat-lbl">CARDS</text>
          </view>
          <view class="stat-pill stat-red">
            <text class="stat-n">{{ padNum(favoritesCount) }}</text>
            <text class="stat-lbl">LOVED</text>
          </view>
          <view class="stat-pill">
            <text class="stat-n">{{ padNum(cityCount) }}</text>
            <text class="stat-lbl">CITIES</text>
          </view>
        </view>
      </view>

      <!-- No journey — create prompt -->
      <view class="section-pad" v-if="!currentTravel">
        <view class="no-journey-card" @click="goCreateTravel">
          <view class="no-journey-left">
            <text class="no-journey-kicker">JOURNEY · 旅程</text>
            <text class="no-journey-title">开始一段旅程</text>
            <text class="no-journey-sub">创建旅程后才能寄出明信片</text>
          </view>
          <view class="no-journey-icon">
            <text class="no-journey-arrow">›</text>
          </view>
        </view>
      </view>

      <!-- Current journey -->
      <view class="section-pad" v-if="currentTravel">
        <view class="section-hd">
          <view>
            <text class="section-kicker">ONGOING · 进行中</text>
            <text class="section-ttl">{{ currentTravel.title }}</text>
          </view>
          <text class="section-right">{{ Math.round(progressPercent) }}%</text>
        </view>
        <view class="section-rule"></view>
        <view class="journey-card">
          <view class="journey-top">
            <view class="pulse-wrap">
              <view class="pulse-core"></view>
              <view class="pulse-ring"></view>
            </view>
            <text class="journey-day">第 {{ travelDays }} 天 / 共 {{ totalDays }} 天</text>
            <text class="journey-no">TRAVEL · 01</text>
          </view>
          <view class="journey-dest-row">
            <text class="journey-pin">◎</text>
            <text class="journey-dest">{{ currentTravel.destination }}</text>
          </view>
          <view class="progress-track">
            <view class="progress-fill" :style="{ width: progressPercent + '%' }"></view>
          </view>
          <view class="journey-dates">
            <text class="journey-mono">{{ dotDate(currentTravel.startDate) }} · 启程</text>
            <text class="journey-mono">{{ dotDate(currentTravel.endDate) }} · 归程</text>
          </view>
        </view>
      </view>

      <!-- Recent postcards -->
      <view class="section-pad">
        <view class="section-hd">
          <view>
            <text class="section-kicker">ARCHIVE · 信件回执</text>
            <text class="section-ttl">最近寄出</text>
          </view>
          <text class="section-link" @click="goToTimeline">全部 →</text>
        </view>
        <view class="section-rule"></view>

        <view v-if="recentPostcards.length > 0" class="card-list">
          <view
            v-for="card in recentPostcards"
            :key="card.id"
            class="letter-row"
            @click="viewPostcard(card)"
          >
            <view class="row-thumb">
              <image v-if="card.photoUrl" :src="card.photoUrl" class="row-thumb-img" mode="aspectFill" />
              <view v-else class="row-thumb-grad"></view>
            </view>
            <view class="row-body">
              <text class="row-meta">{{ card.city.toUpperCase() }} · {{ dotDate(card.recordedAt) }}</text>
              <text class="row-loc">{{ card.locationName }}</text>
              <text class="row-note">"{{ card.note }}"</text>
            </view>
            <view class="row-trail">
              <view :class="{ 'fav-stamping': stampingFavId === card.id }" @click.stop="toggleFavoriteWithAnim(card)">
                <IconFavorite :size="28" :color="card.isFavorite ? '#A43B2D' : '#B5AE9B'" />
              </view>
              <view class="stamp-badge" :style="{ 'border-color': stampColor(card.stampDesign) }">
                <text class="stamp-dot" :style="{ color: stampColor(card.stampDesign) }">✦</text>
              </view>
            </view>
          </view>
        </view>

        <view v-else class="empty-state">
          <IconImage :size="80" color="#B5AE9B" />
          <text class="empty-main">还没有明信片</text>
          <text class="empty-sub">去记录你的第一张明信片吧</text>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { usePostcardStore } from '@/stores/postcard'
import { StampDesigns } from '@/config/app'
import { DateUtil } from '@/utils/date'
import type { Postcard } from '@/model/Postcard'
import { IconFavorite, IconImage } from '@/components/icons'

const store = usePostcardStore()
const isOpeningEnvelope = ref(false)
const stampingFavId = ref<string | null>(null)

const travels = computed(() => store.sortedTravels)
const postcards = computed(() => store.sortedPostcards)
const currentTravel = computed(() => store.currentTravel)
const recentPostcards = computed(() => postcards.value.slice(0, 5))
const latestPostcard = computed(() => recentPostcards.value[0] || null)

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

const totalDays = computed(() => {
  if (!currentTravel.value) return 0
  return DateUtil.getDaysDiff(currentTravel.value.startDate, currentTravel.value.endDate)
})

const progressPercent = computed(() => {
  if (!currentTravel.value) return 0
  const total = currentTravel.value.endDate - currentTravel.value.startDate
  const elapsed = Date.now() - currentTravel.value.startDate
  return Math.min(100, Math.max(0, (elapsed / total) * 100))
})

function padNum(n: number): string {
  return String(n).padStart(2, '0')
}

function dotDate(ts: number): string {
  const d = new Date(ts)
  return `${String(d.getMonth() + 1).padStart(2, '0')}·${String(d.getDate()).padStart(2, '0')}`
}

function stampColor(id: string): string {
  return StampDesigns.find(s => s.id === id)?.color ?? '#8E8775'
}

function goToTimeline() {
  uni.switchTab({ url: '/pages/timeline/timeline' })
}

function goCreateTravel() {
  uni.navigateTo({ url: '/pages/travel/travel' })
}

function openEnvelope(card: Postcard | null) {
  if (!card || isOpeningEnvelope.value) return
  isOpeningEnvelope.value = true
  setTimeout(() => {
    isOpeningEnvelope.value = false
    uni.navigateTo({ url: `/pages/detail/detail?id=${card.id}` })
  }, 750)
}

function viewPostcard(card: Postcard) {
  uni.navigateTo({ url: `/pages/detail/detail?id=${card.id}` })
}

function toggleFavoriteWithAnim(card: Postcard) {
  stampingFavId.value = card.id
  store.toggleFavorite(card.id)
  uni.showToast({ title: '收藏已更新', icon: 'success' })
  setTimeout(() => { stampingFavId.value = null }, 500)
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

// ─── Paper editorial header ───
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
  line-height: 1.5;
}

// ─── Scroll content ───
.content {
  flex: 1;
  overflow: hidden;
}

.section-pad {
  padding: 44rpx 40rpx 0;
}

// ─── Section label ───
.section-hd {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 16rpx;
}

.section-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 8rpx;
}

.section-ttl {
  display: block;
  font-family: $font-family-serif;
  font-weight: 500;
  font-size: 38rpx;
  color: $ink-black;
  line-height: 1;
  letter-spacing: 0.4rpx;
}

.section-rule {
  height: 2rpx;
  background: $line-sepia;
  margin-bottom: 24rpx;
}

.section-right {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
}

.section-link {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
}

// ─── Envelope hero ───
.today-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20rpx;
}

.par-avion {
  border: 1rpx solid $stamp-red;
  padding: 4rpx 14rpx;
}

.par-avion-txt {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: $stamp-red;
}

.envelope-card {
  background: $card-warm;
  border: 1rpx solid $line-sepia;
  border-radius: 4rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 24rpx rgba(40, 30, 15, 0.08);
  position: relative;

  &.env-opening { animation: env-open-anim 0.75s ease-in-out forwards; }

  .env-tear-line {
    position: absolute;
    top: 50rpx;
    left: 50%;
    width: 0;
    height: 4rpx;
    background: linear-gradient(90deg, transparent, rgba(251, 248, 241, 0.9) 30%, rgba(251, 248, 241, 0.9) 70%, transparent);
    transform: translateX(-50%);
    z-index: 5;
    border-radius: 2rpx;
  }
  &.env-opening .env-tear-line { animation: tear-spread 0.45s 0.2s ease-out both; }
}

@keyframes env-open-anim {
  0%   { transform: scale(1); box-shadow: 0 8rpx 24rpx rgba(40, 30, 15, 0.08); }
  20%  { transform: scale(1.018) translateY(-8rpx); box-shadow: 0 28rpx 56rpx rgba(40, 30, 15, 0.2); }
  65%  { transform: scale(1.018) translateY(-8rpx); opacity: 1; }
  100% { transform: scale(0.96) translateY(16rpx); opacity: 0; }
}
@keyframes tear-spread {
  from { width: 0; }
  to   { width: 88%; }
}

.airmail-stripe {
  height: 12rpx;
  background: repeating-linear-gradient(
    45deg,
    $stamp-red 0,
    $stamp-red 10rpx,
    transparent 10rpx,
    transparent 20rpx,
    #1F4B66 20rpx,
    #1F4B66 30rpx,
    transparent 30rpx,
    transparent 40rpx
  );
}

.envelope-body {
  display: flex;
  min-height: 220rpx;
}

.env-photo-wrap {
  width: 220rpx;
  position: relative;
  flex-shrink: 0;
  overflow: hidden;
}

.env-photo {
  width: 100%;
  height: 100%;
}

.env-photo-grad {
  width: 100%;
  height: 100%;
  background: linear-gradient(180deg, #C9D2B6 0%, #6E8862 75%, #4F6A4E 100%);
}

.env-photo-label {
  position: absolute;
  bottom: 16rpx;
  left: 16rpx;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: rgba(244, 239, 229, 0.9);
}

.env-address {
  flex: 1;
  padding: 32rpx 24rpx;
  position: relative;
}

.addr-row {
  display: flex;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.addr-label {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 4rpx;
  color: $travel-blue;
  padding-top: 4rpx;
  flex-shrink: 0;
}

.addr-detail {
  flex: 1;
  min-width: 0;
}

.addr-main {
  display: block;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.4;
}

.addr-sub {
  display: block;
  font-family: $font-family-sans;
  font-size: 22rpx;
  color: $body-text;
  margin-top: 4rpx;
}

.postmark {
  position: absolute;
  bottom: 20rpx;
  right: 16rpx;
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  border: 2rpx solid $stamp-red;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  opacity: 0.65;
  gap: 2rpx;
}

.pm-city {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 2rpx;
  color: $stamp-red;
}

.pm-date {
  font-family: $font-family-serif;
  font-size: 22rpx;
  font-weight: 500;
  color: $stamp-red;
}

.pm-year {
  font-family: $font-family-mono;
  font-size: 12rpx;
  letter-spacing: 2rpx;
  color: $stamp-red;
}

.tap-hint {
  display: block;
  text-align: center;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 4rpx;
  color: $mute-text;
  margin-top: 16rpx;
}

// ─── Stats ───
.stats-row {
  display: flex;
  gap: 14rpx;
}

.stat-pill {
  flex: 1;
  background: $card-bg;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  padding: 24rpx 8rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
}

.stat-red .stat-n {
  color: $stamp-red;
}

.stat-n {
  font-family: $font-family-serif;
  font-size: 52rpx;
  font-weight: 400;
  color: $ink-black;
  line-height: 1;
  letter-spacing: -1rpx;
}

.stat-lbl {
  font-family: $font-family-mono;
  font-size: 16rpx;
  color: $mute-text;
  letter-spacing: 3rpx;
}

// ─── No journey prompt ───
.no-journey-card {
  background: $card-bg;
  border: 1rpx dashed $travel-blue;
  border-radius: 8rpx;
  padding: 32rpx 36rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  opacity: 0.85;
}

.no-journey-left {
  flex: 1;
}

.no-journey-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 10rpx;
}

.no-journey-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: $ink-black;
  margin-bottom: 8rpx;
}

.no-journey-sub {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.no-journey-icon {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  background: $travel-blue;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.no-journey-arrow {
  font-family: $font-family-serif;
  font-size: 40rpx;
  color: $card-bg;
  line-height: 1;
}

// ─── Current journey card ───
.journey-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 32rpx 36rpx 28rpx;
}

.journey-top {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 16rpx;
}

.pulse-wrap {
  position: relative;
  width: 14rpx;
  height: 14rpx;
  flex-shrink: 0;
}

.pulse-core {
  width: 14rpx;
  height: 14rpx;
  border-radius: 50%;
  background: $alive-green;
  position: absolute;
}

.pulse-ring {
  width: 14rpx;
  height: 14rpx;
  border-radius: 50%;
  background: $alive-green;
  position: absolute;
  opacity: 0.3;
  animation: pulse-out 1.8s ease-out infinite;
}

@keyframes pulse-out {
  0% { transform: scale(0.6); opacity: 0.45; }
  100% { transform: scale(2.4); opacity: 0; }
}

.journey-day {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: $alive-green;
  flex: 1;
}

.journey-no {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.journey-dest-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 28rpx;
}

.journey-pin {
  font-size: 26rpx;
  color: $travel-blue;
}

.journey-dest {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $body-text;
}

.progress-track {
  height: 6rpx;
  background: $line-sepia;
  border-radius: 9999rpx;
  overflow: hidden;
  margin-bottom: 16rpx;
}

.progress-fill {
  height: 100%;
  background: $travel-blue;
  border-radius: 9999rpx;
}

.journey-dates {
  display: flex;
  justify-content: space-between;
}

.journey-mono {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

// ─── Letter rows ───
.card-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

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

.row-thumb-img {
  width: 100%;
  height: 100%;
}

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
  letter-spacing: 0.4rpx;
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

.stamp-dot {
  font-size: 20rpx;
}

// ─── Empty state ───
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 80rpx 0;
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
}

.btm-gap {
  height: 120rpx;
}

// ── 收藏邮戳动画 ──
.fav-stamping { animation: fav-press 0.45s cubic-bezier(0.34, 1.56, 0.64, 1); }

@keyframes fav-press {
  0%   { transform: scale(1); }
  30%  { transform: scale(0.65); }
  65%  { transform: scale(1.32); }
  100% { transform: scale(1); }
}
</style>

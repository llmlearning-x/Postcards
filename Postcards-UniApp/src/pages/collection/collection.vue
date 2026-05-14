<template>
  <view class="page-container">
    <!-- Paper editorial header -->
    <view class="postal-header">
      <view class="header-perf"></view>
      <view class="nav-back" @click="goBack">
        <IconBack :size="18" color="#3C604D" />
      </view>
      <text class="header-kicker">COLLECTION · 收藏夹</text>
      <text class="header-title">珍藏邮票</text>
      <text class="header-subtitle">{{ favorites.length }} 枚收藏 · {{ postcards.length }} 张明信片</text>
    </view>

    <scroll-view class="content" scroll-y>

      <!-- Favorites section -->
      <view class="section-pad">
        <view class="section-hd">
          <view>
            <text class="section-kicker">LOVED · 心选</text>
            <text class="section-ttl">收藏明信片</text>
          </view>
          <text class="section-badge">{{ String(favorites.length).padStart(2, '0') }}</text>
        </view>
        <view class="section-rule"></view>

        <view v-if="favorites.length > 0" class="stamp-grid">
          <view
            v-for="card in favorites"
            :key="card.id"
            class="stamp-cell"
            @click="viewPostcard(card)"
          >
            <view class="stamp-frame">
              <view class="stamp-perf-top">
                <view v-for="i in 9" :key="i" class="perf-hole"></view>
              </view>
              <view class="stamp-img-wrap">
                <image v-if="card.photoUrl" :src="card.photoUrl" class="stamp-img" mode="aspectFill" />
                <view v-else class="stamp-img-grad"></view>
                <view class="stamp-color-band" :style="{ background: getStampColor(card.stampDesign) }"></view>
              </view>
              <view class="stamp-perf-bot">
                <view v-for="i in 9" :key="i" class="perf-hole"></view>
              </view>
            </view>
            <text class="stamp-loc">{{ card.locationName }}</text>
            <text class="stamp-city-lbl">{{ card.city }}</text>
            <view class="stamp-fav-btn" @click.stop="unfavorite(card.id)">
              <IconFavorite :size="22" color="#A43B2D" />
            </view>
          </view>
        </view>

        <view v-else class="empty-block">
          <IconFavorite :size="72" color="#B5AE9B" />
          <text class="empty-main">还没有收藏</text>
          <text class="empty-sub">点击明信片上的心形图标即可收藏</text>
        </view>
      </view>

      <!-- All postcards section -->
      <view class="section-pad">
        <view class="section-hd">
          <view>
            <text class="section-kicker">ARCHIVE · 全部明信片</text>
            <text class="section-ttl">所有记录</text>
          </view>
          <text class="section-badge">{{ String(postcards.length).padStart(2, '0') }}</text>
        </view>
        <view class="section-rule"></view>

        <view v-if="postcards.length > 0" class="card-list">
          <view
            v-for="card in postcards"
            :key="card.id"
            class="letter-row"
            @click="viewPostcard(card)"
          >
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
              <view @click.stop="toggleFav(card.id)">
                <IconFavorite :size="26" :color="card.isFavorite ? '#A43B2D' : '#B5AE9B'" />
              </view>
              <view class="stamp-badge" :style="{ 'border-color': getStampColor(card.stampDesign) }">
                <text class="stamp-dot" :style="{ color: getStampColor(card.stampDesign) }">✦</text>
              </view>
            </view>
          </view>
        </view>

        <view v-else class="empty-block">
          <IconImage :size="72" color="#B5AE9B" />
          <text class="empty-main">还没有明信片</text>
          <text class="empty-sub">去记录你的第一张旅行明信片</text>
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
import { StampDesigns } from '@/config/app'
import type { Postcard } from '@/model/Postcard'
import { IconBack, IconFavorite, IconImage } from '@/components/icons'
import { formatDotDate, getStampColor } from '@/utils/stamp'

const store = usePostcardStore()
const postcards = computed(() => store.sortedPostcards)
const favorites = computed(() => postcards.value.filter(p => p.isFavorite))

function viewPostcard(card: Postcard) {
  uni.navigateTo({ url: `/pages/detail/detail?id=${card.id}` })
}

function toggleFav(id: string) {
  store.toggleFavorite(id)
  uni.showToast({ title: '收藏已更新', icon: 'success' })
}

function unfavorite(id: string) {
  store.toggleFavorite(id)
  uni.showToast({ title: '已取消收藏', icon: 'none' })
}

function goBack() {
  uni.navigateBack({ fail: () => uni.switchTab({ url: '/pages/profile/profile' }) })
}

onMounted(() => store.initData())
onShow(() => { if (store.postcards.length === 0) store.initData() })
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
  padding: 96rpx 48rpx 40rpx;
  border-bottom: 1rpx solid $line-sepia;
  position: relative;
  flex-shrink: 0;
}

.header-perf {
  position: absolute;
  top: 88rpx;
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

.nav-back {
  position: absolute;
  top: 52rpx;
  left: 48rpx;
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
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

// ─── Scroll ───
.content {
  flex: 1;
  overflow: hidden;
}

.section-pad {
  padding: 44rpx 40rpx 0;
}

// ─── Section header ───
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
}

.section-badge {
  font-family: $font-family-serif;
  font-size: 44rpx;
  color: $line-sepia;
  line-height: 1;
  letter-spacing: -1rpx;
}

.section-rule {
  height: 2rpx;
  background: $line-sepia;
  margin-bottom: 28rpx;
}

// ─── Stamp grid ───
.stamp-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20rpx;
}

.stamp-cell {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  position: relative;
}

.stamp-frame {
  width: 100%;
  border: 1rpx solid $line-sepia;
  background: $card-bg;
  border-radius: 4rpx;
  overflow: hidden;
}

.stamp-perf-top,
.stamp-perf-bot {
  display: flex;
  justify-content: space-around;
  padding: 4rpx 8rpx;
  background: $page-background;
}

.perf-hole {
  width: 10rpx;
  height: 10rpx;
  border-radius: 50%;
  background: $page-background;
  border: 1rpx solid $line-sepia;
}

.stamp-img-wrap {
  position: relative;
  width: 100%;
  height: 160rpx;
  overflow: hidden;
}

.stamp-img {
  width: 100%;
  height: 100%;
}

.stamp-img-grad {
  width: 100%;
  height: 100%;
  background: linear-gradient(180deg, #C9D2B6 0%, #6E8862 100%);
}

.stamp-color-band {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 6rpx;
  opacity: 0.7;
}

.stamp-loc {
  font-family: $font-family-serif;
  font-size: 22rpx;
  font-weight: 500;
  color: $ink-black;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  width: 100%;
}

.stamp-city-lbl {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  text-align: center;
}

.stamp-fav-btn {
  position: absolute;
  top: 8rpx;
  right: 4rpx;
  width: 48rpx;
  height: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(251, 248, 241, 0.85);
  border-radius: 50%;
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

// ─── Empty state ───
.empty-block {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 72rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
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
  font-size: 24rpx;
  color: $mute-text;
}

.btm-gap { height: 120rpx; }
</style>

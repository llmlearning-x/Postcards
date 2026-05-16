<template>
  <view class="page-container">
    <view class="postal-header">
      <view class="header-perf"></view>
      <view class="nav-back" @click="goBack">
        <IconBack :size="18" color="rgba(255,255,255,0.9)" />
      </view>
      <view class="nav-new" @click="createTravel">
        <IconPlus :size="20" color="rgba(255,255,255,0.9)" />
      </view>
      <text class="header-kicker">TRIPS · 旅程</text>
      <text class="header-title">我的旅程</text>
      <text class="header-subtitle">共 {{ store.sortedTravels.length }} 段旅程</text>
    </view>

    <scroll-view class="content" scroll-y>
      <view v-if="store.sortedTravels.length > 0" class="list-wrap">

        <!-- ── Boarding-pass card ── -->
        <view
          v-for="travel in store.sortedTravels"
          :key="travel.id"
          class="bp-card"
          @click="editTravel(travel.id)"
        >
          <!-- Left status strip -->
          <view class="bp-strip" :class="stripClass(travel.status)"></view>

          <!-- Main ticket body -->
          <view class="bp-body">

            <!-- Header row -->
            <view class="bp-header">
              <text class="bp-kicker">BOARDING PASS · 旅程</text>
              <view class="bp-status-pill" :class="statusClass(travel.status)">
                <text class="bp-status-txt">{{ statusLabel(travel.status) }}</text>
              </view>
            </view>

            <!-- Route: FROM → TO -->
            <view class="bp-route">
              <view class="bp-from">
                <text class="bp-field-lbl">出 发</text>
                <text class="bp-city-code">HOME</text>
              </view>
              <view class="bp-route-mid">
                <view class="bp-route-line"></view>
                <text class="bp-plane">✈</text>
              </view>
              <view class="bp-to">
                <text class="bp-field-lbl">目 的 地</text>
                <text class="bp-dest-name">{{ travel.destination }}</text>
              </view>
            </view>

            <!-- Journey title -->
            <text class="bp-title">{{ travel.title }}</text>

            <!-- Tear line with notch cutouts -->
            <view class="bp-tear">
              <view class="bp-notch bp-notch-l"></view>
              <view class="bp-dashes"></view>
              <view class="bp-notch bp-notch-r"></view>
            </view>

            <!-- Stub: date · status · postcard count -->
            <view class="bp-stub">
              <view class="bp-stub-col">
                <text class="bp-stub-lbl">DATE</text>
                <text class="bp-stub-val">{{ formatShortDate(travel.startDate) }}</text>
              </view>
              <view class="bp-stub-div"></view>
              <view class="bp-stub-col">
                <text class="bp-stub-lbl">STATUS</text>
                <text class="bp-stub-val">{{ statusLabel(travel.status) }}</text>
              </view>
              <view class="bp-stub-div"></view>
              <view class="bp-stub-col">
                <text class="bp-stub-lbl">CARDS</text>
                <text class="bp-stub-val">{{ String(postcardsFor(travel.id)).padStart(2, '0') }}</text>
              </view>
              <view v-if="travel.isCurrent" class="bp-current">
                <text class="bp-current-dot">●</text>
                <text class="bp-current-lbl">当前</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <view v-else class="empty-state">
        <IconMap :size="80" color="#B5AE9B" />
        <text class="empty-main">还没有旅程</text>
        <text class="empty-sub">先创建一段旅程，再记录沿途明信片</text>
        <view class="empty-btn" @click="createTravel">
          <text class="empty-btn-txt">创建第一段旅程</text>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { TravelStatus } from '@/model/Travel'
import { IconBack, IconPlus, IconMap } from '@/components/icons'

const store = usePostcardStore()

function postcardsFor(travelId: string): number {
  return store.getPostcardsByTravel(travelId).length
}

const MONTHS = ['01','02','03','04','05','06','07','08','09','10','11','12']

function formatShortDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getFullYear()}.${MONTHS[d.getMonth()]}.${String(d.getDate()).padStart(2,'0')}`
}

function statusLabel(status: TravelStatus): string {
  const map: Record<TravelStatus, string> = {
    [TravelStatus.PLANNED]:   '计划中',
    [TravelStatus.ONGOING]:   '进行中',
    [TravelStatus.COMPLETED]: '已完成',
    [TravelStatus.CANCELLED]: '已取消',
  }
  return map[status] ?? status
}

function statusClass(status: TravelStatus): string {
  const map: Record<TravelStatus, string> = {
    [TravelStatus.PLANNED]:   'status-planned',
    [TravelStatus.ONGOING]:   'status-ongoing',
    [TravelStatus.COMPLETED]: 'status-completed',
    [TravelStatus.CANCELLED]: 'status-cancelled',
  }
  return map[status] ?? ''
}

function stripClass(status: TravelStatus): string {
  const map: Record<TravelStatus, string> = {
    [TravelStatus.PLANNED]:   'strip-planned',
    [TravelStatus.ONGOING]:   'strip-ongoing',
    [TravelStatus.COMPLETED]: 'strip-completed',
    [TravelStatus.CANCELLED]: 'strip-cancelled',
  }
  return map[status] ?? ''
}

function editTravel(id: string) {
  uni.navigateTo({ url: `/pages/travel/travel?id=${id}` })
}

function createTravel() {
  uni.navigateTo({ url: '/pages/travel/travel' })
}

function goBack() {
  uni.navigateBack({ fail: () => uni.switchTab({ url: '/pages/home/home' }) })
}

onMounted(() => store.initData())
onShow(() => { if (store.travels.length === 0) store.initData() })
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
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 100rpx 48rpx 20rpx;
  position: relative;
  flex-shrink: 0;
}

.header-perf {
  position: absolute; bottom: 0; left: 0; right: 0; height: 6rpx;
  background: repeating-linear-gradient(-45deg, #B8312A 0, #B8312A 5rpx, #ffffff 5rpx, #ffffff 10rpx, #1C3A72 10rpx, #1C3A72 15rpx, #ffffff 15rpx, #ffffff 20rpx);
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

.nav-new {
  position: absolute;
  top: 52rpx;
  right: 48rpx;
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.header-kicker {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(255,255,255,0.65);
  margin-bottom: 12rpx;
}

.header-title {
  display: block;
  font-family: $font-family-body;
  font-size: 46rpx;
  font-weight: 700;
  color: rgba(255,255,255,0.95);
  line-height: 1.15;
  letter-spacing: 0;
}

.header-subtitle {
  display: block;
  font-family: $font-family-body;
  font-size: 26rpx;
  color: rgba(255,255,255,0.7);
  margin-top: 10rpx;
}

.content {
  flex: 1;
  overflow: hidden;
}

.list-wrap {
  padding: 32rpx 40rpx 0;
  display: flex;
  flex-direction: column;
  gap: 28rpx;
}

// ═══════════════════════════════
//  Boarding Pass Card
// ═══════════════════════════════
.bp-card {
  display: flex;
  background: $card-bg;
  border-radius: 12rpx;
  overflow: hidden;
  // ticket drop shadow
  box-shadow: 0 4rpx 24rpx rgba(60, 40, 20, 0.10), 0 1rpx 4rpx rgba(60, 40, 20, 0.06);
}

// ── Left status strip ──
.bp-strip {
  width: 16rpx;
  flex-shrink: 0;
}
.strip-ongoing   { background: $travel-blue; }
.strip-planned   { background: #7A8F7D; }
.strip-completed { background: $line-sepia; }
.strip-cancelled { background: $whisper; }

// ── Body ──
.bp-body {
  flex: 1;
  min-width: 0;
  padding: 28rpx 32rpx 0;
}

// ── Header row ──
.bp-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.bp-kicker {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.bp-status-pill {
  padding: 6rpx 16rpx;
  border-radius: 100rpx;
  border: 1rpx solid currentColor;
}

.bp-status-txt {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
}

.status-ongoing   { color: $travel-blue; background: rgba(46,125,88,0.08); }
.status-planned   { color: #7A8F7D; }
.status-completed { color: $body-text; border-color: $line-sepia; }
.status-cancelled { color: $whisper; border-color: $whisper; }

// ── Route: FROM → TO ──
.bp-route {
  display: flex;
  align-items: flex-end;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.bp-from {
  flex-shrink: 0;
}

.bp-field-lbl {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  margin-bottom: 6rpx;
}

.bp-city-code {
  font-family: $font-family-body;
  font-size: 44rpx;
  font-weight: 400;
  color: $ink-black;
  letter-spacing: -1rpx;
  line-height: 1;
}

.bp-route-mid {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 0;
  padding-bottom: 6rpx;
}

.bp-route-line {
  flex: 1;
  height: 1rpx;
  background: $line-sepia;
}

.bp-plane {
  font-size: 30rpx;
  color: $travel-blue;
  padding: 0 8rpx;
  flex-shrink: 0;
}

.bp-to {
  flex-shrink: 0;
  text-align: right;
}

.bp-dest-name {
  display: block;
  font-family: $font-family-body;
  font-size: 44rpx;
  font-weight: 400;
  color: $ink-black;
  letter-spacing: -1rpx;
  line-height: 1;
}

// ── Journey title ──
.bp-title {
  display: block;
  font-family: $font-family-body;
  font-style: italic;
  font-size: 28rpx;
  color: $body-text;
  margin-bottom: 28rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

// ── Tear line ──
.bp-tear {
  position: relative;
  height: 32rpx;
  display: flex;
  align-items: center;
  margin: 0 -32rpx;  // bleed to card edges
}

.bp-dashes {
  flex: 1;
  height: 0;
  border-top: 2rpx dashed $line-sepia;
  margin: 0 16rpx;
}

// semicircle notches punched out of the card edges
.bp-notch {
  width: 32rpx;
  height: 32rpx;
  background: $page-background;
  border-radius: 50%;
  flex-shrink: 0;
  border: 1rpx solid $line-sepia;
}

.bp-notch-l {
  margin-left: -16rpx;
  // clip right half so it looks like a notch cut into the card
  clip-path: inset(0 0 0 50%);
}

.bp-notch-r {
  margin-right: -16rpx;
  clip-path: inset(0 50% 0 0);
}

// ── Stub ──
.bp-stub {
  display: flex;
  align-items: center;
  padding: 20rpx 0 24rpx;
  gap: 0;
}

.bp-stub-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6rpx;
}

.bp-stub-lbl {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.bp-stub-val {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $ink-black;
  font-weight: 500;
  letter-spacing: 0.5rpx;
}

.bp-stub-div {
  width: 1rpx;
  height: 40rpx;
  background: $line-sepia;
  flex-shrink: 0;
}

.bp-current {
  display: flex;
  align-items: center;
  gap: 6rpx;
  margin-left: 16rpx;
  flex-shrink: 0;
  background: rgba(46,125,88,0.08);
  padding: 8rpx 16rpx;
  border-radius: 100rpx;
}

.bp-current-dot {
  font-size: 22rpx;
  color: $travel-blue;
}

.bp-current-lbl {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

// ─── Empty state ───
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 100rpx 40rpx;
}

.empty-main {
  font-family: $font-family-body;
  font-size: 32rpx;
  color: $body-text;
  margin-top: 28rpx;
  margin-bottom: 8rpx;
}

.empty-sub {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
  margin-bottom: 40rpx;
  text-align: center;
}

.empty-btn {
  background: $travel-blue;
  padding: 20rpx 60rpx;
  border-radius: 6rpx;
}

.empty-btn-txt {
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $card-bg;
  letter-spacing: 2rpx;
}

.btm-gap { height: 120rpx; }
</style>

<template>
  <view class="page-container">
    <!-- Header -->
    <view class="page-header">
      <view class="nav-back" @click="goBack">
        <IconBack :size="20" color="#F4EFE5" />
      </view>
      <view class="header-center">
        <text class="header-kicker">STAMP SHOP · 集邮</text>
        <text class="header-title">邮票商店</text>
      </view>
      <view style="width: 64rpx;"></view>
    </view>

    <scroll-view class="content" scroll-y>

      <!-- Points balance ticket (perforated design) -->
      <view class="balance-ticket">
        <view class="ticket-perf"></view>
        <view class="ticket-body">
          <view class="ticket-left">
            <text class="ticket-lbl">POINTS · 我的积分</text>
            <text class="ticket-amt">{{ points }}</text>
            <text class="ticket-mailbox">{{ authStore.user?.mailboxNo }}</text>
          </view>
          <view class="ticket-sep"></view>
          <view class="ticket-right">
            <view class="daily-btn" :class="{ 'daily-done': dailyClaimed }" @click="claimDaily">
              <text class="daily-sun">☀</text>
              <text class="daily-txt">{{ dailyClaimed ? '已签到' : '每日签到' }}</text>
              <text v-if="!dailyClaimed" class="daily-reward">+5 PT</text>
            </view>
          </view>
        </view>
        <view class="ticket-perf"></view>
      </view>

      <!-- How to earn points (collapsible) -->
      <view class="earn-card">
        <view class="earn-hd" @click="guideOpen = !guideOpen">
          <text class="earn-hd-txt">HOW TO EARN · 获得积分</text>
          <text class="earn-toggle">{{ guideOpen ? '▲' : '▼' }}</text>
        </view>
        <view v-if="guideOpen" class="earn-body">
          <view v-for="item in earnItems" :key="item.key" class="earn-row">
            <view class="earn-dot" :style="{ background: item.color }"></view>
            <text class="earn-label">{{ item.label }}</text>
            <text class="earn-pts">+{{ item.pts }} PT</text>
          </view>
        </view>
      </view>

      <!-- Stamp series sections -->
      <view v-for="group in stampGroups" :key="group.series" class="series-section">
        <view class="series-hd">
          <text class="series-roman">SÉRIE {{ group.series }}</text>
          <text class="series-name-txt">{{ group.seriesName }}</text>
          <view class="series-rule"></view>
          <view class="series-tag" :class="group.isFree ? 'tag-free' : 'tag-paid'">
            <text class="series-tag-txt">{{ group.isFree ? 'FREE' : group.price + ' PT' }}</text>
          </view>
        </view>

        <scroll-view class="stamps-scroll" scroll-x>
          <view class="stamps-row">
            <view
              v-for="stamp in group.items"
              :key="stamp.id"
              class="stamp-card"
              @click="onStampTap(stamp)"
            >
              <!-- Stamp body (perforated frame effect) -->
              <view
                class="stamp-body"
                :style="{
                  borderColor: stamp.isOwned ? stamp.color : '#C8BAA0',
                  opacity: stamp.isOwned || stamp.isFree ? 1 : 0.72,
                }"
              >
                <!-- Ownership badge -->
                <view v-if="stamp.isOwned" class="stamp-badge badge-owned" :style="{ background: stamp.color }">
                  <text class="badge-check">✓</text>
                </view>

                <!-- Artwork area -->
                <view class="stamp-art" :style="{ background: stamp.isOwned ? stamp.color + '14' : '#F0EDE8' }">
                  <image v-if="stamp.imageUrl" :src="stamp.imageUrl" class="stamp-img" mode="aspectFill" />
                  <text v-else class="stamp-glyph" :style="{ color: stamp.isOwned ? stamp.color : '#C8BAA0' }">✦</text>
                </view>

                <!-- Name bar -->
                <view class="stamp-bar" :style="{ background: stamp.isOwned ? stamp.color : '#C8BAA0' }">
                  <text class="stamp-bar-name">{{ stamp.name }}</text>
                </view>
              </view>

              <!-- Price / status label below card -->
              <text v-if="stamp.isOwned" class="stamp-status stamp-status-owned">已拥有</text>
              <text v-else-if="stamp.isFree" class="stamp-status stamp-status-free">FREE</text>
              <text v-else class="stamp-status stamp-status-price">{{ stamp.price }} PT</text>
            </view>
          </view>
        </scroll-view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>

    <!-- Purchase bottom sheet -->
    <view v-if="buying" class="sheet-mask" @click.self="buying = null">
      <view class="sheet-box">
        <!-- Stamp preview -->
        <view class="sheet-preview">
          <view class="sheet-stamp-frame" :style="{ borderColor: buying.color }">
            <view class="sheet-stamp-art" :style="{ background: buying.color + '18' }">
              <image v-if="buying.imageUrl" :src="buying.imageUrl" class="stamp-img" mode="aspectFill" />
              <text v-else class="sheet-glyph" :style="{ color: buying.color }">✦</text>
            </view>
            <view class="sheet-stamp-bar" :style="{ background: buying.color }">
              <text class="sheet-bar-name">{{ buying.name }}</text>
            </view>
          </view>
        </view>

        <text class="sheet-title">解锁邮票</text>
        <text class="sheet-sub">SÉRIE {{ buying.series }} · {{ buying.seriesName }}</text>

        <view class="sheet-table">
          <view class="sheet-row">
            <text class="sheet-row-lbl">邮票价格</text>
            <text class="sheet-row-val">{{ buying.price }} PT</text>
          </view>
          <view class="sheet-sep"></view>
          <view class="sheet-row">
            <text class="sheet-row-lbl">当前积分</text>
            <text class="sheet-row-val">{{ points }} PT</text>
          </view>
          <view class="sheet-sep"></view>
          <view class="sheet-row">
            <text class="sheet-row-lbl">购买后剩余</text>
            <text class="sheet-row-val" :class="{ 'val-warn': points < buying.price }">
              {{ points - buying.price }} PT
            </text>
          </view>
        </view>

        <view v-if="points < buying.price" class="sheet-warn">
          <text class="sheet-warn-txt">积分不足，继续记录和寄出明信片可获得更多积分</text>
        </view>

        <view class="sheet-actions">
          <view class="sheet-cancel" @click="buying = null">
            <text class="sheet-cancel-txt">取消</text>
          </view>
          <view
            class="sheet-confirm"
            :class="{ 'sheet-confirm-dis': points < buying.price || confirming }"
            @click="confirmPurchase"
          >
            <text class="sheet-confirm-txt">{{ confirming ? '购买中…' : '确认兑换' }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useAuthStore } from '@/stores/auth'
import { StampApi, PointsApi, type StampItem } from '@/services/api'
import { IconBack } from '@/components/icons'

const authStore = useAuthStore()

const stamps      = ref<StampItem[]>([])
const points      = ref(authStore.user?.points ?? 0)
const guideOpen   = ref(false)
const dailyClaimed = ref(false)
const buying      = ref<StampItem | null>(null)
const confirming  = ref(false)

const stampGroups = computed(() => {
  const map: Record<string, {
    series: string; seriesName: string; price: number; isFree: boolean; items: StampItem[]
  }> = {}
  stamps.value.forEach(s => {
    if (!map[s.series]) {
      map[s.series] = { series: s.series, seriesName: s.seriesName, price: s.price, isFree: s.isFree, items: [] }
    }
    map[s.series].items.push(s)
  })
  return Object.values(map)
})

const earnItems = [
  { key: 'register', label: '注册账号',   pts: 50, color: '#A43B2D' },
  { key: 'record',   label: '记录明信片', pts: 10, color: '#3C604D' },
  { key: 'send',     label: '寄出明信片', pts: 15, color: '#1F4B66' },
  { key: 'receive',  label: '收到明信片', pts: 5,  color: '#5B4F76' },
  { key: 'daily',    label: '每日签到',   pts: 5,  color: '#C4753A' },
]

async function loadData() {
  try {
    stamps.value = await StampApi.all()
  } catch {}
  try {
    const res = await PointsApi.me()
    points.value = res.points
    authStore.updatePoints(res.points)
  } catch {}
}

async function claimDaily() {
  if (dailyClaimed.value) return
  try {
    const res = await PointsApi.daily()
    points.value = res.points
    authStore.updatePoints(res.points)
    dailyClaimed.value = true
    uni.showToast({ title: `签到成功 +${res.delta} PT`, icon: 'success' })
  } catch (e: any) {
    if (e.message?.includes('今日')) {
      dailyClaimed.value = true
      uni.showToast({ title: '今日已签到', icon: 'none' })
    } else {
      uni.showToast({ title: e.message || '签到失败', icon: 'none' })
    }
  }
}

function onStampTap(stamp: StampItem) {
  if (stamp.isOwned) {
    uni.showToast({ title: '已拥有此邮票', icon: 'none' })
    return
  }
  if (stamp.isFree) {
    uni.showToast({ title: '免费邮票自动解锁', icon: 'none' })
    return
  }
  buying.value = stamp
}

async function confirmPurchase() {
  if (!buying.value || confirming.value || points.value < buying.value.price) return
  confirming.value = true
  try {
    const res = await StampApi.unlock(buying.value.id)
    points.value = res.points
    authStore.updatePoints(res.points)
    authStore.addOwnedStamp(res.stampId)
    // Update local stamp list optimistically
    const idx = stamps.value.findIndex(s => s.id === res.stampId)
    if (idx >= 0) stamps.value[idx] = { ...stamps.value[idx], isOwned: true }
    buying.value = null
    uni.showToast({ title: '解锁成功！', icon: 'success' })
  } catch (e: any) {
    uni.showToast({ title: e.message || '兑换失败', icon: 'none' })
  } finally {
    confirming.value = false
  }
}

function goBack() { uni.navigateBack() }

onShow(() => { loadData() })
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
}

// ── Header ──
.page-header {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 56rpx 40rpx 36rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
}
.nav-back {
  width: 64rpx; height: 64rpx;
  border-radius: 50%;
  background: rgba(244,239,229,0.12);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.header-center { flex: 1; }
.header-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx; letter-spacing: 4rpx;
  color: rgba(244,239,229,0.65);
  margin-bottom: 6rpx;
}
.header-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 40rpx;
  color: #F4EFE5;
}

.content { height: calc(100vh - 200rpx); }

// ── Balance Ticket ──
.balance-ticket {
  margin: 32rpx 40rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 12rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 32rpx rgba(40,30,15,0.07);
}
.ticket-perf {
  height: 20rpx;
  background: repeating-linear-gradient(
    90deg,
    $page-background 0, $page-background 16rpx,
    transparent 16rpx, transparent 32rpx
  );
}
.ticket-body {
  display: flex;
  align-items: stretch;
  padding: 24rpx 32rpx;
  gap: 28rpx;
}
.ticket-left { flex: 1; }
.ticket-lbl {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx; letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 10rpx;
}
.ticket-amt {
  display: block;
  font-family: $font-family-serif;
  font-size: 80rpx;
  color: $ink-black;
  line-height: 1;
  margin-bottom: 8rpx;
}
.ticket-mailbox {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx; letter-spacing: 3rpx;
  color: $mute-text;
}
.ticket-sep {
  width: 1rpx;
  background: repeating-linear-gradient(
    180deg,
    $line-sepia 0, $line-sepia 8rpx,
    transparent 8rpx, transparent 16rpx
  );
}
.ticket-right {
  width: 180rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}
.daily-btn {
  background: $travel-blue;
  border-radius: 10rpx;
  padding: 20rpx 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  width: 100%;
  &.daily-done { background: $line-sepia; }
  &:active:not(.daily-done) { opacity: 0.85; }
}
.daily-sun { font-size: 40rpx; color: #F4EFE5; }
.daily-txt {
  font-family: $font-family-mono;
  font-size: 18rpx; letter-spacing: 1rpx;
  color: rgba(244,239,229,0.9);
}
.daily-reward {
  font-family: $font-family-mono;
  font-size: 22rpx;
  color: #F4EFE5;
  font-weight: bold;
}

// ── Earn Guide ──
.earn-card {
  margin: 24rpx 40rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
}
.earn-hd {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20rpx 28rpx;
}
.earn-hd-txt {
  font-family: $font-family-mono;
  font-size: 18rpx; letter-spacing: 3rpx;
  color: $travel-blue;
}
.earn-toggle {
  font-family: $font-family-mono;
  font-size: 18rpx;
  color: $mute-text;
}
.earn-body {
  border-top: 1rpx solid $line-sepia;
  padding: 16rpx 28rpx 20rpx;
  display: flex;
  flex-direction: column;
  gap: 18rpx;
}
.earn-row { display: flex; align-items: center; gap: 16rpx; }
.earn-dot { width: 10rpx; height: 10rpx; border-radius: 50%; flex-shrink: 0; }
.earn-label { flex: 1; font-family: $font-family-serif; font-size: 26rpx; color: $body-text; }
.earn-pts {
  font-family: $font-family-mono;
  font-size: 22rpx; letter-spacing: 1rpx;
  color: $travel-blue;
}

// ── Series Section ──
.series-section { margin-top: 40rpx; }
.series-hd {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 0 40rpx;
  margin-bottom: 24rpx;
}
.series-roman {
  font-family: $font-family-mono;
  font-size: 16rpx; letter-spacing: 3rpx;
  color: $mute-text;
  white-space: nowrap;
}
.series-name-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  white-space: nowrap;
}
.series-rule { flex: 1; height: 1rpx; background: $line-sepia; }
.series-tag {
  padding: 6rpx 16rpx;
  border-radius: 4rpx;
  flex-shrink: 0;
  &.tag-free {
    background: rgba($travel-blue, 0.1);
    border: 1rpx solid rgba($travel-blue, 0.25);
  }
  &.tag-paid {
    background: rgba(40,30,15,0.05);
    border: 1rpx solid $line-sepia;
  }
}
.series-tag-txt {
  font-family: $font-family-mono;
  font-size: 18rpx; letter-spacing: 2rpx;
  color: $travel-blue;
  .tag-paid & { color: $mute-text; }
}

// ── Stamp Cards ──
.stamps-scroll { width: 100%; }
.stamps-row {
  display: flex;
  gap: 24rpx;
  padding: 0 40rpx 8rpx;
  width: max-content;
}
.stamp-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
}
.stamp-body {
  width: 156rpx;
  border: 2rpx dashed #C8BAA0;
  border-radius: 4rpx;
  position: relative;
  overflow: hidden;
  background: $card-bg;
}
.stamp-badge {
  position: absolute;
  top: -14rpx;
  right: -14rpx;
  width: 44rpx;
  height: 44rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1;
  box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.2);
}
.badge-check {
  font-family: $font-family-mono;
  font-size: 18rpx;
  color: #F4EFE5;
  font-weight: bold;
}
.stamp-art {
  height: 156rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}
.stamp-img { width: 100%; height: 100%; }
.stamp-glyph { font-size: 60rpx; }
.stamp-bar {
  padding: 10rpx 0;
  text-align: center;
}
.stamp-bar-name {
  font-family: $font-family-mono;
  font-size: 18rpx; letter-spacing: 2rpx;
  color: #F4EFE5;
}
.stamp-status {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
}
.stamp-status-owned { color: $travel-blue; }
.stamp-status-free  { color: #A43B2D; }
.stamp-status-price { color: $mute-text; }

.btm-gap { height: 120rpx; }

// ── Purchase Sheet ──
.sheet-mask {
  position: fixed;
  inset: 0;
  background: rgba(16,12,8,0.55);
  z-index: 200;
  display: flex;
  align-items: flex-end;
}
.sheet-box {
  width: 100%;
  background: $page-background;
  border-radius: 32rpx 32rpx 0 0;
  padding: 48rpx 48rpx 88rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.sheet-preview { margin-bottom: 28rpx; }
.sheet-stamp-frame {
  width: 112rpx;
  border: 2rpx dashed currentColor;
  border-radius: 4rpx;
  overflow: hidden;
}
.sheet-stamp-art {
  height: 112rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}
.sheet-glyph { font-size: 44rpx; }
.sheet-stamp-bar { padding: 8rpx 0; text-align: center; }
.sheet-bar-name {
  font-family: $font-family-mono;
  font-size: 16rpx; letter-spacing: 2rpx;
  color: #F4EFE5;
}
.sheet-title {
  font-family: $font-family-serif;
  font-size: 40rpx;
  color: $ink-black;
  margin-bottom: 6rpx;
}
.sheet-sub {
  font-family: $font-family-mono;
  font-size: 18rpx; letter-spacing: 3rpx;
  color: $mute-text;
  margin-bottom: 36rpx;
}
.sheet-table {
  width: 100%;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 0 24rpx;
  margin-bottom: 20rpx;
}
.sheet-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0;
}
.sheet-row-lbl {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $body-text;
}
.sheet-row-val {
  font-family: $font-family-mono;
  font-size: 26rpx;
  color: $ink-black;
  &.val-warn { color: #A43B2D; }
}
.sheet-sep { height: 1rpx; background: $line-sepia; }
.sheet-warn {
  width: 100%;
  background: #FDF0ED;
  border: 1rpx solid rgba(164,59,45,0.2);
  border-radius: 8rpx;
  padding: 18rpx 20rpx;
  margin-bottom: 20rpx;
  box-sizing: border-box;
}
.sheet-warn-txt {
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: #A43B2D;
  line-height: 1.65;
}
.sheet-actions {
  width: 100%;
  display: flex;
  gap: 20rpx;
  margin-top: 8rpx;
}
.sheet-cancel {
  flex: 1;
  height: 88rpx;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  display: flex; align-items: center; justify-content: center;
}
.sheet-cancel-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $mute-text;
}
.sheet-confirm {
  flex: 2;
  height: 88rpx;
  border-radius: 8rpx;
  background: $travel-blue;
  display: flex; align-items: center; justify-content: center;
  &.sheet-confirm-dis { opacity: 0.4; }
  &:active:not(.sheet-confirm-dis) { background: $forest-green; }
}
.sheet-confirm-txt {
  font-family: $font-family-serif;
  font-size: 28rpx; letter-spacing: 4rpx;
  color: #F4EFE5;
}
</style>

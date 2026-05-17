<template>
  <view class="page-container">
    <PostalHeader
      kicker="POINTS · 积分"
      title="积分明细"
      subtitle="记录明信片、每日签到、寄出明信片都能获得积分"
      fallback-url="/pages/profile/profile"
      @back="goBack"
    />

    <!-- 积分余额卡片 -->
    <view class="points-card">
      <view class="points-card-row">
        <view class="points-balance">
          <text class="points-num">{{ points }}</text>
          <text class="points-lbl">PT</text>
        </view>
        <view class="points-progress">
          <view class="progress-bar">
            <view class="progress-fill" :style="{ width: capPct + '%' }"></view>
          </view>
          <text class="progress-txt">今日已赚 {{ todayEarned }} / {{ dailyCap }} PT{{ capReached ? ' · 已达上限' : '' }}</text>
        </view>
      </view>
    </view>

    <!-- 签到 & 去商店 两个操作 -->
    <view class="action-bar">
      <view
        class="action-btn action-checkin"
        :class="{ 'action-done': checkedInToday }"
        @click="doCheckin"
      >
        <view v-if="checking" class="btn-spinner"></view>
        <template v-else>
          <text class="action-icon">{{ checkedInToday ? '✓' : '☀' }}</text>
          <text class="action-txt">{{ checkedInToday ? '今日已签到' : '每日签到 +5' }}</text>
        </template>
      </view>
      <view class="action-btn action-shop" @click="goShop">
        <text class="action-icon">✦</text>
        <text class="action-txt">邮票商店</text>
      </view>
    </view>

    <!-- 积分获取说明 -->
    <view class="earn-strip">
      <view class="earn-rule" v-for="r in earnRules" :key="r.label">
        <text class="earn-label">{{ r.label }}</text>
        <text class="earn-pt">+{{ r.pt }} PT</text>
      </view>
    </view>

    <!-- 明细列表 -->
    <scroll-view class="content" scroll-y>
      <view v-if="loading" class="loading-wrap">
        <view v-for="i in 6" :key="i" class="skeleton-row shimmer"></view>
      </view>

      <view v-else-if="log.length > 0" class="log-wrap">
        <view class="section-hd">
          <text class="section-kicker">HISTORY · 记录</text>
          <text class="section-ttl">收支明细</text>
        </view>
        <view class="section-rule"></view>

        <view v-for="(item, idx) in log" :key="idx" class="log-row">
          <view class="log-icon-wrap" :class="item.delta > 0 ? 'icon-earn' : 'icon-spend'">
            <text class="log-icon">{{ item.delta > 0 ? '+' : '−' }}</text>
          </view>
          <view class="log-body">
            <text class="log-reason">{{ item.reason }}</text>
            <text class="log-date">{{ formatDate(item.createdAt) }}</text>
          </view>
          <text class="log-delta" :class="item.delta > 0 ? 'delta-earn' : 'delta-spend'">
            {{ item.delta > 0 ? '+' : '' }}{{ item.delta }} PT
          </text>
        </view>
      </view>

      <view v-else class="empty-state">
        <text class="empty-main">暂无积分记录</text>
        <text class="empty-sub">记录明信片、每日签到都能获得积分</text>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { PointsApi } from '@/services/api'
import PostalHeader from '@/components/PostalHeader.vue'


const authStore = useAuthStore()

const points         = ref(authStore.user?.points ?? 0)
const log            = ref<Array<{ delta: number; reason: string; createdAt: number }>>([])
const loading        = ref(true)
const checking       = ref(false)
const checkedInToday = ref(false)
const todayEarned    = ref(0)
const dailyCap       = ref(50)

const capPct     = computed(() => Math.min(100, Math.round((todayEarned.value / dailyCap.value) * 100)))
const capReached = computed(() => todayEarned.value >= dailyCap.value)

const earnRules = [
  { label: '注册', pt: 50 },
  { label: '记录明信片', pt: 10 },
  { label: '寄出明信片', pt: 15 },
  { label: '收到明信片', pt: 5 },
  { label: '每日签到', pt: 5 },
]

const MONTHS = ['1','2','3','4','5','6','7','8','9','10','11','12']

function formatDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getFullYear()}年${MONTHS[d.getMonth()]}月${d.getDate()}日`
}

async function loadData() {
  loading.value = true
  try {
    const data = await PointsApi.me()
    points.value      = data.points
    log.value         = data.log
    todayEarned.value = data.todayEarned ?? 0
    dailyCap.value    = data.dailyCap    ?? 50
    authStore.updateUser({ points: data.points })

    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const todayTs = today.getTime()
    checkedInToday.value = data.log.some(
      r => r.reason === '每日签到' && r.createdAt >= todayTs
    )
  } catch {
    // keep showing cached points
  } finally {
    loading.value = false
  }
}

async function doCheckin() {
  if (checkedInToday.value || checking.value) return
  checking.value = true
  try {
    const res = await PointsApi.daily()
    points.value = res.points
    authStore.updateUser({ points: res.points })
    checkedInToday.value = true
    uni.showToast({ title: `签到成功 +${res.delta} PT`, icon: 'success' })
    await loadData()
  } catch (e: any) {
    const msg = e?.data?.error ?? '签到失败，请稍后再试'
    uni.showToast({ title: msg, icon: 'none' })
  } finally {
    checking.value = false
  }
}

function goShop() {
  uni.navigateTo({ url: '/pages/shop/shop' })
}

function goBack() {
  uni.navigateBack({ fail: () => uni.switchTab({ url: '/pages/home/home' }) })
}

onMounted(loadData)
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $page-background;
}

// ─── Points card ───
.points-card {
  margin: 24rpx 32rpx 0;
  background: linear-gradient(180deg, #FFFDF7 0%, #F7F0E3 100%);
  border: 3rpx solid $rule-color;
  border-radius: 28rpx;
  padding: 32rpx 36rpx;
  box-shadow: $shadow-lg;
}

.points-card-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24rpx;
}

.points-balance {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
  flex-shrink: 0;
}

.points-num {
  font-family: $font-family-mono;
  font-size: 52rpx;
  color: $ink-black;
  line-height: 1;
  letter-spacing: -2rpx;
}

.points-lbl {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.points-progress {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  min-width: 0;
}

.progress-bar {
  height: 6rpx;
  background: rgba($line-sepia, 0.5);
  border-radius: 3rpx;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: $travel-blue;
  border-radius: 3rpx;
  transition: width 0.4s ease;
}

.progress-txt {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

// ─── Action bar ───
.action-bar {
  display: flex;
  gap: 16rpx;
  padding: 24rpx 40rpx;
  border-bottom: 1rpx solid $line-sepia;
  flex-shrink: 0;
}

.action-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  padding: 22rpx 0;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  background: $card-bg;
}

.action-checkin {
  border-color: $travel-blue;
  background: rgba(46, 125, 88, 0.06);
}

.action-done {
  border-color: $line-sepia;
  background: $card-bg;
  opacity: 0.6;
}

.action-shop {
  border-color: $line-sepia;
}

.action-icon {
  font-size: 28rpx;
  color: $travel-blue;
}

.action-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $ink-black;
  letter-spacing: 1rpx;
}

.action-done .action-icon,
.action-done .action-txt {
  color: $mute-text;
}

.btn-spinner {
  width: 36rpx;
  height: 36rpx;
  border: 3rpx solid $line-sepia;
  border-top-color: $travel-blue;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

// ─── Earn rules strip ───
.earn-strip {
  display: flex;
  padding: 0 40rpx;
  border-bottom: 1rpx solid $line-sepia;
  flex-shrink: 0;
  overflow-x: auto;
}

.earn-rule {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16rpx 20rpx;
  gap: 4rpx;
  border-right: 1rpx solid $line-sepia;
}

.earn-rule:last-child { border-right: none; }

.earn-label {
  font-family: $font-family-code;
  font-size: 22rpx;
  color: $mute-text;
  white-space: nowrap;
}

.earn-pt {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $travel-blue;
  font-weight: 500;
}

// ─── Content ───
.content {
  flex: 1;
  overflow: hidden;
}

.log-wrap {
  padding: 36rpx 40rpx 0;
}

.section-hd {
  margin-bottom: 16rpx;
}

.section-kicker {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  margin-bottom: 8rpx;
}

.section-ttl {
  display: block;
  font-family: $font-family-body;
  font-size: 38rpx;
  font-weight: 500;
  color: $ink-black;
  line-height: 1;
}

.section-rule {
  height: 2rpx;
  background: $line-sepia;
  margin-bottom: 8rpx;
}

// ─── Log row ───
.log-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx 0;
  border-bottom: 1rpx solid $line-sepia;
}

.log-icon-wrap {
  width: 56rpx;
  height: 56rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.icon-earn  { background: rgba(46, 125, 88, 0.1); }
.icon-spend { background: rgba(164, 59, 45, 0.1); }

.log-icon {
  font-size: 26rpx;
  font-weight: 500;
  color: $travel-blue;
}

.icon-spend .log-icon { color: #A43B2D; }

.log-body {
  flex: 1;
  min-width: 0;
}

.log-reason {
  display: block;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.3;
}

.log-date {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  margin-top: 4rpx;
}

.log-delta {
  font-family: $font-family-body;
  font-size: 30rpx;
  font-weight: 500;
  flex-shrink: 0;
}

.delta-earn  { color: $travel-blue; }
.delta-spend { color: #A43B2D; }

// ─── Skeleton ───
.loading-wrap {
  padding: 36rpx 40rpx 0;
  display: flex;
  flex-direction: column;
  gap: 2rpx;
}

.skeleton-row {
  height: 100rpx;
  border-radius: 4rpx;
  background: $line-sepia;
  opacity: 0.4;
  margin-bottom: 2rpx;
}

.shimmer {
  background: linear-gradient(90deg, $line-sepia 25%, #E8E0D0 50%, $line-sepia 75%);
  background-size: 200% 100%;
  animation: shimmer 1.4s infinite;
}

@keyframes shimmer {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

// ─── Empty ───
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 80rpx 40rpx;
}

.empty-main {
  font-family: $font-family-body;
  font-size: 32rpx;
  color: $body-text;
  margin-bottom: 12rpx;
}

.empty-sub {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  text-align: center;
}

.btm-gap { height: 120rpx; }
</style>

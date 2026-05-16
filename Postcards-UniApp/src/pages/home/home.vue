<template>
  <view class="page-container">
    <!-- Hero header -->
    <view class="hero">
      <view class="hero-inner">
        <view class="hero-left">
          <text class="hero-greeting">{{ greeting }}</text>
          <text class="hero-name">{{ user?.nickname ?? '旅行者' }}</text>
        </view>
        <view class="hero-date">
          <text class="date-month">{{ dateMonth }}</text>
          <text class="date-day">{{ dateDay }}</text>
        </view>
      </view>

      <!-- Stats row inside hero -->
      <view class="hero-stats">
        <view class="stat-item stat-item-tap" @click="goTravels">
          <text class="stat-num">{{ store.travels.length }}</text>
          <text class="stat-lbl">旅程</text>
        </view>
        <view class="stat-sep"></view>
        <view class="stat-item stat-item-tap" @click="goPostcards">
          <text class="stat-num">{{ store.postcards.length }}</text>
          <text class="stat-lbl">明信片</text>
        </view>
        <view class="stat-sep"></view>
        <view class="stat-item stat-item-tap" @click="goCollection">
          <text class="stat-num">{{ favoriteCount }}</text>
          <text class="stat-lbl">收藏</text>
        </view>
        <view class="stat-sep"></view>
        <view class="stat-item stat-item-tap" @click="goPoints">
          <text class="stat-num" style="color: #C4E0CB;">{{ user?.points ?? 0 }}</text>
          <text class="stat-lbl">积分</text>
        </view>
      </view>
    </view>

    <scroll-view class="content" scroll-y>

      <!-- Quick actions -->
      <view class="actions-row">
        <view class="action-btn" @click="goRecord">
          <view class="action-icon"><IconCamera :size="44" color="#2E7D58" /></view>
          <text class="action-lbl">记录</text>
        </view>
        <view class="action-btn" @click="goInbox">
          <view class="action-icon"><IconInbox :size="44" color="#2E7D58" /></view>
          <text class="action-lbl">收件箱</text>
          <view class="action-badge" v-if="unreadCount > 0">
            <text class="action-badge-txt">{{ unreadCount > 9 ? '9+' : unreadCount }}</text>
          </view>
        </view>
        <view class="action-btn" @click="goSend">
          <view class="action-icon"><IconSend :size="44" color="#2E7D58" /></view>
          <text class="action-lbl">寄出</text>
        </view>
        <view class="action-btn" @click="goContacts">
          <view class="action-icon"><IconContacts :size="44" color="#2E7D58" /></view>
          <text class="action-lbl">通讯录</text>
        </view>
      </view>

      <!-- Board banner -->
      <view class="board-banner" @click="goBoard">
        <view class="board-banner-left">
          <text class="board-banner-kicker">BULLETIN BOARD · 公告栏</text>
          <text class="board-banner-title">旅行公告栏</text>
          <text class="board-banner-sub">看看旅行者们都在哪里</text>
        </view>
        <view class="board-banner-right">
          <text class="board-banner-glyph">✦</text>
        </view>
      </view>

      <!-- Current travel -->
      <view class="section" v-if="store.currentTravel">
        <view class="section-hd">
          <text class="section-kicker">CURRENT TRIP · 当前旅程</text>
          <view class="section-rule"></view>
        </view>
        <view class="travel-card" @click="goTravel(store.currentTravel!.id)">
          <view class="travel-card-bar"></view>
          <view class="travel-card-body">
            <view class="travel-card-top">
              <text class="travel-title">{{ store.currentTravel.title }}</text>
              <view class="travel-status-pill">
                <text class="travel-status-txt">进行中</text>
              </view>
            </view>
            <text class="travel-dest">{{ store.currentTravel.destination }}</text>
            <text class="travel-count">{{ postcardCountForTravel(store.currentTravel.id) }} 张明信片</text>
          </view>
          <text class="travel-arr">›</text>
        </view>
      </view>

      <!-- Recent postcards -->
      <view class="section" v-if="recentPostcards.length > 0">
        <view class="section-hd">
          <text class="section-kicker">RECENT · 最近记录</text>
          <view class="section-rule"></view>
          <text class="section-more" @click="goTimeline">全部 ›</text>
        </view>
        <scroll-view scroll-x class="pc-scroll">
          <view class="pc-track">
            <view
              v-for="pc in recentPostcards"
              :key="pc.id"
              class="pc-card"
              @click="goDetail(pc.id)"
            >
              <view class="pc-photo" :style="{ background: getStampColor(pc.stampDesign) + '22' }">
                <image v-if="pc.photoUrl" :src="pc.photoUrl" class="pc-img" mode="aspectFill" />
                <image v-else-if="getStampImageUrl(pc.stampDesign)" :src="getStampImageUrl(pc.stampDesign)" class="pc-img" mode="aspectFill" />
                <text v-else class="pc-stamp-glyph">✦</text>
              </view>
              <view class="pc-card-body">
                <text class="pc-loc">{{ pc.locationName }}</text>
                <text class="pc-city">{{ pc.city }}</text>
                <text class="pc-date">{{ formatDate(pc.recordedAt) }}</text>
              </view>
            </view>
          </view>
        </scroll-view>
      </view>

      <!-- All travels list (when no current travel or as secondary) -->
      <view class="section" v-if="store.travels.length > 0">
        <view class="section-hd">
          <text class="section-kicker">TRAVELS · 旅程记录</text>
          <view class="section-rule"></view>
        </view>
        <view class="travel-list">
          <view
            v-for="t in recentTravels"
            :key="t.id"
            class="travel-row"
            @click="goTravel(t.id)"
          >
            <view class="travel-row-dot" :class="`status-${t.status}`"></view>
            <view class="travel-row-info">
              <text class="travel-row-title">{{ t.title }}</text>
              <text class="travel-row-dest">{{ t.destination }} · {{ postcardCountForTravel(t.id) }} 张</text>
            </view>
            <text class="travel-row-arr">›</text>
          </view>
        </view>
      </view>

      <!-- Empty state -->
      <view class="empty-state" v-if="store.travels.length === 0 && store.postcards.length === 0">
        <text class="empty-glyph">✦</text>
        <text class="empty-title">开始你的第一段旅程</text>
        <text class="empty-sub">记录每一张明信片，留住旅途中的美好时光</text>
        <view class="empty-btn" @click="goRecord">
          <text class="empty-btn-txt">记录第一张明信片 →</text>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>

  <!-- ── 新用户引导 ── -->
  <view v-if="showOnboarding" class="ob-mask">
    <view class="ob-card">
      <!-- 顶部邮票装饰 -->
      <view class="ob-stamp">
        <text class="ob-stamp-char">{{ onboardingSteps[obStep].icon }}</text>
      </view>

      <!-- 内容 -->
      <text class="ob-kicker">STEP {{ obStep + 1 }} / {{ onboardingSteps.length }}</text>
      <text class="ob-title">{{ onboardingSteps[obStep].title }}</text>
      <text class="ob-desc">{{ onboardingSteps[obStep].desc }}</text>

      <!-- 邮箱号展示（仅第 0 步）-->
      <view v-if="obStep === 0" class="ob-mailbox">
        <text class="ob-mailbox-lbl">YOUR MAILBOX NO.</text>
        <text class="ob-mailbox-val">{{ user?.mailboxNo }}</text>
        <text class="ob-mailbox-tip">这是你的唯一编号，好友通过它找到你</text>
      </view>

      <!-- 点指示器 -->
      <view class="ob-dots">
        <view
          v-for="(_, i) in onboardingSteps"
          :key="i"
          class="ob-dot"
          :class="{ 'ob-dot-active': i === obStep }"
        ></view>
      </view>

      <!-- 操作按钮 -->
      <view class="ob-actions">
        <view class="ob-btn-primary" @click="obNext">
          <text class="ob-btn-txt">{{ obStep < onboardingSteps.length - 1 ? '下一步 ›' : '开始使用 →' }}</text>
        </view>
        <text v-if="obStep < onboardingSteps.length - 1" class="ob-skip" @click="obFinish">跳过引导</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { useAuthStore } from '@/stores/auth'
import { MailApi } from '@/services/api'
import { StorageUtil } from '@/utils/storage'
import { getStampColor, getStampImageUrl } from '@/utils/stamp'
import { IconCamera, IconInbox, IconSend, IconContacts } from '@/components/icons'

const store     = usePostcardStore()
const authStore = useAuthStore()
const user      = computed(() => authStore.user)

const unreadCount = ref(0)

// ── 新用户引导 ────────────────────────────────────────────────────
const showOnboarding = ref(false)
const obStep = ref(0)

const onboardingSteps = [
  {
    icon: '邮',
    title: '欢迎来到旅行邮局',
    desc: '这是你的专属邮箱号，好友通过它给你寄明信片。请妥善保管，它也是你的登录凭证。',
  },
  {
    icon: '旅',
    title: '记录你的旅程',
    desc: '先创建一段旅程，再记录旅途中的明信片。每张明信片可附上照片、位置和心情备注。',
  },
  {
    icon: '寄',
    title: '寄给好友',
    desc: '保存明信片后，可以寄给好友。输入对方的邮箱号（如 CN-123456）即可找到 TA。',
  },
  {
    icon: '票',
    title: '收集邮票',
    desc: '每次签到、记录和寄信都能获得积分，用积分在邮票商店解锁更多精美邮票样式。',
  },
]

function obNext() {
  if (obStep.value < onboardingSteps.length - 1) {
    obStep.value++
  } else {
    obFinish()
  }
}

function obFinish() {
  StorageUtil.remove('is_new_user')
  showOnboarding.value = false
}

// ── Greeting ──────────────────────────────────────────────────────
const greeting = computed(() => {
  const h = new Date().getHours()
  if (h >= 5 && h < 12)  return '早上好，'
  if (h >= 12 && h < 14) return '中午好，'
  if (h >= 14 && h < 19) return '下午好，'
  if (h >= 19)            return '晚上好，'
  return '深夜了，'
})

// ── Date display ─────────────────────────────────────────────────
const now        = new Date()
const dateMonth  = String(now.getMonth() + 1).padStart(2, '0') + ' 月'
const dateDay    = String(now.getDate()).padStart(2, '0')

// ── Computed data ─────────────────────────────────────────────────
const favoriteCount = computed(() => store.postcards.filter(p => p.isFavorite).length)

const recentPostcards = computed(() => store.sortedPostcards.slice(0, 8))

const recentTravels = computed(() => store.sortedTravels.slice(0, 5))

function postcardCountForTravel(travelId: string): number {
  return store.postcards.filter(p => p.travelId === travelId).length
}

function formatDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getMonth() + 1}/${d.getDate()}`
}

// ── Navigation ────────────────────────────────────────────────────
function goRecord()     { uni.switchTab({ url: '/pages/record/record' }) }
function goTravels()    { uni.navigateTo({ url: '/pages/travels/travels' }) }
function goPostcards()  { uni.navigateTo({ url: '/pages/postcards/postcards' }) }
function goPoints()     { uni.navigateTo({ url: '/pages/points/points' }) }
function goTimeline()   { uni.switchTab({ url: '/pages/timeline/timeline' }) }
function goInbox()      { uni.navigateTo({ url: '/pages/inbox/inbox' }) }
function goContacts()   { uni.navigateTo({ url: '/pages/contacts/contacts' }) }
function goCollection() { uni.navigateTo({ url: '/pages/collection/collection' }) }
function goShop()       { uni.navigateTo({ url: '/pages/shop/shop' }) }
function goDetail(id: string) { uni.navigateTo({ url: `/pages/detail/detail?id=${id}` }) }
function goTravel(id: string) { uni.navigateTo({ url: `/pages/travel/travel?id=${id}` }) }

function goBoard()      { uni.navigateTo({ url: '/pages/board/board' }) }

function goSend() {
  const first = store.sortedPostcards[0]
  if (first) {
    uni.navigateTo({ url: `/pages/send/send?postcardId=${first.id}` })
  } else {
    uni.showToast({ title: '先记录一张明信片吧', icon: 'none' })
  }
}

// ── Load data ─────────────────────────────────────────────────────
function syncTabBadge(count: number) {
  if (count > 0) {
    uni.setTabBarBadge({ index: 4, text: count > 99 ? '99+' : String(count), fail: () => {} })
  } else {
    uni.removeTabBarBadge({ index: 4, fail: () => {} } as any)
  }
}

async function loadUnread() {
  try {
    const res = await MailApi.inbox()
    unreadCount.value = res.unreadCount
    syncTabBadge(res.unreadCount)
  } catch {
    // non-critical
  }
}

onMounted(() => {
  store.initData()
  if (StorageUtil.get<boolean>('is_new_user', false)) {
    showOnboarding.value = true
    obStep.value = 0
  }
})

onShow(() => {
  loadUnread()
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
}

// ── Hero ──────────────────────────────────────────────────────────
.hero {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 72rpx 40rpx 0;
  border-radius: 0 0 48rpx 48rpx;
}

.hero-inner {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 40rpx;
}

.hero-left {}

.hero-greeting {
  display: block;
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 3rpx;
  color: rgba(244,239,229,0.65);
  margin-bottom: 8rpx;
}

.hero-name {
  display: block;
  font-family: $font-family-serif;
  font-size: 48rpx;
  color: #F4EFE5;
}

.hero-date {
  text-align: right;
  margin-top: 4rpx;
}

.date-month {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: rgba(244,239,229,0.55);
}

.date-day {
  display: block;
  font-family: $font-family-serif;
  font-size: 72rpx;
  color: rgba(244,239,229,0.9);
  line-height: 1;
}

.hero-stats {
  display: flex;
  align-items: center;
  background: rgba(0,0,0,0.15);
  border-radius: 16rpx 16rpx 0 0;
  padding: 24rpx 32rpx;
  margin: 0 -40rpx;
}

.stat-item {
  flex: 1;
  text-align: center;
}

.stat-item-tap {
  border-radius: 8rpx;
  &:active { opacity: 0.7; }
}

.stat-num {
  display: block;
  font-family: $font-family-serif;
  font-size: 36rpx;
  color: #F4EFE5;
  margin-bottom: 4rpx;
}

.stat-lbl {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: rgba(244,239,229,0.55);
}

.stat-sep {
  width: 1rpx;
  height: 48rpx;
  background: rgba(244,239,229,0.2);
}

// ── Content ───────────────────────────────────────────────────────
.content { height: calc(100vh - 340rpx); }

// ── Quick actions ─────────────────────────────────────────────────
.actions-row {
  display: flex;
  gap: 0;
  margin: 32rpx 40rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 12rpx;
  overflow: hidden;
}

.action-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 28rpx 0 24rpx;
  position: relative;
  border-right: 1rpx solid $line-sepia;

  &:last-child { border-right: none; }
  &:active { background: rgba($travel-blue, 0.05); }
}

.action-icon {
  font-size: 36rpx;
  color: $travel-blue;
  margin-bottom: 10rpx;
  line-height: 1;
}

.action-lbl {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.action-badge {
  position: absolute;
  top: 16rpx;
  right: 16rpx;
  min-width: 32rpx;
  height: 32rpx;
  background: #A43B2D;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 6rpx;
}

.action-badge-txt {
  font-family: $font-family-mono;
  font-size: 16rpx;
  color: #F4EFE5;
}

// ── Board banner ──────────────────────────────────────────────────
.board-banner {
  margin: 24rpx 40rpx 0;
  background: linear-gradient(135deg, #2E7D58 0%, #1A5C3F 100%);
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 28rpx 32rpx;
  overflow: hidden;
  position: relative;

  &:active { opacity: 0.88; }
}

.board-banner-left { flex: 1; }

.board-banner-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: rgba(244,239,229,0.6);
  margin-bottom: 8rpx;
}

.board-banner-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 36rpx;
  color: #F4EFE5;
  margin-bottom: 6rpx;
}

.board-banner-sub {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
  color: rgba(244,239,229,0.65);
}

.board-banner-right {
  flex-shrink: 0;
  width: 80rpx;
  height: 80rpx;
  border: 1rpx solid rgba(244,239,229,0.25);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.board-banner-glyph {
  font-size: 36rpx;
  color: rgba(244,239,229,0.7);
}

// ── Section ───────────────────────────────────────────────────────
.section { margin: 32rpx 40rpx 0; }

.section-hd {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.section-kicker {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  white-space: nowrap;
  flex-shrink: 0;
}

.section-rule {
  flex: 1;
  height: 1rpx;
  background: $line-sepia;
}

.section-more {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  flex-shrink: 0;
}

// ── Current travel card ───────────────────────────────────────────
.travel-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 12rpx;
  display: flex;
  align-items: stretch;
  overflow: hidden;

  &:active { opacity: 0.88; }
}

.travel-card-bar {
  width: 6rpx;
  background: $travel-blue;
  flex-shrink: 0;
}

.travel-card-body {
  flex: 1;
  padding: 24rpx 20rpx;
}

.travel-card-top {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 8rpx;
}

.travel-title {
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: $ink-black;
  flex: 1;
}

.travel-status-pill {
  background: rgba($travel-blue, 0.1);
  border-radius: 20rpx;
  padding: 4rpx 16rpx;
}

.travel-status-txt {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
}

.travel-dest {
  display: block;
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $mute-text;
  margin-bottom: 4rpx;
}

.travel-count {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.travel-arr {
  font-family: $font-family-serif;
  font-size: 48rpx;
  color: $mute-text;
  padding: 0 20rpx;
  align-self: center;
}

// ── Recent postcards carousel ─────────────────────────────────────
.pc-scroll {
  width: 100%;
  white-space: nowrap;
}

.pc-track {
  display: inline-flex;
  gap: 16rpx;
  padding-bottom: 8rpx;
}

.pc-card {
  display: inline-flex;
  flex-direction: column;
  width: 200rpx;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
  flex-shrink: 0;

  &:active { opacity: 0.85; }
}

.pc-photo {
  width: 200rpx;
  height: 160rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.pc-img {
  width: 200rpx;
  height: 160rpx;
}

.pc-stamp-glyph {
  font-size: 48rpx;
  color: rgba(244,239,229,0.6);
}

.pc-card-body {
  padding: 14rpx 16rpx;
}

.pc-loc {
  display: block;
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 4rpx;
}

.pc-city {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 4rpx;
}

.pc-date {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  color: $mute-text;
}

// ── Travel list ───────────────────────────────────────────────────
.travel-list {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 12rpx;
  overflow: hidden;
}

.travel-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx;
  border-bottom: 1rpx solid $line-sepia;

  &:last-child { border-bottom: none; }
  &:active { background: rgba($travel-blue, 0.04); }
}

.travel-row-dot {
  width: 14rpx; height: 14rpx;
  border-radius: 50%;
  flex-shrink: 0;

  &.status-ongoing   { background: $travel-blue; }
  &.status-planned   { background: $mute-text; }
  &.status-completed { background: #7A7264; }
  &.status-cancelled { background: #A43B2D; }
}

.travel-row-info { flex: 1; min-width: 0; }

.travel-row-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.travel-row-dest {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.travel-row-arr {
  font-family: $font-family-serif;
  font-size: 40rpx;
  color: $mute-text;
}

// ── Empty state ───────────────────────────────────────────────────
.empty-state {
  margin: 80rpx 40rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.empty-glyph {
  font-size: 80rpx;
  color: rgba($travel-blue, 0.25);
  margin-bottom: 8rpx;
}

.empty-title {
  font-family: $font-family-serif;
  font-size: 36rpx;
  color: $ink-black;
}

.empty-sub {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $mute-text;
  text-align: center;
  line-height: 1.6;
  max-width: 500rpx;
}

.empty-btn {
  margin-top: 16rpx;
  padding: 20rpx 48rpx;
  background: $travel-blue;
  border-radius: 8rpx;

  &:active { background: $forest-green; }
}

.empty-btn-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: #F4EFE5;
}

.btm-gap { height: 120rpx; }

// ── 新用户引导 ─────────────────────────────────────────────────────
.ob-mask {
  position: fixed;
  inset: 0;
  background: rgba(16, 12, 8, 0.82);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

.ob-card {
  width: 620rpx;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 16rpx;
  padding: 48rpx 48rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
  box-shadow: 0 32rpx 80rpx rgba(0, 0, 0, 0.45);
}

.ob-stamp {
  width: 120rpx;
  height: 120rpx;
  border: 2rpx dashed rgba($travel-blue, 0.5);
  border-radius: 8rpx;
  background: rgba($travel-blue, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8rpx;
}

.ob-stamp-char {
  font-family: $font-family-serif;
  font-size: 56rpx;
  color: $travel-blue;
}

.ob-kicker {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 4rpx;
  color: $mute-text;
}

.ob-title {
  font-family: $font-family-serif;
  font-size: 40rpx;
  color: $ink-black;
  text-align: center;
  line-height: 1.3;
}

.ob-desc {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $body-text;
  text-align: center;
  line-height: 1.75;
  max-width: 520rpx;
}

.ob-mailbox {
  width: 100%;
  background: rgba($travel-blue, 0.06);
  border: 1rpx solid rgba($travel-blue, 0.25);
  border-radius: 8rpx;
  padding: 24rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
}

.ob-mailbox-lbl {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
}

.ob-mailbox-val {
  font-family: $font-family-mono;
  font-size: 40rpx;
  letter-spacing: 6rpx;
  color: $ink-black;
  font-weight: 600;
}

.ob-mailbox-tip {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: $mute-text;
  text-align: center;
  line-height: 1.5;
}

.ob-dots {
  display: flex;
  gap: 12rpx;
  margin: 8rpx 0;
}

.ob-dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: $line-sepia;
  transition: background 0.25s;

  &.ob-dot-active {
    background: $travel-blue;
    width: 32rpx;
    border-radius: 6rpx;
  }
}

.ob-actions {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
  margin-top: 8rpx;
}

.ob-btn-primary {
  width: 100%;
  background: $travel-blue;
  border-radius: 8rpx;
  padding: 26rpx 0;
  text-align: center;

  &:active { background: $forest-green; }
}

.ob-btn-txt {
  font-family: $font-family-serif;
  font-size: 30rpx;
  color: #F4EFE5;
  letter-spacing: 4rpx;
}

.ob-skip {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}
</style>

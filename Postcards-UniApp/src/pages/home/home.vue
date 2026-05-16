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

    </view>

    <scroll-view class="content" scroll-y>

      <!-- Primary action -->
      <view class="focus-card">
        <view class="focus-copy">
          <text class="focus-kicker">TODAY · 今日</text>
          <text class="focus-title">{{ focusTitle }}</text>
          <text class="focus-sub">{{ focusSubtitle }}</text>
        </view>
        <view class="focus-action" @click="goPrimaryAction">
          <IconCamera :size="30" color="#F4EFE5" />
          <text class="focus-action-txt">{{ primaryActionText }}</text>
        </view>
      </view>

      <!-- Stats row -->
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
          <text class="stat-num stat-num-points">{{ user?.points ?? 0 }}</text>
          <text class="stat-lbl">积分</text>
        </view>
      </view>

      <!-- Quick actions -->
      <view class="actions-row">
        <view class="action-btn" @click="goInbox">
          <view class="action-icon"><IconInbox :size="34" color="#3C604D" /></view>
          <text class="action-lbl">收件箱</text>
          <view class="action-badge" v-if="unreadCount > 0">
            <text class="action-badge-txt">{{ unreadCount > 9 ? '9+' : unreadCount }}</text>
          </view>
        </view>
        <view class="action-btn" @click="goSend">
          <view class="action-icon"><IconSend :size="34" color="#3C604D" /></view>
          <text class="action-lbl">寄出</text>
        </view>
        <view class="action-btn" @click="goContacts">
          <view class="action-icon"><IconContacts :size="34" color="#3C604D" /></view>
          <text class="action-lbl">通讯录</text>
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

      <!-- Board banner -->
      <view class="board-banner" @click="goBoard">
        <view class="board-banner-left">
          <text class="board-banner-kicker">BULLETIN BOARD · 公告栏</text>
          <text class="board-banner-title">旅行公告栏</text>
          <text class="board-banner-sub">看看旅行者们都在哪里</text>
        </view>
        <text class="board-banner-link">查看 ›</text>
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
        <view class="empty-btn" @click="goCreateTravel">
          <text class="empty-btn-txt">创建第一段旅程 →</text>
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
    icon: '旅',
    title: '先创建一段旅程',
    desc: '每张明信片都会归属到旅程里。先定下目的地，后面记录地点、照片和心情会更自然。',
  },
  {
    icon: '片',
    title: '记录第一张明信片',
    desc: '旅途中到达一个地点时，拍照或手动填写位置，就能把这一刻保存成明信片。',
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

const focusTitle = computed(() =>
  store.currentTravel ? `记录「${store.currentTravel.title}」` : '先创建你的第一段旅程'
)

const focusSubtitle = computed(() =>
  store.currentTravel
    ? `${store.currentTravel.destination} · ${postcardCountForTravel(store.currentTravel.id)} 张明信片`
    : '有了旅程后，每张明信片都会自动归档到路线上'
)

const primaryActionText = computed(() =>
  store.currentTravel || store.travels.length > 0 ? '记录此刻' : '创建旅程'
)

function postcardCountForTravel(travelId: string): number {
  return store.postcards.filter(p => p.travelId === travelId).length
}

function formatDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getMonth() + 1}/${d.getDate()}`
}

// ── Navigation ────────────────────────────────────────────────────
function goPrimaryAction() {
  if (store.currentTravel || store.travels.length > 0) {
    goRecord()
  } else {
    goCreateTravel()
  }
}

function goRecord()     { uni.switchTab({ url: '/pages/record/record' }) }
function goCreateTravel() { uni.navigateTo({ url: '/pages/travel/travel' }) }
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
    setTimeout(goRecord, 650)
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
  padding: 72rpx 40rpx 38rpx;
  border-radius: 0 0 36rpx 36rpx;
}

.hero-inner {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 0;
}

.hero-left {}

.hero-greeting {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: rgba(244,239,229,0.65);
  margin-bottom: 8rpx;
}

.hero-name {
  display: block;
  font-family: $font-family-display;
  font-size: 48rpx;
  color: #F4EFE5;
}

.hero-date {
  text-align: right;
  margin-top: 4rpx;
}

.date-month {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(244,239,229,0.55);
}

.date-day {
  display: block;
  font-family: $font-family-display;
  font-size: 72rpx;
  color: rgba(244,239,229,0.9);
  line-height: 1;
}

// ── Primary focus ─────────────────────────────────────────────────
.focus-card {
  margin: 30rpx 32rpx 0;
  background: $card-bg;
  border: 2rpx solid rgba($travel-blue, 0.34);
  border-radius: 12rpx;
  padding: 30rpx;
  display: flex;
  align-items: center;
  gap: 24rpx;
  box-shadow: $shadow-md;
}

.focus-copy {
  flex: 1;
  min-width: 0;
}

.focus-kicker {
  display: block;
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $travel-blue;
  margin-bottom: 8rpx;
}

.focus-title {
  display: block;
  font-family: $font-family-body;
  font-size: 34rpx;
  font-weight: 700;
  color: $ink-black;
  line-height: 1.25;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.focus-sub {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  line-height: 1.45;
  margin-top: 8rpx;
}

.focus-action {
  height: 92rpx;
  padding: 0 30rpx;
  border-radius: 8rpx;
  background: $travel-blue;
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
  &:active { background: $forest-green; }
}

.focus-action-txt {
  font-family: $font-family-action;
  font-size: 28rpx;
  color: #F4EFE5;
  white-space: nowrap;
}

.hero-stats {
  display: flex;
  align-items: center;
  background: $card-bg;
  border: 2rpx solid $line-sepia;
  border-radius: 12rpx;
  padding: 20rpx 24rpx;
  margin: 22rpx 32rpx 0;
  box-shadow: $shadow-sm;
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
  font-family: $font-family-body;
  font-size: 30rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
}

.stat-num-points {
  color: $travel-blue;
}

.stat-lbl {
  display: block;
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $mute-text;
}

.stat-sep {
  width: 1rpx;
  height: 40rpx;
  background: $line-sepia;
}

// ── Content ───────────────────────────────────────────────────────
.content { height: calc(100vh - 226rpx); }

// ── Quick actions ─────────────────────────────────────────────────
.actions-row {
  display: flex;
  gap: 0;
  margin: 22rpx 32rpx 0;
  background: $card-bg;
  border: 2rpx solid $line-sepia;
  border-radius: 12rpx;
  overflow: hidden;
  box-shadow: $shadow-sm;
}

.action-btn {
  flex: 1;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  padding: 24rpx 0;
  position: relative;
  border-right: 1rpx solid $line-sepia;

  &:last-child { border-right: none; }
  &:active { background: rgba($travel-blue, 0.05); }
}

.action-icon {
  line-height: 1;
}

.action-lbl {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
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
  font-family: $font-family-code;
  font-size: 22rpx;
  color: #F4EFE5;
}

// ── Board banner ──────────────────────────────────────────────────
.board-banner {
  margin: 26rpx 32rpx 0;
  background: rgba($travel-blue, 0.07);
  border: 2rpx solid rgba($travel-blue, 0.22);
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 26rpx;
  overflow: hidden;
  position: relative;

  &:active { opacity: 0.88; }
}

.board-banner-left { flex: 1; }

.board-banner-kicker {
  display: block;
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $mute-text;
  margin-bottom: 8rpx;
}

.board-banner-title {
  display: block;
  font-family: $font-family-body;
  font-size: 30rpx;
  color: $ink-black;
  margin-bottom: 6rpx;
}

.board-banner-sub {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $mute-text;
}

.board-banner-link {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $travel-blue;
  flex-shrink: 0;
}

// ── Section ───────────────────────────────────────────────────────
.section { margin: 38rpx 32rpx 0; }

.section-hd {
  display: flex;
  align-items: center;
  gap: 14rpx;
  margin-bottom: 20rpx;
  padding: 16rpx 18rpx;
  border-left: 8rpx solid $travel-blue;
  background: rgba($travel-blue, 0.08);
  border-radius: 8rpx;
}

.section-kicker {
  font-family: $font-family-action;
  font-size: 24rpx;
  font-weight: 700;
  letter-spacing: 0;
  color: $travel-blue;
  white-space: nowrap;
  flex-shrink: 0;
}

.section-rule {
  flex: 1;
  height: 0;
}

.section-more {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $mute-text;
  flex-shrink: 0;
}

// ── Current travel card ───────────────────────────────────────────
.travel-card {
  background: $card-bg;
  border: 2rpx solid $line-sepia;
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
  font-family: $font-family-body;
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
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $travel-blue;
}

.travel-dest {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  margin-bottom: 4rpx;
}

.travel-count {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.travel-arr {
  font-family: $font-family-body;
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
  border: 2rpx solid $line-sepia;
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
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 4rpx;
}

.pc-city {
  display: block;
  font-family: $font-family-body;
  font-size: 22rpx;
  letter-spacing: 0;
  letter-spacing: 1rpx;
  color: $mute-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 4rpx;
}

.pc-date {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  color: $mute-text;
}

// ── Travel list ───────────────────────────────────────────────────
.travel-list {
  background: $card-bg;
  border: 2rpx solid $line-sepia;
  border-radius: 12rpx;
  overflow: hidden;
  box-shadow: $shadow-sm;
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
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.travel-row-dest {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.travel-row-arr {
  font-family: $font-family-body;
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
  font-family: $font-family-body;
  font-size: 36rpx;
  color: $ink-black;
}

.empty-sub {
  font-family: $font-family-body;
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
  font-family: $font-family-action;
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
  font-family: $font-family-display;
  font-size: 56rpx;
  color: $travel-blue;
}

.ob-kicker {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.ob-title {
  font-family: $font-family-body;
  font-size: 40rpx;
  color: $ink-black;
  text-align: center;
  line-height: 1.3;
}

.ob-desc {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $body-text;
  text-align: center;
  line-height: 1.75;
  max-width: 520rpx;
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
  font-family: $font-family-action;
  font-size: 30rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

.ob-skip {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $mute-text;
}
</style>
  box-shadow: $shadow-sm;
  box-shadow: $shadow-sm;

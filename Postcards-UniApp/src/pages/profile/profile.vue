<template>
  <view class="page-container">
    <scroll-view class="content" scroll-y>
      <!-- Green gradient hero -->
      <view class="hero-section">
        <view class="hero-brand">
          <text class="hero-brand-title">旅行邮局</text>
          <text class="hero-brand-sub">CHINA POST · TRAVEL EDITION</text>
        </view>
        <view class="hero-monogram">
          <text class="monogram-letter">{{ userInitial }}</text>
        </view>
        <text class="hero-name">{{ userName }}</text>
        <text class="hero-rank">{{ profileTitle }}</text>
        <view class="mailbox-pill">
          <text class="mailbox-pill-txt">{{ mailboxNo }}</text>
        </view>
        <text class="hero-days">已加入 {{ joinedDays }} 天</text>
      </view>

      <!-- Floating stats card overlapping hero -->
      <view class="stats-float">
        <view class="stats-inner">
          <view class="stats-item">
            <text class="stats-num">{{ store.travels.length }}</text>
            <text class="stats-lbl">总旅程</text>
          </view>
          <view class="stats-sep"></view>
          <view class="stats-item">
            <text class="stats-num">{{ store.postcards.length }}</text>
            <text class="stats-lbl">明信片</text>
          </view>
          <view class="stats-sep"></view>
          <view class="stats-item">
            <text class="stats-num" style="color: #A43B2D;">{{ favoriteCount }}</text>
            <text class="stats-lbl">收藏</text>
          </view>
          <view class="stats-sep"></view>
          <view class="stats-item">
            <text class="stats-num" style="color: #3C604D;">{{ authStore.user?.points ?? 0 }}</text>
            <text class="stats-lbl">积分</text>
          </view>
        </view>
      </view>

      <!-- Stamp album teaser -->
      <view class="album-section">
        <view class="section-hd">
          <text class="section-kicker">STAMP ALBUM · 邮票集藏</text>
          <view class="section-rule"></view>
        </view>
        <view class="album-card">
          <view class="stamp-row">
            <view
              v-for="stamp in stampDesigns"
              :key="stamp.id"
              class="stamp-swatch"
              :class="{ 'stamp-swatch-collected': ownedSet.has(stamp.id) }"
              :style="ownedSet.has(stamp.id) ? { borderColor: stamp.color } : {}"
            >
              <text
                class="stamp-swatch-icon"
                :style="ownedSet.has(stamp.id) ? { color: stamp.color } : {}"
              >✦</text>
              <text class="stamp-swatch-name">{{ stamp.name }}</text>
            </view>
          </view>
          <view class="album-footer">
            <text class="album-note">已拥有 {{ ownedStampCount }} 款 · 共 {{ stampDesigns.length }} 款</text>
            <text class="album-link" @click="goToShop">前往商店 →</text>
          </view>
        </view>
      </view>

      <!-- Social menu -->
      <view class="menu-section">
        <view class="section-hd">
          <text class="section-kicker">SOCIAL · 社交</text>
          <view class="section-rule"></view>
        </view>
        <view class="menu-card">
          <view class="menu-item" @click="goToShop">
            <view class="menu-item-icon">
              <IconShop :size="22" color="#5C5648" />
            </view>
            <text class="menu-item-text">邮票商店</text>
            <view class="menu-item-pts">
              <text class="menu-pts-txt">{{ authStore.user?.points ?? 0 }} PT</text>
            </view>
            <IconCaretRight :size="18" color="#B5AE9B" />
          </view>
          <view class="menu-rule"></view>
          <view class="menu-item" @click="goToContacts">
            <view class="menu-item-icon">
              <IconContacts :size="22" color="#5C5648" />
            </view>
            <text class="menu-item-text">我的通讯录</text>
            <IconCaretRight :size="18" color="#B5AE9B" />
          </view>
          <view class="menu-rule"></view>
          <view class="menu-item" @click="goToInbox">
            <view class="menu-item-icon">
              <IconInbox :size="22" color="#5C5648" />
            </view>
            <text class="menu-item-text">我的收件箱</text>
            <IconCaretRight :size="18" color="#B5AE9B" />
          </view>
        </view>
      </view>

      <!-- Settings menu -->
      <view class="menu-section">
        <view class="section-hd">
          <text class="section-kicker">SETTINGS · 设置</text>
          <view class="section-rule"></view>
        </view>
        <view class="menu-card">
          <view class="menu-item" @click="editNickname">
            <view class="menu-item-icon">
              <IconEdit :size="22" color="#5C5648" />
            </view>
            <text class="menu-item-text">编辑昵称</text>
            <IconCaretRight :size="18" color="#B5AE9B" />
          </view>
          <view class="menu-rule"></view>
          <view class="menu-item" @click="doLogout">
            <view class="menu-item-icon">
              <IconSignOut :size="22" color="#A43B2D" />
            </view>
            <text class="menu-item-text" style="color: #A43B2D;">退出登录</text>
            <IconCaretRight :size="18" color="#B5AE9B" />
          </view>
        </view>
      </view>

      <view class="menu-section">
        <view class="section-hd">
          <text class="section-kicker">ABOUT · 关于</text>
          <view class="section-rule"></view>
        </view>
        <view class="menu-card">
          <view class="menu-item" @click="showPrivacy">
            <view class="menu-item-icon">
              <IconShield :size="22" color="#5C5648" />
            </view>
            <text class="menu-item-text">隐私协议</text>
            <IconCaretRight :size="18" color="#B5AE9B" />
          </view>
          <view class="menu-rule"></view>
          <view class="menu-item" @click="showAgreement">
            <view class="menu-item-icon">
              <IconFileText :size="22" color="#5C5648" />
            </view>
            <text class="menu-item-text">用户协议</text>
            <IconCaretRight :size="18" color="#B5AE9B" />
          </view>
          <view class="menu-rule"></view>
          <view class="menu-item" @click="showAbout">
            <view class="menu-item-icon">
              <IconInfo :size="22" color="#5C5648" />
            </view>
            <text class="menu-item-text">关于我们</text>
            <IconCaretRight :size="18" color="#B5AE9B" />
          </view>
        </view>
      </view>

      <!-- Footer -->
      <view class="footer">
        <text class="footer-mono">旅行邮局 · v{{ appVersion }}</text>
        <text class="footer-serif">记录旅途 · 寄往远方</text>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { usePostcardStore } from '@/stores/postcard'
import { useAuthStore } from '@/stores/auth'
import { UserApi } from '@/services/api'
import { AppConfig, StampDesigns } from '@/config/app'
import { StorageUtil } from '@/utils/storage'
import {
  IconEdit,
  IconReset,
  IconShield,
  IconFileText,
  IconInfo,
  IconCaretRight,
  IconInbox,
  IconSignOut,
  IconShop,
  IconContacts,
} from '@/components/icons'

const store = usePostcardStore()
const authStore = useAuthStore()

const FIRST_LAUNCH_KEY = 'postcards_first_launch'

const userName   = ref(authStore.user?.nickname || '远方旅人')
const joinedDays = ref(1)
const mailboxNo  = ref(authStore.user?.mailboxNo || 'CN-000000')

const appVersion   = AppConfig.version
const stampDesigns = StampDesigns

const userInitial = computed(() => userName.value.slice(0, 1))

const favoriteCount = computed(() => store.postcards.filter(p => p.isFavorite).length)

const profileTitle = computed(() => {
  const n = store.postcards.length
  if (n >= 20) return '环球旅者'
  if (n >= 10) return '资深邮差'
  if (n >= 5)  return '旅行达人'
  if (n >= 1)  return '初出茅庐'
  return '期待出发'
})

const ownedSet = computed(() =>
  authStore.ownedStamps.length > 0
    ? new Set(authStore.ownedStamps)
    : new Set(['classic', 'nature', 'culture', 'city', 'ocean', 'sunset'])
)
const ownedStampCount = computed(() => ownedSet.value.size)

function initProfileData() {
  userName.value  = authStore.user?.nickname || '远方旅人'
  mailboxNo.value = authStore.user?.mailboxNo || 'CN-000000'

  let firstLaunch = StorageUtil.get<number>(FIRST_LAUNCH_KEY, 0)
  if (firstLaunch === 0) {
    firstLaunch = Date.now()
    StorageUtil.set(FIRST_LAUNCH_KEY, firstLaunch)
  }
  const days = Math.floor((Date.now() - firstLaunch) / (24 * 60 * 60 * 1000))
  joinedDays.value = Math.max(1, days + 1)

  store.initData()
}

function editNickname() {
  uni.showModal({
    title: '编辑昵称',
    editable: true,
    placeholderText: '请输入您的昵称',
    success: async (res) => {
      if (res.confirm && res.content && res.content.trim()) {
        const newName = res.content.trim().slice(0, 12)
        try {
          await UserApi.update({ nickname: newName })
          authStore.updateUser({ nickname: newName })
          userName.value = newName
          uni.showToast({ title: '昵称已更新', icon: 'success' })
        } catch {
          uni.showToast({ title: '更新失败', icon: 'none' })
        }
      }
    },
  })
}

function goToShop() {
  uni.navigateTo({ url: '/pages/shop/shop' })
}

function goToContacts() {
  uni.navigateTo({ url: '/pages/contacts/contacts' })
}

function goToInbox() {
  uni.navigateTo({ url: '/pages/inbox/inbox' })
}

function doLogout() {
  uni.showModal({
    title: '退出登录',
    content: '确定要退出登录吗？',
    confirmColor: '#A43B2D',
    success: (res) => {
      if (res.confirm) {
        authStore.logout()
        uni.reLaunch({ url: '/pages/auth/login' })
      }
    },
  })
}

function resetData() {
  uni.showModal({
    title: '重置数据',
    content: '确定要重置所有数据吗？这将恢复为初始演示数据，您自定义的内容将丢失。',
    confirmColor: '#A43B2D',
    success: (res) => {
      if (res.confirm) {
        store.resetData()
        uni.showToast({ title: '数据已重置', icon: 'success' })
      }
    },
  })
}

function showPrivacy() {
  uni.showModal({
    title: '隐私协议',
    content: '旅行邮局重视您的隐私保护。我们仅在本地设备上存储您的旅行记录和明信片数据，不会上传到任何服务器。您的数据完全由您掌控。',
    showCancel: false,
  })
}

function showAgreement() {
  uni.showModal({
    title: '用户协议',
    content: '欢迎使用旅行邮局。本应用仅供个人旅行记录使用，所有内容版权归用户所有。请勿将应用用于任何违法违规用途。',
    showCancel: false,
  })
}

function goToCollection() {
  uni.navigateTo({ url: '/pages/collection/collection' })
}

function showAbout() {
  uni.showModal({
    title: '关于旅行邮局',
    content: `旅行邮局 v${appVersion}\n\n一款以邮政明信片为主题的旅行记录应用。\n\n记录旅途中的美好瞬间，将回忆封存为一张张独特的明信片。\n\n愿每一次旅行，都能寄往心中的远方。`,
    showCancel: false,
  })
}

onMounted(() => initProfileData())
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
}

.content {
  height: 100vh;
}

// ─── Hero ───
.hero-section {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 120rpx 48rpx 72rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0;
  position: relative;
}

.hero-brand {
  position: absolute;
  top: 56rpx;
  left: 48rpx;
}

.hero-brand-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: rgba(244, 239, 229, 0.85);
  letter-spacing: 4rpx;
}

.hero-brand-sub {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 2rpx;
  color: rgba(244, 239, 229, 0.5);
  margin-top: 4rpx;
}

.hero-monogram {
  width: 152rpx;
  height: 152rpx;
  border-radius: 50%;
  border: 2rpx solid rgba(244, 239, 229, 0.35);
  background: rgba(244, 239, 229, 0.12);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24rpx;
  box-shadow: 0 0 0 12rpx rgba(244, 239, 229, 0.06);
}

.monogram-letter {
  font-family: $font-family-serif;
  font-size: 72rpx;
  font-weight: 400;
  color: rgba(244, 239, 229, 0.95);
}

.hero-name {
  font-family: $font-family-serif;
  font-size: 44rpx;
  font-weight: 400;
  color: #F4EFE5;
  letter-spacing: 1rpx;
  margin-bottom: 10rpx;
}

.hero-rank {
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 26rpx;
  color: rgba(244, 239, 229, 0.75);
  margin-bottom: 20rpx;
}

.mailbox-pill {
  background: rgba(244, 239, 229, 0.12);
  border: 1rpx solid rgba(244, 239, 229, 0.25);
  border-radius: 999rpx;
  padding: 10rpx 32rpx;
  margin-bottom: 16rpx;
}

.mailbox-pill-txt {
  font-family: $font-family-mono;
  font-size: 24rpx;
  letter-spacing: 3rpx;
  color: rgba(244, 239, 229, 0.85);
}

.hero-days {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: rgba(244, 239, 229, 0.55);
}

// ─── Floating stats card ───
.stats-float {
  margin: -44rpx 40rpx 0;
  position: relative;
  z-index: 10;
}

.stats-inner {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding: 32rpx 24rpx;
  box-shadow: 0 8rpx 24rpx rgba(40, 30, 15, 0.10);
}

.stats-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6rpx;
}

.stats-num {
  font-family: $font-family-serif;
  font-size: 52rpx;
  font-weight: 400;
  color: $ink-black;
  line-height: 1;
  letter-spacing: -1rpx;
}

.stats-lbl {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.stats-sep {
  width: 1rpx;
  height: 56rpx;
  background: $line-sepia;
}

// ─── Section header pattern ───
.section-hd {
  display: flex;
  align-items: center;
  gap: 20rpx;
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

// ─── Stamp album ───
.album-section {
  margin: 48rpx 40rpx 0;
}

.album-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 24rpx;
}

.stamp-row {
  display: flex;
  gap: 16rpx;
  overflow-x: auto;
  padding-bottom: 8rpx;
}

.stamp-swatch {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  padding: 16rpx 18rpx 12rpx;
  border: 1rpx dashed $whisper;
  border-radius: 4rpx;
  flex-shrink: 0;
  min-width: 80rpx;
  background: $page-background;
  opacity: 0.45;
}

.stamp-swatch-collected {
  opacity: 1;
}

.stamp-swatch-icon {
  font-size: 24rpx;
  color: $whisper;
}

.stamp-swatch-name {
  font-family: $font-family-serif;
  font-size: 20rpx;
  color: $mute-text;
}

.album-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20rpx;
}

.album-note {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.album-link {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

// ─── Menu ───
.menu-section {
  margin: 40rpx 40rpx 0;
}

.menu-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 28rpx 24rpx;

  &:active {
    background: rgba($travel-blue, 0.04);
  }
}

.menu-item-icon {
  width: 44rpx;
  height: 44rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.menu-item-text {
  flex: 1;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
}

.menu-item-pts {
  background: rgba($travel-blue, 0.1);
  border-radius: 6rpx;
  padding: 4rpx 12rpx;
  margin-right: 8rpx;
}
.menu-pts-txt {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
}

.menu-rule {
  height: 1rpx;
  background: $line-sepia;
  margin: 0 24rpx;
}

// ─── Footer ───
.footer {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  padding: 56rpx 32rpx 0;
}

.footer-mono {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $whisper;
}

.footer-serif {
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 24rpx;
  color: $whisper;
}

.btm-gap { height: 120rpx; }
</style>

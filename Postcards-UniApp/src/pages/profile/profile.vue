<template>
  <view class="page-container">
    <scroll-view class="content" scroll-y>
      <!-- Hero Section -->
      <view class="hero-section">
        <view class="hero-card">
          <view class="brand-header">
            <text class="brand-title">远方邮政</text>
            <text class="brand-subtitle">CHINA POST</text>
          </view>

          <view class="profile-avatar">
            <view class="avatar-circle">
              <IconUser :size="64" color="#2E7D58" />
            </view>
          </view>

          <text class="profile-name">{{ userName }}</text>
          <view class="profile-badge">
            <IconGlobe :size="24" color="#FFD700" />
            <text class="badge-text">{{ profileTitle }}</text>
          </view>
          <text class="profile-days">已加入 {{ joinedDays }} 天</text>

          <view class="mailbox-badge">
            <text class="mailbox-label">个人邮箱</text>
            <text class="mailbox-number">{{ mailboxNo }}</text>
          </view>
        </view>
      </view>

      <!-- Stats Section -->
      <view class="stats-section">
        <view class="stats-card">
          <view class="stat-item">
            <IconStampClassic :size="32" color="#2E7D58" />
            <text class="stat-value">{{ store.travels.length }}</text>
            <text class="stat-label">总旅程</text>
          </view>
          <view class="stat-divider"></view>
          <view class="stat-item">
            <IconImage :size="32" color="#2E7D58" />
            <text class="stat-value">{{ store.postcards.length }}</text>
            <text class="stat-label">明信片</text>
          </view>
          <view class="stat-divider"></view>
          <view class="stat-item">
            <IconFavorite :size="32" color="#C41E3A" />
            <text class="stat-value">{{ favoriteCount }}</text>
            <text class="stat-label">收藏</text>
          </view>
        </view>
      </view>

      <!-- Menu Section -->
      <view class="menu-section">
        <text class="menu-title">设置</text>
        <view class="menu-card">
          <view class="menu-item" @click="editNickname">
            <view class="menu-icon">
              <IconEdit :size="24" color="#2E7D58" />
            </view>
            <text class="menu-text">编辑昵称</text>
            <view class="menu-arrow">
              <IconCaretRight :size="20" color="#999" />
            </view>
          </view>
          <view class="menu-divider"></view>
          <view class="menu-item" @click="resetData">
            <view class="menu-icon">
              <IconReset :size="24" color="#2E7D58" />
            </view>
            <text class="menu-text">重置数据</text>
            <view class="menu-arrow">
              <IconCaretRight :size="20" color="#999" />
            </view>
          </view>
        </view>

        <text class="menu-title">关于</text>
        <view class="menu-card">
          <view class="menu-item" @click="showPrivacy">
            <view class="menu-icon">
              <IconShield :size="24" color="#2E7D58" />
            </view>
            <text class="menu-text">隐私协议</text>
            <view class="menu-arrow">
              <IconCaretRight :size="20" color="#999" />
            </view>
          </view>
          <view class="menu-divider"></view>
          <view class="menu-item" @click="showAgreement">
            <view class="menu-icon">
              <IconFileText :size="24" color="#2E7D58" />
            </view>
            <text class="menu-text">用户协议</text>
            <view class="menu-arrow">
              <IconCaretRight :size="20" color="#999" />
            </view>
          </view>
          <view class="menu-divider"></view>
          <view class="menu-item" @click="showAbout">
            <view class="menu-icon">
              <IconInfo :size="24" color="#2E7D58" />
            </view>
            <text class="menu-text">关于我们</text>
            <view class="menu-arrow">
              <IconCaretRight :size="20" color="#999" />
            </view>
          </view>
        </view>
      </view>

      <!-- Footer -->
      <view class="footer">
        <text class="footer-version">远方邮政 v{{ appVersion }}</text>
        <text class="footer-copyright">记录旅途，寄往远方</text>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { usePostcardStore } from '@/stores/postcard'
import { AppConfig } from '@/config/app'
import { StorageUtil } from '@/utils/storage'
import {
  IconUser,
  IconGlobe,
  IconStampClassic,
  IconImage,
  IconFavorite,
  IconEdit,
  IconReset,
  IconShield,
  IconFileText,
  IconInfo,
  IconCaretRight,
} from '@/components/icons'

const store = usePostcardStore()

const USER_NAME_KEY = 'postcards_user_name'
const FIRST_LAUNCH_KEY = 'postcards_first_launch'
const MAILBOX_NO_KEY = 'postcards_mailbox_no'

const userName = ref('远方旅人')
const joinedDays = ref(1)
const mailboxNo = ref('CN-000001')

const appVersion = AppConfig.version

// 计算收藏数量
const favoriteCount = computed(() => {
  return store.postcards.filter(p => p.isFavorite).length
})

// 根据统计数据动态计算头衔
const profileTitle = computed(() => {
  const count = store.postcards.length
  if (count >= 20) return '环球旅者'
  if (count >= 10) return '资深邮差'
  if (count >= 5) return '旅行达人'
  if (count >= 1) return '初出茅庐'
  return '期待出发'
})

function initProfileData() {
  // 昵称
  const savedName = StorageUtil.get<string>(USER_NAME_KEY, '')
  if (savedName) {
    userName.value = savedName
  }

  // 首次启动时间
  let firstLaunch = StorageUtil.get<number>(FIRST_LAUNCH_KEY, 0)
  if (firstLaunch === 0) {
    firstLaunch = Date.now()
    StorageUtil.set(FIRST_LAUNCH_KEY, firstLaunch)
  }
  const days = Math.floor((Date.now() - firstLaunch) / (24 * 60 * 60 * 1000))
  joinedDays.value = Math.max(1, days + 1)

  // 邮箱编号
  let savedMailbox = StorageUtil.get<string>(MAILBOX_NO_KEY, '')
  if (!savedMailbox) {
    const randomNum = Math.floor(100000 + Math.random() * 900000)
    savedMailbox = `CN-${randomNum}`
    StorageUtil.set(MAILBOX_NO_KEY, savedMailbox)
  }
  mailboxNo.value = savedMailbox

  // 确保 store 数据已加载
  store.initData()
}

function editNickname() {
  uni.showModal({
    title: '编辑昵称',
    editable: true,
    placeholderText: '请输入您的昵称',
    success: (res) => {
      if (res.confirm && res.content && res.content.trim()) {
        const newName = res.content.trim().slice(0, 12)
        userName.value = newName
        StorageUtil.set(USER_NAME_KEY, newName)
        uni.showToast({ title: '昵称已更新', icon: 'success' })
      }
    },
  })
}

function resetData() {
  uni.showModal({
    title: '重置数据',
    content: '确定要重置所有数据吗？这将恢复为初始演示数据，您自定义的内容将丢失。',
    confirmColor: '#C41E3A',
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
    content: '远方邮政重视您的隐私保护。我们仅在本地设备上存储您的旅行记录和明信片数据，不会上传到任何服务器。您的数据完全由您掌控。',
    showCancel: false,
  })
}

function showAgreement() {
  uni.showModal({
    title: '用户协议',
    content: '欢迎使用远方邮政。本应用仅供个人旅行记录使用，所有内容版权归用户所有。请勿将应用用于任何违法违规用途。',
    showCancel: false,
  })
}

function showAbout() {
  uni.showModal({
    title: '关于远方邮政',
    content: `远方邮政 v${appVersion}\n\n一款以邮政明信片为主题的旅行记录应用。\n\n记录旅途中的美好瞬间，将回忆封存为一张张独特的明信片。\n\n愿每一次旅行，都能寄往心中的远方。`,
    showCancel: false,
  })
}

onMounted(() => {
  initProfileData()
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
}

.content {
  padding-bottom: 40rpx;
}

// Hero Section
.hero-section {
  padding: 120rpx 40rpx 40rpx;
  background: linear-gradient(135deg, $travel-blue 0%, $forest-green 100%);
}

.hero-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.brand-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4rpx;
  margin-bottom: 16rpx;
}

.brand-title {
  font-size: 32rpx;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.9);
  font-family: 'Georgia', serif;
  letter-spacing: 4rpx;
}

.brand-subtitle {
  font-size: 18rpx;
  color: rgba(255, 255, 255, 0.6);
  letter-spacing: 2rpx;
}

.profile-avatar {
  margin: 8rpx 0;
}

.avatar-circle {
  width: 160rpx;
  height: 160rpx;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.15);
}

.profile-name {
  font-size: 40rpx;
  font-weight: 700;
  color: #fff;
  margin-top: 8rpx;
}

.profile-badge {
  display: flex;
  align-items: center;
  gap: 8rpx;
  background: rgba(255, 255, 255, 0.15);
  padding: 8rpx 20rpx;
  border-radius: 9999rpx;
}

.badge-text {
  font-size: 24rpx;
  color: #FFD700;
  font-weight: 500;
}

.profile-days {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.7);
  margin-top: 4rpx;
}

.mailbox-badge {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4rpx;
  margin-top: 8rpx;
  padding: 12rpx 32rpx;
  border: 1rpx solid rgba(255, 255, 255, 0.25);
  border-radius: 12rpx;
}

.mailbox-label {
  font-size: 20rpx;
  color: rgba(255, 255, 255, 0.6);
}

.mailbox-number {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 600;
  font-family: 'Courier New', monospace;
  letter-spacing: 2rpx;
}

// Stats Section
.stats-section {
  padding: 0 32rpx;
  margin-top: -32rpx;
}

.stats-card {
  background: #fff;
  border-radius: 20rpx;
  padding: 32rpx;
  display: flex;
  align-items: center;
  justify-content: space-around;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  flex: 1;
}

.stat-divider {
  width: 1rpx;
  height: 60rpx;
  background: $line-sepia;
}

.stat-value {
  font-size: 36rpx;
  font-weight: 700;
  color: $ink-black;
}

.stat-label {
  font-size: 22rpx;
  color: #999;
}

// Menu Section
.menu-section {
  padding: 32rpx;
}

.menu-title {
  font-size: 26rpx;
  font-weight: 600;
  color: #999;
  margin: 24rpx 0 16rpx 8rpx;
  letter-spacing: 2rpx;
}

.menu-card {
  background: #fff;
  border-radius: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
  overflow: hidden;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 28rpx 24rpx;
  transition: background 0.2s;
}

.menu-item:active {
  background: rgba($travel-blue, 0.04);
}

.menu-icon {
  width: 44rpx;
  height: 44rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20rpx;
}

.menu-text {
  flex: 1;
  font-size: 28rpx;
  color: $ink-black;
}

.menu-arrow {
  display: flex;
  align-items: center;
}

.menu-divider {
  height: 1rpx;
  background: rgba($line-sepia, 0.5);
  margin-left: 88rpx;
}

// Footer
.footer {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  padding: 48rpx 32rpx 32rpx;
}

.footer-version {
  font-size: 22rpx;
  color: #bbb;
}

.footer-copyright {
  font-size: 20rpx;
  color: #ccc;
}
</style>

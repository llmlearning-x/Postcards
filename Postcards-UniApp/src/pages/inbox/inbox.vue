<template>
  <view class="page-container">
    <!-- Header -->
    <view class="page-header">
      <view class="nav-back" @click="goBack">
        <IconBack :size="20" color="#F4EFE5" />
      </view>
      <view class="header-center">
        <text class="header-kicker">INBOX · 收件箱</text>
        <text class="header-title">我的来信</text>
      </view>
      <view class="unread-badge" v-if="inbox.unreadCount > 0">
        <text class="unread-num">{{ inbox.unreadCount }}</text>
      </view>
      <view style="width: 64rpx;" v-else></view>
    </view>

    <!-- Perforation line -->
    <view class="perf-line">
      <view v-for="i in 16" :key="i" class="perf-hole"></view>
    </view>

    <scroll-view class="content" scroll-y @scrolltolower="loadMore">
      <!-- Empty state -->
      <view class="empty-state" v-if="!loading && inbox.items.length === 0">
        <IconEnvelope :size="80" color="#B5AE9B" />
        <text class="empty-title">信箱空空如也</text>
        <text class="empty-sub">好友给你寄来的明信片会出现在这里</text>
      </view>

      <!-- Loading -->
      <view class="loading-wrap" v-if="loading">
        <text class="loading-txt">正在取信…</text>
      </view>

      <!-- Mailing list -->
      <view class="mail-list" v-if="!loading">
        <view
          v-for="item in inbox.items"
          :key="item.id"
          class="mail-row"
          :class="{ 'mail-unread': !item.openedAt }"
          @click="viewMail(item)"
        >
          <!-- Unread dot -->
          <view class="unread-dot" v-if="!item.openedAt"></view>
          <view class="unread-dot-placeholder" v-else></view>

          <!-- Sender avatar -->
          <view class="sender-avatar">
            <text class="sender-initial">{{ item.sender.nickname.slice(0, 1) }}</text>
          </view>

          <!-- Content -->
          <view class="mail-content">
            <view class="mail-content-top">
              <text class="sender-name">{{ item.sender.nickname }}</text>
              <text class="mail-date">{{ formatRelativeDate(item.sentAt) }}</text>
            </view>
            <text class="mail-mailbox">{{ item.sender.mailboxNo }}</text>
            <text class="mail-preview">
              {{ item.snapshot.locationName }} · {{ item.snapshot.city }}
              {{ item.personalNote ? ' — ' + item.personalNote : '' }}
            </text>
          </view>

          <!-- Stamp indicator -->
          <view class="stamp-dot" :style="{ background: getStampColor(item.snapshot.stampDesign) }"></view>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { MailApi, type MailingItem, type InboxResponse } from '@/services/api'
import { StampDesigns } from '@/config/app'
import { IconBack, IconEnvelope } from '@/components/icons'
import { getStampColor } from '@/utils/stamp'

const loading = ref(true)
const inbox = ref<InboxResponse>({ unreadCount: 0, items: [] })

function formatRelativeDate(ts: number): string {
  const d = new Date(ts)
  return `${String(d.getMonth() + 1).padStart(2, '0')}/${String(d.getDate()).padStart(2, '0')}`
}

async function loadInbox() {
  loading.value = true
  try {
    inbox.value = await MailApi.inbox()
  } catch (e) {
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function loadMore() {}

function viewMail(item: MailingItem) {
  const data = encodeURIComponent(JSON.stringify(item))
  uni.navigateTo({ url: `/pages/maildetail/maildetail?data=${data}` })
}

function goBack() {
  uni.navigateBack()
}

onShow(() => loadInbox())
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
}

.page-header {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 56rpx 40rpx 36rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.nav-back {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  background: rgba(244, 239, 229, 0.12);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.header-center { flex: 1; }

.header-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 4rpx;
  color: rgba(244, 239, 229, 0.65);
  margin-bottom: 6rpx;
}

.header-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 40rpx;
  font-weight: 400;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

.unread-badge {
  min-width: 48rpx;
  height: 48rpx;
  border-radius: 24rpx;
  background: $stamp-red;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 14rpx;
}

.unread-num {
  font-family: $font-family-mono;
  font-size: 22rpx;
  color: #F4EFE5;
  font-weight: 600;
}

.perf-line {
  display: flex;
  gap: 0;
  padding: 10rpx 24rpx;
  background: $card-bg;
  border-bottom: 1rpx solid $line-sepia;
}

.perf-hole {
  flex: 1;
  height: 16rpx;
  border-radius: 50%;
  border: 1rpx solid $line-sepia;
  background: $page-background;
  margin: 0 4rpx;
}

.content { height: calc(100vh - 220rpx); }

.loading-wrap {
  padding: 80rpx;
  text-align: center;
}

.loading-txt {
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 28rpx;
  color: $mute-text;
}

.empty-state {
  padding: 120rpx 60rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
}

.empty-title {
  font-family: $font-family-serif;
  font-size: 36rpx;
  color: $body-text;
  margin-top: 16rpx;
}

.empty-sub {
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $mute-text;
  text-align: center;
  line-height: 1.7;
}

.mail-list { padding: 0 40rpx; }

.mail-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 28rpx 0;
  border-bottom: 1rpx solid $line-sepia;
  position: relative;

  &:active { background: rgba($travel-blue, 0.03); }
}

.mail-unread .mail-content-top .sender-name {
  color: $ink-black;
  font-weight: 600;
}

.unread-dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: $travel-blue;
  flex-shrink: 0;
}

.unread-dot-placeholder {
  width: 12rpx;
  flex-shrink: 0;
}

.sender-avatar {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.sender-initial {
  font-family: $font-family-serif;
  font-size: 36rpx;
  color: #F4EFE5;
}

.mail-content { flex: 1; min-width: 0; }

.mail-content-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6rpx;
}

.sender-name {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $body-text;
}

.mail-date {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.mail-mailbox {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 8rpx;
}

.mail-preview {
  display: block;
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $mute-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.stamp-dot {
  width: 20rpx;
  height: 20rpx;
  border-radius: 50%;
  flex-shrink: 0;
  opacity: 0.7;
}

.btm-gap { height: 120rpx; }
</style>

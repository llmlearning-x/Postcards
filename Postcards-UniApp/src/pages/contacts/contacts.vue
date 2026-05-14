<template>
  <view class="page-container">
    <!-- Header -->
    <view class="page-header">
      <view class="nav-back" @click="goBack">
        <IconBack :size="20" color="#F4EFE5" />
      </view>
      <view class="header-center">
        <text class="header-kicker">CONTACTS · 通讯录</text>
        <text class="header-title">我的联系人</text>
      </view>
      <view style="width: 64rpx;"></view>
    </view>

    <scroll-view class="content" scroll-y>
      <!-- Loading -->
      <view class="state-center" v-if="loading">
        <text class="state-txt">加载中…</text>
      </view>

      <!-- Error -->
      <view class="state-center" v-else-if="error">
        <text class="state-txt">{{ error }}</text>
        <view class="retry-btn" @click="load">重试</view>
      </view>

      <!-- Empty -->
      <view class="empty-state" v-else-if="contacts.length === 0">
        <view class="empty-icon-wrap">
          <IconContacts :size="48" color="#B5AE9B" />
        </view>
        <text class="empty-title">暂无联系人</text>
        <text class="empty-sub">寄出或收到明信片后，对方会出现在这里</text>
      </view>

      <!-- Contact list -->
      <view class="list" v-else>
        <view
          v-for="(c, idx) in contacts"
          :key="c.id"
          class="contact-card"
          :class="{ 'contact-card-last': idx === contacts.length - 1 }"
        >
          <view class="contact-avatar">
            <image
              v-if="c.avatarUrl"
              :src="c.avatarUrl"
              class="avatar-img"
              mode="aspectFill"
            />
            <text v-else class="avatar-initial">{{ initial(c) }}</text>
          </view>

          <view class="contact-info">
            <text class="contact-name">{{ c.remarkName || c.nickname }}</text>
            <view class="contact-meta">
              <text class="contact-mailbox">{{ c.mailboxNo }}</text>
              <text class="contact-dot">·</text>
              <text class="contact-count">{{ c.mailCount }} 封往来</text>
            </view>
          </view>

          <view class="send-btn" @click="goSend(c)">
            <text class="send-btn-txt">寄出</text>
            <IconSend :size="14" color="#F4EFE5" />
          </view>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ContactsApi, type ContactItem } from '@/services/api'
import { IconBack, IconSend, IconContacts } from '@/components/icons'

const contacts = ref<ContactItem[]>([])
const loading  = ref(true)
const error    = ref('')

function initial(c: ContactItem): string {
  return (c.remarkName || c.nickname).slice(0, 1)
}

async function load() {
  loading.value = true
  error.value   = ''
  try {
    contacts.value = await ContactsApi.list()
  } catch (e: any) {
    error.value = e.message || '加载失败'
  } finally {
    loading.value = false
  }
}

function goSend(c: ContactItem) {
  uni.navigateTo({
    url: `/pages/send/send?recipientId=${c.contactId}&recipientNickname=${encodeURIComponent(c.remarkName || c.nickname)}&recipientMailboxNo=${encodeURIComponent(c.mailboxNo)}`,
  })
}

function goBack() {
  uni.navigateBack()
}

onMounted(load)
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
  width: 64rpx; height: 64rpx;
  border-radius: 50%;
  background: rgba(244,239,229,0.12);
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

.state-center {
  padding: 120rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 32rpx;
}

.state-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $mute-text;
}

.retry-btn {
  padding: 16rpx 48rpx;
  background: $travel-blue;
  border-radius: 8rpx;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: #F4EFE5;
}

.empty-state {
  padding: 120rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
}

.empty-icon-wrap {
  width: 120rpx; height: 120rpx;
  border-radius: 50%;
  background: rgba($travel-blue, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12rpx;
}

.empty-title {
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: $ink-black;
}

.empty-sub {
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $mute-text;
  text-align: center;
  line-height: 1.6;
  max-width: 480rpx;
}

.list {
  padding: 32rpx 40rpx 0;
}

.contact-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 12rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;

  &:active { opacity: 0.85; }
}

.contact-card-last { margin-bottom: 0; }

.contact-avatar {
  width: 80rpx; height: 80rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  overflow: hidden;
}

.avatar-img {
  width: 80rpx; height: 80rpx;
  border-radius: 50%;
}

.avatar-initial {
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: #F4EFE5;
}

.contact-info {
  flex: 1;
  min-width: 0;
}

.contact-name {
  display: block;
  font-family: $font-family-serif;
  font-size: 30rpx;
  color: $ink-black;
  margin-bottom: 8rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.contact-meta {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.contact-mailbox {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.contact-dot {
  font-family: $font-family-mono;
  font-size: 18rpx;
  color: $mute-text;
}

.contact-count {
  font-family: $font-family-mono;
  font-size: 20rpx;
  color: $mute-text;
}

.send-btn {
  flex-shrink: 0;
  height: 60rpx;
  padding: 0 24rpx;
  background: $travel-blue;
  border-radius: 30rpx;
  display: flex;
  align-items: center;
  gap: 8rpx;

  &:active { background: $forest-green; }
}

.send-btn-txt {
  font-family: $font-family-mono;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: #F4EFE5;
}

.btm-gap { height: 120rpx; }
</style>

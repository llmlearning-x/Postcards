<template>
  <view class="page-container" v-if="item">
    <!-- Floating nav -->
    <view class="float-nav">
      <view class="nav-btn" @click="goBack">
        <IconBack :size="20" color="#F4EFE5" />
      </view>
      <text class="nav-label">MAIL · 来信</text>
      <view style="width: 76rpx;"></view>
    </view>

    <scroll-view class="scroll-wrap" scroll-y>
      <!-- Hero photo -->
      <view class="hero-wrap">
        <image
          v-if="item.snapshot.photoUrl"
          :src="item.snapshot.photoUrl"
          class="hero-img"
          mode="aspectFill"
        />
        <view v-else class="hero-placeholder">
          <IconEnvelope :size="80" color="rgba(244,239,229,0.5)" />
        </view>
        <!-- Postmark -->
        <view class="postmark">
          <view class="postmark-outer"></view>
          <view class="postmark-inner"></view>
          <view class="postmark-text">
            <text class="postmark-city">{{ item.snapshot.city.substring(0,4).toUpperCase() }}</text>
            <text class="postmark-date">{{ dotDate(item.sentAt) }}</text>
          </view>
        </view>
        <view class="hero-fade"></view>
      </view>

      <!-- Card -->
      <view class="detail-card-wrap">
        <!-- Sender strip -->
        <view class="sender-strip">
          <view class="sender-avatar">
            <text class="sender-initial">{{ item.sender.nickname.slice(0, 1) }}</text>
          </view>
          <view class="sender-info">
            <text class="sender-name">{{ item.sender.nickname }}</text>
            <text class="sender-mailbox">{{ item.sender.mailboxNo }}</text>
          </view>
          <view class="sent-time">
            <text class="sent-label">SENT</text>
            <text class="sent-date">{{ fullDate(item.sentAt) }}</text>
          </view>
        </view>

        <!-- Postcard back -->
        <view class="pback">
          <view class="pback-hd">
            <view class="pback-hd-left">
              <text class="pback-title">POST CARD · 明信片</text>
              <text class="pback-series">来自 {{ item.snapshot.locationName }}</text>
            </view>
            <view class="pback-stamp" :style="{ borderColor: stampColor(item.snapshot.stampDesign) }">
              <text class="pback-stamp-dot" :style="{ color: stampColor(item.snapshot.stampDesign) }">✦</text>
              <text class="pback-stamp-name" :style="{ color: stampColor(item.snapshot.stampDesign) }">{{ stampName(item.snapshot.stampDesign) }}</text>
            </view>
          </view>
          <view class="pback-rule"></view>

          <view class="pback-body">
            <view class="pback-message">
              <text class="pback-msg-label">MESSAGE · 卡片留言</text>
              <text class="pback-note">{{ item.snapshot.note || '（无留言）' }}</text>
            </view>
            <view class="pback-vdivider"></view>
            <view class="pback-address">
              <text class="pback-addr-label">FROM</text>
              <text class="pback-addr-main">{{ item.snapshot.locationName }}</text>
              <text class="pback-addr-sub">{{ item.snapshot.city }} · {{ item.snapshot.country }}</text>
              <view class="pback-addr-sep"></view>
              <text class="pback-addr-label">TO</text>
              <text class="pback-addr-main">你</text>
            </view>
          </view>

          <!-- Personal note -->
          <view class="personal-note-wrap" v-if="item.personalNote">
            <view class="pback-rule"></view>
            <view class="personal-note">
              <text class="note-label">PERSONAL NOTE · 个人留言</text>
              <text class="note-content">{{ item.personalNote }}</text>
              <text class="note-sig">— {{ item.sender.nickname }}</text>
            </view>
          </view>

          <view class="pback-footer">
            <text class="pback-footer-l">旅行邮局 · 寄往远方</text>
            <text class="pback-footer-r">{{ item.status === 'opened' ? '已读' : '新信' }}</text>
          </view>
        </view>

        <view class="btm-gap"></view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { MailApi, type MailingItem } from '@/services/api'
import { StampDesigns } from '@/config/app'
import { IconBack, IconEnvelope } from '@/components/icons'

const item = ref<MailingItem | null>(null)

function stampColor(id: string): string {
  return (StampDesigns as any[]).find(s => s.id === id)?.color ?? '#8E8775'
}

function stampName(id: string): string {
  return (StampDesigns as any[]).find(s => s.id === id)?.name ?? '经典'
}

function dotDate(ts: number): string {
  const d = new Date(ts)
  return `${String(d.getMonth() + 1).padStart(2, '0')}·${String(d.getDate()).padStart(2, '0')}`
}

function fullDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getFullYear()}/${String(d.getMonth() + 1).padStart(2, '0')}/${String(d.getDate()).padStart(2, '0')}`
}

function goBack() {
  uni.navigateBack()
}

onLoad((opts) => {
  if (opts?.data) {
    try {
      item.value = JSON.parse(decodeURIComponent(opts.data))
    } catch {}
  }
})

onMounted(async () => {
  if (item.value && !item.value.openedAt) {
    MailApi.open(item.value.id).catch(() => {})
  }
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
  position: relative;
}

.float-nav {
  position: fixed;
  top: 0; left: 0; right: 0;
  padding-top: 50px;
  height: 100px;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  padding-left: 32rpx;
  padding-right: 32rpx;
  padding-bottom: 16rpx;
  z-index: 20;
  box-sizing: border-box;
}

.nav-btn {
  width: 76rpx; height: 76rpx;
  border-radius: 50%;
  background: rgba(20, 15, 10, 0.35);
  border: 1rpx solid rgba(244, 239, 229, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-label {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: rgba(244, 239, 229, 0.9);
  text-shadow: 0 2rpx 12rpx rgba(0,0,0,0.3);
}

.scroll-wrap { height: 100vh; }

.hero-wrap {
  position: relative;
  width: 100%;
  height: 640rpx;
}

.hero-img { width: 100%; height: 100%; }

.hero-placeholder {
  width: 100%; height: 100%;
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.hero-fade {
  position: absolute;
  bottom: 0; left: 0; right: 0;
  height: 160rpx;
  background: linear-gradient(180deg, transparent, $page-background);
}

.postmark {
  position: absolute;
  top: 100rpx; right: 36rpx;
  transform: rotate(-9deg);
  width: 150rpx; height: 150rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.postmark-outer {
  position: absolute;
  width: 150rpx; height: 150rpx;
  border-radius: 50%;
  border: 2rpx solid rgba(244,239,229,0.5);
}

.postmark-inner {
  position: absolute;
  width: 120rpx; height: 120rpx;
  border-radius: 50%;
  border: 2rpx solid rgba(244,239,229,0.8);
}

.postmark-text {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.postmark-city {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 4rpx;
  color: rgba(244,239,229,0.9);
}

.postmark-date {
  font-family: $font-family-serif;
  font-size: 30rpx;
  font-weight: 500;
  color: rgba(244,239,229,0.95);
}

.detail-card-wrap {
  padding: 0 36rpx;
  margin-top: -60rpx;
  position: relative;
  z-index: 5;
}

// Sender strip
.sender-strip {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx 8rpx 0 0;
  padding: 24rpx 24rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.sender-avatar {
  width: 72rpx; height: 72rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.sender-initial {
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: #F4EFE5;
}

.sender-info { flex: 1; }

.sender-name {
  display: block;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
}

.sender-mailbox {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
}

.sent-time { text-align: right; }

.sent-label {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
  margin-bottom: 4rpx;
}

.sent-date {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  color: $body-text;
}

// Postcard back
.pback {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-top: none;
  border-radius: 0 0 8rpx 8rpx;
  overflow: hidden;
  box-shadow: 0 24rpx 64rpx rgba(40,30,15,0.10);
}

.pback-hd {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  padding: 24rpx 24rpx 16rpx;
  gap: 16rpx;
}

.pback-hd-left { flex: 1; }

.pback-title {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 4rpx;
  color: $ink-black;
  margin-bottom: 6rpx;
}

.pback-series {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.pback-stamp {
  width: 80rpx; height: 100rpx;
  border: 1rpx dashed currentColor;
  border-radius: 3rpx;
  background: $page-background;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
  transform: rotate(-2deg);
  flex-shrink: 0;
}

.pback-stamp-dot { font-size: 24rpx; }

.pback-stamp-name {
  font-family: $font-family-mono;
  font-size: 12rpx;
  letter-spacing: 1rpx;
}

.pback-rule { height: 1rpx; background: $line-sepia; margin: 0 24rpx; }

.pback-body {
  display: flex;
  min-height: 260rpx;
  padding: 20rpx 24rpx 16rpx;
}

.pback-message { flex: 1; padding-right: 20rpx; }

.pback-msg-label {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 16rpx;
}

.pback-note {
  display: block;
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 26rpx;
  color: $ink-black;
  line-height: 1.75;
}

.pback-vdivider {
  width: 1rpx;
  background: $line-sepia;
  flex-shrink: 0;
  margin: 0 8rpx;
}

.pback-address {
  width: 200rpx;
  flex-shrink: 0;
  padding-left: 16rpx;
}

.pback-addr-label {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 6rpx;
}

.pback-addr-main {
  display: block;
  font-family: $font-family-serif;
  font-size: 22rpx;
  font-weight: 500;
  color: $ink-black;
  margin-bottom: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pback-addr-sub {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  color: $mute-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pback-addr-sep { height: 1rpx; background: $line-sepia; margin: 12rpx 0; }

.personal-note-wrap { border-top: 1rpx dashed $line-sepia; }

.personal-note { padding: 24rpx; }

.note-label {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 16rpx;
}

.note-content {
  display: block;
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 30rpx;
  color: $ink-black;
  line-height: 1.8;
  margin-bottom: 16rpx;
}

.note-sig {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  text-align: right;
}

.pback-footer {
  display: flex;
  justify-content: space-between;
  padding: 16rpx 24rpx;
  border-top: 1rpx solid $line-sepia;
  background: $paper-beige;
}

.pback-footer-l, .pback-footer-r {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

.btm-gap { height: 120rpx; }
</style>

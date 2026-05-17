<template>
  <view class="page-container" v-if="item">
    <!-- Floating nav -->
    <view class="float-nav">
      <view class="nav-btn" @click="goBack">
        <text class="nav-back-icon">←</text>
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
            <text class="postmark-date">{{ formatDotDate(item.sentAt) }}</text>
          </view>
        </view>
        <view class="hero-fade"></view>
      </view>

      <!-- Card -->
      <view class="detail-card-wrap">
        <!-- Sender/Recipient strip -->
        <view class="sender-strip">
          <view class="sender-avatar" :class="{ 'avatar-sent': isSent }">
            <text class="sender-initial">{{ otherParty.nickname.slice(0, 1) }}</text>
          </view>
          <view class="sender-info">
            <text class="sender-name">{{ isSent ? '→ ' : '' }}{{ otherParty.nickname }}</text>
            <text class="sender-mailbox">{{ otherParty.mailboxNo }}</text>
          </view>
          <view class="sent-time">
            <text class="sent-label">{{ isSent ? 'TO' : 'FROM' }}</text>
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
            <view class="pback-stamp" :style="{ borderColor: getStampColor(item.snapshot.stampDesign) }">
              <image v-if="getStampImageUrl(item.snapshot.stampDesign)" :src="getStampImageUrl(item.snapshot.stampDesign)" class="pback-stamp-img" mode="aspectFill" />
              <text v-else class="pback-stamp-dot" :style="{ color: getStampColor(item.snapshot.stampDesign) }">✦</text>
              <text class="pback-stamp-name" :style="{ color: getStampColor(item.snapshot.stampDesign) }">{{ getStampName(item.snapshot.stampDesign) }}</text>
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
              <text class="pback-addr-main">{{ isSent ? otherParty.nickname : '你' }}</text>
            </view>
          </view>

          <!-- Personal note -->
          <view class="personal-note-wrap" v-if="item.personalNote">
            <view class="pback-rule"></view>
            <view class="personal-note">
              <text class="note-label">PERSONAL NOTE · 个人留言</text>
              <text class="note-content">{{ item.personalNote }}</text>
              <text class="note-sig">— {{ otherParty.nickname }}</text>
            </view>
          </view>

          <view class="pback-footer">
            <text class="pback-footer-l">旅行邮箱 · 寄往远方</text>
            <text class="pback-footer-r">{{ isSent ? sentStatusLabel(item.status) : (item.status === 'opened' ? '已读' : '新信') }}</text>
          </view>
        </view>

        <!-- Action bar -->
        <view class="action-bar">
          <!-- Save to collection (inbox only) -->
          <view
            v-if="!isSent"
            class="action-btn action-save"
            :class="{ 'action-loading': saving }"
            @click="doSave"
          >
            <text class="action-icon">{{ saved ? '✓' : '＋' }}</text>
            <text class="action-txt">{{ saved ? '已存入明信片' : '存入我的明信片' }}</text>
          </view>

          <!-- Delete -->
          <view class="action-btn action-del" @click="doDelete">
            <text class="action-icon del-icon">✕</text>
            <text class="action-txt del-txt">删除</text>
          </view>
        </view>

        <view class="btm-gap"></view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { MailApi, type MailingItem } from '@/services/api'
import { usePostcardStore } from '@/stores/postcard'
import { StampDesigns } from '@/config/app'
import { IconEnvelope } from '@/components/icons'
import { formatDotDate, getStampColor, getStampName, getStampImageUrl } from '@/utils/stamp'

const store = usePostcardStore()

const item   = ref<MailingItem | null>(null)
const isSent = ref(false)
const saving = ref(false)
const saved  = ref(false)

// The "other party" is sender for received mail, recipient for sent mail
const otherParty = computed(() => {
  if (!item.value) return { nickname: '', mailboxNo: '' }
  if (isSent.value) return (item.value as any).recipient
  return item.value.sender
})

function sentStatusLabel(status: string): string {
  if (status === 'opened') return '对方已读'
  if (status === 'delivered') return '已送达'
  return '已寄出'
}

function fullDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getFullYear()}/${String(d.getMonth() + 1).padStart(2, '0')}/${String(d.getDate()).padStart(2, '0')}`
}

async function doSave() {
  if (!item.value || saving.value || saved.value) return
  saving.value = true
  try {
    await MailApi.save(item.value.id)
    saved.value = true
    uni.showToast({ title: '已存入我的明信片 ✓', icon: 'none' })
    // 同步 store，让明信片列表立刻反映新增的记录
    store.syncFromServer().catch(() => {})
  } catch (e: any) {
    uni.showToast({ title: e.message || '保存失败', icon: 'none' })
  } finally {
    saving.value = false
  }
}

function doDelete() {
  if (!item.value) return
  uni.showModal({
    title: '删除邮件',
    content: isSent.value ? '从已发送中删除这封邮件？' : '删除这封来信？',
    confirmColor: '#C62828',
    success: async (res) => {
      if (!res.confirm) return
      try {
        await MailApi.delete(item.value!.id)
        uni.showToast({ title: '已删除', icon: 'none' })
        setTimeout(() => uni.navigateBack(), 600)
      } catch (e: any) {
        uni.showToast({ title: e.message || '删除失败', icon: 'none' })
      }
    },
  })
}

function goBack() {
  uni.navigateBack()
}

onLoad((opts) => {
  if (opts?.data) {
    try {
      const parsed = JSON.parse(decodeURIComponent(opts.data))
      isSent.value = !!parsed.isSent
      delete parsed.isSent
      item.value = parsed
    } catch {}
  }
})

onMounted(async () => {
  if (item.value && !isSent.value && !item.value.openedAt) {
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
  padding-top: calc(72rpx + env(safe-area-inset-top));
  height: calc(140rpx + env(safe-area-inset-top));
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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(244,239,229,0.9);
}

.postmark-date {
  font-family: $font-family-body;
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

  &.avatar-sent {
    background: linear-gradient(135deg, #9C7E5A, #7A6040);
  }
}

.sender-initial {
  font-family: $font-family-body;
  font-size: 32rpx;
  color: #F4EFE5;
}

.sender-info { flex: 1; }

.sender-name {
  display: block;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
}

.sender-mailbox {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
}

.sent-time { text-align: right; }

.sent-label {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  margin-bottom: 4rpx;
}

.sent-date {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $ink-black;
  margin-bottom: 6rpx;
}

.pback-series {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
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

.pback-stamp-img { width: 64rpx; height: 64rpx; border-radius: 2rpx; }

.pback-stamp-dot { font-size: 24rpx; }

.pback-stamp-name {
  font-family: $font-family-code;
  font-size: 22rpx;
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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  margin-bottom: 16rpx;
}

.pback-note {
  display: block;
  font-family: $font-family-body;
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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  margin-bottom: 6rpx;
}

.pback-addr-main {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  font-weight: 500;
  color: $ink-black;
  margin-bottom: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pback-addr-sub {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  margin-bottom: 16rpx;
}

.note-content {
  display: block;
  font-family: $font-family-body;
  font-style: italic;
  font-size: 30rpx;
  color: $ink-black;
  line-height: 1.8;
  margin-bottom: 16rpx;
}

.note-sig {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

// ── Action bar ─────────────────────────────────────────────────────
.action-bar {
  display: flex;
  gap: 16rpx;
  margin: 32rpx 36rpx 0;
}

.action-btn {
  flex: 1;
  height: 88rpx;
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  &:active { opacity: 0.8; }
}

.action-save {
  background: $travel-blue;
  &.action-loading { opacity: 0.6; }
}

.action-icon {
  font-size: 28rpx;
  color: #F4EFE5;
}

.action-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

.action-del {
  background: transparent;
  border: 1rpx solid rgba(198, 40, 40, 0.3);
  flex: 0 0 auto;
  padding: 0 32rpx;
}

.del-icon { color: #C62828; }
.del-txt  { color: #C62828; }

.btm-gap { height: 120rpx; }
</style>

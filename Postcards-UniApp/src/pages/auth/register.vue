<template>
  <view class="page">
    <!-- Header -->
    <view class="header">
      <view class="nav-back" @click="goBack">
        <IconBack :size="20" color="rgba(244,239,229,0.8)" />
      </view>
      <view class="header-brand">
        <text class="brand-title">旅行邮局</text>
        <text class="brand-sub">· TRAVEL POST ·</text>
      </view>
      <text class="header-kicker">REGISTER · 注册</text>
    </view>

    <!-- Success state -->
    <view class="success-card" v-if="registered">
      <view class="success-stamp">
        <text class="success-stamp-icon">✦</text>
      </view>
      <text class="success-title">注册成功</text>
      <text class="success-sub">您的专属邮箱号已分配</text>
      <view class="mailbox-display">
        <text class="mailbox-label">MAILBOX NO.</text>
        <text class="mailbox-value">{{ newMailboxNo }}</text>
      </view>
      <text class="mailbox-tip">请牢记此邮箱号，它是您的登录凭证</text>
      <view class="btn-primary" @click="goHome">
        <text class="btn-txt">开始旅程 →</text>
      </view>
    </view>

    <!-- Form card -->
    <view class="form-card" v-else>
      <view class="form-section-title">
        <text class="section-en">NICKNAME</text>
        <text class="section-cn">昵称</text>
      </view>
      <view class="input-wrap">
        <input
          class="form-input"
          v-model="nickname"
          placeholder="给自己起个旅行昵称"
          :placeholder-style="'color:#B5AE9B'"
          maxlength="12"
        />
      </view>

      <view class="form-section-title" style="margin-top: 36rpx;">
        <text class="section-en">PASSWORD</text>
        <text class="section-cn">密码（至少 6 位）</text>
      </view>
      <view class="input-wrap">
        <input
          class="form-input"
          v-model="password"
          placeholder="请设置登录密码"
          :placeholder-style="'color:#B5AE9B'"
          password
          maxlength="32"
        />
      </view>

      <view class="tip-row">
        <text class="tip-txt">注册后系统自动分配您的专属邮箱号（格式 CN-XXXXXX），用于登录和接收明信片</text>
      </view>

      <view class="btn-primary" :class="{ 'btn-dis': !canSubmit || loading }" @click="doRegister">
        <text class="btn-txt">{{ loading ? '注册中…' : '立即注册' }}</text>
      </view>

      <view class="err-row" v-if="errorMsg">
        <text class="err-txt">{{ errorMsg }}</text>
      </view>
    </view>

    <view class="airmail-bottom"></view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { AuthApi } from '@/services/api'
import { useAuthStore, FREE_STAMP_IDS } from '@/stores/auth'
import { IconBack } from '@/components/icons'

const authStore = useAuthStore()

const nickname    = ref('')
const password    = ref('')
const loading     = ref(false)
const errorMsg    = ref('')
const registered  = ref(false)
const newMailboxNo = ref('')

const canSubmit = computed(() => nickname.value.trim().length >= 1 && password.value.length >= 6)

function goBack() {
  uni.navigateBack()
}

async function doRegister() {
  if (!canSubmit.value || loading.value) return
  loading.value = true
  errorMsg.value = ''
  try {
    const res = await AuthApi.register(nickname.value.trim(), password.value)
    authStore.setSession(
      { id: res.user.id, nickname: res.user.nickname, mailboxNo: res.user.mailboxNo, avatarUrl: res.user.avatarUrl ?? null, points: res.user.points ?? 50 },
      res.accessToken,
      res.refreshToken,
    )
    authStore.setOwnedStamps(FREE_STAMP_IDS) // 注册时自动获得 Series I 全部邮票
    newMailboxNo.value = res.user.mailboxNo
    registered.value = true
  } catch (e: any) {
    errorMsg.value = e.message || '注册失败，请重试'
  } finally {
    loading.value = false
  }
}

function goHome() {
  uni.reLaunch({ url: '/pages/home/home' })
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  background: $page-background;
  display: flex;
  flex-direction: column;
  position: relative;
}

.header {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 100rpx 48rpx 72rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  border-radius: 0 0 64rpx 64rpx;
  position: relative;
}

.nav-back {
  position: absolute;
  top: 56rpx;
  left: 40rpx;
  width: 72rpx;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: rgba(244, 239, 229, 0.12);
}

.header-brand {
  display: flex;
  align-items: baseline;
  gap: 20rpx;
}

.brand-title {
  font-family: $font-family-serif;
  font-size: 72rpx;
  font-weight: 400;
  color: #F4EFE5;
  letter-spacing: 16rpx;
}

.brand-sub {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 6rpx;
  color: rgba(244, 239, 229, 0.65);
}

.header-kicker {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 6rpx;
  color: rgba(244, 239, 229, 0.6);
  margin-top: 8rpx;
}

.form-card {
  margin: 48rpx 40rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 40rpx 36rpx 32rpx;
  box-shadow: 0 8rpx 32rpx rgba(40, 30, 15, 0.08);
}

.form-section-title {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 16rpx;
}

.section-en {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 4rpx;
  color: $travel-blue;
}

.section-cn {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: $mute-text;
}

.input-wrap {
  border-bottom: 1rpx solid $line-sepia;
  padding-bottom: 16rpx;
}

.form-input {
  width: 100%;
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: $ink-black;
  height: 64rpx;
}

.tip-row {
  margin-top: 28rpx;
  padding: 20rpx;
  background: rgba($travel-blue, 0.05);
  border-radius: 6rpx;
  border-left: 3rpx solid rgba($travel-blue, 0.3);
}

.tip-txt {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: $body-text;
  line-height: 1.7;
}

.btn-primary {
  margin-top: 40rpx;
  height: 88rpx;
  background: $travel-blue;
  border-radius: 6rpx;
  display: flex;
  align-items: center;
  justify-content: center;

  &.btn-dis { opacity: 0.45; }
  &:active:not(.btn-dis) { background: $forest-green; }
}

.btn-txt {
  font-family: $font-family-serif;
  font-size: 30rpx;
  letter-spacing: 8rpx;
  color: #F4EFE5;
}

.err-row { margin-top: 20rpx; text-align: center; }
.err-txt {
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $stamp-red;
}

// ── Success state ──
.success-card {
  margin: 48rpx 40rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 56rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  box-shadow: 0 8rpx 32rpx rgba(40, 30, 15, 0.08);
}

.success-stamp {
  width: 120rpx;
  height: 120rpx;
  border-radius: 50%;
  border: 2rpx solid rgba($travel-blue, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8rpx;
}

.success-stamp-icon {
  font-size: 48rpx;
  color: $travel-blue;
}

.success-title {
  font-family: $font-family-serif;
  font-size: 44rpx;
  font-weight: 500;
  color: $ink-black;
}

.success-sub {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

.mailbox-display {
  margin-top: 12rpx;
  padding: 24rpx 40rpx;
  background: $page-background;
  border: 1rpx dashed $line-sepia;
  border-radius: 6rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  width: 100%;
  box-sizing: border-box;
}

.mailbox-label {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 4rpx;
  color: $travel-blue;
}

.mailbox-value {
  font-family: $font-family-mono;
  font-size: 52rpx;
  letter-spacing: 6rpx;
  color: $ink-black;
  font-weight: 600;
}

.mailbox-tip {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: $body-text;
  text-align: center;
  line-height: 1.6;
}

.airmail-bottom {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 12rpx;
  background: repeating-linear-gradient(
    45deg,
    $stamp-red 0, $stamp-red 12rpx,
    transparent 12rpx, transparent 24rpx,
    #1F4B66 24rpx, #1F4B66 36rpx,
    transparent 36rpx, transparent 48rpx
  );
}
</style>

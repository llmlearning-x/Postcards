<template>
  <view class="page">
    <!-- Header -->
    <view class="header">
      <view class="header-brand">
        <text class="brand-title">旅行邮局</text>
        <text class="brand-sub">· TRAVEL POST ·</text>
      </view>
      <text class="header-kicker">SIGN IN · 登录</text>
    </view>

    <!-- Form card -->
    <view class="form-card">
      <view class="form-section-title">
        <text class="section-en">MAILBOX NO.</text>
        <text class="section-cn">邮箱号</text>
      </view>
      <view class="input-wrap">
        <input
          class="form-input"
          v-model="mailboxNo"
          placeholder="CN-XXXXXX"
          :placeholder-style="'color:#B5AE9B;font-family:monospace'"
          maxlength="9"
          @input="onMailboxInput"
        />
      </view>

      <view class="form-section-title" style="margin-top: 36rpx;">
        <text class="section-en">PASSWORD</text>
        <text class="section-cn">密码</text>
      </view>
      <view class="input-wrap">
        <input
          class="form-input"
          v-model="password"
          placeholder="请输入密码"
          :placeholder-style="'color:#B5AE9B'"
          password
          maxlength="32"
        />
      </view>

      <view class="btn-primary" :class="{ 'btn-dis': !canSubmit || loading }" @click="doLogin">
        <text class="btn-txt">{{ loading ? '登录中…' : '登　录' }}</text>
      </view>

      <view class="err-row" v-if="errorMsg">
        <text class="err-txt">{{ errorMsg }}</text>
      </view>
    </view>

    <!-- Register link -->
    <view class="bottom-link">
      <text class="link-text">还没有账号？</text>
      <text class="link-action" @click="goRegister">立即注册 →</text>
    </view>

    <!-- Airmail bottom stripe -->
    <view class="airmail-bottom"></view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { AuthApi, StampApi } from '@/services/api'
import { useAuthStore, FREE_STAMP_IDS } from '@/stores/auth'
import { usePostcardStore } from '@/stores/postcard'

const authStore = useAuthStore()
const postcardStore = usePostcardStore()

const mailboxNo = ref('')
const password  = ref('')
const loading   = ref(false)
const errorMsg  = ref('')

const canSubmit = computed(() => mailboxNo.value.length >= 8 && password.value.length >= 6)

function onMailboxInput(e: any) {
  let v: string = e.detail.value.toUpperCase().replace(/[^A-Z0-9-]/g, '')
  if (v.length > 0 && !v.startsWith('CN-')) {
    v = 'CN-' + v.replace(/^CN-?/, '')
  }
  mailboxNo.value = v.slice(0, 9)
}

async function doLogin() {
  if (!canSubmit.value || loading.value) return
  loading.value = true
  errorMsg.value = ''
  try {
    const res = await AuthApi.login(mailboxNo.value.trim(), password.value)
    authStore.setSession(
      { id: res.user.id, nickname: res.user.nickname, mailboxNo: res.user.mailboxNo, avatarUrl: res.user.avatarUrl ?? null, points: res.user.points ?? 0 },
      res.accessToken,
      res.refreshToken,
    )
    // 先清空旧邮票数据，防止跨用户残留
    authStore.setOwnedStamps([])
    // 并行加载用户数据和邮票列表
    const [, stampRes] = await Promise.allSettled([
      postcardStore.syncFromServer(),
      StampApi.my(),
    ])
    if (stampRes.status === 'fulfilled') {
      authStore.setOwnedStamps(stampRes.value.map(s => s.id))
    } else {
      authStore.setOwnedStamps(FREE_STAMP_IDS)
    }
    uni.switchTab({ url: '/pages/home/home' })
  } catch (e: any) {
    errorMsg.value = e.message || '登录失败，请重试'
  } finally {
    loading.value = false
  }
}

function goRegister() {
  uni.navigateTo({ url: '/pages/auth/register' })
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
  font-family: $font-family-mono;
  font-size: 32rpx;
  letter-spacing: 4rpx;
  color: $ink-black;
  height: 64rpx;
}

.btn-primary {
  margin-top: 52rpx;
  height: 88rpx;
  background: $travel-blue;
  border-radius: 6rpx;
  display: flex;
  align-items: center;
  justify-content: center;

  &.btn-dis {
    opacity: 0.45;
  }

  &:active:not(.btn-dis) {
    background: $forest-green;
  }
}

.btn-txt {
  font-family: $font-family-serif;
  font-size: 30rpx;
  letter-spacing: 8rpx;
  color: #F4EFE5;
}

.err-row {
  margin-top: 20rpx;
  text-align: center;
}

.err-txt {
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $stamp-red;
}

.bottom-link {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  margin-top: 48rpx;
}

.link-text {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $mute-text;
}

.link-action {
  font-family: $font-family-mono;
  font-size: 24rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
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

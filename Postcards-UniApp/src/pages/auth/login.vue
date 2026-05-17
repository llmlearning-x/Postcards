<template>
  <view class="page">
    <!-- Header -->
    <view class="header">
      <view class="header-brand">
        <text class="brand-title">旅行邮箱</text>
        <text class="brand-sub">TRAVEL MAILBOX</text>
      </view>
      <text class="header-kicker">TRAVEL DOSSIER · 登录档案</text>
    </view>

    <!-- Form card -->
    <view class="form-card mailbox-card" :class="{ 'mailbox-card-active': inputFocused, 'mailbox-card-ready': canSubmit }">
      <view class="mailbox-flag">
        <view class="mailbox-flag-pole"></view>
        <view class="mailbox-flag-cloth">
          <text class="mailbox-flag-txt">{{ canSubmit ? 'READY' : 'MAIL' }}</text>
        </view>
      </view>
      <view class="mailbox-lid">
        <view class="mailbox-slot">
          <text class="mailbox-slot-txt">{{ inputFocused ? '正在投递信息' : '把邮箱号和密码投入信箱' }}</text>
        </view>
      </view>
      <view class="mailbox-mouth"></view>
      <view class="form-section-title">
        <text class="section-en">MAILBOX NO.</text>
        <text class="section-cn">邮箱号</text>
      </view>
      <text class="field-help">输入 6 位数字即可，系统会自动补全 CN-</text>
      <view class="input-wrap">
        <input
          class="form-input"
          v-model="mailboxNo"
          placeholder="CN-XXXXXX"
          :placeholder-style="'color:#B5AE9B;font-family:monospace'"
          maxlength="9"
          @input="onMailboxInput"
          @focus="inputFocused = true"
          @blur="inputFocused = false"
        />
      </view>
      <view v-if="lastMailboxNo && !mailboxNo" class="last-mailbox" @click="useLastMailbox">
        <text class="last-mailbox-label">上次登录</text>
        <text class="last-mailbox-value">{{ lastMailboxNo }}</text>
      </view>

      <view class="form-section-title" style="margin-top: 44rpx;">
        <text class="section-en">PASSWORD</text>
        <text class="section-cn">密码</text>
      </view>
      <view class="input-wrap">
        <input
          class="form-input"
          :class="{ 'form-input-with-action': true }"
          v-model="password"
          placeholder="请输入密码"
          :placeholder-style="'color:#B5AE9B'"
          :password="!passwordVisible"
          maxlength="32"
          @focus="inputFocused = true"
          @blur="inputFocused = false"
        />
        <view class="password-toggle" @click="togglePasswordVisible">
          <text class="password-toggle-txt">{{ passwordVisible ? '隐藏' : '显示' }}</text>
        </view>
      </view>

      <view class="btn-primary" :class="{ 'btn-dis': !canSubmit || loading }" @click="doLogin">
        <text class="btn-txt">{{ loading ? '开启中…' : '开启信箱' }}</text>
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
import { StorageUtil } from '@/utils/storage'


const authStore = useAuthStore()
const postcardStore = usePostcardStore()

const LAST_MAILBOX_KEY = 'last_mailbox_no'

const mailboxNo = ref('')
const password  = ref('')
const passwordVisible = ref(false)
const inputFocused = ref(false)
const loading   = ref(false)
const errorMsg  = ref('')
const lastMailboxNo = ref(StorageUtil.get<string>(LAST_MAILBOX_KEY, ''))

const canSubmit = computed(() => mailboxNo.value.length >= 8 && password.value.length >= 6)

function onMailboxInput(e: any) {
  let v: string = e.detail.value.toUpperCase().replace(/[^A-Z0-9-]/g, '')
  if (v.length > 0 && !v.startsWith('CN-')) {
    v = 'CN-' + v.replace(/^CN-?/, '')
  }
  mailboxNo.value = v.slice(0, 9)
}

function useLastMailbox() {
  mailboxNo.value = lastMailboxNo.value
}

function togglePasswordVisible() {
  passwordVisible.value = !passwordVisible.value
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
    // 并行加载用户数据、已拥有邮票、全量邮票列表
    const [, stampRes, allStampsRes] = await Promise.allSettled([
      postcardStore.syncFromServer(),
      StampApi.my(),
      StampApi.all(),
    ])
    if (stampRes.status === 'fulfilled') {
      authStore.setOwnedStamps(stampRes.value.map(s => s.id))
    } else {
      authStore.setOwnedStamps(FREE_STAMP_IDS)
    }
    if (allStampsRes.status === 'fulfilled') {
      authStore.setAllStampUrls(allStampsRes.value)
    }
    StorageUtil.set(LAST_MAILBOX_KEY, res.user.mailboxNo)
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
  overflow: hidden;
}



.header {
  padding: 80rpx 48rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  position: relative;
  z-index: 2;
}

.header-brand {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
}

.brand-title {
  font-family: $font-family-sans;
  font-size: 56rpx;
  font-weight: 500;
  color: $forest-green;
  letter-spacing: 3rpx;
}

.brand-sub {
  font-family: $font-family-action;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: rgba($forest-green, 0.4);
}

.header-kicker {
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: rgba($forest-green, 0.35);
  margin-top: 12rpx;
}

.form-card {
  margin: 64rpx 40rpx 0;
  background: linear-gradient(180deg, #FFFDF7 0%, #F7F0E3 100%);
  border: 3rpx solid $rule-color;
  border-radius: 28rpx 28rpx 16rpx 16rpx;
  padding: 108rpx 36rpx 32rpx;
  box-shadow: $shadow-lg;
  position: relative;
  z-index: 1;
  transition: transform 0.22s ease, box-shadow 0.22s ease;
}

.mailbox-card::before {
  content: '';
  position: absolute;
  left: 28rpx;
  right: 28rpx;
  bottom: -18rpx;
  height: 30rpx;
  border-radius: 0 0 18rpx 18rpx;
  background: rgba(60, 96, 77, 0.14);
  filter: blur(10rpx);
  z-index: -1;
}

.mailbox-card-active {
  transform: translateY(-4rpx);
  box-shadow: 0 28px 64px rgba(40, 30, 15, 0.20), 0 6px 16px rgba(40, 30, 15, 0.12);
}

.mailbox-lid {
  position: absolute;
  left: -3rpx;
  right: -3rpx;
  top: -58rpx;
  height: 148rpx;
  border-radius: 90rpx 90rpx 24rpx 24rpx;
  background: linear-gradient(180deg, #5A7D68 0%, $travel-blue 100%);
  border: 3rpx solid $rule-color;
  border-top: 2rpx solid rgba(255, 255, 255, 0.15);
  box-shadow:
    inset 0 -12rpx 24rpx rgba(0, 0, 0, 0.12),
    0 6rpx 16rpx rgba(40, 30, 15, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
}

.mailbox-slot {
  width: 420rpx;
  height: 56rpx;
  border-radius: 999rpx;
  background: rgba(20, 15, 10, 0.26);
  border: 2rpx solid rgba(244, 239, 229, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: box-shadow 0.22s, background 0.22s;
}

.mailbox-card-active .mailbox-slot {
  background: rgba(244, 239, 229, 0.18);
  box-shadow: 0 0 0 8rpx rgba(244, 239, 229, 0.12), 0 0 28rpx rgba(244, 239, 229, 0.18);
}

.mailbox-slot-txt {
  font-family: $font-family-action;
  font-size: 24rpx;
  color: rgba(244, 239, 229, 0.86);
  letter-spacing: 0;
}

.mailbox-mouth {
  position: absolute;
  left: 72rpx;
  right: 72rpx;
  top: 70rpx;
  height: 10rpx;
  border-radius: 999rpx;
  background: rgba($rule-color, 0.75);
}

.mailbox-flag {
  position: absolute;
  right: -14rpx;
  top: -20rpx;
  width: 92rpx;
  height: 132rpx;
  z-index: 3;
  transform-origin: 54rpx 116rpx;
  transition: transform 0.25s ease;
}

.mailbox-card-ready .mailbox-flag {
  transform: rotate(-18deg) translateY(-12rpx);
}

.mailbox-flag-pole {
  position: absolute;
  right: 20rpx;
  top: 26rpx;
  width: 8rpx;
  height: 104rpx;
  border-radius: 999rpx;
  background: $rule-color;
}

.mailbox-flag-cloth {
  position: absolute;
  right: 24rpx;
  top: 18rpx;
  min-width: 66rpx;
  height: 40rpx;
  padding: 0 12rpx;
  border-radius: 10rpx 4rpx 4rpx 10rpx;
  background: $stamp-red;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 6rpx 16rpx rgba(40, 30, 15, 0.18);
}

.mailbox-flag-txt {
  font-family: $font-family-action;
  font-size: 18rpx;
  color: #FFFDF7;
  font-weight: 500;
}

.form-section-title {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 16rpx;
}

.section-en {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.section-cn {
  font-family: $font-family-label;
  font-size: 24rpx;
  color: $mute-text;
}

.input-wrap {
  border-bottom: 2rpx solid rgba($line-sepia, 0.85);
  padding-bottom: 14rpx;
  display: flex;
  align-items: center;
  gap: 14rpx;
}

.field-help {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  margin: -4rpx 0 14rpx;
  line-height: 1.5;
}

.form-input {
  flex: 1;
  min-width: 0;
  font-family: $font-family-code;
  font-size: 32rpx;
  letter-spacing: 2rpx;
  color: $ink-black;
  height: 64rpx;
}

.form-input-with-action {
  font-family: $font-family-body;
  letter-spacing: 0;
}

.password-toggle {
  height: 56rpx;
  padding: 0 14rpx;
  border-radius: 999rpx;
  background: rgba($travel-blue, 0.08);
  display: flex;
  align-items: center;
  gap: 6rpx;
  flex-shrink: 0;

  &:active { background: rgba($travel-blue, 0.14); }
}

.password-toggle-txt {
  font-family: $font-family-action;
  font-size: 22rpx;
  color: $mute-text;
}

.last-mailbox {
  margin-top: 18rpx;
  display: inline-flex;
  align-items: center;
  gap: 12rpx;
  padding: 10rpx 18rpx;
  border: 1rpx solid rgba($travel-blue, 0.25);
  border-radius: 999rpx;
  background: rgba($travel-blue, 0.05);
  align-self: flex-start;
}

.last-mailbox-label {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
}

.last-mailbox-value {
  font-family: $font-family-code;
  font-size: 24rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.btn-primary {
  margin-top: 48rpx;
  height: 88rpx;
  background: $forest-green;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;

  &.btn-dis {
    opacity: 0.4;
  }

  &:active:not(.btn-dis) {
    background: $travel-blue;
  }
}

.btn-txt {
  font-family: $font-family-action;
  font-size: 30rpx;
  letter-spacing: 2rpx;
  color: #F4EFE5;
}

.err-row {
  margin-top: 20rpx;
  text-align: center;
}

.err-txt {
  font-family: $font-family-body;
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
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
}

.link-action {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
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

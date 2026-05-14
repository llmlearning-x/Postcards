<template>
  <view class="page-container">
    <!-- Header -->
    <view class="page-header">
      <view class="nav-back" @click="goBack">
        <IconBack :size="20" color="#F4EFE5" />
      </view>
      <view class="header-center">
        <text class="header-kicker">MAIL · 寄出</text>
        <text class="header-title">寄明信片</text>
      </view>
      <view style="width: 64rpx;"></view>
    </view>

    <scroll-view class="content" scroll-y>

      <!-- ── Mode A: postcardId given, pick recipient ── -->
      <template v-if="mode === 'pick-recipient'">
        <!-- Postcard preview strip -->
        <view class="postcard-preview" v-if="postcard">
          <view class="preview-stamp-dot" :style="{ background: getStampColor(postcard.stampDesign) }"></view>
          <view class="preview-info">
            <text class="preview-loc">{{ postcard.locationName }}</text>
            <text class="preview-sub">{{ postcard.city }} · {{ postcard.country }}</text>
          </view>
          <text class="preview-tag">即将寄出</text>
        </view>

        <!-- Step 1: Search recipient -->
        <view class="section" v-if="!recipient">
          <view class="section-hd">
            <text class="section-kicker">RECIPIENT · 收件人</text>
            <view class="section-rule"></view>
          </view>

          <view class="search-wrap">
            <view class="search-bar">
              <IconSearch :size="20" color="#B5AE9B" />
              <input
                class="search-input"
                v-model="searchQ"
                placeholder="输入邮箱号 CN-XXXXXX 或昵称"
                :placeholder-style="'color:#B5AE9B'"
                @input="onSearchInput"
              />
              <text class="search-clear" v-if="searchQ" @click="searchQ = ''; searchResults = []">✕</text>
            </view>
          </view>

          <view class="search-results" v-if="searchResults.length > 0">
            <view
              v-for="u in searchResults"
              :key="u.id"
              class="user-row"
              @click="selectRecipient(u)"
            >
              <view class="user-avatar">
                <text class="user-initial">{{ u.nickname.slice(0, 1) }}</text>
              </view>
              <view class="user-info">
                <text class="user-name">{{ u.nickname }}</text>
                <text class="user-mailbox">{{ u.mailboxNo }}</text>
              </view>
              <text class="user-select-arr">›</text>
            </view>
          </view>

          <view class="search-empty" v-if="searchQ.length >= 3 && searchResults.length === 0 && !searching">
            <text class="search-empty-txt">未找到匹配用户</text>
          </view>
        </view>

        <!-- Step 2: Compose note -->
        <view class="section" v-if="recipient">
          <view class="section-hd">
            <text class="section-kicker">RECIPIENT · 收件人</text>
            <view class="section-rule"></view>
          </view>

          <view class="selected-recipient">
            <view class="user-avatar">
              <text class="user-initial">{{ recipient.nickname.slice(0, 1) }}</text>
            </view>
            <view class="user-info">
              <text class="user-name">{{ recipient.nickname }}</text>
              <text class="user-mailbox">{{ recipient.mailboxNo }}</text>
            </view>
            <text class="change-btn" @click="recipient = null">更换</text>
          </view>

          <view class="section-hd" style="margin-top: 40rpx;">
            <text class="section-kicker">NOTE · 留言（选填）</text>
            <view class="section-rule"></view>
          </view>
          <view class="note-card">
            <textarea
              class="note-input"
              v-model="personalNote"
              placeholder="写一句想对 TA 说的话…"
              :placeholder-style="'color:#B5AE9B; font-family: serif'"
              maxlength="100"
              :auto-height="true"
            />
            <text class="note-count">{{ personalNote.length }}/100</text>
          </view>

          <view class="action-btn" :class="{ 'action-dis': sending }" @click="doSend">
            <IconSend :size="24" color="#F4EFE5" />
            <text class="action-btn-txt">{{ sending ? '寄出中…' : '寄　出' }}</text>
          </view>
        </view>
      </template>

      <!-- ── Mode B: recipientId given, pick postcard ── -->
      <template v-else>
        <!-- Fixed recipient card -->
        <view class="section">
          <view class="section-hd">
            <text class="section-kicker">RECIPIENT · 收件人</text>
            <view class="section-rule"></view>
          </view>
          <view class="selected-recipient">
            <view class="user-avatar">
              <text class="user-initial">{{ recipient!.nickname.slice(0, 1) }}</text>
            </view>
            <view class="user-info">
              <text class="user-name">{{ recipient!.nickname }}</text>
              <text class="user-mailbox">{{ recipient!.mailboxNo }}</text>
            </view>
            <text class="recipient-tag">来自通讯录</text>
          </view>
        </view>

        <!-- Pick postcard -->
        <view class="section" v-if="!postcard">
          <view class="section-hd" style="margin-top: 8rpx;">
            <text class="section-kicker">POSTCARD · 选择明信片</text>
            <view class="section-rule"></view>
          </view>

          <view class="pc-empty" v-if="allPostcards.length === 0">
            <text class="pc-empty-txt">你还没有记录过明信片，先去记录一张吧</text>
          </view>

          <view class="pc-list" v-else>
            <view
              v-for="pc in allPostcards"
              :key="pc.id"
              class="pc-row"
              @click="postcard = pc"
            >
              <view class="pc-stamp" :style="{ background: getStampColor(pc.stampDesign) }"></view>
              <view class="pc-info">
                <text class="pc-loc">{{ pc.locationName }}</text>
                <text class="pc-sub">{{ pc.city }} · {{ pc.country }}</text>
              </view>
              <text class="pc-arr">›</text>
            </view>
          </view>
        </view>

        <!-- Postcard selected → compose note -->
        <view class="section" v-if="postcard">
          <view class="section-hd" style="margin-top: 8rpx;">
            <text class="section-kicker">POSTCARD · 明信片</text>
            <view class="section-rule"></view>
          </view>
          <view class="postcard-preview">
            <view class="preview-stamp-dot" :style="{ background: getStampColor(postcard.stampDesign) }"></view>
            <view class="preview-info">
              <text class="preview-loc">{{ postcard.locationName }}</text>
              <text class="preview-sub">{{ postcard.city }} · {{ postcard.country }}</text>
            </view>
            <text class="change-btn" @click="postcard = null">更换</text>
          </view>

          <view class="section-hd" style="margin-top: 40rpx;">
            <text class="section-kicker">NOTE · 留言（选填）</text>
            <view class="section-rule"></view>
          </view>
          <view class="note-card">
            <textarea
              class="note-input"
              v-model="personalNote"
              placeholder="写一句想对 TA 说的话…"
              :placeholder-style="'color:#B5AE9B; font-family: serif'"
              maxlength="100"
              :auto-height="true"
            />
            <text class="note-count">{{ personalNote.length }}/100</text>
          </view>

          <view class="action-btn" :class="{ 'action-dis': sending }" @click="doSend">
            <IconSend :size="24" color="#F4EFE5" />
            <text class="action-btn-txt">{{ sending ? '寄出中…' : '寄　出' }}</text>
          </view>
        </view>
      </template>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { UserApi, MailApi, type ApiUser } from '@/services/api'
import { usePostcardStore } from '@/stores/postcard'
import { StampDesigns } from '@/config/app'
import type { Postcard } from '@/model/Postcard'
import { IconBack, IconSearch, IconSend } from '@/components/icons'
import { getStampColor } from '@/utils/stamp'

const store = usePostcardStore()

// 'pick-recipient' = came from postcard detail (postcardId given)
// 'pick-postcard'  = came from contacts (recipientId given)
const mode = ref<'pick-recipient' | 'pick-postcard'>('pick-recipient')

const postcardId   = ref('')
const postcard     = ref<Postcard | null>(null)
const searchQ      = ref('')
const searching    = ref(false)
const searchResults = ref<ApiUser[]>([])
const recipient    = ref<ApiUser | null>(null)
const personalNote = ref('')
const sending      = ref(false)

const allPostcards = computed(() => store.postcards)

let searchTimer: ReturnType<typeof setTimeout> | null = null

function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  if (searchQ.value.trim().length < 3) { searchResults.value = []; return }
  searchTimer = setTimeout(doSearch, 400)
}

async function doSearch() {
  searching.value = true
  try {
    searchResults.value = await UserApi.search(searchQ.value.trim())
  } catch {
    searchResults.value = []
  } finally {
    searching.value = false
  }
}

function selectRecipient(u: ApiUser) {
  recipient.value = u
  searchResults.value = []
}

async function doSend() {
  if (!postcard.value || !recipient.value || sending.value) return
  sending.value = true
  try {
    await MailApi.send(postcard.value.id, recipient.value.id, personalNote.value.trim() || undefined)
    uni.showToast({ title: '已寄出！', icon: 'success' })
    setTimeout(() => uni.navigateBack(), 1500)
  } catch (e: any) {
    uni.showToast({ title: e.message || '寄出失败', icon: 'none' })
    sending.value = false
  }
}

function goBack() {
  uni.navigateBack()
}

onLoad((opts) => {
  if (opts?.postcardId) {
    postcardId.value = opts.postcardId
    mode.value = 'pick-recipient'
  } else if (opts?.recipientId) {
    mode.value = 'pick-postcard'
    recipient.value = {
      id:        opts.recipientId,
      nickname:  decodeURIComponent(opts.recipientNickname || ''),
      mailboxNo: decodeURIComponent(opts.recipientMailboxNo || ''),
      avatarUrl: null,
    }
  }
})

onMounted(() => {
  store.initData()
  if (postcardId.value) {
    postcard.value = store.getPostcardById(postcardId.value) || null
  }
})
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

.postcard-preview {
  margin: 28rpx 40rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 20rpx 24rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.preview-stamp-dot {
  width: 16rpx; height: 16rpx;
  border-radius: 50%;
  flex-shrink: 0;
}

.preview-info { flex: 1; }

.preview-loc {
  display: block;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
}

.preview-sub {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.preview-tag {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.section { margin: 32rpx 40rpx 0; }

.section-hd {
  display: flex;
  align-items: center;
  gap: 16rpx;
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

.search-wrap { margin-bottom: 16rpx; }

.search-bar {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 20rpx 24rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.search-input {
  flex: 1;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  height: 48rpx;
}

.search-clear {
  font-family: $font-family-mono;
  font-size: 24rpx;
  color: $mute-text;
}

.search-results {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
}

.user-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx;
  border-bottom: 1rpx solid $line-sepia;

  &:last-child { border-bottom: none; }
  &:active { background: rgba($travel-blue, 0.04); }
}

.user-avatar {
  width: 72rpx; height: 72rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-initial {
  font-family: $font-family-serif;
  font-size: 30rpx;
  color: #F4EFE5;
}

.user-info { flex: 1; }

.user-name {
  display: block;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 6rpx;
}

.user-mailbox {
  display: block;
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
}

.user-select-arr {
  font-family: $font-family-serif;
  font-size: 40rpx;
  color: $mute-text;
}

.search-empty {
  padding: 40rpx;
  text-align: center;
}

.search-empty-txt {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $mute-text;
}

.selected-recipient {
  background: $card-bg;
  border: 1rpx solid rgba($travel-blue, 0.3);
  border-radius: 8rpx;
  padding: 24rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.change-btn {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.note-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 24rpx;
  position: relative;
}

.note-input {
  width: 100%;
  min-height: 120rpx;
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.75;
}

.note-count {
  display: block;
  text-align: right;
  font-family: $font-family-mono;
  font-size: 18rpx;
  color: $mute-text;
  margin-top: 12rpx;
}

.action-btn {
  margin-top: 48rpx;
  height: 96rpx;
  background: $travel-blue;
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16rpx;

  &.action-dis { opacity: 0.55; }
  &:active:not(.action-dis) { background: $forest-green; }
}

.action-btn-txt {
  font-family: $font-family-serif;
  font-size: 32rpx;
  letter-spacing: 8rpx;
  color: #F4EFE5;
}

.recipient-tag {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  padding: 4rpx 12rpx;
  border: 1rpx solid rgba($travel-blue, 0.4);
  border-radius: 4rpx;
}

.pc-empty {
  padding: 40rpx 0;
  text-align: center;
}

.pc-empty-txt {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $mute-text;
  line-height: 1.6;
}

.pc-list {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
}

.pc-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx;
  border-bottom: 1rpx solid $line-sepia;

  &:last-child { border-bottom: none; }
  &:active { background: rgba($travel-blue, 0.04); }
}

.pc-stamp {
  width: 16rpx; height: 16rpx;
  border-radius: 50%;
  flex-shrink: 0;
}

.pc-info { flex: 1; min-width: 0; }

.pc-loc {
  display: block;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pc-sub {
  display: block;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.pc-arr {
  font-family: $font-family-serif;
  font-size: 40rpx;
  color: $mute-text;
}

.btm-gap { height: 120rpx; }
</style>

<template>
  <view class="page-container">
    <!-- Header -->
    <view class="postal-header">
      <view class="header-perf"></view>
      <view class="nav-back" @click="goBack">
        <IconBack :size="18" color="rgba(255,255,255,0.9)" />
      </view>
      <text class="header-kicker">BULLETIN BOARD · 公告栏</text>
      <text class="header-title">旅行公告栏</text>
    </view>

    <scroll-view class="content" scroll-y @scrolltolower="loadMore">

      <!-- Loading skeleton -->
      <view class="card-grid" v-if="loading && cards.length === 0">
        <view v-for="i in 6" :key="i" class="skeleton-card shimmer"></view>
      </view>

      <!-- Empty -->
      <view class="empty-state" v-else-if="!loading && cards.length === 0">
        <text class="empty-icon">✉</text>
        <text class="empty-title">公告栏还没有内容</text>
        <text class="empty-sub">在明信片详情页将你的明信片投入公告栏，让其他旅行者看到</text>
      </view>

      <!-- Card grid -->
      <view class="card-grid" v-else>
        <view
          v-for="card in cards"
          :key="card.id"
          class="board-card"
          @click="openCard(card)"
        >
          <!-- Photo area -->
          <view class="card-photo">
            <image
              v-if="card.photoUrl"
              :src="card.photoUrl"
              class="card-photo-img"
              mode="aspectFill"
              lazy-load
            />
            <view v-else class="card-photo-grad"></view>
            <!-- Postmark overlay -->
            <view class="card-postmark">
              <text class="card-pm-city">{{ card.city.slice(0, 4).toUpperCase() }}</text>
            </view>
          </view>

          <!-- Card back strip -->
          <view class="card-back">
            <view class="card-back-top">
              <!-- Author avatar -->
              <view class="author-avatar">
                <text class="author-initial">{{ card.author.nickname.slice(0, 1) }}</text>
              </view>
              <!-- Stamp badge -->
              <view class="stamp-badge" :style="{ borderColor: getStampColor(card.stampDesign) }">
                <image
                  v-if="getStampImageUrl(card.stampDesign)"
                  :src="getStampImageUrl(card.stampDesign)"
                  class="stamp-badge-img"
                  mode="aspectFill"
                />
                <view v-else class="stamp-badge-dot" :style="{ background: getStampColor(card.stampDesign) }"></view>
              </view>
            </view>

            <text class="card-loc">{{ card.locationName }}</text>
            <text class="card-city">{{ card.city }}</text>

            <!-- Footer: stamp count -->
            <view class="card-footer">
              <view
                class="stamp-btn"
                :class="{ 'stamp-btn-active': stampedIds.has(card.id) }"
                @click.stop="doStamp(card)"
              >
                <text class="stamp-icon">✦</text>
                <text class="stamp-count">{{ card.stampCount }}</text>
              </view>
              <text class="card-mailbox">{{ card.author.mailboxNo }}</text>
            </view>
          </view>
        </view>
      </view>

      <!-- Load more spinner -->
      <view class="load-more" v-if="loadingMore">
        <text class="load-more-txt">加载中…</text>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>

    <!-- Detail modal -->
    <view class="modal-mask" v-if="activeCard" @click="activeCard = null">
      <view class="modal-card" @click.stop>
        <!-- Photo -->
        <view class="modal-photo">
          <image
            v-if="activeCard.photoUrl"
            :src="activeCard.photoUrl"
            class="modal-photo-img"
            mode="aspectFill"
          />
          <view v-else class="modal-photo-grad"></view>
          <view class="modal-photo-fade"></view>
          <!-- Postmark -->
          <view class="modal-postmark" style="transform: rotate(-8deg);">
            <text class="modal-pm-city">{{ activeCard.city.slice(0, 4).toUpperCase() }}</text>
            <text class="modal-pm-date">{{ formatDate(activeCard.recordedAt) }}</text>
          </view>
        </view>

        <!-- Postcard back -->
        <view class="modal-body">
          <!-- Sender -->
          <view class="modal-sender">
            <view class="modal-avatar">
              <text class="modal-initial">{{ activeCard.author.nickname.slice(0, 1) }}</text>
            </view>
            <view class="modal-sender-info">
              <text class="modal-nickname">{{ activeCard.author.nickname }}</text>
              <text class="modal-mailbox">{{ activeCard.author.mailboxNo }}</text>
            </view>
            <view class="modal-stamp-wrap" :style="{ borderColor: getStampColor(activeCard.stampDesign) }">
              <image
                v-if="getStampImageUrl(activeCard.stampDesign)"
                :src="getStampImageUrl(activeCard.stampDesign)"
                class="modal-stamp-img"
                mode="aspectFill"
              />
              <view v-else class="modal-stamp-dot" :style="{ background: getStampColor(activeCard.stampDesign) }"></view>
            </view>
          </view>

          <view class="modal-rule"></view>

          <!-- Location & note -->
          <text class="modal-loc">{{ activeCard.locationName }}</text>
          <text class="modal-city">{{ activeCard.city }} · {{ activeCard.country }}</text>
          <text class="modal-note" v-if="activeCard.note">"{{ activeCard.note }}"</text>

          <view class="modal-rule" style="margin-top: 24rpx;"></view>

          <!-- Actions -->
          <view class="modal-actions">
            <view
              class="modal-stamp-btn"
              :class="{ 'modal-stamp-active': stampedIds.has(activeCard.id) }"
              @click="doStamp(activeCard)"
            >
              <text class="modal-stamp-icon">✦</text>
              <text class="modal-stamp-txt">{{ stampedIds.has(activeCard.id) ? '已盖章' : '盖章' }} · {{ activeCard.stampCount }}</text>
            </view>

            <view
              v-if="!activeCard.author.isContact && activeCard.author.id !== selfId"
              class="modal-add-btn"
              @click="addContact(activeCard)"
            >
              <text class="modal-add-txt">+ 加为联系人</text>
            </view>
            <view v-else-if="activeCard.author.isContact" class="modal-added-tag">
              <text class="modal-added-txt">✓ 已是联系人</text>
            </view>
          </view>
        </view>

        <text class="modal-close" @click="activeCard = null">关闭</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { PostcardApi, ContactsApi, type BoardPostcard } from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import { IconBack } from '@/components/icons'
import { getStampColor, getStampImageUrl } from '@/utils/stamp'

const authStore  = ref(useAuthStore())
const selfId     = authStore.value.user?.id ?? ''

const cards      = ref<BoardPostcard[]>([])
const loading    = ref(true)
const loadingMore = ref(false)
const page       = ref(1)
const hasMore    = ref(true)
const stampedIds = ref<Set<string>>(new Set())
const activeCard = ref<BoardPostcard | null>(null)

const MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
function formatDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getDate()} ${MONTHS[d.getMonth()]}`
}

async function loadBoard(reset = false) {
  if (reset) {
    page.value   = 1
    hasMore.value = true
    cards.value  = []
    loading.value = true
  }
  try {
    const data = await PostcardApi.board(page.value)
    if (data.length < 20) hasMore.value = false
    cards.value = reset ? data : [...cards.value, ...data]
  } catch {
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value    = false
    loadingMore.value = false
  }
}

async function loadMore() {
  if (!hasMore.value || loadingMore.value || loading.value) return
  loadingMore.value = true
  page.value++
  await loadBoard()
}

function openCard(card: BoardPostcard) {
  activeCard.value = card
}

async function doStamp(card: BoardPostcard) {
  if (stampedIds.value.has(card.id)) return
  try {
    const res = await PostcardApi.stamp(card.id)
    card.stampCount = res.stampCount
    stampedIds.value = new Set([...stampedIds.value, card.id])
    if (activeCard.value?.id === card.id) {
      activeCard.value = { ...activeCard.value, stampCount: res.stampCount }
    }
  } catch {
    uni.showToast({ title: '盖章失败', icon: 'none' })
  }
}

async function addContact(card: BoardPostcard) {
  try {
    await ContactsApi.add(card.author.id)
    card.author.isContact = true
    if (activeCard.value?.id === card.id) {
      activeCard.value = { ...activeCard.value, author: { ...activeCard.value.author, isContact: true } }
    }
    uni.showToast({ title: '已添加为联系人', icon: 'success' })
  } catch (e: any) {
    uni.showToast({ title: e.message || '添加失败', icon: 'none' })
  }
}

function goBack() {
  uni.navigateBack()
}

onShow(() => loadBoard(true))
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
}

.postal-header {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 100rpx 48rpx 20rpx;
  position: relative;
  flex-shrink: 0;
}
.header-perf {
  position: absolute; bottom: 0; left: 0; right: 0; height: 6rpx;
  background: repeating-linear-gradient(-45deg, #B8312A 0, #B8312A 5rpx, #ffffff 5rpx, #ffffff 10rpx, #1C3A72 10rpx, #1C3A72 15rpx, #ffffff 15rpx, #ffffff 20rpx);
}
.nav-back {
  position: absolute; top: 52rpx; left: 48rpx;
  width: 64rpx; height: 64rpx;
  display: flex; align-items: center; justify-content: center;
}
.header-kicker {
  display: block; font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 2rpx; color: rgba(255,255,255,0.65); margin-bottom: 12rpx;
}
.header-title {
  display: block; font-family: $font-family-body;
  font-size: 46rpx; font-weight: 700; color: rgba(255,255,255,0.95); line-height: 1.15; letter-spacing: 0;
}

.perf-line {
  display: flex;
  padding: 10rpx 24rpx;
  background: $card-bg;
  border-bottom: 1rpx solid $line-sepia;
}

.perf-hole {
  flex: 1; height: 16rpx;
  border-radius: 50%;
  border: 1rpx solid $line-sepia;
  background: $page-background;
  margin: 0 4rpx;
}

.content { height: calc(100vh - 220rpx); }

// ── Grid ──
.card-grid {
  padding: 24rpx 24rpx 0;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20rpx;
}

// ── Board card ──
.board-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
  box-shadow: 0 4rpx 16rpx rgba(40,30,15,0.08);
  &:active { opacity: 0.92; }
}

.card-photo {
  width: 100%;
  height: 220rpx;
  position: relative;
  overflow: hidden;
}

.card-photo-img { width: 100%; height: 100%; }

.card-photo-grad {
  width: 100%; height: 100%;
  background: linear-gradient(135deg, #C9D2B6 0%, #3C604D 100%);
}

.card-postmark {
  position: absolute;
  top: 12rpx; right: 12rpx;
  background: rgba(20,15,10,0.5);
  border: 1rpx solid rgba(244,239,229,0.4);
  border-radius: 4rpx;
  padding: 4rpx 10rpx;
}

.card-pm-city {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(244,239,229,0.9);
}

.card-back {
  padding: 16rpx 16rpx 14rpx;
}

.card-back-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10rpx;
}

.author-avatar {
  width: 40rpx; height: 40rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex; align-items: center; justify-content: center;
}

.author-initial {
  font-family: $font-family-body;
  font-size: 22rpx;
  color: #F4EFE5;
}

.stamp-badge {
  width: 36rpx; height: 36rpx;
  border: 1rpx solid currentColor;
  border-radius: 2rpx;
  overflow: hidden;
  background: $paper-beige;
}

.stamp-badge-img { width: 100%; height: 100%; }
.stamp-badge-dot { width: 100%; height: 100%; opacity: 0.8; }

.card-loc {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 2rpx;
}

.card-city {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 12rpx;
}

.card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.stamp-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  padding: 4rpx 10rpx;
  border-radius: 4rpx;
  border: 1rpx solid $line-sepia;
  background: transparent;
  &:active { opacity: 0.7; }
}

.stamp-btn-active {
  background: rgba($travel-blue, 0.1);
  border-color: $travel-blue;
  .stamp-icon, .stamp-count { color: $travel-blue; }
}

.stamp-icon {
  font-size: 22rpx;
  color: $mute-text;
}

.stamp-count {
  font-family: $font-family-code;
  font-size: 22rpx;
  color: $mute-text;
}

.card-mailbox {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  opacity: 0.6;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

// ── Skeleton ──
.skeleton-card {
  height: 360rpx;
  border-radius: 8rpx;
  background: $line-sepia;
  opacity: 0.35;
}

.shimmer {
  background: linear-gradient(90deg, $line-sepia 25%, #E8E0D0 50%, $line-sepia 75%);
  background-size: 200% 100%;
  animation: shimmer 1.4s infinite;
}

@keyframes shimmer {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

// ── Empty ──
.empty-state {
  padding: 120rpx 60rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.empty-icon { font-size: 80rpx; color: $mute-text; opacity: 0.4; }

.empty-title {
  font-family: $font-family-body;
  font-size: 30rpx;
  color: $body-text;
}

.empty-sub {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  text-align: center;
  line-height: 1.7;
}

// ── Load more ──
.load-more {
  padding: 32rpx;
  text-align: center;
}

.load-more-txt {
  font-family: $font-family-body;
  font-style: italic;
  font-size: 24rpx;
  color: $mute-text;
}

// ── Detail modal ──
.modal-mask {
  position: fixed;
  inset: 0;
  background: rgba(12,9,5,0.85);
  z-index: 999;
  display: flex;
  align-items: flex-end;
  justify-content: center;
  animation: fade-in 0.2s ease;
}

@keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }

.modal-card {
  width: 100%;
  max-height: 90vh;
  background: $page-background;
  border-radius: 32rpx 32rpx 0 0;
  overflow: hidden;
  animation: slide-up 0.28s cubic-bezier(0.34,1.56,0.64,1);
  display: flex;
  flex-direction: column;
}

@keyframes slide-up {
  from { transform: translateY(100%); }
  to   { transform: translateY(0); }
}

.modal-photo {
  width: 100%;
  height: 460rpx;
  position: relative;
  flex-shrink: 0;
}

.modal-photo-img { width: 100%; height: 100%; }

.modal-photo-grad {
  width: 100%; height: 100%;
  background: linear-gradient(165deg, $travel-blue, $forest-green);
}

.modal-photo-fade {
  position: absolute;
  bottom: 0; left: 0; right: 0;
  height: 200rpx;
  background: linear-gradient(transparent, $page-background);
}

.modal-postmark {
  position: absolute;
  top: 24rpx; right: 32rpx;
  background: rgba(20,15,10,0.45);
  border: 1rpx solid rgba(244,239,229,0.5);
  border-radius: 6rpx;
  padding: 8rpx 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.modal-pm-city {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: rgba(244,239,229,0.9);
}

.modal-pm-date {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: rgba(244,239,229,0.95);
}

.modal-body {
  padding: 0 40rpx 24rpx;
  margin-top: -40rpx;
  position: relative;
  z-index: 2;
  overflow-y: auto;
}

.modal-sender {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.modal-avatar {
  width: 64rpx; height: 64rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
  border: 3rpx solid $page-background;
}

.modal-initial {
  font-family: $font-family-body;
  font-size: 28rpx;
  color: #F4EFE5;
}

.modal-sender-info { flex: 1; }

.modal-nickname {
  display: block;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
}

.modal-mailbox {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.modal-stamp-wrap {
  width: 56rpx; height: 72rpx;
  border: 1rpx dashed currentColor;
  border-radius: 3rpx;
  background: $paper-beige;
  display: flex; align-items: center; justify-content: center;
  overflow: hidden;
  flex-shrink: 0;
  transform: rotate(-3deg);
}

.modal-stamp-img { width: 100%; height: 100%; }
.modal-stamp-dot { width: 100%; height: 100%; opacity: 0.7; }

.modal-rule {
  height: 1rpx;
  background: $line-sepia;
  margin-bottom: 20rpx;
}

.modal-loc {
  display: block;
  font-family: $font-family-body;
  font-size: 36rpx;
  color: $ink-black;
  margin-bottom: 6rpx;
}

.modal-city {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  margin-bottom: 16rpx;
}

.modal-note {
  display: block;
  font-family: $font-family-body;
  font-style: italic;
  font-size: 26rpx;
  color: $body-text;
  line-height: 1.7;
}

// ── Modal actions ──
.modal-actions {
  display: flex;
  gap: 16rpx;
  align-items: center;
  margin-top: 8rpx;
}

.modal-stamp-btn {
  display: flex;
  align-items: center;
  gap: 10rpx;
  height: 72rpx;
  padding: 0 28rpx;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  background: $card-bg;
  flex-shrink: 0;
  &:active { opacity: 0.8; }
}

.modal-stamp-active {
  background: rgba($travel-blue, 0.08);
  border-color: $travel-blue;
  .modal-stamp-icon, .modal-stamp-txt { color: $travel-blue; }
}

.modal-stamp-icon { font-size: 24rpx; color: $mute-text; }

.modal-stamp-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
}

.modal-add-btn {
  flex: 1;
  height: 72rpx;
  background: $travel-blue;
  border-radius: 8rpx;
  display: flex; align-items: center; justify-content: center;
  &:active { opacity: 0.85; }
}

.modal-add-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

.modal-added-tag {
  flex: 1;
  height: 72rpx;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  display: flex; align-items: center; justify-content: center;
}

.modal-added-txt {
  font-family: $font-family-code;
  font-size: 24rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.modal-close {
  display: block;
  text-align: center;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  padding: 16rpx 0 32rpx;
  flex-shrink: 0;
}

.btm-gap { height: 80rpx; }
</style>

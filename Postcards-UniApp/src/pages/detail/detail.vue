<template>
  <view class="page-container" v-if="postcard">
    <!-- Floating nav over hero photo -->
    <view class="float-nav">
      <view class="nav-btn" @click="goBack">
        <IconBack :size="20" color="#F4EFE5" />
      </view>
      <text class="nav-label">POSTCARD · 明信片</text>
      <view class="nav-btn" @click="showMoreOptions">
        <IconMore :size="20" color="#F4EFE5" />
      </view>
    </view>

    <scroll-view class="scroll-wrap" scroll-y>
      <!-- Full-bleed hero photo -->
      <view class="hero-wrap">
        <image
          v-if="postcard.photoUrl"
          :src="postcard.photoUrl"
          class="hero-img"
          mode="aspectFill"
          @click="previewImage"
        />
        <view v-else class="hero-placeholder">
          <IconImage :size="80" color="#B5AE9B" />
        </view>
        <!-- Postmark badge -->
        <view class="postmark">
          <view class="postmark-outer"></view>
          <view class="postmark-inner"></view>
          <view class="postmark-text">
            <text class="postmark-city">{{ postcard.city.toUpperCase() }}</text>
            <text class="postmark-date">{{ formatDotDate(postcard.recordedAt) }}</text>
            <text class="postmark-year">{{ yearStr(postcard.recordedAt) }}</text>
          </view>
        </view>
        <!-- Gradient fade at bottom -->
        <view class="hero-fade"></view>
      </view>

      <!-- Content card overlapping photo -->
      <view class="detail-card-wrap" :class="{ 'card-revealed': cardRevealed }">
        <!-- ── Postcard back ── -->
        <view class="pback">
          <!-- Header bar -->
          <view class="pback-hd">
            <view class="pback-hd-left">
              <text class="pback-title">POST CARD · 明信片</text>
              <text class="pback-series">SÉRIE {{ getStampSeries(postcard.stampDesign) }} · {{ getStampSeriesName(postcard.stampDesign) }}</text>
            </view>
            <!-- Stamp box -->
            <view class="pback-stamp" :style="{ borderColor: getStampColor(postcard.stampDesign) }">
              <image v-if="getStampImageUrl(postcard.stampDesign)" :src="getStampImageUrl(postcard.stampDesign)" class="pback-stamp-img" mode="aspectFill" />
              <text v-else class="pback-stamp-dot" :style="{ color: getStampColor(postcard.stampDesign) }">✦</text>
              <text class="pback-stamp-name" :style="{ color: getStampColor(postcard.stampDesign) }">{{ getStampName(postcard.stampDesign) }}</text>
            </view>
          </view>
          <view class="pback-top-rule"></view>

          <!-- Body: message left | address right -->
          <view class="pback-body">
            <!-- Left: ruled message area -->
            <view class="pback-message">
              <text class="pback-msg-label">MESSAGE · 留言</text>
              <view class="pback-ruled-lines">
                <view class="pback-rule-line"></view>
                <view class="pback-rule-line"></view>
              </view>
              <text class="pback-note">{{ postcard.note }}</text>
              <view class="pback-ruled-lines" style="margin-top: 12rpx;">
                <view class="pback-rule-line"></view>
                <view class="pback-rule-line"></view>
              </view>
              <view class="pback-sig">
                <text class="pback-sig-name">— 远方旅人</text>
                <text class="pback-sig-date">{{ formatDotDate(postcard.recordedAt) }}</text>
              </view>
            </view>

            <!-- Vertical divider -->
            <view class="pback-vdivider"></view>

            <!-- Right: address block -->
            <view class="pback-address">
              <view class="pback-addr-block">
                <text class="pback-addr-label">FROM</text>
                <text class="pback-addr-main">{{ postcard.locationName }}</text>
                <text class="pback-addr-sub">{{ postcard.city }} · {{ postcard.country }}</text>
              </view>
              <view class="pback-addr-sep"></view>
              <view class="pback-addr-block">
                <text class="pback-addr-label">TO</text>
                <text class="pback-addr-main">未来的我</text>
                <text class="pback-addr-sub">心中的远方</text>
              </view>
              <!-- Postmark -->
              <view class="pback-postmark">
                <view class="pback-pm-outer"></view>
                <view class="pback-pm-inner"></view>
                <view class="pback-pm-text">
                  <text class="pback-pm-city">{{ postcard.city.substring(0,2).toUpperCase() }}</text>
                  <text class="pback-pm-date">{{ formatDotDate(postcard.recordedAt) }}</text>
                </view>
              </view>
            </view>
          </view>

          <!-- Footer -->
          <view class="pback-footer">
            <text class="pback-footer-l">旅行邮局 · 寄往远方</text>
            <text class="pback-footer-r">N° {{ padNum(postcard.id) }}</text>
          </view>
        </view>

        <!-- Action buttons -->
        <view class="action-row">
          <view
            class="action-btn"
            :class="{ 'action-btn-active': postcard.isFavorite, 'fav-stamping': stampingFav }"
            @click="toggleFavorite"
          >
            <IconFavorite :size="22" :color="postcard.isFavorite ? '#A43B2D' : '#8E8775'" />
            <text class="action-main">收藏</text>
            <text class="action-sub">LOVE</text>
          </view>
          <view class="action-btn" @click="goToEdit">
            <IconEdit :size="22" color="#8E8775" />
            <text class="action-main">编辑</text>
            <text class="action-sub">EDIT</text>
          </view>
          <view class="action-btn" @click="goToSend">
            <IconSend :size="22" color="#3C604D" />
            <text class="action-main" style="color:#3C604D;">寄出</text>
            <text class="action-sub">MAIL</text>
          </view>
          <view class="action-btn" @click="sharePostcard">
            <IconShare :size="22" color="#8E8775" />
            <text class="action-main">分享</text>
            <text class="action-sub">SHARE</text>
          </view>
        </view>

        <!-- Public board toggle -->
        <view class="public-toggle" :class="{ 'public-toggle-on': isPublic }" @click="togglePublic">
          <view class="public-toggle-left">
            <IconGlobe :size="22" :color="isPublic ? '#2E7D58' : '#8E8775'" />
            <view class="public-toggle-text">
              <text class="public-toggle-main">{{ isPublic ? '已投入旅行公告栏' : '投入旅行公告栏' }}</text>
              <text class="public-toggle-sub">{{ isPublic ? '正在公开展示，点击撤出' : '与旅行者们分享这张明信片' }}</text>
            </view>
          </view>
          <view class="public-pill" :class="{ 'public-pill-on': isPublic }">
            <text class="public-pill-txt">{{ isPublic ? '公开' : '私密' }}</text>
          </view>
        </view>

        <!-- Print teaser card -->
        <view class="print-teaser" @click="showPrintModal = true">
          <view class="print-teaser-left">
            <text class="print-teaser-kicker">COMING SOON · 即将上线</text>
            <text class="print-teaser-title">印出来，寄给远方的 TA</text>
            <text class="print-teaser-sub">将这张明信片真正印刷并邮寄出去</text>
          </view>
          <view class="print-teaser-arrow">›</view>
        </view>

        <!-- Journey context strip -->
        <view class="journey-strip" v-if="journeyCards.length > 0">
          <view class="journey-strip-hd">
            <view>
              <text class="journey-kicker">JOURNEY · 同一旅程</text>
              <text class="journey-title">{{ travelTitle }}</text>
            </view>
            <text class="journey-count">{{ journeyCards.length }} 张 →</text>
          </view>
          <scroll-view class="journey-scroll" scroll-x>
            <view class="journey-cards">
              <view
                v-for="card in journeyCards"
                :key="card.id"
                class="journey-mini-card"
                @click="viewPostcard(card)"
              >
                <view class="journey-mini-thumb">
                  <image v-if="card.photoUrl" :src="card.photoUrl" class="journey-mini-img" mode="aspectFill" />
                  <view v-else class="journey-mini-grad"></view>
                </view>
                <text class="journey-mini-loc">{{ card.locationName }}</text>
                <text class="journey-mini-date">{{ formatDotDate(card.recordedAt) }}</text>
              </view>
            </view>
          </scroll-view>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>

  <!-- Print interest modal -->
  <view v-if="showPrintModal" class="modal-mask" @click.self="showPrintModal = false">
    <view class="modal-sheet">
      <view class="modal-handle"></view>

      <view class="modal-stamp-deco">
        <text class="modal-stamp-char">印</text>
      </view>

      <text class="modal-kicker">PRINT & MAIL · 实物明信片</text>
      <text class="modal-title">把这张明信片真正寄出去</text>
      <text class="modal-desc">我们正在开发实物印刷服务——把你在旅途中记录的明信片，真正印刷出来，邮寄给你爱的人。</text>

      <view class="modal-steps">
        <view class="modal-step">
          <text class="modal-step-num">01</text>
          <text class="modal-step-txt">选择明信片，填写收件人地址</text>
        </view>
        <view class="modal-step">
          <text class="modal-step-num">02</text>
          <text class="modal-step-txt">我们印刷并贴上真实邮票</text>
        </view>
        <view class="modal-step">
          <text class="modal-step-num">03</text>
          <text class="modal-step-txt">3-5 天送达，附带你的手写留言</text>
        </view>
      </view>

      <view class="modal-btn" :class="{ 'modal-btn-done': printInterestDone }" @click="registerPrintInterest">
        <text class="modal-btn-txt">{{ printInterestDone ? '✓ 已登记，上线第一时间通知你' : '我想要这个功能 →' }}</text>
      </view>
      <text class="modal-cancel" @click="showPrintModal = false">稍后再说</text>
    </view>
  </view>

  <!-- Empty state -->
  <view class="empty-state" v-else>
    <view class="float-nav-empty">
      <view class="nav-btn nav-btn-dark" @click="goBack">
        <IconBack :size="20" color="#5C5648" />
      </view>
    </view>
    <IconImage :size="96" color="#B5AE9B" />
    <text class="empty-main">明信片不存在</text>
    <view class="empty-btn" @click="goBack">
      <text class="empty-btn-txt">返回</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { UIUtil } from '@/utils/ui'
import { ToastMessages, StampDesigns } from '@/config/app'
import type { Postcard } from '@/model/Postcard'
import {
  IconBack,
  IconMore,
  IconImage,
  IconFavorite,
  IconEdit,
  IconShare,
  IconSend,
  IconGlobe,
} from '@/components/icons'
import { formatDotDate, getStampColor, getStampName, getStampSeries, getStampSeriesName, getStampImageUrl } from '@/utils/stamp'
import { PostcardApi, FeedbackApi } from '@/services/api'

const store = usePostcardStore()
const postcard = ref<Postcard | null>(null)
const postcardId = ref('')
const cardRevealed = ref(false)
const stampingFav  = ref(false)
const isPublic     = ref(false)
const isTogglingPublic = ref(false)
const showPrintModal    = ref(false)
const printInterestDone = ref(false)

const travelTitle = computed(() => {
  if (!postcard.value || !postcard.value.travelId) return '来信明信片'
  const travel = store.travels.find(t => t.id === postcard.value!.travelId)
  return travel?.title || '旅行'
})

const journeyCards = computed(() => {
  if (!postcard.value || !postcard.value.travelId) return []
  return store.postcards.filter(
    p => p.travelId === postcard.value!.travelId && p.id !== postcard.value!.id
  ).slice(0, 6)
})

function padNum(id: string): string {
  const match = id.match(/\d+$/)
  return match ? String(match[0]).padStart(4, '0') : '0001'
}

function yearStr(ts: number): string {
  return String(new Date(ts).getFullYear())
}

function metaDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getFullYear()} · ${String(d.getMonth() + 1).padStart(2, '0')} · ${String(d.getDate()).padStart(2, '0')}`
}

function metaTime(ts: number): string {
  const d = new Date(ts)
  return `${String(d.getHours()).padStart(2, '0')} : ${String(d.getMinutes()).padStart(2, '0')}`
}

function goBack() {
  uni.navigateBack({ fail: () => uni.switchTab({ url: '/pages/home/home' }) })
}

function previewImage() {
  if (postcard.value?.photoUrl) {
    uni.previewImage({ urls: [postcard.value.photoUrl], current: postcard.value.photoUrl })
  }
}

function toggleFavorite() {
  if (!postcard.value) return
  stampingFav.value = true
  store.toggleFavorite(postcard.value.id)
  postcard.value = store.getPostcardById(postcardId.value) || null
  UIUtil.showSuccess(ToastMessages.success.favorite)
  setTimeout(() => { stampingFav.value = false }, 500)
}

function goToEdit() {
  if (postcard.value) {
    uni.navigateTo({ url: `/pages/edit/edit?id=${postcard.value.id}` })
  }
}

function goToSend() {
  if (postcard.value) {
    uni.navigateTo({ url: `/pages/send/send?postcardId=${postcard.value.id}` })
  }
}

function sharePostcard() {
  uni.showActionSheet({
    itemList: ['分享给好友', '生成图片'],
    success: (res) => {
      uni.showToast({ title: res.tapIndex === 0 ? '分享功能开发中' : '生成图片功能开发中', icon: 'none' })
    }
  })
}

function showMoreOptions() {
  uni.showActionSheet({
    itemList: ['编辑', '删除'],
    success: (res) => {
      if (res.tapIndex === 0) {
        goToEdit()
      } else {
        confirmDelete()
      }
    }
  })
}

function confirmDelete() {
  uni.showModal({
    title: '确认删除',
    content: ToastMessages.confirm.delete,
    success: (res) => {
      if (res.confirm && postcard.value) {
        store.deletePostcard(postcard.value.id)
        UIUtil.showSuccess(ToastMessages.success.delete)
        setTimeout(() => uni.switchTab({ url: '/pages/home/home' }), 1500)
      }
    }
  })
}

function viewPostcard(card: Postcard) {
  uni.navigateTo({ url: `/pages/detail/detail?id=${card.id}` })
}

async function registerPrintInterest() {
  if (printInterestDone.value) return
  try {
    await FeedbackApi.interest('print_postcard', postcard.value?.id)
    printInterestDone.value = true
  } catch {
    uni.showToast({ title: '登记失败，请稍后重试', icon: 'none' })
  }
}

async function togglePublic() {
  if (!postcard.value || isTogglingPublic.value) return
  isTogglingPublic.value = true
  const next = !isPublic.value
  try {
    await PostcardApi.togglePublic(postcard.value.id, next)
    isPublic.value = next
    store.updatePostcard(postcard.value.id, { isPublic: next })
    uni.showToast({ title: next ? '已投入公告栏' : '已撤出公告栏', icon: 'none' })
  } catch (e: any) {
    uni.showToast({ title: e.message || '操作失败', icon: 'none' })
  } finally {
    isTogglingPublic.value = false
  }
}

onLoad((options) => {
  if (options?.id) postcardId.value = options.id
})

onMounted(() => {
  store.initData()
  if (postcardId.value) {
    postcard.value = store.getPostcardById(postcardId.value) || null
    isPublic.value = postcard.value?.isPublic ?? false
  }
  setTimeout(() => { cardRevealed.value = true }, 120)
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
  position: relative;
}

// ─── Floating nav ───
.float-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
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
  width: 76rpx;
  height: 76rpx;
  border-radius: 50%;
  background: rgba(20, 15, 10, 0.35);
  border: 1rpx solid rgba(244, 239, 229, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-btn-dark {
  background: $card-bg;
  border-color: $line-sepia;
}

.nav-label {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: rgba(244, 239, 229, 0.9);
  text-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.3);
}

// ─── Scroll + hero ───
.scroll-wrap {
  height: 100vh;
}

.hero-wrap {
  position: relative;
  width: 100%;
  height: 800rpx;
}

.hero-img {
  width: 100%;
  height: 100%;
}

.hero-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(180deg, #C9D2B6 0%, #6E8862 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.hero-fade {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 160rpx;
  background: linear-gradient(180deg, transparent, $page-background);
}

// ─── Postmark ───
.postmark {
  position: absolute;
  top: 156rpx;
  right: 36rpx;
  transform: rotate(-9deg);
  width: 172rpx;
  height: 172rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.9;
}

.postmark-outer {
  position: absolute;
  width: 172rpx;
  height: 172rpx;
  border-radius: 50%;
  border: 2rpx solid rgba(244, 239, 229, 0.5);
}

.postmark-inner {
  position: absolute;
  width: 140rpx;
  height: 140rpx;
  border-radius: 50%;
  border: 2rpx solid rgba(244, 239, 229, 0.8);
}

.postmark-text {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0;
}

.postmark-city {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 4rpx;
  color: rgba(244, 239, 229, 0.9);
}

.postmark-date {
  font-family: $font-family-serif;
  font-size: 36rpx;
  font-weight: 500;
  color: rgba(244, 239, 229, 0.95);
  line-height: 1.1;
}

.postmark-year {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 4rpx;
  color: rgba(244, 239, 229, 0.7);
}

// ─── Detail card wrap ───
.detail-card-wrap {
  padding: 0 36rpx;
  margin-top: -76rpx;
  position: relative;
  z-index: 5;
  transform: translateY(80rpx);
  opacity: 0;
  transition: transform 0.72s cubic-bezier(0.25, 0.46, 0.45, 0.94), opacity 0.6s ease;

  &.card-revealed {
    transform: translateY(0);
    opacity: 1;
  }
}

// ─── Postcard back ───
.pback {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
  box-shadow: 0 24rpx 64rpx rgba(40, 30, 15, 0.10);
}

.pback-hd {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  padding: 28rpx 28rpx 20rpx;
  gap: 16rpx;
}

.pback-hd-left { flex: 1; min-width: 0; }

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
  flex-shrink: 0;
  width: 88rpx;
  height: 112rpx;
  border: 1rpx dashed currentColor;
  border-radius: 3rpx;
  background: $page-background;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  transform: rotate(-2deg);
}

.pback-stamp-img {
  width: 72rpx;
  height: 72rpx;
  border-radius: 2rpx;
  flex-shrink: 0;
}

.pback-stamp-dot { font-size: 28rpx; }

.pback-stamp-name {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 1rpx;
}

.pback-top-rule {
  height: 1rpx;
  background: $line-sepia;
  margin: 0 28rpx;
}

// ─── Postcard back body ───
.pback-body {
  display: flex;
  min-height: 320rpx;
  padding: 24rpx 28rpx 20rpx;
  gap: 0;
}

.pback-message {
  flex: 1;
  min-width: 0;
  padding-right: 24rpx;
}

.pback-msg-label {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 16rpx;
}

.pback-ruled-lines {
  display: flex;
  flex-direction: column;
  gap: 22rpx;
}

.pback-rule-line {
  height: 1rpx;
  background: $line-sepia;
}

.pback-note {
  display: block;
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.75;
  letter-spacing: 0.5rpx;
  padding: 16rpx 0;
}

.pback-sig {
  display: flex;
  justify-content: space-between;
  margin-top: 16rpx;
  padding-top: 14rpx;
  border-top: 1rpx dashed $line-sepia;
}

.pback-sig-name,
.pback-sig-date {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

// ─── Vertical divider ───
.pback-vdivider {
  width: 1rpx;
  background: $line-sepia;
  flex-shrink: 0;
  margin: 0 8rpx;
}

// ─── Address block ───
.pback-address {
  width: 220rpx;
  flex-shrink: 0;
  padding-left: 20rpx;
  display: flex;
  flex-direction: column;
  position: relative;
}

.pback-addr-block {
  flex: 1;
}

.pback-addr-label {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 8rpx;
}

.pback-addr-main {
  display: block;
  font-family: $font-family-serif;
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
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pback-addr-sep {
  height: 1rpx;
  background: $line-sepia;
  margin: 16rpx 0;
}

// ─── Postmark in address area ───
.pback-postmark {
  position: relative;
  width: 96rpx;
  height: 96rpx;
  margin-top: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transform: rotate(-8deg);
}

.pback-pm-outer {
  position: absolute;
  width: 96rpx;
  height: 96rpx;
  border-radius: 50%;
  border: 2rpx solid rgba(164, 59, 45, 0.5);
}

.pback-pm-inner {
  position: absolute;
  width: 78rpx;
  height: 78rpx;
  border-radius: 50%;
  border: 1rpx solid rgba(164, 59, 45, 0.35);
}

.pback-pm-text {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2rpx;
}

.pback-pm-city {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: rgba(164, 59, 45, 0.8);
}

.pback-pm-date {
  font-family: $font-family-serif;
  font-size: 22rpx;
  font-weight: 500;
  color: rgba(164, 59, 45, 0.85);
  line-height: 1.1;
}

// ─── Postcard back footer ───
.pback-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16rpx 28rpx;
  border-top: 1rpx solid $line-sepia;
  background: $paper-beige;
}

.pback-footer-l,
.pback-footer-r {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

// ─── Action row ───
.action-row {
  display: flex;
  gap: 16rpx;
  margin-top: 28rpx;
}

.action-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  padding: 28rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 6rpx;
  color: $body-text;

  &.action-btn-active {
    color: $stamp-red;
    border-color: rgba(164, 59, 45, 0.3);
    background: rgba(164, 59, 45, 0.04);
  }
}

.action-main {
  font-family: $font-family-serif;
  font-size: 22rpx;
  font-weight: 500;
  color: $ink-black;
}

.action-btn-active .action-main {
  color: $stamp-red;
}

.action-sub {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

// ─── Public board toggle ───
.public-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16rpx;
  padding: 24rpx 28rpx;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 6rpx;
  gap: 16rpx;

  &.public-toggle-on {
    background: rgba(46, 125, 88, 0.04);
    border-color: rgba(46, 125, 88, 0.3);
  }
}

.public-toggle-left {
  display: flex;
  align-items: center;
  gap: 20rpx;
  flex: 1;
  min-width: 0;
}

.public-toggle-text {
  flex: 1;
  min-width: 0;
}

.public-toggle-main {
  display: block;
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
}

.public-toggle-sub {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.public-pill {
  flex-shrink: 0;
  padding: 6rpx 20rpx;
  border-radius: 20rpx;
  background: $paper-beige;
  border: 1rpx solid $line-sepia;
}

.public-pill-on {
  background: rgba(46, 125, 88, 0.12);
  border-color: rgba(46, 125, 88, 0.4);
}

.public-pill-txt {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 1rpx;
  color: $mute-text;

  .public-pill-on & {
    color: $travel-blue;
  }
}

// ─── Journey context ───
.journey-strip {
  margin-top: 48rpx;
}

.journey-strip-hd {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 20rpx;
}

.journey-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 6rpx;
}

.journey-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 30rpx;
  font-weight: 500;
  color: $ink-black;
}

.journey-count {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.journey-scroll {
  width: 100%;
}

.journey-cards {
  display: flex;
  gap: 20rpx;
  width: max-content;
  padding-bottom: 16rpx;
}

.journey-mini-card {
  width: 240rpx;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 6rpx;
  padding: 16rpx;
}

.journey-mini-thumb {
  width: 100%;
  height: 176rpx;
  border-radius: 4rpx;
  overflow: hidden;
  margin-bottom: 16rpx;
}

.journey-mini-img { width: 100%; height: 100%; }

.journey-mini-grad {
  width: 100%;
  height: 100%;
  background: linear-gradient(180deg, #C9D2B6 0%, #6E8862 100%);
}

.journey-mini-loc {
  display: block;
  font-family: $font-family-serif;
  font-size: 26rpx;
  font-weight: 500;
  color: $ink-black;
  margin-bottom: 6rpx;
}

.journey-mini-date {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

// ─── Empty state ───
.empty-state {
  min-height: 100vh;
  background: $page-background;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80rpx 40rpx;
  position: relative;
}

.float-nav-empty {
  position: absolute;
  top: 50px;
  left: 32rpx;
}

.empty-main {
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: $body-text;
  margin-top: 32rpx;
  margin-bottom: 40rpx;
}

.empty-btn {
  background: $travel-blue;
  padding: 20rpx 60rpx;
  border-radius: 6rpx;
}

.empty-btn-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $card-bg;
  letter-spacing: 4rpx;
}

.btm-gap { height: 120rpx; }

// ─── Print teaser ───
.print-teaser {
  display: flex;
  align-items: center;
  margin-top: 16rpx;
  padding: 28rpx;
  background: linear-gradient(135deg, #FFF8F0 0%, #FFF3E6 100%);
  border: 1rpx dashed rgba(180, 120, 60, 0.35);
  border-radius: 6rpx;
  gap: 16rpx;

  &:active { opacity: 0.85; }
}

.print-teaser-left { flex: 1; }

.print-teaser-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: rgba(180, 120, 60, 0.8);
  margin-bottom: 8rpx;
}

.print-teaser-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: #5C3A1E;
  margin-bottom: 4rpx;
}

.print-teaser-sub {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 1rpx;
  color: rgba(92, 58, 30, 0.6);
}

.print-teaser-arrow {
  font-family: $font-family-serif;
  font-size: 48rpx;
  color: rgba(180, 120, 60, 0.5);
}

// ─── Print modal ───
.modal-mask {
  position: fixed;
  inset: 0;
  background: rgba(16, 12, 8, 0.6);
  z-index: 999;
  display: flex;
  align-items: flex-end;
}

.modal-sheet {
  width: 100%;
  background: $card-bg;
  border-radius: 24rpx 24rpx 0 0;
  padding: 16rpx 48rpx 80rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
}

.modal-handle {
  width: 64rpx;
  height: 6rpx;
  background: $line-sepia;
  border-radius: 3rpx;
  margin-bottom: 8rpx;
}

.modal-stamp-deco {
  width: 112rpx;
  height: 112rpx;
  border: 2rpx dashed rgba(180, 120, 60, 0.4);
  border-radius: 8rpx;
  background: rgba(180, 120, 60, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-stamp-char {
  font-family: $font-family-serif;
  font-size: 56rpx;
  color: rgba(180, 120, 60, 0.8);
}

.modal-kicker {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 4rpx;
  color: $mute-text;
}

.modal-title {
  font-family: $font-family-serif;
  font-size: 40rpx;
  color: $ink-black;
  text-align: center;
  line-height: 1.3;
}

.modal-desc {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $body-text;
  text-align: center;
  line-height: 1.8;
  max-width: 520rpx;
}

.modal-steps {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 16rpx;
  background: $paper-beige;
  border-radius: 8rpx;
  padding: 24rpx;
  margin: 4rpx 0;
}

.modal-step {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.modal-step-num {
  font-family: $font-family-mono;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(180, 120, 60, 0.7);
  width: 48rpx;
  flex-shrink: 0;
}

.modal-step-txt {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $body-text;
  line-height: 1.5;
}

.modal-btn {
  width: 100%;
  background: #7A4A20;
  border-radius: 8rpx;
  padding: 30rpx 0;
  text-align: center;
  margin-top: 8rpx;

  &:active { opacity: 0.85; }
  &.modal-btn-done { background: $travel-blue; }
}

.modal-btn-txt {
  font-family: $font-family-serif;
  font-size: 30rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

.modal-cancel {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  padding: 8rpx;
}

// ── 收藏邮戳动画 ──
.fav-stamping { animation: fav-press 0.45s cubic-bezier(0.34, 1.56, 0.64, 1); }

@keyframes fav-press {
  0%   { transform: scale(1); }
  30%  { transform: scale(0.65); }
  65%  { transform: scale(1.32); }
  100% { transform: scale(1); }
}
</style>

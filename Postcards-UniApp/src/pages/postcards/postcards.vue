<template>
  <view class="page-container">
    <PostalHeader
      kicker="POSTCARDS · 明信片"
      title="我的明信片"
      :subtitle="`共 ${postcards.length} 张明信片`"
      fallback-url="/pages/profile/profile"
      @back="goBack"
    />

    <scroll-view class="content" scroll-y>
      <view v-if="postcards.length > 0" class="list-wrap">

        <!-- ── Postcard card ── -->
        <view
          v-for="(card, idx) in postcards"
          :key="card.id"
          class="pc-card"
          @click="viewPostcard(card)"
        >
          <!-- Top strip: label + postmark -->
          <view class="pc-top">
            <text class="pc-no">POSTCARD · No.{{ String(postcards.length - idx).padStart(3, '0') }}</text>
            <view class="pc-postmark">
              <text class="pc-pm-city">{{ card.city.toUpperCase().slice(0, 6) }}</text>
              <text class="pc-pm-date">{{ formatPostmarkDate(card.recordedAt) }}</text>
            </view>
          </view>

          <!-- Body -->
          <view class="pc-body">

            <!-- Left: photo + note overlay -->
            <view class="pc-left">
              <image
                v-if="card.photoUrl"
                :src="card.photoUrl"
                class="pc-photo"
                mode="aspectFill"
              />
              <view v-else class="pc-photo-grad"></view>
              <view class="pc-note-overlay">
                <text class="pc-note">"{{ card.note }}"</text>
              </view>
            </view>

            <!-- Vertical dashed divider -->
            <view class="pc-vdiv"></view>

            <!-- Right: address area -->
            <view class="pc-right">
              <text class="pc-to-label">致 · 旅途中的自己</text>

              <!-- Ruled lines container -->
              <view class="pc-ruled">
                <text class="pc-city">{{ card.city }}</text>
                <text class="pc-loc">{{ card.locationName }}</text>
              </view>

              <!-- Footer: heart + stamp -->
              <view class="pc-footer">
                <view class="pc-fav" @click.stop="toggleFav(card.id)">
                  <IconFavorite
                    :size="30"
                    :color="card.isFavorite ? '#A43B2D' : '#C8BFB0'"
                  />
                </view>

                <!-- Perforated stamp -->
                <view
                  class="pc-stamp"
                  :style="{ borderColor: getStampColor(card.stampDesign) }"
                >
                  <view class="pc-stamp-perf-row">
                    <view v-for="i in 6" :key="i" class="pc-perf"></view>
                  </view>
                  <view class="pc-stamp-img-wrap">
                    <image
                      v-if="getStampImageUrl(card.stampDesign)"
                      :src="getStampImageUrl(card.stampDesign)"
                      class="pc-stamp-img"
                      mode="aspectFill"
                    />
                    <view
                      v-else
                      class="pc-stamp-color"
                      :style="{ background: getStampColor(card.stampDesign) }"
                    ></view>
                  </view>
                  <view class="pc-stamp-perf-row">
                    <view v-for="i in 6" :key="i" class="pc-perf"></view>
                  </view>
                </view>
              </view>
            </view>
          </view>
        </view>

      </view>

      <view v-else class="empty-state">
        <IconImage :size="80" color="#B5AE9B" />
        <text class="empty-kicker">{{ emptyKicker }}</text>
        <text class="empty-main">{{ emptyTitle }}</text>
        <text class="empty-sub">{{ emptySubtitle }}</text>
        <view class="empty-btn" @click="goEmptyAction">
          <text class="empty-btn-txt">{{ emptyActionText }}</text>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>

  <PostcardFlipModal :postcard="activeCard" @close="activeCard = null" />
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import type { Postcard } from '@/model/Postcard'
import { IconFavorite, IconImage } from '@/components/icons'
import { getStampColor, getStampImageUrl } from '@/utils/stamp'
import PostalHeader from '@/components/PostalHeader.vue'
import PostcardFlipModal from '@/components/PostcardFlipModal.vue'

const store = usePostcardStore()
const postcards = computed(() => store.sortedPostcards)
const hasTravels = computed(() => store.sortedTravels.length > 0)
const activeCard = ref<Postcard | null>(null)

const emptyKicker = computed(() => hasTravels.value ? 'FIRST POSTCARD' : 'FIRST JOURNEY')
const emptyTitle = computed(() => hasTravels.value ? '记录第一张明信片' : '先创建一段旅程')
const emptySubtitle = computed(() =>
  hasTravels.value
    ? '选择一个地点，写下此刻，第一张旅行明信片就会出现在这里。'
    : '明信片需要归属旅程，先定下目的地会更自然。'
)
const emptyActionText = computed(() => hasTravels.value ? '立即记录 ›' : '创建旅程 ›')

const MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']

function formatPostmarkDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`
}

function viewPostcard(card: Postcard) {
  activeCard.value = card
}

function toggleFav(id: string) {
  store.toggleFavorite(id)
  uni.showToast({ title: '收藏已更新', icon: 'success' })
}

function goRecord() {
  uni.switchTab({ url: '/pages/record/record' })
}

function goCreateTravel() {
  uni.navigateTo({ url: '/pages/travel/travel' })
}

function goEmptyAction() {
  if (hasTravels.value) {
    goRecord()
  } else {
    goCreateTravel()
  }
}

function goBack() {
  uni.navigateBack({ fail: () => uni.switchTab({ url: '/pages/home/home' }) })
}

onMounted(() => store.initData())
onShow(() => { if (store.postcards.length === 0) store.initData() })
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $page-background;
}

.content {
  flex: 1;
  overflow: hidden;
}

.list-wrap {
  padding: 32rpx 40rpx 0;
  display: flex;
  flex-direction: column;
  gap: 28rpx;
}

// ═══════════════════════════════
//  Postcard Card
// ═══════════════════════════════
.pc-card {
  background: $card-bg;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  overflow: hidden;
  box-shadow: 0 4rpx 20rpx rgba(60, 40, 20, 0.09), 0 1rpx 3rpx rgba(60, 40, 20, 0.05);
}

// ── Top strip: label + postmark ──
.pc-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14rpx 24rpx;
  background: $paper-beige;
  border-bottom: 1rpx solid $line-sepia;
}

.pc-no {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

// Postmark: oval cancel stamp shape
.pc-postmark {
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 1rpx solid $mute-text;
  border-radius: 6rpx;
  padding: 4rpx 14rpx;
  position: relative;
}

// horizontal cancel lines through postmark
.pc-postmark::before,
.pc-postmark::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  height: 1rpx;
  background: $mute-text;
  opacity: 0.35;
}
.pc-postmark::before { top: 30%; }
.pc-postmark::after  { top: 65%; }

.pc-pm-city {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $body-text;
  line-height: 1.4;
}

.pc-pm-date {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  line-height: 1.4;
}

// ── Body ──
.pc-body {
  display: flex;
  min-height: 230rpx;
}

// ── Left: photo ──
.pc-left {
  width: 190rpx;
  flex-shrink: 0;
  position: relative;
  overflow: hidden;
}

.pc-photo {
  position: absolute;
  top: 0; left: 0;
  width: 100%;
  height: 100%;
}

.pc-photo-grad {
  position: absolute;
  top: 0; left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #C9D2B6 0%, #6E8862 50%, #3C604D 100%);
}

.pc-note-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 32rpx 16rpx 16rpx;
  background: linear-gradient(transparent, rgba(20, 15, 10, 0.62));
}

.pc-note {
  font-family: $font-family-body;
  font-style: normal;
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

// ── Vertical dashed divider ──
.pc-vdiv {
  width: 1rpx;
  flex-shrink: 0;
  background-image: repeating-linear-gradient(
    to bottom,
    $line-sepia 0,
    $line-sepia 8rpx,
    transparent 8rpx,
    transparent 16rpx
  );
}

// ── Right: address area ──
.pc-right {
  flex: 1;
  min-width: 0;
  padding: 20rpx 24rpx 16rpx;
  display: flex;
  flex-direction: column;
  // subtle ruled lines
  background-image: repeating-linear-gradient(
    to bottom,
    transparent 0rpx,
    transparent 47rpx,
    rgba(180, 165, 140, 0.25) 47rpx,
    rgba(180, 165, 140, 0.25) 48rpx
  );
  background-size: 100% 48rpx;
}

.pc-to-label {
  font-family: $font-family-body;
  font-style: normal;
  font-size: 22rpx;
  color: $mute-text;
  margin-bottom: 16rpx;
  display: block;
}

.pc-ruled {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  margin-bottom: 12rpx;
}

.pc-city {
  font-family: $font-family-display;
  font-size: 40rpx;
  font-weight: 400;
  color: $ink-black;
  letter-spacing: -1rpx;
  line-height: 1.1;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pc-loc {
  font-family: $font-family-display;
  font-size: 24rpx;
  color: $body-text;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

// ── Footer: heart + stamp ──
.pc-footer {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.pc-fav {
  width: 56rpx;
  height: 56rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

// Perforated stamp
.pc-stamp {
  border: 1rpx solid currentColor;
  border-radius: 2rpx;
  overflow: hidden;
  width: 80rpx;
}

.pc-stamp-perf-row {
  display: flex;
  justify-content: space-around;
  padding: 3rpx 4rpx;
  background: $card-bg;
}

.pc-perf {
  width: 9rpx;
  height: 9rpx;
  border-radius: 50%;
  background: $page-background;
  border: 1rpx solid $line-sepia;
}

.pc-stamp-img-wrap {
  width: 100%;
  height: 72rpx;
  overflow: hidden;
}

.pc-stamp-img {
  width: 100%;
  height: 100%;
}

.pc-stamp-color {
  width: 100%;
  height: 100%;
  opacity: 0.6;
}

// ─── Empty state ───
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 96rpx 40rpx;
  text-align: center;
}

.empty-kicker {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
  margin-top: 28rpx;
  margin-bottom: 10rpx;
}

.empty-main {
  font-family: $font-family-body;
  font-size: 36rpx;
  color: $ink-black;
  margin-bottom: 8rpx;
}

.empty-sub {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
  line-height: 1.6;
  max-width: 520rpx;
  margin-bottom: 40rpx;
  text-align: center;
}

.empty-btn {
  background: $travel-blue;
  padding: 20rpx 60rpx;
  border-radius: 6rpx;
}

.empty-btn-txt {
  font-family: $font-family-action;
  font-size: 28rpx;
  color: $card-bg;
  letter-spacing: 0;
}

.btm-gap { height: 120rpx; }
</style>

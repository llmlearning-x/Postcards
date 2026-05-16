<template>
  <view v-if="postcard" class="flip-overlay" @click.self="$emit('close')">
    <view class="flip-close" @click="$emit('close')">
      <text class="flip-close-icon">✕</text>
    </view>

    <view class="flip-wrap">
      <text class="flip-hint">{{ flipped ? '再次点击翻回正面' : '点击明信片查看背面' }}</text>

      <view class="flip-stage" @click="toggle">
        <view class="flip-inner" :class="{ flipped }">

          <!-- ─── FRONT: photo side ─── -->
          <view class="flip-face front">
            <image
              v-if="postcard.photoUrl"
              :src="postcard.photoUrl"
              class="front-photo"
              mode="aspectFill"
            />
            <view v-else class="front-grad"></view>

            <!-- City bar: bottom -->
            <view class="front-bar">
              <text class="front-city">{{ postcard.city }}</text>
              <text class="front-date">{{ formatFrontDate(postcard.recordedAt) }}</text>
            </view>
          </view>

          <!-- ─── BACK: postcard back side ─── -->
          <view class="flip-face back">
            <!-- Header row -->
            <view class="back-header">
              <text class="back-label">POSTCARD · 明信片</text>
              <!-- Perforated stamp -->
              <view class="back-stamp" :style="{ borderColor: getStampColor(postcard.stampDesign) }">
                <view class="back-stamp-perf">
                  <view v-for="i in 5" :key="i" class="back-perf"></view>
                </view>
                <view class="back-stamp-inner">
                  <image
                    v-if="getStampImageUrl(postcard.stampDesign)"
                    :src="getStampImageUrl(postcard.stampDesign)"
                    class="back-stamp-img"
                    mode="aspectFill"
                  />
                  <view
                    v-else
                    class="back-stamp-fill"
                    :style="{ background: getStampColor(postcard.stampDesign) }"
                  ></view>
                </view>
                <view class="back-stamp-perf">
                  <view v-for="i in 5" :key="i" class="back-perf"></view>
                </view>
              </view>
            </view>

            <view class="back-divider-h"></view>

            <!-- Body: message | address -->
            <view class="back-body">
              <!-- Left: message -->
              <view class="back-msg">
                <text class="back-note">{{ postcard.note || '此刻，无言。' }}</text>
              </view>

              <!-- Vertical dashed divider -->
              <view class="back-divider-v"></view>

              <!-- Right: address -->
              <view class="back-addr">
                <text class="back-to-lbl">致</text>
                <text class="back-to-name">{{ postcard.toName || '旅途中的自己' }}</text>
                <text class="back-location">{{ postcard.locationName }}</text>
                <text class="back-city">{{ postcard.city }}{{ postcard.country ? ', ' + postcard.country : '' }}</text>
                <!-- Postmark -->
                <view class="back-postmark">
                  <text class="back-pm-city">{{ postcard.city.toUpperCase().slice(0, 6) }}</text>
                  <view class="back-pm-rule"></view>
                  <text class="back-pm-date">{{ formatPostmark(postcard.recordedAt) }}</text>
                </view>
              </view>
            </view>
          </view>

        </view>
      </view>

      <!-- Action buttons -->
      <view class="flip-actions">
        <view class="flip-btn-detail" @click="goDetail">
          <text class="flip-btn-txt">查看详情</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import type { Postcard } from '@/model/Postcard'
import { getStampColor, getStampImageUrl } from '@/utils/stamp'

const props = defineProps<{ postcard: Postcard | null }>()
const emit = defineEmits<{ (e: 'close'): void }>()

const flipped = ref(false)

watch(() => props.postcard, (val) => {
  if (val) flipped.value = false
})

function toggle() {
  flipped.value = !flipped.value
}

const MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']

function formatFrontDate(ts: number): string {
  const d = new Date(ts)
  return `${MONTHS[d.getMonth()]} ${d.getFullYear()}`
}

function formatPostmark(ts: number): string {
  const d = new Date(ts)
  return `${String(d.getDate()).padStart(2,'0')} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`
}

function goDetail() {
  if (!props.postcard) return
  emit('close')
  uni.navigateTo({ url: `/pages/detail/detail?id=${props.postcard.id}` })
}
</script>

<style lang="scss" scoped>
// ─── Overlay ───
.flip-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  z-index: 999;
  background: rgba(20, 15, 10, 0.78);
  display: flex;
  align-items: center;
  justify-content: center;
}

.flip-close {
  position: absolute;
  top: 60rpx;
  right: 48rpx;
  width: 72rpx;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.12);
  border-radius: 50%;
}

.flip-close-icon {
  font-size: 32rpx;
  color: rgba(255, 255, 255, 0.8);
  line-height: 1;
}

// ─── Center wrapper ───
.flip-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 36rpx;
}

.flip-hint {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 3rpx;
  color: rgba(255, 255, 255, 0.5);
}

// ─── 3D flip stage ───
// perspective must be in px for CSS 3D to work correctly
.flip-stage {
  width: 630rpx;
  height: 420rpx;
  perspective: 900px;
  cursor: pointer;
}

.flip-inner {
  width: 100%;
  height: 100%;
  position: relative;
  transform-style: preserve-3d;
  transition: transform 0.65s cubic-bezier(0.4, 0, 0.2, 1);
}

.flip-inner.flipped {
  transform: rotateY(180deg);
}

.flip-face {
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 100%;
  backface-visibility: hidden;
  -webkit-backface-visibility: hidden;
  border-radius: 6rpx;
  overflow: hidden;
  box-shadow: 0 24rpx 80rpx rgba(0, 0, 0, 0.55), 0 4rpx 12rpx rgba(0, 0, 0, 0.3);
}

.back {
  transform: rotateY(180deg);
}

// ═══════════════════════════
//  FRONT FACE
// ═══════════════════════════
.front {
  background: #1a1a1a;
}

.front-photo {
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 100%;
}

.front-grad {
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 100%;
  background: linear-gradient(135deg, #C9D2B6 0%, #6E8862 50%, #3C604D 100%);
}

// City bar: bottom gradient
.front-bar {
  position: absolute;
  bottom: 0; left: 0; right: 0;
  padding: 48rpx 28rpx 24rpx;
  background: linear-gradient(transparent, rgba(10, 8, 5, 0.72));
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.front-city {
  font-family: $font-family-serif;
  font-size: 44rpx;
  color: rgba(255, 255, 255, 0.95);
  letter-spacing: -1rpx;
  line-height: 1.1;
}

.front-date {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: rgba(255, 255, 255, 0.6);
}

// ═══════════════════════════
//  BACK FACE
// ═══════════════════════════
.back {
  background: $card-bg;
  display: flex;
  flex-direction: column;
}

// Header
.back-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16rpx 20rpx 12rpx;
  flex-shrink: 0;
}

.back-label {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

// Perforated stamp
.back-stamp {
  border: 1rpx solid currentColor;
  border-radius: 2rpx;
  overflow: hidden;
  width: 68rpx;
  flex-shrink: 0;
}

.back-stamp-perf {
  display: flex;
  justify-content: space-around;
  padding: 3rpx 3rpx;
  background: $card-bg;
}

.back-perf {
  width: 7rpx;
  height: 7rpx;
  border-radius: 50%;
  background: $page-background;
  border: 1rpx solid $line-sepia;
}

.back-stamp-inner {
  width: 100%;
  height: 60rpx;
  overflow: hidden;
}

.back-stamp-img {
  width: 100%;
  height: 100%;
}

.back-stamp-fill {
  width: 100%;
  height: 100%;
  opacity: 0.65;
}

// Horizontal divider below header
.back-divider-h {
  height: 1rpx;
  background: $line-sepia;
  flex-shrink: 0;
  margin: 0 16rpx;
}

// Body
.back-body {
  flex: 1;
  display: flex;
  min-height: 0;
}

// Left: message
.back-msg {
  flex: 1.1;
  padding: 18rpx 18rpx 18rpx 20rpx;
  background-image: repeating-linear-gradient(
    transparent 0rpx,
    transparent 37rpx,
    rgba(180, 165, 140, 0.22) 37rpx,
    rgba(180, 165, 140, 0.22) 38rpx
  );
  background-size: 100% 38rpx;
  display: flex;
  align-items: flex-start;
}

.back-note {
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 22rpx;
  color: $body-text;
  line-height: 1.7;
  display: -webkit-box;
  -webkit-line-clamp: 6;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

// Vertical dashed divider
.back-divider-v {
  width: 1rpx;
  flex-shrink: 0;
  background-image: repeating-linear-gradient(
    to bottom,
    $line-sepia 0,
    $line-sepia 6rpx,
    transparent 6rpx,
    transparent 12rpx
  );
  margin: 12rpx 0;
}

// Right: address
.back-addr {
  width: 210rpx;
  flex-shrink: 0;
  padding: 18rpx 20rpx 16rpx 16rpx;
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.back-to-lbl {
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 18rpx;
  color: $mute-text;
  display: block;
}

.back-to-name {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $ink-black;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 4rpx;
}

.back-location {
  font-family: $font-family-serif;
  font-size: 18rpx;
  color: $body-text;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 1.4;
}

.back-city {
  font-family: $font-family-serif;
  font-size: 18rpx;
  color: $mute-text;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 1.4;
}

// Postmark
.back-postmark {
  margin-top: auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 1rpx solid rgba(180, 165, 140, 0.5);
  border-radius: 4rpx;
  padding: 8rpx 12rpx;
  align-self: flex-start;
}

.back-pm-city {
  font-family: $font-family-mono;
  font-size: 13rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  line-height: 1.3;
}

.back-pm-rule {
  width: 100%;
  height: 1rpx;
  background: rgba(180, 165, 140, 0.4);
  margin: 4rpx 0;
}

.back-pm-date {
  font-family: $font-family-mono;
  font-size: 11rpx;
  letter-spacing: 1rpx;
  color: $whisper;
  line-height: 1.3;
}

// ─── Actions ───
.flip-actions {
  display: flex;
  gap: 24rpx;
}

.flip-btn-detail {
  background: $card-bg;
  padding: 20rpx 64rpx;
  border-radius: 6rpx;
}

.flip-btn-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  letter-spacing: 4rpx;
}
</style>

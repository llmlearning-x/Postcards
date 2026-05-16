<template>
  <view class="sp-mask" @click="emit('close')">
    <view class="sp-card" @click.stop>

      <!-- 邮票主体（四边锯齿打孔效果） -->
      <view class="sp-stamp-wrap" :style="{ '--stamp-color': stamp.color }">
        <view class="sp-perf sp-perf-t"></view>
        <view class="sp-perf sp-perf-b"></view>
        <view class="sp-perf sp-perf-l"></view>
        <view class="sp-perf sp-perf-r"></view>
        <view class="sp-stamp-inner">
          <image
            v-if="imageUrl"
            :src="imageUrl"
            class="sp-img"
            mode="aspectFit"
          />
          <text v-else class="sp-fallback" :style="{ color: stamp.color }">✦</text>
        </view>
      </view>

      <!-- 系列 / 名称 -->
      <text class="sp-series">SÉRIE {{ stamp.series }} · {{ stamp.seriesName }}</text>
      <text class="sp-name" :style="{ color: stamp.color }">{{ stamp.name }}</text>

      <!-- 设计理念（仅 shop 模式下展示） -->
      <view v-if="description" class="sp-desc-wrap">
        <view class="sp-desc-rule"></view>
        <text class="sp-desc-kicker">DESIGN CONCEPT · 设计理念</text>
        <text class="sp-desc-body">{{ description }}</text>
      </view>

      <view v-else class="sp-divider"></view>

      <!-- 操作按钮 -->
      <view class="sp-actions">
        <!-- record 模式：选用 -->
        <view
          v-if="mode === 'select'"
          class="sp-btn-primary"
          :style="{ background: stamp.color }"
          @click="emit('select')"
        >
          <text class="sp-btn-txt">选用此邮票</text>
        </view>

        <!-- shop 模式：已拥有 / 免费 / 兑换 -->
        <template v-else>
          <view v-if="stamp.isOwned" class="sp-owned-row">
            <view class="sp-btn-primary sp-btn-owned" style="flex:1">
              <text class="sp-btn-txt">✓ 已拥有</text>
            </view>
            <view
              class="sp-fav-btn"
              :class="{ 'sp-fav-active': isFavorited }"
              :style="isFavorited ? { background: stamp.color } : {}"
              @click="toggleFav"
            >
              <text class="sp-fav-icon">{{ isFavorited ? '♥' : '♡' }}</text>
              <text class="sp-fav-txt">{{ isFavorited ? '已入集' : '加入邮票集' }}</text>
            </view>
          </view>
          <view v-else-if="stamp.isFree" class="sp-btn-primary" :style="{ background: stamp.color }">
            <text class="sp-btn-txt">免费获取</text>
          </view>
          <view
            v-else
            class="sp-btn-primary"
            :style="{ background: stamp.color }"
            @click="emit('buy')"
          >
            <text class="sp-btn-txt">兑换解锁 · {{ stamp.price }} PT</text>
          </view>
        </template>

        <text class="sp-btn-close" @click="emit('close')">关闭</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { StampDesigns } from '@/config/app'
import { getStampImageUrl } from '@/utils/stamp'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

interface StampLike {
  id: string
  name: string
  series: string
  seriesName: string
  color: string
  imageUrl?: string | null
  price?: number
  isFree?: boolean
  isOwned?: boolean
}

const props = withDefaults(defineProps<{
  stamp: StampLike
  mode?: 'select' | 'shop'
}>(), {
  mode: 'select',
})

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'select'): void
  (e: 'buy'): void
}>()

const imageUrl = computed(() =>
  props.stamp.imageUrl ?? getStampImageUrl(props.stamp.id)
)

const description = computed(() => {
  const found = (StampDesigns as any[]).find(s => s.id === props.stamp.id)
  return found?.description ?? null
})

const isFavorited = computed(() => authStore.favoriteStampIds.includes(props.stamp.id))

function toggleFav() {
  authStore.toggleFavoriteStamp(props.stamp.id)
  const msg = authStore.favoriteStampIds.includes(props.stamp.id) ? '已加入邮票集 ♥' : '已移出邮票集'
  uni.showToast({ title: msg, icon: 'none' })
}
</script>

<style lang="scss" scoped>
.sp-mask {
  position: fixed;
  inset: 0;
  background: rgba(12, 9, 5, 0.88);
  z-index: 9998;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  animation: sp-fade-in 0.2s ease both;
}

@keyframes sp-fade-in {
  from { opacity: 0; }
  to   { opacity: 1; }
}

.sp-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24rpx;
  padding: 0 48rpx 48rpx;
  max-width: 560rpx;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  animation: sp-slide-up 0.28s cubic-bezier(0.34, 1.56, 0.64, 1) both;
}

@keyframes sp-slide-up {
  from { transform: translateY(60rpx) scale(0.92); opacity: 0; }
  to   { transform: translateY(0) scale(1); opacity: 1; }
}

// 邮票主体 + 锯齿打孔边
.sp-stamp-wrap {
  position: relative;
  width: 460rpx;
  height: 520rpx;
  background: $card-bg;
  box-shadow: 0 32rpx 80rpx rgba(0, 0, 0, 0.6);
  flex-shrink: 0;
}

.sp-perf {
  position: absolute;
  z-index: 1;
  --dot: 18rpx;
  --gap: 22rpx;
}
.sp-perf-t, .sp-perf-b {
  left: 0; right: 0;
  height: 18rpx;
  background: radial-gradient(circle at 50% 50%, rgba(12,9,5,0.88) var(--dot), transparent var(--dot))
    0 0 / var(--gap) 100% repeat-x;
}
.sp-perf-t { top: -9rpx; }
.sp-perf-b { bottom: -9rpx; transform: rotate(180deg); }

.sp-perf-l, .sp-perf-r {
  top: 0; bottom: 0;
  width: 18rpx;
  background: radial-gradient(circle at 50% 50%, rgba(12,9,5,0.88) var(--dot), transparent var(--dot))
    0 0 / 100% var(--gap) repeat-y;
}
.sp-perf-l { left: -9rpx; }
.sp-perf-r { right: -9rpx; }

.sp-stamp-inner {
  position: absolute;
  inset: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  background: $paper-beige;
  border: 3rpx solid var(--stamp-color, #8E8775);
}

.sp-img { width: 100%; height: 100%; }
.sp-fallback { font-size: 120rpx; }

// 信息区
.sp-series {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(244, 239, 229, 0.45);
  text-align: center;
}

.sp-name {
  font-family: $font-family-body;
  font-size: 52rpx;
  text-align: center;
  line-height: 1;
}

// 设计理念区块
.sp-desc-wrap {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.sp-desc-rule {
  height: 1rpx;
  background: rgba(244, 239, 229, 0.12);
}

.sp-desc-kicker {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: rgba(244, 239, 229, 0.3);
}

.sp-desc-body {
  font-family: $font-family-body;
  font-style: italic;
  font-size: 26rpx;
  color: rgba(244, 239, 229, 0.72);
  line-height: 1.75;
  text-align: justify;
}

.sp-divider {
  width: 80rpx;
  height: 1rpx;
  background: rgba(244, 239, 229, 0.15);
}

// 操作
.sp-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24rpx;
  width: 100%;
}

.sp-btn-primary {
  width: 100%;
  padding: 28rpx 0;
  border-radius: 8rpx;
  text-align: center;
  &:active { opacity: 0.85; }
  &.sp-btn-owned {
    background: $line-sepia;
    pointer-events: none;
  }
}

.sp-btn-txt {
  font-family: $font-family-body;
  font-size: 30rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

.sp-btn-close {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: rgba(244, 239, 229, 0.35);
}

// 已拥有 + 收藏 并排
.sp-owned-row {
  display: flex;
  gap: 16rpx;
  width: 100%;
}

.sp-fav-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6rpx;
  padding: 0 28rpx;
  border-radius: 8rpx;
  border: 1rpx solid rgba(244, 239, 229, 0.25);
  flex-shrink: 0;
  &:active { opacity: 0.8; }
}

.sp-fav-active {
  border-color: transparent;
}

.sp-fav-icon {
  font-size: 28rpx;
  color: #F4EFE5;
  line-height: 1;
}

.sp-fav-txt {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: rgba(244, 239, 229, 0.75);
  white-space: nowrap;
}
</style>

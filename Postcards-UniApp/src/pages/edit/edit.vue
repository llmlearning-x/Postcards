<template>
  <view class="page-container">
    <!-- Sticky paper nav -->
    <view class="sticky-nav">
      <view class="nav-back-btn" @click="handleBack">
        <IconBack :size="18" color="#222019" />
      </view>
      <view class="nav-center">
        <text class="nav-kicker">EDITING · N° {{ padNum(postcardId) }}</text>
        <text class="nav-title">编辑明信片</text>
      </view>
      <view class="nav-save-btn" @click="savePostcard">
        <text class="nav-save-txt">SAVE</text>
      </view>
    </view>

    <scroll-view class="scroll-content" scroll-y>
      <view class="form-body">
        <!-- Amber note banner -->
        <view class="note-banner">
          <text class="banner-label">NOTE</text>
          <text class="banner-msg">你正在编辑已寄出的明信片。修改不会改变原始记录时间。</text>
        </view>

        <!-- Photo -->
        <view class="photo-section">
          <view v-if="photoPath" class="photo-preview-wrap">
            <image :src="photoPath" class="photo-preview" mode="aspectFill" />
            <view class="photo-change-btn" @click="selectImage">
              <IconCamera :size="16" color="#F4EFE5" />
            </view>
          </view>
          <view v-else class="photo-upload-zone" @click="selectImage">
            <IconCamera :size="52" color="#3C604D" />
            <text class="upload-title">点击拍照或选择照片</text>
            <text class="upload-hint">4:3 · MAX 10MB</text>
          </view>
        </view>

        <!-- Form cards -->
        <view class="form-card">
          <view class="form-card-label-row">
            <text class="form-en-label">LOCATION</text>
            <view class="form-sep"></view>
            <text class="form-cn-label">位置</text>
            <text class="form-required">*</text>
          </view>
          <input class="form-input" v-model="locationName" placeholder="输入位置信息" placeholder-class="form-placeholder" />
        </view>

        <view class="form-card">
          <view class="form-card-label-row">
            <text class="form-en-label">CITY</text>
            <view class="form-sep"></view>
            <text class="form-cn-label">城市</text>
            <text class="form-required">*</text>
          </view>
          <input class="form-input" v-model="city" placeholder="输入城市名称" placeholder-class="form-placeholder" />
        </view>

        <view class="form-card">
          <view class="form-card-label-row">
            <text class="form-en-label">COUNTRY</text>
            <view class="form-sep"></view>
            <text class="form-cn-label">国家</text>
          </view>
          <input class="form-input" v-model="country" placeholder="输入国家名称" placeholder-class="form-placeholder" />
        </view>

        <view class="form-card">
          <view class="form-card-label-row">
            <text class="form-en-label">MESSAGE</text>
            <view class="form-sep"></view>
            <text class="form-cn-label">备注</text>
          </view>
          <textarea
            class="form-textarea"
            v-model="note"
            placeholder="记录下此刻的心情..."
            placeholder-class="form-placeholder"
            :maxlength="200"
          />
          <text class="textarea-count">{{ note.length }} / 200</text>
        </view>

        <view class="form-card">
          <view class="form-card-label-row">
            <text class="form-en-label">STAMP</text>
            <view class="form-sep"></view>
            <text class="form-cn-label">邮票样式</text>
          </view>
          <view v-for="group in stampGroups" :key="group.series" class="stamp-series-group">
            <text class="stamp-series-lbl">SÉRIE {{ group.series }} · {{ group.seriesName }}</text>
            <scroll-view class="stamp-scroll" scroll-x>
              <view class="stamp-options">
                <view
                  v-for="stamp in group.items"
                  :key="stamp.id"
                  class="stamp-option"
                  :class="{ 'stamp-option-active': stampDesign === stamp.id }"
                  :style="stampDesign === stamp.id ? { borderColor: stamp.color, background: stamp.color + '12' } : {}"
                  @click="stampDesign = stamp.id"
                >
                  <view class="stamp-swatch" :style="{ borderColor: stamp.color }">
                    <image v-if="getStampImageUrl(stamp.id)" :src="getStampImageUrl(stamp.id)" class="stamp-swatch-img" mode="aspectFill" />
                    <text v-else class="stamp-swatch-dot" :style="{ color: stamp.color }">✦</text>
                  </view>
                  <text
                    class="stamp-option-name"
                    :style="stampDesign === stamp.id ? { color: stamp.color } : {}"
                  >{{ stamp.name }}</text>
                </view>
              </view>
            </scroll-view>
          </view>
        </view>

        <!-- Save button -->
        <view class="save-btn" @click="savePostcard">
          <text class="save-btn-txt">保存修改 ›</text>
        </view>

        <!-- Delete button -->
        <view class="delete-btn" @click="confirmDelete">
          <text class="delete-btn-txt">删除这张明信片</text>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { useAuthStore } from '@/stores/auth'
import { UIUtil } from '@/utils/ui'
import { ToastMessages, StampDesigns, AppConfig } from '@/config/app'
import { getStampImageUrl } from '@/utils/stamp'
import { PostcardApi, UploadApi } from '@/services/api'
import type { Postcard } from '@/model/Postcard'
import {
  IconBack,
  IconCamera,
} from '@/components/icons'

const store     = usePostcardStore()
const authStore = useAuthStore()

const postcardId   = ref('')
const photoPath    = ref('')
const locationName = ref('')
const city         = ref('')
const country      = ref(AppConfig.defaultCountry)
const note         = ref('')
const stampDesign  = ref('classic')

const originalData = ref<Postcard | null>(null)
const hasChanges   = ref(false)

// Show only stamps the user owns; fall back to free stamps if store not yet populated
const stampGroups = computed(() => {
  const ownedSet = authStore.ownedStamps.length > 0
    ? new Set(authStore.ownedStamps)
    : new Set(['classic', 'nature', 'culture', 'city', 'ocean', 'sunset'])
  const map: Record<string, { series: string; seriesName: string; items: any[] }> = {}
  ;(StampDesigns as any[]).filter(s => ownedSet.has(s.id)).forEach(s => {
    if (!map[s.series]) map[s.series] = { series: s.series, seriesName: s.seriesName, items: [] }
    map[s.series].items.push(s)
  })
  return Object.values(map)
})

function padNum(id: string): string {
  const match = id.match(/\d+$/)
  return match ? String(match[0]).padStart(4, '0') : '0001'
}

function checkChanges(): boolean {
  if (!originalData.value) return false
  return (
    photoPath.value    !== originalData.value.photoUrl    ||
    locationName.value !== originalData.value.locationName ||
    city.value         !== originalData.value.city         ||
    country.value      !== originalData.value.country      ||
    note.value         !== originalData.value.note         ||
    stampDesign.value  !== originalData.value.stampDesign
  )
}

watch([photoPath, locationName, city, country, note, stampDesign], () => {
  hasChanges.value = checkChanges()
})

function selectImage() {
  uni.showActionSheet({
    itemList: ['拍照', '从相册选择'],
    success: (res) => {
      const sourceType = res.tapIndex === 0 ? ['camera'] : ['album']
      uni.chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType,
        success: (chooseRes) => {
          photoPath.value = chooseRes.tempFilePaths[0]
        },
        fail: () => UIUtil.showError(ToastMessages.error.image),
      })
    },
  })
}

function handleBack() {
  if (hasChanges.value) {
    uni.showModal({
      title: '提示',
      content: ToastMessages.confirm.leave,
      success: (res) => { if (res.confirm) uni.navigateBack() }
    })
  } else {
    uni.navigateBack()
  }
}

async function savePostcard() {
  if (!locationName.value || !city.value) {
    UIUtil.showError('请填写位置和城市信息')
    return
  }
  UIUtil.showLoading('保存中...')

  let finalPhotoUrl = photoPath.value
  if (finalPhotoUrl && !finalPhotoUrl.startsWith('http')) {
    try {
      const up = await UploadApi.image(finalPhotoUrl)
      finalPhotoUrl = up.url
    } catch {
      // keep local path
    }
  }

  const updates = {
    photoUrl:     finalPhotoUrl,
    locationName: locationName.value,
    city:         city.value,
    country:      country.value || AppConfig.defaultCountry,
    note:         note.value || '暂无备注',
    stampDesign:  stampDesign.value,
  }
  store.updatePostcard(postcardId.value, updates)
  try { await PostcardApi.update(postcardId.value, updates) } catch {}

  UIUtil.hideLoading()
  UIUtil.showSuccess(ToastMessages.success.save)
  setTimeout(() => uni.navigateBack(), 1500)
}

function confirmDelete() {
  uni.showModal({
    title: '确认删除',
    content: ToastMessages.confirm.delete,
    confirmColor: '#A43B2D',
    success: async (res) => {
      if (res.confirm) {
        store.deletePostcard(postcardId.value)
        try { await PostcardApi.remove(postcardId.value) } catch {}
        UIUtil.showSuccess(ToastMessages.success.delete)
        setTimeout(() => uni.switchTab({ url: '/pages/home/home' }), 1500)
      }
    }
  })
}

function loadPostcard() {
  const card = store.getPostcardById(postcardId.value)
  if (card) {
    originalData.value = { ...card }
    photoPath.value    = card.photoUrl
    locationName.value = card.locationName
    city.value         = card.city
    country.value      = card.country
    note.value         = card.note
    stampDesign.value  = card.stampDesign
  }
}

onLoad((options) => {
  if (options?.id) postcardId.value = options.id
})

onMounted(() => {
  store.initData()
  if (postcardId.value) loadPostcard()
})
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $page-background;
}

// ─── Sticky nav ───
.sticky-nav {
  position: sticky;
  top: 0;
  z-index: 20;
  background: $page-background;
  padding-top: 54px;
  padding-bottom: 32rpx;
  padding-left: 36rpx;
  padding-right: 36rpx;
  border-bottom: 1rpx solid $line-sepia;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-shrink: 0;
}

.nav-back-btn {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  border: 1rpx solid $line-sepia;
  background: $card-bg;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-center {
  text-align: center;
}

.nav-kicker {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  margin-bottom: 4rpx;
}

.nav-title {
  display: block;
  font-family: $font-family-body;
  font-size: 32rpx;
  font-weight: 700;
  color: $ink-black;
}

.nav-save-btn {
  padding: 14rpx 28rpx;
  border-radius: 999rpx;
  border: 1rpx solid $travel-blue;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-save-txt {
  font-family: $font-family-code;
  font-size: 24rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  font-weight: 600;
}

// ─── Scroll ───
.scroll-content {
  flex: 1;
  overflow: hidden;
}

.form-body {
  padding: 40rpx 40rpx 0;
  display: flex;
  flex-direction: column;
  gap: 28rpx;
}

// ─── Amber note banner ───
.note-banner {
  display: flex;
  align-items: flex-start;
  gap: 24rpx;
  padding: 24rpx 28rpx;
  background: #F9EFD9;
  border: 1rpx solid #E6D8B0;
  border-radius: 6rpx;
}

.banner-label {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: #A37E2D;
  flex-shrink: 0;
  padding-top: 4rpx;
}

.banner-msg {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: #6A5325;
  line-height: 1.6;
}

// ─── Photo ───
.photo-section {}

.photo-preview-wrap {
  position: relative;
  border-radius: 8rpx;
  overflow: hidden;
}

.photo-preview {
  width: 100%;
  height: 400rpx;
  border-radius: 8rpx;
}

.photo-change-btn {
  position: absolute;
  top: 20rpx;
  right: 20rpx;
  width: 64rpx;
  height: 64rpx;
  border-radius: 6rpx;
  background: rgba(20, 15, 10, 0.55);
  display: flex;
  align-items: center;
  justify-content: center;
}

.photo-upload-zone {
  border: 1rpx dashed $rule-color;
  border-radius: 8rpx;
  padding: 72rpx 0;
  background: $card-bg;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
}

.upload-title {
  font-family: $font-family-body;
  font-size: 32rpx;
  font-weight: 500;
  color: $ink-black;
}

.upload-hint {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

// ─── Form cards ───
.form-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 6rpx;
  padding: 24rpx 28rpx 28rpx;
}

.form-card-label-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.form-en-label {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  flex-shrink: 0;
}

.form-sep {
  width: 1rpx;
  height: 24rpx;
  background: $line-sepia;
}

.form-cn-label {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $body-text;
}

.form-required {
  font-family: $font-family-code;
  font-size: 22rpx;
  color: $stamp-red;
}

.form-input {
  font-family: $font-family-body;
  font-size: 30rpx;
  color: $ink-black;
  width: 100%;
  padding: 0;
}

.form-placeholder {
  color: $whisper;
}

.form-textarea {
  width: 100%;
  height: 180rpx;
  font-family: $font-family-body;
  font-style: italic;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.6;
  padding: 0;
  box-sizing: border-box;
}

.textarea-count {
  display: block;
  text-align: right;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  margin-top: 12rpx;
}

// ─── Stamp picker ───
.stamp-series-group {
  margin-top: 16rpx;

  &:first-child { margin-top: 4rpx; }
}

.stamp-series-lbl {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  margin-bottom: 12rpx;
}

.stamp-scroll {
  width: 100%;
}

.stamp-options {
  display: flex;
  gap: 16rpx;
  padding-bottom: 4rpx;
  width: max-content;
}

.stamp-option {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  padding: 16rpx 18rpx;
  border-radius: 6rpx;
  border: 1rpx solid $line-sepia;
  min-width: 120rpx;
  background: transparent;
  flex-shrink: 0;
}

.stamp-swatch {
  width: 68rpx;
  height: 84rpx;
  border: 1rpx dashed currentColor;
  border-radius: 3rpx;
  background: $page-background;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stamp-swatch-dot { font-size: 26rpx; }
.stamp-swatch-img { width: 100%; height: 100%; border-radius: 50%; }

.stamp-option-name {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $body-text;
  font-weight: 500;
}

// ─── Buttons ───
.save-btn {
  background: $travel-blue;
  border-radius: 6rpx;
  padding: 30rpx 0;
  text-align: center;
}

.save-btn-txt {
  font-family: $font-family-body;
  font-size: 28rpx;
  font-weight: 500;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

.delete-btn {
  padding: 26rpx 0;
  border-radius: 6rpx;
  border: 1rpx solid rgba(164, 59, 45, 0.2);
  text-align: center;
  margin-bottom: 8rpx;
}

.delete-btn-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $stamp-red;
}

.btm-gap { height: 120rpx; }
</style>

<template>
  <view class="page-container">
    <view class="custom-header">
      <view class="header-left" @click="handleBack">
        <IconBack :size="28" color="#fff" />
      </view>
      <text class="header-title">编辑明信片</text>
      <view class="header-right" @click="savePostcard">
        <IconCheck :size="28" color="#fff" />
      </view>
    </view>

    <view class="loading-overlay" v-if="store.isLoading">
      <view class="loading-content">
        <view class="loading-spinner"></view>
        <text class="loading-text">保存中...</text>
      </view>
    </view>

    <view class="content" v-else>
      <scroll-view scroll-y class="scroll-content">
        <view class="upload-section">
          <view class="upload-card" @click="selectImage">
            <view class="upload-icon">
              <IconCamera :size="48" color="#2E7D58" />
            </view>
            <text class="upload-text">{{ photoPath ? '点击更换照片' : '点击拍照或选择照片' }}</text>
            <text class="upload-hint">{{ photoPath ? '' : '支持拍照或从相册选择' }}</text>
          </view>
          <image v-if="photoPath" :src="photoPath" class="preview-image" mode="aspectFill" />
        </view>

        <view class="form-section">
          <view class="form-item">
            <view class="form-label-row">
              <IconLocation :size="24" color="#666" />
              <text class="form-label">位置</text>
            </view>
            <input
              class="form-input"
              v-model="locationName"
              placeholder="输入位置信息"
            />
          </view>

          <view class="form-item">
            <view class="form-label-row">
              <IconMap :size="24" color="#666" />
              <text class="form-label">城市</text>
            </view>
            <input
              class="form-input"
              v-model="city"
              placeholder="输入城市名称"
            />
          </view>

          <view class="form-item">
            <view class="form-label-row">
              <IconMap :size="24" color="#666" />
              <text class="form-label">国家</text>
            </view>
            <input
              class="form-input"
              v-model="country"
              placeholder="输入国家名称"
            />
          </view>

          <view class="form-item">
            <view class="form-label-row">
              <IconEdit :size="24" color="#666" />
              <text class="form-label">备注</text>
            </view>
            <textarea
              class="form-textarea"
              v-model="note"
              placeholder="记录下此刻的心情..."
              :maxlength="200"
            />
            <text class="textarea-count">{{ note.length }}/200</text>
          </view>

          <view class="form-item">
            <view class="form-label-row">
              <IconStampClassic :size="24" color="#666" />
              <text class="form-label">邮票样式</text>
            </view>
            <view class="stamp-options">
              <view
                v-for="stamp in stampOptions"
                :key="stamp.id"
                class="stamp-option"
                :class="{ active: stampDesign === stamp.id }"
                @click="stampDesign = stamp.id"
              >
                <component :is="getStampComponent(stamp.icon)" :size="32" :color="stamp.color" />
                <text class="stamp-name">{{ stamp.name }}</text>
              </view>
            </view>
          </view>
        </view>

        <view class="preview-section">
          <view class="section-header">
            <text class="section-title">明信片预览</text>
          </view>
          <view class="preview-card">
            <view class="preview-header">
              <text class="preview-brand">远方邮政</text>
            </view>
            <view class="preview-content">
              <view class="preview-image">
                <IconImage v-if="!photoPath" :size="48" color="#999" />
                <image v-else :src="photoPath" class="preview-image-src" mode="aspectFill" />
              </view>
              <view class="preview-info">
                <text class="preview-location">{{ locationName || '未知位置' }}</text>
                <text class="preview-city">{{ city }} · {{ country }}</text>
              </view>
              <text class="preview-note">{{ note || '写下你的心情...' }}</text>
            </view>
            <view class="preview-footer">
              <view class="preview-stamp">
                <component :is="getStampComponent(getStampIcon(stampDesign))" :size="28" :color="getStampColor(stampDesign)" />
              </view>
              <view class="preview-address">
                <text class="address-text">寄往远方</text>
              </view>
            </view>
          </view>
        </view>

        <view class="bottom-space"></view>
      </scroll-view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted, markRaw, watch } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { UIUtil } from '@/utils/ui'
import { ToastMessages, StampDesigns, AppConfig } from '@/config/app'
import type { Postcard } from '@/model/Postcard'
import {
  IconBack,
  IconCheck,
  IconCamera,
  IconLocation,
  IconMap,
  IconEdit,
  IconImage,
  IconStampClassic,
  IconStampNature,
  IconStampCulture,
  IconStampCity,
  IconStampSea,
  IconStampSunset
} from '@/components/icons'

const store = usePostcardStore()

const postcardId = ref('')
const isEditMode = ref(false)

const photoPath = ref('')
const locationName = ref('')
const city = ref('')
const country = ref(AppConfig.defaultCountry)
const note = ref('')
const stampDesign = ref('classic')

const originalData = ref<Postcard | null>(null)
const hasChanges = ref(false)

const stampOptions = StampDesigns

const stampComponents: Record<string, any> = {
  stampClassic: markRaw(IconStampClassic),
  stampNature: markRaw(IconStampNature),
  stampCulture: markRaw(IconStampCulture),
  stampCity: markRaw(IconStampCity),
  stampSea: markRaw(IconStampSea),
  stampSunset: markRaw(IconStampSunset),
}

function getStampIcon(design: string): string {
  const stamp = stampOptions.find(s => s.id === design)
  return stamp?.icon || 'stampClassic'
}

function getStampColor(design: string): string {
  const stamp = stampOptions.find(s => s.id === design)
  return stamp?.color || '#333'
}

function getStampComponent(iconName: string) {
  return stampComponents[iconName] || IconStampClassic
}

function selectImage() {
  uni.showActionSheet({
    itemList: ['拍照', '从相册选择'],
    success: (res) => {
      const sourceType = res.tapIndex === 0 ? ['camera'] : ['album']
      uni.chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType,
        success: (res) => {
          photoPath.value = res.tempFilePaths[0]
        },
        fail: () => {
          UIUtil.showError(ToastMessages.error.image)
        },
      })
    },
  })
}

function checkChanges() {
  if (!originalData.value) return false
  return (
    photoPath.value !== originalData.value.photoUrl ||
    locationName.value !== originalData.value.locationName ||
    city.value !== originalData.value.city ||
    country.value !== originalData.value.country ||
    note.value !== originalData.value.note ||
    stampDesign.value !== originalData.value.stampDesign
  )
}

watch([photoPath, locationName, city, country, note, stampDesign], () => {
  hasChanges.value = checkChanges()
})

function handleBack() {
  if (hasChanges.value) {
    uni.showModal({
      title: '提示',
      content: ToastMessages.confirm.leave,
      success: (res) => {
        if (res.confirm) {
          uni.navigateBack()
        }
      }
    })
  } else {
    uni.navigateBack()
  }
}

function savePostcard() {
  if (!locationName.value || !city.value) {
    UIUtil.showError('请填写位置和城市信息')
    return
  }

  UIUtil.showLoading('保存中...')

  const updatedPostcard = {
    id: postcardId.value,
    travelId: originalData.value?.travelId || 'travel-1',
    photoUrl: photoPath.value,
    locationName: locationName.value,
    city: city.value,
    country: country.value || AppConfig.defaultCountry,
    note: note.value || '暂无备注',
    stampDesign: stampDesign.value,
    isFavorite: originalData.value?.isFavorite || false,
    recordedAt: originalData.value?.recordedAt || Date.now(),
    createdAt: originalData.value?.createdAt || Date.now()
  }

  store.updatePostcard(updatedPostcard)

  setTimeout(() => {
    UIUtil.hideLoading()
    UIUtil.showSuccess(ToastMessages.success.save)
    setTimeout(() => {
      uni.navigateBack()
    }, 1500)
  }, 500)
}

function loadPostcard() {
  if (postcardId.value) {
    const card = store.getPostcardById(postcardId.value)
    if (card) {
      isEditMode.value = true
      originalData.value = { ...card }
      photoPath.value = card.photoUrl
      locationName.value = card.locationName
      city.value = card.city
      country.value = card.country
      note.value = card.note
      stampDesign.value = card.stampDesign
    }
  }
}

onLoad((options) => {
  if (options?.id) {
    postcardId.value = options.id
  }
})

onMounted(() => {
  store.initData()
  if (postcardId.value) {
    loadPostcard()
  }
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: #FAF7F2;
}

.custom-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 88rpx;
  padding-top: 44px;
  background: linear-gradient(135deg, #2E7D58 0%, #2E6E49 100%);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-left: 24rpx;
  padding-right: 24rpx;
  z-index: 100;
  box-sizing: border-box;
}

.header-left, .header-right {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.header-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #fff;
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
}

.loading-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.loading-spinner {
  width: 48rpx;
  height: 48rpx;
  border: 4rpx solid #F3F3F3;
  border-top: 4rpx solid #2E7D58;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-text {
  font-size: 26rpx;
  color: #666;
}

.content {
  padding-top: calc(88rpx + 44px);
}

.scroll-content {
  height: calc(100vh - 88rpx - 44px);
}

.upload-section {
  padding: 24rpx;
  box-sizing: border-box;
}

.upload-card {
  background: #fff;
  border-radius: 24rpx;
  padding: 60rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
  border: 2rpx dashed #E0D5C0;
}

.upload-icon {
  width: 120rpx;
  height: 120rpx;
  background: #F5F5DC;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.upload-text {
  font-size: 30rpx;
  font-weight: 600;
  color: #2C2C2C;
}

.upload-hint {
  font-size: 24rpx;
  color: #999;
}

.preview-image {
  width: 100%;
  height: 300rpx;
  border-radius: 16rpx;
  margin-top: 16rpx;
}

.form-section {
  padding: 0 24rpx;
  box-sizing: border-box;
}

.form-item {
  background: #fff;
  border-radius: 20rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.04);
}

.form-label-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 16rpx;
}

.form-label {
  font-size: 26rpx;
  color: #666;
}

.form-input {
  font-size: 28rpx;
  color: #2C2C2C;
}

.form-textarea {
  width: 100%;
  height: 160rpx;
  font-size: 28rpx;
  color: #2C2C2C;
  background: #F8F8F8;
  border-radius: 12rpx;
  padding: 16rpx;
  box-sizing: border-box;
}

.textarea-count {
  font-size: 22rpx;
  color: #999;
  text-align: right;
  margin-top: 8rpx;
  display: block;
}

.stamp-options {
  display: flex;
  gap: 16rpx;
}

.stamp-option {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  padding: 20rpx;
  background: #F8F8F8;
  border-radius: 16rpx;
  border: 2rpx solid transparent;
  transition: all 0.2s ease;
}

.stamp-option.active {
  background: rgba(46, 125, 88, 0.1);
  border-color: #2E7D58;
}

.stamp-name {
  font-size: 22rpx;
  color: #666;
}

.preview-section {
  padding: 24rpx;
  box-sizing: border-box;
}

.section-header {
  margin-bottom: 16rpx;
}

.section-title {
  font-size: 30rpx;
  font-weight: 700;
  color: #2C2C2C;
}

.preview-card {
  background: #fff;
  border-radius: 24rpx;
  overflow: hidden;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
}

.preview-header {
  background: linear-gradient(135deg, #2E7D58 0%, #2E6E49 100%);
  padding: 20rpx;
  text-align: center;
}

.preview-brand {
  font-size: 28rpx;
  font-weight: 700;
  color: #fff;
  font-family: 'Georgia', serif;
}

.preview-content {
  padding: 24rpx;
}

.preview-image {
  width: 100%;
  height: 300rpx;
  background: #F5F5DC;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16rpx;
}

.preview-image-src {
  width: 100%;
  height: 100%;
  border-radius: 16rpx;
}

.preview-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12rpx;
}

.preview-location {
  font-size: 28rpx;
  font-weight: 600;
  color: #2C2C2C;
}

.preview-city {
  font-size: 24rpx;
  color: #999;
}

.preview-note {
  font-size: 26rpx;
  color: #666;
  line-height: 1.6;
}

.preview-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 24rpx;
  border-top: 1rpx solid #F0F0F0;
}

.preview-stamp {
  width: 80rpx;
  height: 80rpx;
  background: #F5F5DC;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-address {
  padding: 8rpx 20rpx;
  background: rgba(46, 125, 88, 0.1);
  border-radius: 999rpx;
}

.address-text {
  font-size: 24rpx;
  color: #2E7D58;
}

.bottom-space {
  height: 120rpx;
}
</style>
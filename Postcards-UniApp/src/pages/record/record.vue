<template>
  <view class="page-container">
    <view class="header">
      <text class="header-title">记录明信片</text>
      <text class="header-subtitle">记录旅途的美好时光</text>
    </view>

    <scroll-view class="content" scroll-y>
      <view class="upload-section">
        <view class="upload-card" @click="selectImage">
          <view class="upload-icon">
            <IconCamera :size="48" color="#2E7D58" />
          </view>
          <text class="upload-text">{{ photoPath ? '点击更换照片' : '点击拍照或选择照片' }}</text>
          <text class="upload-hint">{{ photoPath ? '' : '支持拍照或从相册选择' }}</text>
        </view>
      </view>

      <view class="form-section">
        <view class="form-item">
          <view class="form-label-row">
            <IconLocation :size="24" color="#666" />
            <text class="form-label">位置</text>
          </view>
          <view class="location-row" @click="getLocation">
            <input
              class="form-input"
              :value="locationName"
              placeholder="点击获取当前位置"
              disabled
            />
            <view class="location-btn">
              <IconLocation :size="24" :color="isLocating ? '#2E7D58' : '#999'" />
            </view>
          </view>
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

      <view class="submit-section">
        <view class="submit-btn" :class="{ disabled: !canSubmit }" @click="submitPostcard">
          <text class="submit-text">寄出明信片</text>
        </view>
      </view>

      <view class="bottom-space"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, markRaw } from 'vue'
import { usePostcardStore } from '@/stores/postcard'
import { UIUtil } from '@/utils/ui'
import { ToastMessages, StampDesigns, AppConfig } from '@/config/app'
import { 
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

const photoPath = ref('')
const locationName = ref('')
const city = ref('')
const country = ref(AppConfig.defaultCountry)
const note = ref('')
const stampDesign = ref('classic')
const isLocating = ref(false)

const stampOptions = StampDesigns

const stampComponents: Record<string, any> = {
  stampClassic: markRaw(IconStampClassic),
  stampNature: markRaw(IconStampNature),
  stampCulture: markRaw(IconStampCulture),
  stampCity: markRaw(IconStampCity),
  stampSea: markRaw(IconStampSea),
  stampSunset: markRaw(IconStampSunset),
}

const canSubmit = computed(() => {
  return photoPath.value || (locationName.value && city.value && note.value)
})

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

function getLocation() {
  isLocating.value = true
  uni.getLocation({
    type: 'gcj02',
    success: (res) => {
      isLocating.value = false
      locationName.value = `纬度: ${res.latitude.toFixed(4)}, 经度: ${res.longitude.toFixed(4)}`
      if (!city.value) {
        city.value = '未知城市'
      }
      UIUtil.showSuccess(ToastMessages.success.location)
    },
    fail: () => {
      isLocating.value = false
      UIUtil.showError(ToastMessages.error.location)
    },
  })
}

function submitPostcard() {
  if (!canSubmit.value) {
    UIUtil.showError('请填写必要信息')
    return
  }

  const newPostcard = {
    id: `card-${Date.now()}`,
    travelId: store.currentTravel?.id || 'travel-1',
    photoUrl: photoPath.value,
    locationName: locationName.value || '未知位置',
    city: city.value || '未知城市',
    country: country.value || AppConfig.defaultCountry,
    note: note.value || '暂无备注',
    stampDesign: stampDesign.value,
    isFavorite: false,
    recordedAt: Date.now(),
    createdAt: Date.now()
  }

  store.addPostcard(newPostcard)

  UIUtil.showSuccess('明信片已寄出')

  setTimeout(() => {
    uni.switchTab({ url: '/pages/home/home' })
  }, 1500)
}

onMounted(() => {
  store.initData()
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: #FAF7F2;
}

.header {
  background: linear-gradient(135deg, #2E7D58 0%, #2E6E49 100%);
  padding: 120rpx 40rpx 40rpx;
}

.header-title {
  font-size: 44rpx;
  font-weight: 700;
  color: #fff;
  font-family: 'Georgia', serif;
  display: block;
  margin-bottom: 8rpx;
}

.header-subtitle {
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.85);
}

.content {
  height: calc(100vh - 220rpx);
  padding: 24rpx;
  box-sizing: border-box;
  width: 100%;
}

.upload-section {
  margin-bottom: 24rpx;
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

.icon-text {
  font-size: 48rpx;
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

.form-section {
  margin-bottom: 32rpx;
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

.location-row {
  display: flex;
  align-items: center;
}

.form-input {
  flex: 1;
  font-size: 28rpx;
  color: #2C2C2C;
}

.location-btn {
  width: 72rpx;
  height: 72rpx;
  background: #F5F5DC;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-left: 16rpx;
}

.btn-icon {
  font-size: 28rpx;
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

.stamp-icon {
  font-size: 36rpx;
}

.stamp-name {
  font-size: 22rpx;
  color: #666;
}

.preview-section {
  margin-bottom: 32rpx;
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

.image-placeholder {
  font-size: 64rpx;
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

.stamp-text {
  font-size: 32rpx;
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

.submit-section {
  padding-bottom: 40rpx;
}

.submit-btn {
  background: linear-gradient(135deg, #2E7D58 0%, #2E6E49 100%);
  padding: 28rpx;
  border-radius: 999rpx;
  text-align: center;
  box-shadow: 0 8rpx 24rpx rgba(46, 125, 88, 0.3);
}

.submit-btn.disabled {
  background: #DDDDDD;
  box-shadow: none;
}

.submit-text {
  font-size: 32rpx;
  font-weight: 600;
  color: #fff;
}

.bottom-space {
  height: 120rpx;
}
</style>
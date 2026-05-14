<template>
  <view class="page-container">
    <view class="postal-header">
      <view class="header-perf"></view>
      <text class="header-kicker">NEW POSTCARD · 寄往未来</text>
      <text class="header-title">记录明信片</text>
      <text class="header-subtitle">从这里寄出一张明信片</text>
    </view>

    <scroll-view class="content" scroll-y>
      <view class="form-wrap">
        <!-- Photo upload -->
        <view v-if="!photoPath" class="upload-zone" @click="selectImage">
          <IconCamera :size="56" color="#3C604D" />
          <text class="upload-title">点击拍照或选择照片</text>
          <text class="upload-meta">4:3 · MAX 5MB</text>
        </view>
        <view v-else class="photo-preview-wrap" @click="selectImage">
          <image :src="photoPath" class="photo-preview" mode="aspectFill" />
          <view class="photo-change-btn">
            <IconCamera :size="28" color="#FBF8F1" />
          </view>
        </view>

        <!-- Location -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">LOCATION</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">位置</text>
            <text class="form-required">*</text>
          </view>
          <view class="form-input-row">
            <input class="form-input" v-model="locationName" placeholder="点击定位或手动输入" />
            <view class="locate-btn" @click="getLocation">
              <IconLocation :size="28" :color="isLocating ? '#3C604D' : '#8E8775'" />
              <text class="locate-btn-txt">定位</text>
            </view>
          </view>
        </view>

        <!-- City -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">CITY</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">城市</text>
            <text class="form-required">*</text>
          </view>
          <input class="form-input" v-model="city" placeholder="输入城市名称" />
        </view>

        <!-- Country -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">COUNTRY</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">国家</text>
          </view>
          <input class="form-input" v-model="country" placeholder="输入国家名称" />
        </view>

        <!-- Note -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">MESSAGE</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">备注</text>
          </view>
          <textarea
            class="form-textarea"
            v-model="note"
            placeholder="记录下此刻的心情..."
            :maxlength="200"
          />
          <text class="char-count">{{ note.length }} / 200</text>
        </view>

        <!-- Journey selector -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">JOURNEY</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">所属旅程</text>
            <text class="form-required">*</text>
          </view>
          <view v-if="travelOptions.length > 0" class="travel-pick-wrap">
            <picker :range="travelOptions" range-key="label" :value="selectedTravelIdx" @change="onTravelChange">
              <view class="travel-pick-row">
                <view class="travel-pick-info">
                  <text class="travel-pick-name">{{ selectedTravel?.title || '选择旅程' }}</text>
                  <text class="travel-pick-dest">{{ selectedTravel?.destination || '' }}</text>
                </view>
                <text class="travel-pick-arr">›</text>
              </view>
            </picker>
            <view class="travel-new-link" @click="goCreateTravel">
              <text class="travel-new-txt">+ 新建旅程</text>
            </view>
          </view>
          <view v-else class="travel-empty-wrap">
            <text class="travel-empty-hint">明信片需归属一段旅程</text>
            <view class="travel-empty-btn" @click="goCreateTravel">
              <text class="travel-empty-btn-txt">新建旅程 ›</text>
            </view>
          </view>
        </view>

        <!-- Stamp picker — grouped by series -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">STAMP</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">邮票样式</text>
          </view>
          <view v-for="group in stampGroups" :key="group.series" class="stamp-series-block">
            <text class="stamp-series-label">SÉRIE {{ group.series }} · {{ group.seriesName }}</text>
            <scroll-view class="stamp-scroll" scroll-x>
              <view class="stamp-row">
                <view
                  v-for="s in group.items"
                  :key="s.id"
                  class="stamp-option"
                  :class="{ 'stamp-selected': stampDesign === s.id }"
                  :style="stampDesign === s.id ? { 'border-color': s.color, background: s.color + '18' } : {}"
                  @click="stampDesign = s.id"
                >
                  <view class="stamp-swatch" :style="{ 'border-color': s.color }">
                    <image v-if="s.imageUrl" :src="s.imageUrl" class="stamp-swatch-img" mode="aspectFill" />
                    <text v-else class="stamp-swatch-dot" :style="{ color: s.color }">✦</text>
                  </view>
                  <text class="stamp-name" :style="stampDesign === s.id ? { color: s.color } : {}">{{ s.name }}</text>
                </view>
              </view>
            </scroll-view>
          </view>
        </view>

        <!-- Live preview — front + back -->
        <view class="preview-section">
          <view class="preview-hd">
            <text class="section-kicker">LIVE PREVIEW · 预览</text>
            <text class="preview-ttl">明信片</text>
          </view>
          <view class="preview-rule"></view>
          <view class="postcard-preview">
            <!-- Front: photo -->
            <view class="pc-photo-wrap">
              <image v-if="photoPath" :src="photoPath" class="pc-photo" mode="aspectFill" />
              <view v-else class="pc-photo-empty">
                <IconImage :size="48" color="#B5AE9B" />
              </view>
              <view class="pc-photo-overlay">
                <text class="pc-city-code">{{ city ? city.toUpperCase() : 'CITY' }}</text>
              </view>
            </view>
            <!-- Back: divider layout -->
            <view class="pc-back">
              <view class="pc-back-left">
                <text class="pc-back-label">MESSAGE · 留言</text>
                <view class="pc-back-line"></view>
                <text class="pc-back-note">"{{ note || '写下你的心情...' }}"</text>
                <view class="pc-back-line"></view>
                <view class="pc-back-line"></view>
              </view>
              <view class="pc-vdivider"></view>
              <view class="pc-back-right">
                <view class="pc-stamp-box" :style="{ 'border-color': currentStampColor }">
                  <text class="pc-stamp-dot" :style="{ color: currentStampColor }">✦</text>
                </view>
                <view class="pc-addr-from">
                  <text class="pc-addr-label">FROM</text>
                  <text class="pc-addr-main">{{ locationName || '位置名称' }}</text>
                  <text class="pc-addr-sub">{{ city || '城市' }}</text>
                </view>
                <view class="pc-addr-sep"></view>
                <view class="pc-addr-to">
                  <text class="pc-addr-label">TO</text>
                  <text class="pc-addr-main">未来的我</text>
                </view>
              </view>
            </view>
            <view class="pc-footer">
              <text class="pc-footer-left">旅行邮局 · 寄往远方</text>
              <text class="pc-footer-right">CN — 0001</text>
            </view>
          </view>
        </view>

        <!-- Submit -->
        <view
          class="submit-btn"
          :class="{ 'submit-disabled': !canSubmit }"
          @click="submitPostcard"
        >
          <text class="submit-txt">寄出明信片 ›</text>
        </view>
        <text class="submit-sub">POSTAGE PAID · 旅邮</text>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>

    <!-- ── 寄信动画 · 邮件寄出覆盖层 ── -->
    <view v-if="isSending" class="send-overlay">
      <view class="send-scene" :class="'phase-' + sendPhase">

        <!-- 明信片缩略 -->
        <view class="send-mini-card">
          <view class="send-mini-top">
            <image v-if="photoPath" :src="photoPath" class="send-mini-img" mode="aspectFill" />
            <view v-else class="send-mini-img-ph"></view>
            <text class="send-mini-city">{{ city ? city.toUpperCase() : 'CITY' }}</text>
          </view>
          <view class="send-mini-bot">
            <text class="send-mini-to">TO · 未来的我</text>
            <view class="send-mini-stmp" :style="{ borderColor: currentStampColor }">
              <text class="send-mini-sdot" :style="{ color: currentStampColor }">✦</text>
            </view>
          </view>
        </view>

        <!-- 信封 + 邮戳 -->
        <view class="send-env-group">
          <view class="send-env">
            <view class="send-env-airmail"></view>
            <view class="send-env-body">
              <view class="send-env-seal-flap"></view>
              <view class="send-env-interior">
                <text class="send-env-par">PAR AVION · 挂号信</text>
              </view>
            </view>
            <view class="send-env-airmail"></view>
          </view>
          <view class="send-pm">
            <view class="send-pm-ring send-pm-outer"></view>
            <view class="send-pm-ring send-pm-inner"></view>
            <view class="send-pm-txt">
              <text class="send-pm-city">{{ (city || 'CN').toUpperCase().slice(0, 4) }}</text>
              <text class="send-pm-date">{{ nowDotDate }}</text>
            </view>
          </view>
        </view>

        <!-- 阶段提示 -->
        <text class="send-phase-lbl">{{ sendPhaseLbl }}</text>

        <!-- 成功 -->
        <view class="send-ok">
          <text class="send-ok-check">✓</text>
          <text class="send-ok-main">已寄出</text>
          <text class="send-ok-sub">POSTED · 明信片已寄往远方</text>
        </view>

      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { usePostcardStore } from '@/stores/postcard'
import { useAuthStore } from '@/stores/auth'
import { UIUtil } from '@/utils/ui'
import { ToastMessages, StampDesigns, AppConfig } from '@/config/app'
import { PostcardApi, UploadApi } from '@/services/api'
import {
  IconCamera,
  IconLocation,
  IconImage,
} from '@/components/icons'

const store     = usePostcardStore()
const authStore = useAuthStore()

const photoPath    = ref('')
const locationName = ref('')
const city         = ref('')
const country      = ref(AppConfig.defaultCountry)
const note         = ref('')
const stampDesign        = ref('classic')
const isLocating         = ref(false)
const selectedTravelId   = ref('')
const isSending    = ref(false)
const sendPhase    = ref('idle')
const nowDotDate   = ref('')

const canSubmit = computed(() =>
  (photoPath.value || (locationName.value && city.value && note.value)) && selectedTravelId.value
)

const travelOptions = computed(() =>
  store.sortedTravels.map(t => ({ label: `${t.title} · ${t.destination}`, id: t.id }))
)

const selectedTravelIdx = computed(() => {
  const idx = store.sortedTravels.findIndex(t => t.id === selectedTravelId.value)
  return idx >= 0 ? idx : 0
})

const selectedTravel = computed(() =>
  store.sortedTravels.find(t => t.id === selectedTravelId.value) || null
)

const sendPhaseLbl = computed(() => {
  if (sendPhase.value === 'sealing')  return 'SEALING · 封装中...'
  if (sendPhase.value === 'stamping') return 'STAMPING · 盖章中...'
  if (sendPhase.value === 'flying')   return 'DISPATCHING · 寄出中...'
  return ''
})

const currentStampColor = computed(() =>
  StampDesigns.find(s => s.id === stampDesign.value)?.color ?? '#8E8775'
)

function onTravelChange(e: any) {
  selectedTravelId.value = store.sortedTravels[e.detail.value]?.id || ''
}

function goCreateTravel() {
  uni.navigateTo({ url: '/pages/travel/travel' })
}

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

function selectImage() {
  uni.showActionSheet({
    itemList: ['拍照', '从相册选择'],
    success: (res) => {
      const sourceType = res.tapIndex === 0 ? ['camera'] : ['album']
      uni.chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType,
        success: (res) => { photoPath.value = res.tempFilePaths[0] },
        fail: () => UIUtil.showError(ToastMessages.error.image),
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
      locationName.value = `${res.latitude.toFixed(4)}°N, ${res.longitude.toFixed(4)}°E`
      if (!city.value) city.value = '未知城市'
      UIUtil.showSuccess(ToastMessages.success.location)
    },
    fail: () => {
      isLocating.value = false
      UIUtil.showError(ToastMessages.error.location)
    },
  })
}

async function submitPostcard() {
  if (!canSubmit.value) {
    UIUtil.showError('请填写必要信息')
    return
  }

  let photoUrl = photoPath.value
  if (photoUrl && !photoUrl.startsWith('http')) {
    uni.showLoading({ title: '上传中…', mask: true })
    try {
      const up = await UploadApi.image(photoUrl)
      photoUrl = up.url
    } catch {
      // keep local path as fallback
    } finally {
      uni.hideLoading()
    }
  }

  const localCard = {
    id: `card-${Date.now()}`,
    travelId: selectedTravelId.value,
    photoUrl,
    locationName: locationName.value || '未知位置',
    city: city.value || '未知城市',
    country: country.value || AppConfig.defaultCountry,
    note: note.value || '暂无备注',
    stampDesign: stampDesign.value,
    isFavorite: false,
    recordedAt: Date.now(),
    createdAt: Date.now(),
  }
  try {
    const serverCard = await PostcardApi.create(localCard)
    store.addPostcard(serverCard)
  } catch {
    store.addPostcard(localCard)
  }
  const d = new Date()
  nowDotDate.value = `${String(d.getMonth() + 1).padStart(2, '0')}·${String(d.getDate()).padStart(2, '0')}`
  isSending.value = true
  sendPhase.value = 'sealing'
  setTimeout(() => { sendPhase.value = 'stamping' }, 900)
  setTimeout(() => { sendPhase.value = 'flying' }, 1700)
  setTimeout(() => { sendPhase.value = 'done' }, 2400)
  setTimeout(() => {
    isSending.value = false
    sendPhase.value = 'idle'
    uni.switchTab({ url: '/pages/home/home' })
  }, 3800)
}

onMounted(() => store.initData())
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $page-background;
}

.postal-header {
  background: $page-background;
  padding: 100rpx 48rpx 40rpx;
  border-bottom: 1rpx solid $line-sepia;
  position: relative;
  flex-shrink: 0;
}

.header-perf {
  position: absolute;
  top: 90rpx;
  left: 0;
  right: 0;
  height: 2rpx;
  background-image: repeating-linear-gradient(
    90deg, $line-sepia 0, $line-sepia 8rpx, transparent 8rpx, transparent 16rpx
  );
}

.header-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 4rpx;
  color: $travel-blue;
  margin-bottom: 22rpx;
}

.header-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 58rpx;
  font-weight: 400;
  color: $ink-black;
  line-height: 1.15;
}

.header-subtitle {
  display: block;
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $body-text;
  margin-top: 18rpx;
}

.content { flex: 1; overflow: hidden; }

.form-wrap {
  padding: 40rpx 40rpx 0;
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

// ─── Photo ───
.upload-zone {
  border: 2rpx dashed $rule-color;
  border-radius: 12rpx;
  padding: 72rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  background: $card-bg;
}

.upload-title {
  font-family: $font-family-serif;
  font-size: 32rpx;
  font-weight: 500;
  color: $ink-black;
}

.upload-meta {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

.photo-preview-wrap {
  position: relative;
  border-radius: 12rpx;
  overflow: hidden;
}

.photo-preview {
  width: 100%;
  height: 420rpx;
  border-radius: 12rpx;
}

.photo-change-btn {
  position: absolute;
  top: 20rpx;
  right: 20rpx;
  width: 64rpx;
  height: 64rpx;
  border-radius: 12rpx;
  background: rgba(20, 15, 10, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

// ─── Form cards ───
.form-card {
  background: $card-bg;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  padding: 24rpx 32rpx;
}

.form-label-row {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 16rpx;
}

.form-lbl-en {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

.form-lbl-sep {
  color: $whisper;
  font-size: 18rpx;
}

.form-lbl-cn {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: $mute-text;
}

.form-required {
  color: $stamp-red;
  font-size: 22rpx;
  margin-left: -4rpx;
}

.form-input-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.form-input {
  flex: 1;
  font-family: $font-family-serif;
  font-size: 30rpx;
  color: $ink-black;
  letter-spacing: 0.4rpx;
  min-width: 0;
}

.locate-btn {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 10rpx 20rpx;
  border: 1rpx solid rgba(60, 96, 77, 0.4);
  border-radius: 6rpx;
  flex-shrink: 0;
}

.locate-btn-txt {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.form-textarea {
  width: 100%;
  min-height: 160rpx;
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.6;
  box-sizing: border-box;
}

.char-count {
  display: block;
  text-align: right;
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  margin-top: 8rpx;
}

// ─── Stamp picker ───
.stamp-series-block {
  margin-top: 16rpx;

  &:first-child { margin-top: 4rpx; }
}

.stamp-series-label {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
  margin-bottom: 12rpx;
}

.stamp-scroll {
  width: 100%;
}

.stamp-row {
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
  padding: 16rpx 20rpx;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  min-width: 120rpx;
  flex-shrink: 0;
  background: transparent;
}

.stamp-swatch {
  width: 72rpx;
  height: 88rpx;
  border: 1rpx dashed currentColor;
  background: $paper-beige;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 3rpx;
}

.stamp-swatch-dot { font-size: 28rpx; }
.stamp-swatch-img { width: 100%; height: 100%; border-radius: 50%; }

.stamp-name {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: $body-text;
  font-weight: 500;
}

// ─── Postcard preview ───
.preview-section {
  margin-top: 8rpx;
}

.preview-hd {
  margin-bottom: 16rpx;
}

.section-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 8rpx;
}

.preview-ttl {
  display: block;
  font-family: $font-family-serif;
  font-weight: 500;
  font-size: 38rpx;
  color: $ink-black;
}

.preview-rule {
  height: 1rpx;
  background: $line-sepia;
  margin-bottom: 24rpx;
}

.postcard-preview {
  background: $card-bg;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  overflow: hidden;
  box-shadow: 0 16rpx 40rpx rgba(40, 30, 15, 0.10);
  transform: rotate(-0.5deg);
}

// Front: photo
.pc-photo-wrap {
  position: relative;
  height: 260rpx;
  overflow: hidden;
  background: linear-gradient(180deg, #C9D2B6 0%, #6E8862 100%);
}

.pc-photo { width: 100%; height: 100%; }

.pc-photo-empty {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.pc-photo-overlay {
  position: absolute;
  top: 16rpx;
  right: 20rpx;
}

.pc-city-code {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 4rpx;
  color: rgba(244, 239, 229, 0.8);
}

// Back: two-column layout
.pc-back {
  display: flex;
  padding: 24rpx 24rpx 16rpx;
  gap: 0;
  min-height: 240rpx;
}

.pc-back-left {
  flex: 1;
  min-width: 0;
  padding-right: 20rpx;
}

.pc-back-label {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 14rpx;
}

.pc-back-line {
  height: 1rpx;
  background: $line-sepia;
  margin: 18rpx 0;
}

.pc-back-note {
  display: block;
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 24rpx;
  color: $ink-black;
  line-height: 1.65;
}

.pc-vdivider {
  width: 1rpx;
  background: $line-sepia;
  flex-shrink: 0;
}

.pc-back-right {
  width: 190rpx;
  flex-shrink: 0;
  padding-left: 20rpx;
  display: flex;
  flex-direction: column;
}

.pc-stamp-box {
  width: 72rpx;
  height: 88rpx;
  border: 1rpx dashed currentColor;
  border-radius: 3rpx;
  background: $page-background;
  display: flex;
  align-items: center;
  justify-content: center;
  align-self: flex-end;
  margin-bottom: 16rpx;
}

.pc-stamp-dot { font-size: 24rpx; }

.pc-addr-from,
.pc-addr-to { flex: 1; }

.pc-addr-label {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 6rpx;
}

.pc-addr-main {
  display: block;
  font-family: $font-family-serif;
  font-size: 22rpx;
  font-weight: 500;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 3rpx;
}

.pc-addr-sub {
  display: block;
  font-family: $font-family-mono;
  font-size: 14rpx;
  color: $mute-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pc-addr-sep {
  height: 1rpx;
  background: $line-sepia;
  margin: 12rpx 0;
}

.pc-footer {
  border-top: 1rpx solid $line-sepia;
  padding: 14rpx 24rpx;
  display: flex;
  justify-content: space-between;
  background: $paper-beige;
}

.pc-footer-left,
.pc-footer-right {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}

// ─── Submit ───
.submit-btn {
  background: $travel-blue;
  border-radius: 8rpx;
  padding: 32rpx 0;
  text-align: center;
  margin-top: 8rpx;
}

.submit-disabled {
  background: $line-sepia;
}

.submit-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $card-bg;
  letter-spacing: 12rpx;
}

.submit-sub {
  display: block;
  text-align: center;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 4rpx;
  color: $mute-text;
  margin-top: 16rpx;
}

.btm-gap { height: 120rpx; }

// ─── 寄信动画 · 邮件寄出覆盖层 ───
.send-overlay {
  position: fixed;
  inset: 0;
  background: rgba(16, 12, 8, 0.93);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}

.send-scene {
  position: relative;
  width: 500rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 48rpx;
  padding-bottom: 60rpx;
}

// ── Mini postcard ──
.send-mini-card {
  width: 380rpx;
  border-radius: 8rpx;
  border: 2rpx solid #D4C9B0;
  background: #FBF8F1;
  overflow: hidden;
  box-shadow: 0 24rpx 80rpx rgba(0, 0, 0, 0.55);
  flex-shrink: 0;

  .phase-sealing & { animation: mc-drop-in 0.55s cubic-bezier(0.34, 1.56, 0.64, 1) both; }
  .phase-stamping & { animation: mc-into-env 0.5s ease-in both; }
  .phase-flying &, .phase-done & { visibility: hidden; }
}

@keyframes mc-drop-in {
  from { transform: translateY(-340rpx) rotate(-8deg); opacity: 0; }
  to   { transform: translateY(0) rotate(-2deg); opacity: 1; }
}
@keyframes mc-into-env {
  from { transform: translateY(0) rotate(-2deg); opacity: 1; }
  to   { transform: translateY(300rpx) rotate(0deg) scale(0.4); opacity: 0; }
}

.send-mini-top {
  height: 160rpx;
  position: relative;
  overflow: hidden;
  background: linear-gradient(160deg, #B5C4A8 0%, #6E8862 100%);
}
.send-mini-img { width: 100%; height: 100%; }
.send-mini-img-ph { width: 100%; height: 100%; }
.send-mini-city {
  position: absolute;
  bottom: 12rpx;
  left: 16rpx;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 4rpx;
  color: rgba(251, 248, 241, 0.92);
}
.send-mini-bot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16rpx 20rpx;
  border-top: 1rpx solid #E8E0D0;
}
.send-mini-to {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: #3D3328;
}
.send-mini-stmp {
  width: 52rpx;
  height: 64rpx;
  border: 1rpx dashed currentColor;
  border-radius: 2rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}
.send-mini-sdot { font-size: 20rpx; }

// ── Envelope group ──
.send-env-group {
  position: relative;
  width: 440rpx;
  flex-shrink: 0;

  .phase-sealing & { animation: env-rise 0.6s 0.15s cubic-bezier(0.34, 1.56, 0.64, 1) both; }
  .phase-stamping & { opacity: 1; }
  .phase-flying & { animation: env-fly 0.85s ease-in both; }
  .phase-done & { opacity: 0; }
}

@keyframes env-rise {
  from { transform: translateY(240rpx); opacity: 0; }
  to   { transform: translateY(0); opacity: 1; }
}
@keyframes env-fly {
  from { transform: translateY(0) rotate(0deg); opacity: 1; }
  to   { transform: translateY(-660rpx) rotate(-13deg); opacity: 0; }
}

.send-env {
  background: #F5EDD8;
  border: 2rpx solid #C8BAA0;
  border-radius: 6rpx;
  overflow: hidden;
}
.send-env-airmail {
  height: 14rpx;
  background: repeating-linear-gradient(
    45deg,
    #C4312A 0, #C4312A 10rpx,
    transparent 10rpx, transparent 20rpx,
    #1F4B66 20rpx, #1F4B66 30rpx,
    transparent 30rpx, transparent 40rpx
  );
}
.send-env-body {
  position: relative;
  height: 190rpx;
  overflow: hidden;
}
.send-env-interior {
  position: absolute;
  bottom: 24rpx;
  left: 32rpx;
}
.send-env-par {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: #9B8E72;
}
.send-env-seal-flap {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 50%;
  background: #E8D9B8;
  border-bottom: 1rpx solid #C8BAA0;
  transform: scaleY(0);
  transform-origin: top center;

  .phase-stamping &, .phase-flying & {
    animation: flap-seal 0.35s 0.05s ease-out both;
  }
}
@keyframes flap-seal {
  from { transform: scaleY(0); }
  to   { transform: scaleY(1); }
}

// ── Postmark stamp ──
.send-pm {
  position: absolute;
  right: 56rpx;
  top: 30rpx;
  width: 120rpx;
  height: 120rpx;
  display: flex;
  align-items: center;
  justify-content: center;

  .phase-sealing & {
    opacity: 0;
    transform: translateY(-200rpx) scale(1.4);
  }
  .phase-stamping & {
    animation: pm-stamp 0.55s 0.15s cubic-bezier(0.34, 1.56, 0.64, 1) both;
  }
}
@keyframes pm-stamp {
  0%   { transform: translateY(-200rpx) scale(1.4); opacity: 0; }
  55%  { transform: translateY(4rpx) scale(0.88); opacity: 1; }
  75%  { transform: translateY(-6rpx) scale(1.06); }
  100% { transform: translateY(0) scale(1); opacity: 1; }
}
.send-pm-ring {
  position: absolute;
  border-radius: 50%;
  border: 2rpx solid rgba(164, 59, 45, 0.85);
}
.send-pm-outer { width: 120rpx; height: 120rpx; }
.send-pm-inner { width: 96rpx; height: 96rpx; }
.send-pm-txt {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4rpx;
}
.send-pm-city {
  font-family: $font-family-mono;
  font-size: 14rpx;
  letter-spacing: 2rpx;
  color: rgba(164, 59, 45, 0.9);
}
.send-pm-date {
  font-family: $font-family-serif;
  font-size: 22rpx;
  font-weight: 500;
  color: rgba(164, 59, 45, 0.9);
  line-height: 1.1;
}

// ── Phase label ──
.send-phase-lbl {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 4rpx;
  color: rgba(251, 248, 241, 0.45);

  .phase-done & { opacity: 0; }
}

// ── Success ──
.send-ok {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%) scale(0.5);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
  opacity: 0;
  pointer-events: none;

  .phase-done & { animation: ok-appear 0.65s cubic-bezier(0.34, 1.56, 0.64, 1) both; }
}
@keyframes ok-appear {
  from { transform: translate(-50%, -50%) scale(0.5); opacity: 0; }
  to   { transform: translate(-50%, -50%) scale(1); opacity: 1; }
}
.send-ok-check {
  font-size: 100rpx;
  color: $travel-blue;
  line-height: 1;
}
.send-ok-main {
  font-family: $font-family-serif;
  font-size: 54rpx;
  color: #F4EFE5;
  letter-spacing: 10rpx;
}
.send-ok-sub {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 4rpx;
  color: rgba(244, 239, 229, 0.45);
  text-align: center;
}
</style>

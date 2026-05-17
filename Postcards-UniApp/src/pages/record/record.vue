<template>
  <view class="page-container">
    <PostalHeader
      kicker="NEW POSTCARD · 寄往未来"
      title="记录明信片"
      subtitle="先选择旅程，再记录地点和此刻心情"
      :show-back="false"
    />

    <scroll-view class="content" scroll-y>
      <view class="form-wrap">
        <!-- Photo upload -->
        <view v-if="!photoPath" class="upload-zone" @click="selectImage">
          <IconCamera :size="56" color="#2E7D58" />
          <text class="upload-title">点击拍照或选择照片</text>
          <text class="upload-meta">4:3 · MAX 5MB</text>
        </view>
        <view v-else class="photo-preview-wrap" @click="selectImage">
          <image :src="photoPath" class="photo-preview" mode="aspectFill" />
          <view class="photo-change-btn">
            <IconCamera :size="28" color="#FBF8F1" />
          </view>
        </view>

        <!-- Journey selector -->
        <view class="form-card journey-card" :class="{ 'journey-card-empty': travelOptions.length === 0 }">
          <view class="form-label-row">
            <text class="form-lbl-en">JOURNEY</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">所属旅程</text>
            <text class="form-required">*</text>
          </view>
          <view v-if="travelOptions.length > 0" class="travel-pick-wrap">
            <view class="travel-pick-row" @click="showTravelPicker = true">
              <view class="travel-pick-info">
                <text class="travel-pick-name">{{ selectedTravel?.title || '选择旅程' }}</text>
                <text class="travel-pick-dest">{{ selectedTravel?.destination || '明信片会保存到这段旅程里' }}</text>
              </view>
              <text class="travel-pick-arr">›</text>
            </view>
            <view class="travel-new-link" @click="goCreateTravel">
              <text class="travel-new-txt">+ 新建旅程</text>
            </view>
          </view>
          <view v-else class="travel-empty-wrap">
            <view class="travel-empty-copy">
              <text class="travel-empty-title">先创建一段旅程</text>
              <text class="travel-empty-hint">明信片需要归属旅程，创建后会自动回到这里继续记录。</text>
            </view>
            <view class="travel-empty-btn" @click="goCreateTravel">
              <text class="travel-empty-btn-txt">去创建 ›</text>
            </view>
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
            <input
              class="form-input"
              v-model="locationName"
              placeholder="点击定位或手动输入"
              confirm-type="next"
              @input="locationAssist = ''"
            />
            <view class="locate-btn" :class="{ 'locate-btn-active': isLocating }" @click="getLocation">
              <view v-if="isLocating" class="locate-spinner"></view>
              <IconLocation v-else :size="28" color="#8E8775" />
              <text class="locate-btn-txt">{{ locatingLabel }}</text>
            </view>
          </view>
          <view v-if="locationAssist" class="location-assist" :class="`location-assist-${locationAssistType}`">
            <text class="location-assist-txt">{{ locationAssist }}</text>
            <text v-if="locationAssistType !== 'success'" class="location-assist-action" @click="getLocation">重试</text>
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
          <input class="form-input" v-model="city" placeholder="输入城市名称" confirm-type="next" />
        </view>

        <!-- Country -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">COUNTRY</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">国家</text>
          </view>
          <input class="form-input" v-model="country" placeholder="输入国家名称" confirm-type="next" />
        </view>

        <!-- To -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">TO</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">收件人</text>
          </view>
          <input class="form-input" v-model="toName" placeholder="写给谁？（选填，默认：未来的我）" confirm-type="next" />
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
            confirm-type="done"
          />
          <text class="char-count">{{ note.length }} / 200</text>
        </view>

        <!-- Stamp picker — grouped by series -->
        <!-- Submit -->
        <view class="save-panel">
          <view class="save-copy">
            <text class="save-title">{{ canSubmit ? '可以保存了' : '还差一点点' }}</text>
            <text class="save-hint">{{ submitHint }}</text>
          </view>
          <view
            class="submit-btn"
            :class="{ 'submit-disabled': !canSubmit }"
            @click="submitPostcard"
          >
            <text class="submit-txt">保存明信片 ›</text>
          </view>
          <text class="submit-sub">POSTAGE PAID · 旅邮</text>
        </view>

        <!-- Optional refinements -->
        <view class="advanced-card">
          <view class="advanced-row" @click="showStampOptions = !showStampOptions">
            <view class="advanced-copy">
              <text class="advanced-kicker">STAMP · 邮票</text>
              <text class="advanced-title">{{ selectedStamp?.name || '默认邮票' }}</text>
              <text class="advanced-sub">默认会使用当前邮票，保存前也可以更换</text>
            </view>
            <view class="advanced-stamp" :style="{ borderColor: currentStampColor }">
              <image v-if="getStampImageUrl(stampDesign)" :src="getStampImageUrl(stampDesign)" class="advanced-stamp-img" mode="aspectFill" />
              <text v-else class="advanced-stamp-dot" :style="{ color: currentStampColor }">✦</text>
            </view>
            <text class="advanced-arr">{{ showStampOptions ? '收起' : '更换' }}</text>
          </view>

          <view v-if="showStampOptions" class="stamp-picker">
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
                    @click="openStampPreview(s)"
                  >
                    <view class="stamp-swatch" :style="{ 'border-color': s.color }">
                      <image v-if="getStampImageUrl(s.id)" :src="getStampImageUrl(s.id)" class="stamp-swatch-img" mode="aspectFill" />
                      <text v-else class="stamp-swatch-dot" :style="{ color: s.color }">✦</text>
                    </view>
                    <text class="stamp-name" :style="stampDesign === s.id ? { color: s.color } : {}">{{ s.name }}</text>
                  </view>
                </view>
              </scroll-view>
            </view>
          </view>
        </view>

        <view class="advanced-card">
          <view class="advanced-row" @click="showPreview = !showPreview">
            <view class="advanced-copy">
              <text class="advanced-kicker">PREVIEW · 预览</text>
              <text class="advanced-title">明信片效果</text>
              <text class="advanced-sub">点开查看正反面，轻点卡片可翻面</text>
            </view>
            <text class="advanced-arr">{{ showPreview ? '收起' : '查看' }}</text>
          </view>

          <view v-if="showPreview" class="preview-section">
            <view class="preview-hd">
              <view>
                <text class="section-kicker">LIVE PREVIEW · 预览</text>
                <text class="preview-ttl">明信片</text>
              </view>
              <text class="preview-flip-hint">{{ isFlipped ? '正面 ›' : '· 背面 ›' }}</text>
            </view>
            <view class="preview-rule"></view>

            <!-- 3D flip wrapper -->
            <view class="pc-flip-wrap" @click="isFlipped = !isFlipped">
              <view class="pc-flip-inner" :class="{ 'pc-flipped': isFlipped }">

                <!-- ── 正面：照片（无邮票，标准明信片正面只有图案） ── -->
                <view class="pc-face pc-face-front">
                  <view class="pc-photo-wrap">
                    <image v-if="photoPath" :src="photoPath" class="pc-photo" mode="aspectFill" />
                    <view v-else class="pc-photo-empty">
                      <IconImage :size="48" color="#B5AE9B" />
                    </view>
                    <!-- 底部渐变：城市 + 地点 -->
                    <view class="pc-photo-bottom">
                      <text class="pc-city-code">{{ city ? city.toUpperCase() : 'CITY' }}</text>
                      <text class="pc-loc-code">{{ locationName || '—' }}</text>
                    </view>
                  </view>
                  <view class="pc-footer">
                    <text class="pc-footer-left">旅行邮箱 · 寄往远方</text>
                    <text class="pc-footer-right">CN — 0001</text>
                  </view>
                </view>

                <!-- ── 背面：留言 + 地址 ── -->
                <view class="pc-face pc-face-back">
                  <view class="pc-back-body">
                    <view class="pc-back-left">
                      <text class="pc-back-label">MESSAGE · 留言</text>
                      <view class="pc-back-line"></view>
                      <text class="pc-back-note">"{{ note || '写下你的心情...' }}"</text>
                      <view class="pc-back-line"></view>
                      <view class="pc-back-line"></view>
                    </view>
                    <view class="pc-vdivider"></view>
                    <view class="pc-back-right">
                      <view class="pc-stamp-box" :style="{ borderColor: currentStampColor }">
                        <image v-if="getStampImageUrl(stampDesign)" :src="getStampImageUrl(stampDesign)" class="pc-stamp-img" mode="aspectFill" />
                        <text v-else class="pc-stamp-dot" :style="{ color: currentStampColor }">✦</text>
                      </view>
                      <view class="pc-addr-from">
                        <text class="pc-addr-label">FROM</text>
                        <text class="pc-addr-main">{{ locationName || '位置名称' }}</text>
                        <text class="pc-addr-sub">{{ city || '城市' }}</text>
                      </view>
                      <view class="pc-addr-sep"></view>
                      <view class="pc-addr-to">
                        <text class="pc-addr-label">TO</text>
                        <text class="pc-addr-main">{{ toName || '未来的我' }}</text>
                      </view>
                    </view>
                  </view>
                  <view class="pc-footer">
                    <text class="pc-footer-left">旅行邮箱 · 寄往远方</text>
                    <text class="pc-footer-right">CN — 0001</text>
                  </view>
                </view>

              </view>
            </view>

            <!-- 翻转指示点 -->
            <view class="pc-flip-dots">
              <view class="pc-flip-dot" :class="{ 'pc-flip-dot-on': !isFlipped }"></view>
              <view class="pc-flip-dot" :class="{ 'pc-flip-dot-on': isFlipped }"></view>
            </view>
          </view>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>

    <view v-if="!isSending" class="sticky-save">
      <view class="sticky-save-copy">
        <text class="sticky-save-title">{{ canSubmit ? '可以保存了' : '还差一点' }}</text>
        <text class="sticky-save-hint">{{ submitHint }}</text>
      </view>
      <view
        class="sticky-save-btn"
        :class="{ 'sticky-save-btn-disabled': !canSubmit }"
        @click="submitPostcard"
      >
        <text class="sticky-save-btn-txt">保存</text>
      </view>
    </view>

    <!-- ── 旅程选择底部弹窗 ── -->
    <view v-if="showTravelPicker" class="tp-mask" @click.self="showTravelPicker = false">
      <view class="tp-sheet">
        <view class="tp-hd">
          <text class="tp-hd-kicker">JOURNEY · 所属旅程</text>
          <text class="tp-hd-close" @click="showTravelPicker = false">✕</text>
        </view>
        <scroll-view class="tp-list" scroll-y>
          <view
            v-for="t in store.sortedTravels"
            :key="t.id"
            class="tp-item"
            :class="{ 'tp-item-active': selectedTravelId === t.id }"
            @click="selectTravel(t.id)"
          >
            <view class="tp-item-body">
              <text class="tp-item-title">{{ t.title }}</text>
              <text class="tp-item-dest">{{ t.destination }}</text>
            </view>
            <view v-if="selectedTravelId === t.id" class="tp-check">
              <text class="tp-check-mark">✓</text>
            </view>
          </view>
          <view class="tp-new-item" @click="goCreateTravel">
            <text class="tp-new-plus">＋</text>
            <text class="tp-new-txt">新建旅程</text>
          </view>
        </scroll-view>
      </view>
    </view>

    <!-- ── 邮票放大预览 ── -->
    <StampPreviewModal
      v-if="previewStamp"
      :stamp="previewStamp"
      mode="select"
      @close="previewStamp = null"
      @select="selectAndClose"
    />

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
            <text class="send-mini-to">TO · {{ toName || '未来的我' }}</text>
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
          <text class="send-ok-main">已保存</text>
          <text class="send-ok-sub">SAVED · 明信片已加入你的收藏</text>
          <view class="send-ok-actions">
            <view class="send-ok-btn-primary" @click="goDetail">
              <text class="send-ok-btn-txt">查看明信片 ›</text>
            </view>
            <view class="send-ok-btn-secondary" @click="goSend">
              <text class="send-ok-btn-secondary-txt">寄给好友 ›</text>
            </view>
            <text class="send-ok-btn-ghost" @click="goHome">稍后再寄</text>
          </view>
        </view>

      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { useAuthStore } from '@/stores/auth'
import { UIUtil } from '@/utils/ui'
import { ToastMessages, StampDesigns, AppConfig } from '@/config/app'
import { getStampImageUrl } from '@/utils/stamp'
import { PostcardApi, UploadApi, GeoApi } from '@/services/api'
import {
  IconCamera,
  IconLocation,
  IconImage,
} from '@/components/icons'
import PostalHeader from '@/components/PostalHeader.vue'
import StampPreviewModal from '@/components/StampPreviewModal.vue'

const store     = usePostcardStore()
const authStore = useAuthStore()

const photoPath    = ref('')
const locationName = ref('')
const city         = ref('')
const country      = ref(AppConfig.defaultCountry)
const note         = ref('')
const toName       = ref('')
const stampDesign        = ref('classic')
const isLocating         = ref(false)
const locatingLabel      = ref('定位')
const locationAssist     = ref('')
const locationAssistType = ref<'success' | 'warning' | 'error'>('warning')
const isFlipped          = ref(false)
const previewStamp       = ref<any>(null)
const selectedTravelId   = ref('')
const showTravelPicker   = ref(false)
const showStampOptions   = ref(false)
const showPreview        = ref(false)
const isSending       = ref(false)
const sendPhase       = ref('idle')
const nowDotDate      = ref('')
const savedPostcardId = ref('')
const sendTimers: number[] = []

const canSubmit = computed(() =>
  !!String(locationName.value || '').trim() && !!String(city.value || '').trim() && !!selectedTravelId.value
)

const submitHint = computed(() => {
  if (!selectedTravelId.value) return '选择一段旅程后就能保存'
  if (!String(locationName.value || '').trim()) return '填写或定位一个具体位置'
  if (!String(city.value || '').trim()) return '补上城市名称'
  return photoPath.value ? '照片和地点都准备好了' : '没有照片也可以先保存文字明信片'
})

const travelOptions = computed(() =>
  store.sortedTravels.map(t => ({ label: `${t.title} · ${t.destination}`, id: t.id }))
)

const selectedTravel = computed(() =>
  store.sortedTravels.find(t => t.id === selectedTravelId.value) || null
)

const sendPhaseLbl = computed(() => {
  if (sendPhase.value === 'sealing')  return 'SEALING · 封装中...'
  if (sendPhase.value === 'stamping') return 'STAMPING · 盖章中...'
  if (sendPhase.value === 'flying')   return 'SAVING · 保存中...'
  return ''
})

const currentStampColor = computed(() =>
  StampDesigns.find(s => s.id === stampDesign.value)?.color ?? '#8E8775'
)

const selectedStamp = computed(() =>
  StampDesigns.find(s => s.id === stampDesign.value) || null
)

function openStampPreview(s: any) {
  previewStamp.value = s
}

function selectAndClose() {
  if (previewStamp.value) {
    stampDesign.value = previewStamp.value.id
    previewStamp.value = null
  }
}

function goHome() {
  clearSendState()
  uni.switchTab({ url: '/pages/home/home' })
}

function clearSendState() {
  sendTimers.forEach(clearTimeout)
  sendTimers.length = 0
  isSending.value = false
  sendPhase.value = 'idle'
  savedPostcardId.value = ''
}

function goSend() {
  const id = savedPostcardId.value
  clearSendState()
  uni.navigateTo({ url: `/pages/send/send?postcardId=${id}` })
}

function goDetail() {
  const id = savedPostcardId.value
  clearSendState()
  uni.navigateTo({ url: `/pages/detail/detail?id=${id}` })
}

function selectTravel(id: string) {
  selectedTravelId.value = id
  showTravelPicker.value = false
}

function goCreateTravel() {
  showTravelPicker.value = false
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
  if (isLocating.value) return
  isLocating.value  = true
  locatingLabel.value = '获取位置…'
  locationAssist.value = ''
  uni.getLocation({
    type: 'wgs84',
    success: async (res) => {
      locatingLabel.value = '解析地址…'
      try {
        const geo = await GeoApi.reverse(res.latitude, res.longitude)
        locationName.value = geo.locationName
        city.value = geo.city || city.value || '未知城市'
        locationAssistType.value = 'success'
        locationAssist.value = '定位成功，可继续微调地点名称'
        UIUtil.showSuccess('定位成功')
      } catch {
        // 服务端失败时兜底：填入坐标，让用户手动修改
        locationName.value = `${res.latitude.toFixed(4)}°N, ${res.longitude.toFixed(4)}°E`
        if (!city.value) city.value = '未知城市'
        locationAssistType.value = 'warning'
        locationAssist.value = '已获取坐标，但地址解析失败。可以手动改成具体地点。'
        UIUtil.showError('地址解析失败，请手动输入')
      } finally {
        isLocating.value    = false
        locatingLabel.value = '定位'
      }
    },
    fail: async () => {
      // GPS 失败（通常是 HTTP 环境不允许）→ 用 IP 定位兜底获取城市
      locatingLabel.value = '获取城市…'
      try {
        const ipGeo = await GeoApi.ip()
        if (!city.value) city.value = ipGeo.city
        locationAssistType.value = 'warning'
        locationAssist.value = `已识别到 ${ipGeo.city}，请手动填写具体位置。`
        uni.showToast({ title: `已定位到 ${ipGeo.city}，请手动填写具体位置`, icon: 'none', duration: 3000 })
      } catch {
        locationAssistType.value = 'error'
        locationAssist.value = '定位失败，请检查权限或直接手动输入位置。'
        UIUtil.showError('定位失败，请手动输入位置')
      } finally {
        isLocating.value    = false
        locatingLabel.value = '定位'
      }
    },
  })
}

async function submitPostcard() {
  if (!canSubmit.value) {
    UIUtil.showError('请填写必要信息')
    return
  }

  // Clear any lingering animation timers before starting new submission
  sendTimers.forEach(clearTimeout)
  sendTimers.length = 0

  let photoUrl = photoPath.value
  if (photoUrl && !photoUrl.startsWith('http')) {
    uni.showLoading({ title: '上传中…', mask: true })
    try {
      const up = await UploadApi.image(photoUrl)
      photoUrl = up.url
    } catch (err) {
      uni.hideLoading()
      const msg = err instanceof Error ? err.message : '图片上传失败'
      UIUtil.showError(msg)
      return
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
    toName: toName.value.trim() || null,
    stampDesign: stampDesign.value,
    isFavorite: false,
    recordedAt: Date.now(),
    createdAt: Date.now(),
  }
  try {
    const serverCard = await PostcardApi.create(localCard)
    store.addPostcard(serverCard)
    savedPostcardId.value = serverCard.id
  } catch {
    store.addPostcard(localCard)
    savedPostcardId.value = localCard.id
  }
  const d = new Date()
  nowDotDate.value = `${String(d.getMonth() + 1).padStart(2, '0')}·${String(d.getDate()).padStart(2, '0')}`
  isSending.value = true
  sendPhase.value = 'sealing'
  sendTimers.push(setTimeout(() => { sendPhase.value = 'stamping' }, 900))
  sendTimers.push(setTimeout(() => { sendPhase.value = 'flying' }, 1700))
  sendTimers.push(setTimeout(() => { sendPhase.value = 'done' }, 2400))
}

function ensureSelectedTravel() {
  store.initData()
  const currentSelection = store.sortedTravels.find(t => t.id === selectedTravelId.value)
  if (!currentSelection) {
    const travel = store.currentTravel ?? store.sortedTravels[0]
    selectedTravelId.value = travel?.id ?? ''
  }
}

onMounted(() => {
  ensureSelectedTravel()
  // Ensure selected stamp belongs to owned list
  const ownedIds = authStore.ownedStamps.length > 0
    ? authStore.ownedStamps
    : ['classic', 'nature', 'culture', 'city', 'ocean', 'sunset']
  if (!ownedIds.includes(stampDesign.value)) {
    stampDesign.value = ownedIds[0] ?? 'classic'
  }
})
onShow(() => {
  ensureSelectedTravel()
})
onUnmounted(() => {
  sendTimers.forEach(clearTimeout)
  sendTimers.length = 0
})
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $page-background;
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
  border: 3rpx dashed $rule-color;
  border-radius: 12rpx;
  padding: 72rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  background: $card-bg;
  box-shadow: $shadow-sm;
}

.upload-title {
  font-family: $font-family-body;
  font-size: 32rpx;
  font-weight: 500;
  color: $ink-black;
}

.upload-meta {
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
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
  border-radius: 12rpx;
  border: 2rpx solid $line-sepia;
  padding: 28rpx 32rpx;
  box-shadow: $shadow-sm;
}

.form-label-row {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 16rpx;
  padding-bottom: 12rpx;
  border-bottom: 1rpx solid rgba($line-sepia, 0.55);
}

.form-lbl-en {
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $travel-blue;
  font-weight: 500;
}

.form-lbl-sep {
  color: $whisper;
  font-size: 22rpx;
}

.form-lbl-cn {
  font-family: $font-family-label;
  font-size: 24rpx;
  color: $body-text;
}

.form-required {
  color: $stamp-red;
  font-size: 24rpx;
  margin-left: -4rpx;
}

.form-input-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.form-input {
  flex: 1;
  font-family: $font-family-body;
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
  border: 2rpx solid rgba(60, 96, 77, 0.45);
  border-radius: 8rpx;
  flex-shrink: 0;
  transition: background 0.2s, border-color 0.2s;

  &.locate-btn-active {
    background: rgba(60, 96, 77, 0.06);
    border-color: rgba(60, 96, 77, 0.7);
  }
}

.locate-spinner {
  width: 28rpx;
  height: 28rpx;
  border: 3rpx solid rgba(60, 96, 77, 0.2);
  border-top-color: $travel-blue;
  border-radius: 50%;
  animation: locating-spin 0.7s linear infinite;
  flex-shrink: 0;
}

@keyframes locating-spin {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}

.locate-btn-txt {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $travel-blue;
}

.location-assist {
  margin-top: 18rpx;
  padding: 16rpx 18rpx;
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
  background: rgba($travel-blue, 0.05);
  border: 2rpx solid rgba($travel-blue, 0.2);
}

.location-assist-warning {
  background: rgba(156, 126, 90, 0.08);
  border-color: rgba(156, 126, 90, 0.22);
}

.location-assist-error {
  background: rgba($stamp-red, 0.06);
  border-color: rgba($stamp-red, 0.22);
}

.location-assist-txt {
  flex: 1;
  min-width: 0;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $body-text;
  line-height: 1.45;
}

.location-assist-action {
  flex-shrink: 0;
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $travel-blue;
}

.form-textarea {
  width: 100%;
  min-height: 160rpx;
  font-family: $font-family-body;
  font-style: italic;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.6;
  box-sizing: border-box;
}

.char-count {
  display: block;
  text-align: right;
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $mute-text;
  margin-top: 8rpx;
}

// ─── Journey selector ───
.journey-card {
  border-color: rgba($travel-blue, 0.42);
  background: rgba($travel-blue, 0.08);
}

.journey-card-empty {
  border-style: dashed;
}

.travel-pick-wrap {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.travel-pick-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8rpx 0 16rpx;
  &:active { opacity: 0.7; }
}

.travel-pick-info {
  display: flex;
  flex-direction: column;
  gap: 6rpx;
  flex: 1;
  min-width: 0;
}

.travel-pick-name {
  font-family: $font-family-body;
  font-size: 32rpx;
  color: $ink-black;
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.travel-pick-dest {
  font-family: $font-family-body;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $mute-text;
}

.travel-pick-arr {
  font-family: $font-family-body;
  font-size: 36rpx;
  color: $travel-blue;
  flex-shrink: 0;
  padding-left: 16rpx;
}

.travel-new-link {
  border-top: 2rpx solid rgba($travel-blue, 0.16);
  padding-top: 16rpx;
  margin-top: 4rpx;
}

.travel-new-txt {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $travel-blue;
}

.travel-empty-wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24rpx;
  padding: 8rpx 0;
}

.travel-empty-copy {
  flex: 1;
  min-width: 0;
}

.travel-empty-title {
  display: block;
  font-family: $font-family-body;
  font-size: 30rpx;
  color: $ink-black;
  margin-bottom: 8rpx;
}

.travel-empty-hint {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  line-height: 1.55;
}

.travel-empty-btn {
  background: $travel-blue;
  border-radius: 6rpx;
  padding: 12rpx 28rpx;
  flex-shrink: 0;
  &:active { opacity: 0.85; }
}

.travel-empty-btn-txt {
  font-family: $font-family-action;
  font-size: 26rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

// ─── 旅程选择弹窗 ───
.tp-mask {
  position: fixed;
  inset: 0;
  background: rgba(16, 12, 8, 0.5);
  z-index: 9000;
  display: flex;
  align-items: flex-end;
  animation: tp-fade 0.18s ease both;
}

@keyframes tp-fade {
  from { opacity: 0; }
  to   { opacity: 1; }
}

.tp-sheet {
  width: 100%;
  background: $card-bg;
  border-radius: 32rpx 32rpx 0 0;
  padding-bottom: env(safe-area-inset-bottom, 32rpx);
  animation: tp-slide 0.24s cubic-bezier(0.32, 0.72, 0, 1) both;
  max-height: 70vh;
  display: flex;
  flex-direction: column;
}

@keyframes tp-slide {
  from { transform: translateY(100%); }
  to   { transform: translateY(0); }
}

.tp-hd {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 36rpx 48rpx 24rpx;
  border-bottom: 2rpx solid $line-sepia;
  flex-shrink: 0;
}

.tp-hd-kicker {
  font-family: $font-family-action;
  font-size: 24rpx;
  font-weight: 500;
  letter-spacing: 0;
  color: $travel-blue;
}

.tp-hd-close {
  font-size: 28rpx;
  color: $mute-text;
  padding: 8rpx;
}

.tp-list {
  flex: 1;
  overflow: hidden;
}

.tp-item {
  display: flex;
  align-items: center;
  padding: 28rpx 48rpx;
  border-bottom: 2rpx solid rgba($line-sepia, 0.7);
  &:active { background: rgba($travel-blue, 0.04); }
  &.tp-item-active { background: rgba($travel-blue, 0.05); }
}

.tp-item-body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.tp-item-title {
  font-family: $font-family-body;
  font-size: 32rpx;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;

  .tp-item-active & { color: $travel-blue; }
}

.tp-item-dest {
  font-family: $font-family-body;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $mute-text;
}

.tp-check {
  width: 44rpx;
  height: 44rpx;
  border-radius: 50%;
  background: $travel-blue;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.tp-check-mark {
  font-size: 22rpx;
  color: #F4EFE5;
  font-weight: bold;
}

.tp-new-item {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 28rpx 48rpx;
  &:active { opacity: 0.7; }
}

.tp-new-plus {
  font-family: $font-family-body;
  font-size: 36rpx;
  color: $travel-blue;
  line-height: 1;
}

.tp-new-txt {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $travel-blue;
}

// ─── Stamp picker ───
.advanced-card {
  background: $card-bg;
  border: 2rpx solid $line-sepia;
  border-radius: 12rpx;
  padding: 24rpx 28rpx;
  box-shadow: $shadow-sm;
}

.advanced-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.advanced-copy {
  flex: 1;
  min-width: 0;
}

.advanced-kicker {
  display: block;
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
  font-weight: 500;
  color: $travel-blue;
  margin-bottom: 8rpx;
}

.advanced-title {
  display: block;
  font-family: $font-family-body;
  font-size: 30rpx;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.advanced-sub {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  line-height: 1.45;
  margin-top: 4rpx;
}

.advanced-stamp {
  width: 58rpx;
  height: 72rpx;
  border: 1rpx dashed currentColor;
  border-radius: 3rpx;
  background: $paper-beige;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.advanced-stamp-img {
  width: 100%;
  height: 100%;
}

.advanced-stamp-dot {
  font-size: 24rpx;
}

.advanced-arr {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
  flex-shrink: 0;
}

.stamp-picker {
  border-top: 1rpx dashed $line-sepia;
  margin-top: 24rpx;
  padding-top: 20rpx;
}

.stamp-series-block {
  margin-top: 16rpx;

  &:first-child { margin-top: 4rpx; }
}

.stamp-series-label {
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

.stamp-row {
  display: flex;
  gap: 16rpx;
  padding-bottom: 4rpx;
  width: max-content;
}

.stamp-option {
  position: relative;
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
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $body-text;
  font-weight: 500;
}

// ─── Postcard preview ───
.preview-section {
  border-top: 1rpx dashed $line-sepia;
  margin-top: 24rpx;
  padding-top: 20rpx;
}

.preview-hd {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  margin-bottom: 16rpx;
}

.section-kicker {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  margin-bottom: 8rpx;
}

.preview-ttl {
  display: block;
  font-family: $font-family-body;
  font-weight: 500;
  font-size: 38rpx;
  color: $ink-black;
}

.preview-flip-hint {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
  padding-bottom: 6rpx;
}

.preview-rule {
  height: 1rpx;
  background: $line-sepia;
  margin-bottom: 24rpx;
}

// ── 3D flip container ──
.pc-flip-wrap {
  perspective: 2000rpx;
  transform: rotate(-0.5deg);
}

.pc-flip-inner {
  position: relative;
  transform-style: preserve-3d;
  transition: transform 0.55s cubic-bezier(0.4, 0.2, 0.2, 1);

  &.pc-flipped { transform: rotateY(180deg); }
}

.pc-face {
  background: $card-bg;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  overflow: hidden;
  box-shadow: 0 16rpx 40rpx rgba(40, 30, 15, 0.10);
  -webkit-backface-visibility: hidden;
  backface-visibility: hidden;
}

.pc-face-back {
  position: absolute;
  inset: 0;
  transform: rotateY(180deg);
}

// ── 正面 ──
.pc-photo-wrap {
  position: relative;
  height: 320rpx;
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

// 底部城市条
.pc-photo-bottom {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 20rpx 20rpx 16rpx;
  background: linear-gradient(to top, rgba(10,8,5,0.55) 0%, transparent 100%);
  display: flex;
  align-items: baseline;
  gap: 12rpx;
}

.pc-city-code {
  font-family: $font-family-code;
  font-size: 24rpx;
  letter-spacing: 2rpx;
  color: rgba(244, 239, 229, 0.95);
  font-weight: 500;
}

.pc-loc-code {
  font-family: $font-family-body;
  font-size: 22rpx;
  color: rgba(244, 239, 229, 0.65);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

// ── 背面 ──
.pc-back-body {
  display: flex;
  padding: 24rpx 24rpx 16rpx;
  min-height: 240rpx;
}

.pc-back-left {
  flex: 1;
  min-width: 0;
  padding-right: 20rpx;
}

.pc-back-label {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
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
  font-family: $font-family-body;
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

// 背面邮票（真实图案）
.pc-stamp-box {
  width: 72rpx;
  height: 88rpx;
  border: 1rpx dashed currentColor;
  border-radius: 3rpx;
  background: $page-background;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  align-self: flex-end;
  margin-bottom: 16rpx;
}

.pc-stamp-img {
  width: 100%;
  height: 100%;
}

.pc-stamp-dot { font-size: 24rpx; }

.pc-addr-from,
.pc-addr-to { flex: 1; }

.pc-addr-label {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  margin-bottom: 6rpx;
}

.pc-addr-main {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  font-weight: 500;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 3rpx;
}

.pc-addr-sub {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

// ── 翻转指示点 ──
.pc-flip-dots {
  display: flex;
  justify-content: center;
  gap: 12rpx;
  margin-top: 20rpx;
}

.pc-flip-dot {
  width: 10rpx;
  height: 10rpx;
  border-radius: 50%;
  background: $line-sepia;
  transition: all 0.3s;

  &.pc-flip-dot-on {
    background: $travel-blue;
    width: 28rpx;
    border-radius: 5rpx;
  }
}

// ─── Submit ───
.save-panel {
  background: $card-bg;
  border: 2rpx solid rgba($travel-blue, 0.36);
  border-radius: 12rpx;
  padding: 30rpx;
  box-shadow: $shadow-md;
}

.save-copy {
  margin-bottom: 22rpx;
}

.save-title {
  display: block;
  font-family: $font-family-body;
  font-size: 32rpx;
  color: $ink-black;
  margin-bottom: 6rpx;
}

.save-hint {
  display: block;
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
  line-height: 1.5;
}

.submit-btn {
  background: $travel-blue;
  border-radius: 8rpx;
  padding: 32rpx 0;
  text-align: center;
}

.submit-disabled {
  background: $line-sepia;
}

.submit-txt {
  font-family: $font-family-action;
  font-size: 28rpx;
  color: $card-bg;
  letter-spacing: 2rpx;
}

.submit-sub {
  display: block;
  text-align: center;
  font-family: $font-family-body;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $mute-text;
  margin-top: 16rpx;
}

.btm-gap { height: 260rpx; }

// ─── Sticky save action ───
.sticky-save {
  position: fixed;
  left: 24rpx;
  right: 24rpx;
  bottom: calc(112rpx + env(safe-area-inset-bottom));
  z-index: 800;
  min-height: 96rpx;
  padding: 18rpx 20rpx;
  border: 2rpx solid rgba($travel-blue, 0.32);
  border-radius: 12rpx;
  background: rgba(255, 253, 247, 0.98);
  box-shadow: $shadow-lg;
  display: flex;
  align-items: center;
  gap: 18rpx;
  box-sizing: border-box;
}

.sticky-save-copy {
  flex: 1;
  min-width: 0;
}

.sticky-save-title {
  display: block;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.25;
}

.sticky-save-hint {
  display: block;
  margin-top: 4rpx;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  line-height: 1.3;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.sticky-save-btn {
  width: 136rpx;
  height: 68rpx;
  border-radius: 8rpx;
  background: $travel-blue;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  &:active {
    background: $forest-green;
  }
}

.sticky-save-btn-disabled {
  background: $line-sepia;

  &:active {
    background: $line-sepia;
  }
}

.sticky-save-btn-txt {
  font-family: $font-family-action;
  font-size: 28rpx;
  color: #F4EFE5;
  letter-spacing: 1rpx;
  white-space: nowrap;
}

// stamp preview is handled by StampPreviewModal component

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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
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
  font-family: $font-family-body;
  font-size: 24rpx;
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
.send-mini-sdot { font-size: 22rpx; }

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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
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
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(164, 59, 45, 0.9);
}
.send-pm-date {
  font-family: $font-family-body;
  font-size: 24rpx;
  font-weight: 500;
  color: rgba(164, 59, 45, 0.9);
  line-height: 1.1;
}

// ── Phase label ──
.send-phase-lbl {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
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

  .phase-done & {
    animation: ok-appear 0.65s cubic-bezier(0.34, 1.56, 0.64, 1) both;
    pointer-events: auto;
  }
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
  font-family: $font-family-body;
  font-size: 44rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}
.send-ok-sub {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(244, 239, 229, 0.45);
  text-align: center;
}
.send-ok-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 18rpx;
  margin-top: 28rpx;
}
.send-ok-btn-primary {
  min-width: 280rpx;
  height: 76rpx;
  background: $travel-blue;
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  box-sizing: border-box;
}
.send-ok-btn-txt {
  font-family: $font-family-action;
  font-size: 30rpx;
  color: #F4EFE5;
  letter-spacing: 1rpx;
  white-space: nowrap;
}
.send-ok-btn-secondary {
  min-width: 280rpx;
  height: 70rpx;
  border: 1rpx solid rgba(244, 239, 229, 0.24);
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  box-sizing: border-box;
}
.send-ok-btn-secondary-txt {
  font-family: $font-family-action;
  font-size: 28rpx;
  color: rgba(244, 239, 229, 0.82);
  letter-spacing: 2rpx;
  white-space: nowrap;
}
.send-ok-btn-ghost {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: rgba(244, 239, 229, 0.38);
}
</style>

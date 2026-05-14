<template>
  <view class="page-container">
    <!-- Sticky nav -->
    <view class="sticky-nav">
      <view class="nav-back" @click="goBack">
        <IconBack :size="20" color="#5C5648" />
      </view>
      <view class="nav-mid">
        <text class="nav-kicker">{{ isEditing ? 'EDIT JOURNEY · 编辑旅程' : 'NEW JOURNEY · 新旅程' }}</text>
        <text class="nav-title">{{ isEditing ? (travel?.title || '旅程详情') : '创建旅程' }}</text>
      </view>
      <view v-if="isEditing" class="nav-save" :class="{ 'nav-save-dis': !canSave }" @click="saveTravel">
        <text class="nav-save-txt">SAVE</text>
      </view>
    </view>

    <scroll-view class="content" scroll-y>
      <view class="form-wrap">

        <!-- 旅程名称 -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">TITLE</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">旅程名称</text>
            <text class="form-required">*</text>
          </view>
          <input class="form-input" v-model="title" placeholder="给这段旅程起个名字" :maxlength="30" />
        </view>

        <!-- 目的地 -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">DESTINATION</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">目的地</text>
            <text class="form-required">*</text>
          </view>
          <input class="form-input" v-model="destination" placeholder="目的地城市或地区" :maxlength="30" />
        </view>

        <!-- 出发日期 -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">DEPARTURE</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">出发日期</text>
            <text class="form-required">*</text>
          </view>
          <picker mode="date" :value="startDateStr" @change="(e: any) => startDateStr = e.detail.value">
            <view class="date-picker-row">
              <text class="date-val" :class="{ 'date-ph': !startDateStr }">
                {{ startDateStr ? fmtDate(startDateStr) : '选择出发日期' }}
              </text>
              <text class="date-arr">›</text>
            </view>
          </picker>
        </view>

        <!-- 归程日期 -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">RETURN</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">归程日期</text>
            <text class="form-required">*</text>
          </view>
          <picker mode="date" :value="endDateStr" @change="(e: any) => endDateStr = e.detail.value">
            <view class="date-picker-row">
              <text class="date-val" :class="{ 'date-ph': !endDateStr }">
                {{ endDateStr ? fmtDate(endDateStr) : '选择归程日期' }}
              </text>
              <text class="date-arr">›</text>
            </view>
          </picker>
        </view>

        <!-- 旅程备忘 -->
        <view class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">MEMO</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">旅程备忘</text>
          </view>
          <textarea class="form-textarea" v-model="memo" placeholder="记录这段旅程的期待与计划..." :maxlength="200" />
          <text class="char-count">{{ memo.length }} / 200</text>
        </view>

        <!-- 状态（编辑模式） -->
        <view v-if="isEditing" class="form-card">
          <view class="form-label-row">
            <text class="form-lbl-en">STATUS</text>
            <text class="form-lbl-sep">·</text>
            <text class="form-lbl-cn">旅程状态</text>
          </view>
          <view class="status-pills">
            <view
              v-for="s in statusOptions"
              :key="s.value"
              class="status-pill"
              :class="{ 'pill-active': status === s.value, [`pill-${s.value}`]: true }"
              @click="status = s.value"
            >
              <text class="pill-txt">{{ s.label }}</text>
            </view>
          </view>
        </view>

        <!-- 明信片数量（编辑模式） -->
        <view v-if="isEditing" class="info-row">
          <view class="info-item">
            <text class="info-n">{{ cardCount }}</text>
            <text class="info-lbl">POSTCARDS</text>
          </view>
          <view class="info-divider"></view>
          <view class="info-item">
            <text class="info-n">{{ travelDays }}</text>
            <text class="info-lbl">DAYS</text>
          </view>
          <view v-if="travel?.isCurrent" class="info-item">
            <text class="info-n info-n-green">●</text>
            <text class="info-lbl">ACTIVE</text>
          </view>
        </view>

        <!-- 新建模式：出发 / 规划 -->
        <view v-if="!isEditing" class="create-actions">
          <view class="btn-depart" :class="{ 'btn-dis': !canSave }" @click="createOngoing">
            <text class="btn-depart-txt">出发 · DEPART ›</text>
            <text class="btn-depart-sub">立即出发，将其设为当前旅程</text>
          </view>
          <view class="btn-plan" :class="{ 'btn-dis': !canSave }" @click="createPlanned">
            <text class="btn-plan-txt">计划 · PLAN</text>
            <text class="btn-plan-sub">规划行程，待出发时再激活</text>
          </view>
        </view>

        <!-- 编辑模式：操作按钮 -->
        <view v-if="isEditing" class="edit-actions">
          <view class="btn-depart" :class="{ 'btn-dis': !canSave }" @click="saveTravel">
            <text class="btn-depart-txt">保存修改 · SAVE</text>
          </view>
          <view v-if="!travel?.isCurrent" class="btn-activate" @click="activateTravel">
            <text class="btn-activate-txt">设为当前旅程 · ACTIVATE</text>
          </view>
          <view class="btn-delete" @click="confirmDelete">
            <text class="btn-delete-txt">删除旅程 · DELETE</text>
          </view>
        </view>

      </view>
      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { TravelStatus } from '@/model/Travel'
import type { Travel } from '@/model/Travel'
import { TravelApi } from '@/services/api'
import { IconBack } from '@/components/icons'

const store = usePostcardStore()

const travelId = ref('')
const travel   = ref<Travel | null>(null)
const isEditing = computed(() => !!travelId.value)

const title       = ref('')
const destination = ref('')
const startDateStr = ref('')
const endDateStr   = ref('')
const memo         = ref('')
const status       = ref<string>(TravelStatus.PLANNED)

const cardCount  = computed(() => travelId.value ? store.getPostcardsByTravel(travelId.value).length : 0)
const travelDays = computed(() => {
  if (!startDateStr.value || !endDateStr.value) return 0
  const diff = strToTs(endDateStr.value) - strToTs(startDateStr.value)
  return Math.max(1, Math.ceil(diff / 86400000) + 1)
})

const canSave = computed(() =>
  title.value.trim().length > 0 &&
  destination.value.trim().length > 0 &&
  startDateStr.value.length > 0 &&
  endDateStr.value.length > 0
)

const statusOptions = [
  { value: TravelStatus.PLANNED,   label: '待出发' },
  { value: TravelStatus.ONGOING,   label: '进行中' },
  { value: TravelStatus.COMPLETED, label: '已完成' },
  { value: TravelStatus.CANCELLED, label: '已取消' },
]

function fmtDate(str: string): string {
  const p = str.split('-')
  return p.length === 3 ? `${p[0]} · ${p[1]} · ${p[2]}` : str
}

function strToTs(str: string): number {
  return new Date(str + 'T00:00:00').getTime()
}

function tsToStr(ts: number): string {
  const d = new Date(ts)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

function goBack() {
  uni.navigateBack({ fail: () => uni.switchTab({ url: '/pages/map/map' }) })
}

function buildPayload(s: TravelStatus, isCurrent: boolean): Omit<Travel, 'id' | 'createdAt'> {
  return {
    title:       title.value.trim(),
    destination: destination.value.trim(),
    startDate:   strToTs(startDateStr.value),
    endDate:     strToTs(endDateStr.value),
    description: memo.value.trim(),
    status:      s,
    isCurrent,
  }
}

async function createOngoing() {
  if (!canSave.value) return
  try {
    const payload = buildPayload(TravelStatus.ONGOING, true)
    const serverTravel = await TravelApi.create({ ...payload, startDate: payload.startDate, endDate: payload.endDate })
    store.travels.forEach(t => { if (t.isCurrent) store.updateTravel(t.id, { isCurrent: false }) })
    store.addTravel({ ...serverTravel, isCurrent: true })
    uni.showToast({ title: '出发！旅程已启动', icon: 'success' })
    setTimeout(goBack, 1400)
  } catch {
    // fallback to local
    store.travels.forEach(t => { if (t.isCurrent) store.updateTravel(t.id, { isCurrent: false }) })
    store.addTravel({ id: `travel-${Date.now()}`, createdAt: Date.now(), ...buildPayload(TravelStatus.ONGOING, true) })
    uni.showToast({ title: '出发！旅程已启动', icon: 'success' })
    setTimeout(goBack, 1400)
  }
}

async function createPlanned() {
  if (!canSave.value) return
  try {
    const payload = buildPayload(TravelStatus.PLANNED, false)
    const serverTravel = await TravelApi.create(payload)
    store.addTravel(serverTravel)
    uni.showToast({ title: '旅程已规划', icon: 'success' })
    setTimeout(goBack, 1400)
  } catch {
    store.addTravel({ id: `travel-${Date.now()}`, createdAt: Date.now(), ...buildPayload(TravelStatus.PLANNED, false) })
    uni.showToast({ title: '旅程已规划', icon: 'success' })
    setTimeout(goBack, 1400)
  }
}

async function saveTravel() {
  if (!canSave.value || !isEditing.value) return
  const payload = buildPayload(status.value as TravelStatus, travel.value?.isCurrent ?? false)
  store.updateTravel(travelId.value, payload)
  try { await TravelApi.update(travelId.value, payload) } catch {}
  uni.showToast({ title: '保存成功', icon: 'success' })
  setTimeout(goBack, 1200)
}

function activateTravel() {
  store.setCurrentTravel(travelId.value)
  store.updateTravel(travelId.value, { status: TravelStatus.ONGOING })
  travel.value = store.getTravelById(travelId.value) || null
  status.value = TravelStatus.ONGOING
  TravelApi.update(travelId.value, { status: TravelStatus.ONGOING, isCurrent: true }).catch(() => {})
  uni.showToast({ title: '已设为当前旅程', icon: 'success' })
}

function confirmDelete() {
  uni.showModal({
    title: '确认删除',
    content: `"${travel.value?.title}" 旅程下的 ${cardCount.value} 张明信片也将删除，不可恢复。`,
    confirmColor: '#A43B2D',
    success: async (res) => {
      if (res.confirm) {
        store.deleteTravel(travelId.value)
        try { await TravelApi.remove(travelId.value) } catch {}
        uni.showToast({ title: '已删除', icon: 'success' })
        setTimeout(goBack, 1200)
      }
    },
  })
}

onLoad((options) => {
  if (options?.id) travelId.value = options.id
})

onMounted(() => {
  store.initData()
  if (travelId.value) {
    const t = store.getTravelById(travelId.value)
    if (t) {
      travel.value  = t
      title.value   = t.title
      destination.value = t.destination
      startDateStr.value = tsToStr(t.startDate)
      endDateStr.value   = tsToStr(t.endDate)
      memo.value    = t.description || ''
      status.value  = t.status
    }
  } else {
    startDateStr.value = tsToStr(Date.now())
    endDateStr.value   = tsToStr(Date.now() + 7 * 24 * 60 * 60 * 1000)
  }
})
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $page-background;
}

// ── Sticky nav ──
.sticky-nav {
  position: sticky;
  top: 0;
  z-index: 100;
  background: $card-bg;
  border-bottom: 1rpx solid $line-sepia;
  padding: 60rpx 32rpx 20rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.nav-back {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  border: 1rpx solid $line-sepia;
  background: $page-background;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.nav-mid {
  flex: 1;
  min-width: 0;
}

.nav-kicker {
  display: block;
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
  margin-bottom: 4rpx;
}

.nav-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 34rpx;
  color: $ink-black;
  line-height: 1.15;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.nav-save {
  background: $travel-blue;
  padding: 14rpx 30rpx;
  border-radius: 100rpx;
  flex-shrink: 0;
}
.nav-save-dis { background: $line-sepia; }
.nav-save-txt {
  font-family: $font-family-mono;
  font-size: 18rpx;
  letter-spacing: 4rpx;
  color: $card-bg;
}

// ── Content ──
.content { flex: 1; overflow: hidden; }

.form-wrap {
  padding: 40rpx 40rpx 0;
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

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
.form-lbl-sep { color: $whisper; font-size: 18rpx; }
.form-lbl-cn {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: $mute-text;
}
.form-required { color: $stamp-red; font-size: 22rpx; margin-left: -4rpx; }

.form-input {
  font-family: $font-family-serif;
  font-size: 30rpx;
  color: $ink-black;
  letter-spacing: 0.4rpx;
  width: 100%;
}

// Date picker
.date-picker-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.date-val {
  font-family: $font-family-serif;
  font-size: 30rpx;
  color: $ink-black;
}
.date-ph { color: $whisper; }
.date-arr { font-size: 32rpx; color: $mute-text; }

// Textarea
.form-textarea {
  width: 100%;
  min-height: 130rpx;
  font-family: $font-family-serif;
  font-style: italic;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.65;
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

// Status pills
.status-pills {
  display: flex;
  gap: 16rpx;
  flex-wrap: wrap;
}
.status-pill {
  padding: 12rpx 24rpx;
  border-radius: 100rpx;
  border: 1rpx solid $line-sepia;
  background: $page-background;
  &.pill-active {
    border-color: $travel-blue;
    background: rgba(60, 96, 77, 0.08);
    .pill-txt { color: $travel-blue; }
  }
  &.pill-completed.pill-active {
    border-color: $stamp-red;
    background: rgba(164, 59, 45, 0.06);
    .pill-txt { color: $stamp-red; }
  }
  &.pill-cancelled.pill-active {
    border-color: $mute-text;
    background: rgba(142, 135, 117, 0.08);
    .pill-txt { color: $mute-text; }
  }
}
.pill-txt {
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $body-text;
}

// Info row (card count + days)
.info-row {
  background: $paper-beige;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  display: flex;
  align-items: center;
  padding: 24rpx 0;
}
.info-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
}
.info-n {
  font-family: $font-family-serif;
  font-size: 48rpx;
  color: $ink-black;
  line-height: 1;
  letter-spacing: -1rpx;
}
.info-n-green { color: $alive-green; font-size: 32rpx; }
.info-lbl {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 3rpx;
  color: $mute-text;
}
.info-divider {
  width: 1rpx;
  height: 60rpx;
  background: $line-sepia;
  flex-shrink: 0;
}

// ── Create buttons ──
.create-actions {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
  margin-top: 8rpx;
}

.btn-depart {
  background: $travel-blue;
  border-radius: 8rpx;
  padding: 36rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
}
.btn-depart-txt {
  font-family: $font-family-serif;
  font-size: 30rpx;
  color: $card-bg;
  letter-spacing: 8rpx;
}
.btn-depart-sub {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: rgba(251, 248, 241, 0.6);
}

.btn-plan {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 28rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
}
.btn-plan-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  letter-spacing: 4rpx;
}
.btn-plan-sub {
  font-family: $font-family-mono;
  font-size: 16rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.btn-dis { opacity: 0.4; pointer-events: none; }

// ── Edit buttons ──
.edit-actions {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
  margin-top: 8rpx;
}

.btn-activate {
  background: $card-bg;
  border: 1rpx solid rgba(60, 96, 77, 0.4);
  border-radius: 8rpx;
  padding: 28rpx 0;
  text-align: center;
}
.btn-activate-txt {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 3rpx;
  color: $travel-blue;
}

.btn-delete {
  background: $card-bg;
  border: 1rpx solid rgba(164, 59, 45, 0.3);
  border-radius: 8rpx;
  padding: 28rpx 0;
  text-align: center;
}
.btn-delete-txt {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 3rpx;
  color: $stamp-red;
}

.btm-gap { height: 120rpx; }
</style>

<template>
  <view class="page-container">
    <view class="postal-header">
      <view class="header-perf"></view>
      <text class="header-kicker">ATLAS · 旅行图鉴</text>
      <text class="header-title">走过的远方</text>
      <text class="header-subtitle">{{ cityCount }} 座城市 · {{ travels.length }} 段旅程</text>
    </view>

    <scroll-view class="content" scroll-y>

      <!-- ── Stats strip ── -->
      <view class="stats-strip">
        <view class="stat-col">
          <text class="stat-n">{{ countryCount }}</text>
          <text class="stat-l">COUNTRIES</text>
        </view>
        <view class="stat-sep"></view>
        <view class="stat-col">
          <text class="stat-n">{{ cityCount }}</text>
          <text class="stat-l">CITIES</text>
        </view>
        <view class="stat-sep"></view>
        <view class="stat-col">
          <text class="stat-n">{{ postcards.length }}</text>
          <text class="stat-l">POSTCARDS</text>
        </view>
        <view class="stat-sep"></view>
        <view class="stat-col">
          <text class="stat-n">{{ travels.length }}</text>
          <text class="stat-l">JOURNEYS</text>
        </view>
      </view>

      <!-- ── Atlas map card ── -->
      <view class="atlas-wrap">
        <!-- Outer decorative frame -->
        <view class="atlas-outer">
          <!-- Corner ornaments -->
          <text class="corner corner-tl">✦</text>
          <text class="corner corner-tr">✦</text>
          <text class="corner corner-bl">✦</text>
          <text class="corner corner-br">✦</text>

          <!-- Inner frame -->
          <view class="atlas-inner">

            <!-- Header banner -->
            <view class="atlas-banner">
              <view class="banner-line"></view>
              <view class="banner-mid">
                <text class="banner-side">ATLAS</text>
                <text class="banner-title">旅 行 足 迹 图</text>
                <text class="banner-side">{{ currentYear }}</text>
              </view>
              <view class="banner-line"></view>
            </view>

            <!-- Map canvas -->
            <view class="map-canvas">

              <!-- SVG route lines -->
              <svg
                v-if="routePaths.length > 0"
                viewBox="0 0 100 100"
                preserveAspectRatio="none"
                class="map-svg"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  v-for="(p, i) in routePaths"
                  :key="i"
                  :d="p.d"
                  fill="none"
                  stroke="#B5AE9B"
                  stroke-width="0.6"
                  stroke-dasharray="3 2"
                  stroke-linecap="round"
                  opacity="0.8"
                />
                <!-- Arrow heads as small circles at destination -->
                <circle
                  v-for="(p, i) in routePaths"
                  :key="'a'+i"
                  :cx="p.x2"
                  :cy="p.y2"
                  r="0.6"
                  fill="#B5AE9B"
                  opacity="0.6"
                />
              </svg>

              <!-- City pins -->
              <view
                v-for="(city, idx) in cityOrder"
                :key="city"
                class="city-pin"
                :style="{ left: pinLeft(city), top: pinTop(city) }"
              >
                <view class="pin-dot" :style="pinDotStyle(idx)">
                  <text class="pin-num" :style="{ color: pinNumColor(idx) }">{{ idx + 1 }}</text>
                </view>
                <text class="pin-label">{{ city }}</text>
              </view>

              <!-- Compass rose (always bottom-right) -->
              <view class="compass">
                <text class="compass-n">N</text>
                <view class="compass-cross">
                  <view class="compass-h"></view>
                  <view class="compass-v"></view>
                  <text class="compass-star">✦</text>
                </view>
                <text class="compass-s">S</text>
                <text class="compass-w">W</text>
                <text class="compass-e">E</text>
              </view>

              <!-- Empty placeholder -->
              <view v-if="cityOrder.length === 0" class="map-empty">
                <text class="map-empty-icon">✦</text>
                <text class="map-empty-txt">{{ mapEmptyTitle }}</text>
                <text class="map-empty-sub">TERRA INCOGNITA</text>
                <view class="map-empty-btn" @click="goMapEmptyAction">
                  <text class="map-empty-btn-txt">{{ mapEmptyActionText }}</text>
                </view>
              </view>

            </view>

            <!-- Footer -->
            <view class="atlas-footer">
              <view class="footer-line"></view>
              <text class="footer-txt">
                {{ cityOrder.length > 0 ? `已抵达 ${cityOrder.length} 处，旅途仍在继续` : 'TERRA INCOGNITA · 未知之地' }}
              </text>
              <view class="footer-line"></view>
            </view>

          </view>
        </view>
      </view>

      <!-- ── City postmarks ── -->
      <view class="section-block">
        <view class="section-hd-row">
          <text class="section-kicker">POSTMARKS · 到访城市</text>
          <text class="section-count">{{ cityData.length }} 站</text>
        </view>
        <view class="section-rule"></view>

        <view v-if="cityData.length > 0" class="postmarks-grid">
          <view v-for="c in cityData" :key="c.name" class="pm-stamp">
            <view class="pm-cancel-lines">
              <view class="pm-line"></view>
              <view class="pm-line"></view>
            </view>
            <text class="pm-city">{{ c.name }}</text>
            <view class="pm-cancel-lines">
              <view class="pm-line"></view>
              <view class="pm-line"></view>
            </view>
            <text class="pm-meta">{{ c.lastDate }}</text>
            <text class="pm-count">{{ c.count }} 张</text>
          </view>
        </view>

        <view v-else class="pm-empty">
          <text class="pm-empty-kicker">NO POSTMARKS</text>
          <text class="pm-empty-title">{{ postmarkEmptyTitle }}</text>
          <text class="pm-empty-txt">{{ postmarkEmptyText }}</text>
          <view class="pm-empty-btn" @click="goMapEmptyAction">
            <text class="pm-empty-btn-txt">{{ mapEmptyActionText }}</text>
          </view>
        </view>
      </view>

      <!-- ── Journey list ── -->
      <view class="section-block">
        <view class="section-hd-row">
          <text class="section-kicker">JOURNEYS · 旅程记录</text>
          <view class="new-btn" @click="goCreateTravel">
            <text class="new-btn-txt">+ 新建</text>
          </view>
        </view>
        <view class="section-rule"></view>

        <view v-if="travels.length > 0" class="journey-list">
          <view
            v-for="(travel, idx) in travels"
            :key="travel.id"
            class="journey-row"
            @click="goEditTravel(travel.id)"
          >
            <view v-if="idx > 0" class="journey-divider"></view>
            <view class="journey-inner">
              <view class="j-status-dot" :class="`status-${travel.status}`"></view>
              <view class="j-body">
                <text class="j-title">{{ travel.title }}</text>
                <text class="j-meta">{{ travel.destination.toUpperCase() }} · {{ formatTravelDate(travel) }}</text>
              </view>
              <view class="j-badge" :class="`badge-${travel.status}`">
                <text class="j-badge-txt">{{ getStatusText(travel.status) }}</text>
              </view>
            </view>
          </view>
        </view>

        <view v-else class="journey-empty">
          <text class="journey-empty-kicker">FIRST JOURNEY</text>
          <text class="journey-empty-title">创建第一段旅程</text>
          <text class="journey-empty-sub">先定下目的地，之后记录的明信片会自动连成足迹。</text>
          <view class="journey-empty-btn" @click="goCreateTravel">
            <text class="journey-empty-btn-txt">创建旅程 ›</text>
          </view>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { TravelStatus } from '@/model/Travel'
import type { Travel } from '@/model/Travel'

const store     = usePostcardStore()
const travels   = computed(() => store.sortedTravels)
const postcards = computed(() => store.sortedPostcards)

const currentYear = new Date().getFullYear()

// ── Stats ──
const cityList = computed(() => Array.from(new Set(postcards.value.map(p => p.city).filter(Boolean))))
const cityCount = computed(() => cityList.value.length)
const countryCount = computed(() => new Set(postcards.value.map(p => p.country).filter(Boolean)).size)
const hasTravels = computed(() => travels.value.length > 0)
const mapEmptyTitle = computed(() =>
  hasTravels.value ? '记录第一张明信片后，足迹会显示在这里' : '创建旅程后，就能开始生成足迹'
)
const mapEmptyActionText = computed(() =>
  hasTravels.value ? '记录明信片 ›' : '创建旅程 ›'
)
const postmarkEmptyTitle = computed(() =>
  hasTravels.value ? '还没有城市足迹' : '还没有旅程'
)
const postmarkEmptyText = computed(() =>
  hasTravels.value ? '记录一张带城市的明信片后，这里会生成第一枚邮戳。' : '先创建一段旅程，再把途中的城市记录下来。'
)

// ── City visit data (for postmarks) ──
interface CityData { name: string; count: number; lastDate: string }

const MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']

function fmtPostmarkDate(ts: number): string {
  const d = new Date(ts)
  return `${MONTHS[d.getMonth()]} ${d.getFullYear()}`
}

const cityData = computed<CityData[]>(() => {
  const map: Record<string, { count: number; lastTs: number }> = {}
  postcards.value.forEach(p => {
    if (!p.city) return
    if (!map[p.city]) map[p.city] = { count: 0, lastTs: 0 }
    map[p.city].count++
    if (p.recordedAt > map[p.city].lastTs) map[p.city].lastTs = p.recordedAt
  })
  return Object.entries(map)
    .map(([name, { count, lastTs }]) => ({ name, count, lastDate: fmtPostmarkDate(lastTs) }))
    .sort((a, b) => b.count - a.count)
})

// ── City order (chronological by first visit) ──
const cityOrder = computed<string[]>(() => {
  const firstVisit: Record<string, number> = {}
  postcards.value.forEach(p => {
    if (!p.city) return
    if (firstVisit[p.city] === undefined || p.recordedAt < firstVisit[p.city]) {
      firstVisit[p.city] = p.recordedAt
    }
  })
  return Object.entries(firstVisit).sort((a, b) => a[1] - b[1]).map(([c]) => c)
})

// ── City position (hash-based, stable) ──
function hashStr(s: string): number {
  let h = 5381
  for (let i = 0; i < s.length; i++) {
    h = ((h * 33) ^ s.charCodeAt(i)) & 0x7FFFFFFF
  }
  return h >>> 0
}

function pinX(city: string): number { return 8 + (hashStr(city) % 1000) / 1000 * 76 }
function pinY(city: string): number { return 8 + ((hashStr(city) >> 8) % 1000) / 1000 * 72 }

function pinLeft(city: string): string { return `${pinX(city)}%` }
function pinTop(city: string):  string { return `${pinY(city)}%` }

// ── SVG route paths (quadratic bezier) ──
interface SvgPath { d: string; x2: number; y2: number }

const routePaths = computed<SvgPath[]>(() =>
  cityOrder.value.slice(0, -1).map((city, i) => {
    const x1 = pinX(city), y1 = pinY(city)
    const x2 = pinX(cityOrder.value[i + 1]), y2 = pinY(cityOrder.value[i + 1])
    const mx = (x1 + x2) / 2, my = (y1 + y2) / 2
    const dx = x2 - x1, dy = y2 - y1
    const len = Math.sqrt(dx * dx + dy * dy) || 1
    const cx = mx + (-dy / len) * 6
    const cy = my + (dx / len) * 6
    return {
      d: `M ${x1.toFixed(1)} ${y1.toFixed(1)} Q ${cx.toFixed(1)} ${cy.toFixed(1)} ${x2.toFixed(1)} ${y2.toFixed(1)}`,
      x2, y2,
    }
  })
)

// ── Pin styles ──
function pinDotStyle(idx: number): Record<string, string> {
  if (idx === 0) return { background: '#A43B2D', borderColor: '#A43B2D', boxShadow: '0 0 0 6rpx rgba(164,59,45,0.15)' }
  if (idx === cityOrder.value.length - 1) return { background: '#2E7D58', borderColor: '#2E7D58', boxShadow: '0 0 0 6rpx rgba(46,125,88,0.15)' }
  return { background: '#FAF7F2', borderColor: '#9C7E5A' }
}

function pinNumColor(idx: number): string {
  return (idx === 0 || idx === cityOrder.value.length - 1) ? '#F4EFE5' : '#8E8775'
}

// ── Helpers ──
function getStatusText(status: string): string {
  return { ongoing: '进行中', completed: '已完成', planned: '待出发', cancelled: '已取消' }[status] ?? status
}

function formatTravelDate(t: Travel): string {
  const s = new Date(t.startDate), e = new Date(t.endDate)
  return `${s.getMonth()+1}·${String(s.getDate()).padStart(2,'0')} — ${e.getMonth()+1}·${String(e.getDate()).padStart(2,'0')}`
}

function goCreateTravel() { uni.navigateTo({ url: '/pages/travel/travel' }) }
function goRecord() { uni.switchTab({ url: '/pages/record/record' }) }
function goEditTravel(id: string) { uni.navigateTo({ url: `/pages/travel/travel?id=${id}` }) }
function goMapEmptyAction() {
  if (hasTravels.value) {
    goRecord()
  } else {
    goCreateTravel()
  }
}

onMounted(() => store.initData())
onShow(() => { if (store.travels.length > 0) store.initData() })
</script>

<style lang="scss" scoped>
.page-container {
  display: flex; flex-direction: column;
  height: 100vh; background: $page-background;
}

// ─── Header ───
.postal-header {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 56rpx 48rpx 20rpx;
  position: relative;
  flex-shrink: 0;
}
.header-perf {
  position: absolute; bottom: 0; left: 0; right: 0; height: 6rpx;
  background: repeating-linear-gradient(-45deg, #B8312A 0, #B8312A 5rpx, #ffffff 5rpx, #ffffff 10rpx, #1C3A72 10rpx, #1C3A72 15rpx, #ffffff 15rpx, #ffffff 20rpx);
}
.header-kicker {
  display: block; font-family: $font-family-code;
  font-size: 24rpx; letter-spacing: 1rpx; color: rgba(255,255,255,0.65); margin-bottom: 12rpx;
}
.header-title {
  display: block; font-family: $font-family-body;
  font-size: 46rpx; font-weight: 700; color: rgba(255,255,255,0.95); line-height: 1.15; letter-spacing: 0;
}
.header-subtitle {
  display: block; font-family: $font-family-body;
  font-size: 26rpx; color: rgba(255,255,255,0.7); margin-top: 10rpx;
}

.content { flex: 1; overflow: hidden; }

// ─── Stats strip ───
.stats-strip {
  display: flex; align-items: center;
  background: $card-bg;
  border-bottom: 2rpx solid $line-sepia;
  padding: 24rpx 0 26rpx;
  box-shadow: 0 8rpx 22rpx rgba(40, 30, 15, 0.08);
}
.stat-col {
  flex: 1; display: flex; flex-direction: column; align-items: center; gap: 6rpx;
}
.stat-n {
  font-family: $font-family-body; font-size: 44rpx; font-weight: 400;
  color: $ink-black; line-height: 1; letter-spacing: -1rpx;
}
.stat-l {
  font-family: $font-family-action; font-size: 22rpx; letter-spacing: 0; color: $mute-text;
}
.stat-sep {
  width: 1rpx; height: 48rpx; background: $line-sepia; flex-shrink: 0;
}

// ═══════════════════════════════════════
//  Atlas map card
// ═══════════════════════════════════════
.atlas-wrap {
  margin: 36rpx 32rpx 0;
}

.atlas-outer {
  border: 3rpx solid $rule-color;
  border-radius: 10rpx;
  padding: 14rpx;
  background: $paper-beige;
  position: relative;
  box-shadow: $shadow-md;
}

// Corner ornaments
.corner {
  position: absolute; font-size: 22rpx; color: $line-sepia; z-index: 2;
  font-family: serif;
}
.corner-tl { top: 4rpx;  left: 4rpx;  }
.corner-tr { top: 4rpx;  right: 4rpx; }
.corner-bl { bottom: 4rpx; left: 4rpx; }
.corner-br { bottom: 4rpx; right: 4rpx; }

.atlas-inner {
  border: 2rpx solid rgba($rule-color, 0.7);
  border-radius: 6rpx;
  background: rgba($card-bg, 0.28);
}

// Header banner
.atlas-banner {
  padding: 18rpx 18rpx 14rpx;
  border-bottom: 2rpx solid rgba($rule-color, 0.7);
  background: rgba($card-bg, 0.38);
}
.banner-line {
  height: 1rpx; background: $line-sepia; margin: 4rpx 0;
}
.banner-mid {
  display: flex; justify-content: space-between; align-items: center;
  padding: 4rpx 0;
}
.banner-side {
  font-family: $font-family-action; font-size: 22rpx; letter-spacing: 0; color: $mute-text;
}
.banner-title {
  font-family: $font-family-display; font-size: 30rpx; font-weight: 500;
  color: $ink-black; letter-spacing: 2rpx;
}

// Map canvas
.map-canvas {
  position: relative;
  width: 100%;
  height: 430rpx;
  overflow: hidden;
  background: $paper-beige;
  // subtle dot-grid background like old maps
  background-image: radial-gradient(circle, rgba(156,126,90,0.15) 1rpx, transparent 1rpx);
  background-size: 28rpx 28rpx;
}

.map-svg {
  position: absolute; top: 0; left: 0;
  width: 100%; height: 100%;
}

// City pin
.city-pin {
  position: absolute;
  display: flex; flex-direction: column; align-items: center;
  transform: translate(-50%, -50%);
  z-index: 2;
}

.pin-dot {
  width: 32rpx; height: 32rpx;
  border-radius: 50%;
  border: 2rpx solid #9C7E5A;
  display: flex; align-items: center; justify-content: center;
  position: relative; z-index: 1;
}

.pin-num {
  font-family: $font-family-code; font-size: 22rpx; line-height: 1;
}

.pin-label {
  font-family: $font-family-body;
  font-size: 22rpx; letter-spacing: 0;
  color: $ink-black;
  margin-top: 4rpx;
  background: rgba(250,247,242,0.85);
  padding: 1rpx 6rpx;
  border-radius: 2rpx;
  white-space: nowrap;
}

// Compass rose (fixed bottom-right)
.compass {
  position: absolute; bottom: 20rpx; right: 20rpx;
  width: 72rpx; height: 72rpx;
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  opacity: 0.45;
}
.compass-n, .compass-s {
  font-family: $font-family-code; font-size: 22rpx; color: $ink-black; line-height: 1;
}
.compass-cross {
  position: relative; width: 40rpx; height: 40rpx;
  display: flex; align-items: center; justify-content: center;
}
.compass-h {
  position: absolute; left: 0; right: 0; height: 1rpx; background: $mute-text;
}
.compass-v {
  position: absolute; top: 0; bottom: 0; width: 1rpx; background: $mute-text; left: 50%; margin-left: -0.5rpx;
}
.compass-star {
  font-size: 22rpx; color: $mute-text; z-index: 1;
}
.compass-w, .compass-e {
  position: absolute;
  font-family: $font-family-code; font-size: 22rpx; color: $ink-black;
  top: 50%; transform: translateY(-50%);
}
.compass-w { left: 0; }
.compass-e { right: 0; }

// Map empty state
.map-empty {
  position: absolute; inset: 0;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center; gap: 18rpx;
}
.map-empty-icon { font-size: 48rpx; color: $line-sepia; opacity: 0.5; }
.map-empty-txt {
  font-family: $font-family-body; font-size: 30rpx; color: $body-text; text-align: center; font-weight: 600;
}
.map-empty-sub {
  font-family: $font-family-body; font-size: 24rpx; letter-spacing: 0; color: $mute-text;
}
.map-empty-btn {
  margin-top: 4rpx;
  min-width: 204rpx;
  height: 68rpx;
  border-radius: 8rpx;
  background: rgba($travel-blue, 0.92);
  display: flex;
  align-items: center;
  justify-content: center;

  &:active { background: $forest-green; }
}
.map-empty-btn-txt {
  font-family: $font-family-action; font-size: 24rpx; color: #F4EFE5; letter-spacing: 0;
}

// Atlas footer
.atlas-footer {
  padding: 14rpx 18rpx 18rpx;
  border-top: 2rpx solid rgba($rule-color, 0.7);
  display: flex; align-items: center; gap: 12rpx;
}
.footer-line { flex: 1; height: 1rpx; background: $line-sepia; }
.footer-txt {
  font-family: $font-family-action; font-size: 22rpx; letter-spacing: 0; color: $mute-text;
  white-space: nowrap;
}

// ═══════════════════════════════════════
//  City postmarks
// ═══════════════════════════════════════
.section-block { margin: 40rpx 32rpx 0; }

.section-hd-row {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 16rpx;
  padding: 16rpx 18rpx;
  border-left: 8rpx solid $travel-blue;
  background: rgba($travel-blue, 0.08);
  border-radius: 8rpx;
}
.section-kicker {
  font-family: $font-family-action; font-size: 24rpx; font-weight: 700; letter-spacing: 0; color: $travel-blue;
}
.section-count {
  font-family: $font-family-action; font-size: 22rpx; letter-spacing: 0; color: $mute-text;
}
.section-rule { height: 0; margin-bottom: 22rpx; }

.postmarks-grid {
  display: grid; grid-template-columns: repeat(3, 1fr); gap: 16rpx;
}

.pm-stamp {
  border: 1rpx solid $line-sepia;
  border-radius: 4rpx;
  background: $card-bg;
  padding: 10rpx 10rpx 12rpx;
  display: flex; flex-direction: column; align-items: center; gap: 0;
}

.pm-cancel-lines {
  width: 100%; display: flex; flex-direction: column; gap: 4rpx; padding: 4rpx 0;
}
.pm-line {
  height: 1rpx; background: $mute-text; opacity: 0.3; border-radius: 1rpx;
}

.pm-city {
  font-family: $font-family-display;
  font-size: 28rpx; font-weight: 500; color: $ink-black;
  text-align: center; padding: 8rpx 0;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap; width: 100%;
}

.pm-meta {
  font-family: $font-family-code; font-size: 22rpx; letter-spacing: 1rpx;
  color: $mute-text; margin-top: 6rpx;
}
.pm-count {
  font-family: $font-family-body; font-size: 24rpx; color: $travel-blue; margin-top: 2rpx;
}

.pm-empty {
  padding: 44rpx 32rpx; text-align: center;
  background: $card-bg; border: 2rpx solid $line-sepia; border-radius: 10rpx;
  box-shadow: $shadow-sm;
  display: flex; flex-direction: column; align-items: center; gap: 12rpx;
}
.pm-empty-kicker {
  font-family: $font-family-code; font-size: 22rpx; letter-spacing: 2rpx; color: $travel-blue;
}
.pm-empty-title {
  font-family: $font-family-body; font-size: 32rpx; color: $ink-black;
}
.pm-empty-txt {
  font-family: $font-family-body; font-size: 24rpx; color: $mute-text; line-height: 1.55;
}
.pm-empty-btn {
  margin-top: 8rpx;
  min-width: 220rpx;
  height: 70rpx;
  border-radius: 8rpx;
  background: $travel-blue;
  display: flex; align-items: center; justify-content: center;
}
.pm-empty-btn-txt {
  font-family: $font-family-action; font-size: 26rpx; color: #F4EFE5; letter-spacing: 0;
}

// ─── Journey list ───
.new-btn {
  border: 1rpx solid rgba(46,125,88,0.4); border-radius: 100rpx;
  padding: 6rpx 22rpx; background: rgba(46,125,88,0.06);
}
.new-btn-txt {
  font-family: $font-family-action; font-size: 24rpx; letter-spacing: 0; color: $travel-blue;
}

.journey-list {
  background: $card-bg; border: 2rpx solid $line-sepia; border-radius: 10rpx; overflow: hidden;
  box-shadow: $shadow-sm;
}
.journey-divider { height: 1rpx; background: $line-sepia; margin: 0 24rpx; }

.journey-inner {
  display: flex; align-items: center; gap: 20rpx; padding: 22rpx 24rpx;
}

.j-status-dot {
  width: 16rpx; height: 16rpx; border-radius: 50%; flex-shrink: 0;
  &.status-ongoing   { background: #5E8C4F; }
  &.status-completed { background: $mute-text; }
  &.status-planned   { background: #1F4B66; }
  &.status-cancelled { background: #A43B2D; opacity: 0.5; }
}

.j-body { flex: 1; min-width: 0; }
.j-title {
  display: block; font-family: $font-family-body;
  font-size: 28rpx; font-weight: 500; color: $ink-black;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-bottom: 4rpx;
}
.j-meta {
  display: block; font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 2rpx; color: $mute-text;
}

.j-badge {
  flex-shrink: 0; padding: 6rpx 16rpx; border-radius: 100rpx; border: 1rpx solid currentColor;
  &.badge-ongoing   { color: #5E8C4F;  background: rgba(94,140,79,0.08);  }
  &.badge-completed { color: $mute-text; background: rgba(142,135,117,0.08); }
  &.badge-planned   { color: #1F4B66; background: rgba(31,75,102,0.08);   }
  &.badge-cancelled { color: #A43B2D; background: rgba(164,59,45,0.08);   }
}
.j-badge-txt {
  font-family: $font-family-action; font-size: 22rpx; letter-spacing: 0;
}

.journey-empty {
  background: $card-bg; border: 2rpx solid $line-sepia;
  border-radius: 10rpx; padding: 52rpx 36rpx; text-align: center;
  box-shadow: $shadow-sm;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
}
.journey-empty-kicker {
  font-family: $font-family-code; font-size: 22rpx; letter-spacing: 2rpx; color: $travel-blue;
}
.journey-empty-title {
  font-family: $font-family-body; font-size: 34rpx; color: $ink-black;
}
.journey-empty-sub {
  font-family: $font-family-body; font-size: 24rpx; color: $mute-text; line-height: 1.55;
}
.journey-empty-btn {
  margin-top: 8rpx;
  min-width: 220rpx;
  height: 72rpx;
  border-radius: 8rpx;
  background: $travel-blue;
  display: flex;
  align-items: center;
  justify-content: center;
}
.journey-empty-btn-txt {
  font-family: $font-family-action; font-size: 26rpx; color: #F4EFE5; letter-spacing: 0;
}

.btm-gap { height: 120rpx; }
</style>

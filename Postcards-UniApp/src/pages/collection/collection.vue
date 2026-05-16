<template>
  <view class="page-container">
    <view class="postal-header">
      <view class="header-perf"></view>
      <view class="nav-back" @click="goBack">
        <IconBack :size="18" color="rgba(255,255,255,0.9)" />
      </view>
      <text class="header-kicker">COLLECTION · 珍藏</text>
      <text class="header-title">我的收藏</text>
      <text class="header-subtitle">{{ postcardAlbums.length }} 本明信片集 · {{ stampAlbums.length }} 本邮票集</text>
    </view>

    <scroll-view class="content" scroll-y>

      <!-- ─── 增值服务：实体印刷 ─── -->
      <view class="print-banner" @click="onPrintTap">
        <view class="print-left">
          <text class="print-kicker">PRINT SERVICE · 增值服务</text>
          <text class="print-title">印成实体册</text>
          <text class="print-desc">将你的明信片集或邮票集冲印为精美纸质版，永久珍藏</text>
          <view class="print-tag-row">
            <view class="print-tag">明信片集</view>
            <view class="print-tag">邮票集</view>
            <view class="print-tag">礼品定制</view>
          </view>
        </view>
        <view class="print-right">
          <text class="print-icon">✉</text>
          <text class="print-cta">了解详情 →</text>
        </view>
      </view>

      <!-- ─── 明信片集（按旅程） ─── -->
      <view class="section-wrap">
        <view class="section-hd">
          <view>
            <text class="section-kicker">POSTCARD ALBUMS · 明信片集</text>
            <text class="section-ttl">按旅程收录</text>
          </view>
          <text class="section-badge">{{ String(postcardAlbums.length).padStart(2, '0') }}</text>
        </view>
        <view class="section-rule"></view>
        <text class="section-hint">收藏明信片后，自动归入对应旅程册</text>

        <view v-if="postcardAlbums.length > 0" class="album-grid">
          <view
            v-for="album in postcardAlbums"
            :key="album.travel.id"
            class="pc-album"
            @click="openPostcardAlbum(album)"
          >
            <view class="album-spine" :class="spineClass(album.travel.status)"></view>
            <view class="album-cover">
              <view class="cover-photo-area">
                <template v-if="album.cards.length >= 4">
                  <view class="cover-collage">
                    <view v-for="i in 4" :key="i" class="collage-cell">
                      <image v-if="album.cards[i-1].photoUrl" :src="album.cards[i-1].photoUrl" class="collage-img" mode="aspectFill" />
                      <view v-else class="collage-grad"></view>
                    </view>
                  </view>
                </template>
                <template v-else>
                  <image v-if="album.cards[0].photoUrl" :src="album.cards[0].photoUrl" class="cover-single-img" mode="aspectFill" />
                  <view v-else class="cover-single-grad"></view>
                </template>
                <view class="cover-count-badge">
                  <text class="cover-count-n">{{ album.cards.length }}</text>
                  <text class="cover-count-lbl">张</text>
                </view>
              </view>
              <view class="cover-info">
                <text class="cover-dest">{{ album.travel.destination.toUpperCase() }}</text>
                <text class="cover-title">{{ album.travel.title }}</text>
                <text class="cover-date">{{ formatAlbumDate(album.travel.startDate) }}</text>
              </view>
              <view class="cover-perf">
                <view v-for="i in 14" :key="i" class="cover-perf-hole"></view>
              </view>
            </view>
          </view>
        </view>

        <view v-else class="empty-block">
          <text class="empty-main">还没有明信片集</text>
          <text class="empty-sub">收藏明信片后自动归册</text>
        </view>
      </view>

      <!-- ─── 邮票集（按系列） ─── -->
      <view class="section-wrap">
        <view class="section-hd">
          <view>
            <text class="section-kicker">STAMP ALBUMS · 邮票集</text>
            <text class="section-ttl">按系列收录</text>
          </view>
          <view class="section-hd-right">
            <text class="section-badge">{{ String(stampAlbums.length).padStart(2, '0') }}</text>
            <text class="section-more" @click="goShop">商店 ›</text>
          </view>
        </view>
        <view class="section-rule"></view>
        <text class="section-hint">在邮票商店预览邮票时，点击「加入邮票集」即可收录</text>

        <view v-if="stampsLoading" class="album-grid">
          <view v-for="i in 4" :key="i" class="sk-album shimmer"></view>
        </view>

        <view v-else-if="stampAlbums.length > 0" class="album-grid">
          <view
            v-for="album in stampAlbums"
            :key="album.series"
            class="stamp-album"
            @click="goShop"
          >
            <view class="album-spine" :style="{ background: album.stamps[0].color }"></view>
            <view class="stamp-album-cover">
              <view class="stamp-mosaic">
                <view
                  v-for="stamp in album.stamps.slice(0, 6)"
                  :key="stamp.id"
                  class="mosaic-stamp"
                  :style="{ borderColor: stamp.color }"
                >
                  <image v-if="stamp.imageUrl" :src="stamp.imageUrl" class="mosaic-stamp-img" mode="aspectFill" />
                  <view v-else class="mosaic-stamp-color" :style="{ background: stamp.color }"></view>
                </view>
                <view
                  v-for="i in Math.max(0, 6 - album.stamps.length)"
                  :key="'ph' + i"
                  class="mosaic-stamp mosaic-empty"
                ></view>
              </view>
              <view class="stamp-cover-info">
                <view class="stamp-series-row">
                  <text class="stamp-series-tag">SÉRIE {{ album.series }}</text>
                  <text class="stamp-owned-count">{{ album.stamps.length }} 款</text>
                </view>
                <text class="stamp-series-name">{{ album.seriesName }}系列</text>
              </view>
              <view class="cover-perf">
                <view v-for="i in 14" :key="i" class="cover-perf-hole"></view>
              </view>
            </view>
          </view>
        </view>

        <view v-else class="empty-block">
          <text class="empty-main">还没有邮票集</text>
          <text class="empty-sub">解锁邮票后，在预览中加入邮票集</text>
          <view class="empty-link" @click="goShop">
            <text class="empty-link-txt">前往邮票商店 →</text>
          </view>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>

    <!-- Postcard album detail sheet -->
    <view v-if="activeAlbum" class="album-sheet-mask" @click.self="activeAlbum = null">
      <view class="album-sheet">
        <view class="sheet-hd">
          <view>
            <text class="sheet-kicker">{{ activeAlbum.travel.destination.toUpperCase() }}</text>
            <text class="sheet-title">{{ activeAlbum.travel.title }}</text>
          </view>
          <view class="sheet-close" @click="activeAlbum = null">
            <text class="sheet-close-txt">✕</text>
          </view>
        </view>
        <view class="sheet-rule"></view>
        <scroll-view class="sheet-scroll" scroll-y>
          <view class="sheet-grid">
            <view
              v-for="card in activeAlbum.cards"
              :key="card.id"
              class="sheet-cell"
              @click="viewPostcard(card)"
            >
              <view class="sheet-photo-wrap">
                <image v-if="card.photoUrl" :src="card.photoUrl" class="sheet-photo" mode="aspectFill" />
                <view v-else class="sheet-photo-grad"></view>
                <view class="sheet-overlay">
                  <text class="sheet-loc">{{ card.locationName }}</text>
                  <IconFavorite :size="18" color="#A43B2D" />
                </view>
              </view>
              <text class="sheet-date">{{ formatShortDate(card.recordedAt) }}</text>
            </view>
          </view>
        </scroll-view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { useAuthStore } from '@/stores/auth'
import { StampApi } from '@/services/api'
import type { StampItem } from '@/services/api'
import type { Postcard } from '@/model/Postcard'
import { TravelStatus } from '@/model/Travel'
import { IconBack, IconFavorite } from '@/components/icons'

const store     = usePostcardStore()
const authStore = useAuthStore()

// ── Postcard albums: favorited postcards grouped by travel ──
interface PostcardAlbum {
  travel: (typeof store.sortedTravels)[0]
  cards: Postcard[]
}

const postcardAlbums = computed<PostcardAlbum[]>(() => {
  const favCards = store.sortedPostcards.filter(p => p.isFavorite)
  return store.sortedTravels
    .map(travel => ({ travel, cards: favCards.filter(c => c.travelId === travel.id) }))
    .filter(a => a.cards.length > 0)
})

// ── Stamp albums: favorited owned stamps grouped by series ──
interface StampAlbum { series: string; seriesName: string; stamps: StampItem[] }

const ownedStamps   = ref<StampItem[]>([])
const stampsLoading = ref(true)

const stampAlbums = computed<StampAlbum[]>(() => {
  const favStamps = ownedStamps.value.filter(s => authStore.favoriteStampIds.includes(s.id))
  const map: Record<string, StampItem[]> = {}
  favStamps.forEach(s => {
    if (!map[s.series]) map[s.series] = []
    map[s.series].push(s)
  })
  return Object.keys(map).sort().map(series => ({
    series,
    seriesName: map[series][0].seriesName,
    stamps: map[series],
  }))
})

async function loadStamps() {
  stampsLoading.value = true
  try { ownedStamps.value = await StampApi.my() }
  catch { ownedStamps.value = [] }
  finally { stampsLoading.value = false }
}

// ── Active album sheet ──
const activeAlbum = ref<PostcardAlbum | null>(null)
function openPostcardAlbum(album: PostcardAlbum) { activeAlbum.value = album }
function viewPostcard(card: Postcard) {
  activeAlbum.value = null
  uni.navigateTo({ url: `/pages/detail/detail?id=${card.id}` })
}

// ── Print service ──
function onPrintTap() {
  uni.showToast({ title: '敬请期待，即将上线', icon: 'none' })
}

// ── Helpers ──
const MONTHS_SHORT = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
function formatAlbumDate(ts: number): string {
  const d = new Date(ts)
  return `${MONTHS_SHORT[d.getMonth()]} ${d.getFullYear()}`
}
function formatShortDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getMonth()+1}/${d.getDate()}`
}
function spineClass(status: TravelStatus): string {
  return { ongoing: 'spine-ongoing', planned: 'spine-planned', completed: 'spine-completed', cancelled: 'spine-cancelled' }[status] ?? 'spine-completed'
}

function goShop() { uni.navigateTo({ url: '/pages/shop/shop' }) }
function goBack()  { uni.navigateBack({ fail: () => uni.switchTab({ url: '/pages/home/home' }) }) }

onMounted(async () => { store.initData(); await loadStamps() })
onShow(() => { if (store.postcards.length === 0) store.initData(); loadStamps() })
</script>

<style lang="scss" scoped>
.page-container {
  display: flex; flex-direction: column;
  height: 100vh; background: $page-background;
}

// ─── Header ───
.postal-header {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 100rpx 48rpx 20rpx;
  position: relative;
  flex-shrink: 0;
}
.header-perf {
  position: absolute; bottom: 0; left: 0; right: 0; height: 6rpx;
  background: repeating-linear-gradient(-45deg, #B8312A 0, #B8312A 5rpx, #ffffff 5rpx, #ffffff 10rpx, #1C3A72 10rpx, #1C3A72 15rpx, #ffffff 15rpx, #ffffff 20rpx);
}
.nav-back {
  position: absolute; top: 52rpx; left: 48rpx;
  width: 64rpx; height: 64rpx;
  display: flex; align-items: center; justify-content: center;
}
.header-kicker {
  display: block; font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 2rpx; color: rgba(255,255,255,0.65); margin-bottom: 12rpx;
}
.header-title {
  display: block; font-family: $font-family-body;
  font-size: 46rpx; font-weight: 700; color: rgba(255,255,255,0.95); line-height: 1.15; letter-spacing: 0;
}
.header-subtitle {
  display: block; font-family: $font-family-body;
  font-size: 24rpx; color: rgba(255,255,255,0.7); margin-top: 10rpx;
}

.content { flex: 1; overflow: hidden; }

// ═══════════════════════════════════════
//  Print service banner
// ═══════════════════════════════════════
.print-banner {
  margin: 32rpx 40rpx 0;
  background: linear-gradient(135deg, #2E7D58 0%, #1F5C3F 100%);
  border-radius: 12rpx;
  padding: 32rpx 28rpx 28rpx;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20rpx;
  position: relative;
  overflow: hidden;
}

// Decorative background pattern
.print-banner::before {
  content: '';
  position: absolute;
  top: -40rpx; right: -40rpx;
  width: 200rpx; height: 200rpx;
  border-radius: 50%;
  background: rgba(255,255,255,0.05);
}
.print-banner::after {
  content: '';
  position: absolute;
  bottom: -60rpx; right: 40rpx;
  width: 160rpx; height: 160rpx;
  border-radius: 50%;
  background: rgba(255,255,255,0.04);
}

.print-left { flex: 1; min-width: 0; }

.print-kicker {
  display: block; font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 1rpx; color: rgba(196,224,203,0.7); margin-bottom: 10rpx;
}
.print-title {
  display: block; font-family: $font-family-body;
  font-size: 44rpx; font-weight: 400; color: #F4EFE5; line-height: 1.1; margin-bottom: 12rpx;
}
.print-desc {
  display: block; font-family: $font-family-body;
  font-size: 24rpx; color: rgba(244,239,229,0.7); line-height: 1.6; margin-bottom: 20rpx;
}
.print-tag-row {
  display: flex; flex-wrap: wrap; gap: 10rpx;
}
.print-tag {
  font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 1rpx; color: rgba(196,224,203,0.9);
  border: 1rpx solid rgba(196,224,203,0.35);
  border-radius: 100rpx; padding: 4rpx 14rpx;
}

.print-right {
  display: flex; flex-direction: column; align-items: center;
  gap: 10rpx; flex-shrink: 0; position: relative; z-index: 1;
}
.print-icon {
  font-size: 56rpx; color: rgba(244,239,229,0.45); line-height: 1;
}
.print-cta {
  font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 2rpx; color: rgba(196,224,203,0.9);
  white-space: nowrap;
}

// ─── Section ───
.section-wrap { padding: 44rpx 40rpx 0; }

.section-hd {
  display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 16rpx;
}
.section-hd-right { display: flex; align-items: baseline; gap: 16rpx; }
.section-kicker {
  display: block; font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 1rpx; color: $travel-blue; margin-bottom: 8rpx;
}
.section-ttl {
  display: block; font-family: $font-family-body;
  font-weight: 500; font-size: 38rpx; color: $ink-black; line-height: 1;
}
.section-badge {
  font-family: $font-family-body; font-size: 44rpx; color: $line-sepia; line-height: 1; letter-spacing: -1rpx;
}
.section-more {
  font-family: $font-family-code; font-size: 22rpx; letter-spacing: 2rpx; color: $travel-blue;
}
.section-rule { height: 2rpx; background: $line-sepia; margin-bottom: 12rpx; }
.section-hint {
  display: block; font-family: $font-family-body;
  font-size: 24rpx; font-style: italic; color: $mute-text; margin-bottom: 24rpx;
}

// ═══════════════════════════════════════
//  Album grid — 2 columns
// ═══════════════════════════════════════
.album-grid {
  display: grid; grid-template-columns: repeat(2, 1fr);
  gap: 20rpx; margin-bottom: 8rpx;
}

.album-spine {
  width: 14rpx; flex-shrink: 0; border-radius: 2rpx 0 0 2rpx;
}
.spine-ongoing   { background: $travel-blue; }
.spine-planned   { background: #7A8F7D; }
.spine-completed { background: #9C7E5A; }
.spine-cancelled { background: $whisper; }

.cover-perf {
  display: flex; justify-content: space-around;
  padding: 5rpx 6rpx; background: $page-background; border-top: 1rpx solid $line-sepia;
}
.cover-perf-hole {
  width: 9rpx; height: 9rpx; border-radius: 50%;
  background: $page-background; border: 1rpx solid $line-sepia;
}

// ── Postcard album ──
.pc-album {
  display: flex; border-radius: 6rpx; overflow: hidden;
  box-shadow: 3rpx 4rpx 16rpx rgba(60,40,20,0.13), 0 1rpx 3rpx rgba(60,40,20,0.06);
  background: $card-bg; border: 1rpx solid $line-sepia;
}
.album-cover { flex: 1; display: flex; flex-direction: column; min-width: 0; }

.cover-photo-area {
  flex: 1; position: relative; overflow: hidden; min-height: 220rpx;
}
.cover-collage {
  display: grid; grid-template-columns: 1fr 1fr; grid-template-rows: 1fr 1fr;
  width: 100%; height: 100%; position: absolute; top: 0; left: 0; gap: 1rpx;
}
.collage-cell { overflow: hidden; position: relative; }
.collage-img  { width: 100%; height: 100%; }
.collage-grad { width: 100%; height: 100%; background: linear-gradient(135deg, #C9D2B6, #6E8862); }
.cover-single-img {
  position: absolute; top: 0; left: 0; width: 100%; height: 100%;
}
.cover-single-grad {
  position: absolute; top: 0; left: 0; width: 100%; height: 100%;
  background: linear-gradient(135deg, #C9D2B6 0%, #6E8862 60%, #3C604D 100%);
}
.cover-count-badge {
  position: absolute; bottom: 10rpx; right: 10rpx;
  background: rgba(20,15,10,0.55); border-radius: 4rpx; padding: 4rpx 10rpx;
  display: flex; align-items: baseline; gap: 3rpx;
}
.cover-count-n   { font-family: $font-family-body; font-size: 26rpx; color: #fff; line-height: 1; }
.cover-count-lbl { font-family: $font-family-code; font-size: 22rpx; color: rgba(255,255,255,0.8); }

.cover-info { padding: 14rpx 16rpx 10rpx; background: $card-bg; }
.cover-dest {
  display: block; font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 1rpx; color: $mute-text; margin-bottom: 4rpx;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.cover-title {
  display: block; font-family: $font-family-body;
  font-size: 28rpx; font-weight: 500; color: $ink-black; line-height: 1.2;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.cover-date {
  display: block; font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 1rpx; color: $whisper; margin-top: 4rpx;
}

// ── Stamp album ──
.stamp-album {
  display: flex; border-radius: 6rpx; overflow: hidden;
  box-shadow: 3rpx 4rpx 16rpx rgba(60,40,20,0.13), 0 1rpx 3rpx rgba(60,40,20,0.06);
  background: $card-bg; border: 1rpx solid $line-sepia;
}
.stamp-album-cover { flex: 1; display: flex; flex-direction: column; min-width: 0; }

.stamp-mosaic {
  display: grid; grid-template-columns: repeat(3, 1fr);
  gap: 6rpx; padding: 16rpx 14rpx 10rpx; background: $paper-beige; flex: 1;
}
.mosaic-stamp {
  aspect-ratio: 1; border: 1rpx solid $line-sepia; border-radius: 2rpx; overflow: hidden;
}
.mosaic-stamp-img   { width: 100%; height: 100%; }
.mosaic-stamp-color { width: 100%; height: 100%; opacity: 0.5; }
.mosaic-empty       { background: $card-bg; border: 1rpx dashed $line-sepia; opacity: 0.5; }

.stamp-cover-info { padding: 12rpx 16rpx 10rpx; background: $card-bg; }
.stamp-series-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4rpx; }
.stamp-series-tag {
  font-family: $font-family-code; font-size: 22rpx; letter-spacing: 1rpx; color: $mute-text;
}
.stamp-owned-count {
  font-family: $font-family-body; font-size: 24rpx; color: $travel-blue;
}
.stamp-series-name {
  display: block; font-family: $font-family-body;
  font-size: 28rpx; font-weight: 500; color: $ink-black; line-height: 1.2;
}

// ─── Skeleton ───
.sk-album {
  height: 340rpx; border-radius: 6rpx; background: $line-sepia; opacity: 0.25;
}
.shimmer {
  background: linear-gradient(90deg, $line-sepia 25%, #E8E0D0 50%, $line-sepia 75%);
  background-size: 200% 100%;
  animation: shimmer 1.4s infinite;
}
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }

// ─── Empty ───
.empty-block {
  display: flex; flex-direction: column; align-items: center;
  padding: 52rpx 0; background: $card-bg;
  border: 1rpx solid $line-sepia; border-radius: 8rpx; margin-bottom: 8rpx;
}
.empty-main { font-family: $font-family-body; font-size: 30rpx; color: $body-text; margin-bottom: 8rpx; }
.empty-sub  { font-family: $font-family-body; font-size: 24rpx; color: $mute-text; text-align: center; padding: 0 40rpx; }
.empty-link { margin-top: 20rpx; }
.empty-link-txt { font-family: $font-family-code; font-size: 24rpx; letter-spacing: 2rpx; color: $travel-blue; }

// ═══════════════════════════════════════
//  Postcard album detail bottom sheet
// ═══════════════════════════════════════
.album-sheet-mask {
  position: fixed; inset: 0;
  background: rgba(20,15,10,0.5); z-index: 100;
  display: flex; align-items: flex-end;
}
.album-sheet {
  background: $page-background; border-radius: 24rpx 24rpx 0 0;
  width: 100%; max-height: 75vh;
  display: flex; flex-direction: column;
  padding-bottom: env(safe-area-inset-bottom, 0);
}
.sheet-hd {
  display: flex; justify-content: space-between; align-items: flex-start;
  padding: 32rpx 40rpx 20rpx; border-bottom: 1rpx solid $line-sepia;
}
.sheet-kicker {
  display: block; font-family: $font-family-code;
  font-size: 22rpx; letter-spacing: 1rpx; color: $travel-blue; margin-bottom: 6rpx;
}
.sheet-title {
  display: block; font-family: $font-family-body;
  font-size: 40rpx; font-weight: 400; color: $ink-black; line-height: 1.2;
}
.sheet-close {
  width: 56rpx; height: 56rpx;
  display: flex; align-items: center; justify-content: center;
  background: $card-bg; border-radius: 50%; border: 1rpx solid $line-sepia;
}
.sheet-close-txt { font-size: 24rpx; color: $body-text; }
.sheet-rule { height: 1rpx; background: $line-sepia; }
.sheet-scroll { flex: 1; overflow: hidden; }
.sheet-grid {
  display: grid; grid-template-columns: repeat(3, 1fr);
  gap: 12rpx; padding: 24rpx 32rpx 40rpx;
}
.sheet-cell { display: flex; flex-direction: column; align-items: center; gap: 6rpx; }
.sheet-photo-wrap {
  width: 100%; aspect-ratio: 1; border-radius: 6rpx; overflow: hidden; position: relative;
}
.sheet-photo {
  position: absolute; top: 0; left: 0; width: 100%; height: 100%;
}
.sheet-photo-grad {
  position: absolute; top: 0; left: 0; width: 100%; height: 100%;
  background: linear-gradient(135deg, #C9D2B6, #6E8862);
}
.sheet-overlay {
  position: absolute; bottom: 0; left: 0; right: 0;
  padding: 20rpx 10rpx 8rpx;
  background: linear-gradient(transparent, rgba(20,15,10,0.55));
  display: flex; justify-content: space-between; align-items: flex-end;
}
.sheet-loc {
  font-family: $font-family-body; font-size: 22rpx; color: #fff;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1;
}
.sheet-date {
  font-family: $font-family-code; font-size: 22rpx; letter-spacing: 1rpx; color: $mute-text; text-align: center;
}

.btm-gap { height: 120rpx; }
</style>

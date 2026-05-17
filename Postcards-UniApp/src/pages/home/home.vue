<template>
  <view class="page-container">
    <!-- Hero header -->
    <view class="hero">
      <view class="hero-inner">
        <view class="hero-left">
          <text class="hero-greeting">{{ greeting }}</text>
          <text class="hero-name">{{ user?.nickname ?? '旅行者' }}</text>
        </view>
        <view class="hero-date">
          <text class="date-month">{{ dateMonth }}</text>
          <text class="date-day">{{ dateDay }}</text>
        </view>
      </view>

    </view>

    <scroll-view class="content" scroll-y @scrolltolower="loadMore">

      <!-- Primary action -->
      <view class="focus-card">
        <view class="focus-copy">
          <text class="focus-kicker">TODAY · 今日</text>
          <text class="focus-title">{{ focusTitle }}</text>
          <text class="focus-sub">{{ focusSubtitle }}</text>
        </view>
        <view class="focus-action" @click="goPrimaryAction">
          <IconCamera :size="30" color="#F4EFE5" />
          <text class="focus-action-txt">{{ primaryActionText }}</text>
        </view>
      </view>

      <!-- Quick actions -->
      <view class="actions-row">
        <view class="action-btn" @click="goInbox">
          <view class="action-icon"><IconInbox :size="34" color="#3C604D" /></view>
          <text class="action-lbl">收件箱</text>
          <view class="action-badge" v-if="unreadCount > 0">
            <text class="action-badge-txt">{{ unreadCount > 9 ? '9+' : unreadCount }}</text>
          </view>
        </view>
        <view class="action-btn" @click="goSend">
          <view class="action-icon"><IconSend :size="34" color="#3C604D" /></view>
          <text class="action-lbl">寄出</text>
        </view>
        <view class="action-btn" @click="goContacts">
          <view class="action-icon"><IconContacts :size="34" color="#3C604D" /></view>
          <text class="action-lbl">通讯录</text>
        </view>
      </view>

      <!-- Current travel -->
      <view class="section" v-if="store.currentTravel">
        <view class="section-hd">
          <text class="section-kicker">CURRENT TRIP · 当前旅程</text>
          <view class="section-rule"></view>
        </view>
        <view class="travel-card" @click="goTravel(store.currentTravel!.id)">
          <view class="travel-card-bar"></view>
          <view class="travel-card-body">
            <view class="travel-card-top">
              <text class="travel-title">{{ store.currentTravel.title }}</text>
              <view class="travel-status-pill">
                <text class="travel-status-txt">进行中</text>
              </view>
            </view>
            <text class="travel-dest">{{ store.currentTravel.destination }}</text>
            <text class="travel-count">{{ postcardCountForTravel(store.currentTravel.id) }} 张明信片</text>
          </view>
          <text class="travel-arr">›</text>
        </view>
      </view>

      <!-- Board feed -->
      <view class="section">
        <view class="section-hd">
          <text class="section-kicker">BULLETIN BOARD · 旅行公告栏</text>
          <view class="section-rule"></view>
          <view class="board-refresh" :class="{ 'board-refresh-spin': boardLoading }" @click="refreshBoard">
            <IconReset :size="18" color="#2E7D58" />
          </view>
        </view>

        <!-- Loading skeleton -->
        <view class="board-grid" v-if="boardLoading && boardCards.length === 0">
          <view v-for="i in 4" :key="i" class="board-skeleton shimmer"></view>
        </view>

        <!-- Empty -->
        <view class="board-empty" v-else-if="!boardLoading && boardCards.length === 0">
          <text class="board-empty-txt">公告栏还没有内容</text>
        </view>

        <!-- Card grid -->
        <view class="board-grid" v-else>
          <view
            v-for="card in boardCards"
            :key="card.id"
            class="board-card"
            @click="openBoardCard(card)"
          >
            <view class="board-card-photo">
              <image
                v-if="card.photoUrl"
                :src="card.photoUrl"
                class="board-card-img"
                mode="aspectFill"
                lazy-load
              />
              <view v-else class="board-card-grad"></view>
              <view class="board-card-pm">
                <text class="board-card-pm-city">{{ card.city.slice(0, 4).toUpperCase() }}</text>
              </view>
            </view>
            <view class="board-card-body">
              <view class="board-card-top">
                <view class="board-card-avatar">
                  <text class="board-card-initial">{{ card.author.nickname.slice(0, 1) }}</text>
                </view>
                <view class="board-card-stamp" :style="{ borderColor: getStampColor(card.stampDesign) }">
                  <image
                    v-if="getStampImageUrl(card.stampDesign)"
                    :src="getStampImageUrl(card.stampDesign)"
                    class="board-card-stamp-img"
                    mode="aspectFill"
                  />
                  <view v-else class="board-card-stamp-dot" :style="{ background: getStampColor(card.stampDesign) }"></view>
                </view>
              </view>
              <text class="board-card-loc">{{ card.locationName }}</text>
              <text class="board-card-city">{{ card.city }}</text>
              <view class="board-card-footer">
                <view
                  class="board-card-stamp-btn"
                  :class="{ 'board-card-stamp-active': stampedIds.has(card.id) }"
                  @click.stop="doStamp(card.id)"
                >
                  <text class="board-card-stamp-icon">✦</text>
                  <text class="board-card-stamp-count">{{ card.stampCount }}</text>
                </view>
                <text class="board-card-mailbox">{{ card.author.mailboxNo }}</text>
              </view>
            </view>
          </view>
        </view>

        <!-- Load more -->
        <view class="board-load-more" v-if="loadingMore">
          <text class="board-load-more-txt">加载中…</text>
        </view>
        <view class="board-load-more" v-else-if="!hasMore && boardCards.length > 0">
          <text class="board-load-more-txt">— 到底了 —</text>
        </view>
      </view>

      <!-- Empty state -->
      <view class="empty-state" v-if="store.travels.length === 0 && store.postcards.length === 0">
        <text class="empty-glyph">✦</text>
        <text class="empty-title">开始你的第一段旅程</text>
        <text class="empty-sub">记录每一张明信片，留住旅途中的美好时光</text>
        <view class="empty-btn" @click="goCreateTravel">
          <text class="empty-btn-txt">创建第一段旅程 →</text>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>

  <!-- ── 明信片预览弹窗（底部弹出）── -->
  <view class="modal-mask" v-if="activeCard" @click="closeFlipModal">
    <view class="modal-card" @click.stop>
      <!-- Photo area with flip -->
      <view class="modal-photo" @click="toggleFlip">
        <view class="modal-photo-inner" :class="{ flipped: isFlipped }">
          <!-- Front: photo -->
          <view class="modal-photo-face modal-photo-front">
            <image
              v-if="activeCard.photoUrl"
              :src="activeCard.photoUrl"
              class="modal-photo-img"
              mode="aspectFill"
            />
            <view v-else class="modal-photo-grad"></view>
            <view class="modal-photo-fade"></view>
            <view class="modal-postmark" style="transform: rotate(-8deg);">
              <text class="modal-pm-city">{{ activeCard.city.slice(0, 4).toUpperCase() }}</text>
              <text class="modal-pm-date">{{ formatModalDate(activeCard.recordedAt) }}</text>
            </view>
            <view class="modal-flip-hint">
              <text class="modal-flip-hint-txt">点击翻转背面</text>
            </view>
          </view>
          <!-- Back: postcard back -->
          <view class="modal-photo-face modal-photo-back">
            <view class="modal-back-inner">
              <view class="modal-back-header">
                <text class="modal-back-label">POSTCARD · 明信片</text>
                <view class="modal-back-stamp" :style="{ borderColor: getStampColor(activeCard.stampDesign) }">
                  <image
                    v-if="getStampImageUrl(activeCard.stampDesign)"
                    :src="getStampImageUrl(activeCard.stampDesign)"
                    class="modal-back-stamp-img"
                    mode="aspectFill"
                  />
                  <view v-else class="modal-back-stamp-dot" :style="{ background: getStampColor(activeCard.stampDesign) }"></view>
                </view>
              </view>
              <view class="modal-back-divider"></view>
              <view class="modal-back-body">
                <view class="modal-back-msg">
                  <text class="modal-back-note">{{ activeCard.note || '此刻，无言。' }}</text>
                </view>
                <view class="modal-back-addr">
                  <text class="modal-back-to">致 {{ activeCard.toName || '旅途中的自己' }}</text>
                  <text class="modal-back-loc">{{ activeCard.locationName }}</text>
                  <text class="modal-back-city">{{ activeCard.city }}{{ activeCard.country ? ', ' + activeCard.country : '' }}</text>
                  <view class="modal-back-pm">
                    <text class="modal-back-pm-city">{{ activeCard.city.toUpperCase().slice(0, 6) }}</text>
                    <view class="modal-back-pm-rule"></view>
                    <text class="modal-back-pm-date">{{ formatModalDate(activeCard.recordedAt) }}</text>
                  </view>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- Info body -->
      <view class="modal-body">
        <view class="modal-sender">
          <view class="modal-avatar">
            <text class="modal-initial">{{ activeCard.author.nickname.slice(0, 1) }}</text>
          </view>
          <view class="modal-sender-info">
            <text class="modal-nickname">{{ activeCard.author.nickname }}</text>
            <text class="modal-mailbox">{{ activeCard.author.mailboxNo }}</text>
          </view>
        </view>

        <view class="modal-rule"></view>

        <text class="modal-loc">{{ activeCard.locationName }}</text>
        <text class="modal-city">{{ activeCard.city }} · {{ activeCard.country }}</text>
        <text class="modal-note" v-if="activeCard.note">"{{ activeCard.note }}"</text>

        <view class="modal-rule" style="margin-top: 24rpx;"></view>

        <view class="modal-actions">
          <view
            class="modal-stamp-btn"
            :class="{ 'modal-stamp-active': stampedIds.has(activeCard.id) }"
            @click="doStamp(activeCard.id)"
          >
            <text class="modal-stamp-icon">✦</text>
            <text class="modal-stamp-txt">{{ stampedIds.has(activeCard.id) ? '已盖章' : '盖章' }} · {{ activeCard.stampCount }}</text>
          </view>

          <view
            v-if="!activeCard.author.isContact && activeCard.author.id !== authStore.user?.id"
            class="modal-add-btn"
            @click="addContact(activeCard.author.id)"
          >
            <text class="modal-add-txt">+ 加为联系人</text>
          </view>
          <view v-else-if="activeCard.author.isContact" class="modal-added-tag">
            <text class="modal-added-txt">✓ 已是联系人</text>
          </view>
        </view>
      </view>

      <text class="modal-close" @click="closeFlipModal">关闭</text>
    </view>
  </view>

  <!-- ── 新用户引导 ── -->
  <view v-if="showOnboarding" class="ob-mask">
    <view class="ob-card">
      <!-- 顶部邮票装饰 -->
      <view class="ob-stamp">
        <text class="ob-stamp-char">{{ onboardingSteps[obStep].icon }}</text>
      </view>

      <!-- 内容 -->
      <text class="ob-kicker">STEP {{ obStep + 1 }} / {{ onboardingSteps.length }}</text>
      <text class="ob-title">{{ onboardingSteps[obStep].title }}</text>
      <text class="ob-desc">{{ onboardingSteps[obStep].desc }}</text>

      <!-- 点指示器 -->
      <view class="ob-dots">
        <view
          v-for="(_, i) in onboardingSteps"
          :key="i"
          class="ob-dot"
          :class="{ 'ob-dot-active': i === obStep }"
        ></view>
      </view>

      <!-- 操作按钮 -->
      <view class="ob-actions">
        <view class="ob-btn-primary" @click="obNext">
          <text class="ob-btn-txt">{{ obStep < onboardingSteps.length - 1 ? '下一步 ›' : '开始使用 →' }}</text>
        </view>
        <text v-if="obStep < onboardingSteps.length - 1" class="ob-skip" @click="obFinish">跳过引导</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { usePostcardStore } from '@/stores/postcard'
import { useAuthStore } from '@/stores/auth'
import { MailApi, PostcardApi, ContactsApi, type BoardPostcard } from '@/services/api'
import { StorageUtil } from '@/utils/storage'
import { getStampColor, getStampImageUrl } from '@/utils/stamp'

import { IconCamera, IconInbox, IconSend, IconContacts, IconReset } from '@/components/icons'


const store     = usePostcardStore()
const authStore = useAuthStore()
const user      = computed(() => authStore.user)

const unreadCount = ref(0)

// ── 新用户引导 ────────────────────────────────────────────────────
const showOnboarding = ref(false)
const obStep = ref(0)

const onboardingSteps = [
  {
    icon: '旅',
    title: '先创建一段旅程',
    desc: '每张明信片都会归属到旅程里。先定下目的地，后面记录地点、照片和心情会更自然。',
  },
  {
    icon: '片',
    title: '记录第一张明信片',
    desc: '旅途中到达一个地点时，拍照或手动填写位置，就能把这一刻保存成明信片。',
  },
  {
    icon: '寄',
    title: '寄给好友',
    desc: '保存明信片后，可以寄给好友。输入对方的邮箱号（如 CN-123456）即可找到 TA。',
  },
  {
    icon: '票',
    title: '收集邮票',
    desc: '每次签到、记录和寄信都能获得积分，用积分在邮票商店解锁更多精美邮票样式。',
  },
]

function obNext() {
  if (obStep.value < onboardingSteps.length - 1) {
    obStep.value++
  } else {
    obFinish()
  }
}

function obFinish() {
  StorageUtil.remove('is_new_user')
  showOnboarding.value = false
}

// ── Greeting ──────────────────────────────────────────────────────
const greeting = computed(() => {
  const h = new Date().getHours()
  if (h >= 5 && h < 12)  return '早上好，'
  if (h >= 12 && h < 14) return '中午好，'
  if (h >= 14 && h < 19) return '下午好，'
  if (h >= 19)            return '晚上好，'
  return '深夜了，'
})

// ── Date display ─────────────────────────────────────────────────
const now        = new Date()
const dateMonth  = String(now.getMonth() + 1).padStart(2, '0') + ' 月'
const dateDay    = String(now.getDate()).padStart(2, '0')

// ── Computed data ─────────────────────────────────────────────────
const boardCards    = ref<BoardPostcard[]>([])
const boardLoading  = ref(true)
const loadingMore   = ref(false)
const boardPage     = ref(1)
const hasMore       = ref(true)
const activeCard    = ref<BoardPostcard | null>(null)
const isFlipped     = ref(false)
const stampedIds    = ref<Set<string>>(new Set())

function toggleFlip() {
  isFlipped.value = !isFlipped.value
}

function openBoardCard(card: BoardPostcard) {
  activeCard.value = card
  isFlipped.value = false
}

function closeFlipModal() {
  activeCard.value = null
  isFlipped.value = false
}

const MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
function formatModalDate(ts: number): string {
  const d = new Date(ts)
  return `${String(d.getDate()).padStart(2,'0')} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`
}

async function doStamp(id: string) {
  if (stampedIds.value.has(id)) return
  try {
    const res = await PostcardApi.stamp(id)
    const card = boardCards.value.find(c => c.id === id)
    if (card) card.stampCount = res.stampCount
    stampedIds.value = new Set([...stampedIds.value, id])
  } catch {
    uni.showToast({ title: '盖章失败', icon: 'none' })
  }
}

async function addContact(authorId: string) {
  try {
    await ContactsApi.add(authorId)
    const card = boardCards.value.find(c => c.author.id === authorId)
    if (card) card.author.isContact = true
    if (activeCard.value && activeCard.value.author.id === authorId) {
      activeCard.value = { ...activeCard.value, author: { ...activeCard.value.author, isContact: true } }
    }
    uni.showToast({ title: '已添加为联系人', icon: 'success' })
  } catch (e: any) {
    uni.showToast({ title: e.message || '添加失败', icon: 'none' })
  }
}

async function loadBoard(reset = false) {
  if (reset) {
    boardPage.value = 1
    hasMore.value   = true
    boardCards.value = []
    boardLoading.value = true
  }
  try {
    const data = await PostcardApi.board(boardPage.value)
    if (data.length < 20) hasMore.value = false
    boardCards.value = reset ? data : [...boardCards.value, ...data]
  } catch {
    // non-critical
  } finally {
    boardLoading.value = false
    loadingMore.value  = false
  }
}

async function refreshBoard() {
  if (boardLoading.value) return
  await loadBoard(true)
  uni.showToast({ title: '已刷新', icon: 'none' })
}

async function loadMore() {
  if (!hasMore.value || loadingMore.value || boardLoading.value) return
  loadingMore.value = true
  boardPage.value++
  await loadBoard()
}



const focusTitle = computed(() =>
  store.currentTravel ? `记录「${store.currentTravel.title}」` : '先创建你的第一段旅程'
)

const focusSubtitle = computed(() =>
  store.currentTravel
    ? `${store.currentTravel.destination} · ${postcardCountForTravel(store.currentTravel.id)} 张明信片`
    : '有了旅程后，每张明信片都会自动归档到路线上'
)

const primaryActionText = computed(() =>
  store.currentTravel || store.travels.length > 0 ? '记录此刻' : '创建旅程'
)

function postcardCountForTravel(travelId: string): number {
  return store.postcards.filter(p => p.travelId === travelId).length
}

// ── Navigation ────────────────────────────────────────────────────
function goPrimaryAction() {
  if (store.currentTravel || store.travels.length > 0) {
    goRecord()
  } else {
    goCreateTravel()
  }
}

function goRecord()     { uni.switchTab({ url: '/pages/record/record' }) }
function goCreateTravel() { uni.navigateTo({ url: '/pages/travel/travel' }) }
function goInbox()      { uni.navigateTo({ url: '/pages/inbox/inbox' }) }
function goContacts()   { uni.navigateTo({ url: '/pages/contacts/contacts' }) }
function goTravel(id: string) { uni.navigateTo({ url: `/pages/travel/travel?id=${id}` }) }

function goBoard()      { uni.navigateTo({ url: '/pages/board/board' }) }

function goSend() {
  // 进入寄出页面，先选择明信片（排除保存的来信）
  const ownPostcards = store.sortedPostcards.filter(pc => !pc.isSavedMailing)
  if (ownPostcards.length > 0) {
    uni.navigateTo({ url: '/pages/send/send' })
  } else {
    uni.showToast({ title: '先记录一张明信片吧', icon: 'none' })
    setTimeout(goRecord, 650)
  }
}

// ── Load data ─────────────────────────────────────────────────────
function syncTabBadge(count: number) {
  if (count > 0) {
    uni.setTabBarBadge({ index: 4, text: count > 99 ? '99+' : String(count), fail: () => {} })
  } else {
    uni.removeTabBarBadge({ index: 4, fail: () => {} } as any)
  }
}

async function loadUnread() {
  try {
    const res = await MailApi.inbox()
    unreadCount.value = res.unreadCount
    syncTabBadge(res.unreadCount)
  } catch {
    // non-critical
  }
}

onMounted(() => {
  store.initData()
  loadBoard(true)
  if (StorageUtil.get<boolean>('is_new_user', false)) {
    showOnboarding.value = true
    obStep.value = 0
  }
})

onShow(() => {
  loadUnread()
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
}

// ── Hero ──────────────────────────────────────────────────────────
.hero {
  background: linear-gradient(165deg, $travel-blue 0%, $forest-green 100%);
  padding: 72rpx 40rpx 38rpx;
  border-radius: 0 0 36rpx 36rpx;
}

.hero-inner {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 0;
}

.hero-left {}

.hero-greeting {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: rgba(244,239,229,0.65);
  margin-bottom: 8rpx;
}

.hero-name {
  display: block;
  font-family: $font-family-body;
  font-size: 40rpx;
  font-weight: 500;
  color: #F4EFE5;
}

.hero-date {
  text-align: right;
  margin-top: 4rpx;
}

.date-month {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(244,239,229,0.55);
}

.date-day {
  display: block;
  font-family: $font-family-mono;
  font-size: 64rpx;
  color: rgba(244,239,229,0.9);
  line-height: 1;
}

// ── Primary focus ─────────────────────────────────────────────────
.focus-card {
  margin: 30rpx 32rpx 0;
  background: $card-bg;
  border: 2rpx solid rgba($travel-blue, 0.34);
  border-radius: 12rpx;
  padding: 30rpx;
  display: flex;
  align-items: center;
  gap: 24rpx;
  box-shadow: $shadow-md;
}

.focus-copy {
  flex: 1;
  min-width: 0;
}

.focus-kicker {
  display: block;
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $travel-blue;
  margin-bottom: 8rpx;
}

.focus-title {
  display: block;
  font-family: $font-family-body;
  font-size: 34rpx;
  font-weight: 500;
  color: $ink-black;
  line-height: 1.25;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.focus-sub {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  line-height: 1.45;
  margin-top: 8rpx;
}

.focus-action {
  height: 92rpx;
  padding: 0 30rpx;
  border-radius: 8rpx;
  background: $travel-blue;
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
  &:active { background: $forest-green; }
}

.focus-action-txt {
  font-family: $font-family-action;
  font-size: 28rpx;
  color: #F4EFE5;
  white-space: nowrap;
}

// ── Content ───────────────────────────────────────────────────────
.content { height: calc(100vh - 226rpx); }

// ── Quick actions ─────────────────────────────────────────────────
.actions-row {
  display: flex;
  gap: 0;
  margin: 22rpx 32rpx 0;
  background: $card-bg;
  border: 2rpx solid $line-sepia;
  border-radius: 12rpx;
  overflow: hidden;
  box-shadow: $shadow-sm;
}

.action-btn {
  flex: 1;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  padding: 24rpx 0;
  position: relative;
  border-right: 1rpx solid $line-sepia;

  &:last-child { border-right: none; }
  &:active { background: rgba($travel-blue, 0.05); }
}

.action-icon {
  line-height: 1;
}

.action-lbl {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $mute-text;
}

.action-badge {
  position: absolute;
  top: 16rpx;
  right: 16rpx;
  min-width: 32rpx;
  height: 32rpx;
  background: #A43B2D;
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 6rpx;
}

.action-badge-txt {
  font-family: $font-family-code;
  font-size: 22rpx;
  color: #F4EFE5;
}

// ── Board feed grid ───────────────────────────────────────────────
.board-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16rpx;
}

.board-skeleton {
  height: 280rpx;
  border-radius: 8rpx;
  background: $line-sepia;
  opacity: 0.35;
}

.shimmer {
  background: linear-gradient(90deg, $line-sepia 25%, #E8E0D0 50%, $line-sepia 75%);
  background-size: 200% 100%;
  animation: shimmer 1.4s infinite;
}

@keyframes shimmer {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

.board-empty {
  padding: 48rpx 0;
  text-align: center;
}

.board-empty-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
}

.board-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
  box-shadow: 0 4rpx 16rpx rgba(40,30,15,0.08);
  &:active { opacity: 0.92; }
}

.board-card-photo {
  width: 100%;
  height: 200rpx;
  position: relative;
  overflow: hidden;
}

.board-card-img {
  width: 100%;
  height: 100%;
}

.board-card-grad {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #C9D2B6 0%, #3C604D 100%);
}

.board-card-pm {
  position: absolute;
  top: 10rpx;
  right: 10rpx;
  background: rgba(20,15,10,0.5);
  border: 1rpx solid rgba(244,239,229,0.4);
  border-radius: 4rpx;
  padding: 4rpx 10rpx;
}

.board-card-pm-city {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(244,239,229,0.9);
}

.board-card-body {
  padding: 14rpx 16rpx 14rpx;
}

.board-card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10rpx;
}

.board-card-avatar {
  width: 40rpx;
  height: 40rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.board-card-initial {
  font-family: $font-family-body;
  font-size: 22rpx;
  color: #F4EFE5;
}

.board-card-stamp {
  width: 36rpx;
  height: 36rpx;
  border: 1rpx solid currentColor;
  border-radius: 2rpx;
  overflow: hidden;
  background: $paper-beige;
}

.board-card-stamp-img { width: 100%; height: 100%; }
.board-card-stamp-dot { width: 100%; height: 100%; opacity: 0.8; }

.board-card-loc {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 2rpx;
}

.board-card-city {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 12rpx;
}

.board-card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.board-card-stamp-btn {
  display: flex;
  align-items: center;
  gap: 6rpx;
  padding: 4rpx 10rpx;
  border-radius: 4rpx;
  border: 1rpx solid $line-sepia;
  background: transparent;
  &:active { opacity: 0.7; }
}

.board-card-stamp-active {
  background: rgba($travel-blue, 0.1);
  border-color: $travel-blue;
  .board-card-stamp-icon, .board-card-stamp-count { color: $travel-blue; }
}

.board-card-stamp-icon {
  font-size: 22rpx;
  color: $mute-text;
}

.board-card-stamp-count {
  font-family: $font-family-code;
  font-size: 22rpx;
  color: $mute-text;
}

.board-card-mailbox {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  opacity: 0.6;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.board-load-more {
  padding: 32rpx 0;
  text-align: center;
}

.board-load-more-txt {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
}

// ── Section ───────────────────────────────────────────────────────
.section { margin: 38rpx 32rpx 0; }

.section-hd {
  display: flex;
  align-items: center;
  gap: 14rpx;
  margin-bottom: 20rpx;
  padding: 16rpx 18rpx;
  border-left: 8rpx solid $travel-blue;
  background: rgba($travel-blue, 0.08);
  border-radius: 8rpx;
}

.section-kicker {
  font-family: $font-family-action;
  font-size: 24rpx;
  font-weight: 500;
  letter-spacing: 0;
  color: $travel-blue;
  white-space: nowrap;
  flex-shrink: 0;
}

.section-rule {
  flex: 1;
  height: 0;
}

.section-more {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $mute-text;
  flex-shrink: 0;
}

.board-refresh {
  width: 48rpx;
  height: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  margin-left: 12rpx;
  border-radius: 50%;
  &:active { background: rgba(46, 125, 88, 0.08); }
}

.board-refresh-spin {
  animation: board-spin 0.8s linear infinite;
}

@keyframes board-spin {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}

// ── Current travel card ───────────────────────────────────────────
.travel-card {
  background: $card-bg;
  border: 2rpx solid $line-sepia;
  border-radius: 12rpx;
  display: flex;
  align-items: stretch;
  overflow: hidden;

  &:active { opacity: 0.88; }
}

.travel-card-bar {
  width: 6rpx;
  background: $travel-blue;
  flex-shrink: 0;
}

.travel-card-body {
  flex: 1;
  padding: 24rpx 20rpx;
}

.travel-card-top {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 8rpx;
}

.travel-title {
  font-family: $font-family-body;
  font-size: 32rpx;
  color: $ink-black;
  flex: 1;
}

.travel-status-pill {
  background: rgba($travel-blue, 0.1);
  border-radius: 20rpx;
  padding: 4rpx 16rpx;
}

.travel-status-txt {
  font-family: $font-family-action;
  font-size: 22rpx;
  letter-spacing: 0;
  color: $travel-blue;
}

.travel-dest {
  display: block;
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  margin-bottom: 4rpx;
}

.travel-count {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.travel-arr {
  font-family: $font-family-body;
  font-size: 48rpx;
  color: $mute-text;
  padding: 0 20rpx;
  align-self: center;
}

// ── Empty state ───────────────────────────────────────────────────
.empty-state {
  margin: 80rpx 40rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.empty-glyph {
  font-size: 80rpx;
  color: rgba($travel-blue, 0.25);
  margin-bottom: 8rpx;
}

.empty-title {
  font-family: $font-family-body;
  font-size: 36rpx;
  color: $ink-black;
}

.empty-sub {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
  text-align: center;
  line-height: 1.6;
  max-width: 500rpx;
}

.empty-btn {
  margin-top: 16rpx;
  padding: 20rpx 48rpx;
  background: $travel-blue;
  border-radius: 8rpx;

  &:active { background: $forest-green; }
}

.empty-btn-txt {
  font-family: $font-family-action;
  font-size: 28rpx;
  color: #F4EFE5;
}

.btm-gap { height: 120rpx; }

// ── 新用户引导 ─────────────────────────────────────────────────────
.ob-mask {
  position: fixed;
  inset: 0;
  background: rgba(16, 12, 8, 0.82);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

.ob-card {
  width: 620rpx;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 16rpx;
  padding: 48rpx 48rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
  box-shadow: 0 32rpx 80rpx rgba(0, 0, 0, 0.45);
}

.ob-stamp {
  width: 120rpx;
  height: 120rpx;
  border: 2rpx dashed rgba($travel-blue, 0.5);
  border-radius: 8rpx;
  background: rgba($travel-blue, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8rpx;
}

.ob-stamp-char {
  font-family: $font-family-body;
  font-size: 56rpx;
  color: $travel-blue;
}

.ob-kicker {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.ob-title {
  font-family: $font-family-body;
  font-size: 40rpx;
  color: $ink-black;
  text-align: center;
  line-height: 1.3;
}

.ob-desc {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $body-text;
  text-align: center;
  line-height: 1.75;
  max-width: 520rpx;
}

.ob-dots {
  display: flex;
  gap: 12rpx;
  margin: 8rpx 0;
}

.ob-dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  background: $line-sepia;
  transition: background 0.25s;

  &.ob-dot-active {
    background: $travel-blue;
    width: 32rpx;
    border-radius: 6rpx;
  }
}

.ob-actions {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
  margin-top: 8rpx;
}

.ob-btn-primary {
  width: 100%;
  background: $travel-blue;
  border-radius: 8rpx;
  padding: 26rpx 0;
  text-align: center;

  &:active { background: $forest-green; }
}

.ob-btn-txt {
  font-family: $font-family-action;
  font-size: 30rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

.ob-skip {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $mute-text;
}

// ── Modal (bottom sheet) ──────────────────────────────────────────
.modal-mask {
  position: fixed;
  inset: 0;
  background: rgba(12,9,5,0.85);
  z-index: 999;
  display: flex;
  align-items: flex-end;
  justify-content: center;
  animation: fade-in 0.2s ease;
}

@keyframes fade-in { from { opacity: 0; } to { opacity: 1; } }

.modal-card {
  width: 100%;
  max-height: 90vh;
  background: $page-background;
  border-radius: 32rpx 32rpx 0 0;
  overflow: hidden;
  animation: slide-up 0.28s cubic-bezier(0.34,1.56,0.64,1);
  display: flex;
  flex-direction: column;
}

@keyframes slide-up {
  from { transform: translateY(100%); }
  to   { transform: translateY(0); }
}

// Photo with 3D flip
.modal-photo {
  width: 100%;
  height: 460rpx;
  position: relative;
  flex-shrink: 0;
  perspective: 900px;
  cursor: pointer;
}

.modal-photo-inner {
  width: 100%;
  height: 100%;
  position: relative;
  transform-style: preserve-3d;
  transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-photo-inner.flipped {
  transform: rotateY(180deg);
}

.modal-photo-face {
  position: absolute;
  inset: 0;
  backface-visibility: hidden;
  -webkit-backface-visibility: hidden;
}

.modal-photo-back {
  transform: rotateY(180deg);
  background: $card-bg;
}

.modal-photo-img { width: 100%; height: 100%; }

.modal-photo-grad {
  width: 100%; height: 100%;
  background: linear-gradient(165deg, $travel-blue, $forest-green);
}

.modal-photo-fade {
  position: absolute;
  bottom: 0; left: 0; right: 0;
  height: 200rpx;
  background: linear-gradient(transparent, $page-background);
}

.modal-postmark {
  position: absolute;
  top: 24rpx; right: 32rpx;
  background: rgba(20,15,10,0.45);
  border: 1rpx solid rgba(244,239,229,0.5);
  border-radius: 6rpx;
  padding: 8rpx 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.modal-pm-city {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: rgba(244,239,229,0.9);
}

.modal-pm-date {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: rgba(244,239,229,0.95);
}

.modal-flip-hint {
  position: absolute;
  bottom: 20rpx;
  left: 0; right: 0;
  text-align: center;
}

.modal-flip-hint-txt {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: rgba(244,239,229,0.7);
}

// Back face design
.modal-back-inner {
  width: 100%;
  height: 100%;
  padding: 24rpx 32rpx;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}

.modal-back-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}

.modal-back-label {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.modal-back-stamp {
  width: 56rpx; height: 72rpx;
  border: 1rpx dashed currentColor;
  border-radius: 3rpx;
  background: $paper-beige;
  display: flex; align-items: center; justify-content: center;
  overflow: hidden;
  transform: rotate(-3deg);
}

.modal-back-stamp-img { width: 100%; height: 100%; }
.modal-back-stamp-dot { width: 100%; height: 100%; opacity: 0.7; }

.modal-back-divider {
  height: 1rpx;
  background: $line-sepia;
  margin-bottom: 16rpx;
}

.modal-back-body {
  flex: 1;
  display: flex;
  gap: 24rpx;
}

.modal-back-msg {
  flex: 1;
  display: flex;
  align-items: center;
}

.modal-back-note {
  font-family: $font-family-display;
  font-style: italic;
  font-size: 26rpx;
  color: $body-text;
  line-height: 1.7;
}

.modal-back-addr {
  width: 200rpx;
  display: flex;
  flex-direction: column;
  gap: 6rpx;
  border-left: 1rpx dashed $line-sepia;
  padding-left: 20rpx;
}

.modal-back-to {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $ink-black;
}

.modal-back-loc {
  font-family: $font-family-body;
  font-size: 22rpx;
  color: $mute-text;
}

.modal-back-city {
  font-family: $font-family-code;
  font-size: 20rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}

.modal-back-pm {
  margin-top: auto;
  border: 2rpx solid rgba(164, 59, 45, 0.35);
  border-radius: 50%;
  width: 120rpx;
  height: 120rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  align-self: flex-end;
  transform: rotate(-12deg);
}

.modal-back-pm-city {
  font-family: $font-family-code;
  font-size: 20rpx;
  letter-spacing: 1rpx;
  color: rgba(164, 59, 45, 0.8);
}

.modal-back-pm-rule {
  width: 60rpx;
  height: 1rpx;
  background: rgba(164, 59, 45, 0.35);
  margin: 4rpx 0;
}

.modal-back-pm-date {
  font-family: $font-family-body;
  font-size: 18rpx;
  color: rgba(164, 59, 45, 0.7);
}

// Modal body (info section)
.modal-body {
  padding: 0 40rpx 24rpx;
  margin-top: -40rpx;
  position: relative;
  z-index: 2;
  overflow-y: auto;
}

.modal-sender {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.modal-avatar {
  width: 64rpx; height: 64rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
  border: 3rpx solid $page-background;
}

.modal-initial {
  font-family: $font-family-body;
  font-size: 28rpx;
  color: #F4EFE5;
}

.modal-sender-info { flex: 1; }

.modal-nickname {
  display: block;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
}

.modal-mailbox {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.modal-rule {
  height: 1rpx;
  background: $line-sepia;
  margin-bottom: 20rpx;
}

.modal-loc {
  display: block;
  font-family: $font-family-body;
  font-size: 36rpx;
  color: $ink-black;
  margin-bottom: 6rpx;
}

.modal-city {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  margin-bottom: 16rpx;
}

.modal-note {
  display: block;
  font-family: $font-family-body;
  font-style: italic;
  font-size: 26rpx;
  color: $body-text;
  line-height: 1.7;
}

.modal-actions {
  display: flex;
  gap: 16rpx;
  align-items: center;
  margin-top: 8rpx;
}

.modal-stamp-btn {
  display: flex;
  align-items: center;
  gap: 10rpx;
  height: 72rpx;
  padding: 0 28rpx;
  border-radius: 8rpx;
  border: 1rpx solid $line-sepia;
  background: $card-bg;
  flex-shrink: 0;
  &:active { opacity: 0.8; }
}

.modal-stamp-active {
  background: rgba($travel-blue, 0.08);
  border-color: $travel-blue;
  .modal-stamp-icon, .modal-stamp-txt { color: $travel-blue; }
}

.modal-stamp-icon { font-size: 24rpx; color: $mute-text; }

.modal-stamp-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
}

.modal-add-btn {
  flex: 1;
  height: 72rpx;
  background: $travel-blue;
  border-radius: 8rpx;
  display: flex; align-items: center; justify-content: center;
  &:active { opacity: 0.85; }
}

.modal-add-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

.modal-added-tag {
  flex: 1;
  height: 72rpx;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  display: flex; align-items: center; justify-content: center;
}

.modal-added-txt {
  font-family: $font-family-code;
  font-size: 24rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.modal-close {
  display: block;
  text-align: center;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  padding: 16rpx 0 32rpx;
  flex-shrink: 0;
}
</style>

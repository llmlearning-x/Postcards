<template>
  <view class="page-container">
    <PostalHeader
      kicker="MAILBOX · 邮箱"
      :title="filterNickname ? filterNickname + ' 的往来' : (tab === 'inbox' ? '我的来信' : '已寄出')"
      fallback-url="/pages/profile/profile"
    >
      <template #title-extra>
        <view class="unread-badge" v-if="tab === 'inbox' && unreadCount > 0 && !filterContactId">
          <text class="unread-num">{{ unreadCount }}</text>
        </view>
      </template>
    </PostalHeader>

    <!-- Tabs (hidden when filtering by contact, which shows both) -->
    <view class="tab-bar" v-if="!filterContactId">
      <view class="tab-item" :class="{ 'tab-active': tab === 'inbox' }" @click="switchTab('inbox')">
        <text class="tab-txt">来信</text>
        <view class="tab-dot" v-if="unreadCount > 0 && tab !== 'inbox'"></view>
      </view>
      <view class="tab-item" :class="{ 'tab-active': tab === 'sent' }" @click="switchTab('sent')">
        <text class="tab-txt">已寄出</text>
      </view>
    </view>

    <scroll-view class="content" scroll-y @scrolltolower="loadMore">

      <!-- Loading -->
      <view class="loading-wrap" v-if="loading">
        <text class="loading-txt">{{ tab === 'inbox' ? '正在取信…' : '加载中…' }}</text>
      </view>

      <!-- ══ INBOX ══ -->
      <template v-if="!loading && (tab === 'inbox' || filterContactId)">
        <view class="section-label" v-if="filterContactId">
          <text class="section-label-txt">来信</text>
        </view>

        <view class="empty-state" v-if="filteredInbox.length === 0">
          <IconEnvelope :size="64" color="#B5AE9B" />
          <text class="empty-title">{{ filterContactId ? '还没有收到 TA 的来信' : '信箱空空如也' }}</text>
          <text class="empty-sub" v-if="!filterContactId">好友给你寄来的明信片会出现在这里</text>
        </view>

        <view class="mail-list" v-else>
          <view
            v-for="item in filteredInbox"
            :key="item.id"
            class="mail-row"
            :class="{ 'mail-unread': !item.openedAt }"
            @click="viewMail(item)"
          >
            <view class="unread-dot" v-if="!item.openedAt"></view>
            <view class="unread-dot-ph" v-else></view>

            <!-- Photo thumb -->
            <view class="mail-thumb">
              <image v-if="item.snapshot?.photoUrl" :src="item.snapshot.photoUrl" class="mail-thumb-img" mode="aspectFill" lazy-load />
              <view v-else class="mail-thumb-grad">
                <view class="mail-stamp-badge" :style="{ borderColor: getStampColor(item.snapshot?.stampDesign || '') }">
                  <image v-if="getStampImageUrl(item.snapshot?.stampDesign || '')" :src="getStampImageUrl(item.snapshot?.stampDesign || '')" class="badge-img" mode="aspectFill" lazy-load />
                  <view v-else class="badge-color" :style="{ background: getStampColor(item.snapshot?.stampDesign || '') }"></view>
                </view>
              </view>
              <!-- Stamp overlay on photo -->
              <view v-if="item.snapshot?.photoUrl" class="mail-stamp-badge" :style="{ borderColor: getStampColor(item.snapshot?.stampDesign || '') }">
                <image v-if="getStampImageUrl(item.snapshot?.stampDesign || '')" :src="getStampImageUrl(item.snapshot?.stampDesign || '')" class="badge-img" mode="aspectFill" lazy-load />
                <view v-else class="badge-color" :style="{ background: getStampColor(item.snapshot?.stampDesign || '') }"></view>
              </view>
            </view>

            <!-- Content -->
            <view class="mail-content">
              <view class="mail-top-row">
                <view class="sender-avatar-sm">
                  <text class="sender-initial-sm">{{ item.sender.nickname.slice(0, 1) }}</text>
                </view>
                <text class="sender-name">{{ item.sender.nickname }}</text>
                <text class="mail-date">{{ formatDate(item.sentAt) }}</text>
              </view>
              <text class="mail-loc">{{ item.snapshot?.locationName }} · {{ item.snapshot?.city }}</text>
              <text class="mail-note" v-if="item.personalNote">{{ item.personalNote }}</text>
            </view>
          </view>
        </view>
      </template>

      <!-- ══ SENT ══ -->
      <template v-if="!loading && (tab === 'sent' || filterContactId)">
        <view class="section-label" v-if="filterContactId" style="margin-top: 40rpx;">
          <text class="section-label-txt">已寄出</text>
        </view>

        <view class="empty-state" v-if="filteredSent.length === 0">
          <IconSend :size="64" color="#B5AE9B" />
          <text class="empty-title">{{ filterContactId ? '还没有寄出过明信片给 TA' : '还没有寄出过明信片' }}</text>
          <text class="empty-sub" v-if="!filterContactId">在明信片详情页点击「寄出」开始寄信</text>
        </view>

        <view class="mail-list" v-else>
          <view
            v-for="item in filteredSent"
            :key="item.id"
            class="mail-row"
            @click="viewSent(item)"
          >
            <view class="unread-dot-ph"></view>

            <!-- Photo thumb -->
            <view class="mail-thumb">
              <image v-if="item.snapshot?.photoUrl" :src="item.snapshot.photoUrl" class="mail-thumb-img" mode="aspectFill" lazy-load />
              <view v-else class="mail-thumb-grad">
                <view class="mail-stamp-badge" :style="{ borderColor: getStampColor(item.snapshot?.stampDesign || '') }">
                  <image v-if="getStampImageUrl(item.snapshot?.stampDesign || '')" :src="getStampImageUrl(item.snapshot?.stampDesign || '')" class="badge-img" mode="aspectFill" lazy-load />
                  <view v-else class="badge-color" :style="{ background: getStampColor(item.snapshot?.stampDesign || '') }"></view>
                </view>
              </view>
              <view v-if="item.snapshot?.photoUrl" class="mail-stamp-badge" :style="{ borderColor: getStampColor(item.snapshot?.stampDesign || '') }">
                <image v-if="getStampImageUrl(item.snapshot?.stampDesign || '')" :src="getStampImageUrl(item.snapshot?.stampDesign || '')" class="badge-img" mode="aspectFill" lazy-load />
                <view v-else class="badge-color" :style="{ background: getStampColor(item.snapshot?.stampDesign || '') }"></view>
              </view>
            </view>

            <!-- Content -->
            <view class="mail-content">
              <view class="mail-top-row">
                <view class="sender-avatar-sm sent-avatar">
                  <text class="sender-initial-sm">{{ item.recipient.nickname.slice(0, 1) }}</text>
                </view>
                <text class="sender-name">→ {{ item.recipient.nickname }}</text>
                <view class="status-tag" :class="'status-' + item.status">
                  <text class="status-txt">{{ statusLabel(item.status) }}</text>
                </view>
                <text class="mail-date">{{ formatDate(item.sentAt) }}</text>
              </view>
              <text class="mail-loc">{{ item.snapshot?.locationName }} · {{ item.snapshot?.city }}</text>
              <text class="mail-note" v-if="item.personalNote">{{ item.personalNote }}</text>
            </view>
          </view>
        </view>
      </template>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { MailApi, type MailingItem, type SentItem } from '@/services/api'
import PostalHeader from '@/components/PostalHeader.vue'
import { safeBack } from '@/utils/navigation'
import { IconEnvelope, IconSend } from '@/components/icons'
import { getStampColor, getStampImageUrl } from '@/utils/stamp'

const tab             = ref<'inbox' | 'sent'>('inbox')
const loading         = ref(true)
const inboxItems      = ref<MailingItem[]>([])
const sentItems       = ref<SentItem[]>([])
const unreadCount     = ref(0)
const filterContactId = ref('')
const filterNickname  = ref('')

const filteredInbox = computed(() =>
  filterContactId.value
    ? inboxItems.value.filter(m => m.sender.id === filterContactId.value)
    : inboxItems.value
)

const filteredSent = computed(() =>
  filterContactId.value
    ? sentItems.value.filter(m => m.recipient.id === filterContactId.value)
    : sentItems.value
)

const MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
function formatDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getDate()} ${MONTHS[d.getMonth()]}`
}

function statusLabel(status: string): string {
  if (status === 'opened') return '已读'
  if (status === 'delivered') return '已达'
  return '已寄'
}

async function loadAll() {
  loading.value = true
  try {
    const [inboxRes, sentRes] = await Promise.all([MailApi.inbox(), MailApi.sent()])
    inboxItems.value  = inboxRes.items
    unreadCount.value = inboxRes.unreadCount
    sentItems.value   = sentRes
  } catch {
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function switchTab(t: 'inbox' | 'sent') {
  tab.value = t
}

function viewMail(item: MailingItem) {
  const data = encodeURIComponent(JSON.stringify(item))
  uni.navigateTo({ url: `/pages/maildetail/maildetail?data=${data}` })
}

function viewSent(item: SentItem) {
  const data = encodeURIComponent(JSON.stringify({ ...item, isSent: true }))
  uni.navigateTo({ url: `/pages/maildetail/maildetail?data=${data}` })
}

function loadMore() {}

function goBack() {
  safeBack('/pages/profile/profile')
}

onLoad((opts) => {
  if (opts?.contactId) {
    filterContactId.value = opts.contactId
    filterNickname.value  = decodeURIComponent(opts.nickname || '')
  }
  if (opts?.tab === 'sent') {
    tab.value = 'sent'
  }
})

onShow(() => loadAll())
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
  display: flex;
  flex-direction: column;
}

.unread-badge {
  min-width: 48rpx; height: 48rpx;
  border-radius: 24rpx;
  background: $stamp-red;
  display: flex; align-items: center; justify-content: center;
  padding: 0 14rpx; flex-shrink: 0;
}
.unread-num {
  font-family: $font-family-code;
  font-size: 24rpx;
  color: #F4EFE5;
}

.perf-line {
  display: flex;
  padding: 10rpx 24rpx;
  background: $card-bg;
  border-bottom: 1rpx solid $line-sepia;
}

.perf-hole {
  flex: 1;
  height: 16rpx;
  border-radius: 50%;
  border: 1rpx solid $line-sepia;
  background: $page-background;
  margin: 0 4rpx;
}

// ── Tabs ──
.tab-bar {
  display: flex;
  background: $card-bg;
  border-bottom: 1rpx solid $line-sepia;
}

.tab-item {
  flex: 1;
  padding: 24rpx 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  position: relative;
  border-bottom: 3rpx solid transparent;

  &.tab-active {
    border-bottom-color: $travel-blue;
  }
}

.tab-txt {
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $mute-text;

  .tab-active & {
    color: $travel-blue;
  }
}

.tab-dot {
  width: 12rpx; height: 12rpx;
  border-radius: 50%;
  background: $stamp-red;
}

// ── Section label (conversation mode) ──
.section-label {
  padding: 24rpx 40rpx 8rpx;
}

.section-label-txt {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
}

.content { flex: 1; overflow: hidden; }

.loading-wrap {
  padding: 80rpx;
  text-align: center;
}

.loading-txt {
  font-family: $font-family-body;
  font-style: italic;
  font-size: 28rpx;
  color: $mute-text;
}

.empty-state {
  padding: 80rpx 60rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}

.empty-title {
  font-family: $font-family-body;
  font-size: 30rpx;
  color: $body-text;
  margin-top: 8rpx;
}

.empty-sub {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  text-align: center;
  line-height: 1.7;
}

// ── Mail list ──
.mail-list { padding: 0 40rpx; }

.mail-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 20rpx 0;
  border-bottom: 1rpx solid $line-sepia;
  &:active { background: rgba($travel-blue, 0.03); }
}

.unread-dot {
  width: 12rpx; height: 12rpx;
  border-radius: 50%;
  background: $travel-blue;
  flex-shrink: 0;
}

.unread-dot-ph {
  width: 12rpx;
  flex-shrink: 0;
}

// ── Photo thumbnail ──
.mail-thumb {
  width: 100rpx; height: 72rpx;
  border-radius: 6rpx;
  overflow: hidden;
  flex-shrink: 0;
  position: relative;
  background: $paper-beige;
}

.mail-thumb-img { width: 100%; height: 100%; }

.mail-thumb-grad {
  width: 100%; height: 100%;
  background: linear-gradient(135deg, #C9D2B6, #3C604D);
  display: flex;
  align-items: center;
  justify-content: center;
}

// Stamp badge (bottom-right of thumb)
.mail-stamp-badge {
  position: absolute;
  bottom: 4rpx; right: 4rpx;
  width: 28rpx; height: 28rpx;
  border: 1rpx solid currentColor;
  border-radius: 2rpx;
  overflow: hidden;
  background: $paper-beige;
  flex-shrink: 0;
}

.badge-img { width: 100%; height: 100%; }
.badge-color { width: 100%; height: 100%; opacity: 0.8; }

// ── Mail content ──
.mail-content { flex: 1; min-width: 0; }

.mail-top-row {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-bottom: 8rpx;
}

.sender-avatar-sm {
  width: 36rpx; height: 36rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.sent-avatar {
  background: linear-gradient(135deg, #9C7E5A, #7A6040);
}

.sender-initial-sm {
  font-family: $font-family-body;
  font-size: 22rpx;
  color: #F4EFE5;
}

.sender-name {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $ink-black;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.mail-date {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  flex-shrink: 0;
}

.mail-loc {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  margin-bottom: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.mail-note {
  display: block;
  font-family: $font-family-body;
  font-style: italic;
  font-size: 24rpx;
  color: $body-text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

// ── Status tags ──
.status-tag {
  padding: 2rpx 10rpx;
  border-radius: 4rpx;
  flex-shrink: 0;
}

.status-txt {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
}

.status-opened {
  background: rgba($travel-blue, 0.08);
  .status-txt { color: $travel-blue; }
}

.status-delivered {
  background: rgba(156, 126, 90, 0.1);
  .status-txt { color: #9C7E5A; }
}

.status-sent, .status-pending {
  background: rgba(180, 165, 140, 0.15);
  .status-txt { color: $mute-text; }
}

.btm-gap { height: 120rpx; }
</style>

<template>
  <view class="page-container">
    <PostalHeader
      kicker="MAIL · 寄出"
      title="寄明信片"
      fallback-url="/pages/home/home"
    />

    <scroll-view class="content" scroll-y>

      <!-- ── Mode A: postcardId given, pick recipient ── -->
      <template v-if="mode === 'pick-recipient' || mode === 'select-postcard-first'">
        <!-- Postcard preview strip -->
        <view class="postcard-preview" v-if="postcard">
          <view class="preview-thumb">
            <image
              v-if="postcard.photoUrl"
              :src="postcard.photoUrl"
              class="preview-thumb-img"
              mode="aspectFill"
            />
            <view v-else class="preview-thumb-grad"></view>
          </view>
          <view class="preview-info">
            <text class="preview-loc">{{ postcard.locationName }}</text>
            <text class="preview-sub">{{ postcard.city }} · {{ postcard.country }}</text>
          </view>
          <text class="preview-tag">即将寄出</text>
        </view>

        <!-- Step 1: Pick postcard (only for select-postcard-first mode) -->
        <view class="section" v-if="mode === 'select-postcard-first' && !postcard">
          <view class="section-hd" style="margin-top: 8rpx;">
            <text class="section-kicker">POSTCARD · 选择明信片</text>
            <view class="section-rule"></view>
          </view>

          <!-- Search -->
          <view class="search-bar">
            <text class="search-icon">🔍</text>
            <input
              v-model="searchQuery"
              class="search-input"
              placeholder="搜索地点、城市…"
              placeholder-style="color:#B5AE9B"
              confirm-type="search"
              @confirm="onSearch"
            />
            <text v-if="searchQuery" class="search-clear" @click="searchQuery = ''; onSearch()">✕</text>
          </view>

          <view class="pc-empty" v-if="!pcLoading && postcardList.length === 0">
            <text class="pc-empty-kicker">NO POSTCARDS</text>
            <text class="pc-empty-title">{{ searchQuery ? '没有找到匹配的明信片' : '还没有可寄出的明信片' }}</text>
            <text class="pc-empty-txt">{{ searchQuery ? '换个关键词试试' : '先记录一张明信片，再回来寄给好友。' }}</text>
            <view v-if="!searchQuery" class="pc-empty-btn" @click="goRecord">
              <text class="pc-empty-btn-txt">去记录明信片 ›</text>
            </view>
          </view>

          <view class="pc-list" v-if="postcardList.length > 0">
            <view
              v-for="pc in postcardList"
              :key="pc.id"
              class="pc-row"
              @click="postcard = pc"
            >
              <view class="pc-thumb">
                <image
                  v-if="pc.photoUrl"
                  :src="pc.photoUrl"
                  class="pc-thumb-img"
                  mode="aspectFill"
                />
                <view v-else class="pc-thumb-grad"></view>
                <view class="pc-stamp-badge" :style="{ borderColor: getStampColor(pc.stampDesign) }">
                  <image
                    v-if="getStampImageUrl(pc.stampDesign)"
                    :src="getStampImageUrl(pc.stampDesign)"
                    class="pc-stamp-badge-img"
                    mode="aspectFill"
                  />
                  <view v-else class="pc-stamp-badge-color" :style="{ background: getStampColor(pc.stampDesign) }"></view>
                </view>
              </view>
              <view class="pc-info">
                <text class="pc-loc">{{ pc.locationName }}</text>
                <text class="pc-sub">{{ pc.city }} · {{ pc.country }}</text>
                <text class="pc-date">{{ formatPostmarkDate(pc.recordedAt) }}</text>
              </view>
              <text class="pc-arr">›</text>
            </view>
          </view>

          <!-- Load more -->
          <view v-if="pcHasMore && !pcLoading" class="load-more" @click="loadMore">
            <text class="load-more-txt">加载更多 ›</text>
          </view>
          <view v-if="pcLoading" class="load-more">
            <text class="load-more-txt">加载中…</text>
          </view>
          <view v-if="!pcHasMore && postcardList.length > 0" class="load-more">
            <text class="load-more-txt">— 共 {{ pcTotal }} 张 —</text>
          </view>
        </view>

        <!-- Step 2: Pick recipient -->
        <view class="section" v-if="!recipient && (postcard || mode === 'pick-recipient')">

          <!-- Contacts list -->
          <view class="section-hd">
            <text class="section-kicker">CONTACTS · 联系人</text>
            <view class="section-rule"></view>
          </view>

          <view class="contacts-loading" v-if="contactsLoading">
            <text class="contacts-loading-txt">加载中…</text>
          </view>

          <view class="contacts-list" v-else-if="contacts.length > 0">
            <view
              v-for="c in contacts"
              :key="c.id"
              class="contact-row"
              @click="selectContact(c)"
            >
              <view class="user-avatar">
                <image v-if="c.avatarUrl" :src="c.avatarUrl" class="avatar-img" mode="aspectFill" />
                <text v-else class="user-initial">{{ (c.remarkName || c.nickname).slice(0, 1) }}</text>
              </view>
              <view class="user-info">
                <text class="user-name">{{ c.remarkName || c.nickname }}</text>
                <text class="user-mailbox">{{ c.mailboxNo }}</text>
              </view>
              <text class="user-select-arr">›</text>
            </view>
          </view>

          <view class="contacts-empty" v-else>
            <text class="contacts-empty-txt">暂无联系人</text>
          </view>

          <!-- Search for other users -->
          <view class="section-hd" style="margin-top: 40rpx;">
            <text class="section-kicker">SEARCH · 搜索其他用户</text>
            <view class="section-rule"></view>
          </view>

          <view class="search-wrap">
            <UserSearchPanel
              action-label="选择"
              done-label="已选择"
              :existing-user-ids="recipient ? [recipient.id] : []"
              @select="selectRecipient"
            />
          </view>
        </view>

        <!-- Step 3: Compose note -->
        <view class="section" v-if="recipient">
          <view class="section-hd">
            <text class="section-kicker">RECIPIENT · 收件人</text>
            <view class="section-rule"></view>
          </view>

          <view class="selected-recipient">
            <view class="user-avatar">
              <text class="user-initial">{{ recipient.nickname.slice(0, 1) }}</text>
            </view>
            <view class="user-info">
              <text class="user-name">{{ recipient.nickname }}</text>
              <text class="user-mailbox">{{ recipient.mailboxNo }}</text>
            </view>
            <text class="change-btn" @click="recipient = null">更换</text>
          </view>

          <view class="section-hd" style="margin-top: 40rpx;">
            <text class="section-kicker">NOTE · 留言（选填）</text>
            <view class="section-rule"></view>
          </view>
          <view class="note-card">
            <textarea
              class="note-input"
              v-model="personalNote"
              placeholder="写一句想对 TA 说的话…"
              :placeholder-style="'color:#B5AE9B; font-family: serif'"
              maxlength="100"
              :auto-height="true"
            />
            <text class="note-count">{{ personalNote.length }}/100</text>
          </view>

          <view class="action-btn" :class="{ 'action-dis': sending }" @click="doSend">
            <IconSend :size="24" color="#F4EFE5" />
            <text class="action-btn-txt">{{ sending ? '寄出中…' : '寄　出' }}</text>
          </view>
        </view>
      </template>

      <!-- ── Mode B: recipientId given, pick postcard ── -->
      <template v-else>
        <!-- Fixed recipient card -->
        <view class="section">
          <view class="section-hd">
            <text class="section-kicker">RECIPIENT · 收件人</text>
            <view class="section-rule"></view>
          </view>
          <view class="selected-recipient">
            <view class="user-avatar">
              <text class="user-initial">{{ recipient!.nickname.slice(0, 1) }}</text>
            </view>
            <view class="user-info">
              <text class="user-name">{{ recipient!.nickname }}</text>
              <text class="user-mailbox">{{ recipient!.mailboxNo }}</text>
            </view>
            <text class="recipient-tag">来自通讯录</text>
          </view>
        </view>

        <!-- Pick postcard -->
        <view class="section" v-if="!postcard">
          <view class="section-hd" style="margin-top: 8rpx;">
            <text class="section-kicker">POSTCARD · 选择明信片</text>
            <view class="section-rule"></view>
          </view>

          <view class="pc-empty" v-if="allPostcards.length === 0">
            <text class="pc-empty-kicker">NO POSTCARDS</text>
            <text class="pc-empty-title">还没有可寄出的明信片</text>
            <text class="pc-empty-txt">先记录一张明信片，再回来寄给好友。</text>
            <view class="pc-empty-btn" @click="goRecord">
              <text class="pc-empty-btn-txt">去记录明信片 ›</text>
            </view>
          </view>

          <view class="pc-list" v-else>
            <view
              v-for="pc in allPostcards"
              :key="pc.id"
              class="pc-row"
              @click="postcard = pc"
            >
              <!-- Photo thumbnail -->
              <view class="pc-thumb">
                <image
                  v-if="pc.photoUrl"
                  :src="pc.photoUrl"
                  class="pc-thumb-img"
                  mode="aspectFill"
                />
                <view v-else class="pc-thumb-grad"></view>
                <!-- Mini stamp badge -->
                <view class="pc-stamp-badge" :style="{ borderColor: getStampColor(pc.stampDesign) }">
                  <image
                    v-if="getStampImageUrl(pc.stampDesign)"
                    :src="getStampImageUrl(pc.stampDesign)"
                    class="pc-stamp-badge-img"
                    mode="aspectFill"
                  />
                  <view v-else class="pc-stamp-badge-color" :style="{ background: getStampColor(pc.stampDesign) }"></view>
                </view>
              </view>

              <!-- Info -->
              <view class="pc-info">
                <text class="pc-loc">{{ pc.locationName }}</text>
                <text class="pc-sub">{{ pc.city }} · {{ pc.country }}</text>
                <text class="pc-date">{{ formatPostmarkDate(pc.recordedAt) }}</text>
              </view>
              <text class="pc-arr">›</text>
            </view>
          </view>
        </view>

        <!-- Postcard selected → compose note -->
        <view class="section" v-if="postcard">
          <view class="section-hd" style="margin-top: 8rpx;">
            <text class="section-kicker">POSTCARD · 明信片</text>
            <view class="section-rule"></view>
          </view>
          <view class="postcard-preview">
            <view class="preview-thumb">
              <image
                v-if="postcard.photoUrl"
                :src="postcard.photoUrl"
                class="preview-thumb-img"
                mode="aspectFill"
              />
              <view v-else class="preview-thumb-grad"></view>
            </view>
            <view class="preview-info">
              <text class="preview-loc">{{ postcard.locationName }}</text>
              <text class="preview-sub">{{ postcard.city }} · {{ postcard.country }}</text>
            </view>
            <text class="change-btn" @click="postcard = null">更换</text>
          </view>

          <view class="section-hd" style="margin-top: 40rpx;">
            <text class="section-kicker">NOTE · 留言（选填）</text>
            <view class="section-rule"></view>
          </view>
          <view class="note-card">
            <textarea
              class="note-input"
              v-model="personalNote"
              placeholder="写一句想对 TA 说的话…"
              :placeholder-style="'color:#B5AE9B; font-family: serif'"
              maxlength="100"
              :auto-height="true"
            />
            <text class="note-count">{{ personalNote.length }}/100</text>
          </view>

          <view class="action-btn" :class="{ 'action-dis': sending }" @click="doSend">
            <IconSend :size="24" color="#F4EFE5" />
            <text class="action-btn-txt">{{ sending ? '寄出中…' : '寄　出' }}</text>
          </view>
        </view>
      </template>

      <view class="btm-gap"></view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { MailApi, ContactsApi, PostcardApi, type ApiUser, type ContactItem } from '@/services/api'
import { usePostcardStore } from '@/stores/postcard'
import type { Postcard } from '@/model/Postcard'
import PostalHeader from '@/components/PostalHeader.vue'
import UserSearchPanel from '@/components/UserSearchPanel.vue'
import { IconSend } from '@/components/icons'
import { safeBack } from '@/utils/navigation'
import { getStampColor, getStampImageUrl } from '@/utils/stamp'

const MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
function formatPostmarkDate(ts: number): string {
  const d = new Date(ts)
  return `${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`
}

const store = usePostcardStore()

// 'pick-recipient'        = came from postcard detail (postcardId given)
// 'pick-postcard'         = came from contacts (recipientId given)
// 'select-postcard-first' = came from home send button (no param)
const mode = ref<'pick-recipient' | 'pick-postcard' | 'select-postcard-first'>('pick-recipient')

const postcardId    = ref('')
const postcard      = ref<Postcard | null>(null)
const recipient     = ref<ApiUser | null>(null)
const personalNote  = ref('')
const sending       = ref(false)

const contacts        = ref<ContactItem[]>([])
const contactsLoading = ref(false)

async function loadContacts() {
  contactsLoading.value = true
  try {
    contacts.value = await ContactsApi.list()
  } catch {
    // silently fail — user can still search
  } finally {
    contactsLoading.value = false
  }
}

function selectContact(c: ContactItem) {
  recipient.value = {
    id:        c.contactId,
    nickname:  c.remarkName || c.nickname,
    mailboxNo: c.mailboxNo,
    avatarUrl: c.avatarUrl ?? null,
  }
}

// ── 明信片列表（分页 + 搜索）─────────────────────────────────────
const postcardList   = ref<Postcard[]>([])
const searchQuery    = ref('')
const pcOffset       = ref(0)
const pcHasMore      = ref(true)
const pcLoading      = ref(false)
const pcTotal        = ref(0)
const PAGE_SIZE      = 20

async function loadPostcards(append = false) {
  if (pcLoading.value) return
  pcLoading.value = true
  try {
    const [items, countRes] = await Promise.all([
      PostcardApi.list({
        q: searchQuery.value || undefined,
        limit: PAGE_SIZE,
        offset: append ? pcOffset.value : 0,
      }),
      PostcardApi.count({ q: searchQuery.value || undefined }),
    ])
    pcTotal.value = countRes.total
    const filtered = items.filter(pc => !pc.isSavedMailing)
    if (append) {
      postcardList.value.push(...filtered)
    } else {
      postcardList.value = filtered
    }
    pcOffset.value = postcardList.value.length
    pcHasMore.value = pcOffset.value < pcTotal.value
  } catch (e: any) {
    uni.showToast({ title: e.message || '加载失败', icon: 'none' })
  } finally {
    pcLoading.value = false
  }
}

function onSearch() {
  pcOffset.value = 0
  pcHasMore.value = true
  loadPostcards(false)
}

function loadMore() {
  if (!pcHasMore.value || pcLoading.value) return
  loadPostcards(true)
}

function selectRecipient(u: ApiUser) {
  recipient.value = u
}

async function doSend() {
  if (!postcard.value || !recipient.value || sending.value) return
  sending.value = true
  try {
    await MailApi.send(postcard.value.id, recipient.value.id, personalNote.value.trim() || undefined)
    uni.showToast({ title: '已寄出！', icon: 'success' })
    // sending stays true — prevents double-submit during navigation
    setTimeout(() => safeBack('/pages/inbox/inbox'), 800)
  } catch (e: any) {
    uni.showToast({ title: e.message || '寄出失败', icon: 'none' })
    sending.value = false
  }
}

function goBack() {
  safeBack('/pages/home/home')
}

function goRecord() {
  uni.switchTab({ url: '/pages/record/record' })
}

onLoad((opts) => {
  if (opts?.postcardId) {
    postcardId.value = opts.postcardId
    mode.value = 'pick-recipient'
  } else if (opts?.recipientId) {
    mode.value = 'pick-postcard'
    recipient.value = {
      id:        opts.recipientId,
      nickname:  decodeURIComponent(opts.recipientNickname || ''),
      mailboxNo: decodeURIComponent(opts.recipientMailboxNo || ''),
      avatarUrl: null,
    }
  } else {
    mode.value = 'select-postcard-first'
  }
})

onMounted(() => {
  store.initData()
  if (postcardId.value) {
    postcard.value = store.getPostcardById(postcardId.value) || null
  }
  if (mode.value === 'pick-recipient' || mode.value === 'select-postcard-first') {
    loadContacts()
  }
  if (mode.value === 'select-postcard-first') {
    loadPostcards(false)
  }
})
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
  display: flex;
  flex-direction: column;
}

.content { flex: 1; overflow: hidden; }

.postcard-preview {
  margin: 28rpx 40rpx 0;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 16rpx 20rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
  overflow: hidden;
}

.preview-thumb {
  width: 100rpx;
  height: 72rpx;
  border-radius: 6rpx;
  overflow: hidden;
  flex-shrink: 0;
  position: relative;
}

.preview-thumb-img {
  width: 100%;
  height: 100%;
}

.preview-thumb-grad {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #C9D2B6 0%, #6E8862 50%, #3C604D 100%);
}

.preview-info { flex: 1; min-width: 0; }

.preview-loc {
  display: block;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.preview-sub {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
  margin-top: 4rpx;
}

.preview-tag {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
  flex-shrink: 0;
}

.section { margin: 32rpx 40rpx 0; }

.section-hd {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.section-kicker {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
  white-space: nowrap;
  flex-shrink: 0;
}

.section-rule {
  flex: 1;
  height: 1rpx;
  background: $line-sepia;
}

// ── Contacts list in pick-recipient mode ──────────────────
.contacts-loading {
  padding: 32rpx 0;
  text-align: center;
}

.contacts-loading-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
}

.contacts-list {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
  margin-bottom: 8rpx;
}

.contact-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 20rpx 24rpx;
  border-bottom: 1rpx solid $line-sepia;

  &:last-child { border-bottom: none; }
  &:active { background: rgba($travel-blue, 0.05); }
}

.avatar-img {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
}

.contacts-empty {
  padding: 24rpx 0;
}

.contacts-empty-txt {
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
  font-style: italic;
}

.search-wrap { margin-bottom: 16rpx; }

.user-avatar {
  width: 72rpx; height: 72rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-initial {
  font-family: $font-family-body;
  font-size: 30rpx;
  color: #F4EFE5;
}

.user-info { flex: 1; }

.user-name {
  display: block;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 6rpx;
}

.user-mailbox {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
}

.selected-recipient {
  background: $card-bg;
  border: 1rpx solid rgba($travel-blue, 0.3);
  border-radius: 8rpx;
  padding: 24rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.change-btn {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: $mute-text;
}

.note-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 24rpx;
  position: relative;
}

.note-input {
  width: 100%;
  min-height: 120rpx;
  font-family: $font-family-body;
  font-style: normal;
  font-size: 28rpx;
  color: $ink-black;
  line-height: 1.75;
}

.note-count {
  display: block;
  text-align: right;
  font-family: $font-family-code;
  font-size: 22rpx;
  color: $mute-text;
  margin-top: 12rpx;
}

.action-btn {
  margin-top: 48rpx;
  height: 96rpx;
  background: $travel-blue;
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16rpx;

  &.action-dis { opacity: 0.55; }
  &:active:not(.action-dis) { background: $forest-green; }
}

.action-btn-txt {
  font-family: $font-family-action;
  font-size: 32rpx;
  letter-spacing: 2rpx;
  color: #F4EFE5;
}

.recipient-tag {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $travel-blue;
  padding: 4rpx 12rpx;
  border: 1rpx solid rgba($travel-blue, 0.4);
  border-radius: 4rpx;
}

.pc-empty {
  padding: 48rpx 32rpx;
  text-align: center;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
}

.pc-empty-kicker {
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.pc-empty-title {
  font-family: $font-family-body;
  font-size: 34rpx;
  color: $ink-black;
}

.pc-empty-txt {
  font-family: $font-family-body;
  font-size: 24rpx;
  color: $mute-text;
  line-height: 1.6;
}

.pc-empty-btn {
  margin-top: 8rpx;
  min-width: 240rpx;
  height: 72rpx;
  border-radius: 8rpx;
  background: $travel-blue;
  display: flex;
  align-items: center;
  justify-content: center;

  &:active { background: $forest-green; }
}

.pc-empty-btn-txt {
  font-family: $font-family-action;
  font-size: 26rpx;
  color: #F4EFE5;
  letter-spacing: 0;
}

.pc-list {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  overflow: hidden;
}

.pc-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 20rpx 24rpx;
  border-bottom: 1rpx solid $line-sepia;

  &:last-child { border-bottom: none; }
  &:active { background: rgba($travel-blue, 0.04); }
}

// Photo thumbnail
.pc-thumb {
  width: 110rpx;
  height: 80rpx;
  border-radius: 6rpx;
  overflow: hidden;
  flex-shrink: 0;
  position: relative;
}

.pc-thumb-img {
  width: 100%;
  height: 100%;
}

.pc-thumb-grad {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #C9D2B6 0%, #6E8862 50%, #3C604D 100%);
}

// Mini stamp badge (bottom-right of thumb)
.pc-stamp-badge {
  position: absolute;
  bottom: 4rpx;
  right: 4rpx;
  width: 32rpx;
  height: 32rpx;
  border: 2rpx solid currentColor;
  border-radius: 2rpx;
  overflow: hidden;
  background: $paper-beige;
}

.pc-stamp-badge-img {
  width: 100%;
  height: 100%;
}

.pc-stamp-badge-color {
  width: 100%;
  height: 100%;
  opacity: 0.8;
}

.pc-info { flex: 1; min-width: 0; }

.pc-loc {
  display: block;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.pc-sub {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.pc-date {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
  opacity: 0.6;
  margin-top: 6rpx;
}

.pc-arr {
  font-family: $font-family-body;
  font-size: 40rpx;
  color: $mute-text;
}

.btm-gap { height: 120rpx; }

// ── Search bar ───────────────────────────────────────────────────
.search-bar {
  display: flex;
  align-items: center;
  gap: 16rpx;
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 8rpx;
  padding: 16rpx 24rpx;
  margin-bottom: 20rpx;
}
.search-icon {
  font-size: 28rpx;
  flex-shrink: 0;
}
.search-input {
  flex: 1;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  height: 44rpx;
}
.search-clear {
  font-size: 24rpx;
  color: $mute-text;
  padding: 8rpx;
}

// ── Load more ────────────────────────────────────────────────────
.load-more {
  padding: 24rpx 0;
  text-align: center;
}
.load-more-txt {
  font-family: $font-family-code;
  font-size: 24rpx;
  letter-spacing: 1rpx;
  color: $mute-text;
}
</style>

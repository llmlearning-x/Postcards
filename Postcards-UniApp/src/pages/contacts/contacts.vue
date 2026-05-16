<template>
  <view class="page-container">
    <!-- Header -->
    <view class="postal-header">
      <view class="header-perf"></view>
      <view class="nav-back" @click="goBack">
        <IconBack :size="18" color="rgba(255,255,255,0.9)" />
      </view>
      <view class="header-add" @click="openAddSheet">
        <IconPlus :size="20" color="rgba(255,255,255,0.9)" />
      </view>
      <text class="header-kicker">CONTACTS · 通讯录</text>
      <text class="header-title">我的联系人</text>
    </view>

    <scroll-view class="content" scroll-y>
      <!-- Loading -->
      <view class="state-center" v-if="loading">
        <text class="state-txt">加载中…</text>
      </view>

      <!-- Error -->
      <view class="state-center" v-else-if="loadError">
        <text class="state-txt">{{ loadError }}</text>
        <view class="retry-btn" @click="load">重试</view>
      </view>

      <!-- Empty -->
      <view class="empty-state" v-else-if="contacts.length === 0">
        <view class="empty-icon-wrap">
          <IconContacts :size="48" color="#B5AE9B" />
        </view>
        <text class="empty-title">暂无联系人</text>
        <text class="empty-sub">通过对方的邮箱号搜索并添加好友</text>
        <view class="empty-add-btn" @click="openAddSheet">
          <IconPlus :size="16" color="#F4EFE5" />
          <text class="empty-add-txt">添加联系人</text>
        </view>
      </view>

      <!-- Contact list -->
      <view class="list" v-else>
        <view class="contact-count-bar">
          <text class="contact-count-txt">共 {{ contacts.length }} 位联系人</text>
        </view>

        <view
          v-for="c in contacts"
          :key="c.id"
          class="contact-card"
        >
          <view class="contact-avatar">
            <image v-if="c.avatarUrl" :src="c.avatarUrl" class="avatar-img" mode="aspectFill" />
            <text v-else class="avatar-initial">{{ initial(c) }}</text>
          </view>

          <view class="contact-info">
            <view class="contact-name-row">
              <text class="contact-name">{{ c.remarkName || c.nickname }}</text>
              <text v-if="c.remarkName" class="contact-real-name">{{ c.nickname }}</text>
            </view>
            <view class="contact-meta">
              <text class="contact-mailbox">{{ c.mailboxNo }}</text>
              <text class="contact-sep">·</text>
              <text class="contact-mail-count">{{ c.mailCount }} 封往来</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="history-btn" @click="goHistory(c)">
              <IconEnvelope :size="16" color="#8A8070" />
            </view>
            <view class="send-btn" @click="goSend(c)">
              <IconSend :size="16" color="#F4EFE5" />
              <text class="send-btn-txt">寄出</text>
            </view>
            <view class="more-btn" @click="showMore(c)">
              <IconMore :size="18" color="#8A8070" />
            </view>
          </view>
        </view>
      </view>

      <view class="btm-gap"></view>
    </scroll-view>

    <!-- ── Add contact sheet ── -->
    <view class="overlay" v-if="showAddSheet" @click="closeAddSheet"></view>
    <view class="bottom-sheet" :class="{ 'sheet-visible': showAddSheet }">
      <view class="sheet-handle"></view>
      <text class="sheet-title">添加联系人</text>

      <view class="search-bar">
        <IconSearch :size="16" color="#8A8070" />
        <input
          class="search-input"
          v-model="searchQ"
          placeholder="输入 6 位邮箱号"
          placeholder-style="color:#B5AE9B"
          @input="onSearchInput"
          confirm-type="search"
          type="number"
          maxlength="6"
        />
        <view class="search-clear" v-if="searchQ" @click="clearSearch">
          <IconX :size="14" color="#8A8070" />
        </view>
      </view>

      <!-- Search loading -->
      <view class="search-hint" v-if="searching">
        <text class="search-hint-txt">搜索中…</text>
      </view>

      <!-- Search prompt -->
      <view class="search-hint" v-else-if="!searchQ">
        <text class="search-hint-txt">请输入对方的完整邮箱号，如 CN-123456</text>
      </view>

      <!-- 格式不对 -->
      <view class="search-hint" v-else-if="searchQ && !isValidMailboxNo(searchQ)">
        <text class="search-hint-txt">请输入 6 位数字</text>
      </view>

      <!-- No results -->
      <view class="search-hint" v-else-if="searchQ && searchResults.length === 0 && !searching">
        <text class="search-hint-txt">未找到该邮箱号对应的用户</text>
      </view>

      <!-- Results -->
      <scroll-view class="search-results" scroll-y v-else-if="searchResults.length > 0">
        <view
          v-for="u in searchResults"
          :key="u.id"
          class="result-row"
        >
          <view class="result-avatar">
            <text class="result-initial">{{ u.nickname.slice(0, 1) }}</text>
          </view>
          <view class="result-info">
            <text class="result-name">{{ u.nickname }}</text>
            <text class="result-mailbox">{{ u.mailboxNo }}</text>
          </view>
          <view
            class="add-btn"
            :class="{ 'add-btn-done': isContact(u.id) }"
            @click="addContact(u)"
          >
            <text class="add-btn-txt">{{ isContact(u.id) ? '已添加' : '添加' }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- ── Remark edit modal ── -->
    <view class="overlay" v-if="showRemarkModal" @click="cancelRemark"></view>
    <view class="remark-modal" v-if="showRemarkModal">
      <text class="modal-title">设置备注</text>
      <text class="modal-sub">为 {{ remarkTarget?.nickname }} 设置一个备注名</text>
      <input
        class="remark-input"
        v-model="remarkInput"
        :placeholder="remarkTarget?.nickname || ''"
        placeholder-style="color:#B5AE9B"
        maxlength="20"
      />
      <view class="modal-btns">
        <view class="modal-btn modal-btn-cancel" @click="cancelRemark">取消</view>
        <view class="modal-btn modal-btn-confirm" @click="confirmRemark">确认</view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { ContactsApi, type ContactItem, UserApi } from '@/services/api'
import { IconBack, IconPlus, IconSend, IconMore, IconSearch, IconX, IconContacts, IconEnvelope } from '@/components/icons'

const contacts     = ref<ContactItem[]>([])
const loading      = ref(true)
const loadError    = ref('')

// ── Add sheet ─────────────────────────────────────────────
const showAddSheet  = ref(false)
const searchQ       = ref('')
const searching     = ref(false)
const searchResults = ref<any[]>([])
let   searchTimer: ReturnType<typeof setTimeout> | null = null

// ── Remark modal ──────────────────────────────────────────
const showRemarkModal = ref(false)
const remarkTarget    = ref<ContactItem | null>(null)
const remarkInput     = ref('')

function initial(c: ContactItem): string {
  return (c.remarkName || c.nickname).slice(0, 1)
}

function isContact(userId: string): boolean {
  return contacts.value.some(c => c.contactId === userId)
}

async function load() {
  loading.value   = true
  loadError.value = ''
  try {
    contacts.value = await ContactsApi.list()
  } catch (e: any) {
    loadError.value = e.message || '加载失败'
  } finally {
    loading.value = false
  }
}

// ── Add contact ───────────────────────────────────────────
function openAddSheet() {
  showAddSheet.value = true
  searchQ.value      = ''
  searchResults.value = []
}

function closeAddSheet() {
  showAddSheet.value = false
  if (searchTimer) clearTimeout(searchTimer)
}

function clearSearch() {
  searchQ.value       = ''
  searchResults.value = []
}

function isValidMailboxNo(s: string): boolean {
  return /^\d{6}$/.test(s.trim())
}

function onSearchInput() {
  if (searchTimer) clearTimeout(searchTimer)
  const q = searchQ.value.trim()
  if (!q) { searchResults.value = []; return }
  // 只有完整邮箱号格式才触发搜索
  if (!isValidMailboxNo(q)) { searchResults.value = []; return }
  searchTimer = setTimeout(doSearch, 300)
}

async function doSearch() {
  const q = searchQ.value.trim()
  if (!isValidMailboxNo(q)) return
  searching.value = true
  try {
    searchResults.value = await UserApi.search(q)
  } catch (e: any) {
    searchResults.value = []
    uni.showToast({ title: e.message || '搜索失败，请重试', icon: 'none' })
  } finally {
    searching.value = false
  }
}

async function addContact(u: any) {
  if (isContact(u.id)) return
  try {
    const item = await ContactsApi.add(u.id)
    contacts.value.unshift(item)
    uni.showToast({ title: '已添加', icon: 'success' })
    setTimeout(() => closeAddSheet(), 800)
  } catch (e: any) {
    uni.showToast({ title: e.message || '添加失败', icon: 'none' })
  }
}

// ── More menu ─────────────────────────────────────────────
function showMore(c: ContactItem) {
  uni.showActionSheet({
    itemList: ['查看往来记录', '寄出明信片', '设置备注', '删除联系人'],
    success: (res) => {
      if (res.tapIndex === 0) goHistory(c)
      if (res.tapIndex === 1) goSend(c)
      if (res.tapIndex === 2) openRemark(c)
      if (res.tapIndex === 3) confirmDelete(c)
    },
  })
}

function goSend(c: ContactItem) {
  uni.navigateTo({
    url: `/pages/send/send?recipientId=${c.contactId}&recipientNickname=${encodeURIComponent(c.remarkName || c.nickname)}&recipientMailboxNo=${encodeURIComponent(c.mailboxNo)}`,
  })
}

function goHistory(c: ContactItem) {
  uni.navigateTo({
    url: `/pages/inbox/inbox?contactId=${c.contactId}&nickname=${encodeURIComponent(c.remarkName || c.nickname)}`,
  })
}

// ── Delete ────────────────────────────────────────────────
function confirmDelete(c: ContactItem) {
  uni.showModal({
    title: '删除联系人',
    content: `确认删除「${c.remarkName || c.nickname}」？`,
    confirmColor: '#C62828',
    success: async (res) => {
      if (!res.confirm) return
      try {
        await ContactsApi.remove(c.id)
        contacts.value = contacts.value.filter(x => x.id !== c.id)
        uni.showToast({ title: '已删除', icon: 'none' })
      } catch {
        uni.showToast({ title: '删除失败', icon: 'none' })
      }
    },
  })
}

// ── Remark ────────────────────────────────────────────────
function openRemark(c: ContactItem) {
  remarkTarget.value    = c
  remarkInput.value     = c.remarkName || ''
  showRemarkModal.value = true
}

function cancelRemark() {
  showRemarkModal.value = false
  remarkTarget.value    = null
}

async function confirmRemark() {
  const c = remarkTarget.value
  if (!c) return
  try {
    await ContactsApi.setRemark(c.id, remarkInput.value.trim() || null)
    const idx = contacts.value.findIndex(x => x.id === c.id)
    if (idx !== -1) contacts.value[idx].remarkName = remarkInput.value.trim() || null
    uni.showToast({ title: '备注已保存', icon: 'success' })
  } catch {
    uni.showToast({ title: '保存失败', icon: 'none' })
  } finally {
    showRemarkModal.value = false
    remarkTarget.value    = null
  }
}

function goBack() {
  uni.navigateBack()
}

onShow(load)
</script>

<style lang="scss" scoped>
.page-container {
  min-height: 100vh;
  background: $page-background;
}

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
.header-add {
  position: absolute; top: 52rpx; right: 48rpx;
  width: 64rpx; height: 64rpx;
  display: flex; align-items: center; justify-content: center;
  &:active { opacity: 0.6; }
}
.header-kicker {
  display: block; font-family: $font-family-mono;
  font-size: 20rpx; letter-spacing: 4rpx; color: rgba(255,255,255,0.65); margin-bottom: 12rpx;
}
.header-title {
  display: block; font-family: $font-family-serif;
  font-size: 46rpx; font-weight: 400; color: rgba(255,255,255,0.95); line-height: 1.15; letter-spacing: -1rpx;
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

.content { height: calc(100vh - 220rpx); }

// ── States ──────────────────────────────────────────────────
.state-center {
  padding: 120rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 32rpx;
}

.state-txt {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $mute-text;
}

.retry-btn {
  padding: 16rpx 48rpx;
  background: $travel-blue;
  border-radius: 8rpx;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: #F4EFE5;
}

.empty-state {
  padding: 100rpx 60rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
}

.empty-icon-wrap {
  width: 120rpx; height: 120rpx;
  border-radius: 50%;
  background: rgba($travel-blue, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12rpx;
}

.empty-title {
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: $ink-black;
}

.empty-sub {
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $mute-text;
  text-align: center;
  line-height: 1.6;
}

.empty-add-btn {
  margin-top: 16rpx;
  height: 72rpx;
  padding: 0 40rpx;
  background: $travel-blue;
  border-radius: 36rpx;
  display: flex;
  align-items: center;
  gap: 12rpx;
  &:active { opacity: 0.85; }
}

.empty-add-txt {
  font-family: $font-family-mono;
  font-size: 26rpx;
  color: #F4EFE5;
  letter-spacing: 2rpx;
}

// ── List ────────────────────────────────────────────────────
.list { padding: 0 40rpx; }

.contact-count-bar {
  padding: 24rpx 0 16rpx;
}

.contact-count-txt {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: $mute-text;
}

.contact-card {
  background: $card-bg;
  border: 1rpx solid $line-sepia;
  border-radius: 12rpx;
  padding: 20rpx 20rpx 20rpx 24rpx;
  margin-bottom: 16rpx;
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.contact-avatar {
  width: 80rpx; height: 80rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  overflow: hidden;
}

.avatar-img { width: 80rpx; height: 80rpx; border-radius: 50%; }

.avatar-initial {
  font-family: $font-family-serif;
  font-size: 32rpx;
  color: #F4EFE5;
}

.contact-info { flex: 1; min-width: 0; }

.contact-name-row {
  display: flex;
  align-items: baseline;
  gap: 12rpx;
  margin-bottom: 8rpx;
}

.contact-name {
  font-family: $font-family-serif;
  font-size: 30rpx;
  color: $ink-black;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.contact-real-name {
  font-family: $font-family-serif;
  font-size: 22rpx;
  color: $mute-text;
  flex-shrink: 0;
}

.contact-meta {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.contact-mailbox {
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.contact-sep {
  font-size: 18rpx;
  color: $mute-text;
}

.contact-mail-count {
  font-family: $font-family-mono;
  font-size: 20rpx;
  color: $mute-text;
}

.card-actions {
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
}

.history-btn {
  width: 56rpx; height: 56rpx;
  border-radius: 28rpx;
  border: 1rpx solid $line-sepia;
  display: flex;
  align-items: center;
  justify-content: center;
  &:active { background: rgba($travel-blue, 0.06); }
}

.send-btn {
  height: 56rpx;
  padding: 0 20rpx;
  background: $travel-blue;
  border-radius: 28rpx;
  display: flex;
  align-items: center;
  gap: 8rpx;
  &:active { background: $forest-green; }
}

.send-btn-txt {
  font-family: $font-family-mono;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: #F4EFE5;
}

.more-btn {
  width: 56rpx; height: 56rpx;
  border-radius: 28rpx;
  border: 1rpx solid $line-sepia;
  display: flex;
  align-items: center;
  justify-content: center;
  &:active { background: rgba($travel-blue, 0.06); }
}

// ── Add sheet ───────────────────────────────────────────────
.overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  z-index: 100;
}

.bottom-sheet {
  position: fixed;
  left: 0; right: 0; bottom: 0;
  background: $card-bg;
  border-radius: 32rpx 32rpx 0 0;
  padding: 16rpx 40rpx 60rpx;
  z-index: 101;
  transform: translateY(100%);
  transition: transform 0.28s cubic-bezier(0.4, 0, 0.2, 1);
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}

.sheet-visible {
  transform: translateY(0);
}

.sheet-handle {
  width: 80rpx; height: 8rpx;
  border-radius: 4rpx;
  background: $line-sepia;
  margin: 0 auto 32rpx;
}

.sheet-title {
  font-family: $font-family-serif;
  font-size: 36rpx;
  color: $ink-black;
  margin-bottom: 28rpx;
  display: block;
}

.search-bar {
  height: 80rpx;
  background: $page-background;
  border: 1rpx solid $line-sepia;
  border-radius: 40rpx;
  padding: 0 24rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 24rpx;
  flex-shrink: 0;
}

.search-input {
  flex: 1;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  background: transparent;
}

.search-clear {
  width: 40rpx; height: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-hint {
  padding: 40rpx 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-hint-txt {
  font-family: $font-family-serif;
  font-size: 26rpx;
  color: $mute-text;
  font-style: italic;
}

.search-results {
  flex: 1;
  overflow: hidden;
}

.result-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 20rpx 0;
  border-bottom: 1rpx solid $line-sepia;
}

.result-avatar {
  width: 72rpx; height: 72rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.result-initial {
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: #F4EFE5;
}

.result-info { flex: 1; min-width: 0; }

.result-name {
  display: block;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
}

.result-mailbox {
  display: block;
  font-family: $font-family-mono;
  font-size: 20rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.add-btn {
  height: 56rpx;
  padding: 0 28rpx;
  background: $travel-blue;
  border-radius: 28rpx;
  display: flex;
  align-items: center;
  flex-shrink: 0;
  &:active { opacity: 0.8; }
}

.add-btn-done {
  background: transparent;
  border: 1rpx solid $line-sepia;
}

.add-btn-txt {
  font-family: $font-family-mono;
  font-size: 22rpx;
  letter-spacing: 1rpx;
  color: #F4EFE5;

  .add-btn-done & {
    color: $mute-text;
  }
}

// ── Remark modal ────────────────────────────────────────────
.remark-modal {
  position: fixed;
  left: 60rpx; right: 60rpx;
  top: 50%;
  transform: translateY(-50%);
  background: $card-bg;
  border-radius: 24rpx;
  padding: 48rpx 40rpx 40rpx;
  z-index: 101;
}

.modal-title {
  display: block;
  font-family: $font-family-serif;
  font-size: 34rpx;
  color: $ink-black;
  margin-bottom: 10rpx;
}

.modal-sub {
  display: block;
  font-family: $font-family-serif;
  font-size: 24rpx;
  color: $mute-text;
  margin-bottom: 36rpx;
  line-height: 1.5;
}

.remark-input {
  width: 100%;
  height: 80rpx;
  background: $page-background;
  border: 1rpx solid $line-sepia;
  border-radius: 12rpx;
  padding: 0 24rpx;
  font-family: $font-family-serif;
  font-size: 28rpx;
  color: $ink-black;
  box-sizing: border-box;
  margin-bottom: 32rpx;
}

.modal-btns {
  display: flex;
  gap: 20rpx;
}

.modal-btn {
  flex: 1;
  height: 80rpx;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: $font-family-mono;
  font-size: 26rpx;
  letter-spacing: 2rpx;
  &:active { opacity: 0.8; }
}

.modal-btn-cancel {
  background: $page-background;
  border: 1rpx solid $line-sepia;
  color: $mute-text;
}

.modal-btn-confirm {
  background: $travel-blue;
  color: #F4EFE5;
}

.btm-gap { height: 120rpx; }
</style>

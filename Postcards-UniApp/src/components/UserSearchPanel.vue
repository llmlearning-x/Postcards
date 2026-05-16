<template>
  <view class="user-search-panel">
    <view class="search-bar">
      <IconSearch :size="16" color="#8A8070" />
      <input
        class="search-input"
        v-model="query"
        placeholder="输入 6 位邮箱号"
        placeholder-style="color:#B5AE9B"
        confirm-type="search"
        type="number"
        maxlength="6"
        @input="onInput"
      />
      <view v-if="query" class="search-clear" @click="clear">
        <IconX :size="14" color="#8A8070" />
      </view>
    </view>

    <view v-if="searching" class="search-hint">
      <text class="search-hint-txt">搜索中…</text>
    </view>
    <view v-else-if="!query" class="search-hint">
      <text class="search-hint-txt">{{ emptyHint }}</text>
    </view>
    <view v-else-if="!isValidMailboxNo(query)" class="search-hint">
      <text class="search-hint-txt">请输入 6 位数字</text>
    </view>
    <view v-else-if="errorMsg" class="search-hint">
      <text class="search-hint-txt">{{ errorMsg }}</text>
    </view>
    <view v-else-if="searched && results.length === 0" class="search-hint">
      <text class="search-hint-txt">未找到该邮箱号对应的用户</text>
    </view>

    <scroll-view v-else-if="results.length > 0" class="search-results" scroll-y>
      <view
        v-for="u in results"
        :key="u.id"
        class="result-row"
      >
        <view class="result-avatar">
          <image v-if="u.avatarUrl" :src="u.avatarUrl" class="avatar-img" mode="aspectFill" />
          <text v-else class="result-initial">{{ u.nickname.slice(0, 1) }}</text>
        </view>
        <view class="result-info">
          <text class="result-name">{{ u.nickname }}</text>
          <text class="result-mailbox">{{ u.mailboxNo }}</text>
        </view>
        <view
          class="result-action"
          :class="{ 'result-action-done': isDone(u.id) }"
          @click="selectUser(u)"
        >
          <text class="result-action-txt">{{ isDone(u.id) ? doneLabel : actionLabel }}</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { UserApi, type ApiUser } from '@/services/api'
import { IconSearch, IconX } from '@/components/icons'

const props = withDefaults(defineProps<{
  existingUserIds?: string[]
  actionLabel?: string
  doneLabel?: string
  emptyHint?: string
}>(), {
  existingUserIds: () => [],
  actionLabel: '选择',
  doneLabel: '已添加',
  emptyHint: '请输入对方的完整邮箱号，如 CN-123456',
})

const emit = defineEmits<{
  (e: 'select', user: ApiUser): void
}>()

const query     = ref('')
const searching = ref(false)
const searched  = ref(false)
const errorMsg  = ref('')
const results   = ref<ApiUser[]>([])
let timer: ReturnType<typeof setTimeout> | null = null

function isValidMailboxNo(s: string): boolean {
  return /^\d{6}$/.test(s.trim())
}

function isDone(id: string): boolean {
  return props.existingUserIds.includes(id)
}

function clear() {
  if (timer) clearTimeout(timer)
  query.value = ''
  results.value = []
  searched.value = false
  errorMsg.value = ''
}

function onInput() {
  if (timer) clearTimeout(timer)
  results.value = []
  searched.value = false
  errorMsg.value = ''

  if (!isValidMailboxNo(query.value)) return
  timer = setTimeout(search, 300)
}

async function search() {
  if (!isValidMailboxNo(query.value)) return
  searching.value = true
  errorMsg.value = ''
  try {
    results.value = await UserApi.search(query.value.trim())
  } catch (e: any) {
    results.value = []
    errorMsg.value = e.message || '搜索失败，请重试'
  } finally {
    searched.value = true
    searching.value = false
  }
}

function selectUser(user: ApiUser) {
  if (isDone(user.id)) return
  emit('select', user)
}

defineExpose({ clear })
</script>

<style lang="scss" scoped>
.user-search-panel {
  display: flex;
  flex-direction: column;
  min-height: 0;
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
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  background: transparent;
}

.search-clear {
  width: 40rpx;
  height: 40rpx;
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
  font-family: $font-family-body;
  font-size: 26rpx;
  color: $mute-text;
  font-style: italic;
  text-align: center;
  line-height: 1.5;
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
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $travel-blue, $forest-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  overflow: hidden;
}

.avatar-img {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
}

.result-initial {
  font-family: $font-family-body;
  font-size: 28rpx;
  color: #F4EFE5;
}

.result-info {
  flex: 1;
  min-width: 0;
}

.result-name {
  display: block;
  font-family: $font-family-body;
  font-size: 28rpx;
  color: $ink-black;
  margin-bottom: 4rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.result-mailbox {
  display: block;
  font-family: $font-family-code;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: $travel-blue;
}

.result-action {
  height: 56rpx;
  padding: 0 28rpx;
  background: $travel-blue;
  border-radius: 28rpx;
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.result-action:active {
  opacity: 0.8;
}

.result-action-done {
  background: transparent;
  border: 1rpx solid $line-sepia;
}

.result-action-txt {
  font-family: $font-family-action;
  font-size: 24rpx;
  letter-spacing: 0;
  color: #F4EFE5;
}

.result-action-done .result-action-txt {
  color: $mute-text;
}
</style>

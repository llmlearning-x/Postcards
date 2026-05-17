import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { StorageUtil } from '@/utils/storage'

export interface AuthUser {
  id: string
  nickname: string
  mailboxNo: string
  avatarUrl: string | null
  points: number
}

export interface StampUrlEntry {
  id: string
  imageUrl: string
}

// Series I stamp IDs — always free, used as fallback when stamps haven't been synced yet
export const FREE_STAMP_IDS = ['classic', 'nature', 'culture', 'city', 'ocean', 'sunset']

export const useAuthStore = defineStore('auth', () => {
  const user             = ref<AuthUser | null>(StorageUtil.get('auth_user', null))
  const token            = ref<string>(StorageUtil.get('auth_token', ''))
  const ownedStamps      = ref<string[]>(StorageUtil.get('auth_owned_stamps', []))
  const favoriteStampIds = ref<string[]>(StorageUtil.get('auth_fav_stamps', []))
  // 全量邮票列表（含服务端 imageUrl），和商店使用同一份数据
  const allStampUrls     = ref<StampUrlEntry[]>(StorageUtil.get('auth_stamp_urls', []))

  const isLoggedIn = computed(() => !!token.value && !!user.value)

  function setSession(u: AuthUser, accessToken: string, refreshToken: string) {
    user.value  = u
    token.value = accessToken
    StorageUtil.set('auth_user', u)
    StorageUtil.set('auth_token', accessToken)
    StorageUtil.set('auth_refresh', refreshToken)
  }

  function updateUser(patch: Partial<AuthUser>) {
    if (user.value) {
      user.value = { ...user.value, ...patch }
      StorageUtil.set('auth_user', user.value)
    }
  }

  function updatePoints(pts: number) {
    if (user.value) {
      user.value = { ...user.value, points: pts }
      StorageUtil.set('auth_user', user.value)
    }
  }

  function setOwnedStamps(ids: string[]) {
    ownedStamps.value = ids
    StorageUtil.set('auth_owned_stamps', ids)
  }

  function setAllStampUrls(stamps: { id: string; imageUrl: string | null }[]) {
    const entries = stamps
      .filter(s => s.imageUrl)
      .map(s => ({ id: s.id, imageUrl: s.imageUrl as string }))
    allStampUrls.value = entries
    StorageUtil.set('auth_stamp_urls', entries)
  }

  function addOwnedStamp(id: string) {
    if (!ownedStamps.value.includes(id)) {
      ownedStamps.value = [...ownedStamps.value, id]
      StorageUtil.set('auth_owned_stamps', ownedStamps.value)
    }
  }

  function toggleFavoriteStamp(id: string) {
    const next = favoriteStampIds.value.includes(id)
      ? favoriteStampIds.value.filter(s => s !== id)
      : [...favoriteStampIds.value, id]
    favoriteStampIds.value = next
    StorageUtil.set('auth_fav_stamps', next)
  }

  function logout() {
    user.value             = null
    token.value            = ''
    ownedStamps.value      = []
    favoriteStampIds.value = []
    allStampUrls.value     = []
    StorageUtil.remove('auth_user')
    StorageUtil.remove('auth_token')
    StorageUtil.remove('auth_refresh')
    StorageUtil.remove('auth_owned_stamps')
    StorageUtil.remove('auth_fav_stamps')
    StorageUtil.remove('auth_stamp_urls')
  }

  return {
    user, token, ownedStamps, favoriteStampIds, allStampUrls, isLoggedIn,
    setSession, updateUser, updatePoints, setAllStampUrls,
    setOwnedStamps, addOwnedStamp, toggleFavoriteStamp, logout,
  }
})

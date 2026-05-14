import { StorageUtil } from '@/utils/storage'
import { API_BASE_URL } from '@/config/env'

const API_BASE = API_BASE_URL || 'http://localhost:3000/api'
const REQUEST_TIMEOUT = 30000

function getToken(): string {
  return StorageUtil.get<string>('auth_token', '')
}

function getRefreshToken(): string {
  return StorageUtil.get<string>('auth_refresh', '')
}

function saveToken(token: string): void {
  StorageUtil.set('auth_token', token)
}

function clearAuthAndRedirect(): void {
  StorageUtil.remove('auth_user')
  StorageUtil.remove('auth_token')
  StorageUtil.remove('auth_refresh')
  StorageUtil.remove('auth_owned_stamps')
  uni.showToast({ title: '登录已过期，请重新登录', icon: 'none', duration: 2000 })
  setTimeout(() => {
    uni.reLaunch({ url: '/pages/auth/login' })
  }, 1500)
}

// ── Token refresh state ───────────────────────────────────────────
let isRefreshing = false
let refreshSubscribers: Array<(token: string) => void> = []

function subscribeRefresh(cb: (token: string) => void) {
  refreshSubscribers.push(cb)
}

function onRefreshed(newToken: string) {
  refreshSubscribers.forEach(cb => cb(newToken))
  refreshSubscribers = []
}

async function doRefresh(): Promise<string | null> {
  const refreshToken = getRefreshToken()
  if (!refreshToken) return null

  try {
    const res = await new Promise<any>((resolve, reject) => {
      uni.request({
        url: `${API_BASE}/auth/refresh`,
        method: 'POST',
        data: { refreshToken },
        header: { 'Content-Type': 'application/json' },
        timeout: REQUEST_TIMEOUT,
        success: (r) => resolve(r),
        fail: (err) => reject(new Error(err.errMsg || '网络连接失败')),
      })
    })

    if (res.statusCode >= 200 && res.statusCode < 300 && res.data?.accessToken) {
      saveToken(res.data.accessToken)
      return res.data.accessToken as string
    }
    return null
  } catch {
    return null
  }
}

// ── Core request wrapper ──────────────────────────────────────────
function request<T>(method: string, path: string, data?: unknown, retry = true): Promise<T> {
  const token = getToken()

  return new Promise((resolve, reject) => {
    uni.request({
      url: `${API_BASE}${path}`,
      method: method as any,
      data: data as any,
      header: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      timeout: REQUEST_TIMEOUT,
      success: async (res) => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(res.data as T)
          return
        }

        // 401 — attempt token refresh once
        if (res.statusCode === 401 && retry) {
          if (isRefreshing) {
            // Queue this request until refresh completes
            subscribeRefresh((newToken) => {
              request<T>(method, path, data, false)
                .then(resolve)
                .catch(reject)
            })
            return
          }

          isRefreshing = true
          const newToken = await doRefresh()
          isRefreshing = false

          if (newToken) {
            onRefreshed(newToken)
            // Retry original request with new token (no further refresh)
            request<T>(method, path, data, false)
              .then(resolve)
              .catch(reject)
            return
          }

          // Refresh failed — clear auth and redirect
          onRefreshed('')
          clearAuthAndRedirect()
          reject(new Error('登录已过期'))
          return
        }

        const msg = (res.data as any)?.error || `HTTP ${res.statusCode}`
        reject(new Error(msg))
      },
      fail: (err) => reject(new Error(err.errMsg || '网络连接失败')),
    })
  })
}

// ── Auth ──────────────────────────────────────────────────────────
export interface ApiUser {
  id: string
  nickname: string
  mailboxNo: string
  avatarUrl: string | null
  createdAt?: number
}

export interface AuthResponse {
  accessToken: string
  refreshToken: string
  user: ApiUser
}

export const AuthApi = {
  register: (nickname: string, password: string) =>
    request<AuthResponse>('POST', '/auth/register', { nickname, password }),
  login: (mailboxNo: string, password: string) =>
    request<AuthResponse>('POST', '/auth/login', { mailboxNo, password }),
  refresh: (refreshToken: string) =>
    request<{ accessToken: string }>('POST', '/auth/refresh', { refreshToken }),
}

// ── User ──────────────────────────────────────────────────────────
export const UserApi = {
  me: () => request<ApiUser>('GET', '/users/me'),
  update: (data: { nickname?: string; avatarUrl?: string; pushToken?: string }) =>
    request<ApiUser>('PUT', '/users/me', data),
  search: (q: string) => {
    const params = new URLSearchParams({ q })
    return request<ApiUser[]>('GET', `/users/search?${params.toString()}`)
  },
}

// ── Travels ───────────────────────────────────────────────────────
export interface TravelDto {
  id: string
  title: string
  destination: string
  startDate: number
  endDate: number
  note: string
  isCurrent: boolean
  createdAt: number
}

export const TravelApi = {
  list: (since?: number) => {
    const params = new URLSearchParams()
    if (since) params.append('since', String(since))
    const qs = params.toString()
    return request<TravelDto[]>('GET', qs ? `/travels?${qs}` : '/travels')
  },
  create: (data: Omit<TravelDto, 'id' | 'createdAt'>) =>
    request<TravelDto>('POST', '/travels', data),
  update: (id: string, data: Partial<Omit<TravelDto, 'id' | 'createdAt'>>) =>
    request<TravelDto>('PUT', `/travels/${id}`, data),
  remove: (id: string) => request<void>('DELETE', `/travels/${id}`),
}

// ── Postcards ─────────────────────────────────────────────────────
export interface PostcardDto {
  id: string
  travelId: string
  photoUrl: string | null
  locationName: string
  city: string
  country: string
  note: string
  stampDesign: string
  isFavorite: boolean
  recordedAt: number
  createdAt: number
}

export const PostcardApi = {
  list: (since?: number) => {
    const params = new URLSearchParams()
    if (since) params.append('since', String(since))
    const qs = params.toString()
    return request<PostcardDto[]>('GET', qs ? `/postcards?${qs}` : '/postcards')
  },
  create: (data: Omit<PostcardDto, 'id' | 'createdAt'>) =>
    request<PostcardDto>('POST', '/postcards', data),
  update: (id: string, data: Partial<Omit<PostcardDto, 'id' | 'createdAt'>>) =>
    request<PostcardDto>('PUT', `/postcards/${id}`, data),
  remove: (id: string) => request<void>('DELETE', `/postcards/${id}`),
}

// ── Mailings ──────────────────────────────────────────────────────
export interface MailingItem {
  id: string
  postcardId: string
  personalNote: string | null
  snapshot: {
    photoUrl: string | null
    locationName: string
    city: string
    country: string
    note: string
    stampDesign: string
    recordedAt: number
    sender: { id: string; nickname: string; mailboxNo: string; avatarUrl: string | null }
  }
  status: 'pending' | 'sent' | 'delivered' | 'opened'
  sentAt: number
  openedAt: number | null
  sender: { id: string; nickname: string; mailboxNo: string; avatarUrl: string | null }
}

export interface InboxResponse {
  unreadCount: number
  items: MailingItem[]
}

export const MailApi = {
  send: (postcardId: string, recipientId: string, personalNote?: string) =>
    request<{ success: boolean; mailingId: string }>('POST', '/mailings', { postcardId, recipientId, personalNote }),
  inbox: () => request<InboxResponse>('GET', '/mailings/inbox'),
  sent: () => request<MailingItem[]>('GET', '/mailings/sent'),
  open: (id: string) => request<void>('PUT', `/mailings/${id}/open`),
}

// ── Stamps ────────────────────────────────────────────────────────
export interface StampItem {
  id: string
  name: string
  series: string
  seriesName: string
  color: string
  imageUrl: string | null
  price: number
  isFree: boolean
  isOwned: boolean
}

export const StampApi = {
  all:    ()         => request<StampItem[]>('GET', '/stamps'),
  my:     ()         => request<StampItem[]>('GET', '/stamps/my'),
  unlock: (id: string) =>
    request<{ success: boolean; points: number; stampId: string }>('POST', `/stamps/${id}/unlock`),
}

// ── Points ────────────────────────────────────────────────────────
export interface PointsState {
  points: number
  log: Array<{ delta: number; reason: string; createdAt: number }>
}

export const PointsApi = {
  me:    () => request<PointsState>('GET', '/points/me'),
  daily: () => request<{ points: number; delta: number }>('POST', '/points/daily'),
}

// ── Contacts ──────────────────────────────────────────────────────
export interface ContactItem {
  id: string
  remarkName: string | null
  contactId: string
  nickname: string
  mailboxNo: string
  avatarUrl: string | null
  mailCount: number
  createdAt: number
}

export const ContactsApi = {
  list: () => request<ContactItem[]>('GET', '/contacts'),
}

// ── Upload ────────────────────────────────────────────────────────
export const UploadApi = {
  image: (filePath: string): Promise<{ url: string }> => {
    const token = getToken()
    return new Promise((resolve, reject) => {
      uni.uploadFile({
        url: `${API_BASE}/upload/image`,
        filePath,
        name: 'file',
        header: token ? { Authorization: `Bearer ${token}` } : {},
        timeout: REQUEST_TIMEOUT,
        success: (res) => {
          if (res.statusCode < 200 || res.statusCode >= 300) {
            reject(new Error(`上传失败: HTTP ${res.statusCode}`))
            return
          }
          try {
            const data = JSON.parse(res.data as string)
            if (data.url) resolve(data)
            else reject(new Error(data.error || '上传失败'))
          } catch {
            reject(new Error('上传响应解析失败'))
          }
        },
        fail: (err) => reject(new Error(err.errMsg || '上传失败')),
      })
    })
  },
}

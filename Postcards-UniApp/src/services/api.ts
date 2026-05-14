import { StorageUtil } from '@/utils/storage'

export const API_BASE = 'http://115.175.15.145/api'

function getToken(): string {
  return StorageUtil.get<string>('auth_token', '')
}

function request<T>(method: string, path: string, data?: unknown): Promise<T> {
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
      success: (res) => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(res.data as T)
        } else {
          const msg = (res.data as any)?.error || `HTTP ${res.statusCode}`
          reject(new Error(msg))
        }
      },
      fail: (err) => reject(new Error(err.errMsg || '网络连接失败')),
    })
  })
}

// ── Auth ────────────────────────────────────────────────────────
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

// ── User ────────────────────────────────────────────────────────
export const UserApi = {
  me: () => request<ApiUser>('GET', '/users/me'),
  update: (data: { nickname?: string; avatarUrl?: string; pushToken?: string }) =>
    request<ApiUser>('PUT', '/users/me', data),
  search: (q: string) =>
    request<ApiUser[]>('GET', `/users/search?q=${encodeURIComponent(q)}`),
}

// ── Travels ─────────────────────────────────────────────────────
export const TravelApi = {
  list: (since?: number) =>
    request<any[]>('GET', since ? `/travels?since=${since}` : '/travels'),
  create: (data: any) => request<any>('POST', '/travels', data),
  update: (id: string, data: any) => request<any>('PUT', `/travels/${id}`, data),
  remove: (id: string) => request<void>('DELETE', `/travels/${id}`),
}

// ── Postcards ────────────────────────────────────────────────────
export const PostcardApi = {
  list: (since?: number) =>
    request<any[]>('GET', since ? `/postcards?since=${since}` : '/postcards'),
  create: (data: any) => request<any>('POST', '/postcards', data),
  update: (id: string, data: any) => request<any>('PUT', `/postcards/${id}`, data),
  remove: (id: string) => request<void>('DELETE', `/postcards/${id}`),
}

// ── Mailings ─────────────────────────────────────────────────────
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
  status: string
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
    request<any>('POST', '/mailings', { postcardId, recipientId, personalNote }),
  inbox: () => request<InboxResponse>('GET', '/mailings/inbox'),
  sent: () => request<any[]>('GET', '/mailings/sent'),
  open: (id: string) => request<void>('PUT', `/mailings/${id}/open`),
}

// ── Stamps ───────────────────────────────────────────────────────
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

// ── Points ───────────────────────────────────────────────────────
export interface PointsState {
  points: number
  log: Array<{ delta: number; reason: string; createdAt: number }>
}

export const PointsApi = {
  me:    () => request<PointsState>('GET', '/points/me'),
  daily: () => request<{ points: number; delta: number }>('POST', '/points/daily'),
}

// ── Contacts ─────────────────────────────────────────────────────
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

// ── Upload ───────────────────────────────────────────────────────
export const UploadApi = {
  image: (filePath: string): Promise<{ url: string }> => {
    const token = getToken()
    return new Promise((resolve, reject) => {
      uni.uploadFile({
        url: `${API_BASE}/upload/image`,
        filePath,
        name: 'file',
        header: { Authorization: `Bearer ${token}` },
        success: (res) => {
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

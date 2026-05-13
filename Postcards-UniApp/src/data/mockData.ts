import type { Travel } from '@/model/Travel'
import { TravelStatus } from '@/model/Travel'
import type { Postcard } from '@/model/Postcard'

const now = Date.now()
const day = 24 * 60 * 60 * 1000

export const mockTravels: Travel[] = [
  {
    id: 'travel-1',
    title: '江南水乡之旅',
    destination: '杭州',
    startDate: now - 5 * day,
    endDate: now + 2 * day,
    createdAt: now - 7 * day,
    status: TravelStatus.ONGOING,
    isCurrent: true,
    description: '探索江南美景'
  },
  {
    id: 'travel-2',
    title: '西北风光行',
    destination: '敦煌',
    startDate: now - 30 * day,
    endDate: now - 23 * day,
    createdAt: now - 35 * day,
    status: TravelStatus.COMPLETED,
    isCurrent: false,
    description: '丝绸之路的记忆'
  },
  {
    id: 'travel-3',
    title: '山城重庆',
    destination: '重庆',
    startDate: now - 60 * day,
    endDate: now - 54 * day,
    createdAt: now - 65 * day,
    status: TravelStatus.COMPLETED,
    isCurrent: false,
    description: '火锅与夜景'
  },
  {
    id: 'travel-4',
    title: '彩云之南',
    destination: '丽江',
    startDate: now + 15 * day,
    endDate: now + 22 * day,
    createdAt: now - 2 * day,
    status: TravelStatus.PLANNED,
    isCurrent: false,
    description: '期待的旅程'
  }
]

export const mockPostcards: Postcard[] = [
  {
    id: 'card-1',
    travelId: 'travel-1',
    photoUrl: 'https://images.unsplash.com/photo-1598865049044-9a51131622d1?w=800&q=80',
    locationName: '西湖断桥',
    city: '杭州',
    country: '中国',
    note: '断桥不断，情意绵绵',
    stampDesign: 'classic',
    isFavorite: true,
    recordedAt: now - 4 * day,
    createdAt: now - 4 * day
  },
  {
    id: 'card-2',
    travelId: 'travel-1',
    photoUrl: 'https://images.unsplash.com/photo-1588252910189-9c9f5535646b?w=800&q=80',
    locationName: '雷峰塔',
    city: '杭州',
    country: '中国',
    note: '白娘子的传说',
    stampDesign: 'nature',
    isFavorite: true,
    recordedAt: now - 3 * day,
    createdAt: now - 3 * day
  },
  {
    id: 'card-3',
    travelId: 'travel-1',
    photoUrl: 'https://images.unsplash.com/photo-1578762857609-6ffbcb8b4642?w=800&q=80',
    locationName: '灵隐寺',
    city: '杭州',
    country: '中国',
    note: '深山藏古寺',
    stampDesign: 'culture',
    isFavorite: false,
    recordedAt: now - 2 * day,
    createdAt: now - 2 * day
  },
  {
    id: 'card-4',
    travelId: 'travel-2',
    photoUrl: 'https://images.unsplash.com/photo-1545145313-113695546321?w=800&q=80',
    locationName: '莫高窟',
    city: '敦煌',
    country: '中国',
    note: '千年壁画，艺术瑰宝',
    stampDesign: 'culture',
    isFavorite: true,
    recordedAt: now - 29 * day,
    createdAt: now - 29 * day
  },
  {
    id: 'card-5',
    travelId: 'travel-2',
    photoUrl: 'https://images.unsplash.com/photo-1542401886-65d6c61db217?w=800&q=80',
    locationName: '鸣沙山',
    city: '敦煌',
    country: '中国',
    note: '沙漠中的歌声',
    stampDesign: 'nature',
    isFavorite: true,
    recordedAt: now - 28 * day,
    createdAt: now - 28 * day
  },
  {
    id: 'card-6',
    travelId: 'travel-2',
    photoUrl: 'https://images.unsplash.com/photo-1665991063977-402ae7450de7?w=800&q=80',
    locationName: '月牙泉',
    city: '敦煌',
    country: '中国',
    note: '沙漠中的绿洲',
    stampDesign: 'nature',
    isFavorite: false,
    recordedAt: now - 27 * day,
    createdAt: now - 27 * day
  },
  {
    id: 'card-7',
    travelId: 'travel-3',
    photoUrl: 'https://images.unsplash.com/photo-1581252584837-95f73fd23574?w=800&q=80',
    locationName: '洪崖洞',
    city: '重庆',
    country: '中国',
    note: '千与千寻的世界',
    stampDesign: 'city',
    isFavorite: true,
    recordedAt: now - 59 * day,
    createdAt: now - 59 * day
  },
  {
    id: 'card-8',
    travelId: 'travel-3',
    photoUrl: 'https://images.unsplash.com/photo-1627727240288-71c6b9ae5ee6?w=800&q=80',
    locationName: '长江索道',
    city: '重庆',
    country: '中国',
    note: '空中看山城',
    stampDesign: 'city',
    isFavorite: false,
    recordedAt: now - 58 * day,
    createdAt: now - 58 * day
  },
  {
    id: 'card-9',
    travelId: 'travel-3',
    photoUrl: 'https://images.unsplash.com/photo-1663609968423-657ff4f0dd5a?w=800&q=80',
    locationName: '磁器口古镇',
    city: '重庆',
    country: '中国',
    note: '老重庆的味道',
    stampDesign: 'culture',
    isFavorite: true,
    recordedAt: now - 57 * day,
    createdAt: now - 57 * day
  }
]

// 应用配置
export const AppConfig = {
  name: '远方邮政',
  version: '1.0.0',
  storageKeys: {
    TRAVELS: 'postcards_travels',
    POSTCARDS: 'postcards_postcards',
    USER_SETTINGS: 'postcards_user_settings',
  },
  maxImageSize: 5 * 1024 * 1024, // 5MB
  defaultCountry: '中国',
  defaultLanguage: 'zh-CN',
} as const

// Toast 消息配置
export const ToastMessages = {
  success: {
    save: '保存成功',
    delete: '删除成功',
    favorite: '收藏已更新',
    location: '位置获取成功',
    image: '图片选择成功',
  },
  error: {
    save: '保存失败，请重试',
    delete: '删除失败，请重试',
    location: '位置获取失败',
    image: '图片选择失败',
    network: '网络错误，请检查网络',
    permission: '请授予相关权限',
  },
  confirm: {
    delete: '确定要删除吗？此操作不可恢复',
    leave: '确定要离开吗？未保存内容将丢失',
  },
} as const

// 邮票样式配置
export const StampDesigns = [
  { id: 'classic', name: '经典', icon: 'stampClassic', color: '#C41E3A' },
  { id: 'nature', name: '自然', icon: 'stampNature', color: '#2E7D58' },
  { id: 'culture', name: '文化', icon: 'stampCulture', color: '#7C3AED' },
  { id: 'city', name: '城市', icon: 'stampCity', color: '#2563EB' },
  { id: 'sea', name: '海洋', icon: 'stampSea', color: '#0EA5E9' },
  { id: 'sunset', name: '日落', icon: 'stampSunset', color: '#F97316' },
] as const

// Mock 图片数据 - 全部来自 Unsplash 开源图库 (CC0 License)
// 按城市/景点真实场景匹配，禁止 emoji，企业级产品规范
export const MockImages = {
  postcards: [
    // 杭州
    'https://images.unsplash.com/photo-1598865049044-9a51131622d1?w=800&q=80', // 西湖断桥
    'https://images.unsplash.com/photo-1588252910189-9c9f5535646b?w=800&q=80', // 雷峰塔
    'https://images.unsplash.com/photo-1578762857609-6ffbcb8b4642?w=800&q=80', // 灵隐寺
    // 敦煌
    'https://images.unsplash.com/photo-1545145313-113695546321?w=800&q=80', // 莫高窟
    'https://images.unsplash.com/photo-1542401886-65d6c61db217?w=800&q=80', // 鸣沙山
    'https://images.unsplash.com/photo-1665991063977-402ae7450de7?w=800&q=80', // 月牙泉
    // 重庆
    'https://images.unsplash.com/photo-1581252584837-95f73fd23574?w=800&q=80', // 洪崖洞
    'https://images.unsplash.com/photo-1627727240288-71c6b9ae5ee6?w=800&q=80', // 长江索道
    'https://images.unsplash.com/photo-1663609968423-657ff4f0dd5a?w=800&q=80', // 磁器口古镇
  ],
  avatars: [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
  ],
} as const
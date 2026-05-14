// 应用配置
export const AppConfig = {
  name: '旅行邮局',
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

// 邮票样式配置 — 4 系列 · 20 款（复古印刷色调）
// imageUrl: 邮票图案图片，留空时前端用符号占位，图片由后端 stamp_designs 表管理
export const StampDesigns = [
  // Series I · 旅行 TRAVEL
  { id: 'classic',     name: '经典', series: 'I',   seriesName: '旅行', color: '#A43B2D', imageUrl: '' },
  { id: 'nature',      name: '自然', series: 'I',   seriesName: '旅行', color: '#3C604D', imageUrl: '' },
  { id: 'culture',     name: '文化', series: 'I',   seriesName: '旅行', color: '#5B4F76', imageUrl: '' },
  { id: 'city',        name: '城市', series: 'I',   seriesName: '旅行', color: '#1F4B66', imageUrl: '' },
  { id: 'ocean',       name: '海洋', series: 'I',   seriesName: '旅行', color: '#3A7791', imageUrl: '' },
  { id: 'sunset',      name: '日落', series: 'I',   seriesName: '旅行', color: '#C4753A', imageUrl: '' },
  // Series II · 古迹 HERITAGE
  { id: 'greatwall',   name: '长城', series: 'II',  seriesName: '古迹', color: '#7A7264', imageUrl: '' },
  { id: 'terracotta',  name: '兵马俑', series: 'II', seriesName: '古迹', color: '#9C6240', imageUrl: '' },
  { id: 'pagoda',      name: '古塔', series: 'II',  seriesName: '古迹', color: '#8B5030', imageUrl: '' },
  { id: 'garden',      name: '苏园', series: 'II',  seriesName: '古迹', color: '#3E7058', imageUrl: '' },
  { id: 'canal',       name: '水乡', series: 'II',  seriesName: '古迹', color: '#3B5E7A', imageUrl: '' },
  // Series III · 四季 SEASONS
  { id: 'spring',      name: '春樱', series: 'III', seriesName: '四季', color: '#B26573', imageUrl: '' },
  { id: 'summer',      name: '夏荷', series: 'III', seriesName: '四季', color: '#2F6E5E', imageUrl: '' },
  { id: 'autumn',      name: '秋枫', series: 'III', seriesName: '四季', color: '#B25A30', imageUrl: '' },
  { id: 'winter',      name: '冬雪', series: 'III', seriesName: '四季', color: '#6A85A0', imageUrl: '' },
  // Series IV · 节气 SOLAR TERMS
  { id: 'lichun',      name: '立春', series: 'IV',  seriesName: '节气', color: '#6B8E4E', imageUrl: '' },
  { id: 'qingming',    name: '清明', series: 'IV',  seriesName: '节气', color: '#7B946F', imageUrl: '' },
  { id: 'xiazhi',      name: '夏至', series: 'IV',  seriesName: '节气', color: '#C49432', imageUrl: '' },
  { id: 'liqiu',       name: '立秋', series: 'IV',  seriesName: '节气', color: '#9C6F2B', imageUrl: '' },
  { id: 'shuangjiang', name: '霜降', series: 'IV',  seriesName: '节气', color: '#7E97A8', imageUrl: '' },
  { id: 'dahan',       name: '大寒', series: 'IV',  seriesName: '节气', color: '#3D5266', imageUrl: '' },
  // Series V · 远方 FAR LANDS
  { id: 'prairie',     name: '草原', series: 'V',   seriesName: '远方', color: '#7A8540', imageUrl: '' },
  { id: 'snowpeak',    name: '雪山', series: 'V',   seriesName: '远方', color: '#5A7585', imageUrl: '' },
  { id: 'desert',      name: '沙漠', series: 'V',   seriesName: '远方', color: '#B07A3E', imageUrl: '' },
  { id: 'island',      name: '海岛', series: 'V',   seriesName: '远方', color: '#2E7689', imageUrl: '' },
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
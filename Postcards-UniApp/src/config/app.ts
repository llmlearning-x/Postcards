// 应用配置
export const AppConfig = {
  name: '旅行邮箱',
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

// 邮票样式配置 — 5 系列（复古印刷色调）
// imagePath: 相对于 STAMPS_BASE_URL 的路径，与服务器 STAMP_IMAGE_PATHS 保持同步
export const StampDesigns = [
  // Series I · 旅行 TRAVEL
  { id: 'classic',     name: '经典',   series: 'I',   seriesName: '旅行', color: '#A43B2D', imagePath: 'serie-i-travel/classic-stamp-art.png',                  description: '旅行的原点。一张邮票，寄出万里。以复古印刷质感致敬最初出发的那一刻，也致敬每一封寄往远方的信。' },
  { id: 'nature',      name: '自然',   series: 'I',   seriesName: '旅行', color: '#3C604D', imagePath: 'serie-i-travel/nature-stamp-art.png',                   description: '山河草木皆是远方。设计取意原野与森林，以墨绿沉淀自然的呼吸，记录脚踏土地时的宁静与辽阔。' },
  { id: 'culture',     name: '文化',   series: 'I',   seriesName: '旅行', color: '#5B4F76', imagePath: 'serie-i-travel/culture-stamp-art.png',                  description: '人文积淀，文明印记，跨越千年。深紫色调源自古典印章，提醒旅行者在每座城市寻找时间留下的痕迹。' },
  { id: 'city',        name: '城市',   series: 'I',   seriesName: '旅行', color: '#1F4B66', imagePath: 'serie-i-travel/city-stamp-art.png',                     description: '都市脉络，灯光如海，时代律动。以深蓝捕捉城市夜晚的节奏，记录那些霓虹与阴影交织的都市街头。' },
  { id: 'ocean',       name: '海洋',   series: 'I',   seriesName: '旅行', color: '#3A7791', imagePath: 'serie-i-travel/ocean-stamp-art.png',                    description: '碧海无涯，潮声入信，寄往天边。海洋蓝的深邃让每一张明信片都带着浪的气息，飘向世界另一端。' },
  { id: 'sunset',      name: '日落',   series: 'I',   seriesName: '旅行', color: '#C4753A', imagePath: 'serie-i-travel/sunset-stamp-art.png',                   description: '余晖入境，黄金时刻，此刻永恒。暖橙色调捕捉一天中最后的光，以邮票的形式将黄昏永远留住。' },
  // Series II · 古迹 HERITAGE
  { id: 'greatwall',   name: '长城',   series: 'II',  seriesName: '古迹', color: '#7A7264', imagePath: 'serie-ii-heritage/greatwall-stamp-art.png',             description: '万里长城，砖瓦之间，铭刻岁月。每一块砖都是一段故事，以石灰灰调重现历史的厚重与绵延不绝。' },
  { id: 'terracotta',  name: '兵马俑', series: 'II',  seriesName: '古迹', color: '#9C6240', imagePath: 'serie-ii-heritage/terracotta-stamp-art.png',            description: '兵马俑前，千年沉默，历史开口。陶土赤褐源自秦俑本色，每一张邮票都是对那场地下王国的致敬。' },
  { id: 'pagoda',      name: '古塔',   series: 'II',  seriesName: '古迹', color: '#8B5030', imagePath: 'serie-ii-heritage/pagoda-stamp-art.png',                description: '古塔凌云，晨钟暮鼓，时光轮转。砖红色彩取自佛塔的土烧气质，承载着千年香火与时间的重量。' },
  { id: 'garden',      name: '苏园',   series: 'II',  seriesName: '古迹', color: '#3E7058', imagePath: 'serie-ii-heritage/garden-stamp-art.png',                description: '苏园精妙，窗含秀色，小中见大。以深翠复刻江南园林的层叠之美，一砖一瓦皆是匠心所在。' },
  { id: 'canal',       name: '水乡',   series: 'II',  seriesName: '古迹', color: '#3B5E7A', imagePath: 'serie-ii-heritage/canal-stamp-art.png',                 description: '水乡清晨，船橹声声，江南如梦。以水蓝灰调描摹乌镇、西塘清晨的薄雾与倒影，梦境般宁静。' },
  // Series III · 四季 SEASONS
  { id: 'spring',      name: '春樱',   series: 'III', seriesName: '四季', color: '#B26573', imagePath: 'serie-iii-seasons/spring-cherry-stamp-art.png',         description: '樱雪纷飞，春风十里，花信传书。玫瑰粉调取自樱花盛开时最饱满的一刻，转瞬即逝，因此更值得珍藏。' },
  { id: 'summer',      name: '夏荷',   series: 'III', seriesName: '四季', color: '#2F6E5E', imagePath: 'serie-iii-seasons/summer-lotus-stamp-art.png',          description: '夏荷绽放，蛙鸣蝉噪，暑意渐浓。荷叶深绿捕捉盛夏荷塘的生机，也寄出那些潮湿而美好的记忆。' },
  { id: 'autumn',      name: '秋枫',   series: 'III', seriesName: '四季', color: '#B25A30', imagePath: 'serie-iii-seasons/autumn-maple-stamp-art.png',          description: '红枫似火，秋风送爽，远山层染。深橙赤调复刻枫林深处的燃烧时刻，寄出秋天最浓烈的温柔。' },
  { id: 'winter',      name: '冬雪',   series: 'III', seriesName: '四季', color: '#6A85A0', imagePath: 'serie-iii-seasons/winter-snow-stamp-art.png',           description: '白雪无声，万籁俱寂，寒中见暖。蓝灰调如同清晨第一眼看见雪后世界——一切静止，一切清明。' },
  // Series IV · 节气 SOLAR TERMS
  { id: 'lichun',      name: '立春',   series: 'IV',  seriesName: '节气', color: '#6B8E4E', imagePath: 'serie-iv-solar-terms/lichun-stamp-art.png',             description: '东风解冻，土脉初动，立春一刻。嫩绿取意万物破土前的蓄势，新年的第一个节气，万事皆可重来。' },
  { id: 'qingming',    name: '清明',   series: 'IV',  seriesName: '节气', color: '#7B946F', imagePath: 'serie-iv-solar-terms/qingming-stamp-art.png',           description: '草色烟光，细雨霏霏，清明时节。灰绿如同清明前后的天色，悲喜交织，思念与新生同在。' },
  { id: 'xiazhi',      name: '夏至',   series: 'IV',  seriesName: '节气', color: '#C49432', imagePath: 'serie-iv-solar-terms/xiazhi-stamp-art.png',             description: '日长至极，蝉声声声，夏至正午。金黄取自一年中日照最长时刻的阳光质感，充盈而炽热。' },
  { id: 'liqiu',       name: '立秋',   series: 'IV',  seriesName: '节气', color: '#9C6F2B', imagePath: 'serie-iv-solar-terms/liqiu-stamp-art.png',              description: '秋意初至，禾谷成熟，天地转凉。琥珀调源自立秋时节稻穗低垂的颜色，丰收与告别同步降临。' },
  { id: 'shuangjiang', name: '霜降',   series: 'IV',  seriesName: '节气', color: '#7E97A8', imagePath: 'serie-iv-solar-terms/shuangjiang-stamp-art.png',        description: '霜花铺地，枫叶渐红，霜降之晨。蓝灰如同第一层薄霜，冷冽而纯净，让人想起深秋清晨的呼吸。' },
  { id: 'dahan',       name: '大寒',   series: 'IV',  seriesName: '节气', color: '#3D5266', imagePath: 'serie-iv-solar-terms/dahan-stamp-art.png',              description: '岁末寒深，腊梅独放，大寒将尽。深靛蓝取意冬至后最寒冷的节气，凛冽之中孕育着春的转机。' },
  // Series V · 远方 FAR LANDS
  { id: 'prairie',     name: '草原',   series: 'V',   seriesName: '远方', color: '#7A8540', imagePath: 'serie-v-faraway/grassland-stamp-art.png',               description: '天苍苍，野茫茫，风吹草低见牛羊。黄绿调取意草原最壮阔的季节，辽阔到无法用语言描述的远方。' },
  { id: 'snowpeak',    name: '雪山',   series: 'V',   seriesName: '远方', color: '#5A7585', imagePath: 'serie-v-faraway/snow-mountain-stamp-art.png',           description: '雪峰刺云，万古不化，此刻凝望。蓝灰如同仰望雪山时天空与冰川的交界，渺小感与崇高感同时涌现。' },
  { id: 'desert',      name: '沙漠',   series: 'V',   seriesName: '远方', color: '#B07A3E', imagePath: 'serie-v-faraway/desert-stamp-art.png',                  description: '黄沙千里，驼铃悠远，沙漠入信。暖沙棕色取自正午沙丘最饱和的色温，炙热而宁静，遥远而真实。' },
  { id: 'island',      name: '海岛',   series: 'V',   seriesName: '远方', color: '#2E7689', imagePath: 'serie-v-faraway/island-stamp-art.png',                  description: '碧浪涌岛，椰风送爽，海天之际。深青蓝取意热带岛屿海水的纯净，让每张明信片都带着海盐的气息。' },
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
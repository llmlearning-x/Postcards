import { config } from '../config'

const STAMP_IMAGE_PATHS: Record<string, string> = {
  // Series I · 旅行
  classic:  'serie-i-travel/classic-stamp-art.png',
  nature:   'serie-i-travel/nature-stamp-art.png',
  culture:  'serie-i-travel/culture-stamp-art.png',
  city:     'serie-i-travel/city-stamp-art.png',
  ocean:    'serie-i-travel/ocean-stamp-art.png',
  sunset:   'serie-i-travel/sunset-stamp-art.png',
  // Series II · 古迹
  greatwall:  'serie-ii-heritage/greatwall-stamp-art.png',
  terracotta: 'serie-ii-heritage/terracotta-stamp-art.png',
  pagoda:     'serie-ii-heritage/pagoda-stamp-art.png',
  garden:     'serie-ii-heritage/garden-stamp-art.png',
  canal:      'serie-ii-heritage/canal-stamp-art.png',
  // Series III · 四季
  spring: 'serie-iii-seasons/spring-cherry-stamp-art.png',
  summer: 'serie-iii-seasons/summer-lotus-stamp-art.png',
  autumn: 'serie-iii-seasons/autumn-maple-stamp-art.png',
  winter: 'serie-iii-seasons/winter-snow-stamp-art.png',
  // Series IV · 节气
  lichun:      'serie-iv-solar-terms/lichun-stamp-art.png',
  qingming:    'serie-iv-solar-terms/qingming-stamp-art.png',
  xiazhi:      'serie-iv-solar-terms/xiazhi-stamp-art.png',
  liqiu:       'serie-iv-solar-terms/liqiu-stamp-art.png',
  shuangjiang: 'serie-iv-solar-terms/shuangjiang-stamp-art.png',
  dahan:       'serie-iv-solar-terms/dahan-stamp-art.png',
  // Series V · 远方
  prairie:  'serie-v-faraway/grassland-stamp-art.png',
  snowpeak: 'serie-v-faraway/snow-mountain-stamp-art.png',
  desert:   'serie-v-faraway/desert-stamp-art.png',
  island:   'serie-v-faraway/island-stamp-art.png',
}

export function resolveStampImageUrl(id: string, dbImageUrl: string | null): string {
  if (dbImageUrl) return dbImageUrl
  const path = STAMP_IMAGE_PATHS[id]
  if (!path) return ''
  const base = config.stamps.baseUrl.replace(/\/$/, '')
  return `${base}/${path}`
}

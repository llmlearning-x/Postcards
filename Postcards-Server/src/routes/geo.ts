import { FastifyInstance } from 'fastify'
import { requireAuth } from '../middleware/auth'
import https from 'https'

function httpsGet(url: string): Promise<any> {
  return new Promise((resolve, reject) => {
    const req = https.get(url, { headers: { 'User-Agent': 'PostcardsApp/1.0' } }, (res) => {
      let body = ''
      res.on('data', (chunk) => body += chunk)
      res.on('end', () => {
        try { resolve(JSON.parse(body)) } catch { reject(new Error('解析失败')) }
      })
    })
    req.on('error', reject)
    req.setTimeout(8000, () => { req.destroy(); reject(new Error('超时')) })
  })
}

function amapFetch(lat: number, lon: number, key: string): Promise<any> {
  return new Promise((resolve, reject) => {
    // 高德接口要求 location=lon,lat 顺序，coordsys=gps 接受 WGS-84
    const url = `https://restapi.amap.com/v3/geocode/regeo?key=${key}&location=${lon},${lat}&coordsys=gps&extensions=base&radius=100`
    const req = https.get(url, { headers: { 'User-Agent': 'PostcardsApp/1.0' } }, (res) => {
      let body = ''
      res.on('data', (chunk) => body += chunk)
      res.on('end', () => {
        try { resolve(JSON.parse(body)) } catch { reject(new Error('解析失败')) }
      })
    })
    req.on('error', reject)
    req.setTimeout(8000, () => { req.destroy(); reject(new Error('超时')) })
  })
}

export async function geoRoutes(app: FastifyInstance) {

  // GET /geo/reverse?lat=...&lon=... — 逆地理编码，返回中文地名
  app.get('/geo/reverse', { preHandler: requireAuth }, async (req, reply) => {
    const { lat, lon } = req.query as { lat?: string; lon?: string }
    const latN = parseFloat(lat ?? '')
    const lonN = parseFloat(lon ?? '')

    if (isNaN(latN) || isNaN(lonN)) {
      return reply.code(400).send({ error: '无效坐标' })
    }

    const key = process.env.AMAP_KEY
    if (!key) {
      return reply.code(503).send({ error: '地理编码服务未配置' })
    }

    try {
      const data = await amapFetch(latN, lonN, key)
      if (data.status !== '1') {
        return reply.code(502).send({ error: '地理编码服务异常', detail: data.info })
      }

      const comp = data.regeocode?.addressComponent ?? {}

      // 直辖市（北京/上海/天津/重庆）city 字段是空数组，回退到 province
      const cityRaw: string = Array.isArray(comp.city) ? (comp.province ?? '') : (comp.city ?? comp.province ?? '')
      const city = cityRaw.replace(/市$/, '') || '未知城市'

      // 地点名：街道 > 乡镇 > 区县
      const street   = comp.streetNumber?.street ?? ''
      const township = comp.township ?? ''
      const district = comp.district ?? ''
      const locationName = street || township || district || data.regeocode?.formatted_address?.split(city)[1]?.slice(0, 10) || '未知位置'

      return reply.send({ locationName, city, raw: data.regeocode?.formatted_address ?? '' })
    } catch (e: any) {
      return reply.code(502).send({ error: '地理编码服务暂时不可用', detail: e.message })
    }
  })

  // GET /geo/ip — 根据客户端 IP 返回城市（HTTP 下的兜底定位）
  app.get('/geo/ip', { preHandler: requireAuth }, async (req, reply) => {
    const key = process.env.AMAP_KEY
    if (!key) return reply.code(503).send({ error: '地理编码服务未配置' })

    const forwarded = req.headers['x-forwarded-for'] as string | undefined
    const clientIp  = (forwarded ? forwarded.split(',')[0] : req.ip).trim()

    try {
      const data = await httpsGet(
        `https://restapi.amap.com/v3/ip?key=${key}&ip=${clientIp}`
      )
      if (data.status !== '1') {
        return reply.code(502).send({ error: 'IP 定位失败', detail: data.info })
      }
      const cityRaw: string = Array.isArray(data.city) ? (data.province ?? '') : (data.city ?? data.province ?? '')
      const city = cityRaw.replace(/市$/, '') || '未知城市'
      return reply.send({ city, province: data.province ?? '', ip: clientIp })
    } catch (e: any) {
      return reply.code(502).send({ error: 'IP 定位服务暂时不可用', detail: e.message })
    }
  })
}

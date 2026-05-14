import { FastifyInstance } from 'fastify'
import { requireAuth, userId } from '../middleware/auth'
import { query, queryOne, execute } from '../db/client'
import { newId } from '../utils/id'

// Authoritative price list — 0 means free (auto-granted on registration)
export const STAMP_PRICES: Record<string, number> = {
  // Series I · 旅行 — free
  classic: 0, nature: 0, culture: 0, city: 0, ocean: 0, sunset: 0,
  // Series II · 古迹 — 20 PT each
  greatwall: 20, terracotta: 20, pagoda: 20, garden: 20, canal: 20,
  // Series III · 四季 — 30 PT each
  spring: 30, summer: 30, autumn: 30, winter: 30,
  // Series IV · 节气 — 50 PT each
  lichun: 50, qingming: 50, xiazhi: 50, liqiu: 50, shuangjiang: 50, dahan: 50,
  // Series V · 远方 — 80 PT each
  prairie: 80, snowpeak: 80, desert: 80, island: 80,
}

const SERIES_NAMES: Record<string, string> = {
  I: '旅行', II: '古迹', III: '四季', IV: '节气', V: '远方',
}

export async function stampRoutes(app: FastifyInstance) {

  // GET /stamps — all stamps with per-user ownership status
  app.get('/stamps', { preHandler: requireAuth }, async (req, reply) => {
    const uid    = userId(req)
    const stamps = await query<any>('SELECT * FROM stamp_designs ORDER BY series, sort_order')
    const owned  = await query<any>('SELECT stamp_id FROM user_stamps WHERE user_id = ?', [uid])
    const ownedSet = new Set(owned.map((r: any) => r.stamp_id))

    return reply.send(stamps.map((r: any) => ({
      id:         r.id,
      name:       r.name,
      series:     r.series,
      seriesName: SERIES_NAMES[r.series] ?? r.series,
      color:      r.color,
      imageUrl:   r.image_url ?? null,
      price:      STAMP_PRICES[r.id] ?? 99,
      isFree:     (STAMP_PRICES[r.id] ?? 1) === 0,
      isOwned:    ownedSet.has(r.id),
    })))
  })

  // GET /stamps/my — only stamps this user owns (used by postcard pickers)
  app.get('/stamps/my', { preHandler: requireAuth }, async (req, reply) => {
    const uid  = userId(req)
    const rows = await query<any>(
      `SELECT sd.id, sd.name, sd.series, sd.color, sd.image_url
       FROM user_stamps us
       JOIN stamp_designs sd ON sd.id = us.stamp_id
       WHERE us.user_id = ?
       ORDER BY sd.series, sd.sort_order`,
      [uid]
    )
    return reply.send(rows.map((r: any) => ({
      id:         r.id,
      name:       r.name,
      series:     r.series,
      seriesName: SERIES_NAMES[r.series] ?? r.series,
      color:      r.color,
      imageUrl:   r.image_url ?? null,
      price:      STAMP_PRICES[r.id] ?? 0,
      isFree:     (STAMP_PRICES[r.id] ?? 1) === 0,
      isOwned:    true,
    })))
  })

  // POST /stamps/:id/unlock — purchase a stamp with points
  app.post<{ Params: { id: string } }>('/stamps/:id/unlock', { preHandler: requireAuth }, async (req, reply) => {
    const uid     = userId(req)
    const stampId = req.params.id
    const price   = STAMP_PRICES[stampId]

    if (price === undefined) return reply.code(404).send({ error: '邮票不存在' })
    if (price === 0)         return reply.code(400).send({ error: '此为免费邮票，已自动拥有' })

    const existing = await queryOne<any>(
      'SELECT id FROM user_stamps WHERE user_id = ? AND stamp_id = ?', [uid, stampId]
    )
    if (existing) return reply.code(400).send({ error: '已拥有此邮票' })

    const user = await queryOne<any>('SELECT points FROM users WHERE id = ?', [uid])
    if (!user) return reply.code(401).send({ error: '用户不存在' })
    if (user.points < price) {
      return reply.code(400).send({ error: `积分不足，还需 ${price - user.points} 积分` })
    }

    const now = Date.now()
    await execute('UPDATE users SET points = points - ? WHERE id = ?', [price, uid])
    await execute(
      'INSERT INTO user_stamps (id, user_id, stamp_id, unlocked_at) VALUES (?, ?, ?, ?)',
      [newId(), uid, stampId, now]
    )
    await execute(
      'INSERT INTO points_log (id, user_id, delta, reason, ref_id, created_at) VALUES (?, ?, ?, ?, ?, ?)',
      [newId(), uid, -price, `解锁邮票·${stampId}`, stampId, now]
    )

    const updated = await queryOne<any>('SELECT points FROM users WHERE id = ?', [uid])
    return reply.send({ success: true, points: updated!.points, stampId })
  })
}

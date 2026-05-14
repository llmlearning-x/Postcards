import { FastifyInstance } from 'fastify'
import { requireAuth, userId } from '../middleware/auth'
import { query, queryOne } from '../db/client'
import { addPoints, DAILY_BONUS } from '../utils/points'

const REASON_LABELS: Record<string, string> = {
  register_bonus:  '注册奖励',
  record_postcard: '记录明信片',
  send_mailing:    '寄出明信片',
  receive_mailing: '收到明信片',
  daily_bonus:     '每日签到',
}

export async function pointsRoutes(app: FastifyInstance) {

  // GET /points/me — balance + recent transaction log
  app.get('/points/me', { preHandler: requireAuth }, async (req, reply) => {
    const uid  = userId(req)
    const user = await queryOne<any>('SELECT points FROM users WHERE id = ?', [uid])
    const log  = await query<any>(
      'SELECT delta, reason, created_at FROM points_log WHERE user_id = ? ORDER BY created_at DESC LIMIT 20',
      [uid]
    )
    return reply.send({
      points: user?.points ?? 0,
      log: log.map((r: any) => ({
        delta:     r.delta,
        reason:    REASON_LABELS[r.reason] ?? r.reason,
        createdAt: r.created_at,
      })),
    })
  })

  // POST /points/daily — claim daily login bonus (idempotent: one per calendar day)
  app.post('/points/daily', {
    preHandler: requireAuth,
    config: { rateLimit: { max: 3, timeWindow: '1 minute' } },
  }, async (req, reply) => {
    const uid     = userId(req)
    const today   = new Date()
    today.setHours(0, 0, 0, 0)
    const todayTs = today.getTime()

    const already = await queryOne<any>(
      `SELECT id FROM points_log WHERE user_id = ? AND reason = 'daily_bonus' AND created_at >= ?`,
      [uid, todayTs]
    )
    if (already) return reply.code(400).send({ error: '今日签到积分已领取' })

    await addPoints(uid, DAILY_BONUS, 'daily_bonus')
    const user = await queryOne<any>('SELECT points FROM users WHERE id = ?', [uid])
    return reply.send({ points: user!.points, delta: DAILY_BONUS })
  })
}

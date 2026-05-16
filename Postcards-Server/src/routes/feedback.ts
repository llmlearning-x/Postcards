import { FastifyInstance } from 'fastify'
import { requireAuth, userId } from '../middleware/auth'
import { execute, query } from '../db/client'
import { newId } from '../utils/id'

export async function feedbackRoutes(app: FastifyInstance) {

  // 登记功能兴趣
  app.post('/feedback/interest', { preHandler: requireAuth }, async (req, reply) => {
    const { feature, refId } = req.body as { feature: string; refId?: string }
    if (!feature) return reply.code(400).send({ error: '缺少 feature' })

    const uid = userId(req)
    const now = Date.now()

    // 同一用户同一功能只记一条
    const existing = await query(
      'SELECT id FROM feature_interest WHERE user_id = ? AND feature = ?',
      [uid, feature]
    )
    if (existing.length > 0) return reply.send({ ok: true, alreadyRegistered: true })

    await execute(
      'INSERT INTO feature_interest (id, user_id, feature, ref_id, created_at) VALUES (?, ?, ?, ?, ?)',
      [newId(), uid, feature, refId ?? null, now]
    )
    return reply.send({ ok: true, alreadyRegistered: false })
  })

  // 查询某功能的兴趣总数（不鉴权，内部用）
  app.get('/feedback/interest/:feature/count', async (req, reply) => {
    const { feature } = req.params as { feature: string }
    const rows = await query<{ cnt: number }>(
      'SELECT COUNT(*) AS cnt FROM feature_interest WHERE feature = ?',
      [feature]
    )
    return reply.send({ feature, count: rows[0]?.cnt ?? 0 })
  })
}

import { FastifyInstance } from 'fastify'
import { requireAuth, userId } from '../middleware/auth'
import { query, queryOne, execute } from '../db/client'
import { newId } from '../utils/id'
import { addPoints, RECORD_BONUS } from '../utils/points'

export async function postcardRoutes(app: FastifyInstance) {

  // ── 获取我的明信片（支持增量同步 + 旅程筛选）────────────────────
  app.get('/postcards', { preHandler: requireAuth }, async (req, reply) => {
    const { since, travelId } = req.query as { since?: string; travelId?: string }
    const uid = userId(req)

    let sql = 'SELECT * FROM postcards WHERE user_id = ?'
    const vals: any[] = [uid]

    if (travelId) { sql += ' AND travel_id = ?';  vals.push(travelId) }
    if (since)    { sql += ' AND updated_at > ?';  vals.push(parseInt(since)) }
    sql += ' ORDER BY recorded_at DESC'

    const rows = await query(sql, vals)
    return reply.send(rows.map(toCamel))
  })

  // ── 创建明信片 ───────────────────────────────────────────────────
  app.post('/postcards', { preHandler: requireAuth }, async (req, reply) => {
    const { travelId, photoUrl, locationName, city, country, note, stampDesign, recordedAt } = req.body as any
    if (!travelId || !locationName || !city) {
      return reply.code(400).send({ error: '缺少必填字段' })
    }

    const uid = userId(req)
    const now = Date.now()
    const id  = newId()

    await execute(
      `INSERT INTO postcards (id, user_id, travel_id, photo_url, location_name, city, country, note, stamp_design, is_favorite, recorded_at, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?)`,
      [id, uid, travelId, photoUrl || null, locationName, city, country || '中国',
       note || '', stampDesign || 'classic', recordedAt || now, now, now]
    )

    const row = await queryOne('SELECT * FROM postcards WHERE id = ?', [id])
    addPoints(uid, RECORD_BONUS, 'record_postcard', id).catch(() => {})
    return reply.code(201).send(toCamel(row))
  })

  // ── 更新明信片（含切换收藏）─────────────────────────────────────
  app.put<{ Params: { id: string } }>('/postcards/:id', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params
    const uid = userId(req)
    const row = await queryOne('SELECT id FROM postcards WHERE id = ? AND user_id = ?', [id, uid])
    if (!row) return reply.code(404).send({ error: '明信片不存在' })

    const { photoUrl, locationName, city, country, note, stampDesign, isFavorite } = req.body as any
    const now = Date.now()

    await execute(
      `UPDATE postcards SET
         photo_url     = COALESCE(?, photo_url),
         location_name = COALESCE(?, location_name),
         city          = COALESCE(?, city),
         country       = COALESCE(?, country),
         note          = COALESCE(?, note),
         stamp_design  = COALESCE(?, stamp_design),
         is_favorite   = COALESCE(?, is_favorite),
         updated_at    = ?
       WHERE id = ? AND user_id = ?`,
      [photoUrl, locationName, city, country, note, stampDesign,
       isFavorite !== undefined ? (isFavorite ? 1 : 0) : undefined,
       now, id, uid]
    )

    const updated = await queryOne('SELECT * FROM postcards WHERE id = ?', [id])
    return reply.send(toCamel(updated))
  })

  // ── 删除明信片 ───────────────────────────────────────────────────
  app.delete<{ Params: { id: string } }>('/postcards/:id', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params
    const uid = userId(req)
    const { affectedRows } = await execute(
      'DELETE FROM postcards WHERE id = ? AND user_id = ?', [id, uid]
    )
    if (!affectedRows) return reply.code(404).send({ error: '明信片不存在' })
    return reply.code(204).send()
  })
}

function toCamel(row: any) {
  if (!row) return null
  return {
    id:           row.id,
    userId:       row.user_id,
    travelId:     row.travel_id,
    photoUrl:     row.photo_url,
    locationName: row.location_name,
    city:         row.city,
    country:      row.country,
    note:         row.note,
    stampDesign:  row.stamp_design,
    isFavorite:   row.is_favorite === 1,
    recordedAt:   row.recorded_at,
    createdAt:    row.created_at,
    updatedAt:    row.updated_at,
  }
}

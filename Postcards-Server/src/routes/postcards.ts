import { FastifyInstance } from 'fastify'
import { requireAuth, userId } from '../middleware/auth'
import { query, queryOne, execute } from '../db/client'
import { newId } from '../utils/id'
import { resolveStampImageUrl } from '../utils/stampImages'
import { addPoints, RECORD_BONUS } from '../utils/points'

export async function postcardRoutes(app: FastifyInstance) {

  // ── 获取我的明信片（支持增量同步 + 旅程筛选 + 分页 + 搜索）──────
  app.get('/postcards', { preHandler: requireAuth }, async (req, reply) => {
    const { since, travelId, q, limit, offset } = req.query as {
      since?: string; travelId?: string; q?: string; limit?: string; offset?: string
    }
    const uid = userId(req)

    let sql = 'SELECT * FROM postcards WHERE user_id = ?'
    const vals: any[] = [uid]

    if (travelId) { sql += ' AND travel_id = ?';  vals.push(travelId) }
    if (since)    { sql += ' AND updated_at > ?';  vals.push(parseInt(since)) }
    if (q) {
      sql += ' AND (location_name LIKE ? OR city LIKE ? OR country LIKE ? OR note LIKE ?)'
      const like = `%${q}%`
      vals.push(like, like, like, like)
    }
    sql += ' ORDER BY recorded_at DESC'

    const take = limit  ? Math.min(50, parseInt(limit))  : 50
    const skip = offset ? parseInt(offset) : 0
    sql += ` LIMIT ${take} OFFSET ${skip}`

    const rows = await query(sql, vals)
    return reply.send(rows.map(toCamel))
  })

  // ── 获取我的明信片总数（用于分页 UI）────────────────────────────
  app.get('/postcards/count', { preHandler: requireAuth }, async (req, reply) => {
    const { travelId, q } = req.query as { travelId?: string; q?: string }
    const uid = userId(req)

    let sql = 'SELECT COUNT(*) as total FROM postcards WHERE user_id = ?'
    const vals: any[] = [uid]

    if (travelId) { sql += ' AND travel_id = ?';  vals.push(travelId) }
    if (q) {
      sql += ' AND (location_name LIKE ? OR city LIKE ? OR country LIKE ? OR note LIKE ?)'
      const like = `%${q}%`
      vals.push(like, like, like, like)
    }

    const row = await queryOne<any>(sql, vals)
    return reply.send({ total: row?.total ?? 0 })
  })

  // ── 创建明信片 ───────────────────────────────────────────────────
  app.post('/postcards', { preHandler: requireAuth }, async (req, reply) => {
    const { travelId, photoUrl, locationName, city, country, note, stampDesign, recordedAt, toName } = req.body as any
    if (!travelId || !locationName || !city) {
      return reply.code(400).send({ error: '缺少必填字段' })
    }

    const uid = userId(req)
    const now = Date.now()
    const id  = newId()

    await execute(
      `INSERT INTO postcards (id, user_id, travel_id, photo_url, location_name, city, country, note, stamp_design, to_name, is_favorite, recorded_at, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?)`,
      [id, uid, travelId, photoUrl || null, locationName, city, country || '中国',
       note || '', stampDesign || 'classic', toName || null, recordedAt || now, now, now]
    )

    const row = await queryOne('SELECT * FROM postcards WHERE id = ?', [id])
    addPoints(uid, RECORD_BONUS, 'record_postcard', id).catch(() => {})
    return reply.code(201).send(toCamel(row))
  })

  // ── 更新明信片（含切换收藏 / 公开状态）────────────────────────────
  app.put<{ Params: { id: string } }>('/postcards/:id', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params
    const uid = userId(req)
    const row = await queryOne('SELECT id FROM postcards WHERE id = ? AND user_id = ?', [id, uid])
    if (!row) return reply.code(404).send({ error: '明信片不存在' })

    const { photoUrl, locationName, city, country, note, stampDesign, isFavorite, toName, isPublic } = req.body as any
    const now = Date.now()

    // 保存的来信不允许公开
    if (isPublic !== undefined && isPublic) {
      const existing = await queryOne<any>('SELECT is_saved_mailing FROM postcards WHERE id = ? AND user_id = ?', [id, uid])
      if (existing && existing.is_saved_mailing === 1) {
        return reply.code(403).send({ error: '保存的来信不允许公开' })
      }
    }

    await execute(
      `UPDATE postcards SET
         photo_url     = COALESCE(?, photo_url),
         location_name = COALESCE(?, location_name),
         city          = COALESCE(?, city),
         country       = COALESCE(?, country),
         note          = COALESCE(?, note),
         stamp_design  = COALESCE(?, stamp_design),
         to_name       = COALESCE(?, to_name),
         is_favorite   = COALESCE(?, is_favorite),
         is_public     = COALESCE(?, is_public),
         updated_at    = ?
       WHERE id = ? AND user_id = ?`,
      [photoUrl ?? null, locationName ?? null, city ?? null, country ?? null,
       note ?? null, stampDesign ?? null, toName ?? null,
       isFavorite !== undefined ? (isFavorite ? 1 : 0) : null,
       isPublic  !== undefined ? (isPublic  ? 1 : 0) : null,
       now, id, uid]
    )

    const updated = await queryOne('SELECT * FROM postcards WHERE id = ?', [id])
    return reply.send(toCamel(updated))
  })

  // ── 旅行公告栏：公开明信片列表 ──────────────────────────────────
  app.get('/postcards/public', { preHandler: requireAuth }, async (req, reply) => {
    const { page = '1', limit = '20' } = req.query as { page?: string; limit?: string }
    const uid    = userId(req)
    const offset = (Math.max(1, parseInt(page)) - 1) * Math.min(50, parseInt(limit))
    const take   = Math.min(50, parseInt(limit))

    const rows = await query<any>(
      `SELECT p.*, u.nickname, u.mailbox_no, u.avatar_url,
              EXISTS(SELECT 1 FROM contacts c WHERE c.user_id = ? AND c.contact_id = p.user_id) AS is_contact
       FROM postcards p
       JOIN users u ON u.id = p.user_id
       WHERE p.is_public = 1
       ORDER BY p.updated_at DESC
       LIMIT ${take} OFFSET ${offset}`,
      [uid]
    )

    return reply.send(rows.map(r => ({
      ...toCamel(r),
      isPublic:    true,
      stampCount:  r.stamp_count,
      author: {
        id:        r.user_id,
        nickname:  r.nickname,
        mailboxNo: r.mailbox_no,
        avatarUrl: r.avatar_url ?? null,
        isContact: r.is_contact === 1,
      },
    })))
  })

  // ── 盖章 / 取消盖章 ──────────────────────────────────────────────
  app.post<{ Params: { id: string } }>('/postcards/:id/stamp', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params
    const row = await queryOne<any>('SELECT id, stamp_count FROM postcards WHERE id = ? AND is_public = 1', [id])
    if (!row) return reply.code(404).send({ error: '明信片不存在' })
    await execute('UPDATE postcards SET stamp_count = stamp_count + 1 WHERE id = ?', [id])
    return reply.send({ stampCount: row.stamp_count + 1 })
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
    toName:       row.to_name || null,
    stampDesign:  row.stamp_design,
    stampImageUrl: resolveStampImageUrl(row.stamp_design, null),
    isFavorite:   row.is_favorite === 1,
    isPublic:     row.is_public === 1,
    isSavedMailing: row.is_saved_mailing === 1,
    stampCount:   row.stamp_count ?? 0,
    recordedAt:   row.recorded_at,
    createdAt:    row.created_at,
    updatedAt:    row.updated_at,
  }
}

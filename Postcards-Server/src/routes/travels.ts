import { FastifyInstance } from 'fastify'
import { requireAuth, userId } from '../middleware/auth'
import { query, queryOne, execute } from '../db/client'
import { newId } from '../utils/id'

export async function travelRoutes(app: FastifyInstance) {

  // ── 获取我的旅程列表（支持增量同步）──────────────────────────────
  app.get('/travels', { preHandler: requireAuth }, async (req, reply) => {
    const { since } = req.query as { since?: string }
    const uid = userId(req)

    let sql = 'SELECT * FROM travels WHERE user_id = ?'
    const vals: any[] = [uid]

    if (since) { sql += ' AND updated_at > ?'; vals.push(parseInt(since)) }
    sql += ' ORDER BY created_at DESC'

    const rows = await query(sql, vals)
    return reply.send(rows.map(toCamel))
  })

  // ── 创建旅程 ────────────────────────────────────────────────────
  app.post('/travels', { preHandler: requireAuth }, async (req, reply) => {
    const { title, destination, description, status, isCurrent, startDate, endDate } = req.body as any
    if (!title || !destination || !startDate || !endDate) {
      return reply.code(400).send({ error: '缺少必填字段' })
    }

    const uid = userId(req)
    const now = Date.now()
    const id  = newId()

    // 若新旅程是当前旅程，先把其他旅程的 is_current 置为 0
    if (isCurrent) {
      await execute('UPDATE travels SET is_current = 0, updated_at = ? WHERE user_id = ?', [now, uid])
    }

    await execute(
      `INSERT INTO travels (id, user_id, title, destination, description, status, is_current, start_date, end_date, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, uid, title, destination, description || '', status || 'planned', isCurrent ? 1 : 0,
       startDate, endDate, now, now]
    )

    const row = await queryOne('SELECT * FROM travels WHERE id = ?', [id])
    return reply.code(201).send(toCamel(row))
  })

  // ── 更新旅程 ────────────────────────────────────────────────────
  app.put<{ Params: { id: string } }>('/travels/:id', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params
    const uid  = userId(req)
    const row  = await queryOne<any>('SELECT * FROM travels WHERE id = ? AND user_id = ?', [id, uid])
    if (!row) return reply.code(404).send({ error: '旅程不存在' })

    const { title, destination, description, status, isCurrent, startDate, endDate } = req.body as any
    const now = Date.now()

    if (isCurrent) {
      await execute('UPDATE travels SET is_current = 0, updated_at = ? WHERE user_id = ?', [now, uid])
    }

    await execute(
      `UPDATE travels SET
         title = COALESCE(?, title),
         destination = COALESCE(?, destination),
         description = COALESCE(?, description),
         status = COALESCE(?, status),
         is_current = COALESCE(?, is_current),
         start_date = COALESCE(?, start_date),
         end_date = COALESCE(?, end_date),
         updated_at = ?
       WHERE id = ? AND user_id = ?`,
      [title, destination, description, status,
       isCurrent !== undefined ? (isCurrent ? 1 : 0) : undefined,
       startDate, endDate, now, id, uid]
    )

    const updated = await queryOne('SELECT * FROM travels WHERE id = ?', [id])
    return reply.send(toCamel(updated))
  })

  // ── 删除旅程（级联删明信片）──────────────────────────────────────
  app.delete<{ Params: { id: string } }>('/travels/:id', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params
    const uid = userId(req)
    const row = await queryOne('SELECT id FROM travels WHERE id = ? AND user_id = ?', [id, uid])
    if (!row) return reply.code(404).send({ error: '旅程不存在' })

    await execute('DELETE FROM postcards WHERE travel_id = ? AND user_id = ?', [id, uid])
    await execute('DELETE FROM travels WHERE id = ? AND user_id = ?', [id, uid])
    return reply.code(204).send()
  })
}

function toCamel(row: any) {
  if (!row) return null
  return {
    id:          row.id,
    userId:      row.user_id,
    title:       row.title,
    destination: row.destination,
    description: row.description,
    status:      row.status,
    isCurrent:   row.is_current === 1,
    startDate:   row.start_date,
    endDate:     row.end_date,
    createdAt:   row.created_at,
    updatedAt:   row.updated_at,
  }
}

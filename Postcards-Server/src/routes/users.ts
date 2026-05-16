import { FastifyInstance } from 'fastify'
import { requireAuth, userId } from '../middleware/auth'
import { query, queryOne, execute } from '../db/client'
import { newId } from '../utils/id'

export async function userRoutes(app: FastifyInstance) {

  // ── 获取自己的信息 ───────────────────────────────────────────────
  app.get('/users/me', { preHandler: requireAuth }, async (req, reply) => {
    const me = await queryOne<any>(
      `SELECT id, nickname, mailbox_no, avatar_url, points, created_at
       FROM users WHERE id = ?`,
      [userId(req)]
    )
    if (!me) return reply.code(404).send({ error: '用户不存在' })
    return reply.send({ ...toPublic(me), points: me.points ?? 0 })
  })

  // ── 更新个人信息 ─────────────────────────────────────────────────
  app.put('/users/me', { preHandler: requireAuth }, async (req, reply) => {
    const { nickname, avatarUrl, pushToken } = req.body as any
    const uid = userId(req)
    const now = Date.now()

    const sets: string[] = ['updated_at = ?']
    const vals: any[]    = [now]

    if (nickname?.trim())  { sets.push('nickname = ?');   vals.push(nickname.trim().slice(0, 20)) }
    if (avatarUrl)         { sets.push('avatar_url = ?'); vals.push(avatarUrl) }
    if (pushToken)         { sets.push('push_token = ?'); vals.push(pushToken) }

    if (sets.length === 1) return reply.code(400).send({ error: '没有可更新的字段' })

    vals.push(uid)
    await execute(`UPDATE users SET ${sets.join(', ')} WHERE id = ?`, vals)

    const me = await queryOne<any>('SELECT id, nickname, mailbox_no, avatar_url FROM users WHERE id = ?', [uid])
    return reply.send(toPublic(me!))
  })

  // ── 按邮箱号精确搜索用户（邮箱号全局唯一，禁止昵称搜索）──────────
  app.get('/users/search', { preHandler: requireAuth }, async (req, reply) => {
    const { q } = req.query as { q?: string }
    const raw = (q ?? '').trim().replace(/^CN-/i, '')
    if (!/^\d{6}$/.test(raw)) {
      return reply.code(400).send({ error: '请输入 6 位数字邮箱号' })
    }
    const keyword = `CN-${raw}`
    const users = await query<any>(
      `SELECT id, nickname, mailbox_no, avatar_url FROM users WHERE mailbox_no = ? LIMIT 1`,
      [keyword]
    )
    return reply.send(users.map(toPublic))
  })

  // ── 查看联系人列表（含往来明信片数量）──────────────────────────
  app.get('/contacts', { preHandler: requireAuth }, async (req, reply) => {
    const uid = userId(req)
    const contacts = await query<any>(
      `SELECT c.id, c.remark_name, c.created_at,
              u.id as contact_id, u.nickname, u.mailbox_no, u.avatar_url,
              (SELECT COUNT(*) FROM mailings m
               WHERE (m.sender_id = c.user_id AND m.recipient_id = c.contact_id)
                  OR (m.sender_id = c.contact_id AND m.recipient_id = c.user_id)
              ) as mail_count
       FROM contacts c
       JOIN users u ON u.id = c.contact_id
       WHERE c.user_id = ?
       ORDER BY mail_count DESC, c.created_at DESC`,
      [uid]
    )
    return reply.send(contacts.map(toContact))
  })

  // ── 添加联系人 ──────────────────────────────────────────────────
  app.post('/contacts', { preHandler: requireAuth }, async (req, reply) => {
    const { contactId } = req.body as { contactId: string }
    const uid = userId(req)

    if (!contactId) return reply.code(400).send({ error: '缺少 contactId' })
    if (contactId === uid) return reply.code(400).send({ error: '不能添加自己' })

    const target = await queryOne<any>('SELECT id FROM users WHERE id = ?', [contactId])
    if (!target) return reply.code(404).send({ error: '用户不存在' })

    const existing = await queryOne<any>(
      'SELECT id FROM contacts WHERE user_id = ? AND contact_id = ?', [uid, contactId]
    )
    if (existing) return reply.code(409).send({ error: '已在联系人中' })

    const id  = newId()
    const now = Date.now()
    await execute(
      'INSERT INTO contacts (id, user_id, contact_id, remark_name, created_at) VALUES (?, ?, ?, NULL, ?)',
      [id, uid, contactId, now]
    )

    const row = await queryOne<any>(
      `SELECT c.id, c.remark_name, c.created_at,
              u.id as contact_id, u.nickname, u.mailbox_no, u.avatar_url, 0 as mail_count
       FROM contacts c JOIN users u ON u.id = c.contact_id
       WHERE c.id = ?`, [id]
    )
    return reply.code(201).send(toContact(row!))
  })

  // ── 修改备注名 ──────────────────────────────────────────────────
  app.put('/contacts/:id', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params as { id: string }
    const { remarkName } = req.body as { remarkName?: string | null }
    const uid = userId(req)

    const contact = await queryOne<any>(
      'SELECT id FROM contacts WHERE id = ? AND user_id = ?', [id, uid]
    )
    if (!contact) return reply.code(404).send({ error: '联系人不存在' })

    await execute(
      'UPDATE contacts SET remark_name = ? WHERE id = ?',
      [remarkName?.trim() || null, id]
    )
    return reply.send({ ok: true })
  })

  // ── 删除联系人 ──────────────────────────────────────────────────
  app.delete('/contacts/:id', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params as { id: string }
    const uid = userId(req)

    const contact = await queryOne<any>(
      'SELECT id FROM contacts WHERE id = ? AND user_id = ?', [id, uid]
    )
    if (!contact) return reply.code(404).send({ error: '联系人不存在' })

    await execute('DELETE FROM contacts WHERE id = ?', [id])
    return reply.send({ ok: true })
  })
}

function toContact(c: any) {
  return {
    id:         c.id,
    remarkName: c.remark_name ?? null,
    createdAt:  c.created_at,
    contactId:  c.contact_id,
    nickname:   c.nickname,
    mailboxNo:  c.mailbox_no,
    avatarUrl:  c.avatar_url ?? null,
    mailCount:  Number(c.mail_count ?? 0),
  }
}

function toPublic(u: any) {
  return {
    id:        u.id,
    nickname:  u.nickname,
    mailboxNo: u.mailbox_no,
    avatarUrl: u.avatar_url ?? null,
    createdAt: u.created_at,
  }
}

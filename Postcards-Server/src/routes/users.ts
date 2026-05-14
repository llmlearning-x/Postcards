import { FastifyInstance } from 'fastify'
import { requireAuth, userId } from '../middleware/auth'
import { query, queryOne, execute } from '../db/client'

export async function userRoutes(app: FastifyInstance) {

  // ── 获取自己的信息 ───────────────────────────────────────────────
  app.get('/users/me', { preHandler: requireAuth }, async (req, reply) => {
    const me = await queryOne<any>(
      `SELECT id, nickname, mailbox_no, avatar_url, first_launch_at, created_at
       FROM users WHERE id = ?`,
      [userId(req)]
    )
    if (!me) return reply.code(404).send({ error: '用户不存在' })
    return reply.send(toPublic(me))
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

  // ── 按邮箱号搜索用户（用于发明信片时找收件人）────────────────────
  app.get('/users/search', { preHandler: requireAuth }, async (req, reply) => {
    const { q } = req.query as { q?: string }
    if (!q || q.trim().length < 3) {
      return reply.code(400).send({ error: '请输入至少 3 个字符' })
    }
    const keyword = q.trim().toUpperCase()
    // 精确匹配邮箱号（CN-XXXXXX），或模糊匹配昵称
    const users = await query<any>(
      `SELECT id, nickname, mailbox_no, avatar_url FROM users
       WHERE mailbox_no = ? OR nickname LIKE ?
       LIMIT 10`,
      [keyword, `%${keyword}%`]
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
    return reply.send(contacts.map((c: any) => ({
      id:         c.id,
      remarkName: c.remark_name,
      createdAt:  c.created_at,
      contactId:  c.contact_id,
      nickname:   c.nickname,
      mailboxNo:  c.mailbox_no,
      avatarUrl:  c.avatar_url ?? null,
      mailCount:  Number(c.mail_count ?? 0),
    })))
  })
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

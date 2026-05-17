import { FastifyInstance } from 'fastify'
import { requireAuth, userId } from '../middleware/auth'
import { query, queryOne, execute } from '../db/client'
import { newId } from '../utils/id'
import { addPoints, SEND_BONUS, RECEIVE_BONUS } from '../utils/points'

export async function mailingRoutes(app: FastifyInstance) {

  // ── 寄出明信片 ───────────────────────────────────────────────────
  app.post('/mailings', { preHandler: requireAuth }, async (req, reply) => {
    const { postcardId, recipientId, personalNote } = req.body as any
    if (!postcardId || !recipientId) {
      return reply.code(400).send({ error: '缺少明信片ID或收件人ID' })
    }

    const uid = userId(req)
    if (uid === recipientId) return reply.code(400).send({ error: '不能寄给自己' })

    // 验证明信片属于寄件人
    const postcard = await queryOne<any>(
      'SELECT * FROM postcards WHERE id = ? AND user_id = ?', [postcardId, uid]
    )
    if (!postcard) return reply.code(404).send({ error: '明信片不存在' })

    // 验证收件人存在
    const recipient = await queryOne<any>(
      'SELECT id, nickname, mailbox_no FROM users WHERE id = ?', [recipientId]
    )
    if (!recipient) return reply.code(404).send({ error: '收件人不存在' })

    // 获取寄件人信息（用于快照）
    const sender = await queryOne<any>(
      'SELECT id, nickname, mailbox_no, avatar_url FROM users WHERE id = ?', [uid]
    )
    if (!sender) {
      return reply.code(401).send({ error: '登录已过期，请重新登录' })
    }

    // 快照：保存寄出时的明信片内容（即使原始被删除，收件人仍可查看）
    const snapshot = {
      photoUrl:     postcard.photo_url,
      locationName: postcard.location_name,
      city:         postcard.city,
      country:      postcard.country,
      note:         postcard.note,
      stampDesign:  postcard.stamp_design,
      recordedAt:   postcard.recorded_at,
      sender: {
        id:        sender.id,
        nickname:  sender.nickname,
        mailboxNo: sender.mailbox_no,
        avatarUrl: sender.avatar_url,
      },
    }

    const now = Date.now()
    const id  = newId()

    await execute(
      `INSERT INTO mailings (id, postcard_id, sender_id, recipient_id, personal_note, snapshot, status, sent_at, created_at)
       VALUES (?, ?, ?, ?, ?, ?, 'sent', ?, ?)`,
      [id, postcardId, uid, recipientId, personalNote || null, JSON.stringify(snapshot), now, now]
    )

    // 建立通讯录关系（双向）
    await upsertContact(uid, recipientId)
    await upsertContact(recipientId, uid)
    // 寄件人获得积分
    addPoints(uid, SEND_BONUS, 'send_mailing', id).catch(() => {})

    // TODO: 推送通知给收件人（接入 FCM 或 EMAS 后在此添加）

    return reply.code(201).send({
      id,
      status: 'sent',
      recipient: { id: recipient.id, nickname: recipient.nickname, mailboxNo: recipient.mailbox_no },
    })
  })

  // ── 收件箱 ───────────────────────────────────────────────────────
  app.get('/mailings/inbox', { preHandler: requireAuth }, async (req, reply) => {
    const uid = userId(req)
    const { since } = req.query as { since?: string }

    let sql = `SELECT m.*, u.nickname as sender_nickname, u.mailbox_no as sender_mailbox, u.avatar_url as sender_avatar
               FROM mailings m
               JOIN users u ON u.id = m.sender_id
               WHERE m.recipient_id = ? AND m.recipient_deleted = 0`
    const vals: any[] = [uid]

    if (since) { sql += ' AND m.sent_at > ?'; vals.push(parseInt(since)) }
    sql += ' ORDER BY m.sent_at DESC LIMIT 100'

    const rows = await query<any>(sql, vals)

    const unreadCount = rows.filter(r => !r.opened_at).length

    return reply.send({
      unreadCount,
      items: rows.map(r => ({
        id:           r.id,
        postcardId:   r.postcard_id,
        personalNote: r.personal_note,
        snapshot:     typeof r.snapshot === 'string' ? JSON.parse(r.snapshot) : r.snapshot,
        status:       r.status,
        sentAt:       r.sent_at,
        openedAt:     r.opened_at,
        sender: {
          id:        r.sender_id,
          nickname:  r.sender_nickname,
          mailboxNo: r.sender_mailbox,
          avatarUrl: r.sender_avatar,
        },
      }))
    })
  })

  // ── 发件箱 ───────────────────────────────────────────────────────
  app.get('/mailings/sent', { preHandler: requireAuth }, async (req, reply) => {
    const uid = userId(req)
    const rows = await query<any>(
      `SELECT m.*, u.nickname as recipient_nickname, u.mailbox_no as recipient_mailbox, u.avatar_url as recipient_avatar
       FROM mailings m
       JOIN users u ON u.id = m.recipient_id
       WHERE m.sender_id = ? AND m.sender_deleted = 0
       ORDER BY m.sent_at DESC LIMIT 100`,
      [uid]
    )
    return reply.send(rows.map(r => ({
      id:           r.id,
      postcardId:   r.postcard_id,
      personalNote: r.personal_note,
      snapshot:     typeof r.snapshot === 'string' ? JSON.parse(r.snapshot) : (r.snapshot ?? null),
      status:       r.status,
      sentAt:       r.sent_at,
      openedAt:     r.opened_at,
      recipient: {
        id:        r.recipient_id,
        nickname:  r.recipient_nickname,
        mailboxNo: r.recipient_mailbox,
        avatarUrl: r.recipient_avatar ?? null,
      },
    })))
  })

  // ── 删除邮件（收件人删来信 / 寄件人删已发，各自独立）────────────
  app.delete<{ Params: { id: string } }>('/mailings/:id', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params
    const uid = userId(req)

    // 收件人删来信
    const asRecipient = await queryOne<any>(
      'SELECT id FROM mailings WHERE id = ? AND recipient_id = ?', [id, uid]
    )
    if (asRecipient) {
      await execute('UPDATE mailings SET recipient_deleted = 1 WHERE id = ?', [id])
      return reply.send({ ok: true })
    }

    // 寄件人删已发
    const asSender = await queryOne<any>(
      'SELECT id FROM mailings WHERE id = ? AND sender_id = ?', [id, uid]
    )
    if (asSender) {
      await execute('UPDATE mailings SET sender_deleted = 1 WHERE id = ?', [id])
      return reply.send({ ok: true })
    }

    return reply.code(404).send({ error: '邮件不存在' })
  })

  // ── 保存来信明信片到个人收藏 ─────────────────────────────────────
  app.post<{ Params: { id: string } }>('/mailings/:id/save', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params
    const uid = userId(req)

    const mailing = await queryOne<any>(
      'SELECT * FROM mailings WHERE id = ? AND recipient_id = ?', [id, uid]
    )
    if (!mailing) return reply.code(404).send({ error: '邮件不存在' })

    const snap = typeof mailing.snapshot === 'string' ? JSON.parse(mailing.snapshot) : mailing.snapshot
    if (!snap) return reply.code(400).send({ error: '邮件数据不完整' })

    const newPostcardId = newId()
    const now = Date.now()

    await execute(
      `INSERT INTO postcards (id, user_id, travel_id, photo_url, location_name, city, country, note, stamp_design, to_name, is_favorite, is_saved_mailing, recorded_at, created_at, updated_at)
       VALUES (?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, 0, 1, ?, ?, ?)`,
      [
        newPostcardId, uid,
        snap.photoUrl || null,
        snap.locationName || '',
        snap.city || '',
        snap.country || '',
        snap.note || '',
        snap.stampDesign || 'classic',
        snap.sender?.nickname ? `来自 ${snap.sender.nickname}` : null,
        snap.recordedAt || now,
        now, now,
      ]
    )

    return reply.code(201).send({ id: newPostcardId })
  })

  // ── 开封（标记已读）──────────────────────────────────────────────
  app.put<{ Params: { id: string } }>('/mailings/:id/open', { preHandler: requireAuth }, async (req, reply) => {
    const { id } = req.params
    const uid = userId(req)

    const mailing = await queryOne<any>(
      'SELECT id, opened_at FROM mailings WHERE id = ? AND recipient_id = ?', [id, uid]
    )
    if (!mailing) return reply.code(404).send({ error: '明信片不存在' })

    if (!mailing.opened_at) {
      await execute('UPDATE mailings SET opened_at = ?, status = ? WHERE id = ?',
        [Date.now(), 'opened', id])
      // 收件人首次开封获得积分
      addPoints(uid, RECEIVE_BONUS, 'receive_mailing', id).catch(() => {})
    }

    return reply.send({ success: true })
  })
}

async function upsertContact(userId: string, contactId: string) {
  const existing = await queryOne(
    'SELECT id FROM contacts WHERE user_id = ? AND contact_id = ?', [userId, contactId]
  )
  if (!existing) {
    await execute(
      'INSERT INTO contacts (id, user_id, contact_id, created_at) VALUES (?, ?, ?, ?)',
      [newId(), userId, contactId, Date.now()]
    ).catch(() => {}) // 忽略唯一键冲突
  }
}

import { FastifyInstance } from 'fastify'
import bcrypt from 'bcrypt'
import { query, queryOne, execute } from '../db/client'
import { newId, newMailboxNo } from '../utils/id'
import { config } from '../config'
import { addPoints, grantFreeStamps, REGISTER_BONUS } from '../utils/points'

interface RegisterBody { nickname: string; password: string }
interface LoginBody    { mailboxNo: string; password: string }

export async function authRoutes(app: FastifyInstance) {

  // ── 注册（生成专属邮箱号作为登录 ID）────────────────────────────
  app.post<{ Body: RegisterBody }>('/auth/register', async (req, reply) => {
    const { nickname, password } = req.body

    if (!nickname?.trim()) {
      return reply.code(400).send({ error: '请输入昵称' })
    }
    if (!password || password.length < 6) {
      return reply.code(400).send({ error: '密码至少 6 位' })
    }

    const id           = newId()
    const passwordHash = await bcrypt.hash(password, 10)
    const mailboxNo    = await generateUniqueMailbox()
    const displayName  = nickname.trim().slice(0, 20)
    const now          = Date.now()

    await execute(
      `INSERT INTO users (id, nickname, mailbox_no, password_hash, first_launch_at, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [id, displayName, mailboxNo, passwordHash, now, now, now]
    )

    // Grant registration bonus + free Series I stamps (fire-and-forget)
    addPoints(id, REGISTER_BONUS, 'register_bonus').catch(() => {})
    grantFreeStamps(id).catch(() => {})

    const accessToken  = await signAccess(app, id)
    const refreshToken = await signRefresh(app, id)

    return reply.code(201).send({
      accessToken,
      refreshToken,
      user: { id, nickname: displayName, mailboxNo, points: REGISTER_BONUS },
    })
  })

  // ── 登录（用邮箱号 CN-XXXXXX + 密码）───────────────────────────
  app.post<{ Body: LoginBody }>('/auth/login', async (req, reply) => {
    const { mailboxNo, password } = req.body
    if (!mailboxNo || !password) {
      return reply.code(400).send({ error: '请输入邮箱号和密码' })
    }

    const user = await queryOne<any>(
      'SELECT id, nickname, mailbox_no, password_hash, points FROM users WHERE mailbox_no = ?',
      [mailboxNo.trim().toUpperCase()]
    )
    if (!user) return reply.code(401).send({ error: '邮箱号或密码错误' })

    const ok = await bcrypt.compare(password, user.password_hash)
    if (!ok) return reply.code(401).send({ error: '邮箱号或密码错误' })

    const accessToken  = await signAccess(app, user.id)
    const refreshToken = await signRefresh(app, user.id)

    return reply.send({
      accessToken,
      refreshToken,
      user: { id: user.id, nickname: user.nickname, mailboxNo: user.mailbox_no, points: user.points ?? 0 },
    })
  })

  // ── 刷新 Token ──────────────────────────────────────────────────
  app.post('/auth/refresh', async (req, reply) => {
    const { refreshToken } = req.body as { refreshToken: string }
    if (!refreshToken) return reply.code(400).send({ error: '缺少 refreshToken' })

    try {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const payload = (app.jwt.verify as any)(refreshToken, { secret: config.jwt.refreshSecret }) as { userId: string }
      const newAccess = await signAccess(app, payload.userId)
      return reply.send({ accessToken: newAccess })
    } catch {
      return reply.code(401).send({ error: 'refreshToken 无效或已过期' })
    }
  })
}

// ── helpers ──────────────────────────────────────────────────────
async function signAccess(app: FastifyInstance, userId: string): Promise<string> {
  return app.jwt.sign({ userId }, { expiresIn: config.jwt.accessExpiry })
}

async function signRefresh(app: FastifyInstance, userId: string): Promise<string> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (app.jwt.sign as any)({ userId }, { secret: config.jwt.refreshSecret, expiresIn: config.jwt.refreshExpiry })
}

async function generateUniqueMailbox(): Promise<string> {
  for (let i = 0; i < 10; i++) {
    const no = newMailboxNo()
    const existing = await queryOne('SELECT id FROM users WHERE mailbox_no = ?', [no])
    if (!existing) return no
  }
  throw new Error('无法生成唯一邮箱号')
}

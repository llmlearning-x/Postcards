import 'dotenv/config'
import Fastify from 'fastify'
import cors from '@fastify/cors'
import jwt from '@fastify/jwt'
import multipart from '@fastify/multipart'
import staticFiles from '@fastify/static'
import rateLimit from '@fastify/rate-limit'
import path from 'path'
import { config } from './config'
import { authRoutes } from './routes/auth'
import { userRoutes } from './routes/users'
import { travelRoutes } from './routes/travels'
import { postcardRoutes } from './routes/postcards'
import { mailingRoutes } from './routes/mailings'
import { stampRoutes } from './routes/stamps'
import { uploadRoutes } from './routes/upload'
import { pointsRoutes } from './routes/points'

const app = Fastify({
  logger: {
    level: config.nodeEnv === 'production' ? 'warn' : 'info',
    transport: config.nodeEnv !== 'production'
      ? { target: 'pino-pretty', options: { colorize: true } }
      : undefined,
  },
})

async function bootstrap() {
  // ── 插件注册 ──────────────────────────────────────────────────────
  await app.register(cors, {
    origin: config.cors.origin,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  })

  await app.register(rateLimit, {
    max: 100,
    timeWindow: '1 minute',
    keyGenerator: (req) => req.ip,
    errorResponseBuilder: (req, context) => ({
      statusCode: 429,
      error: 'Too Many Requests',
      message: `请求过于频繁，请稍后再试。限制：${context.max} 次 / ${context.after}`,
      retryAfter: context.after,
    }),
  })

  await app.register(jwt, {
    secret: config.jwt.secret,
  })

  await app.register(multipart, {
    limits: { fileSize: config.upload.maxSizeMb * 1024 * 1024 },
  })

  // 静态文件服务 — 提供 uploads 目录下的图片
  await app.register(staticFiles, {
    root: config.upload.dir,
    prefix: '/uploads/',
    decorateReply: false,
  })

  // 静态文件服务 — 提供 stamps 目录下的邮票图片
  await app.register(staticFiles, {
    root: config.stamps.dir,
    prefix: '/stamps/',
    decorateReply: false,
  })

  // ── 路由注册（统一加 /api 前缀）──────────────────────────────────
  await app.register(authRoutes,     { prefix: '/api' })
  await app.register(userRoutes,     { prefix: '/api' })
  await app.register(travelRoutes,   { prefix: '/api' })
  await app.register(postcardRoutes, { prefix: '/api' })
  await app.register(mailingRoutes,  { prefix: '/api' })
  await app.register(stampRoutes,    { prefix: '/api' })
  await app.register(pointsRoutes,   { prefix: '/api' })
  await app.register(uploadRoutes,   { prefix: '/api' })

  // ── 健康检查 ───────────────────────────────────────────────────────
  app.get('/health', async () => ({ status: 'ok', ts: Date.now() }))

  // ── 启动 ────────────────────────────────────────────────────────────
  await app.listen({ port: config.port, host: config.host })
  console.log(`🚀  Server running on http://${config.host}:${config.port}`)
}

// ── 优雅关闭 ─────────────────────────────────────────────────────────
async function shutdown(signal: string) {
  console.log(`\n${signal} received. Shutting down gracefully...`)
  try {
    await app.close()
    console.log('Server closed.')
    process.exit(0)
  } catch (err) {
    console.error('Error during shutdown:', err)
    process.exit(1)
  }
}

process.on('SIGTERM', () => shutdown('SIGTERM'))
process.on('SIGINT', () => shutdown('SIGINT'))

bootstrap().catch(err => {
  console.error(err)
  process.exit(1)
})

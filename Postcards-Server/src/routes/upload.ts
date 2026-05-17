import { FastifyInstance } from 'fastify'
import { requireAuth } from '../middleware/auth'
import { config } from '../config'
import path from 'path'
import fs from 'fs'
import crypto from 'crypto'
import sharp from 'sharp'

export async function uploadRoutes(app: FastifyInstance) {

  // ── 上传普通图片（明信片照片）────────────────────────────────────
  app.post('/upload/image', { preHandler: requireAuth }, async (req, reply) => {
    const data = await req.file()
    if (!data) return reply.code(400).send({ error: '未收到文件' })

    const mime = data.mimetype
    if (!mime.startsWith('image/')) {
      return reply.code(400).send({ error: '只支持图片文件' })
    }

    const uploadDir = config.upload.dir
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true })
    }

    const ext = '.jpg'
    const filename = crypto.randomBytes(16).toString('hex') + ext
    const filePath = path.join(uploadDir, filename)

    const buffer = await data.toBuffer()
    const maxBytes = config.upload.maxSizeMb * 1024 * 1024
    if (buffer.length > maxBytes) {
      return reply.code(413).send({ error: `文件大小超过 ${config.upload.maxSizeMb}MB 限制` })
    }

    // 压缩为 1200px 最长边，质量 80%，体积比原来减少 40-60%
    await sharp(buffer)
      .rotate()
      .resize(1200, 1200, { fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 80, progressive: true, mozjpeg: true })
      .toFile(filePath)

    const url = `${config.upload.baseUrl}/${filename}`
    return reply.code(201).send({ url })
  })

  // ── 上传头像（单独处理，尺寸更小）────────────────────────────────
  app.post('/upload/avatar', { preHandler: requireAuth }, async (req, reply) => {
    const data = await req.file()
    if (!data) return reply.code(400).send({ error: '未收到文件' })

    const mime = data.mimetype
    if (!mime.startsWith('image/')) {
      return reply.code(400).send({ error: '只支持图片文件' })
    }

    const uploadDir = config.upload.dir
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true })
    }

    const ext = '.jpg'
    const filename = crypto.randomBytes(16).toString('hex') + ext
    const filePath = path.join(uploadDir, filename)

    const buffer = await data.toBuffer()
    const maxBytes = config.upload.maxSizeMb * 1024 * 1024
    if (buffer.length > maxBytes) {
      return reply.code(413).send({ error: `文件大小超过 ${config.upload.maxSizeMb}MB 限制` })
    }

    // 头像压缩为 256x256 正方形，质量 75%，通常 10-30KB
    await sharp(buffer)
      .rotate()
      .resize(256, 256, { fit: 'cover', withoutEnlargement: true })
      .jpeg({ quality: 75, progressive: true, mozjpeg: true })
      .toFile(filePath)

    const url = `${config.upload.baseUrl}/${filename}`
    return reply.code(201).send({ url })
  })
}

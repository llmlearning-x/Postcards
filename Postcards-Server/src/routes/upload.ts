import { FastifyInstance } from 'fastify'
import { requireAuth } from '../middleware/auth'
import { config } from '../config'
import path from 'path'
import fs from 'fs'
import crypto from 'crypto'
import sharp from 'sharp'

export async function uploadRoutes(app: FastifyInstance) {

  // ── 上传图片 ─────────────────────────────────────────────────────
  app.post('/upload/image', { preHandler: requireAuth }, async (req, reply) => {
    const data = await req.file()
    if (!data) return reply.code(400).send({ error: '未收到文件' })

    const mime = data.mimetype
    if (!mime.startsWith('image/')) {
      return reply.code(400).send({ error: '只支持图片文件' })
    }

    // 确保上传目录存在
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

    // 用 sharp 压缩并统一转为 JPEG，最长边不超过 2048px
    await sharp(buffer)
      .rotate()                         // 保留 EXIF 方向
      .resize(2048, 2048, { fit: 'inside', withoutEnlargement: true })
      .jpeg({ quality: 85, progressive: true })
      .toFile(filePath)

    const url = `${config.upload.baseUrl}/${filename}`
    return reply.code(201).send({ url })
  })
}

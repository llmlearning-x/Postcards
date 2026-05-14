import { FastifyRequest, FastifyReply } from 'fastify'

export async function requireAuth(request: FastifyRequest, reply: FastifyReply) {
  try {
    await request.jwtVerify()
  } catch {
    reply.code(401).send({ error: '未登录或 Token 已过期' })
  }
}

// 从已验证的 token 中取 userId
export function userId(request: FastifyRequest): string {
  const payload = request.user as { userId: string }
  return payload.userId
}

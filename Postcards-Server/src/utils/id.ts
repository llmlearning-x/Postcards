import { customAlphabet } from 'nanoid'

const nanoid = customAlphabet('0123456789abcdefghijklmnopqrstuvwxyz', 21)

export function newId(): string {
  return nanoid()
}

// 生成 CN-XXXXXX 格式邮箱号（6位数字）
export function newMailboxNo(): string {
  const n = Math.floor(100000 + Math.random() * 900000)
  return `CN-${n}`
}

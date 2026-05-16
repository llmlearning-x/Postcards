import { query, execute } from '../db/client'
import { newId } from './id'

export const REGISTER_BONUS = 50
export const RECORD_BONUS   = 10
export const SEND_BONUS     = 15
export const RECEIVE_BONUS  = 5
export const DAILY_BONUS    = 5

// 每日可赚积分总上限（注册奖励不计入）
export const DAILY_EARN_CAP = 50

// 不受每日上限限制的行为
const UNCAPPED_REASONS = new Set(['register_bonus'])

// Series I stamps are free and auto-granted on registration
export const FREE_STAMP_IDS = ['classic', 'nature', 'culture', 'city', 'ocean', 'sunset']

// 北京时间 UTC+8 的今日零点（毫秒），与服务器时区无关
export function todayStartMs(): number {
  const OFFSET_MS = 8 * 60 * 60 * 1000
  return Math.floor((Date.now() + OFFSET_MS) / 86400000) * 86400000 - OFFSET_MS
}

export async function addPoints(
  userId: string,
  delta: number,
  reason: string,
  refId?: string,
): Promise<{ added: number; capped: boolean }> {
  if (delta <= 0) return { added: 0, capped: false }

  let actual = delta

  if (!UNCAPPED_REASONS.has(reason)) {
    const dayStart = todayStartMs()
    const rows = await query<{ earned: number }>(
      `SELECT COALESCE(SUM(delta), 0) AS earned
       FROM points_log
       WHERE user_id = ? AND delta > 0 AND reason NOT IN ('register_bonus') AND created_at >= ?`,
      [userId, dayStart],
    )
    const earned = rows[0]?.earned ?? 0
    const remaining = Math.max(0, DAILY_EARN_CAP - earned)
    actual = Math.min(delta, remaining)
  }

  if (actual <= 0) return { added: 0, capped: true }

  await execute('UPDATE users SET points = points + ? WHERE id = ?', [actual, userId])
  await execute(
    'INSERT INTO points_log (id, user_id, delta, reason, ref_id, created_at) VALUES (?, ?, ?, ?, ?, ?)',
    [newId(), userId, actual, reason, refId ?? null, Date.now()],
  )
  return { added: actual, capped: actual < delta }
}

export async function grantFreeStamps(userId: string): Promise<void> {
  const now = Date.now()
  for (const stampId of FREE_STAMP_IDS) {
    await execute(
      'INSERT IGNORE INTO user_stamps (id, user_id, stamp_id, unlocked_at) VALUES (?, ?, ?, ?)',
      [newId(), userId, stampId, now],
    ).catch(() => {})
  }
}

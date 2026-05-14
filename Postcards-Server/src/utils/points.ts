import { execute } from '../db/client'
import { newId } from './id'

export const REGISTER_BONUS = 50
export const RECORD_BONUS   = 10
export const SEND_BONUS     = 15
export const RECEIVE_BONUS  = 5
export const DAILY_BONUS    = 5

// Series I stamps are free and auto-granted on registration
export const FREE_STAMP_IDS = ['classic', 'nature', 'culture', 'city', 'ocean', 'sunset']

export async function addPoints(
  userId: string,
  delta: number,
  reason: string,
  refId?: string,
): Promise<void> {
  if (delta === 0) return
  await execute('UPDATE users SET points = points + ? WHERE id = ?', [delta, userId])
  await execute(
    'INSERT INTO points_log (id, user_id, delta, reason, ref_id, created_at) VALUES (?, ?, ?, ?, ?, ?)',
    [newId(), userId, delta, reason, refId ?? null, Date.now()],
  )
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

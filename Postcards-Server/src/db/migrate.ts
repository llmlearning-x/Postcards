/**
 * 数据库迁移 — 新增社交功能所需的表和字段
 * 运行: npm run db:migrate
 */
import 'dotenv/config'
import { pool, execute } from './client'

async function migrate() {
  console.log('▶ 开始数据库迁移...')

  // 逐列 ALTER（兼容 MySQL 8.0，忽略"column already exists"错误）
  const alterCols = [
    `ALTER TABLE users ADD COLUMN password_hash VARCHAR(100) NOT NULL DEFAULT ''`,
    `ALTER TABLE users ADD COLUMN push_token VARCHAR(512)`,
  ]
  for (const sql of alterCols) {
    await execute(sql).catch(() => {})
  }

  // 确保 mailbox_no 有唯一索引（登录 ID）
  await execute(`CREATE UNIQUE INDEX uk_mailbox ON users (mailbox_no)`).catch(() => {})

  // mailings 表
  await execute(`
    CREATE TABLE IF NOT EXISTS mailings (
      id              VARCHAR(36)   NOT NULL  PRIMARY KEY,
      postcard_id     VARCHAR(36)   NOT NULL,
      sender_id       VARCHAR(36)   NOT NULL,
      recipient_id    VARCHAR(36)   NOT NULL,
      personal_note   VARCHAR(200),
      snapshot        JSON          NOT NULL,
      status          VARCHAR(20)   NOT NULL  DEFAULT 'sent',
      sent_at         BIGINT        NOT NULL,
      opened_at       BIGINT,
      created_at      BIGINT        NOT NULL,
      INDEX idx_sender    (sender_id, sent_at),
      INDEX idx_recipient (recipient_id, status, sent_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `)

  // stamp_designs — 新增 image_url 列
  await execute(`ALTER TABLE stamp_designs ADD COLUMN image_url VARCHAR(512)`).catch(() => {})

  // contacts 表
  await execute(`
    CREATE TABLE IF NOT EXISTS contacts (
      id          VARCHAR(36)   NOT NULL  PRIMARY KEY,
      user_id     VARCHAR(36)   NOT NULL,
      contact_id  VARCHAR(36)   NOT NULL,
      remark_name VARCHAR(50),
      created_at  BIGINT        NOT NULL,
      UNIQUE KEY uk_pair (user_id, contact_id),
      INDEX idx_user (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `)

  // Series II · 古迹 HERITAGE 邮票（补充缺失系列）
  const seriesII = [
    { id: 'greatwall',  name: '长城',   color: '#7A7264', sort_order: 20 },
    { id: 'terracotta', name: '兵马俑', color: '#9C6240', sort_order: 21 },
    { id: 'pagoda',     name: '古塔',   color: '#8B5030', sort_order: 22 },
    { id: 'garden',     name: '苏园',   color: '#3E7058', sort_order: 23 },
    { id: 'canal',      name: '水乡',   color: '#3B5E7A', sort_order: 24 },
  ]
  for (const s of seriesII) {
    await execute(
      `INSERT IGNORE INTO stamp_designs (id, name, series, color, sort_order) VALUES (?, ?, 'II', ?, ?)`,
      [s.id, s.name, s.color, s.sort_order]
    ).catch(() => {})
  }

  // 积分系统：users.points 字段
  await execute(`ALTER TABLE users ADD COLUMN points INT NOT NULL DEFAULT 0`).catch(() => {})

  // user_stamps 表 — 记录用户拥有的邮票
  await execute(`
    CREATE TABLE IF NOT EXISTS user_stamps (
      id          VARCHAR(36)   NOT NULL  PRIMARY KEY,
      user_id     VARCHAR(36)   NOT NULL,
      stamp_id    VARCHAR(50)   NOT NULL,
      unlocked_at BIGINT        NOT NULL,
      UNIQUE KEY uk_user_stamp (user_id, stamp_id),
      INDEX idx_user (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `)

  // points_log 表 — 积分流水明细
  await execute(`
    CREATE TABLE IF NOT EXISTS points_log (
      id          VARCHAR(36)   NOT NULL  PRIMARY KEY,
      user_id     VARCHAR(36)   NOT NULL,
      delta       INT           NOT NULL,
      reason      VARCHAR(100)  NOT NULL,
      ref_id      VARCHAR(36),
      created_at  BIGINT        NOT NULL,
      INDEX idx_user_ts (user_id, created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `)

  console.log('✅ 迁移完成')
  await pool.end()
}

migrate().catch(e => { console.error('❌ 迁移失败:', e); process.exit(1) })

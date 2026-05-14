import mysql from 'mysql2/promise'
import { config } from '../config'

export const pool = mysql.createPool({
  host:            config.db.host,
  port:            config.db.port,
  database:        config.db.database,
  user:            config.db.user,
  password:        config.db.password,
  waitForConnections: true,
  connectionLimit: 10,
  charset:         'utf8mb4',
})

export async function query<T = any>(sql: string, values?: any[]): Promise<T[]> {
  const [rows] = await pool.execute(sql, values)
  return rows as T[]
}

export async function queryOne<T = any>(sql: string, values?: any[]): Promise<T | null> {
  const rows = await query<T>(sql, values)
  return rows[0] ?? null
}

export async function execute(sql: string, values?: any[]): Promise<{ affectedRows: number; insertId: number }> {
  const [result] = await pool.execute(sql, values) as any
  return { affectedRows: result.affectedRows, insertId: result.insertId }
}

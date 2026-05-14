import path from 'path'

function require_env(key: string): string {
  const v = process.env[key]
  if (!v) throw new Error(`Missing env: ${key}`)
  return v
}

export const config = {
  port:    parseInt(process.env.PORT || '3000'),
  host:    process.env.HOST || '0.0.0.0',
  nodeEnv: process.env.NODE_ENV || 'development',

  db: {
    host:     require_env('DB_HOST'),
    port:     parseInt(process.env.DB_PORT || '3306'),
    database: require_env('DB_NAME'),
    user:     require_env('DB_USER'),
    password: require_env('DB_PASS'),
  },

  jwt: {
    secret:        require_env('JWT_SECRET'),
    refreshSecret: require_env('JWT_REFRESH_SECRET'),
    accessExpiry:  '7d',
    refreshExpiry: '30d',
  },

  upload: {
    dir:     process.env.UPLOAD_DIR || path.join(process.cwd(), 'uploads'),
    baseUrl: process.env.UPLOAD_BASE_URL || 'http://localhost:3000/uploads',
    maxSizeMb: parseInt(process.env.MAX_FILE_SIZE_MB || '10'),
  },

  stamps: {
    dir:     path.join(process.cwd(), 'stamps'),
    baseUrl: process.env.STAMPS_BASE_URL || 'http://localhost:3000/stamps',
  },

  cors: {
    origin: (process.env.CORS_ORIGIN || 'http://localhost:3000').split(',').map(s => s.trim()),
  },
}

module.exports = {
  apps: [
    {
      name: 'postcards-api',
      script: './dist/index.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
      // 读取同目录下的 .env 文件
      env_file: '/path/to/postcards/.env',
      error_file: '/path/to/postcards/logs/err.log',
      out_file:   '/path/to/postcards/logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
    },
  ],
}

import { defineConfig, loadEnv } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_')
  
  // 只保留生产环境 URL（本地开发通过 Vite proxy 走 /api）
  const apiUrl = env.VITE_API_BASE_URL || 'http://115.190.7.207/api'
  const stampsUrl = env.VITE_STAMPS_BASE_URL || 'http://115.190.7.207/stamps'
  
  console.log('>>> MODE:', mode, 'API_URL:', apiUrl, 'STAMPS_URL:', stampsUrl)
  
  return {
    define: {
      __API_BASE_URL__: JSON.stringify(apiUrl),
      __STAMPS_BASE_URL__: JSON.stringify(stampsUrl),
    },
    plugins: [uni()],
    css: {
      preprocessorOptions: {
        scss: {
          api: 'modern',
          additionalData: `@use "@/styles/variables.scss" as *;`
        }
      }
    },
    server: {
      proxy: {
        '/api': {
          target: 'http://115.190.7.207',
          changeOrigin: true,
        },
        '/stamps': {
          target: 'http://115.190.7.207',
          changeOrigin: true,
        },
      }
    }
  }
})

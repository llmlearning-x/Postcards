import { defineConfig, loadEnv } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_')
  
  // 显式注入环境变量（uni-app alpha 版 import.meta.env 替换有 bug）
  const apiUrl = env.VITE_API_BASE_URL || (mode === 'test' ? 'http://115.175.15.145/api' : 'http://115.190.7.207/api')
  const stampsUrl = env.VITE_STAMPS_BASE_URL || (mode === 'test' ? 'http://115.175.15.145/stamps' : 'http://115.190.7.207/stamps')
  
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
          target: 'http://115.175.15.145',
          changeOrigin: true,
        },
        '/stamps': {
          target: 'http://115.175.15.145',
          changeOrigin: true,
        },
      }
    }
  }
})

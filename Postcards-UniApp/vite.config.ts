import { defineConfig } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'

export default defineConfig({
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
})

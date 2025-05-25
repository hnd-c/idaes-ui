import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import * as path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  build:{
    outDir:'../idaes_ui/fv/static'
  },
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    }
  },
  define: {
    'import.meta.env.VITE_MODE': JSON.stringify(process.env.VITE_MODE || 'prod')
  }
})
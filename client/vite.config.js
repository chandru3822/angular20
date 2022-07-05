import vue from '@vitejs/plugin-vue2'
import path from 'path'
import { VuetifyResolver } from 'unplugin-vue-components/resolvers'
import Components from 'unplugin-vue-components/vite'


export default {
  plugins: [
    vue(),
    Components({
      resolvers: [
        VuetifyResolver()
      ]
    })],
  resolve: {
    extensions: ['.js', '.vue', '.json', '.mjs'],
    alias: [
      { find: '@', replacement: path.resolve(__dirname, './src') },
    ]
  },
  build: {
    sourcemap: true
  },
  optimizeDeps: {
    include: ['map-promisified', 'mapbox-gl']
  }
}

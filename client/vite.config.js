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
  css: {
    // https://vitejs.dev/config/#css-preprocessoroptions
    preprocessorOptions: {
      sass: {
        additionalData: [
          // vuetify variable overrides
          '@import "@/styles/variables.scss"',
          '',
        ].join('\n'),
      },
    },
  },
  build: {
    sourcemap: true
  },
  optimizeDeps: {
    include: ['mapbox-gl']
  }
}

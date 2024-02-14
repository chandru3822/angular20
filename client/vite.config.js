import vue from '@vitejs/plugin-vue2'
import path from 'path'
import { VuetifyResolver } from 'unplugin-vue-components/resolvers'
import Components from 'unplugin-vue-components/vite'
import { VitePWA } from 'vite-plugin-pwa'

export default {
  server: {
    port: 3000
  },
  plugins: [
    vue(),
    Components({
      resolvers: [VuetifyResolver()]
    }),
    VitePWA({
      strategies: 'injectManifest',
      injectRegister: false,
      srcDir: 'src',
      filename: 'firebase-messaging-sw.js',
      manifest: false,
      injectManifest: {
        injectionPoint: undefined,
      },
      devOptions: {
        enabled: true,
        type:'module'
      }
    })
  ],
  resolve: {
    extensions: ['.js', '.vue', '.json', '.mjs'],
    alias: [{ find: '@', replacement: path.resolve(__dirname, './src') }]
  },
  css: {
    // https://vitejs.dev/config/#css-preprocessoroptions
    preprocessorOptions: {
      sass: {
        additionalData: [
          // vuetify variable overrides
          '@import "@/styles/variables.scss"',
          ''
        ].join('\n')
      }
    }
  },
  build: {
    sourcemap: true
  },
  optimizeDeps: {
    include: ['mapbox-gl']
  }
}

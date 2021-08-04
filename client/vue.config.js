const MomentLocalesPlugin = require('moment-locales-webpack-plugin');

module.exports = {
  chainWebpack: config => config
    .plugins.delete('prefetch').end()
    .plugin('moment-locales-webpack-plugin').use(MomentLocalesPlugin).end()
    .plugin('webpack-bundle-analyzer').tap(args => [...args, {
      openAnalyzer: false
    }]).end()
    .devtool('source-map')
    .optimization
    .splitChunks({
      chunks: 'all',
      // minSize: 100000
    }),

  pluginOptions: {
    webpackBundleAnalyzer: {
      openAnalyzer: false
    }
  },

  pwa: {
    workboxPluginMode: 'InjectManifest',
    workboxOptions: {
      swSrc: './src/service-worker.js',
      swDest: 'service-worker.js'
    }
  }
}

const MomentLocalesPlugin = require('moment-locales-webpack-plugin');

module.exports = {
  chainWebpack: config => config
    .plugins.delete('prefetch').end()
    .plugin('moment-locales-webpack-plugin').use(MomentLocalesPlugin).end()
    .plugin('webpack-bundle-analyzer').tap(args => [...args, {
      analyzerMode: process.env.NODE_ENV === 'production' ? 'disabled' : 'static',
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
      analyzerMode: process.env.NODE_ENV === 'production' ? 'disabled' : 'static',
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

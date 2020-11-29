module.exports = {
  configureWebpack: {
    devtool: 'source-map'
  },
  pwa: {
    workboxPluginMode: 'InjectManifest',
    workboxOptions: {
      swSrc: 'client/src/service-worker.js',
      swDest: 'service-worker.js'
    }
  }
}

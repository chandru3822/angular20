module.exports = {
  configureWebpack: {
    devtool: 'source-map'
  },
  devServer: {
    proxy: process.env.VUE_APP_ENV === 'dev' ?
        'https://dev-albatross-api.myblueraven.com' :
        process.env.VUE_APP_ENV === 'uat' ?
          'https://uat-albatross-api.myblueraven.com' :
          process.env.VUE_APP_ENV === 'prod' ?
            'https://prod-albatross-api.myblueraven.com' : 'http://localhost:8080'
  }
}

import Vue from 'vue'
import './plugins/vuetify'
import App from './App.vue'
import router from './router'
import store from './store'
import axios from 'axios'
import { UserMutations } from './stores/UserStore'
import JsonExcel from 'vue-json-excel'
import moment from 'moment'

// @todo: make PWA awesomeness
// import './registerServiceWorker'

const { VUE_APP_BASE_API } = process.env
const JWT_EXPIRED = 'invalid token'

Vue.config.productionTip = false

Vue.component('downloadExcel', JsonExcel)

Vue.filter('formatDate', function (value, format) {
  if (value && format) {
    return moment(String(value)).format(format)
  } else if (value) {
    // default format if none provided
    return moment(String(value)).format('M/D/YYYY')
  }
})

axios.interceptors.request.use(config => {
  if (store && store.state && store.state.user && config.url.indexOf(VUE_APP_BASE_API) > -1) {
    config.headers['Authorization'] = `Bearer ${store.state.user.jwt}`
  }
  return config
})

axios.interceptors.response.use((response) => {
  return response
}, ({ response }) => {
  if (response && response.data) {
    const { message } = response.data
    console.log('*** Request Error ***', response)
    // if the jwt token expired
    if (message && message.toLowerCase().indexOf(JWT_EXPIRED) > -1) {
      localStorage.removeItem('store')
      store.commit(UserMutations.LOGIN_ERROR, 'Session Expired')
      router.push({ name: 'login' })
    }
  }
})

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')

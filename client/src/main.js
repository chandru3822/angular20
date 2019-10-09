import Vue from 'vue'
import Vuetify from './plugins/vuetify'
import Vue2Filters from 'vue2-filters'
import App from './App.vue'
import router from './router'
import store from './store'
import axios from 'axios'
import VueFlatPickr from 'vue-flatpickr-component'
import 'flatpickr/dist/flatpickr.css'
import { UserMutations } from './stores/UserStore'
import JsonExcel from 'vue-json-excel'
// import moment from 'moment'
import moment from 'moment-timezone'

// @todo: make PWA awesomeness
import './registerServiceWorker'

const { VUE_APP_BASE_API } = process.env
const JWT_EXPIRED = 'invalid token'

Vue.config.productionTip = false

Vue.component('downloadExcel', JsonExcel)

Vue.use(Vue2Filters)
Vue.use(VueFlatPickr)

Vue.filter('formatDate', function (value, type, timezone, format) {
  /*
  //  this part of the code: `moment(String(value))` was throwing format warnings from moment with regular timestamp formats
  //  i can probably handle more scenarios but for now these don't throw errors: .format('YYYY-MM-DD') OR .format('YYYY-MM-DDTHH:mm:ssZ')
  //  TYPES: 'date', 'timestamp'
  */

  if(!type || (type === 'timezone' && !timezone)) {
    console.error('TYPE IS REQUIRED, TIMEZONE IS REQUIRED FOR TIMESTAMPS')
    return
  }

  if (value && format) {
    return moment(String(value)).tz(timezone).format(format)
  } else if (value) {
    // default format if none provided, date doesn't do anything with timezone, just reformats the string
    return type === 'date' ? moment(String(value)).format('M/D/YYYY') : moment(String(value)).tz(timezone).format('M/D/YYYY h:mm a')
  }
})

router.beforeEach((to, from, next) => {
  document.title = to.meta.title || 'BRS Albatross Placeholder'
  next()
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


Vue.use(Vuetify)

new Vue({
  router,
  store,
  vuetify: Vuetify,
  render: h => h(App)
}).$mount('#app')

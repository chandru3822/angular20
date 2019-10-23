import Vue from 'vue'
import Vuetify from './plugins/vuetify'
import Vue2Filters from 'vue2-filters'
import App from './App.vue'
import router from './router'
import store from './store'
import axios from 'axios'
import VueFlatPickr from 'vue-flatpickr-component'
import 'flatpickr/dist/flatpickr.css'
import 'mapbox-gl/dist/mapbox-gl.css'
import '@fullcalendar/core/main.css'
import '@fullcalendar/timeline/main.css'
import '@fullcalendar/resource-timeline/main.css'
import { UserMutations } from './stores/UserStore'
import JsonExcel from 'vue-json-excel'
// import moment from 'moment'
import moment from 'moment-timezone'
import devtools from '@vue/devtools'
import VueMapbox from 'vue-mapbox'
import Mapbox from 'mapbox-gl'

// @todo: make PWA awesomeness
import './registerServiceWorker'

const { VUE_APP_BASE_API, VUE_APP_ENV, NODE_ENV } = process.env

if (NODE_ENV === 'development') {
  devtools.connect('http://localhost', 8098)
}

const JWT_EXPIRED = 'invalid token'

Vue.config.productionTip = false

Vue.component('downloadExcel', JsonExcel)

Vue.use(Vue2Filters)
Vue.use(VueFlatPickr)
Vue.use(VueMapbox, { mapboxgl: Mapbox });

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
    // if the jwt token expired, or 401 unauthorized, or 403 Forbidden
    if ((message && message.toLowerCase().indexOf(JWT_EXPIRED) > -1)
        || response.status === 401  || response.status === 403) {
      const msg = response.status === 401  || response.status === 403 ? 'User Unauthorized' : 'Session Expired'
      localStorage.removeItem('store')
      store.commit(UserMutations.LOGIN_ERROR, msg)
      router.push({ name: 'login' })
    } else if (VUE_APP_ENV !== 'local' && response.status >= 500 && response.status <= 599) {
      //remove the loading spinner that was likely turned on before this error happened
      store.commit(UserMutations.SET_LOADING, false)
      //dont do this reroute on local, it is super annoying
      router.push({path: `/serverError?code=${response.status}`})
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

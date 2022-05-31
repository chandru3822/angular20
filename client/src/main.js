import Vue from 'vue'
import Vuetify from './plugins/vuetify'
import Chat from 'vue-beautiful-chat'
import Vue2Filters from 'vue2-filters'
import App from './App.vue'
import router from './router'
import store from './store'
import axios from 'axios'
import { UserMutations } from '@/stores/UserStore'
import { AppMutations } from '@/stores/AppStore'
import moment from 'moment-timezone'
import VueGtag from 'vue-gtag'

import '@/styles/main.scss'

// @todo: make PWA awesomeness
import './registerServiceWorker'

const { VUE_APP_BASE_API, VUE_APP_ENV, VUE_APP_GA_ID, VUE_APP_MAINTENANCE_MODE } = process.env
const JWT_EXPIRED = 'invalid token'

Vue.config.productionTip = false

Vue.use(Vue2Filters)
Vue.prototype.$filters = Vue.options.filters

//this filter is only used for the zoneless time picker stuff
Vue.filter('formatDateZoneless', function (value) {
  if (value) {
    return moment.utc(String(value), 'HH:mm:ss').format('h:mm a')
  }
})

Vue.filter('formatDate', function (value, type, format, inputFormat) {
  /*
  //  this part of the code: `moment(String(value))` was throwing format warnings from moment with regular timestamp formats
  //  i can probably handle more scenarios but for now these don't throw errors: .format('YYYY-MM-DD') OR .format('YYYY-MM-DDTHH:mm:ssZ')
  //  TYPES: 'date', 'timestamp'
  */

  const timezone = store?.state?.user?.details?.timezone?.value

  if (!type || (type === 'timestamp' && !timezone)) {
    console.error('TYPE IS REQUIRED, TIMEZONE IS REQUIRED FOR TIMESTAMPS')
    return
  }

  // default format if none provided
  if (!format) {
    // timestampAsDate means do the timezone conversion but then only display the date
    format =
      type === 'date' || type === 'timestampAsDate'
        ? 'M/D/YYYY'
        : 'M/D/YYYY h:mm a'
  }

  if (value) {
    // date doesn't do anything with timezone, just reformats the string
    // leave it be = assume it is already in the right timezone and dont mess with it
    return type === 'date'
      ? moment.utc(String(value), inputFormat ?? null).format(format)
      : moment
          .utc(String(value), inputFormat ?? null)
          .tz(timezone)
          .format(format)
  }
})

router.beforeEach((to, from, next) => {
  document.title = to.meta.title || 'Albatross'
  next()
})

axios.interceptors.request.use((config) => {
  if (
    store &&
    store.state &&
    store.state.user &&
    (config.baseURL?.indexOf(VUE_APP_BASE_API) > -1 || config.url.indexOf(VUE_APP_BASE_API) > -1)
  ) {
    config.headers['Authorization'] = `Bearer ${store.state.user.jwt}`
  }

  // if config.source passed in then use that
  let source = config.source
  //dont cancel if override sent in
  let skipCancel = config.skipCancel

  if (!source) {
    // if no source passed in, Generate cancel token source
    source = axios.CancelToken.source()
    config.cancelToken = source.token
  }

  // Add to vuex to make cancellation available from anywhere
  // todo: investigate using parent/child route detection instead of a param that gets passed in and always skipsCancel even if leaving the route tree
  if(!skipCancel) {
    store.commit('ADD_CANCEL_TOKEN', source)
  }
  return config
})

axios.interceptors.response.use(
  (response) => {
    return response
  },
  ({ response }) => {
    if (response) {
      const { message } = response?.data
      const { status } = response
      console.error('*** Request Error ***', response)
      // if the jwt token expired, or 401 unauthorized, or 403 Forbidden
      if (
        (message && message.toLowerCase().indexOf(JWT_EXPIRED) > -1) ||
        status === 401 ||
        status === 403
      ) {
        const msg =
          response.status === 401
            ? 'Session Expired'
            : response.status === 403
            ? 'User Unauthorized'
            : 'Unknown Error'
        if(response?.data?.maintenanceMode && status === 403) {
          //if we dont remove the store item then a logged in user who USED to have permission will still have permission later
          localStorage.removeItem('store')
          router.push({ name: 'siteUnderMaintenance' })
        } else {
          localStorage.removeItem('store')
          store.commit(UserMutations.LOGIN_ERROR, msg)
          router.push({ name: 'login' })
        }
      } else if (status >= 500 && status <= 599) {
        //remove the loading spinner that was likely turned on before this error happened
        store.commit(AppMutations.SET_LOADING, false)
        //dont do this reroute on local, it is super annoying
        if (VUE_APP_ENV !== 'local') {
          router.push({ path: `/serverError?code=${response.status}` })
        }
      } else if (![200, 201, 204].includes(status)) {
        //dont take this out, it makes axios await errors work correctly
        throw { data: response?.data, status }
      }
    }
  }
)

Vue.use(
  VueGtag,
  {
    config: { id: VUE_APP_GA_ID },
  },
  router
)

Vue.use(Chat)

new Vue({
  router,
  store,
  vuetify: Vuetify,
  render: (h) => h(App),
}).$mount('#app')

import Vue from 'vue'
import Vuetify from '@/plugins/vuetify'
import Chat from 'vue-beautiful-chat'
import Vue2Filters from 'vue2-filters'
import App from '@/App.vue'
import router from '@/router'
import store, { pinia } from '@/store'
import axios from 'axios'
import { SnackbarPlugin } from '@/plugins/SnackbarPlugin'
import moment from 'moment-timezone'
import VueGtag from 'vue-gtag'

import '@/styles/main.scss'
import { requestInterceptor, responseInterceptor  } from '@/helpers/interceptors'
import { useUserStore } from '@/stores/UserStorePinia.js'

const { VITE_GA_ID } = import.meta.env
Vue.config.productionTip = false

Vue.use(SnackbarPlugin)
Vue.use(Vue2Filters)
Vue.prototype.$filters = Vue.options.filters

//this filter is only used for the zoneless time picker stuff
Vue.filter('formatDateZoneless', function(value) {
  if (value) {
    return moment.utc(String(value), 'HH:mm:ss').format('h:mm a')
  }
})

Vue.filter('formatDate', function(value, type, format, inputFormat) {
  /*
  //  this part of the code: `moment(String(value))` was throwing format warnings from moment with regular timestamp formats
  //  i can probably handle more scenarios but for now these don't throw errors: .format('YYYY-MM-DD') OR .format('YYYY-MM-DDTHH:mm:ssZ')
  //  TYPES: 'date', 'timestamp'
  */

  const userStore = useUserStore()

  let timezone = userStore.details?.timezone?.value

  if (!timezone) {
    userStore.guessTimeZone()
    timezone = userStore.details?.timezone?.value
  }

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

axios.interceptors.request.use(requestInterceptor)
axios.interceptors.response.use((r) => r, responseInterceptor)

Vue.use(
  VueGtag,
  {
    config: { id: VITE_GA_ID }
  },
  router
)

Vue.use(Chat)

new Vue({
  router,
  store,
  vuetify: Vuetify,
  pinia,
  render: (h) => h(App)
}).$mount('#app')


if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register(
    import.meta.env.MODE === 'production' ? '/firebase-messaging-sw.js' : '/dev-sw.js?dev-sw',
    { type: import.meta.env.MODE === 'production' ? 'classic' : 'module' }
  )
}

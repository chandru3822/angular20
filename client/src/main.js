import Vue from 'vue'
import Vuetify from '@/plugins/vuetify'
import Chat from 'vue-beautiful-chat'
import App from '@/App.vue'
import router from '@/router'
import pinia from '@/store'
import logger from '@/logger.js'
import axios from 'axios'
import moment from 'moment-timezone'
import VueGtag from 'vue-gtag'
import AlbatrossTextField from '@/components/customVuetify/AlbatrossTextField.vue'
import AlbatrossTextarea from '@/components/customVuetify/AlbatrossTextarea.vue'
import AlbatrossButton from '@/components/customVuetify/AlbatrossButton.vue'
import AlbatrossSelect from '@/components/customVuetify/AlbatrossSelect.vue'
import AlbatrossAutocomplete from '@/components/customVuetify/AlbatrossAutocomplete.vue'

import '@/styles/main.scss'
import { requestInterceptor, responseInterceptor } from '@/helpers/interceptors'
import { useUserStore } from '@/stores/UserStore.js'
import { useScheduleStore } from '@/stores/ScheduleStore.js'

const { VITE_GA_ID, VITE_SENTRY_DSN } = import.meta.env

Vue.config.productionTip = false
Vue.prototype.$filters = Vue.options.filters

Vue.filter('currency', function (value, symbol, digits) {
  if (typeof value != 'number' || typeof digits != 'number') {
    return
  } else {
    return symbol + parseFloat(value).toFixed(digits)
  }
})

Vue.filter('percent', function (value, digits = 0) {
  if (typeof value != 'number' || typeof digits != 'number') return

  value = value * 100

  let integer = parseInt(value)

  if (value === integer) return value + '%'
  else {
    return parseFloat(value).toFixed(digits) + '%'
  }
})

//this filter is only used for the zoneless time picker stuff
Vue.filter('formatDateZoneless', function (value) {
  if (value) {
    return moment.utc(String(value), 'HH:mm:ss').format('h:mm a')
  }
})

Vue.filter('searchHighlight', function (value, query, ignoreWhiteSpace = false) {
  if (value) {
    if (ignoreWhiteSpace === true) {
      const queryLength = query.length
      query = query.replace(/\s/g, '')
      let newQuery = ''
      for (const char of query) {
        console.log(char)
        newQuery = newQuery.concat(char, ' ?')
      }
      query = "[(".concat(newQuery, ")]{", queryLength,",}")
    }
    return value.replace(
      new RegExp(query, 'ig'),
      (v) => `<span class="grey lighten-2">${v}</span>`
    )
  }
})

Vue.filter('fieldValues', function (field) {
  if (Array.isArray(field.values)) {
    return field?.values?.join(', ')
  }
  return field.values
})

Vue.filter('formatDate', function (value, type, format, inputFormat) {
  /*
  //  this part of the code: `moment(String(value))` was throwing format warnings from moment with regular timestamp formats
  //  i can probably handle more scenarios but for now these don't throw errors: .format('YYYY-MM-DD') OR .format('YYYY-MM-DDTHH:mm:ssZ')
  //  TYPES: 'date', 'timestamp'
  */

  const userStore = useUserStore()
  const scheduleStore = useScheduleStore()

  let timezone = userStore.timezone.value

  //The schedule screen has it's own timezone. Use that if user is on schedule screen, else default to regular timezone
  if (
    router.currentRoute.name === 'schedule' &&
    scheduleStore.timezone?.value
  ) {
    timezone = scheduleStore.timezone.value
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

//add the Albatross Components Globally so we can stop importing them everywhere
Vue.component('a-autocomplete', AlbatrossAutocomplete)
Vue.component('a-select', AlbatrossSelect)
Vue.component('a-text-field', AlbatrossTextField)
Vue.component('a-textarea', AlbatrossTextarea)
Vue.component('a-btn', AlbatrossButton)

Vue.use(
  VueGtag,
  {
    config: { id: VITE_GA_ID }
  },
  router
)

Vue.use(Chat)

if (VITE_SENTRY_DSN) {
  logger(VITE_SENTRY_DSN, router)
}

new Vue({
  router,
  vuetify: Vuetify,
  pinia,
  render: (h) => h(App)
}).$mount('#app')

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register(
    import.meta.env.MODE === 'production'
      ? '/firebase-messaging-sw.js'
      : '/dev-sw.js?dev-sw',
    { type: import.meta.env.MODE === 'production' ? 'classic' : 'module' }
  )
}

import Vue from 'vue'
import Vuetify from '@/plugins/vuetify'
import Chat from 'vue-beautiful-chat'
import App from '@/App.vue'
import router from '@/router'
import pinia from '@/store'
import axios from 'axios'
import { SnackbarPlugin } from '@/plugins/SnackbarPlugin'
import moment from 'moment-timezone'
import VueGtag from 'vue-gtag'
import AlbatrossTextField from '@/components/customVuetify/AlbatrossTextField.vue'
import AlbatrossTextarea from '@/components/customVuetify/AlbatrossTextarea.vue'
import AlbatrossButton from '@/components/customVuetify/AlbatrossButton.vue'
import AlbatrossSelect from '@/components/customVuetify/AlbatrossSelect.vue'
import AlbatrossAutocomplete from '@/components/customVuetify/AlbatrossAutocomplete.vue'

import '@/styles/main.scss'
import { requestInterceptor, responseInterceptor  } from '@/helpers/interceptors'
import { useUserStore } from '@/stores/UserStore.js'
import { useScheduleStore } from '@/stores/ScheduleStore.js'

const { VITE_GA_ID } = import.meta.env
Vue.config.productionTip = false

Vue.use(SnackbarPlugin)
Vue.prototype.$filters = Vue.options.filters

//todo: @kaleb the filters in your mixin.js didnt seem to be working
Vue.filter('capitalize', function(value) {
  if (!value) return
  return value[0].toUpperCase() + value?.slice(1).toLowerCase()
})

Vue.filter('currency', function (value, symbol, digits) {
  if (typeof value != "number" || typeof digits != "number")
    return

  let integer = parseInt(value);

  if (value === integer)
    return symbol + value;
  else {
    return symbol + parseFloat(value).toFixed(digits);
  }
});

Vue.filter('percent', function (value, digits = 0) {
  if (typeof value != "number" || typeof digits != "number")
    return

  value = value * 100

  let integer = parseInt(value);

  if (value === integer)
    return value + '%';
  else {
    return parseFloat(value).toFixed(digits) + '%';
  }
});
//todo: kaleb, most of this stuff is for proposals but it wasn't working in the mixins.js file
const dateTimeFormat = new Intl.DateTimeFormat('default', {
  dateStyle: 'short',
  timeStyle: 'short'
})

const numberFormat = new Intl.NumberFormat('default', {
  maximumFractionDigits: 15
})

Vue.filter('customValueFormatter', function({value, type}) {
  if (Array.isArray(value)) {
    return value?.join(', ')
  }

  if (type === 'timestamp') {
    return dateTimeFormat.format(new Date(value))
  }

  if (!isNaN(value) && (type === 'numeric' || type === 'integer')) {
    return numberFormat.format(value)
  }

  if (type === 'boolean') {
    return value ? '✔' : ''
  }
  return value
})

//this filter is only used for the zoneless time picker stuff
Vue.filter('formatDateZoneless', function(value) {
  if (value) {
    return moment.utc(String(value), 'HH:mm:ss').format('h:mm a')
  }
})

Vue.filter('searchHighlight', function(value, query) {
  if (value) {
    return value.replace(new RegExp(query, "ig"),(v) => `<span class="grey lighten-2">${v}</span>`)
  }
})

Vue.filter('fieldValues', function(field) {
    if (Array.isArray(field.values)) {
        return field?.values?.join(', ')
    }
    return field.values
})

Vue.filter('formatDate', function(value, type, format, inputFormat) {
  /*
  //  this part of the code: `moment(String(value))` was throwing format warnings from moment with regular timestamp formats
  //  i can probably handle more scenarios but for now these don't throw errors: .format('YYYY-MM-DD') OR .format('YYYY-MM-DDTHH:mm:ssZ')
  //  TYPES: 'date', 'timestamp'
  */

  const userStore = useUserStore()
  const scheduleStore = useScheduleStore()

  let timezone = userStore.timezone.value

  //The schedule screen has it's own timezone. Use that if user is on schedule screen, else default to regular timezone
  if (router.currentRoute.name === 'schedule' && scheduleStore.timezone?.value) {
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

new Vue({
  router,
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

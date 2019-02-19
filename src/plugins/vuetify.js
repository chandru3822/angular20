import Vue from 'vue'
import Vuetify from 'vuetify/lib'
import 'vuetify/src/stylus/app.styl'
import 'vuetify/src/stylus/main.styl'

Vue.use(Vuetify, {
  iconfont: 'md',
  options: {
    customProperties: true
  },
  theme: {
    primary: '#30363c',
    primaryCustom: '#30363c',
    secondary: '#f2f2f2',
    secondaryCustom: '#f2f2f2',
    brGreen: '#73d697',
    brRed: '#ee6f6a',
    brBlue: '#2292cc',
    primaryButton: '#157efb',
    secondaryButton: '#878787',
    calendarBorder: '#f2f5f8'
  }
})

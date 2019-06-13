import Vue from 'vue'
import Vuetify from 'vuetify/lib'
import 'vuetify/src/stylus/app.styl'
import 'vuetify/src/stylus/main.styl'
import 'material-design-icons-iconfont/dist/material-design-icons.css'

Vue.use(Vuetify, {
  iconfont: 'md',
  options: {
    customProperties: true
  },
  theme: {
    primary: '#1F3C73',
    primaryCustom: '#1F3C73',
    secondary: '#f2f2f2',
    secondaryCustom: '#f2f2f2',
    rowShade: '#EAEAF4',
    rowShadeCustom: '#EAEAF4',
    brGreen: '#73d697',
    brRed: '#ee6f6a',
    brBlue: '#2292cc',
    primaryButton: '#1F3C73',
    secondaryButton: '#878787',
    calendarBorder: '#f2f5f8',
    primaryText: '#1F3C73'
  },
})

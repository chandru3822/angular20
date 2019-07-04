import Vue from 'vue'
import Vuetify from 'vuetify'
// import 'vuetify/src/stylus/app.styl'
import 'vuetify/dist/vuetify.min.css'
import 'material-design-icons-iconfont/dist/material-design-icons.css'

Vue.use(Vuetify)

export default new Vuetify({
  iconfont: 'md',
  options: {
    customProperties: true
  },
  theme: {
    themes: {
      light: {
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
      // dark: {
      //   primary: '#1F3C73',
      //   primaryCustom: '#1F3C73',
      //   secondary: '#f2f2f2',
      //   secondaryCustom: '#f2f2f2',
      //   rowShade: '#EAEAF4',
      //   rowShadeCustom: '#EAEAF4',
      //   brGreen: '#73d697',
      //   brRed: '#ee6f6a',
      //   brBlue: '#2292cc',
      //   primaryButton: '#1F3C73',
      //   secondaryButton: '#878787',
      //   calendarBorder: '#f2f5f8',
      //   primaryText: '#1F3C73'
      // }
    },
    //   primary: '#1F3C73',
    //   primaryCustom: '#1F3C73',
    //   secondary: '#f2f2f2',
    //   secondaryCustom: '#f2f2f2',
    //   rowShade: '#EAEAF4',
    //   rowShadeCustom: '#EAEAF4',
    //   brGreen: '#73d697',
    //   brRed: '#ee6f6a',
    //   brBlue: '#2292cc',
    //   primaryButton: '#1F3C73',
    //   secondaryButton: '#878787',
    //   calendarBorder: '#f2f5f8',
    //   primaryText: '#1F3C73'
  },
})

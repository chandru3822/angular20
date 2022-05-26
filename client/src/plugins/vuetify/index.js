import Vue from 'vue'
import Vuetify from 'vuetify/lib'
// import 'vuetify/dist/vuetify.min.css'
// import 'material-design-icons-iconfont/dist/material-design-icons.css'
import '@mdi/font/css/materialdesignicons.css'
// note: to use font awesome just need to npm install it then import it here. do not need to update `iconfont: 'fa'` unless you want that to override
// all of the icons used by default.  specifically the checkboxes on v-data-tables currently look bad with font-awesome as default
// import '@fortawesome/fontawesome-free/css/all.css'

Vue.use(Vuetify)

export default new Vuetify({
  icons: {
    iconfont: 'mdi'
  },
  theme: {
    options: {
      customProperties: true
    },
    themes: {
      light: {
        primary: '#1F3C73',
        secondary: '#F6F7F8',

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

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
        primary: {
            base:'#1F3C73',
            lighten1:'#3c538d',
            lighten2:'#576ba7',
            lighten3:'#7184c3',
            lighten4:'#8c9edf',
            lighten5:'#a8b9fc',
            lighten6:'#EAEAF4',
            darken1:'#00275a',
            darken2:'#001342',
            darken3:'#00002c',
            darken4:'#00001a'
        },
        secondary: '#F6F7F8',
        error:'#B4221F'
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

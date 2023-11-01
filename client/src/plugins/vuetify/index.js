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
                  lighten1:'#2c5893',
                  lighten2:'#3368a5',
                  lighten3:'#3c79b6',
                  lighten4:'#4486c3',
                  lighten5:'#5796cb',
                  lighten6:'#6fa7d3',
                  lighten7:'#94c0e0',
                  lighten8:'#bbd8ec',
                  lighten9:'#e3eff7'
              },
              secondary: '#F6F7F8',
              accent: '#3c79b6',
              error:{
                  base:'#B4221F',
                  lighten1:'#D03331',
                  lighten2:'#EC5552',
                  lighten3:'#ED9B9B',
                  lighten4:'#FECDD2'
              },
              warning:'#FB8C00',
              success: {
                  base: '#1B5E20',
                  lighten1:'#388E3B',
                  lighten2:'#66BB6A',
                  lighten3:'#A5D6A7',
                  lighten4:'#E8F5E9'

              },
              active:'#e3eff7',
              anchor: '#2c5893',
              grey: {
                base: '#9E9E9E',
                lighten1: '#BDBDBD',
                lighten2:'#E0E0E0',
                lighten3:'#EEEEEE',
                lighten4:'#F5F5F5',
                lighten5:'#FAFAFA',
                darken1:'#757575',
                darken2:'#616161',
                darken3:'#424242',
                darken4:'#212121',
              }
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

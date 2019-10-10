<template>
  <v-content>
    <v-container class="fill-height">
      <v-row align="center" justify="center">
        <v-col xs="12" sm="8">
          <v-card color="secondaryMaster" class="elevation-12 pb-5">
            <v-toolbar dark color="red">
              <v-toolbar-title>Server Error</v-toolbar-title>
            </v-toolbar>
              <v-card-text class="login-card-text">
              We are having trouble contacting the server.
              If the problem persists after a few minutes please contact an Administrator.
            </v-card-text>
            <v-card-actions class="justify-center">
              <v-btn to="/">Click Here to Try Again</v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-content>
</template>

<script>
import { IS_MOBILE } from '@/helpers/helpers'
import Spinner from '@/components/Spinner.vue'
import AccountMenu from '@/components/AccountMenu.vue'

//@TODO: Maybe eventually combine this into App.vue and breakout nav into its own component

export default {
  name: 'home',
  components: {
    Spinner,
    AccountMenu
  },
  data () {
    return {
      IS_MOBILE,
      appLoading: this.$store.state.app.loading,
      loadComplete: false,
      companyName: this.$store.state.user.details.companyName,
      model: '',
      tabs: [ {
        label: 'Customers',
        path: '/leads',
        display: true
      }, {
        label: 'Projects',
        path: '/project/45669',
        display: true
      }, {
        label: 'AHJ Database',
        path: '/ahj',
        display: true
      }]
    }
  },
  created () {
		this.loadComplete = true
	},
  computed: {
    displayedTabs () {
      return this.tabs.filter(tab => tab.display)
    }
  },
  methods: {}
}
</script>

<style scoped lang="scss">
#portal {
  font-family: 'Lato', sans-serif;
  letter-spacing: .4px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  background-color: var(--v-secondaryCustom-base);
  min-height: 100vh;
  .app-title {
    font-size: 25px;
    margin-top: 7px;
  }
}

#header {
  /* @randa
  /* todo: look into this, vuetify 2.0.17 had overhanging tabs without this line*!*/
  height: unset !important;
}

@media (min-width: 769px) {
  #portal{
    .app-title {
      font-size: 35px;
    }
  }
  #header {
    padding: 0 10px;
  }
}
</style>

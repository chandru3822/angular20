<template>
  <v-app id="app">
    <!--  don't show the new version notification on the login screen. it looks weird  -->
    <v-toolbar v-if="$store.state.app.availableUpdate && $route.name !== 'login'">
      <v-toolbar-title>A newer version of the app is available.</v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text @click="refreshPage">Click here to Refresh</v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <!--    <v-toolbar v-if="showMobileBanner && $route.name !== 'login'">-->
    <v-toolbar
      v-if="!dismissMobileToolbar && showMobileBanner && !noNavRoutes.includes($route.name) && $route.path !== '/apps'"
      class="clickable"
      dense>
      <v-toolbar-title @click="goToApps" class="primary--text">
        Go to App Download Page
        <v-icon color="primary" class="ml-3">
          mdi-arrow-right
        </v-icon>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn x-small text color="primary" @click="dismissMobileToolbar = !dismissMobileToolbar">
          <v-icon>close</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <AppNav v-if="!noNavRoutes.includes($route.name) && !hideHeader" />
    <v-main>
      <v-container class="router-container">
        <Spinner v-if="$store.state.app.loading" :spinnerColor="'primary'" :size="100"></Spinner>
        <router-view class="router-view" />
      </v-container>
    </v-main>
    <Snackbar></Snackbar>
  </v-app>

</template>

<script>
import { AppMutations } from '@/stores/AppStore'
import AppNav from '@/components/AppNav'
import Snackbar from '@/components/Snackbar'
import Spinner from '@/components/Spinner'

export default {
  name: 'App',
  components: {
    AppNav,
    Snackbar,
    Spinner
  },
  data() {
    return {
      hideHeader: this.$store.state.user.hideHeader || false,
      hideMobileBanner: this.$store.state.user.hideMobileBanner || false,
      noNavRoutes: ['login', 'forgotPassword', 'forgotPasswordReset', 'resetPassword', 'siteUnderMaintenance'],
      showMobileBanner: false,
      dismissMobileToolbar: false
    }
  },
  created() {
    document.addEventListener(
      'swUpdated', this.showRefreshUI, { once: true }
    )
    let userAgent = window.navigator.userAgent
    if (!this.hideMobileBanner && userAgent && ['Android', 'iPhone', 'iPad'].some(v => userAgent.includes(v))) {
      //the hideMobileBanner prop is used so that the mobile app can disable the mobile banner when displaying web views inside the app
      this.showMobileBanner = true
    }
  },
  methods: {
    async showRefreshUI() {
      this.$store.commit(AppMutations.SET_AVAILABLE_UPDATE, true)
    },
    async goToApps() {
      this.$router.push('/apps')
    },
    async refreshPage() {
      this.$store.commit(AppMutations.SET_AVAILABLE_UPDATE, false)
      // true = hard refresh?
      window.location.reload(true)
      //not sure if this works
      // todo: this stuff below doesn't seem to work and if we are reloading the page anyway why do the whole skip waiting thing?
      // if (!this.registration || !this.registration.waiting) {
      //   return
      // }
      // this.registration.waiting.postMessage('skipWaiting')
    }
  }
}
</script>

<style scoped lang="scss">
#app {
  letter-spacing: .4px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  padding-top: 0 !important;
  background-color: var(--v-grey-lighten4);
  min-height: 100vh;

  .app-title {
    font-size: 25px;
    margin-top: 7px;
  }
}

@media (min-width: 769px) {
  #app {
    .app-title {
      font-size: 35px;
    }
  }
}
</style>

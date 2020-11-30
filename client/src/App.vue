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
    <v-toolbar v-if="!dismissMobileToolbar && showMobileBanner && $route.name !== 'login' && $route.name !== 'forgotPassword' && $route.path !== '/apps'"
               class="clickable"
               dense>
      <v-toolbar-title  @click="goToApps">
        Go to App Download Page
        <v-icon color="primaryCustom" class="ml-3">
          mdi-arrow-right
        </v-icon>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn x-small text color="primaryCustom" @click="dismissMobileToolbar = !dismissMobileToolbar">
          <v-icon>close</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <AppNav v-if="$route.name !== 'login' && $route.name !== 'forgotPassword' && !hideHeader"/>
    <v-main>
      <v-container class="router-container">
        <router-view class="router-view" />
      </v-container>
    </v-main>
    <Snackbar></Snackbar>
  </v-app>

</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import AppNav from '@/components/AppNav.vue'
  import Snackbar from '@/components/Snackbar'

  export default {
    name: 'App',
    components: {
      AppNav,
      Snackbar
    },
    data() {
      return {
        hideHeader: this.$store.state.user.hideHeader || false,
        showMobileBanner: false,
        dismissMobileToolbar: false
      }
    },
    created () {
      document.addEventListener(
        'swUpdated', this.showRefreshUI, { once: true }
      );
      let userAgent = window.navigator.userAgent
      if(userAgent &&  ['Android', 'iPhone', 'iPad'].some(v => userAgent.includes(v))){
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
      },
    }
  }
</script>

<style lang="scss">
@import "@/styles/main.scss";

</style>

<style scoped lang="scss">
#app {
  font-family: 'Lato', sans-serif;
  letter-spacing: .4px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  padding-top: 0 !important;
  background-color: var(--v-secondaryCustom-base);
  min-height: 100vh;
  .app-title {
    font-size: 25px;
    margin-top: 7px;
  }
}

@media (min-width: 769px) {
  #app{
    .app-title {
      font-size: 35px;
    }
  }
}
</style>

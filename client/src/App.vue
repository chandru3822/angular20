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
    <router-view/>
  </v-app>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  export default {
    name: 'App',
    data() {
      return {}
    },
    created () {
      document.addEventListener(
        'swUpdated', this.showRefreshUI, { once: true }
      );
      // this doesn't seem to do anything either
      // navigator.serviceWorker.addEventListener(
      //   'controllerchange', () => {
      //     if (this.refreshing) {
      //       return
      //     }
      //     this.refreshing = true
      //     window.location.reload()
      //   }
      // )
    },
    methods: {
      async showRefreshUI() {
        this.$store.commit(AppMutations.SET_AVAILABLE_UPDATE, true)
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

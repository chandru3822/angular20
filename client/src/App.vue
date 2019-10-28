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
      //     console.log('this is happening')
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
        console.log('also happening')
        this.$store.commit(AppMutations.SET_AVAILABLE_UPDATE, true)
      },
      async refreshPage() {
        console.log('some stuff going on')
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
/*
 * OVERRIDES FOR VUETIFY THEMES
*/
.theme--light,
.theme--light.application,
.theme--light.application .text--primary,
.theme--light.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled),
.theme--light.v-input:not(.v-input--is-disabled) input,
.theme--light.v-select .v-select__selections {
  color: var(--v-primaryText-base) !important;
  /*color: #1F3C73 !important;*/
}
/*
 * not sure what to do about this. this makes the date time picker look way nicer and doesn't
 * seem to affect anything else so far.  will have to figure out a solution later if it does
 */
body {
  font-family: Verdana, 'Arial', sans-serif;
  background: #f8f8f8;
}

/* I hate that the main window doesn't use the entire screen.  maybe we will come back and change this later but for now i am just going to set my own margins as needed */
.container {
  max-width: unset !important;
}

.app-toolbar {
  border-bottom: solid 1px rgba(0, 0, 0, 0.12) !important;
  //-webkit-box-shadow: 0 6px 6px -6px #000 !important;
  //-moz-box-shadow: 0 6px 6px -6px #000 !important;
  //box-shadow: 0 6px 6px -6px #000 !important;
}

#app {
  font-family: 'Lato', sans-serif;
  letter-spacing: .4px;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: var(--v-secondary-base);
  min-height: 100vh;
}
.app-button{
  padding: 0 5px;
  border-radius: 3px;
  text-transform: capitalize;
  height: 45px !important;
}

/* universally change the data-table footer height */
.v-data-footer {
  height: 40px;
  align-content: center;
}

.v-list-item--dense, .v-list--dense .v-list-item {
  /* vuetify's default code for v-list-dense sets the min-height to 40px, but nothing was setting the height itself so depending on content adding the `dense` flag wasn't doing anything */
  height: 40px;
}
.router-container{
  justify-content: center;
  max-width: 100vw;
  overflow: auto;
}
label[for="adminOriginatorSelect"] {
  color: var(--v-secondary-base) !important;
}
.green-text{
  color: #73d697 !important;
}
.red-text{
  color: #ee6f6a !important;
}
.grab {
  cursor: grab;
  &:active {
    cursor: grabbing;
  }
}
.table-title-row{
  height: 70px;
  line-height: 70px;
  background-color: #ffffff;
  color: rgba(0,0,0,0.87);
  border-top-left-radius: 2px;
  border-top-right-radius: 2px;
  border-collapse: collapse;
  border-spacing: 0;
  border-bottom: solid 2px var(--v-primary-base);
  width: 100%;
  max-width: 100%;
  padding-left: 10px;
  text-align: left;
  vertical-align: middle;
}
.table-header-with-title .v-datatable{
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}
.table-title{
  font-size: 24px;
  vertical-align: middle;
  margin-left: 10px;
}
.flex-display {
  display: flex;
}
.page-header{
  text-align: left;
  font-size: 30px;
  font-weight: 600;
}
.page-subheader{
  text-align: left;
  font-size: 30px;
  font-weight: 600;
}
.underline .v-btn__content{
  text-decoration: underline;
}
.fix-opacity {
  opacity: 100 !important;
}

.fix-column-width-bug table {
  table-layout: fixed;
}

.shaded-row{
  background-color: var(--v-rowShadeCustom-base) !important;
}

.row-hover:hover {
  background-color: var(--v-rowHoverCustom-base) !important;
}

.square-card{
  border-radius: 0 !important;
}

.hr-non-transparent {
  border-color: #e0e1e2 !important;
}

.clickable {
  cursor: pointer;
}
.no-display {
  display: none !important;
}
.centered {
  text-align: center;
}
.text-left {
  text-align: left;
}
.error-text {
  color: var(--v-error-base) !important;
}

.one-hunned {
  width: 100%;
}
.bordered {
  border: solid 1px var(--v-primary-base);
  border-color: #000 !important;
}
.overflow-auto {
  overflow: auto;
}
.relative {
  position: relative;
}

.br-5 {
  border-radius: 5px;
}

.br-10 {
  border-radius: 10px;
}

.app-toolbar{
  .app-title {
    font-size: 20px;
  }
}

/* this margin makes the pagination footer not fit on one row on mobile.  should work globally */
.v-application--is-ltr .v-data-footer__pagination {
  margin: 0 0 0 24px !important;
}

@media (min-width: 769px) {
  .v-application--is-ltr .v-data-footer__pagination {
    margin: 0 32px 0 24px !important;
  }

  .router-container{
    display: flex;
  }
  .router-view{
    /* @joe - do we even need this?  lets just use the full screen till they complain. i hate the white space on the sides */
    /*margin-left: 107px !important;*/
    /*margin-right: 107px !important;*/
  }
  .page-header{
    font-size: 40px;
  }
  .page-subheader{
    padding-left: 40px;
  }
  .app-button{
    padding: 0 16px;
    border-radius: 3px;
    height: 45px !important;
    margin-right: 10px !important;
  }
  .app-toolbar{
    .app-title {
      font-size: 35px;
    }
  }
}
</style>

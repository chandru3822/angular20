<template>
  <v-layout column id="portal" v-if="loadComplete">
    <v-flex xs12>
      <Spinner v-if="$store.state.app.loading" :spinnerColor="'primary'" :size="100"></Spinner>
      <!--non-mobile header...is this necessary?-->
      <v-app-bar dense id="header" color="primaryCustom" tabs dark extension-height="53">
        <v-toolbar-title class="app-title">Blue Raven Solar</v-toolbar-title>
        <v-spacer v-if="!IS_MOBILE" class="ml-5"></v-spacer>
        <v-toolbar-items>
          <AccountMenu :showImage="true"></AccountMenu>
        </v-toolbar-items>
        <v-tabs color="secondaryCustom" v-model="model" slot="extension" dark slider-color="secondaryCustom">
          <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
            {{tab.label}}
          </v-tab>
        </v-tabs>
      </v-app-bar>
      <v-content>
        <v-container class="router-container">
          <router-view class="router-view" />
        </v-container>
      </v-content>
    </v-flex>
  </v-layout>
</template>

<script>
import { IS_MOBILE } from '@/helpers/helpers'
import Spinner from '@/components/Spinner.vue'
import AccountMenu from '@/components/AccountMenu.vue'

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
      model: '',
      tabs: [{
        label: 'Users',
        path: '/users',
        display: true
      }, {
        label: 'Orgs',
        path: '/orgs',
        display: true
      }, {
        label: 'AHJ Database',
        path: '/ahj',
        display: true
      }, {
      //   label: 'AHJ Database TEST',
      //   path: '/ahjTest',
      //   display: true
      // }, {
        label: 'Settings',
        path: '/settings',
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

@media (min-width: 769px) {
  #portal{
    .app-title {
      font-size: 40px;
    }
  }
  #header {
    padding: 10px;
  }
}
</style>

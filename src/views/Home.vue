<template>
  <div id="portal" v-if="loadComplete">
    <Spinner v-if="$store.state.app.loading" :spinnerColor="'primary'" :size="100"></Spinner>
    <!--non-mobile header...is this necessary?-->
    <v-toolbar prominent id="header" color="primaryCustom" app tabs dark>
      <v-toolbar-title class="app-title">Blue Raven Solar</v-toolbar-title>
        <v-spacer></v-spacer>
				<AccountMenu :showImage="true"></AccountMenu>
				<v-spacer v-if="!IS_MOBILE" class="ml-5"></v-spacer>
        <v-tabs color="primaryCustom" v-model="model" slot="extension" dark slider-color="secondary">
          <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
              {{tab.label}}
          </v-tab>
        </v-tabs>
    </v-toolbar>
    <v-content>
      <v-container class="router-container">
        <router-view class="router-view"/>
      </v-container>
    </v-content>
  </div>
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
      tabs: [
        {
          label: 'Users',
          path: '/users',
          display: true
        }
      ]
    }
  },
  created () {
		this.loadComplete = true
	},
  computed: {
    displayedTabs: function () {
      return this.tabs.filter(function (tab) {
        return tab.display
      })
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
    padding: 20px;
  }
}
</style>

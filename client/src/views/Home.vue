<template>
  <div id="portal" v-if="loadComplete">
    <v-row>
      <v-col cols="12" class="pt-0">
        <Spinner v-if="$store.state.app.loading" :spinnerColor="'primary'" :size="100"></Spinner>
        <!--non-mobile header...is this necessary?-->
<!--        <v-app-bar dense id="header" color="primaryCustom" tabs dark extension-height="33">-->
<!--          <v-toolbar-title class="app-title">{{companyName}}</v-toolbar-title>-->
<!--          <v-spacer class="ml-5"></v-spacer>-->
<!--          <v-toolbar-items>-->
<!--            <AccountMenu :showImage="true"></AccountMenu>-->
<!--          </v-toolbar-items>-->
<!--          <v-tabs :optional="true" color="secondaryCustom" background-color="primaryCustom" v-model="model" slot="extension" dark slider-color="secondaryCustom">-->
<!--            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">-->
<!--              {{tab.label}}-->
<!--            </v-tab>-->
<!--          </v-tabs>-->
<!--        </v-app-bar>-->
        <v-app-bar dense id="header" color="primaryCustom" tabs dark>
          <v-btn icon>
            <img class="header-logo" src="../assets/bird.png">
          </v-btn>
          <v-tabs :optional="true" color="secondaryCustom" background-color="primaryCustom" v-model="model" dark slider-color="secondaryCustom">
            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
              {{tab.label}}
            </v-tab>
          </v-tabs>
          <v-spacer class="ml-5"></v-spacer>
          <v-toolbar-items>
            <AccountMenu :showImage="true"></AccountMenu>
          </v-toolbar-items>
        </v-app-bar>
        <v-content>
          <v-container class="router-container">
            <router-view class="router-view" />
          </v-container>
        </v-content>
      </v-col>
    </v-row>
  </div>
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
        path: '/project/192015',
        display: true
      }, {
        label: 'AHJ Database',
        path: '/ahj',
        display: true
      }, {
        label: 'Schedule',
        path: '/schedule',
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

<style lang="scss">
  #portal .v-slide-group__prev {
    display: none !important;
  }
</style>

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

.header-logo {
  max-height: 50px;
  max-width: 50px;
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

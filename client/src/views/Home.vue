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
        <v-app-bar dense id="header" :color="headerColor" tabs dark>
          <v-menu data-app left
                  offset-y
                  v-model="menuOpen"
                  class="account-menu"
                  :close-on-content-click="false">
            <template v-slot:activator="{ on }">
              <v-btn icon v-on="on" :color="selectedCompany.logoPresignedUrl ? 'transparent' : '#bbbbbb'">
                <img class="header-logo" v-if="selectedCompany.logoPresignedUrl" :src="selectedCompany.logoPresignedUrl">
                <v-icon v-else>mdi-office-building</v-icon>
              </v-btn>
            </template>
            <v-list v-if="companies.length > 1">
              <v-list-item v-for="(item, index) in companies" :key="index"
                           :class="item.id === $store.state.user.details.companyId ? 'v-list-item--active' : ''"
                           @click="[menuOpen = false, changeContext(item.id)]">
                <v-list-item-title>{{item.companyName}}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
          <v-tabs :optional="true" color="secondaryCustom" :background-color="headerColor" v-model="model" dark slider-color="secondaryCustom">
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
    <Snackbar :snackbar="snackbar"></Snackbar>
  </div>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import { UserActions } from '@/stores/UserStore'
import { getRequest, getSnackbar } from '@/helpers/helpers'
import Spinner from '@/components/Spinner.vue'
import AccountMenu from '@/components/AccountMenu.vue'
import Snackbar from '@/components/Snackbar.vue'

const { VUE_APP_ENV } = process.env
//@TODO: Maybe eventually combine this into App.vue and breakout nav into its own component

export default {
  name: 'home',
  components: {
    Snackbar,
    Spinner,
    AccountMenu
  },
  data () {
    return {
      snackbar: {},
      appLoading: this.$store.state.app.loading,
      loadComplete: false,
      companyName: this.$store.state.user.details.companyName,
      selectedCompany: {},
      menuOpen: false,
      companies: [],
      model: '',
      headerColor: VUE_APP_ENV === 'local' ? 'pink' : VUE_APP_ENV === 'uat' || VUE_APP_ENV === 'dev' ? 'orange' : 'primaryCustom',
      tabs: [ {
        label: 'Contacts',
        path: '/contacts',
          display: this.$store.getters.userHasFeature('CONTACTS')
      }, {
        label: 'Projects',
        path: '/project/search',
        display: this.$store.getters.userHasFeature('PROJECTS')
      }, {
        label: 'Closer Dashboard',
        path: '/closerDashboard',
        display: this.$store.getters.userHasFeature('CLOSER_DASHBOARD')
      }, {
        label: 'AHJ Database',
        path: '/ahj',
        display: this.$store.getters.userHasFeature('AHJ_DATABASE')
      }, {
        label: 'Commissions',
        path: '/commissionManagement/closers',
        display: this.$store.getters.userHasFeature('COMMISSIONS')
      }, {
        label: 'Finance',
        display: this.$store.getters.userHasFeature('FINANCES'),
        path: '/finances/rebate/viewPayments',
        children: [
          {
            label: 'BluePower + Rebates',
            path: '/finances/rebate/viewPayments',
            display: this.$store.getters.userHasFeature('FINANCES')
          }
        ]
      }, {
        label: 'Schedule',
        path: '/schedule',
        display: this.$store.getters.userHasFeature('SCHEDULE')
      }, {
        label: 'Proposal',
        path: '/proposal',
        display: this.$store.getters.userHasFeature('PROPOSAL')
      }, {
        label: 'Work Queue',
        path: '/workQueue',
        display: this.$store.getters.userHasFeature('WORK_QUEUE')
      }, {
        label: 'Smartlists',
        path: '/smartlist',
        display: this.$store.getters.userHasFeature('SMARTLIST')
      }]
    }
  },
  created () {
		this.loadComplete = true
    this.getCompanies()
	},
  computed: {
    displayedTabs () {
      return this.tabs.filter(tab => tab.display)
    }
  },
  methods: {
    async changeContext (companyId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      const params = {
        companyId,
        isAdmin: this.$store.getters.isFullAdmin
      }
      await this.$store.dispatch(UserActions.CHANGE_CONTEXT, params )
    },
    async getCompanies () {
      // get the companies that a user has access to
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let url
        if(this.$store.getters.isFullAdmin) {
          url = `/companies`
        } else {
          url = `/companies/assignedToUser`
        }
        const {data} = await getRequest(url)
        this.companies = data
        this.selectedCompany = this.companies.find(c => c.id === this.$store.state.user.details.companyId)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Changing Companies')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
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
  max-height: 45px;
  max-width: 45px;
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

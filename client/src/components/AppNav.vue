<template>
  <div v-if="loadComplete">
    <v-row>
      <v-col cols="12" class="pt-0 pb-0">
        <Spinner v-if="$store.state.app.loading" :spinnerColor="'primaryCustom'" :size="100"></Spinner>
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
          <v-toolbar-items v-if="companyTools.length > 0">
            <CompanyTools :company-tools="companyTools"/>
          </v-toolbar-items>
          <v-spacer class="ml-5"></v-spacer>
          <v-toolbar-items>
            <AccountMenu :showImage="true"></AccountMenu>
          </v-toolbar-items>
        </v-app-bar>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {UserActions, UserMutations} from '@/stores/UserStore'
import { getRequest, getSnackbar } from '@/helpers/helpers'
import Spinner from '@/components/Spinner.vue'
import AccountMenu from '@/components/AccountMenu.vue'
import CompanyTools from '@/components/CompanyTools.vue'


const { VUE_APP_ENV } = process.env
//@TODO: Maybe eventually combine this into App.vue and breakout nav into its own component

export default {
  name: 'appNav',
  components: {

    Spinner,
    AccountMenu,
    CompanyTools,
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
      companyTools: [],
      model: '',
      headerColor: VUE_APP_ENV === 'local' ? 'pink' :
                   VUE_APP_ENV === 'dev' || VUE_APP_ENV === 'stage' ? 'orange' :
                   VUE_APP_ENV === 'uat' ? 'blue' : 'primaryCustom',
      tabs: [ {
        label: 'Contacts',
        path: '/contacts',
        feature: 'CONTACTS'
      }, {
        label: 'Projects',
        path: '/projects',
        feature: 'PROJECTS'
      },
        {
        label: 'Schedule',
        path: '/schedule',
        feature: 'SCHEDULE'
      },
        {
        label: 'Work Queue',
        path: '/workQueue',
        feature: 'WORK_QUEUE'
      }, {
        label: 'Smartlists',
        path: '/smartlist',
        feature: 'SMARTLIST'
      }]
    }
  },
  created () {
		this.loadComplete = true
    this.getCompanies()
    this.getCompanyTools()
	},
  computed: {
    displayedTabs () {
      return this.tabs.filter(tab => this.$store.getters.userHasFeature(tab.feature))
    },
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
        this.$store.commit(UserMutations.SET_COMPANIES, this.companies)
        this.selectedCompany = this.companies.find(c => c.id === this.$store.state.user.details.companyId)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Changing Companies')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyTools () {
          // get the company tools then filter the ones the user has access to
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
              const {data} = await getRequest(`/feature/companyTools`)
              this.companyTools = data.filter(d => {
                return this.$store.getters.userHasFeature(d.featureCode)
              })
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

</style>

<style scoped lang="scss">
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
  #header {
    padding: 0 10px;
  }
}
</style>

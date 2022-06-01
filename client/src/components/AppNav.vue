<template>
  <div v-if="loadComplete">
    <v-row class="toolbar-z-index-override">
      <v-col
        v-if="VUE_APP_ENV === 'uat'"
        cols="12"
        style="font-size: 18px; text-align: center; background-color: orange; color: white;"
      >
        THIS IS UAT - YOU SHOULD BE WORKING IN PRODUCTION
        <v-btn
            href="https://albatross.myblueraven.com"
        >
          CLICK HERE
        </v-btn>
      </v-col>
      <v-col
        v-if="userIsMasquerading"
        cols="12"
        style="font-size: 18px; text-align: center; background-color: red; color: white;"
      >
        BE CAREFUL!! YOU ARE MASQUERADING!!
        <v-btn :disabled="clearingMasquerade" :loading="clearingMasquerade"
          @click="clearMasquerade()"
        >
          CLEAR
        </v-btn>
      </v-col>
      <v-col cols="12" class="pt-0 pb-0">

        <v-app-bar dense id="header" :color="headerColor" tabs dark>
          <v-menu data-app left
                  offset-y
                  :disabled="userIsMasquerading"
                  v-if="companies.length > 1"
                  :max-height="`calc(100vh - 20px)`"
                  v-model="menuOpen"
                  class="account-menu"
                  :close-on-content-click="false">
            <template v-slot:activator="{ on }">
              <v-btn icon v-on="on" :color="selectedCompany.logoPresignedUrl ? 'transparent' : '#bbbbbb'">
                <img class="header-logo" v-if="selectedCompany.logoPresignedUrl" :src="selectedCompany.logoPresignedUrl">
                <v-icon v-else>mdi-office-building</v-icon>
              </v-btn>
            </template>
            <v-list>
              <v-list-item v-for="(item, index) in companies" :key="index"
                           :class="item.id === $store.state.user.details.companyId ? 'v-list-item--active' : ''"
                           @click="[menuOpen = false, changeContext(item.id)]">
                <v-list-item-title>{{item.companyName}}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
          <v-btn icon v-else to="/home"
                 :color="selectedCompany.logoPresignedUrl ? 'transparent' : '#bbbbbb'">
            <img class="header-logo" v-if="selectedCompany.logoPresignedUrl" :src="selectedCompany.logoPresignedUrl">
            <v-icon v-else>mdi-office-building</v-icon>
          </v-btn>
          <v-menu v-if="constants.IS_MOBILE" data-app left
                  offset-y
                  :max-height="`calc(100vh - 20px)`"
                  v-model="tabMenuOpen"
                  class="account-menu"
                  :close-on-content-click="false">
            <template v-slot:activator="{ on }">
              <v-btn class="account-menu-button"
                     :color="headerColor"
                     dark
                     v-on="on">
                Pages
                <v-icon>mdi-chevron-down</v-icon>
              </v-btn>
            </template>
            <v-list v-if="displayedTabs.length > 1">
              <v-list-item v-for="(tab, index) in displayedTabs" :key="index"
                           @click="[tabMenuOpen = false, goToPath(tab.path)]">
                <v-list-item-title>{{tab.label}}
                  <v-badge
                    class="notif-badge"
                    color="#F35858"
                    v-if="tab.label == 'Inbox' && smsNotification.length > 0"
                  >
                  </v-badge>
                </v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
          <v-tabs v-else :optional="true" color="secondary" :background-color="headerColor" v-model="model" dark slider-color="secondary">
            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
              {{tab.label}}
              <v-badge
                dot
                class="notif-badge"
                color="#F35858"
                v-if="tab.label == 'Inbox' && smsNotification.length > 0"
              >
              </v-badge>
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
<!--    <div id="context-label"-->
<!--         @click="goToPath('/home')"-->
<!--         v-if="companies.length > 1 && selectedCompany.companyName" class="rounded-tr-xl">-->
<!--      {{selectedCompany.companyName}}-->
<!--    </div>-->
  </div>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {UserActions, UserMutations} from '@/stores/UserStore'
import { getRequest, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import AccountMenu from '@/components/AccountMenu.vue'
import CompanyTools from '@/components/CompanyTools.vue'
import axios from 'axios'

const { VUE_APP_ENV } = process.env
//@TODO: Maybe eventually combine this into App.vue and breakout nav into its own component

export default {
  name: 'appNav',
  components: {
    AccountMenu,
    CompanyTools,
  },
  data () {
    return {
      snackbar: {},
      constants,
      appLoading: this.$store.state.app.loading,
      loadComplete: false,
      clearingMasquerade: false,
      companyName: this.$store.state.user?.details?.companyName,
      userIsMasquerading: this.$store.state.user?.details?.masqueradingUserId != null,
      selectedCompany: {},
      menuOpen: false,
      tabMenuOpen: false,
      companies: [],
      companyTools: [],
      model: '',
      headerColor: VUE_APP_ENV === 'local' ? constants.LOCAL_COLOR :
                   VUE_APP_ENV === 'dev' || VUE_APP_ENV === 'stage' ?  constants.STAGE_COLOR :
                   VUE_APP_ENV === 'flux' ? constants.FLUX_COLOR :
                   VUE_APP_ENV === 'uat' ? constants.UAT_COLOR : constants.PROD_COLOR,
      tabs: [ {
        label: 'Contacts',
        path: '/contacts',
        feature: 'CONTACTS',
        show: true
      }, {
        label: 'Projects',
        path: '/projects',
        feature: 'PROJECTS',
        show: true
      },
        {
        label: 'Schedule',
        path: '/schedule',
        feature: 'SCHEDULE',
          show: true
      },
        {
        label: 'Work Queue',
        path: '/workQueue',
        feature: 'WORK_QUEUE',
        show: true
      }, {
        label: 'Smartlists',
        path: '/smartlist',
        feature: 'SMARTLIST',
        show: true
      }, {
        label: 'Inbox',
        path: '/inbox',
        feature: 'SMS_INBOX',
        show: true
      }],
      VUE_APP_ENV,
      smsNotification: []
    }
  },
  created () {
		this.loadComplete = true
    if(this.$store.state.user?.details?.id) {
      this.getCompanies()
      this.getCompanyTools()
      this.getSmsNotification()
    }
	},
  mounted() {
    //notification stream
    this.evtSource = new EventSource(`${constants.VUE_APP_BASE_API}/api/v1/flow/notifications/stream?access_token=${this.$store.state.user.jwt}`)
    this.evtSource.addEventListener('sms_reply', function(e) {
      const data = JSON.parse(e.data)
      if (data) {
        this.getSmsNotification()
      }
    }.bind(this))
  },
  computed: {
    displayedTabs () {
      return this.tabs.filter(tab => this.$store.getters.userHasFeature(tab.feature) && tab.show)
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
        const {data} = await getRequest(url, null, [])
        this.companies = data
        this.$store.commit(UserMutations.SET_COMPANIES, this.companies)
        this.selectedCompany = this.companies.find(c => c.id === this.$store.state.user?.details?.companyId) || {}
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
            const {data} = await getRequest(`/feature/companyTools`, null, [])
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
      goToPath(path) {
        this.$router.push({path: `${path}`})
      },
      async clearMasquerade () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.clearingMasquerade = true
          const {data} = await axios.get(`${constants.VUE_APP_BASE_API}/auth/masquerade/clear`)
          if(data && data.token) {
            this.$store.commit(UserMutations.SET_JWT, data.token)
            //update the user
            const {data: currentUser} = await getRequest(`/user/current`)
            await this.$store.commit(UserMutations.SET_DETAILS, currentUser);
            //then reload the screen
            window.location.reload()
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Clearing Masquerade')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    async getSmsNotification() {
      try {
        const {data} = await getRequest(`/notifications/`)
        if (data && data.length > 0) {
          this.smsNotification = data.filter(n => n.topic == "sms_reply")
        }
        else {
          this.smsNotification = []
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching notifications')
      }
    }
  }
}
</script>

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

.account-menu-button{
  text-transform: capitalize;
  box-shadow: none !important;
  -webkit-box-shadow: none !important;
  border: none !important;
}

#context-label {
  opacity: .85;
  position: absolute;
  left: 0;
  color: #fff;
  bottom: 0;
  padding: 5px 15px 5px 10px;
  z-index: 1000;
  background-color: var(--v-primary-base);
}

@media (min-width: 769px) {
  #header {
    padding: 0 10px;
  }
}

.notif-badge {
  margin-bottom: 16px;
}
</style>

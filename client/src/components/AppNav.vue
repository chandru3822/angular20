<template>
  <div v-if="loadComplete">
    <v-row class="toolbar-z-index-override">
      <v-col
          v-if="userIsMasquerading"
          cols="12"
          style="font-size: 18px; text-align: center; background-color: var(--v-error-base); color: white;"
      >
        BE CAREFUL!! YOU ARE MASQUERADING!!
        <a-btn
            :disabled="clearingMasquerade"
            :loading="clearingMasquerade"
            @click="clearMasquerade()"
            class="primary--text"
            color="unset"
            text="CLEAR"
        ></a-btn>
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
              <a-btn
                  icon
                  :activation-handler="on"
                  :color="selectedCompany.logoPresignedUrl ? 'transparent' : '#bbbbbb'"
              >
                <template #default>
                  <img class="header-logo" v-if="selectedCompany.logoPresignedUrl"
                       :src="selectedCompany.logoPresignedUrl">
                  <v-icon v-else>mdi-office-building</v-icon>
                </template>
              </a-btn>
            </template>
            <v-list>
              <v-list-item v-for="(item, index) in companies" :key="index"
                           :class="item.id === userStore.details.companyId ? 'v-list-item--active' : ''"
                           @click="[menuOpen = false, changeContext(item.id)]">
                <v-list-item-title>{{ item.companyName }}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>
          <a-btn
              icon
              v-else
              to="/home"
              :color="selectedCompany.logoPresignedUrl ? 'transparent' : '#bbbbbb'"
              prepend-icon="mdi-office-building"
          >
            <template #default>
              <img class="header-logo" v-if="selectedCompany.logoPresignedUrl" :src="selectedCompany.logoPresignedUrl">
              <v-icon v-else>mdi-office-building</v-icon>
            </template>
          </a-btn>
          <a-btn
              v-if="showMobileBanner && $route.path !== '/apps'"
              @click="goToPath('/apps')"
              icon
              class="text-capitalize bold px-0"
              color="unset"
              prepend-icon="mdi-download-circle"
          ></a-btn>
          <v-spacer v-if="isMobile"></v-spacer>
          <div v-if="isMobile" class="flex-display flex-align-items-center">
            <v-menu data-app left
                    offset-y
                    :max-height="`calc(100vh - 20px)`"
                    v-model="tabMenuOpen"
                    class="account-menu"
                    :close-on-content-click="false">
              <template v-slot:activator="{ on }">
                <a-btn
                    class="account-menu-button label-medium px-3 pages-button"
                    :color="headerColor"
                    size="x-small"
                    :activation-handler="on"
                >
                  <template #default>
                    PAGES
                    <v-icon>mdi-chevron-down</v-icon>
                  </template>
                </a-btn>
              </template>
              <v-list v-if="displayedTabs.length > 1">
                <v-list-item v-for="(tab, index) in displayedTabs" :key="index"
                             @click="[tabMenuOpen = false, goToPath(tab.path)]">
                  <v-list-item-title>{{ tab.label }}
                    <v-badge
                        class="notif-badge"
                        color="#D03331"
                        :content="smsNotification.length"
                        v-if="tab.label === 'Inbox' && smsNotification.length > 0"
                    >
                    </v-badge>
                  </v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>
            <!--            <div class="company-tools-container" v-if="companyTools.length > 0">-->
            <CompanyTools v-if="companyTools.length > 0" :is-mobile="isMobile" :company-tools="companyTools"/>
            <!--            </div>-->
          </div>
          <v-tabs v-else :optional="true" color="secondary" :background-color="headerColor"
                  v-model="model" dark
                  class="header-tab-container"
                  :show-arrows="isBetween"
                  slider-color="secondary">
            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path" class="label-medium">
              {{ tab.label }}
              <v-badge
                  class="notif-badge"
                  color="#D03331"
                  :content="smsNotification.length"
                  v-if="tab.label == 'Inbox' && smsNotification.length > 0"
              >
              </v-badge>
            </v-tab>
            <div class="company-tools-container" v-if="companyTools.length > 0">
              <CompanyTools :company-tools="companyTools"/>
            </div>
          </v-tabs>
          <v-spacer v-if="!isMobile" class="ml-5"></v-spacer>
          <v-toolbar-items>
            <AnnouncementDropdown></AnnouncementDropdown>
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

<script setup>

import {getRequest,  handleHidingGlobalLoader} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import AccountMenu from '@/components/AccountMenu.vue'
import CompanyTools from '@/components/CompanyTools.vue'
import axios from 'axios'
import AnnouncementDropdown from '@/components/AnnouncementDropdown.vue'
import moment from 'moment'
import {useNotificationStore} from '@/stores/NotificationStore.js'

import {getCurrentInstance, toRefs, computed, ref, onMounted, watch} from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import {useAppStore} from '@/stores/AppStorePinia.js'
import { useScheduleStore } from '@/stores/ScheduleStore.js'

const appStore = useAppStore()
const notificationStore = useNotificationStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const scheduleStore = useScheduleStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify

const loadComplete = ref(false)
const clearingMasquerade = ref(false)
const selectedCompany = ref({})
const menuOpen = ref(false)
const tabMenuOpen = ref(false)
const companies = ref([])
const announcements = ref([])
const companyTools = ref([])
const model = ref('')
const showMobileBanner = ref(false)
const headerColor = ref(constants.ENV_COLOR)
const tabs = ref([{
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
  }])


onMounted(() => {
  loadComplete.value = true
  if (userStore?.details?.id) {
    getCompanies()
    getCompanyTools()
    getSmsNotification()
    getActiveAnnouncements()
  }

  //@TODO: #smartlistsv2 Please leave while smartlists v2 is being developed
  if (userStore.isSystemAdmin) {
    tabs.value.splice(4, 0, {
      label: 'Smartlists v1',
      path: '/smartlistv1',
      feature: 'SMARTLIST',
      show: true
    })
  }

  let userAgent = window.navigator.userAgent
  if (!hideMobileBanner.value && userAgent && ['Android', 'iPhone', 'iPad'].some(v => userAgent.includes(v))) {
    //the hideMobileBanner prop is used so that the mobile app can disable the mobile banner when displaying web views inside the app
    showMobileBanner.value = true
  }
})

const companyName = computed(() => {
  return userStore?.details?.companyName
})
const userIsMasquerading = computed(() => {
  return userStore?.details?.masqueradingUserId != null
})
const hideMobileBanner = computed(() => {
  return userStore?.hideMobileBanner || false
})
const displayedTabs = computed(() => {
  return tabs.value.filter(tab => userStore.userHasFeature(tab.feature) && tab.show)
})
const smsNotification = computed(() => {
  return notificationStore.getNotificationsByTopic('sms_reply')
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const isBetween = computed(() => {
  return !vuetify.breakpoint.smAndDown && !vuetify.breakpoint.lgAndUp
})
const themeUpdateEvents = computed(() => {
  return notificationStore.getEventsByTopic('theme_update').length
})
const announcementEvents = computed(() => {
  return notificationStore.getEventsByTopic('announcement').length
})

watch(themeUpdateEvents, async () => {
  // todo refactor this to receive the theme update from the notification so we dont have load anything
  // console.log('THIS IS HAPPENING', themeUpdateEvents.value)
  //reload the companies so we get any new icons
  await getCompanies()
})

watch(announcementEvents, async () => {
  notificationStore.getEventsByTopic('announcement').forEach(ae => {
    //there seems to be an issue when stale announcements are in the eventstream and they are populating when they shouldn't
    //this time check will hopefully fix that.
    if (ae.endTime == null || moment().isBetween(moment(ae.startTime), moment(ae.endTime))) {
      let match = appStore.announcements.find(a => a.id === ae.announcement?.id)
      if (!match && ae.announcement) {
        appStore.announcements.push(ae.announcement)
      }
    }
  })
})

const changeContext = async (companyId) => {
  appStore.loading = true
  const params = {
    companyId,
    isAdmin: userStore.isSystemAdmin
  }
  await userStore.changeContext(params)
}
const getCompanies = async () => {
  // get the companies that a user has access to
  // appStore.loading = true
  try {
    const url = (userStore.isSystemAdmin) ? `/companies` : `/companies/assignedToUser`
    const {data} = await getRequest(url, null, [])
    companies.value = data
    userStore.companies = companies.value
    selectedCompany.value = companies.value.find(c => c.id === userStore?.details?.companyId) || {}
    //always do this, that way if they dont have a spinner it will unset the url
    appStore.spinnerUrl = selectedCompany.value?.spinnerPresignedUrl

    //this handles if the color is null too
    appStore.setPrimaryBaseColor(selectedCompany.value?.primaryColor)
    appStore.setBannerColor(selectedCompany.value?.bannerColor)
	vueInstance.$vuetify.theme.themes.light = appStore.theme

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Changing Companies')
    // appStore.loading = false
  }
}
const getCompanyTools = async () => {
  // get the company tools then filter the ones the user has access to
  appStore.loading = true
  try {
    let parentId = -1;
    let childNames;
    let childPaths;
    const {data} = await getRequest(`/feature/companyTools`, null, [])

    companyTools.value = data.filter(d => {
      if (d.parentCompanyFeatureId != null && userStore.userHasFeature(d.childCode)) {
        if (parentId == -1 || (parentId != d.parentCompanyFeatureId)) {
          childNames = []
          childPaths = []
          parentId = d.parentCompanyFeatureId;
        }
        childNames.push(d.childName);
        childPaths.push(d.featurePath)
        d.featurePath = null;
        d.childNames = childNames.slice();
        d.childPaths = childPaths.slice();
      }
      return userStore.userHasFeature(d.childCode);

    })
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Changing Companies')
    appStore.loading = false
  }
}
const goToPath = (path) => {
  router.push(path)
}
const clearMasquerade = async () => {
  appStore.loading = true
  try {
    clearingMasquerade.value = true
    const {data} = await axios.get(`${constants.VUE_APP_BASE_API}/auth/masquerade/clear`)
    if (data && data.token) {
      userStore.jwt = data.token
      //update the user
      const {data: currentUser} = await getRequest(`/user/current`)
      userStore.details = currentUser
	  scheduleStore.timezone = currentUser.timezone
      //then reload the screen
      window.location.reload()
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Clearing Masquerade')

    appStore.loading = false
  }
}
const getSmsNotification = () => {
  notificationStore.fetchNotifications()
}
const getActiveAnnouncements = async () => {
  try {
    appStore.announcements = []
    appStore.loading = true
    const {data, status} = await getRequest(`/announcements/active`)
    appStore.announcements = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  } finally {
    appStore.loading = false
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

.header-tab-container {
  max-width: calc(100% - 170px);
}

.account-menu-button {
  text-transform: capitalize;
  box-shadow: none !important;
  -webkit-box-shadow: none !important;
  border: none !important;
}

.pages-button {
  padding-left: 8px !important;
  padding-right: 4px !important;
}

.company-tools-container {
  margin-top: 5px;
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
  margin-top: 13px;
  left: -25px;
  padding-right: 41px;
}

</style>

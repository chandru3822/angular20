<template>
  <v-container class="pt-0">
    <v-row class="settings-container" :class="{'d-inline-block': isMobile}">
      <v-col class="text-left pa-0" :class="{'collapse-left':leftCollapsed && !isMobile, 'col-md-3': !leftCollapsed}">
        <v-menu data-app
                v-if="isMobile"
                offset-y
                attach
                v-model="menuOpen"
                min-width="100%"
                class="account-menu"
                :close-on-content-click="false">
          <template v-slot:activator="{ on }">
            <v-toolbar
                color="white"
                v-on="on"
                class="label-large"
                style="z-index: 1"
            >
              {{ title }}
              <v-spacer></v-spacer>
              <AlbatrossButton
                variant="text"
                prepend-icon="expand-more"
              />
            </v-toolbar>
          </template>
          <SettingsMenu class="pa-3" :title="title" :menu-list="items" :companyObjectItems="companyObjectTypes" @closeMenu="menuOpen=false" @updateTitle="setTitle($event)"></SettingsMenu>
        </v-menu>
        <v-card v-else class=" left-menu square-card d-flex">
          <SettingsMenu class="px-5 py-2 settings-container" :menu-list="items" :companyObjectItems="companyObjectTypes" :class="{'hidden': leftCollapsed}"></SettingsMenu>
          <AlbatrossButton
            size="small"
            variant="text"
            color="primary"
            @click="collapseMenu"
            class="py-6"
            prepend-icon="mdi-menu"
          />
        </v-card>
      </v-col>
      <v-col class="px-4 pt-0 main-section" :class="{'main-section-left-collapsed': leftCollapsed, 'col-12 col-md-9': !leftCollapsed}">
        <router-view/>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'

import { handleHidingGlobalLoader, getRequest } from '@/helpers/helpers'
import SettingsMenu from './SettingsMenu'
import {getCurrentInstance, onMounted, ref, computed} from 'vue'
import AlbatrossButton from '@/components/customVuetify/AlbatrossButton.vue'
import { useUserStore } from '@/stores/UserStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()

const route = vueInstance.$route

const menuOpen = ref(false)
const title = ref(null)
const hasSettingsAccess = ref(userStore.userHasFeature('SETTINGS'))
const companyObjectTypes = ref([])
const companyId = ref(userStore.details.companyId)
const parentId = ref(userStore.details.parentCompanyId)


const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const leftCollapsed = computed(() => {
  return userStore.settingsMenuCollapsed
})
const items = computed(() => {
  return [
    {
      header: 'Preferences',
      show: true
    }, {
      path: '/settings/userProfile',
      title: 'User Profile',
      show: true
    }, {
      header: 'Company',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/company/settings',
      title: 'Defaults',
      pathMatch: '/settings/company',
      show: hasSettingsAccess.value,
    }, {
      path: '/settings/proposals',
      title: 'Proposals',
      show: userStore.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')
    }, {
      path: '/settings/states',
      title: 'States',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/zip/postalCodes',
      title: 'Postal Codes',
      pathMatch: '/settings/zip',
      show: userStore.userHasFeature('POSTAL_CODE')
    }, {
      path: '/settings/roundRobins',
      title: 'Round Robins',
      pathMatch: '/settings/roundRobin',
      show: userStore.userHasFeature('ROUND_ROBIN')
    }, {
      path: '/settings/callGroups',
      title: 'Call Groups',
      pathMatch: '/settings/callGroup',
      show: userStore.userHasFeature('CALL_GROUPS')
    }, {
      path: '/settings/tournaments',
      title: 'Tournaments',
      pathMatch: '/settings/tournaments',
      show: userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'ADMIN')
    }, {
      path: '/settings/companyCustomFields',
      title: 'Company Custom Fields',
      pathMatch: '/settings/companyCustomField',
      show: hasSettingsAccess.value && null != userStore.details.apiPath,
    }, {
      path: '/settings/companyObjectTypes',
      title: 'Company Object Types',
      show: hasSettingsAccess.value && null != userStore.details.apiPath,
    },
    {
      header: 'User Management',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/availability/main/schedule',
      title: 'Availability',
      show: hasSettingsAccess.value || userStore.userHasFeature('AVAILABILITY')
    }, {
      path: '/settings/positions',
      title: 'Positions',
      show: hasSettingsAccess.value
    }, {
      // path: '/settings/roles',
      // title: 'Roles',
      // }, {
      header: 'Custom Components',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/customFields',
      pathMatch: '/settings/customField',
      title: 'Custom Fields',

      show: hasSettingsAccess.value
    }, {
      path: '/settings/links',
      title: 'Links',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/tags',
      title: 'Tags',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/functions',
      pathMatch: '/settings/function',
      title: 'Functions',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/messageTemplates',
      title: 'Message Templates',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/announcements/current',
      title: 'Announcements',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/hashtags',
      title: 'Topic Hashtags',
      show: hasSettingsAccess.value
    }, {
      header: 'Configurations',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/dataViews',
      title: 'Data Views',
      pathMatch: '/settings/dataView',
      show: userStore.userHasFeatureAccessLevel('DATA_VIEW', 'ADMIN')
    }, {
      path: '/settings/orgTypes',
      title: 'Organization Types',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/eventStatuses',
      title: 'Event Statuses',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/processStepStatuses',
      title: 'Process Step Statuses',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/projectStatuses',
      title: 'Project Statuses',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/smsTeams',
      title: 'SMS Teams',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/workQueue/types',
      title: 'Work Queue',
      show: hasSettingsAccess.value || userStore.userHasFeatureAccessLevel('WORK_QUEUE', 'ADMIN')
    }, {
      header: 'Processes',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/processes',
      pathMatch: '/settings/processes',
      title: 'Processes',
      show: hasSettingsAccess.value
    }, {
      path: '/settings/processSteps',
      pathMatch: '/settings/processStep',
      pathMatchExclude: '/settings/processStepStatuses',
      title: 'Process Steps',
      show: hasSettingsAccess.value
    }, {
      header: 'Objects',
      show: hasSettingsAccess.value
    }
    // , {
    //   path: '/settings/project/customFieldGroups?=${c.id}',
    //   title: 'Project',
    //   show: hasSettingsAccess.value
    // }
  ]
})

const getCompanyObjectTypes = async () => {
  if(hasSettingsAccess.value) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/objectType/getCompanyObjectTypes`, null,[])
      companyObjectTypes.value = data
      setTitle()
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const setTitle =  (_title)  => {
  //title passed in on item click
  if(_title){
    title.value = _title
  }
  // this determines the title if the page is refreshed
  else if(route.path.includes('/settings/customFieldGroup') || route.path.includes('/customFieldGroups')) {
    if(companyObjectTypes.value.length > 0) {
      const match = companyObjectTypes.value.find(ot => ot.id.toString() === route.params.id)
      title.value = match?.objectType
    }
  } else {
    title.value = items.value.find(i => i.pathMatch ?? i.path === route.path).title
  }
}
const collapseMenu =  () => {
  userStore.settingsMenuCollapsed = !userStore.settingsMenuCollapsed
}

onMounted(() =>{
  getCompanyObjectTypes()
  setTitle()
})

</script>

<style scoped lang="scss">
.settings-container {
  height: calc(100vh - 50px);
  max-width: 100vw;
  flex-grow:2;
  @media (max-width: 960px) {
    width: 100vw;
  }
}

a {
  text-decoration: none;
}

.left-menu {
  max-height: calc(100vh - 50px);
  height: calc(100vh - 50px);
  overflow: auto;
  background-color: var(--v-grey-lighten4);
}

.left-column {
  background-color: var(--v-grey-lighten4);
  height: 100%;
  max-height: 100%;
}
.collapse-left {
  max-width: 72px;
  padding-left:0;
  div.left-menu {
    justify-content: center !important;
  }
}
.hidden {
  display: none;
}

.main-section {
  height: 100vh;
  background-color: #fff;
  max-height: 100%;
  overflow: auto;
  .main-section-left-collapsed {
    max-width: calc(100% - 72px) !important;
  }

}
</style>

<style lang="scss">
.settings-container {
  .v-menu__content.theme--light.menuable__content__active{
    @media (max-width: 960px) {
      max-height: calc(100vh - 110px);
    }
  }
}
</style>

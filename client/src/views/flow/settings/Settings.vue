<template>
  <v-container class="pt-0">
    <v-row class="settings-container">
      <v-col cols="12" md="3" class="text-left pa-0 left-column">
        <v-menu data-app left
                v-if="constants.IS_MOBILE"
                offset-y
                v-model="menuOpen"
                max-height="350"
                class="account-menu"
                :close-on-content-click="false">
          <template v-slot:activator="{ on }">
            <v-toolbar
              color="white"
              v-on="on"
            >
              {{ title }}
              <v-spacer></v-spacer>
              <v-btn text>
                <v-icon>expand_more</v-icon>
              </v-btn>
            </v-toolbar>
          </template>
          <v-list dense class="pa-3">
            <template v-for="(item, index) in filterBy(items, true, 'show')">
              <h3 v-if="item.header">{{item.header}}</h3>

              <v-list-item
                v-else
                :key="item.title"
                :to="item.path"
                :class="{'shaded-row': item.pathMatch ? $route.path.includes(`${item.pathMatch}`) : $route.path === item.path}"
                @click="[menuOpen = false, setTitle(item.title)]"
              >
                <v-list-item-content>
                  <v-list-item-title>{{item.title}}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
            <v-list-item dense v-for="o in filterBy(companyObjectTypes, 1, 'flowTypeId')" :key="o.id"
                         :to="{ path: `/settings/customFieldGroup/${o.id}`}"
                         @click="menuOpen = false, setTitle(o.objectType)"
                         :class="{'shaded-row': $route.path === `/settings/customFieldGroup/${o.id}`}">
              <v-list-item-content>
                <v-list-item-title>{{o.objectType}}</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </v-menu>
        <v-card class="px-5 py-2 left-menu square-card" v-else>
          <v-list dense color="transparent">
            <template v-for="(item, index) in filterBy(items, true, 'show')">
              <h3 v-if="item.header">{{item.header}}</h3>
              <v-list-item
                v-else
                :key="item.title"
                @click="setTitle"
                :to="item.path"
                class="dense-setting-row"
                :class="{'shaded-row': item.pathMatch && item.pathMatchExclude ? $route.path.includes(`${item.pathMatch}`) && !$route.path.includes(item.pathMatchExclude)
                                          : item.pathMatch ? $route.path.includes(`${item.pathMatch}`) : $route.path === item.path}"
              >
                <v-list-item-content>
                  <v-list-item-title>{{item.title}}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
            <v-list-item dense v-for="o in filterBy(companyObjectTypes, (cot) => { return [1,3,4,5].includes(cot.flowTypeId) })" :key="o.id"
                         :to="{ path: o.flowTypeId === 3 ? `/settings/project/customFieldGroups?companyObjectTypeId=${o.id}` :
                                      o.flowTypeId === 4 ? `/settings/events` :
                                      o.flowTypeId === 5 ? `/settings/attachments` : `/settings/objectType/${o.id}/customFieldGroups?objectType=${o.objectType}`}"
                         @click="setTitle"
                         class="dense-setting-row"
                         :class="{'shaded-row': $route.path === `/settings/objectType/${o.id}/customFieldGroups?objectType=${o.objectType}` || ($route.query && $route.query.companyObjectTypeId && parseInt($route.query.companyObjectTypeId) === o.id)}">
              <v-list-item-content>
                <v-list-item-title>{{o.objectType}}</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </v-card>
      </v-col>
      <v-col cols="12" md="9" class="px-4 pt-0 main-section">
        <router-view/>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'

import Vue2Filters from 'vue2-filters'
import { handleHidingGlobalLoader, getRequest, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'Settings',
  mixins: [Vue2Filters.mixin],

  data () {
    return {
      snackbar: {},
      menuOpen: false,
      constants,
      title: null,
      hasSettingsAccess: this.$store.getters.userHasFeature('SETTINGS'),
      companyObjectTypes: [],
      companyId: this.$store.state.user.details.companyId,
      parentId: this.$store.state.user.details.parentCompanyId,

    }
  },
  computed: {
    items() { return [
      {
        header: 'Preferences',
        show: true
      }, {
        path: '/settings/userProfile',
        title: 'User Profile',
        show: true
      }, {
        header: 'Company',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/company/settings',
        title: 'Defaults',
        pathMatch: '/settings/company',
        show: this.hasSettingsAccess,
      }, {
        path: '/settings/proposals',
        title: 'Proposals',
        show: this.$store.getters.userHasFeatureAccessLevel('PROPOSALS', 'ADMIN')
      }, {
        path: '/settings/states',
        title: 'States',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/postalCodes',
        title: 'Round Robins',
        pathMatch: '/settings/postalCode',
        show: this.$store.getters.userHasFeature('ROUND_ROBIN')
      }, {
        path: '/settings/callGroups',
        title: 'Call Groups',
        pathMatch: '/settings/callGroup',
        show: this.$store.getters.userHasFeature('CALL_GROUPS')
      }, {
        path: '/settings/tournaments',
        title: 'Tournaments',
        pathMatch: '/settings/tournaments',
        show: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'ADMIN')
      }, {
        path: '/settings/companyCustomFields',
        title: 'Company Custom Fields',
        show: this.hasSettingsAccess && null != this.$store.state.user.details.apiPath,
      }, {
        path: '/settings/companyObjectTypes',
        title: 'Company Object Types',
        show: this.hasSettingsAccess && null != this.$store.state.user.details.apiPath,
      },
      {
        header: 'User Management',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/availability/main/schedule',
        title: 'Availability',
        show: this.hasSettingsAccess || this.$store.getters.userHasFeature('AVAILABILITY')
      }, {
        path: '/settings/positions',
        title: 'Positions',
        show: this.hasSettingsAccess
      }, {
        // path: '/settings/roles',
        // title: 'Roles',
        // }, {
        header: 'Custom Components',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/customFields',
        title: 'Custom Fields',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/links',
        title: 'Links',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/functions',
        pathMatch: '/settings/function',
        title: 'Functions',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/messageTemplates',
        title: 'Message Templates',
        show: this.hasSettingsAccess
      }, {
        header: 'Configurations',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/dataViews',
        title: 'Data Views',
        pathMatch: '/settings/dataView',
        show: this.$store.getters.userHasFeatureAccessLevel('DATA_VIEW', 'ADMIN')
      }, {
        path: '/settings/orgTypes',
        title: 'Organization Types',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/eventStatuses',
        title: 'Event Statuses',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/processStepStatuses',
        title: 'Process Step Statuses',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/projectStatuses',
        title: 'Project Statuses',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/smsTeams',
        title: 'SMS Teams',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/workQueue/types',
        title: 'Work Queue',
        show: this.hasSettingsAccess || this.$store.getters.userHasFeatureAccessLevel('WORK_QUEUE', 'ADMIN')
      }, {
        header: 'Processes',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/processes',
        pathMatch: '/settings/processes',
        title: 'Processes',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/processSteps',
        pathMatch: '/settings/processStep',
        pathMatchExclude: '/settings/processStepStatuses',
        title: 'Process Steps',
        show: this.hasSettingsAccess
      }, {
        header: 'Objects',
        show: this.hasSettingsAccess
      }
      // , {
      //   path: '/settings/project/customFieldGroups?=${c.id}',
      //   title: 'Project',
      //   show: this.hasSettingsAccess
      // }
    ]
    }
  },
  methods: {
    async getCompanyObjectTypes () {
      if(this.hasSettingsAccess) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/objectType/getCompanyObjectTypes`)
          this.companyObjectTypes = data
          this.setTitle()
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    setTitle (title) {
      //title passed in on item click
      if(title){
        this.title = title
      }
      // this determines the title if the page is refreshed
      else if( this.$route.path.includes('/settings/customFieldGroup')) {
        if(this.companyObjectTypes.length > 0) {
          const match = this.companyObjectTypes.find(ot => ot.id.toString() === this.$route.params.id)
          this.title = match?.objectType
        }
      } else {
        this.title = this.items.find(i => i.pathMatch ?? i.path === this.$route.path).title
      }
    }
  },
  created () {
    this.getCompanyObjectTypes()
  }
}
</script>

<style scoped lang="scss">
.settings-container {
  height: calc(100vh - 50px);
  overflow: hidden;
}

a {
  text-decoration: none;
}

.left-menu {
  max-height: 100%;
  height: 100%;
  overflow: auto;
  background-color: var(--v-grey-lighten4);
}

.left-column {
  background-color: var(--v-grey-lighten4);
  height: 100%;
  max-height: 100%;
}

.main-section {
  background-color: #fff;
  max-height: 100%;
  overflow: auto;
}

.dense-setting-row {
  height: 30px !important;
  min-height: 30px !important;
}
</style>

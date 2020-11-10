<template>
  <v-container>
    <v-row>
      <v-col cols="12" md="3" class="text-left">
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
        <v-card class="px-5 py-2" v-else>
          <v-list dense>
            <template v-for="(item, index) in filterBy(items, true, 'show')">
              <h3 v-if="item.header">{{item.header}}</h3>

              <v-list-item
                  v-else
                  :key="item.title"
                  @click="setTitle"
                  :to="item.path"
                  :class="{'shaded-row': item.pathMatch ? $route.path.includes(`${item.pathMatch}`) : $route.path === item.path}"
              >
                <v-list-item-content>
                  <v-list-item-title>{{item.title}}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
            <v-list-item dense v-for="o in filterBy(companyObjectTypes, (cot) => { return cot.flowTypeId === 1 || cot.flowTypeId === 3 })" :key="o.id"
                         :to="{ path: o.flowTypeId === 3 ? `/settings/project/customFieldGroups?companyObjectTypeId=${o.id}` : `/settings/customFieldGroup/${o.id}`}"
                         @click="setTitle"
                         :class="{'shaded-row': $route.path === `/settings/customFieldGroup/${o.id}` || $route.path.includes(`?companyObjectTypeId=${o.id}`)}">
              <v-list-item-content>
                <v-list-item-title>{{o.objectType}}</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </v-card>
      </v-col>
      <v-col cols="12" md="9" class="pa-4">
        <v-sheet color="#fff" class="elevation-2 text-left">
          <router-view/>
        </v-sheet>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'

import Vue2Filters from 'vue2-filters'
import { getRequest, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'
const { VUE_APP_ENV } = process.env

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
        path: '/settings/company',
        title: 'Company',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/postalCodes',
        title: 'Round Robins',
        show: this.hasSettingsAccess
      }, {
        header: 'User Management',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/availability',
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
        path: '/settings/attachments',
        title: 'Attachments',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/links',
        title: 'Links',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/orgTypes',
        title: 'Organization Types',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/eventTypes',
        title: 'Scheduling Tool Event Types',
        show: this.$store.getters.isParent(this.parentId) && this.hasSettingsAccess
      }, {
        path: '/settings/workQueue/types',
        title: 'Work Queue',
        show: this.$store.getters.isParent(this.parentId) && this.hasSettingsAccess
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
        title: 'Process Steps',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/functions',
        pathMatch: '/settings/function',
        title: 'Functions',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/statuses',
        title: 'Statuses',
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
    async getCustomFieldObjectTypes () {
      if(this.hasSettingsAccess) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/customField/getCustomFieldObjectTypes`)
          this.companyObjectTypes = data
          this.setTitle()
          this.$store.commit(AppMutations.SET_LOADING, false)
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
    this.getCustomFieldObjectTypes()
  }
}
</script>

<style scoped lang="scss">
a {
  text-decoration: none;
}
</style>

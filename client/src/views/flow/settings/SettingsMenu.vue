<template>
  <v-list :dense="$vuetify.breakpoint.smAndUp" color="transparent" class="">
    <template v-for="(item, index) in filterBy(items, true, 'show')">
      <h3 class="label-large" v-if="item.header">{{item.header}}</h3>
      <v-list-item
          v-else
          :key="item.title"
          @click="selectMenuItem(item.title)"
          :to="item.path"
          class="dense-setting-row"
          :class="{'shaded-row': item.pathMatch && item.pathMatchExclude ? $route.path.includes(`${item.pathMatch}`) && !$route.path.includes(item.pathMatchExclude)
                                          : item.pathMatch ? $route.path.includes(`${item.pathMatch}`) : $route.path === item.path}"
      >
        <v-list-item-content>
          <v-list-item-title class="body-medium">{{item.title}}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </template>
    <v-list-item :dense="$vuetify.breakpoint.smAndDown" v-for="o in filterBy(companyObjectTypes, (cot) => { return [1,3,4,5].includes(cot.flowTypeId) })" :key="o.id"
                 :to="{ path: o.flowTypeId === 3 ? `/settings/project/customFieldGroups?companyObjectTypeId=${o.id}` :
                                      o.flowTypeId === 4 ? `/settings/events` :
                                      o.flowTypeId === 5 ? `/settings/attachments` : `/settings/objectType/${o.id}/customFieldGroups?objectType=${o.objectType}`}"
                 @click="selectMenuItem(o.objectType)"
                 class="dense-setting-row"
                 :class="{'shaded-row': $route.path === `/settings/objectType/${o.id}/customFieldGroups?objectType=${o.objectType}` || ($route.query && $route.query.companyObjectTypeId && parseInt($route.query.companyObjectTypeId) === o.id)}">
      <v-list-item-content>
        <v-list-item-title class="body-medium">{{o.objectType}}</v-list-item-title>
      </v-list-item-content>
    </v-list-item>
  </v-list>

</template>

<script>
import {AppMutations} from '@/stores/AppStore'

import Vue2Filters from 'vue2-filters'
import { handleHidingGlobalLoader, getRequest, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'
export default {
  name: "SettingsMenu",
  props: {
    title: String
  },
  data(){
    return {
      constants,
      hasSettingsAccess: this.$store.getters.userHasFeature('SETTINGS'),
      companyObjectTypes: [],
    }
  },
  mixins: [Vue2Filters.mixin],
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
        pathMatch: '/settings/companyCustomField',
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
        pathMatch: '/settings/customField',
        title: 'Custom Fields',

        show: this.hasSettingsAccess
      }, {
        path: '/settings/links',
        title: 'Links',
        show: this.hasSettingsAccess
      }, {
        path: '/settings/tags',
        title: 'Tags',
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
      this.$emit('updateTitle', title)
    },
    selectMenuItem(title){
      this.setTitle(title)
      this.$emit('closeMenu')

    }
  },
  created () {
    this.getCompanyObjectTypes()
  }
}
</script>

<style lang="scss" scoped>
@media (min-width: 960px) {
  .dense-setting-row {
    height: 30px !important;
    min-height: 30px !important;
  }
}
</style>

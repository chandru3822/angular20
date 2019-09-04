<template>
<v-container grid-list-xl>
  <v-layout row wrap>
    <v-flex xs4 class="text-left">
      <v-sheet  class="elevation-2 pa-4 br-10 testing">
        <h2>Preferences</h2>
        <v-subheader :class="{'shaded-row': $route.path === `/settings/userProfile`}">
          <router-link to="/settings/userProfile">User Profile</router-link>
        </v-subheader>
        <v-subheader>Account</v-subheader>
        <h2>Custom Components</h2>
        <v-subheader :class="{'shaded-row': $route.path === `/settings/customFields`}">
          <router-link to="/settings/customFields">Custom Fields</router-link>
        </v-subheader>
        <v-subheader :class="{'shaded-row': $route.path === `/settings/attachments`}">
          <router-link to="/settings/attachments">Attachments</router-link>
        </v-subheader>
        <v-subheader :class="{'shaded-row': $route.path === `/settings/links`}">
          <router-link to="/settings/links">Links</router-link>
        </v-subheader>
        <h2>Processes</h2>
        <v-subheader :class="{'shaded-row': $route.path === `/settings/processes`}">
          <router-link to="/settings/processes">Processes</router-link>
        </v-subheader>
        <v-subheader :class="{'shaded-row': $route.path.includes('/settings/processStep')}">
          <router-link to="/settings/processSteps">Process Steps</router-link>
        </v-subheader>
        <v-subheader :class="{'shaded-row': $route.path === `/settings/functions`}">
          <router-link to="/settings/functions">Functions</router-link>
        </v-subheader>
        <v-subheader :class="{'shaded-row': $route.path === `/settings/statuses`}">
          <router-link to="/settings/statuses">Statuses</router-link>
        </v-subheader>
        <h2>Objects</h2>
        <v-subheader v-for="o in filterBy(objectTypes, 1, 'flowTypeId')" :index="o.id" :class="{'shaded-row': $route.path === `/settings/customFieldGroup/${o.id}`}">
          <router-link :to="{ path: `/settings/customFieldGroup/${o.id}`}">{{o.objectType}}</router-link>
        </v-subheader>
      </v-sheet>
    </v-flex>
    <v-flex xs8>
      <v-sheet color="#fff" class="elevation-2 text-xs-left pa-4 br-10">
        <router-view/>
      </v-sheet>
    </v-flex>
  </v-layout>
  <Snackbar :snackbar="snackbar"></Snackbar>
</v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import { getSnackbar } from '@/helpers/helpers'
import Vue2Filters from 'vue2-filters'
import { getRequest } from '@/helpers/helpers'

export default {
  name: 'Settings',
  mixins: [Vue2Filters.mixin],
  components: {
    Snackbar
  },
  data () {
    return {
      snackbar: {},
      objectTypes: [],
      companyId: this.$store.state.user.details.companyId
    }
  },
  computed: {
  },
  methods: {
    async getCustomFieldObjectTypes () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/customField/getCustomFieldObjectTypes`)
        this.objectTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  },
  created () {
    this.getCustomFieldObjectTypes()
  }
}
</script>

<style scoped lang="scss">
testing {
  background-color: red;
}
a {
  text-decoration: none;
}
</style>

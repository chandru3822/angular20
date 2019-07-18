<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" flat>
        <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        <v-spacer></v-spacer>
        <div v-if="changesMade">
          <v-btn class="mr-2" :to="{ path: `/settings/processSteps`}">cancel</v-btn>
          <v-btn color="primary white--text" @click="saveProcessStep">Save Changes</v-btn>
        </div>
      </v-toolbar>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">
          {{ processStep.processStepName }}
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-tabs>
            <v-tab to="/settings/processStep/1/components">
              UI Components
            </v-tab>
            <v-tab to="/settings/processStep/1/actions">
              Actions
            </v-tab>
          </v-tabs>
        </v-toolbar-items>
      </v-toolbar>
      <router-view/>
    </v-flex>

  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: 'ProcessStep',
    mixins: [Vue2Filters.mixin],
    components: {
      ProcessStepCustomFieldGroups
    },
    data () {
      return {
        changesMade: false,
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        processStep: {},
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/settings/processSteps`
          },
        ]
      }
    },
    computed: {
    },
    async created () {
      this.getProcessStepDetails()
    },
    methods: {
      async getProcessStepDetails () {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}`)
        this.processStep = data
      },
    }

  }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-rowShadeCustom-base) !important;
  border-radius: 5px;
}
</style>

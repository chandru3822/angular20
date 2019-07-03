<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">
          {{ this.processStepId ? this.processStep.processStepName : 'New Process Step'}}
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          UI Components
        </v-toolbar-items>
      </v-toolbar>
      <v-container class="mt-2 name-container">
        <v-text-field
            label="Process Step Name"
            tabindex=1
            v-model="processStep.processStepName"
        ></v-text-field>
        <v-autocomplete
            v-model="processStep.orgId"
            :items="orgs"
            tabindex=2
            label="Owning Org"
            item-text="orgName"
            item-value="id"
            browser-autocomplete="new-password"
            return-object
        ></v-autocomplete>
        <v-btn v-if="!processStepId" :disabled="!processStep.processStepName" @click="addProcessStep">Save</v-btn>
      </v-container>
      <v-flex v-if="processStepId">
        <h3>Custom Fields</h3>
        <v-btn>
          <v-icon>add</v-icon>
          Create Group
        </v-btn>
      </v-flex>
      <v-divider></v-divider>
      <v-flex v-if="processStepId">
        <h3>Links</h3>
        <v-btn>
          <v-icon>add</v-icon>
          Create Group
        </v-btn>
      </v-flex><v-divider></v-divider>
      <v-flex v-if="processStepId">
        <h3>Attachments</h3>
        <v-btn>
          <v-icon>add</v-icon>
          Create Group
        </v-btn>
      </v-flex>
    </v-flex>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: 'ProcessStep',
    mixins: [Vue2Filters.mixin],
    data () {
      return {
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        processStep: {},
        orgs: [],
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            href: '/settings/customFields'
          },
        ]
      }
    },
    computed: {
    },
    methods: {
      async addProcessStep () {
        console.log('ADD HERE', this.processStep)
      },
      async getProcessStepDetails () {
        console.log('will load details here', this.processStep)
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${this.processStepId}`)
        this.processStep = data
      },
      async getOrgs () {
        console.log('will load orgs here')
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/org`)
        this.orgs = data
      }
    },
    async created () {
      this.getOrgs()
      if(this.processStepId) {
        this.getProcessStepDetails()
      }
    }
  }
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-rowShadeCustom-base) !important;
  border-radius: 5px;
}
</style>

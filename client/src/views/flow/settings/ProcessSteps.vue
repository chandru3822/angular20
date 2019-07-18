<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar class="testing elevation-1">
        <v-toolbar-title class="app-title">Process Steps</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="addNew = !addNew; newStep = {}">
            {{'Add New'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container>
        <v-text-field v-if="addNew"
            label="Process Step Name"
            tabindex=1
            v-model="newStep.processStepName"
        ></v-text-field>
        <v-btn v-if="addNew" :disabled="!newStep.processStepName" @click="addProcessStep">Save</v-btn>
        <v-list v-for="(ps, index) in filterBy(processSteps, false, 'archived')"
                :key="index">
          <v-list-item>
            <v-list-item-content>
              {{ps.processStepName}}
            </v-list-item-content>
            <v-list-item-action class="clickable">
              <v-btn :to="{ path: `/settings/processStep/${ps.id}/components`}" text>
                <v-icon>edit</v-icon>
              </v-btn>
            </v-list-item-action>
            <v-dialog
                v-model="ps.deleteConfirm"
                width="500">
              <template v-slot:activator="{ on }">
                <v-list-item-action class="clickable" v-on="on">
                  <v-icon>delete</v-icon>
                </v-list-item-action>
              </template>
              <v-card>
                <v-card-title
                    class="headline grey lighten-2"
                    primary-title
                >
                  Confirm
                </v-card-title>

                <v-card-text>
                  Are you sure you want to delete this process step: <strong>{{ ps.processStepName }}</strong>?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                      @click="ps.deleteConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                      color="primary"
                      text
                      @click="ps.archived = true; deleteProcessStep(ps.id)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>
        </v-list>
      </v-container>
    </v-flex>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: 'ProcessSteps',
    mixins: [Vue2Filters.mixin],
    data () {
      return {
        addNew: false,
        newStep: {},
        selectedProcessStepId: null,
        companyId: this.$store.state.user.details.companyId,
        userId: this.$store.state.user.details.id,
        processSteps: []
      }
    },
    computed: {
    },
    methods: {
      async getProcessSteps () {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep`)
        this.processSteps = data
      },
      async deleteProcessStep (processStepId) {
        await deleteRequest(`/api/v1/flow/companies/${this.companyId}/processStep/${processStepId}`)
      },
      async addProcessStep () {
        const {data} = await postRequest(`/api/v1/flow/companies/${this.companyId}/processStep`, this.newStep)
        this.$router.push({path: `/settings/processStep/${data.id}/components`})
      },
    },
    async created () {
      this.getProcessSteps()
    }
  }
</script>

<style scoped lang="scss">


</style>

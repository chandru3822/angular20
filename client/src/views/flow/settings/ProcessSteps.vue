<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Process Steps</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn flat :to="{ path: `/settings/processStep`}">
            {{'Add New'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container>
        <!--<v-list v-for="(ps, index) in filterBy(processSteps, false, 'archived')"-->
        <v-list v-for="(ps, index) in processSteps"
                :key="index">
          <v-list-tile>
            <v-list-tile-content>
              {{ps.processStepName}}
            </v-list-tile-content>
            <v-list-tile-action class="clickable">
              <v-btn :to="{ path: `/settings/processStep/${ps.id}`}" flat>
                <v-icon>edit</v-icon>
              </v-btn>
            </v-list-tile-action>
            <v-dialog
                v-model="ps.deleteConfirm"
                width="500">
              <template v-slot:activator="{ on }">
                <v-list-tile-action class="clickable" v-on="on">
                  <v-icon>delete</v-icon>
                </v-list-tile-action>
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
                      flat
                      @click="ps.archived = true; deleteProcessStep(ps.id)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-tile>
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
      }
    },
    async created () {
      this.getProcessSteps()
    }
  }
</script>

<style scoped lang="scss">

</style>

<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Process Steps</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn flat @click="addNew = !addNew; newProject = {}">
            {{addNew ? 'Cancel' : 'Add New'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container>
        <v-text-field v-if="addNew"
                      v-model="newProcessStep.processName"
                      placeholder="Enter new process name"
                      label="Process">
        </v-text-field>
        <v-btn v-if="addNew" @click="addNewProcessStep">Save</v-btn>
        <v-list v-for="(ps, index) in filterBy(processSteps, false, 'archived')"
                :key="index">
          <v-list-tile>
            <v-list-tile-content>
              <v-text-field class="one-hunned" v-if="selectedProcessStepId === ps.id" v-model="ps.processName">
              </v-text-field>
              <div v-else>{{ps.processName}}</div>
            </v-list-tile-content>
            <v-list-tile-action class="clickable">
              <v-icon v-if="selectedProcessStepId === ps.id" @click="saveProcessStep(ps)">save</v-icon>
              <v-icon v-else @click="selectedProcessStepId = ps.id">edit</v-icon>
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
                  Are you sure you want to delete this process step: <strong>{{ ps.processName }}</strong>?
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
        <!--<v-btn v-else-if="groupOrderChanged" @click="saveGroupChanges">Save Changes</v-btn>-->
      </v-container>
    </v-flex>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import orderBy from 'lodash.orderby'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

  export default {
    name: 'ProcessSteps',
    mixins: [Vue2Filters.mixin],
    data () {
      return {
        addNew: false,
        selectedProcessStepId: null,
        newProcessStep: {},
        companyId: this.$store.state.user.details.companyId,
        parentCompanyId: this.$store.state.user.details.parentCompanyId,
        userId: this.$store.state.user.details.id,
        processSteps: []
      }
    },
    computed: {
    },
    methods: {
      async getProcessSteps () {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processes`)
        this.processSteps = data
      },
      async deleteProcessStep (processId) {
        // await deleteRequest(`/api/v1/flow/companies/${this.companyId}/processes/${processId}`)
      },
      async addNewProcessStep () {
        // const {data} = await postRequest(`/api/v1/flow/companies/${this.companyId}/processes`, this.newProcessStep)

        // add it to the records already on the screen
        this.processSteps.push(data)
        this.processSteps = orderBy(this.processSteps, [ps => ps.processName.toLowerCase()])

        // reset the new process fields
        this.addNew = false
        this.newProcessStep = {}
      },
      async saveProcessStep (ps) {
        this.selectedProcessStepId = null
        ps.modifiedById = this.userId
        // await putRequest(`/api/v1/flow/companies/${this.companyId}/processes`, ps)
      }
    },
    async created () {
      this.getProcessSteps()
    }
  }
</script>

<style scoped lang="scss">

</style>

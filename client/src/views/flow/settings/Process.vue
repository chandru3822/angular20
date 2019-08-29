<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" flat>
        <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        <v-spacer></v-spacer>
        <div v-if="changesMade">
          <v-btn class="mr-2" :to="{ path: `/settings/processes`}">cancel</v-btn>
          <v-btn color="primary white--text" @click="saveProcess">Save Changes</v-btn>
        </div>
      </v-toolbar>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">
          {{  processId ? process.processName : 'New Process Step'}}
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="getAvailableProcessSteps(); getOwningOrgs()">
            {{addNew ? 'Cancel' : 'Add Process Step'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container v-if="addNew">
        <v-select v-model="newProcessStep.processStepId"
                  :items="availableProcessSteps"
                  no-data-text="No Steps Available"
                  label="Select a Process Step"
                  item-text="processStepName"
                  item-value="id"
        ></v-select>
        <v-select v-model="newProcessStep.orgId"
                  :items="owningOrgs"
                  no-data-text="No Orgs Available"
                  label="Select an Owning Org"
                  item-text="orgName"
                  item-value="id"
        ></v-select>
        <v-btn :disabled="!newProcessStep.processStepId || !newProcessStep.orgId" @click="assignProcessStep">Save</v-btn>
      </v-container>
      <v-data-table
          :headers="headers"
          :items="process.processStepProcesses"
          :items-per-page="-1"
          hide-default-footer
          class="elevation-1"
      >
        <template v-slot:no-data>
          NO DATA HERE!
        </template>

        <template v-slot:no-results>
          NO RESULTS HERE!
        </template>

        <template #body="{ items }">
          <tr v-for="(item, index) in filterBy(items, false, 'archived')" :key="item.id" v-if="!item.custom" :class="{ 'shaded-row': index % 2 }">
            <td>{{ item.processStepName }}</td>
            <td>{{ item.orgName }}</td>
            <td>{{ item.dateCreated | formatDate('date', $store.state.user.details.timezone) }}</td>
            <td>{{ item.dateModified | formatDate('date', $store.state.user.details.timezone) }}</td>
            <td>
              <v-dialog
                  v-model="item.deleteConfirm"
                  width="500">
                <template v-slot:activator="{ on }">
                  <v-btn text v-on="on">
                    <v-icon>delete</v-icon>
                  </v-btn>
                </template>
                <v-card>
                  <v-card-title
                      class="headline grey lighten-2"
                      primary-title>
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to delete <strong>{{ item.processStepName }}</strong> from <strong>{{process.processName}}</strong>?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="item.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        color="primary"
                        text
                        @click="item.archived = true; deleteStepFromProcess(item.id)">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </td>
          </tr>
        </template>
      </v-data-table>
    </v-flex>
  </v-layout>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import orderBy from 'lodash.orderby'
import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

export default {
  name: 'Process',
  mixins: [Vue2Filters.mixin],
  data () {
    return {
      addNew: false,
      newProcessStep: {},
      availableProcessSteps: [],
      owningOrgs: [],
      processId: this.$route.params.id,
      companyId: this.$store.state.user.details.companyId,
      changesMade: false,
      process: {},
      breadcrumbs: [
        {
          text: 'Back',
          disabled: false,
          exact: true,
          to: `/settings/processes`
        },
      ],
      headers: [
        { text: 'Name', value: 'processStepName'},
        { text: 'Owning Org', value: 'orgName'},
        { text: 'Created', value: 'dateCreated'},
        { text: 'Last Modified', value: 'dateModified'},
        { text: null, value: null},
      ]
    }
  },
  async created () {
    this.getProcessDetails()
  },
  computed: {
  },
  methods: {
    async getProcessDetails () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      const {data} = await getRequest(`/api/v1/flow/${this.companyId}/processes/${this.processId}`)
      this.process = data
      this.$store.commit(AppMutations.SET_LOADING, false)
    },
    async saveProcess () {
      console.log('will save process here')
    },
    async deleteStepFromProcess (id) {
      //reset the addNew field in case they delete one while it is open
      this.addNew = false
      await deleteRequest(`/api/v1/flow/${this.companyId}/processes/processStepProcess/${id}`)
    },
    async getOwningOrgs () {
      console.log('will load orgs here')
      const {data} = await getRequest(`/api/v1/flow/${this.companyId}/org/owning`)
      this.owningOrgs = data
    },
    async getAvailableProcessSteps () {
      //reset field in case they hit cancel
      this.newProcessStep = {}
      this.addNew = !this.addNew
      if(this.addNew) {
        const {data} = await getRequest(`/api/v1/flow/${this.companyId}/processes/availableProcessSteps/${this.processId}`)
        this.availableProcessSteps = data
      }
    },
    async assignProcessStep () {
      const {data} = await postRequest(`/api/v1/flow/${this.companyId}/processes/${this.processId}/processStep`, this.newProcessStep)
      console.log('randaLogger', data)
      this.process.processStepProcesses.push(data)
      this.process.processStepProcesses = orderBy(this.process.processStepProcesses, p => p.processStepName.toLowerCase())
      this.addNew = false
      this.newProcessStep = {}
    }
  },
}
</script>

<style scoped lang="scss">

</style>

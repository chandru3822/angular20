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
          <v-btn text @click="getAvailableProcessSteps">
            {{addNew ? 'Cancel' : 'Add Process Step'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container v-if="addNew">
        <v-select v-model="newProcessStepId"
                  :items="availableProcessSteps"
                  label="Select a Process Step"
                  no-data-text="No Steps Available"
                  item-text="processStepName"
                  item-value="id"
                  @input="assignProcessStep"
        ></v-select>
      </v-container>
      <v-data-table
          :headers="headers"
          :items="process.processStepProcesses"
          :items-per-page="-1"
          hide-default-footer
          class="elevation-1"
      >
        <template #body="{ items }">
          <tr v-for="(item, index) in filterBy(items, false, 'archived')" :key="item.id" v-if="!item.custom" :class="{ 'shaded-row': index % 2 }">
            <td>{{ item.processStepName }}</td>
            <td>{{ item.dateCreated | formatDate('M/D/YYYY') }}</td>
            <td>{{ item.dateUpdated | formatDate('M/D/YYYY') }}</td>
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
      newProcessStepId: null,
      availableProcessSteps: [],
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
        { text: 'Created', value: 'dateCreated'},
        { text: 'Last Modified', value: 'dateUpdated'},
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
      const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processes/${this.processId}`)
      this.process = data
    },
    async saveProcess () {
      console.log('will save process here')
    },
    async deleteStepFromProcess (id) {
      await deleteRequest(`/api/v1/flow/companies/${this.companyId}/processes/processStepProcess/${id}`)
    },
    async getAvailableProcessSteps (processId) {
      //reset field in case they hit cancel
      this.newProcessStepId = null
      this.addNew = !this.addNew
      if(this.addNew) {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processes/availableProcessSteps/${this.processId}`)
        this.availableProcessSteps = data
      }
    },
    async assignProcessStep () {
      const {data} = await postRequest(`/api/v1/flow/companies/${this.companyId}/processes/${this.processId}/processStep/${this.newProcessStepId}`)
      console.log('randaLogger', data)
      this.process.processStepProcesses.push(data)
      this.process.processStepProcesses = orderBy(this.process.processStepProcesses, p => p.processStepName.toLowerCase())
      this.addNew = false
      this.newProcessStepId = null
    }
  },
}
</script>

<style scoped lang="scss">

</style>

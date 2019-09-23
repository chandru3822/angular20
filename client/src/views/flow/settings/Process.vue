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
          <v-text-field class="d-inline-block mt-4" v-if="editName" v-model="process.processName"></v-text-field>
          <span v-else>
            {{  processId ? process.processName : 'New Process Step'}}
          </span>
          <v-btn class="d-inline-block" small text v-if="processId && editName" @click="saveProcess()">
            <v-icon>save</v-icon>
          </v-btn>
          <v-btn class="d-inline-block" small text v-else-if="processId" @click="editName = true">
            <v-icon>edit</v-icon>
          </v-btn>
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
            <td class="text-left">{{ item.processStepName }}</td>
            <td class="text-left">{{ item.orgName }}</td>
            <td class="text-left">{{ item.dateCreated | formatDate('date', $store.state.user.details.timezone) }}</td>
            <td class="text-left">{{ item.dateModified | formatDate('date', $store.state.user.details.timezone) }}</td>
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
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-layout>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import orderBy from 'lodash.orderby'
import Snackbar from '@/components/Snackbar.vue'
import { getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'

export default {
  name: 'Process',
  mixins: [Vue2Filters.mixin],
  components: {
    Snackbar
  },
  data () {
    return {
      snackbar: {},
      addNew: false,
      editName: false,
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
      try {
        const {data} = await getRequest(`/processes/${this.processId}`)
        this.process = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveProcess () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.editName = false
        await putRequest(`/processes`, this.process)
        this.snackbar = getSnackbar('SUCCESS', 'Process Updated')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Process')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteStepFromProcess (id) {
      //reset the addNew field in case they delete one while it is open
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNew = false
        await deleteRequest(`/processes/processStepProcess/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Step Deleted from Process')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Step From Process')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getOwningOrgs () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/org/owning`)
        this.owningOrgs = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableProcessSteps () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //reset field in case they hit cancel
        this.newProcessStep = {}
        this.addNew = !this.addNew
        if(this.addNew) {
          const {data} = await getRequest(`/processes/availableProcessSteps/${this.processId}`)
          this.availableProcessSteps = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignProcessStep () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await postRequest(`/processes/${this.processId}/processStep`, this.newProcessStep)
        console.log('randaLogger', data)
        this.process.processStepProcesses.push(data)
        this.process.processStepProcesses = orderBy(this.process.processStepProcesses, p => p.processStepName.toLowerCase())
        this.addNew = false
        this.newProcessStep = {}
        this.snackbar = getSnackbar('SUCCESS', 'Process Step Assigned')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Assigning Process Step')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  },
}
</script>

<style scoped lang="scss">

</style>

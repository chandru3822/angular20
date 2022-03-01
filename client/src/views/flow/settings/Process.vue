<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" flat>
          <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
          <v-spacer></v-spacer>
          <div v-if="changesMade">
            <v-btn class="mr-2" :to="{ path: `/settings/processes`}">cancel</v-btn>
            <v-btn color="primaryCustom white--text" @click="saveProcess" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">Save Changes</v-btn>
          </div>
        </v-toolbar>
        <v-toolbar flat class="app-toolbar">
            <v-text-field class="d-inline-block mt-4" v-if="editName" v-model="process.processName"></v-text-field>
            <span v-else>
              {{  processId ? process.processName : 'New Process Step'}}
            </span>
            <v-btn class="d-inline-block" small text v-if="processId && editName && $store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')" @click="saveProcess()">
              <v-icon>save</v-icon>
            </v-btn>
            <v-btn class="d-inline-block" small text v-else-if="processId && $store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')" @click="editName = true">
              <v-icon>edit</v-icon>
            </v-btn>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="getAvailableProcessSteps()" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
              {{addNew ? 'Cancel' : 'Add Process Step'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container v-if="addNew">
          <v-autocomplete v-model="newProcessStep.processStepId"
                          :items="availableProcessSteps"
                          no-data-text="No Steps Available"
                          label="Select a Process Step"
                          item-text="processStepName"
                          item-value="id"
                          attach
          ></v-autocomplete>
          <v-autocomplete v-model="newProcessStep.owningPositions"
                          :items="owningPositions"
                          no-data-text="No Positions Available"
                          label="Select Owning Positions"
                          item-text="position"
                          item-value="positionId"
                          multiple
                          return-object
                          attach
          ></v-autocomplete>
<!--          <v-btn :disabled="!newProcessStep.processStepId || !newProcessStep.orgId" @click="assignProcessStep">Save</v-btn>-->
          <!--  per scott: temporarily removing requirement for orgId        -->
          <v-btn :disabled="!newProcessStep.processStepId || !newProcessStep.owningPositions || newProcessStep.owningPositions.length === 0"
                 @click="assignProcessStep">
            Save
          </v-btn>
        </v-container>
        <v-text-field
          v-model="search"
          class="mb-3 px-3"
          style="width: 250px;"
          append-icon="mdi-magnify"
          label="Search"
          single-line
          hide-details
        ></v-text-field>
        <v-data-table
            :headers="headers"
            :items="filterProcesses()"
            :items-per-page="100"
            :footer-props="footerProps"
            single-expand
            :search="search"
            fixed-header
            :expanded.sync="expanded"
            class="elevation-1"
        >
          <template v-slot:no-data>
            NO DATA HERE!
          </template>

          <template v-slot:no-results>
            NO RESULTS HERE!
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pb-4" :class="{'shaded-row': process.processStepProcesses.indexOf(item) % 2}">
              <v-card flat color="transparent" class="text-left pa-4">
                <div class="mb-2">
                  <label>Initial Step:</label>
                  <input type="checkbox" class="ml-2" v-model="item.initialStep" @change="getActiveAssignedToProcessStep(item)">
                  <v-autocomplete v-model="item.companyProcessStepStatusTypeId"
                                  v-if="item.initialStep"
                                  :loading="statusesLoading"
                                  class="mt-4 mb-2"
                                  :items="processStepStatusTypes"
                                  label="Initial Process Step Status Type"
                                  item-text="processStepStatusType"
                                  item-value="id"
                                  attach
                  ></v-autocomplete>
                </div>
                <v-autocomplete v-model="item.owningPositions"
                                class="pt-4"
                                :items="owningPositions"
                                no-data-text="No Positions Available"
                                label="Select Owning Positions"
                                item-text="position"
                                item-value="positionId"
                                multiple
                                return-object
                                attach
                ></v-autocomplete>
                <div class="mt-3 text-center">
                  <v-btn :disabled="(item.initialStep && !item.companyProcessStepStatusTypeId) || (!item.owningPositions || item.owningPositions.length === 0)"
                         @click="saveProcessStepProcess(item)">
                    <v-icon>save</v-icon>
                    Save
                  </v-btn>
                  <v-btn class="ml-3" @click="expanded = []">
                    <v-icon>remove</v-icon>
                    Cancel
                  </v-btn>
                </div>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{ 'shaded-row': process.processStepProcesses.indexOf(item) % 2 }">
              <td class="text-left">{{ item.processStepName }}</td>
              <td class="text-left">
                <span v-for="(op,idx) in item.owningPositions" :key="idx">{{op.position}}<br/></span>
              </td>
              <td class="text-left">{{ item.dateModified ? item.dateModified : item.dateCreated | formatDate('date') }}</td>
              <td class="text-center">
                <input type="checkbox" v-model="item.initialStep"
                       disabled readonly>
              </td>
              <td class="text-left">{{ item.processStepStatusType }}</td>
              <td>
                <div style="display: flex; float: right;">
                  <v-btn text @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index, getActiveAssignedToProcessStep(item)]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                    <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                    <v-icon v-else>expand_more</v-icon>
                  </v-btn>
                  <confirm-delete-dialog :label="`this process step from the ${process.processName} process`" :item-to-delete="item.processStepName" @confirm-delete="[item.archived = true, deleteStepFromProcess(item.id)]"></confirm-delete-dialog>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import orderBy from 'lodash.orderby'
import cloneDeep from 'lodash.clonedeep'

import {getActiveAssignedToProcessStep} from '@/services/processStepStatusTypeService'
import { handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";

export default {
  name: 'Process',
  components: {ConfirmDeleteDialog},
  mixins: [Vue2Filters.mixin],

  data () {
    return {
      snackbar: {},
      addNew: false,
      search: '',
      editName: false,
      newProcessStep: {},
      availableProcessSteps: [],
      processStepStatusTypes: [],
      owningPositions: [],
      processId: this.$route.params.id,
      companyId: this.$store.state.user.details.companyId,
      changesMade: false,
      statusesLoading: false,
      process: {
        processStepProcesses: []
      },
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
        { text: 'Owning Positions', value: 'positionName', sortable: false},
        { text: 'Last Modified', value: 'dateModified'},
        { text: 'Initial', value: 'initialStep'},
        { text: 'Status Type', value: 'processStepStatusType'},
        { text: null, value: null},
      ],
      footerProps: {
        'items-per-page-text': 'Rows per page:',
        'items-per-page-options': [25, 50, 100, 1000]
      },
      expanded: [],
      selectedIndex: null
    }
  },
  created () {
    this.getPositions()
    this.getProcessDetails()
  },
  computed: {
  },
  methods: {
    filterProcesses () {
      return this.process.processStepProcesses.filter(psp => { return !psp.archived})
      // return orderBy(this.process.processStepProcesses.filter(psp => { return !psp.archived}), psp => psp.displayOrder)
    },
    async getProcessDetails () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/processes/${this.processId}`)
        this.process = cloneDeep(data)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveRowChanges (rows) {
      if(rows?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/processes/${this.processId}/processStepProcesses`, rows)
          // this.$set(this.process, 'processStepProcesses', data.processStepProcesses)
          this.snackbar = getSnackbar('SUCCESS', 'Order Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Order Changes')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async saveProcessStepProcess (item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        item.companyProcessStepStatusTypeId = item.initialStep ? item.companyProcessStepStatusTypeId : null
        const {data, status} = await putRequest(`/processes/${this.processId}/processStepProcess`, item)
        item.initialStep = data.initialStep
        item.companyProcessStepStatusTypeId = data.companyProcessStepStatusTypeId
        item.processStepStatusType = data.processStepStatusType
        this.expanded = []
        this.snackbar = getSnackbar('SUCCESS', 'Process Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Process')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveProcess () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.editName = false
        const {status} = await putRequest(`/processes`, this.process)
        this.snackbar = getSnackbar('SUCCESS', 'Process Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Process')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteStepFromProcess (id) {
      //reset the addNew field in case they delete one while it is open
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNew = false
        const {status} = await deleteRequest(`/processes/processStepProcess/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Step Deleted from Process')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Step From Process')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getPositions() {
      try {
        const {data, status} = await getRequest(`/position/withParent`)
        this.owningPositions = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableProcessSteps () {
      try {
        //reset field in case they hit cancel
        this.newProcessStep = {}
        this.addNew = !this.addNew
        if(this.addNew) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await getRequest(`/processes/${this.processId}/availableProcessSteps`)
          this.availableProcessSteps = data
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignProcessStep () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await postRequest(`/processes/${this.processId}/processStep`, this.newProcessStep)
        this.process.processStepProcesses.push(data)
        this.process.processStepProcesses = orderBy(this.process.processStepProcesses, 'processStepName')

        this.addNew = false
        this.newProcessStep = {}
        this.snackbar = getSnackbar('SUCCESS', 'Process Step Assigned')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Assigning Process Step')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getActiveAssignedToProcessStep (item) {
      if(item.initialStep) {
        this.processStepStatusTypes = []
        this.statusesLoading = true
        try {
          const {data} = await getActiveAssignedToProcessStep(item.processStepId)
          this.processStepStatusTypes = data
          this.statusesLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.statusesLoading = false
        }
      }
    },
  },
}
</script>

<style scoped lang="scss">
.handle {
  cursor: move !important;
}

.v-data-table ::v-deep .v-data-table__wrapper {
  max-height: calc(100vh - 350px);
}

</style>

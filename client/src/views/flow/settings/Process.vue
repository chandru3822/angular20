<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" flat>
          <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
          <v-spacer></v-spacer>
          <div v-if="changesMade">
            <v-btn class="mr-2" :to="{ path: `/settings/processes`}">cancel</v-btn>
            <v-btn color="primary white--text" @click="saveProcess" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">Save Changes</v-btn>
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
          <v-select v-model="newProcessStep.processStepId"
                    :items="availableProcessSteps"
                    no-data-text="No Steps Available"
                    label="Select a Process Step"
                    item-text="processStepName"
                    item-value="id"
          ></v-select>
          <v-select v-model="newProcessStep.owningPositions"
                    :items="owningPositions"
                    no-data-text="No Positions Available"
                    label="Select Owning Positions"
                    item-text="position"
                    item-value="positionId"
                    multiple
                    return-object
          ></v-select>
<!--          <v-btn :disabled="!newProcessStep.processStepId || !newProcessStep.orgId" @click="assignProcessStep">Save</v-btn>-->
          <!--  per scott: temporarily removing requirement for orgId        -->
          <v-btn :disabled="!newProcessStep.processStepId || !newProcessStep.owningPositions || newProcessStep.owningPositions.length === 0" @click="assignProcessStep">Save</v-btn>
        </v-container>
        <v-data-table
            :headers="headers"
            :items="filterProcesses()"
            :items-per-page="-1"
            :sort-by="['displayOrder']"
            :sort-desc="[false]"
            hide-default-footer
            single-expand
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
            <td :colspan="headers.length" class="pb-4" :class="{'shaded-row': selectedIndex % 2}">
              <v-card flat color="transparent" class="text-left pt-4">
                <label>Initial Step:</label>
                <input type="checkbox" class="ml-2" v-model="item.initialStep">
                <v-select v-model="item.companyProcessStepStatusTypeId"
                          v-if="item.initialStep"
                          :items="processStepStatusTypes"
                          label="Initial Process Step Status Type"
                          item-text="processStepStatusType"
                          item-value="id"
                          class="mt-4"
                ></v-select>
                <v-select v-model="item.owningPositions"
                          :items="owningPositions"
                          no-data-text="No Positions Available"
                          label="Select Owning Positions"
                          item-text="position"
                          item-value="positionId"
                          multiple
                          return-object
                ></v-select>
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
            <tr :class="{ 'shaded-row': index % 2 }">
              <td style="width: 50px">
                <v-btn text icon small class="handle">
                  <v-icon>drag_handle</v-icon>
                </v-btn>
              </td>
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
                  <v-btn text @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                    <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                    <v-icon v-else>expand_more</v-icon>
                  </v-btn>
                  <v-dialog
                      v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
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
                            @click="[item.archived = true, deleteStepFromProcess(item.id)]">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import orderBy from 'lodash.orderby'
import cloneDeep from 'lodash.clonedeep'
import Sortable from 'sortablejs'
import Snackbar from '@/components/Snackbar.vue'
import {getStatusTypes} from '@/services/processStepStatusTypeService'
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
      processStepStatusTypes: [],
      owningPositions: [],
      processId: this.$route.params.id,
      companyId: this.$store.state.user.details.companyId,
      changesMade: false,
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
        { text: null, value: 'draggable', width: '50px', show: true, sortable: false },
        { text: 'Name', value: 'processStepName', sortable: false},
        { text: 'Owning Positions', value: 'positionName', sortable: false},
        { text: 'Last Modified', value: 'dateModified', sortable: false},
        { text: 'Initial', value: 'initial', sortable: false},
        { text: 'Status Type', value: 'statusType', sortable: false},
        { text: null, value: null},
      ],
      expanded: [],
      selectedIndex: null
    }
  },
  mounted() {
    let table = document.querySelector('tbody')
    const _self = this
    Sortable.create(table, {
      handle: '.handle',
      onEnd({ newIndex, oldIndex }) {
        const rowSelected = _self.process.processStepProcesses.splice(oldIndex, 1)[0]
        _self.process.processStepProcesses.splice(newIndex, 0, rowSelected)
        let rowsClone = cloneDeep(_self.process.processStepProcesses)
        rowsClone.forEach((r, idx) => {
          r.displayOrder = idx
        })
        _self.saveRowChanges(rowsClone)
      }
    })
  },
  created () {
    this.getPositions()
    this.getProcessDetails()
    this.getStatusTypes()
  },
  computed: {
  },
  methods: {
    filterProcesses () {
      return this.process.processStepProcesses.filter(psp => { return !psp.archived})
    },
    async getProcessDetails () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/processes/${this.processId}`)
        this.process = cloneDeep(data)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveRowChanges (rows) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/processes/${this.processId}/processStepProcesses`, rows)
        this.snackbar = getSnackbar('SUCCESS', 'Order Updated')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Order Changes')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveProcessStepProcess (item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        item.companyProcessStepStatusTypeId = item.initialStep ? item.companyProcessStepStatusTypeId : null
        const {data} = await putRequest(`/processes/${this.processId}/processStepProcess`, item)
        item.initialStep = data.initialStep
        item.companyProcessStepStatusTypeId = data.companyProcessStepStatusTypeId
        item.processStepStatusType = data.processStepStatusType
        this.expanded = []
        this.snackbar = getSnackbar('SUCCESS', 'Process Saved')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Process')
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
    async getPositions() {
      try {
        const {data} = await getRequest(`/position/withParent`)
        this.owningPositions = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
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
          const {data} = await getRequest(`/processes/${this.processId}/availableProcessSteps`)
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
    },
    async getStatusTypes () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getStatusTypes()
        this.processStepStatusTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  },
}
</script>

<style scoped lang="scss">
.handle {
  cursor: move !important;
}

</style>

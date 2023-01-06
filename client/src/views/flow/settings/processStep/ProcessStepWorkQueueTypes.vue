<template>
  <v-row>
    <v-col cols="12" class="pt-0 px-0">
      <!--            work queue types -->
      <v-toolbar flat class="wqt-header-bar">
        <v-toolbar-title class="app-title">Work Queue Types</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text color="primary"
                 @click="[newWorkQueueType = { projectStatuses: [], processStepStatuses: [], eventStatuses: [] }, getWorkQueueTypesForItem(), prepTempStatuses(newWorkQueueType, false), prepTempProcessStepStatuses(newWorkQueueType, false), prepTempEventStatuses(newWorkQueueType, false)]"
                 v-if="userCanAdd">
            <v-icon v-if="!addNewWorkQueueType">add</v-icon>
            {{ addNewWorkQueueType ? 'Cancel' : 'Add Work Queue Type' }}
          </v-btn>
          <v-btn text @click="expandWqt = !expandWqt">
            <v-icon v-if="!expandWqt">mdi-chevron-down</v-icon>
            <v-icon v-else>mdi-chevron-up</v-icon>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <div>
        <v-card flat class="square-card mb-3 pa-3" color="primary lighten-9" v-if="addNewWorkQueueType">
          <v-autocomplete v-model="newWorkQueueType.workQueueTypeId"
                          :items="workQueueTypes"
                          label="Select Work Queue Type"
                          item-value="id"
                          item-text="workQueueType"
                          attach
          >
            <template slot="item" slot-scope="data">
              <!-- HTML that describes how select should render items when the select is open -->
              {{ data.item.workQueueCategory }} - {{ data.item.workQueueType }}
            </template>
          </v-autocomplete>
          <v-autocomplete
            v-model="newWorkQueueType.projectStatuses"
            :items="newWorkQueueType.tempStatuses"
            multiple
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            label="Project Status Types"
            item-text="uniqueText"
            return-object>
            <template #selection="{ item, index }">
                    <span :class="{'bold': item.isRoot}">
                      <span v-if="index !== 0" class="">
                        ,
                      </span>
                      <span class="">
                        {{ item.projectStatusType }}
                      </span>
                    </span>
            </template>
            <template #item="data">
              <template v-if="data.item.header !== null">
                <v-list-item-content v-text="data.item.header"></v-list-item-content>
              </template>
              <template v-else>
                <v-list-item dense class="combined-statuses">
                  <v-list-item-action>
                    <input type="checkbox" :disabled="data.item.disabled" v-model="data.item.selected"
                           @change="addValueToNew(data.item)">
                  </v-list-item-action>
                  <v-list-item-title>
                    {{ data.item.projectStatusType }}
                    {{ !data.item.isRoot ? `(${data.item.rootProjectStatusType})` : '' }}
                  </v-list-item-title>
                </v-list-item>
              </template>
            </template>
          </v-autocomplete>
          <v-autocomplete
            v-model="newWorkQueueType.processStepStatuses"
            :items="newWorkQueueType.tempProcessStepStatuses"
            multiple
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            label="Process Step Status Types"
            item-text="uniqueText"
            return-object>
            <template #selection="{ item, index }">
                    <span :class="{'bold': item.isRoot}">
                      <span v-if="index !== 0" class="">
                        ,
                      </span>
                      <span class="">
                        {{ item.processStepStatusType }}
                      </span>
                    </span>
            </template>
            <template #item="data">
              <template v-if="data.item.header !== null">
                <v-list-item-content v-text="data.item"></v-list-item-content>
              </template>
              <template v-else>
                <v-list-item dense class="combined-statuses">
                  <v-list-item-action>
                    <input type="checkbox" :disabled="data.item.disabled" v-model="data.item.selected"
                           @change="addProcessStepValueToNew(data.item)">
                  </v-list-item-action>
                  <v-list-item-title>
                    {{ data.item.processStepStatusType }}
                    {{ data.item.isRoot ? `(${data.item.rootProcessStepStatusType})` : '' }}
                  </v-list-item-title>
                </v-list-item>
              </template>
            </template>
          </v-autocomplete>
          <v-autocomplete
            v-if="showEventFields"
            v-model="newWorkQueueType.eventStatuses"
            :items="newWorkQueueType.tempEventStatuses"
            multiple
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            label="Event Status Types"
            item-text="uniqueText"
            return-object>
            <template #selection="{ item, index }">
                    <span :class="{'bold': item.isRoot}">
                      <span v-if="index !== 0" class="">
                        ,
                      </span>
                      <span class="">
                        {{ item.eventStatusType }}
                      </span>
                    </span>
            </template>
            <template #item="data">
              <template v-if="data.item.header !== null">
                <v-list-item-content v-text="data.item"></v-list-item-content>
              </template>
              <template v-else>
                <v-list-item dense class="combined-statuses">
                  <v-list-item-action>
                    <input type="checkbox" :disabled="data.item.disabled" v-model="data.item.selected"
                           @change="addEventValueToNew(data.item)">
                  </v-list-item-action>
                  <v-list-item-title>
                    {{ data.item.eventStatusType }}
                    {{ data.item.isRoot ? `(${data.item.rootEventStatusType})` : '' }}
                  </v-list-item-title>
                </v-list-item>
              </template>
            </template>
          </v-autocomplete>
          <v-btn color="primary"
            :disabled="!newWorkQueueType.workQueueTypeId || (!newWorkQueueType.projectStatuses || newWorkQueueType.projectStatuses.length === 0)
          || (!newWorkQueueType.processStepStatuses || newWorkQueueType.processStepStatuses.length === 0)
           || (showEventFields && (!newWorkQueueType.eventStatuses || newWorkQueueType.eventStatuses.length === 0))"
            @click="assignNewWorkQueueType">
            Save
          </v-btn>
        </v-card>
        <v-card flat v-if="((processStep && processStep.workQueueTypes && processStep.workQueueTypes.length > 0)
                          || event && event.workQueueTypes && event.workQueueTypes.length > 0) && expandWqt">
          <v-data-table
            :headers="displayedHeaders"
            :items="filterWorkQueueTypes()"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            :items-per-page="-1"
            disable-sort
            class="elevation-1 square-card"
          >
            <template #no-data>
              <span class="default-text-color">No available work queue types</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available work queue types</span>
            </template>

            <template #expanded-item="{ headers, item }">
              <td :colspan="headers.length" class="pa-4"
                  :class="{'shaded-row': (processStep && processStep.workQueueTypes.indexOf(item) % 2) || (event && event.workQueueTypes.indexOf(item) % 2)}">

                <v-autocomplete
                  v-model="item.projectStatuses"
                  :items="item.tempStatuses"
                  multiple
                  menu-props="auto"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Project Status Types"
                  item-text="uniqueText"
                  return-object>
                  <template #selection="{ item: status, index }" v-if="showShit">
                          <span :class="{'bold': status.isRoot}">
                            <span class="" v-if="!status.archived">{{ status.projectStatusType }}</span>
                            <span v-if="!status.archived && index !== item.projectStatuses.length - 1"
                                  class=" mr-1">,</span>
                          </span>
                  </template>
                  <template #item="data" v-if="showShit">
                    <template v-if="data.item.header !== null">
                      <v-list-item-content v-text="data.item"></v-list-item-content>
                    </template>
                    <template v-else>
                      <v-list-item dense class="combined-statuses">
                        <v-list-item-action>
                          <v-checkbox :disabled="data.item.disabled"
                                      :input-value="getExistingValue(item.projectStatuses, data.item)"
                                      @change="[data.item.selected = !data.item.selected, addValueToExisting($event, item, data.item)]"/>
                        </v-list-item-action>
                        <v-list-item-title>
                          {{ data.item.projectStatusType }}
                          {{ !data.item.isRoot ? `(${data.item.rootProjectStatusType})` : '' }}
                        </v-list-item-title>
                      </v-list-item>
                    </template>
                  </template>
                </v-autocomplete>

                <v-autocomplete
                  v-model="item.processStepStatuses"
                  :items="item.tempProcessStepStatuses"
                  multiple
                  menu-props="auto"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Process Step Status Types"
                  item-text="uniqueText"
                  return-object>
                  <template #selection="{ item: status, index }" v-if="showPsShit">
                          <span :class="{'bold': status.isRoot}">
                            <span class="" v-if="!status.archived">{{ status.processStepStatusType }}</span>
                            <span v-if="!status.archived && index !== item.processStepStatuses.length - 1"
                                  class="mr-1">,</span>
                          </span>
                  </template>
                  <template #item="data" v-if="showPsShit">
                    <template v-if="data.item.header !== null">
                      <v-list-item-content v-text="data.item"></v-list-item-content>
                    </template>
                    <template v-else>
                      <v-list-item dense class="combined-statuses">
                        <v-list-item-action>
                          <v-checkbox :disabled="data.item.disabled"
                                      :input-value="getProcessStepExistingValue(item.processStepStatuses, data.item)"
                                      @change="[data.item.selected = !data.item.selected, addProcessStepValueToExisting($event, item, data.item)]"/>
                        </v-list-item-action>
                        <v-list-item-title>
                          {{ data.item.processStepStatusType }}
                          {{ !data.item.isRoot ? `(${data.item.rootProcessStepStatusType})` : '' }}
                        </v-list-item-title>
                      </v-list-item>
                    </template>
                  </template>
                </v-autocomplete>

                <v-autocomplete
                  v-if="showEventFields"
                  v-model="item.eventStatuses"
                  :items="item.tempEventStatuses"
                  multiple
                  menu-props="auto"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Event Status Types"
                  item-text="uniqueText"
                  return-object>
                  <template #selection="{ item: status, index }" v-if="showEventShit">
                          <span :class="{'bold': status.isRoot}">
                            <span class="" v-if="!status.archived">{{ status.eventStatusType }}</span>
                            <span v-if="!status.archived && index !== item.eventStatuses.length - 1"
                                  class=" mr-1">,</span>
                          </span>
                  </template>
                  <template #item="data" v-if="showEventShit">
                    <template v-if="data.item.header !== null">
                      <v-list-item-content v-text="data.item"></v-list-item-content>
                    </template>
                    <template v-else>
                      <v-list-item dense class="combined-statuses">
                        <v-list-item-action>
                          <v-checkbox :disabled="data.item.disabled"
                                      :input-value="getEventExistingValue(item.eventStatuses, data.item)"
                                      @change="[data.item.selected = !data.item.selected, addEventValueToExisting($event, item, data.item)]"/>
                        </v-list-item-action>
                        <v-list-item-title>
                          {{ data.item.eventStatusType }}
                          {{ !data.item.isRoot ? `(${data.item.rootEventStatusType})` : '' }}
                        </v-list-item-title>
                      </v-list-item>
                    </template>
                  </template>
                </v-autocomplete>

                <v-btn class="mt-3" v-if="userCanEdit" color="primary"
                       :disabled="(!item.projectStatuses || item.projectStatuses.filter(ps => !ps.archived).length === 0)
                                    || (!item.processStepStatuses || item.processStepStatuses.filter(ps => !ps.archived).length === 0)
                                    || (showEventFields && (!item.eventStatuses || item.eventStatuses.filter(ps => !ps.archived).length === 0))"
                       @click="saveStatusesToWorkQueueType(item)">
                  Save
                </v-btn>
              </td>
            </template>

            <template #item="{ item, index }">
              <tr class="clickable" :class="{'shaded-row': index % 2}">
                <td class="text-left">{{ item.workQueueCategory }}</td>
                <td class="text-left">
                  <a :href="`/settings/workQueue/type/${item.workQueueTypeId}`">{{ item.workQueueType }}</a>
                </td>
                <td class="text-left">
                        <span v-for="(ps, idx) in filterBy(item.projectStatuses, false, 'archived')">
                          <span v-if="idx !== 0">, </span>
                          <span :class="{'bold': ps.isRoot}">{{ ps.projectStatusType }}</span>
                        </span>
                </td>
                <td class="text-left">
                        <span v-for="(pss, idx) in filterBy(item.processStepStatuses, false, 'archived')">
                          <span v-if="idx !== 0">, </span>
                          <span :class="{'bold': pss.isRoot}">{{ pss.processStepStatusType }}</span>
                        </span>
                </td>
                <td class="text-left" v-if="showEventFields">
                        <span v-for="(pss, idx) in filterBy(item.eventStatuses, false, 'archived')">
                          <span v-if="idx !== 0">, </span>
                          <span :class="{'bold': pss.isRoot}">{{ pss.eventStatusType }}</span>
                        </span>
                </td>
                <td class="text-right">
                  <div class="flex-display">
                    <v-btn text color="primary"
                           @click="[expanded = [item], prepTempStatuses(item, true), prepTempProcessStepStatuses(item, true), prepTempEventStatuses(item, true)]"
                           v-if="!expanded.includes(item)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn text color="primary" @click="expanded = []" v-else>cancel
                    </v-btn>
                    <v-btn v-if="userCanEdit" text color="primary" @click="workQueueTypeToDelete=item"><v-icon>delete</v-icon></v-btn>
                  </div>
                </td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </div>
    </v-col>
    <ConfirmationDialog :open-dialog="!!workQueueTypeToDelete" @confirm="deleteWorkQueueTypeFromStep" @close-dialog="workQueueTypeToDelete=null">
      Are you sure you want to delete <strong>{{workQueueTypeToDeleteName}}</strong>?

    </ConfirmationDialog>
  </v-row>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import cloneDeep from 'lodash.clonedeep'

import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar,
  getRequestWithParams
} from '@/helpers/helpers'
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'ProcessStepWorkQueueTypes',
  mixins: [Vue2Filters.mixin],
  components: {ConfirmationDialog},
  props: {
    processStep: Object,
    event: Object
  },
  data() {
    return {
      snackbar: {},
      expandWqt: true,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      companyProjectStatusTypes: [],
      expanded: [],
      projectStatusTypes: [],
      combinedStatuses: [],
      companyProcessStepStatusTypes: [],
      processStepStatusTypes: [],
      combinedProcessStepStatuses: [],
      companyEventStatusTypes: [],
      eventStatusTypes: [],
      combinedEventStatuses: [],
      headers: [
        {text: 'Category', value: 'workQueueCategory', show: true},
        {text: 'Type', value: 'workQueueType', show: true},
        {text: 'Project Status', value: 'projectStatus', show: true},
        {text: 'Process Step Status', value: 'processStepStatus', show: true},
        {text: 'Event Status', value: 'eventStatus', show: this.event?.id},
        {text: '', value: 'icons', show: true, width: '100px'},
      ],
      addNewType: false,
      newType: {},
      processStepId: this.$route.params.id,
      companyId: this.$store.state.user.details.companyId,
      companyStatusesLoading: false,
      workQueueTypes: [],
      newWorkQueueType: {
        processStepStatuses: [],
        projectStatuses: [],
        eventStatuses: [],
      },
      addNewWorkQueueType: false,
      showShit: true,
      showPsShit: true,
      showEventShit: true, //dom key crap
      showEventFields: false,
      workQueueTypeToDelete: null
    }
  },
  computed: {
    displayedHeaders () {
      return this.headers.filter(h => h.show)
    },
    workQueueTypeToDeleteName(){
      return this.workQueueTypeToDelete ? this.workQueueTypeToDelete.workQueueType : ''
    }
  },
  async created() {
    if (this.event?.id) {
      this.showEventFields = true
      this.getEventStatusTypesForWorkQueue()
    }
    this.getProjectStatusTypesForWorkQueue()
    this.getProcessStepStatusTypesForWorkQueue()
  },
  methods: {
    addValueToNew(selectedItem) {
      if (selectedItem.selected) {
        if (selectedItem.isRoot) {
          //if it is a root item, then remove any company level ones that were already selected that share the root status
          this.newWorkQueueType.projectStatuses = this.newWorkQueueType.projectStatuses.filter(ps => {
            return ps.companyProjectStatusTypeId === null || (ps.projectStatusTypeId !== selectedItem.projectStatusTypeId)
          })
          //disable any of the options in the dropdown that share the same root
          this.newWorkQueueType.tempStatuses = this.newWorkQueueType.tempStatuses.map(ps => ({
            ...ps,
            disabled: ps.companyProjectStatusTypeId !== null && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? true : ps.disabled,
            selected: ps.companyProjectStatusTypeId !== null && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? false : ps.selected
          }))
        }
        this.newWorkQueueType.projectStatuses.push(selectedItem)
      } else {
        //remove it if it has already been added
        this.newWorkQueueType.projectStatuses = this.newWorkQueueType.projectStatuses.filter(ps => {
          if (selectedItem.companyProjectStatusTypeId === null) {
            return ps.projectStatusTypeId !== selectedItem.projectStatusTypeId
          } else {
            return ps.companyProjectStatusTypeId !== selectedItem.companyProjectStatusTypeId
          }
        })
        //if the item is de-selected and isRoot then enable the child options again
        if (selectedItem.isRoot) {
          this.newWorkQueueType.tempStatuses.forEach(ps => {
            if (ps.companyProjectStatusTypeId !== null && ps.projectStatusTypeId === selectedItem.projectStatusTypeId) {
              ps.disabled = false
            }
          })
        }
      }
    },
    addValueToExisting(e, wqtItem, selectedItem) {
      //check if already in existing - if it is, set archived as needed
      //note: the selectedItem.selected value hasn't changed yet, but "e" should be the accurate event value
      let match = selectedItem.isRoot
        ? wqtItem.projectStatuses?.find(ps => ps.isRoot && ps.projectStatusTypeId === selectedItem.projectStatusTypeId)
        : wqtItem.projectStatuses?.find(ps => !ps.isRoot && ps.companyProjectStatusTypeId === selectedItem.companyProjectStatusTypeId)

      if (match !== undefined) {
        match.archived = !e
        selectedItem.archived = !e

        //if the selectedItem isRoot then enable/disable the child options as required
        if (selectedItem.isRoot) {
          this.handleTogglingParentStatus(e, wqtItem, selectedItem)
        }
      } else if (selectedItem.selected) {
        //if not already exists then if selected - add to existingProjectStatuses
        //then filter/disable as needed
        selectedItem.archived = false //this un-does some crap we do elsewhere
        wqtItem.projectStatuses.push(selectedItem)
        if (selectedItem.isRoot) {
          this.handleTogglingParentStatus(e, wqtItem, selectedItem)
        }
      }

    },
    handleTogglingParentStatus(e, wqtItem, selectedItem) {
      this.showShit = false

      wqtItem.tempStatuses = wqtItem.tempStatuses.map(ts => ({
        ...ts,
        selected: !ts.isRoot && ts.projectStatusTypeId === selectedItem.projectStatusTypeId && !e ? false : ts.selected,
        disabled: !ts.isRoot && ts.projectStatusTypeId === selectedItem.projectStatusTypeId ? e : ts.disabled,
        archived: !ts.isRoot && ts.projectStatusTypeId === selectedItem.projectStatusTypeId ? true : ts.archived
      }))

      wqtItem.projectStatuses = wqtItem.projectStatuses.map(ps => ({
        ...ps,
        archived: !ps.isRoot && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? true : ps.archived,
        selected: !ps.isRoot && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? false : ps.archived
      }))
      this.showShit = true
    },
    handleTogglingParentProcessStepStatus(e, wqtItem, selectedItem) {
      this.showPsShit = false

      wqtItem.tempProcessStepStatuses = wqtItem.tempProcessStepStatuses.map(ts => ({
        ...ts,
        selected: !ts.isRoot && ts.processStepStatusTypeId === selectedItem.processStepStatusTypeId && !e ? false : ts.selected,
        disabled: !ts.isRoot && ts.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? e : ts.disabled,
        archived: !ts.isRoot && ts.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? true : ts.archived
      }))

      wqtItem.processStepStatuses = wqtItem.processStepStatuses.map(ps => ({
        ...ps,
        archived: !ps.isRoot && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? true : ps.archived,
        selected: !ps.isRoot && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? false : ps.archived
      }))
      this.showPsShit = true
    },
    getExistingValue(existingProjectStatuses, item) {
      //if ps contains item then return true
      if (item.isRoot) {
        let match = existingProjectStatuses?.find(ps => ps.projectStatusTypeId === item.projectStatusTypeId && ps.isRoot && !ps.archived)
        return match !== undefined
      } else {
        //company status
        let match = existingProjectStatuses?.find(ps => ps.companyProjectStatusTypeId === item.companyProjectStatusTypeId && !ps.isRoot && !ps.archived)
        return match !== undefined
      }
    },
    prepTempStatuses(item, existingItem) {
      //this is required so that selections made on one wqt are not auto-selected in other wqt's
      item.tempStatuses = cloneDeep(this.combinedStatuses)

      if (existingItem) {
        //if an existing item, then get a list of all the used root statuses and disable the ui as needed
        let rootStatusesIdsUsed = []
        item.projectStatuses.forEach(ps => {
          if (ps.isRoot) {
            rootStatusesIdsUsed.push(ps.projectStatusTypeId)
          }
        })
        //if there are root statuses being used then handle that shit
        if (rootStatusesIdsUsed.length > 0) {
          item.tempStatuses = item.tempStatuses.map(ts => ({
            ...ts,
            disabled: !ts.isRoot && rootStatusesIdsUsed.includes(ts.projectStatusTypeId)
          }))
        }
      }
    },
    async getProjectStatusTypesForWorkQueue() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/project/statusesForWqt`)
        this.combinedStatuses = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Project Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    // process step status repeat of all the project status stuff
    addProcessStepValueToNew(selectedItem) {
      if (selectedItem.selected) {
        if (selectedItem.isRoot) {
          //if it is a root item, then remove any company level ones that were already selected that share the root status
          this.newWorkQueueType.processStepStatuses = this.newWorkQueueType.processStepStatuses.filter(ps => {
            return ps.companyProcessStepStatusTypeId === null || (ps.processStepStatusTypeId !== selectedItem.processStepStatusTypeId)
          })
          //disable any of the options in the dropdown that share the same root
          this.newWorkQueueType.tempProcessStepStatuses = this.newWorkQueueType.tempProcessStepStatuses.map(ps => ({
            ...ps,
            disabled: ps.companyProcessStepStatusTypeId !== null && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? true : ps.disabled,
            selected: ps.companyProcessStepStatusTypeId !== null && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? false : ps.selected
          }))
        }

        this.newWorkQueueType.processStepStatuses.push(selectedItem)
      } else {
        //remove it if it has already been added
        this.newWorkQueueType.processStepStatuses = this.newWorkQueueType.processStepStatuses.filter(ps => {
          if (selectedItem.companyProcessStepStatusTypeId === null) {
            return ps.processStepStatusTypeId !== selectedItem.processStepStatusTypeId
          } else {
            return ps.companyProcessStepStatusTypeId !== selectedItem.companyProcessStepStatusTypeId
          }
        })
        //if the item is de-selected and isRoot then enable the child options again
        if (selectedItem.isRoot) {
          this.newWorkQueueType.tempProcessStepStatuses.forEach(ps => {
            if (ps.companyProcessStepStatusTypeId !== null && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId) {
              ps.disabled = false
            }
          })
        }
      }
    },
    addProcessStepValueToExisting(e, wqtItem, selectedItem) {
      //check if already in existing - if it is, set archived as needed
      //note: the selectedItem.selected value hasn't changed yet, but "e" should be the accurate event value
      let match = selectedItem.isRoot
        ? wqtItem.processStepStatuses?.find(ps => ps.isRoot && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId)
        : wqtItem.processStepStatuses?.find(ps => !ps.isRoot && ps.companyProcessStepStatusTypeId === selectedItem.companyProcessStepStatusTypeId)

      if (match !== undefined) {
        match.archived = !e
        selectedItem.archived = !e

        //if the selectedItem isRoot then enable/disable the child options as required
        if (selectedItem.isRoot) {
          this.handleTogglingParentProcessStepStatus(e, wqtItem, selectedItem)
        }
      } else if (selectedItem.selected) {
        //if not already exists then if selected - add to existingProjectStatuses
        //then filter/disable as needed
        selectedItem.archived = false //this un-does some crap we do elsewhere
        wqtItem.processStepStatuses.push(selectedItem)
        if (selectedItem.isRoot) {
          this.handleTogglingParentProcessStepStatus(e, wqtItem, selectedItem)
        }
      }
    },
    getProcessStepExistingValue(existingProcessStepStatuses, item) {
      //if ps contains item then return true
      if (item.isRoot) {
        let match = existingProcessStepStatuses?.find(ps => ps.processStepStatusTypeId === item.processStepStatusTypeId && ps.isRoot && !ps.archived)
        return match !== undefined
      } else {
        //company status
        let match = existingProcessStepStatuses?.find(ps => ps.companyProcessStepStatusTypeId === item.companyProcessStepStatusTypeId && !ps.isRoot && !ps.archived)
        return match !== undefined
      }
    },
    prepTempProcessStepStatuses(item, existingItem) {
      //this is required so that selections made on one wqt are not auto-selected in other wqt's
      item.tempProcessStepStatuses = cloneDeep(this.combinedProcessStepStatuses)

      if (existingItem) {
        //if an existing item, then get a list of all the used root statuses and disable the ui as needed
        let rootStatusesIdsUsed = []
        item.processStepStatuses.forEach(ps => {
          if (ps.isRoot) {
            rootStatusesIdsUsed.push(ps.processStepStatusTypeId)
          }
        })
        //if there are root statuses being used then handle that shit
        if (rootStatusesIdsUsed.length > 0) {
          item.tempProcessStepStatuses = item.tempProcessStepStatuses.map(ts => ({
            ...ts,
            disabled: !ts.isRoot && rootStatusesIdsUsed.includes(ts.processStepStatusTypeId)
          }))
        }
      }
    },
    async getProcessStepStatusTypesForWorkQueue() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await getRequestWithParams(`/processStep/status/forWqt`, {
          params: {processStepId: this.processStepId}
        })
        this.combinedProcessStepStatuses = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Process Step Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    // event status repeat of all the project status stuff
    addEventValueToNew(selectedItem) {
      if (selectedItem.selected) {
        if (selectedItem.isRoot) {
          //if it is a root item, then remove any company level ones that were already selected that share the root status
          this.newWorkQueueType.eventStatuses = this.newWorkQueueType.eventStatuses.filter(ps => {
            return ps.companyEventStatusTypeId === null || (ps.eventStatusTypeId !== selectedItem.eventStatusTypeId)
          })
          //disable any of the options in the dropdown that share the same root
          this.newWorkQueueType.tempEventStatuses = this.newWorkQueueType.tempEventStatuses.map(ps => ({
            ...ps,
            disabled: ps.companyEventStatusTypeId !== null && ps.eventStatusTypeId === selectedItem.eventStatusTypeId ? true : ps.disabled,
            selected: ps.companyEventStatusTypeId !== null && ps.eventStatusTypeId === selectedItem.eventStatusTypeId ? false : ps.selected
          }))
        }

        this.newWorkQueueType.eventStatuses.push(selectedItem)
      } else {
        //remove it if it has already been added
        this.newWorkQueueType.eventStatuses = this.newWorkQueueType.eventStatuses.filter(ps => {
          if (selectedItem.companyEventStatusTypeId === null) {
            return ps.eventStatusTypeId !== selectedItem.eventStatusTypeId
          } else {
            return ps.companyEventStatusTypeId !== selectedItem.companyEventStatusTypeId
          }
        })
        //if the item is de-selected and isRoot then enable the child options again
        if (selectedItem.isRoot) {
          this.newWorkQueueType.tempEventStatuses.forEach(ps => {
            if (ps.companyEventStatusTypeId !== null && ps.eventStatusTypeId === selectedItem.eventStatusTypeId) {
              ps.disabled = false
            }
          })
        }
      }
    },
    addEventValueToExisting(e, wqtItem, selectedItem) {
      //check if already in existing - if it is, set archived as needed
      //note: the selectedItem.selected value hasn't changed yet, but "e" should be the accurate event value
      let match = selectedItem.isRoot
        ? wqtItem.eventStatuses?.find(ps => ps.isRoot && ps.eventStatusTypeId === selectedItem.eventStatusTypeId)
        : wqtItem.eventStatuses?.find(ps => !ps.isRoot && ps.companyEventStatusTypeId === selectedItem.companyEventStatusTypeId)

      if (match !== undefined) {
        match.archived = !e
        selectedItem.archived = !e

        //if the selectedItem isRoot then enable/disable the child options as required
        if (selectedItem.isRoot) {
          this.handleTogglingParentEventStatus(e, wqtItem, selectedItem)
        }
      } else if (selectedItem.selected) {
        //if not already exists then if selected - add to existingProjectStatuses
        //then filter/disable as needed
        selectedItem.archived = false //this un-does some crap we do elsewhere
        wqtItem.eventStatuses.push(selectedItem)
        if (selectedItem.isRoot) {
          this.handleTogglingParentEventStatus(e, wqtItem, selectedItem)
        }
      }
    },
    handleTogglingParentEventStatus(e, wqtItem, selectedItem) {
      this.showEventShit = false

      wqtItem.tempEventStatuses = wqtItem.tempEventStatuses.map(ts => ({
        ...ts,
        selected: !ts.isRoot && ts.eventStatusTypeId === selectedItem.eventStatusTypeId && !e ? false : ts.selected,
        disabled: !ts.isRoot && ts.eventStatusTypeId === selectedItem.eventStatusTypeId ? e : ts.disabled,
        archived: !ts.isRoot && ts.eventStatusTypeId === selectedItem.eventStatusTypeId ? true : ts.archived
      }))

      wqtItem.eventStatuses = wqtItem.eventStatuses.map(ps => ({
        ...ps,
        archived: !ps.isRoot && ps.eventStatusTypeId === selectedItem.eventStatusTypeId ? true : ps.archived,
        selected: !ps.isRoot && ps.eventStatusTypeId === selectedItem.eventStatusTypeId ? false : ps.archived
      }))
      this.showEventShit = true
    },
    getEventExistingValue(existingEventStatuses, item) {
      //if ps contains item then return true
      if (item.isRoot) {
        let match = existingEventStatuses?.find(ps => ps.eventStatusTypeId === item.eventStatusTypeId && ps.isRoot && !ps.archived)
        return match !== undefined
      } else {
        //company status
        let match = existingEventStatuses?.find(ps => ps.companyEventStatusTypeId === item.companyEventStatusTypeId && !ps.isRoot && !ps.archived)
        return match !== undefined
      }
    },
    prepTempEventStatuses(item, existingItem) {
      if(this.showEventFields) {
        //this is required so that selections made on one wqt are not auto-selected in other wqt's
        item.tempEventStatuses = cloneDeep(this.combinedEventStatuses)

        if (existingItem) {
          //if an existing item, then get a list of all the used root statuses and disable the ui as needed
          let rootStatusesIdsUsed = []
          item.eventStatuses.forEach(ps => {
            if (ps.isRoot) {
              rootStatusesIdsUsed.push(ps.eventStatusTypeId)
            }
          })
          //if there are root statuses being used then handle that shit
          if (rootStatusesIdsUsed.length > 0) {
            item.tempEventStatuses = item.tempEventStatuses.map(ts => ({
              ...ts,
              disabled: !ts.isRoot && rootStatusesIdsUsed.includes(ts.eventStatusTypeId)
            }))
          }
        }
      }
    },
    async getEventStatusTypesForWorkQueue() {
      if(this.showEventFields) {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await getRequestWithParams(`/event/statusesForWqt`, {
            params: {processStepId: this.processStepId, eventId: this.event.eventId}
          })
          this.combinedEventStatuses = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Status Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    //end event stuff
    async getWorkQueueTypesForItem() {
      try {
        this.addNewWorkQueueType = !this.addNewWorkQueueType
        if (this.addNewWorkQueueType) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          let url = this.showEventFields ? `/workQueueType/event/${this.$route.params.eventId}` :  `/workQueueType/processStep/${this.$route.params.id}`
          const {data, status} = await getRequest(url, null, [])
          this.workQueueTypes = data
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignNewWorkQueueType() {
      //todo make this work for both proj and process step types
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newWorkQueueType.processStepId = this.$route.params.id
        this.newWorkQueueType.processStepEventId = this.$route.params.eventId
        let url = this.showEventFields ? `/workQueueType/event` : `/workQueueType/processStep`
        const {data, status} = await postRequest(url, this.newWorkQueueType)
        if(this.showEventFields) {
          this.event?.workQueueTypes.push(data)
        } else {
          this.processStep?.workQueueTypes.push(data)
        }
        // reset fields
        this.addNewWorkQueueType = false
        this.newWorkQueueType = {projectStatuses: [], processStepStatuses: [], eventStatuses: []}
        this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Work Queue Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveStatusesToWorkQueueType(item) {
      //todo: fix this to save both things
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let url = this.showEventFields ? `/workQueueType/saveStatusTypesToProcessStepEventWorkQueueType` : `/workQueueType/saveStatusTypesToProcessStepWorkQueueType`
        const {data, status} = await putRequest(url, item)
        item.projectStatuses = data.projectStatuses
        item.processStepStatuses = data.processStepStatuses
        item.eventStatuses = data.eventStatuses || []
        this.expanded = []
        this.snackbar = getSnackbar('SUCCESS', 'Status Types Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteWorkQueueTypeFromStep() {
      const item = this.workQueueTypeToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewWorkQueueType = false
        let url = this.showEventFields ? `/workQueueType/event/${item.id}` : `/workQueueType/processStep/${item.id}`
        const {status} = await deleteRequest(url)
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Link')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterWorkQueueTypes() {
      if(this.showEventFields) {
        return this.event?.workQueueTypes.filter(u => {
          return !u.archived
        })
      } else {
        return this.processStep?.workQueueTypes.filter(u => {
          return !u.archived
        })
      }
    },
  }

}
</script>

<style scoped lang="scss">
.combined-statuses > div.v-list-item__action {
  min-width: 10px !important;
  width: 10px;
  margin-left: 15px;
  margin-right: 20px !important;
}

.wqt-header-bar {
  border-bottom: 1px solid #E6E6E6;
  border-top: 1px solid #E6E6E6;
}

</style>

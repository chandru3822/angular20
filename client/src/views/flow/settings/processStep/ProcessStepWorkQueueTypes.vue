<template>
  <v-row>
    <v-col cols="12" class="pt-0 px-0">
      <!--            work queue types -->
      <v-toolbar flat class="wqt-header-bar">
        <v-toolbar-title class="title-large">Work Queue Types</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text color="primary"
                 @click="[newWorkQueueType = { projectStatuses: [], processStepStatuses: [], eventStatuses: [] }, getWorkQueueTypesForItem(), prepTempStatuses(newWorkQueueType, false), prepTempProcessStepStatuses(newWorkQueueType, false), prepTempEventStatuses(newWorkQueueType, false)]"
                 v-if="userCanAdd">
            <v-icon v-if="!addNewWorkQueueType">add</v-icon>
            <v-icon v-else-if="$vuetify.breakpoint.smAndDown">close</v-icon>
            <span v-if="!$vuetify.breakpoint.smAndDown">{{ addNewWorkQueueType ? 'Cancel' : 'Add Work Queue Type' }}</span>
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
            :items="filteredWorkQueueTypes"
            single-expand
            :expanded.sync="expanded"
            hide-default-footer
            :items-per-page="-1"
            disable-sort
            class="elevation-1 square-card table-striped"
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


                <template #item.workQueueCategory="{item}" class="clickable text-left">{{ item.workQueueCategory }}</template>
                <template #item.workQueueType="{item}" class="clickable text-left">
                  <a :href="`/settings/workQueue/type/${item.workQueueTypeId}`">{{ item.workQueueType }}</a>
                </template>
                <template #item.projectStatus="{item}" class="clickable text-left">
                        <span v-for="(ps, idx) in item.projectStatuses.filter(p => !p.archived)">
                          <span v-if="idx !== 0">, </span>
                          <span :class="{'bold': ps.isRoot}">{{ ps.projectStatusType }}</span>
                        </span>
                </template>
                <template #item.processStepStatus="{item}" class="clickable text-left">
                        <span v-for="(pss, idx) in item.processStepStatuses.filter(p => !p.archived)">
                          <span v-if="idx !== 0">, </span>
                          <span :class="{'bold': pss.isRoot}">{{ pss.processStepStatusType }}</span>
                        </span>
                </template>
                <template #item.eventStatus="{item}" class="clickable text-left" v-if="showEventFields">
                        <span v-for="(pss, idx) in item.eventStatuses.filter(p => !p.archived)">
                          <span v-if="idx !== 0">, </span>
                          <span :class="{'bold': pss.isRoot}">{{ pss.eventStatusType }}</span>
                        </span>
                </template>
                <template #item.icons="{item}" class="clickable text-right">
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

<script setup>
import {AppMutations} from '@/stores/AppStore'
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
import ConfirmationDialog from "@/components/ConfirmationDialog";
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables";
const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

import {defineProps} from 'vue'
const props = defineProps({
  processStep: Object,
  event: Object
})
const {processStep, event} = props;

      const expandWqt = ref(true)
      const companyProjectStatusTypes = ref([])
      const expanded = ref([])
      const projectStatusTypes = ref([])
      const combinedStatuses = ref([])
      const companyProcessStepStatusTypes = ref([])
      const processStepStatusTypes = ref([])
      const combinedProcessStepStatuses = ref([])
      const companyEventStatusTypes = ref([])
      const eventStatusTypes = ref([])
      const combinedEventStatuses = ref([])
      const addNewType = ref(false)
      const newType = ref({})
      const companyStatusesLoading = ref(false)
      const workQueueTypes = ref([])
      const addNewWorkQueueType = ref(false)
      const showShit = ref(true)
      const showPsShit = ref(true)
      const showEventShit = ref(true)
      const showEventFields = ref(false)
      const workQueueTypeToDelete = ref(null)
      const headers = ref([
  {text: 'Category', value: 'workQueueCategory', show: true},
  {text: 'Type', value: 'workQueueType', show: true},
  {text: 'Project Status', value: 'projectStatus', show: true},
  {text: 'Process Step Status', value: 'processStepStatus', show: true},
  {text: 'Event Status', value: 'eventStatus', show: event?.id},
  {text: '', value: 'icons', show: true, width: '100px'},
])
   const newWorkQueueType = ref({
  processStepStatuses: [],
      projectStatuses: [],
      eventStatuses: [],
})

const eventId = computed(() => {
  return route.params.eventId
})
const processStepId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const userId = computed(() => {
  return userStore.details.id
})
const displayedHeaders = computed(() => {
  return headers.value?.filter(h => h.show)
})
const workQueueTypeToDeleteName = computed(() => {
  return workQueueTypeToDelete.workQueueType?.value || ''
})
const filteredWorkQueueTypes = computed(() => {
  if(showEventFields.value) {
    return event?.workQueueTypes?.filter(u => {
      return !u.archived
    })
  } else {
    return processStep?.workQueueTypes?.filter(u => {
      return !u.archived
    })
  }
})

onMounted(() => {
  if (event?.id) {
    showEventFields.value = true
    getEventStatusTypesForWorkQueue()
  }
  getProjectStatusTypesForWorkQueue()
  getProcessStepStatusTypesForWorkQueue()
})

    const addValueToNew = (selectedItem) => {
      if (selectedItem.selected) {
        if (selectedItem.isRoot) {
          //if it is a root item, then remove any company level ones that were already selected that share the root status
          newWorkQueueType.value.projectStatuses = newWorkQueueType.value.projectStatuses.filter(ps => {
            return ps.companyProjectStatusTypeId === null || (ps.projectStatusTypeId !== selectedItem.projectStatusTypeId)
          })
          //disable any of the options in the dropdown that share the same root
          newWorkQueueType.value.tempStatuses = newWorkQueueType.value.tempStatuses.map(ps => ({
            ...ps,
            disabled: ps.companyProjectStatusTypeId !== null && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? true : ps.disabled,
            selected: ps.companyProjectStatusTypeId !== null && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? false : ps.selected
          }))
        }
        newWorkQueueType.value.projectStatuses.push(selectedItem)
      } else {
        //remove it if it has already been added
        newWorkQueueType.value.projectStatuses = newWorkQueueType.value.projectStatuses.filter(ps => {
          if (selectedItem.companyProjectStatusTypeId === null) {
            return ps.projectStatusTypeId !== selectedItem.projectStatusTypeId
          } else {
            return ps.companyProjectStatusTypeId !== selectedItem.companyProjectStatusTypeId
          }
        })
        //if the item is de-selected and isRoot then enable the child options again
        if (selectedItem.isRoot) {
          newWorkQueueType.value.tempStatuses.forEach(ps => {
            if (ps.companyProjectStatusTypeId !== null && ps.projectStatusTypeId === selectedItem.projectStatusTypeId) {
              ps.disabled = false
            }
          })
        }
      }
    }
    const addValueToExisting = (e, wqtItem, selectedItem) =>{
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
          handleTogglingParentStatus(e, wqtItem, selectedItem)
        }
      } else if (selectedItem.selected) {
        //if not already exists then if selected - add to existingProjectStatuses
        //then filter/disable as needed
        selectedItem.archived = false //this un-does some crap we do elsewhere
        wqtItem.projectStatuses.push(selectedItem)
        if (selectedItem.isRoot) {
          handleTogglingParentStatus(e, wqtItem, selectedItem)
        }
      }

    }
    const handleTogglingParentStatus = (e, wqtItem, selectedItem) => {
      showShit.value = false

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
      showShit.value = true
    }
    const handleTogglingParentProcessStepStatus = (e, wqtItem, selectedItem) => {
      showPsShit.value = false

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
      showPsShit.value = true
    }
    const getExistingValue = (existingProjectStatuses, item) => {
      //if ps contains item then return true
      if (item.isRoot) {
        let match = existingProjectStatuses?.find(ps => ps.projectStatusTypeId === item.projectStatusTypeId && ps.isRoot && !ps.archived)
        return match !== undefined
      } else {
        //company status
        let match = existingProjectStatuses?.find(ps => ps.companyProjectStatusTypeId === item.companyProjectStatusTypeId && !ps.isRoot && !ps.archived)
        return match !== undefined
      }
    }
    const prepTempStatuses = (item, existingItem) => {
      //this is required so that selections made on one wqt are not auto-selected in other wqt's
      item.tempStatuses = cloneDeep(combinedStatuses.value)

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
    }
    const getProjectStatusTypesForWorkQueue = async() => {
      store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/projectStatus/wqt`)
        combinedStatuses.value = data
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        getSnackbar('ERROR', 'Error Retrieving Project Status Types')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    // process step status repeat of all the project status stuff
    const addProcessStepValueToNew = (selectedItem) => {
      if (selectedItem.selected) {
        if (selectedItem.isRoot) {
          //if it is a root item, then remove any company level ones that were already selected that share the root status
          newWorkQueueType.value.processStepStatuses = newWorkQueueType.value.processStepStatuses.filter(ps => {
            return ps.companyProcessStepStatusTypeId === null || (ps.processStepStatusTypeId !== selectedItem.processStepStatusTypeId)
          })
          //disable any of the options in the dropdown that share the same root
          newWorkQueueType.value.tempProcessStepStatuses = newWorkQueueType.value.tempProcessStepStatuses.map(ps => ({
            ...ps,
            disabled: ps.companyProcessStepStatusTypeId !== null && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? true : ps.disabled,
            selected: ps.companyProcessStepStatusTypeId !== null && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? false : ps.selected
          }))
        }

        newWorkQueueType.value.processStepStatuses.push(selectedItem)
      } else {
        //remove it if it has already been added
        newWorkQueueType.value.processStepStatuses = newWorkQueueType.value.processStepStatuses.filter(ps => {
          if (selectedItem.companyProcessStepStatusTypeId === null) {
            return ps.processStepStatusTypeId !== selectedItem.processStepStatusTypeId
          } else {
            return ps.companyProcessStepStatusTypeId !== selectedItem.companyProcessStepStatusTypeId
          }
        })
        //if the item is de-selected and isRoot then enable the child options again
        if (selectedItem.isRoot) {
          newWorkQueueType.value.tempProcessStepStatuses.forEach(ps => {
            if (ps.companyProcessStepStatusTypeId !== null && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId) {
              ps.disabled = false
            }
          })
        }
      }
    }
    const addProcessStepValueToExisting = (e, wqtItem, selectedItem) => {
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
          handleTogglingParentProcessStepStatus(e, wqtItem, selectedItem)
        }
      } else if (selectedItem.selected) {
        //if not already exists then if selected - add to existingProjectStatuses
        //then filter/disable as needed
        selectedItem.archived = false //this un-does some crap we do elsewhere
        wqtItem.processStepStatuses.push(selectedItem)
        if (selectedItem.isRoot) {
          handleTogglingParentProcessStepStatus(e, wqtItem, selectedItem)
        }
      }
    }
    const getProcessStepExistingValue = (existingProcessStepStatuses, item) => {
      //if ps contains item then return true
      if (item.isRoot) {
        let match = existingProcessStepStatuses?.find(ps => ps.processStepStatusTypeId === item.processStepStatusTypeId && ps.isRoot && !ps.archived)
        return match !== undefined
      } else {
        //company status
        let match = existingProcessStepStatuses?.find(ps => ps.companyProcessStepStatusTypeId === item.companyProcessStepStatusTypeId && !ps.isRoot && !ps.archived)
        return match !== undefined
      }
    }
    const prepTempProcessStepStatuses = (item, existingItem) => {
      //this is required so that selections made on one wqt are not auto-selected in other wqt's
      item.tempProcessStepStatuses = cloneDeep(combinedProcessStepStatuses.value)

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
    }
    const getProcessStepStatusTypesForWorkQueue = async() => {
      try {
        store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await getRequestWithParams(`/processStep/status/forWqt`, {
          params: {processStepId: processStepId.value}
        })
        combinedProcessStepStatuses.value = data
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        getSnackbar('ERROR', 'Error Retrieving Process Step Status Types')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    // event status repeat of all the project status stuff
    const addEventValueToNew = (selectedItem) => {
      if (selectedItem.selected) {
        if (selectedItem.isRoot) {
          //if it is a root item, then remove any company level ones that were already selected that share the root status
          newWorkQueueType.value.eventStatuses = newWorkQueueType.value.eventStatuses.filter(ps => {
            return ps.companyEventStatusTypeId === null || (ps.eventStatusTypeId !== selectedItem.eventStatusTypeId)
          })
          //disable any of the options in the dropdown that share the same root
          newWorkQueueType.value.tempEventStatuses = newWorkQueueType.value.tempEventStatuses.map(ps => ({
            ...ps,
            disabled: ps.companyEventStatusTypeId !== null && ps.eventStatusTypeId === selectedItem.eventStatusTypeId ? true : ps.disabled,
            selected: ps.companyEventStatusTypeId !== null && ps.eventStatusTypeId === selectedItem.eventStatusTypeId ? false : ps.selected
          }))
        }

        newWorkQueueType.value.eventStatuses.push(selectedItem)
      } else {
        //remove it if it has already been added
        newWorkQueueType.value.eventStatuses = newWorkQueueType.value.eventStatuses.filter(ps => {
          if (selectedItem.companyEventStatusTypeId === null) {
            return ps.eventStatusTypeId !== selectedItem.eventStatusTypeId
          } else {
            return ps.companyEventStatusTypeId !== selectedItem.companyEventStatusTypeId
          }
        })
        //if the item is de-selected and isRoot then enable the child options again
        if (selectedItem.isRoot) {
          newWorkQueueType.value.tempEventStatuses.forEach(ps => {
            if (ps.companyEventStatusTypeId !== null && ps.eventStatusTypeId === selectedItem.eventStatusTypeId) {
              ps.disabled = false
            }
          })
        }
      }
    }
    const addEventValueToExisting = (e, wqtItem, selectedItem) => {
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
          handleTogglingParentEventStatus(e, wqtItem, selectedItem)
        }
      } else if (selectedItem.selected) {
        //if not already exists then if selected - add to existingProjectStatuses
        //then filter/disable as needed
        selectedItem.archived = false //this un-does some crap we do elsewhere
        wqtItem.eventStatuses.push(selectedItem)
        if (selectedItem.isRoot) {
          handleTogglingParentEventStatus(e, wqtItem, selectedItem)
        }
      }
    }
    const handleTogglingParentEventStatus = (e, wqtItem, selectedItem) => {
      showEventShit.value = false

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
      showEventShit.value = true
    }
    const getEventExistingValue = (existingEventStatuses, item) => {
      //if ps contains item then return true
      if (item.isRoot) {
        let match = existingEventStatuses?.find(ps => ps.eventStatusTypeId === item.eventStatusTypeId && ps.isRoot && !ps.archived)
        return match !== undefined
      } else {
        //company status
        let match = existingEventStatuses?.find(ps => ps.companyEventStatusTypeId === item.companyEventStatusTypeId && !ps.isRoot && !ps.archived)
        return match !== undefined
      }
    }
    const prepTempEventStatuses = (item, existingItem) => {
      if(showEventFields.value) {
        //this is required so that selections made on one wqt are not auto-selected in other wqt's
        item.tempEventStatuses = cloneDeep(combinedEventStatuses.value)

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
    }
    const getEventStatusTypesForWorkQueue = async() => {
      if(showEventFields.value) {
        try {
          store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await getRequestWithParams(`/event/statusesForWqt`, {
            params: {processStepId: processStepId.value, eventId: event.eventId}
          })
          combinedEventStatuses.value = data
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          getSnackbar('ERROR', 'Error Retrieving Event Status Types')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
    //end event stuff
    const getWorkQueueTypesForItem = async() => {
      try {
        addNewWorkQueueType.value = !addNewWorkQueueType.value
        if (addNewWorkQueueType.value) {
          store.commit(AppMutations.SET_LOADING, true)
          let url = showEventFields.value ? `/workQueueType/event/${eventId.value}` :  `/workQueueType/processStep/${processStepId.value}`
          const {data, status} = await getRequest(url, null, [])
          workQueueTypes.value = data
          handleHidingGlobalLoader(vueInstance, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    const assignNewWorkQueueType = async() => {
      //todo make this work for both proj and process step types
      store.commit(AppMutations.SET_LOADING, true)
      try {
        newWorkQueueType.value.processStepId = processStepId.value
        newWorkQueueType.value.processStepEventId = eventId.value
        let url = showEventFields.value ? `/workQueueType/event` : `/workQueueType/processStep`
        const {data, status} = await postRequest(url, newWorkQueueType.value)
        if(showEventFields.value) {
          event?.workQueueTypes.push(data)
        } else {
          processStep?.workQueueTypes.push(data)
        }
        // reset fields
        addNewWorkQueueType.value = false
        newWorkQueueType.value = {projectStatuses: [], processStepStatuses: [], eventStatuses: []}
        getSnackbar('SUCCESS', 'Work Queue Type Added')
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        getSnackbar('ERROR', 'Error Adding Work Queue Type')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    const saveStatusesToWorkQueueType = async(item) => {
      //todo: fix this to save both things
      store.commit(AppMutations.SET_LOADING, true)
      try {
        let url = showEventFields.value ? `/workQueueType/saveStatusTypesToProcessStepEventWorkQueueType` : `/workQueueType/saveStatusTypesToProcessStepWorkQueueType`
        const {data, status} = await putRequest(url, item)
        item.projectStatuses = data.projectStatuses
        item.processStepStatuses = data.processStepStatuses
        item.eventStatuses = data.eventStatuses || []
        expanded.value = []
        getSnackbar('SUCCESS', 'Status Types Saved')
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        getSnackbar('ERROR', 'Error Adding Status Types')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    const deleteWorkQueueTypeFromStep = async() => {
      const item = workQueueTypeToDelete.value
      store.commit(AppMutations.SET_LOADING, true)
      try {
        addNewWorkQueueType.value = false
        let url = showEventFields.value ? `/workQueueType/event/${item.id}` : `/workQueueType/processStep/${item.id}`
        const {status} = await deleteRequest(url)
        item.archived = true
        getSnackbar('SUCCESS', 'Work Queue Type Deleted')
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        getSnackbar('ERROR', 'Error Deleting Link')
        store.commit(AppMutations.SET_LOADING, false)
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

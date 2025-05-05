<template>
  <v-row>
    <v-col cols="12" class="pt-0 px-0">
      <!--            work queue types -->
      <v-toolbar flat class="wqt-header-bar">
        <v-toolbar-title class="title-large">Work Queue Types</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <a-btn
              variant="text"
              color="primary"
              @click="[newWorkQueueType = { projectStatuses: [], processStepStatuses: [], eventStatuses: [] }, getWorkQueueTypesForItem(), prepTempStatuses(newWorkQueueType, false), prepTempProcessStepStatuses(newWorkQueueType, false), prepTempEventStatuses(newWorkQueueType, false)]"
              v-if="userCanAdd"
              :prepend-icon="!addNewWorkQueueType ? 'add' : 'close'"
              :text="$vuetify.breakpoint.smAndDown ? '' : addNewWorkQueueType ? 'Cancel' : 'Add Work Queue Type' "
          ></a-btn>
          <a-btn
              variant="text"
              @click="expandWqt = !expandWqt"
              color="unset"
              :prepend-icon="!expandWqt ? 'mdi-chevron-down' : 'mdi-chevron-up'"
          ></a-btn>
        </v-toolbar-items>
      </v-toolbar>
      <div>
        <v-card flat class="square-card mb-3 pa-3" color="primary lighten-9" v-if="addNewWorkQueueType">
          <a-autocomplete v-model="newWorkQueueType.workQueueTypeId"
                          :items="workQueueTypes"
                          label="Select Work Queue Type"
                          item-value="id"
                          :item-title="item => `${item.workQueueCategory} - ${item.workQueueType}`"
                          attach
          >
          </a-autocomplete>
          <a-autocomplete
            v-model="newWorkQueueType.projectStatuses"
            :items="newWorkQueueType.tempStatuses"
            multiple
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            label="Project Status Types"
            item-title="uniqueText"
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
          </a-autocomplete>
          <a-autocomplete
            v-model="newWorkQueueType.processStepStatuses"
            :items="newWorkQueueType.tempProcessStepStatuses"
            multiple
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            label="Process Step Status Types"
            item-title="uniqueText"
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
          </a-autocomplete>
          <a-autocomplete
            v-if="showEventFields"
            v-model="newWorkQueueType.eventStatuses"
            :items="newWorkQueueType.tempEventStatuses"
            multiple
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            label="Event Status Types"
            item-title="uniqueText"
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
          </a-autocomplete>
          <a-btn
              color="primary"
              :disabled="!newWorkQueueType.workQueueTypeId || (!newWorkQueueType.projectStatuses || newWorkQueueType.projectStatuses.length === 0) || (!newWorkQueueType.processStepStatuses || newWorkQueueType.processStepStatuses.length === 0) || (showEventFields && (!newWorkQueueType.eventStatuses || newWorkQueueType.eventStatuses.length === 0))"
              @click="assignNewWorkQueueType"
              text="Save"
          ></a-btn>
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

                <a-autocomplete
                  v-model="item.projectStatuses"
                  :items="item.tempStatuses"
                  multiple
                  menu-props="auto"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Project Status Types"
                  item-title="uniqueText"
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
                </a-autocomplete>

                <a-autocomplete
                  v-model="item.processStepStatuses"
                  :items="item.tempProcessStepStatuses"
                  multiple
                  menu-props="auto"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Process Step Status Types"
                  item-title="uniqueText"
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
                </a-autocomplete>

                <template>
                  <v-row>
                    <v-col cols="3" class="field-container elevation-1">
                      <v-tabs v-model="tab" class="tabs">
                        <v-tab>Filters</v-tab>
                      </v-tabs>
                      <v-tabs-items v-model="tab" class="show-overflow">
                        <v-tab-item>
                          <!-- Add Filter dropdown - always visible -->
                          <v-autocomplete
                            v-model="selectedFilters"
                            :items="availableFilters"
                            @change="handleFilterChange"
                            hide-details
                            class="mx-4 mt-4 filter-text"
                            density="compact"
                            variant="outlined"
                            item-title="name"
                            item-value="id"
                            label="Add Filter"
                            return-object
                            :menu-props="{ closeOnContentClick: true }"
                            :search-input.sync="filterSearch"
                            :filter="customFilter"
                          >
                            <template v-slot:selection="{ item }">
                              <div class="text-left mt-2">
                                <v-btn
                                  v-if="selectedFilters && selectedFilters.name"
                                  class="ma-1"
                                  color="primary"
                                  variant="tonal"
                                  @click="toggleFilter"
                                  size="small"
                                  rounded
                                  style="text-transform: none;"
                                >
                                  {{ selectedFilters.name + (selectedFilters.processStepName ? ` - (${selectedFilters.processStepName})` : '') }}
                                  <v-icon end size="small" class="ml-1" @click.stop="toggleFilter">mdi-close</v-icon>
                                </v-btn>
                              </div>
                            </template>
                            <template v-slot:item="{ item }">
                              <v-list-item-title>
                                {{ item.name }}{{ item.processStepName ? ` - ${item.processStepName}` : '' }}
                              </v-list-item-title>
                            </template>
                          </v-autocomplete>

                          <!-- Operator selection - only visible after filter is selected -->
                          <template v-if="selectedFilters && selectedFilters.id && operators.length > 0">
                            <v-autocomplete
                              v-model="selectedFilters.operator"
                              :items="operators"
                              hide-details
                              class="mx-4 mt-4"
                              density="compact"
                              variant="outlined"
                              item-title="name"
                              item-value="id"
                              label="Select Operator"
                              @update:model-value="handleOperatorChange"
                              return-object
                            >
                              <template v-slot:selection="{ item }">
                                {{ item.name }}
                              </template>
                              <template v-slot:item="{ item }">
                                <v-list-item-title>
                                  {{ item.name }}
                                </v-list-item-title>
                              </template>
                            </v-autocomplete>

                            <!-- Value selection - only visible after operator is selected -->
                            <template v-if="selectedFilters.operator">
                              <v-autocomplete
                                v-model="selectedFilters.value"
                                :items="valueTypes"
                                hide-details
                                class="mx-4 mt-4"
                                density="compact"
                                variant="outlined"
                                item-title="name"
                                item-value="id"
                                label="Select Value"
                                return-object
                              >
                                <template v-slot:selection="{ item }">
                                  {{ item.name }}
                                </template>
                                <template v-slot:item="{ item }">
                                  <v-list-item-title>
                                    {{ item.name }}
                                  </v-list-item-title>
                                </template>
                              </v-autocomplete>
                            </template>
                          </template>
                        </v-tab-item>
                      </v-tabs-items>
                    </v-col>

                    <!-- Added column to display selected filter -->
                    <v-col cols="9" v-if="selectedFilters && selectedFilters.name">
                      <v-card flat class="mx-4">
                        <v-card-text class="pb-0 pt-2">
                          <div class="text-subtitle-2 mb-2">Selected Filters:</div>
                          <v-btn
                            class="mx-1 mb-0"
                            color="primary"
                            variant="tonal"
                            @click="toggleFilter"
                            size="small"
                            rounded
                            style="text-transform: none;"
                          >
                            {{ selectedFilters.name + (selectedFilters.processStepName ? ` - (${selectedFilters.processStepName})` : '')
                          + (selectedFilters.operator ? `, ${selectedFilters.operator.name}` : '')
                          + (selectedFilters.value ? `, ${selectedFilters.value.name}` : '') }}
                            <v-icon end size="small" class="ml-1" @click.stop="toggleFilter">mdi-close</v-icon>
                          </v-btn>
                        </v-card-text>
                      </v-card>
                    </v-col>

                    <!-- Added section to display saved filters from database -->
                    <v-col cols="9" v-if="item && savedFilters.length > 0">
                      <v-card flat class="mx-4">
                        <v-card-text>
                          <div class="text-subtitle-2 mb-2">Saved Filters:</div>
                          <div class="d-flex flex-column align-items-start">
                            <v-btn
                              v-for="(filter, index) in savedFilters"
                              :key="`filter-${filter.id}-${index}`"
                              class="mb-2 non-clickable-btn"
                              color="secondary"
                              variant="tonal"
                              style="text-transform: none; align-self: flex-start; color: black !important; pointer-events: none;"
                              size="small"
                              rounded
                              :disabled="filter.isDeleting"
                              type="button"
                            >
                              {{ getFilterDisplayText(filter) }}
                              <v-icon
                                end
                                size="small"
                                class="ml-1 clickable-icon"
                                @click.stop="deleteSavedFilter(filter, $event)"
                              >mdi-close</v-icon>
                            </v-btn>
                          </div>
                        </v-card-text>
                      </v-card>
                    </v-col>
                  </v-row>
                </template>

                <a-autocomplete
                  v-if="showEventFields"
                  v-model="item.eventStatuses"
                  :items="item.tempEventStatuses"
                  multiple
                  menu-props="auto"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Event Status Types"
                  item-title="uniqueText"
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
                </a-autocomplete>

                <a-btn
                    class="mt-3"
                    v-if="userCanEdit"
                    color="primary"
                    :disabled="(!item.projectStatuses || item.projectStatuses.filter(ps => !ps.archived).length === 0) || (!item.processStepStatuses || item.processStepStatuses.filter(ps => !ps.archived).length === 0) || (showEventFields && (!item.eventStatuses || item.eventStatuses.filter(ps => !ps.archived).length === 0))"
                    @click="saveStatusesToWorkQueueType(item)"
                > Save </a-btn>
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
            <template #item.filters="{item}" class="clickable text-left">
              <div>
                <span v-for="(filter, idx) in item.selectedFilters" :key="filter.id">
                  <span v-if="idx !== 0">, </span>
                  <span>{{ filter.name }}</span>
                </span>
                  <span v-if="item.filterCount > 0" class="filter-count ml-2">
                  {{ item.filterCount }}
                </span>
                  <span v-else-if="filterCountsLoaded && (!item.selectedFilters || item.selectedFilters.length === 0)" class="grey--text text--darken-2">
                  No filters
                </span>
                  <span v-else-if="!filterCountsLoaded" class="grey--text text--darken-2">
                  Loading...
                </span>
              </div>
            </template>
                <template #item.icons="{item}" class="clickable text-right">
                  <div class="flex-display">
                    <a-btn
                      variant="text"
                      color="primary"
                      @click="[expanded = [item], prepTempStatuses(item, true), prepTempProcessStepStatuses(item, true), prepTempEventStatuses(item, true), loadSavedFilters(item)]"
                      v-if="!expanded.includes(item)"
                      prepend-icon="edit"
                    ></a-btn>
                    <a-btn
                        variant="text"
                        color="primary"
                        @click="expanded = []"
                        v-else
                        text="Cancel"
                    ></a-btn>
                    <a-btn
                        v-if="userCanEdit"
                        variant="text"
                        color="primary"
                        @click="workQueueTypeToDelete=item"
                        prepend-icon="delete"
                    ></a-btn>
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
import { watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const filterSearch = ref('')
const tab = ref(null)
const availableFilters = ref([])
const operators = ref([])
const valueTypes = ref([])
const savedFilters = ref([])
const selectedFilters = ref([])
const filterCountsLoaded = ref(false);

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
  {text: 'Filters', value: 'filters', show: true},
  {text: 'Event Status', value: 'eventStatus', show: event?.id},
  {text: '', value: 'icons', show: true, width: '100px'},
])
   const newWorkQueueType = ref({
  processStepStatuses: [],
      projectStatuses: [],
      eventStatuses: [],
})

const getAvailableFilters = async (forceUpdate = false) => {
  if (availableFilters.value.length === 0 || forceUpdate) {
    try {
      appStore.loading = true
      const objectTypeId = 4
      const projectDetails = false

      const response = await getRequest(`/smartlist/fields?objectTypeIds=${objectTypeId}&projectDetails=${projectDetails}`)
      const {data, status} = response

      // Make sure data is an array before calling map
      if (Array.isArray(data)) {
        availableFilters.value = data.map(filter => ({
          id: filter.customFieldGroupAssignmentId,
          name: filter.name,
          processStepName: filter.processStepName,
          dataTypeId: filter.dataTypeId,
          objectTypeId: filter.objectTypeId,
          hasListValues: filter.hasListValues
        }))
      } else {
        console.error('Expected data to be an array but got:', typeof data, data)
        // Set to empty array if data is not an array
        availableFilters.value = []
      }

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error retrieving available filters')
      appStore.loading = false
    }
  }
}

const fetchOperators = async (dataTypeId) => {
  try {
    appStore.loading = true
    const { data } = await getRequest(`/operator/${dataTypeId}`)
    operators.value = data.map(op => ({
      id: op.id,
      name: op.operatorType,
      operatorType: op.operatorType
    }))
  } catch (e) {
    console.error('Error fetching operators:', e)
    appStore.showSnack('ERROR', 'Error fetching operators')
    operators.value = []
  } finally {
    appStore.loading = false
  }
}

const fetchValueTypes = async (dataTypeId) => {
  try {
    appStore.loading = true
    const { data } = await getRequest(`/dataType/getDataTypeRequirements/${dataTypeId}`)

    valueTypes.value = data.map(requirement => ({
      id: requirement.id,
      name: requirement.dataTypeValue,
      dataTypeId: requirement.dataTypeId,
      secondaryRequirement: requirement.secondaryRequirement
    }))

  } catch (e) {
    console.error('Error fetching value types:', e)
    appStore.showSnack('ERROR', 'Error fetching value types')
  } finally {
    appStore.loading = false
  }
}

const fetchSavedFilters = async (item) => {
  if (!item) return

  try {
    appStore.loading = true

    const { data, status } = await getRequestWithParams('/workQueueType/filters', {
      params: { workQueueTypeId: item.workQueueTypeId }
    })

    savedFilters.value = data || []
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('Error fetching saved filters:', e)
    appStore.loading = false
  }
}

const loadAllFilterCounts = async () => {
  filterCountsLoaded.value = false;

  const filteredWorkQueueTypes = showEventFields.value
    ? event?.workQueueTypes?.filter(u => !u.archived)
    : processStep?.workQueueTypes?.filter(u => !u.archived);

  if (!filteredWorkQueueTypes?.length) {
    filterCountsLoaded.value = true;
    return;
  }
  filteredWorkQueueTypes.forEach(wqt => {
    wqt.filterCount = 0;
  });

  for (const wqt of filteredWorkQueueTypes) {
    try {
      const { data, status } = await getRequestWithParams('/workQueueType/filters', {
        params: { workQueueTypeId: wqt.workQueueTypeId }
      });

      wqt.filterCount = data?.length || 0;
    } catch (error) {
      console.error(`Error fetching filters for ${wqt.workQueueType}:`, error);
    }
  }

  filterCountsLoaded.value = true;
}

const deleteSavedFilter = async (filter, event) => {
  if (event) {
    event.stopImmediatePropagation();
    event.preventDefault();
    event.stopPropagation();
  }

  const filterId = filter.id;
  filter.isDeleting = true;

  selectedFilters.value = [];
  operators.value = [];
  valueTypes.value = [];

  try {
    appStore.loading = true;
    await deleteRequest(`/workQueueType/filter/${filterId}`);

    savedFilters.value = savedFilters.value.filter(f => f.id !== filterId);

    await loadAllFilterCounts();

    appStore.showSnack('SUCCESS', 'Filter removed successfully');
  } catch (e) {
    console.error('Error removing filter:', e);
    appStore.showSnack('ERROR', 'Error removing filter');
    const filterToReset = savedFilters.value.find(f => f.id === filterId);
    if (filterToReset) filterToReset.isDeleting = false;
  } finally {
    appStore.loading = false;
  }
}

watch(selectedFilters, (newVal) => {
  if (newVal === null) {
    selectedFilters.value = []
  }
}, { deep: true })

const handleFilterChange = async (filter) => {
  if (filter) {
    selectedFilters.value = {
      id: filter.id,
      name: filter.name,
      processStepName: filter.processStepName,
      dataTypeId: filter.dataTypeId,
      operator: null,
      value: null
    }

    if (filter.dataTypeId) {
      await fetchOperators(filter.dataTypeId)
      await fetchValueTypes(filter.dataTypeId)
    }
  } else {
    selectedFilters.value = null
    operators.value = []
    valueTypes.value = []
  }
}

const handleOperatorChange = () => {
  if (selectedFilters.value) {
    selectedFilters.value.value = null
  }
}

const removeFilter = () => {
  selectedFilters.value = []
}

const loadSavedFilters = async (item) => {
  if (item && expanded.value.includes(item)) {
    try {
      selectedFilters.value = []

      await fetchSavedFilters(item)
      await getAvailableFilters()

      if (savedFilters.value && savedFilters.value.length > 0) {
        for (const filter of savedFilters.value) {
          if (filter.filterId) {
            const availableFilter = availableFilters.value.find(af => af.id === filter.filterId)
            if (availableFilter && availableFilter.dataTypeId) {
              filter.dataTypeId = availableFilter.dataTypeId

              await fetchOperators(availableFilter.dataTypeId)
              await fetchValueTypes(availableFilter.dataTypeId)
            } else {
              console.warn('No matching filter or dataTypeId for filterId:', filter.filterId)
            }
          }
        }
      }
    } catch (e) {
      console.error('Error in loadSavedFilters:', e)
    }
  }
}

const toggleFilter = () => {
  if (selectedFilters.value) {
    selectedFilters.value = []
    operators.value = []
    valueTypes.value = []
  }
}

const customFilter = (item, queryText) => {
  const searchText = queryText.toLowerCase()
  const name = item.name.toLowerCase()
  const processStepName = item.processStepName ? item.processStepName.toLowerCase() : ''

  return name.includes(searchText) ||
    processStepName.includes(searchText)
}

const getFilterDisplayText = (filter) => {
  const filterObj = availableFilters.value.find(f => f.id === filter.filterId)
  let filterName = filterObj ? filterObj.name : `Filter ${filter.filterId}`

  if (filterObj && filterObj.processStepName) {
    filterName += ` - (${filterObj.processStepName})`
  }

  let operatorName = filter.operatorName;
  if (!operatorName) {
    const operatorObj = operators.value.find(o => o.id === filter.operatorId)
    operatorName = operatorObj ? operatorObj.name : `Operator ${filter.operatorId}`
  }

  let valueName = filter.valueName;
  if (!valueName) {
    const valueObj = valueTypes.value.find(v => v.id === filter.valueId)
    valueName = valueObj ? valueObj.name : `Value ${filter.valueId}`
  }

  const result = `${filterName}, ${operatorName}, ${valueName}`;
  return result;
}

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
  appStore.loading = true;

  if (event?.id) {
    showEventFields.value = true;
  }

  const loadingPromises = [
    getProjectStatusTypesForWorkQueue(),
    getProcessStepStatusTypesForWorkQueue(),
    loadAllFilterCounts()
  ];

  if (showEventFields.value) {
    loadingPromises.push(getEventStatusTypesForWorkQueue());
  }

  Promise.all(loadingPromises)
    .then(() => {
      const uniqueDataTypeIds = [...new Set(availableFilters.value
        .filter(f => f.dataTypeId)
        .map(f => f.dataTypeId))];

      uniqueDataTypeIds.forEach(dataTypeId => {
        fetchOperators(dataTypeId);
        fetchValueTypes(dataTypeId);
      });
    })
    .catch(error => {
      console.error('Error loading initial data:', error);
      appStore.showSnack('ERROR', 'Error loading data');
    })
    .finally(() => {
      appStore.loading = false;
    });
});

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
      appStore.loading = true
      try {
        const {data, status} = await getRequest(`/projectStatus/wqt`)
        combinedStatuses.value = data
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Retrieving Project Status Types')
        appStore.loading = false
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
        appStore.loading = true
        const {data, status} = await getRequestWithParams(`/processStep/status/forWqt`, {
          params: {processStepId: processStepId.value}
        })
        combinedProcessStepStatuses.value = data
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Retrieving Process Step Status Types')
        appStore.loading = false
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
          appStore.loading = true
          const {data, status} = await getRequestWithParams(`/event/statusesForWqt`, {
            params: {processStepId: processStepId.value, eventId: event.eventId}
          })
          combinedEventStatuses.value = data
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.showSnack('ERROR', 'Error Retrieving Event Status Types')
          appStore.loading = false
        }
      }
    }
    //end event stuff
    const getWorkQueueTypesForItem = async() => {
      try {
        addNewWorkQueueType.value = !addNewWorkQueueType.value
        if (addNewWorkQueueType.value) {
          appStore.loading = true
          let url = showEventFields.value ? `/workQueueType/event/${eventId.value}` :  `/workQueueType/processStep/${processStepId.value}`
          const {data, status} = await getRequest(url, null, [])

          workQueueTypes.value = (data || [])
            .filter(wqt => wqt && typeof wqt === 'object')
            .map(wqt => ({
              id: wqt.id || null,
              workQueueCategory: wqt.workQueueCategory || '',
              workQueueType: wqt.workQueueType || '',
              workQueueTypeId: wqt.workQueueTypeId || null,
              selectedFilters: Array.isArray(wqt.selectedFilters) ? wqt.selectedFilters : [],
              projectStatuses: Array.isArray(wqt.projectStatuses) ? wqt.projectStatuses : [],
              processStepStatuses: Array.isArray(wqt.processStepStatuses) ? wqt.processStepStatuses : [],
              eventStatuses: Array.isArray(wqt.eventStatuses) ? wqt.eventStatuses : [],
              ...wqt
            }))

          handleHidingGlobalLoader(status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Retrieving Work Queue Types')
        appStore.loading = false
      }
    }
    const assignNewWorkQueueType = async() => {
      appStore.loading = true
      try {
        const requestPayload = {
          workQueueTypeId: Number(newWorkQueueType.value.workQueueTypeId),
          processStepId: Number(processStepId.value),
          projectStatuses: newWorkQueueType.value.projectStatuses
            .filter(status => status)
            .map(status => ({
              projectStatusTypeId: Number(status.projectStatusTypeId),
              companyProjectStatusTypeId: status.companyProjectStatusTypeId ?
                Number(status.companyProjectStatusTypeId) : null,
              isRoot: Boolean(status.isRoot),
              archived: false
            })),
          processStepStatuses: newWorkQueueType.value.processStepStatuses
            .filter(status => status)
            .map(status => ({
              processStepStatusTypeId: Number(status.processStepStatusTypeId),
              companyProcessStepStatusTypeId: status.companyProcessStepStatusTypeId ?
                Number(status.companyProcessStepStatusTypeId) : null,
              isRoot: Boolean(status.isRoot),
              archived: false
            }))
        }

        if (showEventFields.value) {
          requestPayload.processStepEventId = eventId.value ? Number(eventId.value) : null
          requestPayload.eventStatuses = newWorkQueueType.value.eventStatuses
            .filter(status => status)
            .map(status => ({
              eventStatusTypeId: Number(status.eventStatusTypeId),
              companyEventStatusTypeId: status.companyEventStatusTypeId ?
                Number(status.companyEventStatusTypeId) : null,
              isRoot: Boolean(status.isRoot),
              archived: false
            }))
        }

        if (selectedFilters.value?.id &&
          selectedFilters.value?.operator?.id &&
          selectedFilters.value?.value?.id) {
          requestPayload.selectedFilters = {
            filterId: Number(selectedFilters.value.id),
            operatorId: Number(selectedFilters.value.operator.id),
            valueId: Number(selectedFilters.value.value.id)
          }
        }

        let url = showEventFields.value ? `/workQueueType/event` : `/workQueueType/processStep`
        const {data, status} = await postRequest(url, requestPayload)

        if(showEventFields.value) {
          event?.workQueueTypes.push({
            ...data,
            selectedFilters: data.selectedFilters || null
          })
        } else {
          processStep?.workQueueTypes.push({
            ...data,
            selectedFilters: data.selectedFilters || null
          })
        }

        addNewWorkQueueType.value = false
        newWorkQueueType.value = {projectStatuses: [], processStepStatuses: [], eventStatuses: []}
        selectedFilters.value = []

        appStore.showSnack('SUCCESS', 'Work Queue Type Added')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Adding Work Queue Type')
        appStore.loading = false
      }
    }
    const saveStatusesToWorkQueueType = async(item) => {
      // Validate that a filter is selected
      if (!selectedFilters.value || !selectedFilters.value.id) {
        appStore.showSnack('ERROR', 'Please select a filter');
        return;
      }

      // Validate filter selection if a filter is partially filled out
      if (selectedFilters.value && selectedFilters.value.id) {
        if (!selectedFilters.value.operator) {
          appStore.showSnack('ERROR', 'Please select an operator for your filter');
          return;
        }

        if (!selectedFilters.value.value) {
          appStore.showSnack('ERROR', 'Please select a value for your filter');
          return;
        }
      }

      appStore.loading = true;
      try {
        item.selectedFilters = selectedFilters.value ? {
          id: selectedFilters.value.id,
          name: selectedFilters.value.name,
          processStepName: selectedFilters.value.processStepName,
          operator: selectedFilters.value.operator ? {
            id: selectedFilters.value.operator.id,
            name: selectedFilters.value.operator.name
          } : null,
          value: selectedFilters.value.value ? {
            id: selectedFilters.value.value.id,
            name: selectedFilters.value.value.name
          } : null
        } : null;

        let url = showEventFields.value
          ? `/workQueueType/saveStatusTypesToProcessStepEventWorkQueueType`
          : `/workQueueType/saveStatusTypesToProcessStepWorkQueueType`;

        const {data, status} = await putRequest(url, item);

        item.projectStatuses = data.projectStatuses;
        item.processStepStatuses = data.processStepStatuses;
        item.eventStatuses = data.eventStatuses || [];
        item.selectedFilters = data.selectedFilters || null;

        selectedFilters.value = [];
        operators.value = [];
        valueTypes.value = [];
        expanded.value = [];

        await loadAllFilterCounts();

        appStore.showSnack('SUCCESS', 'Filter saved successfully');
        handleHidingGlobalLoader(status);
      } catch (e) {
        console.error('*** ERROR SAVING FILTERS ***', e);
        console.error('Failed item data:', JSON.stringify(item, null, 2));
        appStore.showSnack('ERROR', 'Error saving filter');
        appStore.loading = false;
      }
    }
    const deleteWorkQueueTypeFromStep = async() => {
      const item = workQueueTypeToDelete.value
      appStore.loading = true
      try {
        addNewWorkQueueType.value = false
        let url = showEventFields.value ? `/workQueueType/event/${item.id}` : `/workQueueType/processStep/${item.id}`
        const {status} = await deleteRequest(url)
        item.archived = true

        await loadAllFilterCounts();

        appStore.showSnack('SUCCESS', 'Work Queue Type Deleted')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Deleting Link')
        appStore.loading = false
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

.filter-text {
  :deep(.v-field) {
    max-width: 500px !important;
    margin: 0 auto;

    .v-field__input {
      max-width: 500px !important;

      input {
        max-width: 460px !important;
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
      }
    }
  }
}

.filter-count {
  color: white;
  font-size: 0.85rem;
  font-weight: 500;
}

.field-container {
  width: 1250px;
  min-width: 1250px;
  max-width: 1250px;
  background-color: white;
  z-index: 0;
}

.tabs {
  border-bottom: solid 1px var(--v-grey-lighten2) !important;
}

.filter-count {
  color: black;
  font-size: 0.85rem;
  font-weight: 500;
}

.non-clickable-btn {
  cursor: default !important;
}

.clickable-icon {
  cursor: pointer !important;
  pointer-events: auto !important;
  position: relative;
  z-index: 1;
}

</style>

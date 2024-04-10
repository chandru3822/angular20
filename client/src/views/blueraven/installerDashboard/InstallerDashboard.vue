<template>
  <v-container class="app-container">
    <v-dialog v-model="showModal" max-width="1600">
      <ProductionStatsDrilldown
        :start-date="startDate"
        :end-date="endDate"
        :title="drilldownTitle"
        :drilldown-data="drilldownData"
        @prodStatsDrilldownDialogClosed="showModal = false"
      ></ProductionStatsDrilldown>
    </v-dialog>

    <!-- Non-Mobile code -->
    <template v-if="!constants.IS_MOBILE">
      <v-row>
        <v-col cols="12">
          <v-toolbar flat class="app-toolbar">
            <v-toolbar-title class="app-title">Installer Dashboard</v-toolbar-title>
          </v-toolbar>
          <v-divider class="mt-3"/>
          <v-row class="px-4">
            <v-col cols="3" md="2">
              <a-autocomplete v-model="selectedRegionalManagers"
                              :items="regionalManagers"
                              label="Regional Installation Manager"
                              multiple
                              clearable
                              return-object
                              item-title="fullName"
                              @change="getInstallationCrew()"
                              @click:clear="selectedInstallationCrews = []">
                <v-list-item
                  slot="prepend-item"
                  ripple
                  @click="toggleSelectAllManagers()"
                >
                  <v-list-item-action>
                    <v-icon>{{ iconManagers }}</v-icon>
                  </v-list-item-action>
                  <v-list-item-title>Select All</v-list-item-title>
                </v-list-item>
                <v-divider
                  slot="prepend-item"
                  class="mt-2"
                ></v-divider>
                <template
                  slot="selection"
                  slot-scope="{ item, index }"
                >
                <span v-if="index === 0" class="primary--text text-caption">
                  {{ selectedRegionalManagers.length }} selected
                </span>
                </template>
              </a-autocomplete>
            </v-col>
            <v-col cols="3" md="2">
              <a-autocomplete v-model="selectedInstallationCrews"
                              :items="installationCrew"
                              label="Installation Crews"
                              multiple
                              clearable
                              return-object
                              item-title="fullName">
                <template  v-slot:prepend-item>
                  <v-list-item
                    ripple
                    @click="toggleSelectAllCrews()"
                  >
                    <v-list-item-action>
                      <v-icon>{{ iconCrews }}</v-icon>
                    </v-list-item-action>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item>
                  <v-divider
                    class="mt-2"
                  ></v-divider>
                </template>
                <template  v-slot:selection="{item, index}">
                  <span v-if="index === 0" class="primary--text text-caption">
                    {{ selectedInstallationCrews.length }} selected
                  </span>
                </template>
              </a-autocomplete>
            </v-col>
            <v-col cols="3" md="2">
              <a-select attach custom-classes="date-range-dropdown  py-2"
                        v-model="selectedDateRange"
                        :items="dateRanges"
                        label="Date Range"
                        @change="setDateRange()"
                        hide-details
              ></a-select>
            </v-col>
            <v-col cols="3" md="2">
              <DatetimePickerInput :custom-class="'date-range-date'"  py-2
                                   v-model="startDate"
                                   :timezone="timezone"
                                   :maxDate="endDate"
                                   :type="'date'"
                                   label="Start Date"
                                   @input="setDateRangeCustom(false)"
                                   hide-details
                                   :hide-prepend-icon="true"
              ></DatetimePickerInput>
            </v-col>
            <v-col cols="3" md="2">
              <DatetimePickerInput :custom-class="'date-range-date'"  py-2
                                   v-model="endDate"
                                   :timezone="timezone"
                                   :minDate="startDate"
                                   :type="'date'"
                                   @input="setDateRangeCustom(false)"
                                   label="End Date"
                                   hide-details
                                   :hide-prepend-icon="true"
              ></DatetimePickerInput>
            </v-col>
            <v-col cols="3" md="2">
              <a-btn
                color="primary"
                :disabled="selectedInstallationCrews.length < 1"
                @click="getDashboardValues()"
                text="Go"
              ></a-btn>
            </v-col>
          </v-row>
          <v-row>
            <v-toolbar flat class="app-toolbar">
              <v-toolbar-title class="app-title">Production Stats</v-toolbar-title>
            </v-toolbar>
          </v-row>
          <v-row>
            <v-card tile v-for="stat in dashValues" class="ma-3 flex-display card-main"
                    width="200" height="100" >
              <div class="card-accent" :style="{'background-color': 'white'}"></div>
              <v-card-text class="pt-1 stats-tile" @click="drilldownTitle = stat.name; drilldownData= stat.drilldownData; showModal = true">
                <div class="text-left default-text-color">{{stat.name}}</div>
                <div class="card-count">{{stat.value}}</div>
              </v-card-text>
            </v-card>
          </v-row>
          <v-row>
            <v-toolbar flat class="app-toolbar">
              <v-toolbar-title class="app-title">WIP</v-toolbar-title>
            </v-toolbar>
          </v-row>
          <v-row>
            <v-card tile v-for="wq in workQueues" class="ma-3 flex-display card-main"
                    :class="{'clickable': wq.workQueueCount > 0}"
                    :key="wq.id"
                    width="200" height="100" >
              <div class="card-accent" :style="{'background-color': wq.color}"></div>
              <v-card-text class="pt-1">
                <router-link class="no-text-decoration card-link" target="_blank"
                             :to="{name: 'workQueueDrilldown', params: {id: wq.workQueueTypeId}, query: { smartlistId: wq.smartlistId, upId: 99999999, unassigned: selectedUserPosition.unassigned,
                                                                                                          installationCrewIds}}">
                  <div class="text-left default-text-color">{{wq.workQueueType}}</div>
                  <div class="card-count">{{wq.workQueueCount}}</div>
                </router-link>
              </v-card-text>
            </v-card>
          </v-row>
        </v-col>
      </v-row>
      <v-row>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Key Performance Metrics</v-toolbar-title>
        </v-toolbar>
        <v-col cols="3" md="2">
          <a-select attach custom-classes="date-range-dropdown py-2"
                    v-model="metricsSelectedDateRange"
                    :items="dateRanges"
                    label="Date Range"
                    @change="setMetricsDateRange()"
                    hide-details
          ></a-select>
        </v-col>
        <v-col cols="3" md="2">
          <DatetimePickerInput :custom-class="'date-range-date'"  py-2
                               v-model="metricsStartDate"
                               :timezone="timezone"
                               :maxDate="metricsEndDate"
                               :type="'date'"
                               @input="setDateRangeCustom(true)"
                               label="Start Date"
                               hide-details
                               :hide-prepend-icon="true"
          ></DatetimePickerInput>
        </v-col>
        <v-col cols="3" md="2">
          <DatetimePickerInput :custom-class="'date-range-date'"  py-2
                               v-model="metricsEndDate"
                               :timezone="timezone"
                               :minDate="metricsStartDate"
                               :type="'date'"
                               @input="setDateRangeCustom(true)"
                               label="End Date"
                               hide-details
                               :hide-prepend-icon="true"
          ></DatetimePickerInput>
        </v-col>
        <v-col cols="3" md="2">
          <a-btn
            color="primary"
            class="mr-2 mb-3"
            @click="getPerformanceMetrics"
            text="Go"
          ></a-btn>
        </v-col>
      </v-row>
    </template>

    <!-- Mobile code -->
    <template v-if="constants.IS_MOBILE">
      <v-row>
        <v-col cols="12">
          <v-toolbar flat class="app-toolbar">
            <v-toolbar-title class="app-title">Installer Dashboard</v-toolbar-title>
          </v-toolbar>
          <v-divider class="mt-3"/>
          <v-row class="px-4">
            <v-row>
              <v-col cols="5" md="2">
                <a-autocomplete v-model="selectedRegionalManagers" class="zzzz"
                                :items="regionalManagers"
                                label="Regional Installation Manager"
                                multiple
                                clearable
                                return-object
                                item-title="fullName"
                                @change="getInstallationCrew()"
                                @click:clear="selectedInstallationCrews = []">
                  <v-list-item
                    slot="prepend-item"
                    ripple
                    @click="toggleSelectAllManagers()"
                  >
                    <v-list-item-action>
                      <v-icon>{{ iconManagers }}</v-icon>
                    </v-list-item-action>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item>
                  <v-divider
                    slot="prepend-item"
                    class="mt-2"
                  ></v-divider>
                  <template
                    slot="selection"
                    slot-scope="{ item, index }"
                  >
                  <span v-if="index === 0" class="primary--text text-caption">
                    {{ selectedRegionalManagers.length }} selected
                  </span>
                  </template>
                </a-autocomplete>
              </v-col>
              <v-col cols="5" md="2">
                <a-autocomplete v-model="selectedInstallationCrews"
                                :items="installationCrew"
                                label="Installation Crews"
                                multiple
                                clearable
                                return-object
                                item-title="fullName">
                  <template  v-slot:prepend-item>
                    <v-list-item
                      ripple
                      @click="toggleSelectAllCrews()"
                    >
                      <v-list-item-action>
                        <v-icon>{{ iconCrews }}</v-icon>
                      </v-list-item-action>
                      <v-list-item-title>Select All</v-list-item-title>
                    </v-list-item>
                    <v-divider
                      class="mt-2"
                    ></v-divider>
                  </template>
                  <template
                    slot="selection"
                    slot-scope="{ item, index }"
                  >
                  <span v-if="index === 0" class="primary--text text-caption">
                    {{ selectedInstallationCrews.length }} selected
                  </span>
                  </template>
                </a-autocomplete>
              </v-col>
            </v-row>

            <v-row>
              <v-col cols="5" md="2">
                <a-select attach custom-classes="date-range-dropdown py-2"
                          v-model="selectedDateRange"
                          :items="dateRanges"
                          label="Date Range"
                          @change="setDateRange()"
                          hide-details
                ></a-select>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="5" md="2">
                <DatetimePickerInput :custom-class="'date-range-date'"  py-2
                                     v-model="startDate"
                                     :timezone="timezone"
                                     :maxDate="endDate"
                                     :type="'date'"
                                     label="Start Date"
                                     @input="setDateRangeCustom(false)"
                                     hide-details
                                     :hide-prepend-icon="true"
                ></DatetimePickerInput>
              </v-col>
              <v-col cols="5" md="2">
                <DatetimePickerInput :custom-class="'date-range-date'"  py-2
                                     v-model="endDate"
                                     :timezone="timezone"
                                     :minDate="startDate"
                                     :type="'date'"
                                     @input="setDateRangeCustom(false)"
                                     label="End Date"
                                     hide-details
                                     :hide-prepend-icon="true"
                ></DatetimePickerInput>
              </v-col>
            </v-row>
            <v-col cols="5" md="2">
              <a-btn
                color="primary"
                :disabled="selectedInstallationCrews.length < 1"
                @click="getDashboardValues()"
                text="Go"
              ></a-btn>
            </v-col>
          </v-row>
          <v-row>
            <v-toolbar flat class="app-toolbar">
              <v-toolbar-title class="app-title">Production Stats</v-toolbar-title>
            </v-toolbar>
          </v-row>
          <v-row>
            <v-card tile v-for="stat in dashValues" class="ma-3 flex-display card-main"
                    width="200" height="100" >
              <div class="card-accent" :style="{'background-color': 'white'}"></div>
              <v-card-text class="pt-1 stats-tile" @click="drilldownTitle = stat.name; drilldownData= stat.drilldownData; showModal = true">
                <div class="text-left default-text-color">{{stat.name}}</div>
                <div class="card-count">{{stat.value}}</div>
              </v-card-text>
            </v-card>
          </v-row>
          <v-row>
            <v-toolbar flat class="app-toolbar">
              <v-toolbar-title class="app-title">WIP</v-toolbar-title>
            </v-toolbar>
          </v-row>
          <v-row>
            <v-card tile v-for="wq in workQueues" class="ma-3 flex-display card-main"
                    :class="{'clickable': wq.workQueueCount > 0}"
                    :key="wq.id"
                    width="200" height="100" >
              <div class="card-accent" :style="{'background-color': wq.color}"></div>
              <v-card-text class="pt-1">
                <router-link class="no-text-decoration" target="_blank"
                             :to="{name: 'workQueueDrilldown', params: {id: wq.workQueueTypeId}, query: { smartlistId: wq.smartlistId, upId: 99999999, unassigned: selectedUserPosition.unassigned,
                                                                                                          installationCrewIds}}">
                  <div class="text-left default-text-color">{{wq.workQueueType}}</div>
                  <div class="card-count card-link">{{wq.workQueueCount}}</div>
                </router-link>
              </v-card-text>
            </v-card>
          </v-row>
        </v-col>
      </v-row>
      <v-row>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Key Performance Metrics</v-toolbar-title>
        </v-toolbar>
      </v-row>
      <v-row>
        <v-col cols="5" md="2">
          <a-select attach custom-classes="date-range-dropdown  py-2"
                    v-model="metricsSelectedDateRange"
                    :items="dateRanges"
                    label="Date Range"
                    @change="setMetricsDateRange()"
                    hide-details
          ></a-select>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="4" md="2">
          <DatetimePickerInput :custom-class="'date-range-date'"  py-2
                               v-model="metricsStartDate"
                               :timezone="timezone"
                               :maxDate="metricsEndDate"
                               :type="'date'"
                               @input="setDateRangeCustom(true)"
                               label="Start Date"
                               hide-details
                               :hide-prepend-icon="true"
          ></DatetimePickerInput>
        </v-col>
        <v-col cols="4" md="2">
          <DatetimePickerInput :custom-class="'date-range-date'"  py-2
                               v-model="metricsEndDate"
                               :timezone="timezone"
                               :minDate="metricsStartDate"
                               :type="'date'"
                               @input="setDateRangeCustom(true)"
                               label="End Date"
                               hide-details
                               :hide-prepend-icon="true"
          ></DatetimePickerInput>
        </v-col>
      </v-row>
      <v-col cols="5" md="2">
        <a-btn
          color="primary"
          class="mr-2 mb-3"
          @click="getPerformanceMetrics"
          text="Go"
        ></a-btn>
      </v-col>
    </template>

    <v-data-table
      :headers="headers"
      :items="performanceMetrics"
      :fixed-header="true"
      :items-per-page="-1"
      single-expand
      :mobile-breakpoint="0"
      :expanded.sync="expanded"
      hide-default-footer
      class="elevation-1 perf-table pb-md-5"
    >
      <template #no-data>
        NO DATA FOUND
      </template>

      <template #no-results>
        No parameters exist for this function
      </template>

      <template #item="{ item }">
        <tr class="text-left" :class="{'shaded-row': performanceMetrics.indexOf(item) % 2}">
          <td class="text-left">{{ item.rnk }}</td>
          <td class="text-left">{{ item.crewname }}</td>
          <td class="text-left">{{ parseFloat(item.substantialcompletions).toFixed(2)}}</td>
          <td class="text-left">{{ item.inspectionapproval }}%</td>
          <td class="text-left">{{ item.score }}</td>
        </tr>
      </template>
    </v-data-table>

  </v-container>
</template>


<script setup>

import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, } from '@/helpers/helpers'
import moment from "moment";
import constants from '@/helpers/constants'
import ProductionStatsDrilldown from "./ProductionStatsDrilldown"
import cloneDeep from "lodash.clonedeep";


import {ref, onMounted, computed, watch, getCurrentInstance} from "vue";
import {useAppStore} from "@/stores/AppStorePinia.js";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const router = vueInstance.$router
const route = vueInstance.$route
const vuetify = vueInstance.$vuetify

const model = ref({})
const workQueues = ref([])
const regionalManagers = ref([])
const installationCrew = ref([])
const expanded = ref([])
const selectedUserPosition = ref({})
const selectedRegionalManagers = ref([])
const selectedInstallationCrews = ref([])
const selectedDateRange = ref('Current Week')
const metricsSelectedDateRange = ref('Current Period')
const startDate = ref(moment().format('YYYY-MM-DD'))
const endDate = ref(moment().format('YYYY-MM-DD'))
const metricsStartDate = ref(moment().format('YYYY-MM-DD'))
const metricsEndDate = ref(moment().format('YYYY-MM-DD'))
const weekNum = ref(1)
const currentPeriod = ref(Math.floor(moment().isoWeek() / 4))
const timezone = ref('US/Mountain')
const dateRanges = ref(['Yesterday', 'Today', 'Current Week', 'Current Period', 'Last Week', 'Last Period', 'Custom', 'This Month', 'This Year', 'All Time'])
const workQueueOwners = ref([])
const dashValues = ref([])
const performanceMetrics = ref([])
const drilldownTitle = ref('')
const drilldownData = ref([])
const isLoading = ref(false)
const headers = ref([
  { text: 'Rank', value: 'rnk', width: 80, show: true },
  { text: 'Crew', value: 'crewname', width: 80, show: true },
  { text: 'Substantial Completions kW', value: 'substantialcompletions', width: 80, show: true },
  { text: 'Inspection Pass Rate', value: 'inspectionapproval', width: 80, show: true },
  { text: 'Score (kw x Pass rate)', value: 'score', width: 80, show: true },
])
const showModal = ref(false)

const appStore = useAppStore()

const selectAllManagers = computed(() => {
  return regionalManagers.value.length === selectedRegionalManagers.value.length
})
const selectSomeManagers = computed(() => {
  return selectedRegionalManagers.value.length > 0 && !selectAllManagers.value
})
const iconManagers = computed(() => {
  if (regionalManagers.value.length === selectedRegionalManagers.value.length) {
    return 'check_box'
  }
  if (selectSomeManagers.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllCrews = computed(() => {
  return installationCrew.value.length === selectedInstallationCrews.value.length
})
const selectSomeCrews = computed(() => {
  return selectedInstallationCrews.value.length > 0 && !selectAllCrews.value
})
const iconCrews = computed(() => {
  if (installationCrew.value.length === selectedInstallationCrews.value.length) {
    return 'check_box'
  }
  if (selectSomeCrews.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const additionalStartWeek = computed(() => {
  if (currentPeriod.value > 9) {
    return 1;
  }
  return 0;
})
const additionalEndWeek = computed(() => {
  if (currentPeriod.value === 9 || currentPeriod.value === 12) {
    return 1;
  }
  return 0;
})
const additionalStartWeekLastPeriod = computed(() => {
  if (currentPeriod.value > 10) {
    return 1;
  }
  return 0;
})
const additionalEndWeekLastPeriod = computed(() => {
  if (currentPeriod.value === 10 || currentPeriod.value === 1) {
    return 1;
  }
  return 0;
})
const momentStartOfPeriod = computed(() => {
  return moment().startOf('isoWeek').isoWeek((currentPeriod.value) * 4 - 1 + additionalStartWeek.value)
})
const startOfPeriod = computed(() => {
  return moment().startOf('isoWeek').isoWeek((currentPeriod.value) * 4 - 1 + additionalStartWeek.value).format('YYYY-MM-DD')
})
const endOfPeriod = computed(() => {
  return moment(momentStartOfPeriod.value).clone().add(3 + additionalEndWeek.value, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
})
const startOfWeek = computed(() => {
  return moment().startOf('W').format('YYYY-MM-DD')
})
const endOfWeek = computed(() => {
  return moment().endOf('W').format('YYYY-MM-DD')
})
const installationCrewIds = computed(() => {
  return selectedInstallationCrews.value?.length > 0 ? selectedInstallationCrews.value.map(u => u.positionId) : [];
})

onMounted(() => {
  setDateRange()
  setMetricsDateRange()
  getRegionalManagers()
})

  const toggleSelectAllManagers = () => {
    vueInstance.$nextTick(() => {
      if (selectAllManagers.value) {
        selectedRegionalManagers.value = []
      } else {
        selectedRegionalManagers.value = cloneDeep(regionalManagers.value)
        getInstallationCrew();
      }
    })
  }
  const toggleSelectAllCrews = () => {
    vueInstance.$nextTick(() => {
      if (selectAllCrews.value) {
        selectedInstallationCrews.value = []
      } else {
        selectedInstallationCrews.value = cloneDeep(installationCrew.value)
      }
    })
  }
  const getRegionalManagers = async () => {
    try {
      const {data} = await getRequest(`/installerDashboard/regionalManagers`)
      regionalManagers.value = data
      // If the logged in user is in this list, select them by default
      selectedRegionalManagers.value = regionalManagers.value.filter(u => u.userId);
      await getInstallationCrew()
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error retrieving Regional Managers')
    }
  }
  const getInstallationCrew = async () => {
    try {
      let regionalManagersIds = selectedRegionalManagers.value?.length > 0 ? selectedRegionalManagers.value.map(u => u.positionId) : [];
      if (regionalManagersIds.length < 1) {
        return;
      }

      const {data} = await getRequest(`/installerDashboard/installationCrew/`+ regionalManagersIds)
      installationCrew.value = data
      toggleSelectAllCrews();
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error retrieving Installation Crew')

    }
  }
  const getDashboardValues = async () => {
    try {
      appStore.loading = true
      const params = {
        startDate: startDate.value,
        endDate: endDate.value
      }

      const {data, status} = await getRequestWithParams('/installerDashboard/dashboardValues/' + installationCrewIds.value, {params})
      dashValues.value = data

      await getWipValues();
      isLoading.value = false
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error retrieving data')
      isLoading.value = false
      appStore.loading = false
    }
  }
  const getWipValues = async () => {
    try {
      appStore.loading = true
      const {data, status} = await getRequest('/installerDashboard/wipValues/' + installationCrewIds.value)
      workQueues.value = data

      isLoading.value = false
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error retrieving WIP data')
      isLoading.value = false
      appStore.loading = false
    }
  }
  const getPerformanceMetrics = async () => {
    try {
      appStore.loading = true

      const params = {
        startDate: metricsStartDate.value,
        endDate: metricsEndDate.value
      }

      const {data, status} = await getRequestWithParams('/installerDashboard/performanceMetrics', {params}, null, [])
      performanceMetrics.value = data
      isLoading.value = false
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error retrieving data')
      isLoading.value = false
      appStore.loading = false
    }
  }
  const setDateRange = () => {
    switch (selectedDateRange.value) {
      case 'Yesterday':
        startDate.value = moment().startOf('day').add(-1, 'days').format('YYYY-MM-DD')
        endDate.value = moment().endOf('day').add(-1, 'days').format('YYYY-MM-DD')
        break
      case 'Today':
        startDate.value = moment().startOf('day').format('YYYY-MM-DD')
        endDate.value = moment().endOf('day').format('YYYY-MM-DD')
        break
      case 'Current Week':
        startDate.value = startOfWeek.value
        endDate.value = endOfWeek.value
        break
      case 'Current Period':
        startDate.value = startOfPeriod.value
        endDate.value = endOfPeriod.value
        break
      case 'Last Week':
        startDate.value = moment().subtract(1, 'week').startOf('week').add(1, 'day').format('YYYY-MM-DD')
        endDate.value = moment().subtract(1, 'week').endOf('week').add(1, 'day').format('YYYY-MM-DD')
        break
      case 'Last Period':
        momentStartOfLastPeriod.value = moment().clone().startOf('isoWeek').isoWeek((currentPeriod.value - 1) * 4 - 1 + additionalStartWeekLastPeriod.value)
        startDate.value = moment().clone().startOf('isoWeek').isoWeek((currentPeriod.value - 1) * 4 - 1 + additionalStartWeekLastPeriod.value).format('YYYY-MM-DD')
        endDate.value = moment(momentStartOfLastPeriod.value).clone().add(3 + additionalEndWeekLastPeriod.value, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
        break
      case 'Custom':
        startDate.value = moment(startDate.value).format('YYYY-MM-DD')
        endDate.value = moment(startDate.value).format('YYYY-MM-DD')
        break
      case 'This Month':
        startDate.value = moment().startOf('month').format('YYYY-MM-DD')
        endDate.value = moment().endOf('month').format('YYYY-MM-DD')
        break
      case 'This Year':
        startDate.value = moment().startOf('year').format('YYYY-MM-DD')
        endDate.value = moment().format('YYYY-MM-DD')
        break;
      case 'All Time':
        startDate.value = moment('2000-01-01').format('YYYY-MM-DD')
        endDate.value = moment().format('YYYY-MM-DD')
        break
      default:
        startDate.value = startOfWeek.value
        endDate.value = endOfWeek.value
        break
    }
  }
  const setMetricsDateRange = () => {
    switch (metricsSelectedDateRange.value) {
      case 'Yesterday':
        metricsStartDate.value = moment().startOf('day').add(-1, 'days').format('YYYY-MM-DD')
        metricsEndDate.value = moment().endOf('day').add(-1, 'days').format('YYYY-MM-DD')
        break
      case 'Today':
        metricsStartDate.value = moment().startOf('day').format('YYYY-MM-DD')
        metricsEndDate.value = moment().endOf('day').format('YYYY-MM-DD')
        break
      case 'Current Week':
        metricsStartDate.value = startOfWeek.value
        metricsEndDate.value = endOfWeek.value
        break
      case 'Current Period':
        metricsStartDate.value = startOfPeriod.value
        metricsEndDate.value = endOfPeriod.value
        break
      case 'Last Week':
        metricsStartDate.value = moment().subtract(1, 'week').startOf('week').add(1, 'day').format('YYYY-MM-DD')
        metricsEndDate.value = moment().subtract(1, 'week').endOf('week').add(1, 'day').format('YYYY-MM-DD')
        break
      case 'Last Period':
        momentStartOfLastPeriod.value = moment().clone().startOf('isoWeek').isoWeek((currentPeriod.value - 1) * 4 - 1 + additionalStartWeekLastPeriod.value)
        metricsStartDate.value = moment().clone().startOf('isoWeek').isoWeek((currentPeriod.value - 1) * 4 - 1 + additionalStartWeekLastPeriod.value).format('YYYY-MM-DD')
        metricsEndDate.value = moment(momentStartOfLastPeriod.value).clone().add(3 + additionalEndWeekLastPeriod.value, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
        break
      case 'Custom':
        metricsStartDate.value = moment(startDate.value).format('YYYY-MM-DD')
        metricsEndDate.value = moment(startDate.value).format('YYYY-MM-DD')
        break
      case 'This Month':
        metricsStartDate.value = moment().startOf('month').format('YYYY-MM-DD')
        metricsEndDate.value = moment().endOf('month').format('YYYY-MM-DD')
        break
      case 'This Year':
        metricsStartDate.value = moment().startOf('year').format('YYYY-MM-DD')
        metricsEndDate.value = moment().format('YYYY-MM-DD')
        break;
      case 'All Time':
        metricsStartDate.value = moment('2000-01-01').format('YYYY-MM-DD')
        metricsEndDate.value = moment().format('YYYY-MM-DD')
        break
      default:
        metricsStartDate.value = startOfWeek.value
        metricsEndDate.value = endOfWeek.value
        break
    }
  }
  const setDateRangeCustom = (isMetricDateRange) => {
    if (isMetricDateRange) {
      metricsSelectedDateRange.value = 'Custom'
    }
    else {
      selectedDateRange.value = 'Custom'
    }
  }
</script>

<style scoped lang="scss">
.card-main {
  /* @click adds the pointer but i didnt want the pointer on count == 0 */
  cursor: default;
  text-align: center;
}
.card-accent {
  height: 100%;
  width: 5px;
  /*border-radius: 4px 0 0 4px !important;*/
}
.card-count {
  line-height: 2;
  font-size: 30px;
  font-weight: 600;
  position: absolute;
  bottom: 0;
  right: 0;
  left: 0;
}
.card-link {
  color: var(--v-grey-darken2);
}
.stats-tile {
  cursor: pointer;
}
</style>

<template>
  <v-container id="setter-dash-container" ref="setterDashContainer">
    <!---------------------------------- DASHBOARD TAB START ---------------------------------->
    <!-- PERSONAL PERFORMANCE SECTION START -->
    <div class="headline-large performance-header">
      Personal Performance
      <v-menu data-app left
              offset-y
              :max-height="`calc(100vh - 20px)`"
              class="dropdown-header body-small"
              v-model="openPersonalPerformanceDatesMenu"
              :close-on-content-click="true">
        <template v-slot:activator="{ on }">
          <a-btn class="dropdown-header body-small"
                 :activation-handler="on">
                    <span v-if="getDropdownById(personalPerformanceDateRange)?.name === 'CUSTOM' && performanceCustom.name != null" class="selected-option body-small">
                            {{performanceCustom.name}}</span>
            <span v-else-if="getDropdownById(personalPerformanceDateRange)?.name === 'PERIOD'" class="selected-option body-small">
                    {{ getDropdownById(personalPerformanceDateRange).periodList[personalPerformancePeriod].shortLabel}}
                    </span>
            <span v-else class="selected-option body-small">
                    {{ getDropdownById(personalPerformanceDateRange)?.friendlyName}}
                    </span>
            <v-spacer></v-spacer>
            <v-spacer></v-spacer>
            <v-icon color="primary">mdi-menu-down</v-icon>
          </a-btn>
        </template>
        <div>
          <v-list style="height: 400px; overflow-y:auto">
            <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
              <v-list-item-title v-if="item.name === 'PERIOD'">
                <v-menu open-on-hover offset-x>
                  <template v-slot:activator="{ on }">
                        <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                          {{ item.friendlyName }}
                          <v-icon style="display: flex">mdi-chevron-right</v-icon>
                        </span>
                  </template>
                  <div>
                    <v-list style="height: 300px; overflow-y:auto">
                      <v-list-item v-for="(period, index) in item.periodList"
                                   @click="personalPerformanceDateRange = item.id; personalPerformancePeriod = index; loadPersonalPerformance(); openPersonalPerformanceDatesMenu = false">
                        <v-list-item-title>
                          {{ period.label }}
                        </v-list-item-title>
                      </v-list-item>
                    </v-list>
                  </div>
                </v-menu>

              </v-list-item-title>
              <v-list-item-title v-else-if="item.name === 'CUSTOM'"
                                 @click="selectingCustomDates = true; personalPerformanceDateRange = item.id; customTable = 'Performance'"
                                 class="dashboard-menu-option body-large">
                {{ item.friendlyName }}
              </v-list-item-title>
              <v-list-item-title v-else
                                 @click="personalPerformanceDateRange = item.id; loadPersonalPerformance();"
                                 class="dashboard-menu-option body-large">
                {{ item.friendlyName }}
              </v-list-item-title>
            </v-list-item>
          </v-list>
        </div>
      </v-menu>
    </div>

    <v-row class="performance-row">
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-month</v-icon><span class="performance-card-header">Total Appointments</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.totalAppointments }}
        </span>
        <span class="body-small performance-card-contents">
          (not cancelled)
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-check</v-icon><span class="performance-card-header">Total Pitches</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.totalPitches }}
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-circle-slice-1</v-icon><span class="performance-card-header">Pitch Percentage</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.pitchPercentage }}%
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-poll</v-icon><span class="performance-card-header">Company Rank</span></span>
        <span v-if="isSetterMgr" class="headline-large performance-card-contents">
            {{ rankingData.currentOfficeRank }}
          </span>
        <span v-if="!isSetterMgr" class="headline-large performance-card-contents">
            {{ rankingData.currentRank }}
          </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-account</v-icon><span class="performance-card-header">Rep to Beat</span></span>
        <div class="headline-large">
          <span id="rep-to-beat-name" class="performance-card-contents">
              {{ rankingData.toBeatName }}
            </span>
        <br>
        </div>
        <span v-if="rankingData.currentRank !== '1'"
              class="body-small performance-card-contents">
              {{ rankingData.pitchesToGo }} {{ rankingData.pitchesToGo === 1 ? 'Pitch' : 'Pitches' }} to beat rep
            </span>
      </div>
    </v-row>
    <!-- PERSONAL PERFORMANCE SECTION END -->


    <!-- OFFICE PERFORMANCE SECTION START -->
    <div class="headline-large performance-header mt-5">
      Office Performance
      <v-menu data-app left
              offset-y
              :max-height="`calc(100vh - 20px)`"
              class="dropdown-header body-small"
              v-model="openOfficePerformanceDatesMenu"
              :close-on-content-click="true">
        <template v-slot:activator="{ on }">
          <a-btn class="dropdown-header body-small"
                 :activation-handler="on">
                    <span v-if="getDropdownById(officePerformanceDateRange)?.name === 'CUSTOM' && officePerformanceCustom.name != null" class="selected-option body-small">
                            {{officePerformanceCustom.name}}</span>
            <span v-else-if="getDropdownById(officePerformanceDateRange)?.name === 'PERIOD'" class="selected-option body-small">
                    {{ getDropdownById(officePerformanceDateRange).periodList[officePerformancePeriod].shortLabel}}
                    </span>
            <span v-else class="selected-option body-small">
                    {{ getDropdownById(officePerformanceDateRange)?.friendlyName}}
                    </span>
            <v-spacer></v-spacer>
            <v-spacer></v-spacer>
            <v-icon color="primary">mdi-menu-down</v-icon>
          </a-btn>
        </template>
        <div>
          <v-list style="height: 400px; overflow-y:auto">
            <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
              <v-list-item-title v-if="item.name === 'PERIOD'">
                <v-menu open-on-hover offset-x>
                  <template v-slot:activator="{ on }">
                        <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                          {{ item.friendlyName }}
                          <v-icon style="display: flex">mdi-chevron-right</v-icon>
                        </span>
                  </template>
                  <div>
                    <v-list style="height: 300px; overflow-y:auto">
                      <v-list-item v-for="(period, index) in item.periodList"
                                   @click="officePerformanceDateRange = item.id; officePerformancePeriod = index; loadOfficePerformance(); openOfficePerformanceDatesMenu = false">
                        <v-list-item-title>
                          {{ period.label }}
                        </v-list-item-title>
                      </v-list-item>
                    </v-list>
                  </div>
                </v-menu>

              </v-list-item-title>
              <v-list-item-title v-else-if="item.name === 'CUSTOM'"
                                 @click="selectingCustomDates = true; officePerformanceDateRange = item.id; customTable = 'Office Performance'"
                                 class="dashboard-menu-option body-large">
                {{ item.friendlyName }}
              </v-list-item-title>
              <v-list-item-title v-else
                                 @click="officePerformanceDateRange = item.id; loadOfficePerformance();"
                                 class="dashboard-menu-option body-large">
                {{ item.friendlyName }}
              </v-list-item-title>
            </v-list-item>
          </v-list>
        </div>
      </v-menu>
    </div>
    <v-row class="performance-row">
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-month</v-icon><span class="performance-card-header">Total Appointments</span></span>
        <span class="headline-large performance-card-contents">
          {{ officePerformanceData.totalAppointments }}
        </span>
        <span class="body-small performance-card-contents">
          (not cancelled)
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-check</v-icon><span class="performance-card-header">Total Pitches</span></span>
        <span class="headline-large performance-card-contents">
          {{ officePerformanceData.totalPitches }}
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-circle-slice-1</v-icon><span class="performance-card-header">Pitch Percentage</span></span>
        <span class="headline-large performance-card-contents">
          {{ officePerformanceData.pitchPercentage }}%
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-poll</v-icon><span class="performance-card-header">Company Rank</span></span>
        <span v-if="isSetterMgr" class="headline-large performance-card-contents">
            {{ officePerformanceData.currentOfficeRank }}
          </span>
        <span v-if="!isSetterMgr" class="headline-large performance-card-contents">
            {{ officePerformanceData.currentRank }}
          </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-account</v-icon><span class="performance-card-header">Office to Beat</span></span>
        <div class="headline-large">
          <span id="rep-to-beat-name" class="performance-card-contents">
              {{ officePerformanceData.toBeatName }}
            </span>
          <br>
        </div>
        <span v-if="officePerformanceData.currentRank !== '1'"
              class="body-small performance-card-contents">
              {{ officePerformanceData.pitchesToGo }} {{ officePerformanceData.pitchesToGo === 1 ? 'Pitch' : 'Pitches' }} to beat office
            </span>
      </div>
    </v-row>
    <!-- OFFICE PERFORMANCE SECTION END -->


    <!-- RANKING TABLES HEADER START -->
    <div class="headline-large company-header">
      Company Performance
    </div>
    <!-- RANKING TABLES HEADER END -->
    <div class="top-row">
      <v-card class="ranking-tables-card ranking-table-left">
        <div class="ranking-tables-section">
          <div class="ranking-table">
            <v-row class="filter-row">
              <div class="headline-small table-title">
                Top Reps
              </div>
              <v-menu data-app left
                      offset-y
                      :max-height="`calc(100vh - 20px)`"
                      class="dropdown-header body-small"
                      v-model="openRepMenu"
                      :close-on-content-click="true">
                <template v-slot:activator="{ on }">
                  <a-btn class="dropdown-header body-small"
                         :activation-handler="on">
                    <span v-if="getDropdownById(repDateRange)?.name === 'CUSTOM' && repCustom.name != null" class="selected-option body-small">
                            {{repCustom.name}}</span>
                    <span v-else-if="getDropdownById(repDateRange)?.name === 'PERIOD'" class="selected-option body-small">
                    {{ getDropdownById(repDateRange).periodList[topRepsPeriod].shortLabel}}
                    </span>
                    <span v-else-if="repDateRange != null" class="selected-option body-small">
                    {{ getDropdownById(repDateRange)?.friendlyName}}
                    </span>
                    <span v-else class="placeholder-option body-small">
                      Select Date Range
                    </span>
                    <v-spacer></v-spacer>
                    <v-spacer></v-spacer>
                    <v-icon color="primary">mdi-menu-down</v-icon>
                  </a-btn>
                </template>
                <div>
                  <v-list style="height: 400px; overflow-y:auto">
                    <v-list-item v-for="(item, index) in dropdownValues" class="pa-0">
                      <v-list-item-title v-if="item.name === 'PERIOD'">
                        <v-menu open-on-hover offset-x>
                          <template v-slot:activator="{ on }">
                        <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                          {{ item.friendlyName }}
                          <v-icon style="display: flex">mdi-chevron-right</v-icon>
                        </span>
                          </template>
                          <div>
                            <v-list style="height: 300px; overflow-y:auto">
                              <v-list-item v-for="(period, index) in item.periodList"
                                           @click="repDateRange = item.id; topRepsPeriod = index; getTopReps(); openRepMenu = false">
                                <v-list-item-title>
                                  {{ period.label }}
                                </v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </div>
                        </v-menu>

                      </v-list-item-title>
                      <v-list-item-title v-else-if="item.name === 'CUSTOM'"
                                         @click="selectingCustomDates = true; repDateRange = item.id; customTable = 'Rep'"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                      <v-list-item-title v-else
                                         @click="repDateRange = item.id; getTopReps();"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                    </v-list-item>
                  </v-list>
                </div>
              </v-menu>
              <a-btn variant="text" :disabled="repsData?.length === 0" class="export-button" @click="exportCsv('reps')">
                <v-icon class="mr-2">mdi-tray-arrow-down</v-icon>
                Export
              </a-btn>
            </v-row>
            <SetterRankingTable
              v-if="!topRepsLoading"
              title="Top Reps Table"
              id="top-reps-table"
              :tableData=repsData
              :tableHeaders=repRankingHeaders
              :noDataText=topRepsText
            />
          </div>
        </div>
      </v-card>
      <br class="hide-large">
      <v-card class="ranking-tables-card">
        <div class="ranking-tables-section">
          <!-- Office FDC RANK START -->
          <div class="ranking-table">
            <v-row class="filter-row">
              <div class="headline-small table-title">
                Office Rank
              </div>
              <v-menu data-app left
                      offset-y
                      :max-height="`calc(100vh - 20px)`"
                      class="dropdown-header body-small"
                      v-model="openCloserOfficeMenu"
                      :close-on-content-click="true">
                <template v-slot:activator="{ on }">
                  <a-btn class="dropdown-header body-small"
                         :activation-handler="on">
                    <span v-if="getDropdownById(closerOfficeDateRange)?.name === 'CUSTOM' && officeCustom.name != null" class="selected-option body-small">
                            {{officeCustom.name}}</span>
                    <span v-else-if="getDropdownById(closerOfficeDateRange)?.name === 'PERIOD'" class="selected-option body-small">
                    {{ getDropdownById(closerOfficeDateRange).periodList[officePeriod].shortLabel}}
                    </span>
                    <span v-else-if="closerOfficeDateRange != null" class="selected-option body-small">
                    {{ getDropdownById(closerOfficeDateRange)?.friendlyName}}
                    </span>
                    <span v-else class="placeholder-option body-small">
                      Select Date Range
                    </span>
                    <v-spacer></v-spacer>
                    <v-spacer></v-spacer>
                    <v-icon color="primary">mdi-menu-down</v-icon>
                  </a-btn>
                </template>
                <div>
                  <v-list style="height: 400px; overflow-y:auto">
                    <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                      <v-list-item-title v-if="item.name === 'PERIOD'">
                        <v-menu open-on-hover offset-x>
                          <template v-slot:activator="{ on }">
                        <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                          {{ item.friendlyName }}
                          <v-icon style="display: flex">mdi-chevron-right</v-icon>
                        </span>
                          </template>
                          <div>
                            <v-list style="height: 300px; overflow-y:auto">
                              <v-list-item v-for="(period, index) in item.periodList"
                                           @click="closerOfficeDateRange = item.id; officePeriod = index; getOfficeRanking(); openCloserOfficeMenu = false">
                                <v-list-item-title>
                                  {{ period.label }}
                                </v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </div>
                        </v-menu>

                      </v-list-item-title>
                      <v-list-item-title v-else-if="item.name === 'CUSTOM'"
                                         @click="selectingCustomDates = true; closerOfficeDateRange = item.id; customTable = 'Office'"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                      <v-list-item-title v-el2se
                                         @click="closerOfficeDateRange = item.id; getOfficeRanking();"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                    </v-list-item>
                  </v-list>
                </div>
              </v-menu>
              <a-btn variant="text" :disabled="officeRankingData?.length === 0" class="export-button" @click="exportCsv('office')">
                <v-icon class="mr-2">mdi-tray-arrow-down</v-icon>
                Export
              </a-btn>
            </v-row>
            <SetterRankingTable
              :tableData=officeRankingData
              :tableHeaders=officeRankingHeaders
              :noDataText=officeRankText
              id="office-rank-table"
            />
          </div>
        </div>
      </v-card>

    </div>
    <ConfirmationDialog v-if="selectingCustomDates" :disableConfirm="customDate.startDate === null || customDate.endDate === null || customDate.startDate?.length === 0 || customDate.endDate?.length === 0" :open-dialog="selectingCustomDates" @confirm="applyCustomDates()" @cancel="cancelCustomDialogue()" @close-dialog="selectingCustomDates = false">
      <template v-slot:title>Custom Date Range</template>
      <div>
        <DatetimePickerInput
          v-model="customDate.startDate"
          :timezone="timezone"
          :type="'date'"
          :format="'MMMM DD, YYYY'"
          input-format="HH:mm:ss"
          label="Start Date"
        />
        <DatetimePickerInput
          v-model="customDate.endDate"
          :timezone="timezone"
          :type="'date'"
          :format="'MMMM DD, YYYY'"
          input-format="HH:mm:ss"
          label="End Date"
        />
      </div>
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Confirm</template>

    </ConfirmationDialog>

    <!---------------------------------- DASHBOARD TAB END ---------------------------------->
  </v-container>
</template>

<script setup>
import moment from 'moment'
import constants from '@/helpers/constants'
import { handleHidingGlobalLoader, getRequestWithParams,  } from '@/helpers/helpers'
import {saveAs} from 'file-saver'

import SpinnerInline from '@/components/SpinnerInline'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import SetterRankingTable from "./SetterRankingTable.vue";

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const isBrCorporateUser = ref(userStore.details.companyId === 2)
const customTable = ref(null)
const timezone = ref('US/Mountain')
const personalPerformancePeriod = ref(null)
const officePerformancePeriod = ref(null)
const topRepsPeriod = ref(null)
const officePeriod = ref(null)
const openRepMenu = ref(false)
const openCloserOfficeMenu = ref(false)
const selectingCustomDates = ref(false)
const customDate = ref({startDate: "",endDate: "",trendStart: "",trendEnd: ""})
const performanceCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const officePerformanceCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const repCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const officeCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const repDateRange = ref(null)
const openPersonalPerformanceDatesMenu = ref(false)
const openOfficePerformanceDatesMenu = ref(false)
const roundRobins = ref([])
const dropdownValues = ref([])
const topRepsDataLoaded = ref(false)
const officeRankDataLoaded = ref(false)
const personalPerformanceDateRange = ref(6)
const officePerformanceDateRange = ref(6)
const closerOfficeDateRange = ref(null)
const isLoading = ref(false)
const isSetter = ref(false)
const isSetterMgr = ref(false)
const isSetterRegional = ref(false)
const officeRankingLoading = ref(false)
const topRepsLoading = ref(false)
const setterDashContainer = ref(null)
const rankingTablesLoaded = ref(false)
const rankingData = ref({})
const offices = ref([])
const reps = ref([])
const officeRankingData = ref([])
const officePerformanceData = ref({})
const repsData = ref([])
const userOffice = ref('')
const userOfficeId = ref(null)

const currentUserId = computed(() => {
  return userStore.details.id
})

const repRankingHeaders = computed(() => {
  return [
    { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true, width: '80px' },
    { text: 'Rep', value: 'name', sortable: false, class: 'total-col-th milestone-col-th data-width', show: !isBrCorporateUser.value },
    { text: 'Total Pitched Appointments', value: 'pitches', sortable: false, align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
  ]
})

const officeRankingHeaders = computed(() => {
  return [
    { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true, width: '80px' },
    { text: 'Office', value: 'org', sortable: false, class: 'total-col-th milestone-col-th data-width', show: !isBrCorporateUser.value },
    { text: 'Total Appointments', value: 'totalAppointments', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
    { text: 'Total Pitched Appointments', value: 'totalPitches', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
  ]
})

onMounted(async() => {
  appStore.loading = true
  let userPositions = userStore.details.userPositions

  if (userPositions?.length > 0) {
    userOfficeId.value = userPositions.filter(position => position.primaryFlag && !position.endDate)[0].orgId
    userOffice.value = userPositions.filter(position => position.orgId === userOfficeId.value)[0].hierarchy.filter(orgLevel => orgLevel.orgId === userOfficeId.value)[0].orgName
    isSetter.value = userPositions.filter(position => (position.positionId === 4) && !position.endDate && !position.archived && position.primaryFlag).length > 0
    isSetterMgr.value = userPositions.filter(position => (position.positionId === 5) && !position.endDate && !position.archived && position.primaryFlag).length > 0
    isSetterRegional.value = userPositions.filter(position => (position.positionId === 6) && !position.endDate && !position.archived && position.primaryFlag).length > 0
  }

  await getDropdownValues()

  let requests = [
    loadPersonalPerformance(),
    loadOfficePerformance(),
    // getTopReps(),
    // getOfficeRanking(),
  ]

  await Promise.all(requests).then(() => {
    rankingTablesLoaded.value = true
    appStore.loading = false
  })
})

const exportCsv = async (tableName) => {
  appStore.loading = true
  try {
    if(tableName === 'reps') {
      let filename = 'Setter Dashboard - Top Reps.csv'
      let csvData = ' , '
      if (dropdownValues.value.find(x => x.id === repDateRange.value).name === 'PERIOD') {
        csvData += dropdownValues.value.find(x => x.id === repDateRange.value).periodList[topRepsPeriod.value].shortLabel;
      } else {
        csvData += ((dropdownValues.value.find(x => x.id === repDateRange.value).name === 'CUSTOM') ? repCustom.value.name : dropdownValues.value.find(x => x.id === repDateRange.value).friendlyName);
      }
      csvData += '\n';

      csvData += 'Rank, Rep, Total Pitched Appointments';
      csvData += '\n';
      repsData.value.forEach((p, i) => {
        csvData += p.rank + ',' + p.name + ',' + p.pitches;
        csvData += '\n';
      })
      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      });

      saveAs(blob, filename);
    }
    else if(tableName === 'office') {
      let filename = 'Setter Dashboard - Office Rank.csv'
      let csvData = ' , '
      if (dropdownValues.value.find(x => x.id === closerOfficeDateRange.value).name === 'PERIOD') {
        csvData += dropdownValues.value.find(x => x.id === closerOfficeDateRange.value).periodList[officePeriod.value].shortLabel;
      } else {
        csvData += ((dropdownValues.value.find(x => x.id === closerOfficeDateRange.value).name === 'CUSTOM') ? officeFdcCustom.value.name : dropdownValues.value.find(x => x.id === closerOfficeDateRange.value).friendlyName);
      }
      csvData += '\n';

      csvData += 'Rank, Office, Total Appointments, Total Pitched Appointments';
      csvData += '\n';
      officeRankingData.value.forEach((p, i) => {
        csvData += p.rank + ',"' + p.org + '",' + p.total_appointments + ',' + p.total_pitches;
        csvData += '\n';
      })
      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      });

      saveAs(blob, filename);
    }

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Residual Review')

    appStore.loading = false
  }
}

const applyCustomDates = async()=> {
  if(customTable.value === 'Performance') {
    performanceCustom.value.startDate = moment(customDate.value.startDate);
    performanceCustom.value.endDate = moment(customDate.value.endDate);
    performanceCustom.value.name=moment(performanceCustom.value.startDate).format('MM/DD/YY') + '-' + moment(performanceCustom.value.endDate).format('MM/DD/YY');
    await loadPersonalPerformance()
  } else if(customTable.value === 'Office Performance') {
    officePerformanceCustom.value.startDate = moment(customDate.value.startDate);
    officePerformanceCustom.value.endDate = moment(customDate.value.endDate);
    officePerformanceCustom.value.name=moment(officePerformanceCustom.value.startDate).format('MM/DD/YY') + '-' + moment(officePerformanceCustom.value.endDate).format('MM/DD/YY');
    await loadPersonalPerformance()
  } else if(customTable.value === 'Rep') {
    repCustom.value.startDate = moment(customDate.value.startDate);
    repCustom.value.endDate = moment(customDate.value.endDate);
    repCustom.value.name=moment(repCustom.value.startDate).format('MM/DD/YY') + '-' + moment(repCustom.value.endDate).format('MM/DD/YY');
    await getTopReps()
  }
  else if(customTable.value === 'Office') {
    officeCustom.value.startDate = moment(customDate.value.startDate);
    officeCustom.value.endDate = moment(customDate.value.endDate);
    officeCustom.value.name=moment(officeCustom.value.startDate).format('MM/DD/YY') + '-' + moment(officeCustom.value.endDate).format('MM/DD/YY');
    await getOfficeRanking()
  }
}

const topRepsText = computed(() => {
  if(topRepsDataLoaded.value){
    return "Ranking Unavailable Now"
  }
  else {
    return "Please Select a Date"
  }
})

const officeRankText = computed(() => {
  if(officeRankDataLoaded.value){
    return "Ranking Unavailable Now"
  }
  else {
    return "Please Select a Date"
  }
})

const getDropdownValues = async()=>
{
  try {
    const params = {
      today: moment().format('YYYY-MM-DD')
    }

    const {data, status} = await getRequestWithParams('/setterDashboard/dropdownValues', {params}, 'blueraven', [])
    dropdownValues.value = data
    isLoading.value = false
    handleHidingGlobalLoader(this, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving data')
    isLoading.value = false
  }
}

const getDropdownById = (id) => {
  return dropdownValues.value.find(x => x.id === id)
}

const getFormattedStartAndEndParams = (dateRangeId, period, custom) => {
  let dropdown = getDropdownById(dateRangeId)
  let startDate, endDate
  if(dropdown && dropdown.id) {

      if(dropdown.name === 'PERIOD'){
        let periodList = dropdown.periodList[period.value]
        startDate = periodList.startDate
        endDate = periodList.endDate
      } else if(dropdown?.name === 'CUSTOM'){
        startDate = custom.startDate.format('MM/DD/YY')
        endDate = custom.endDate.format('MM/DD/YY')
      } else {
        startDate = moment(dropdown.startDate).format('YYYY-MM-DD')
        endDate = moment(dropdown.endDate).format('YYYY-MM-DD')
      }
  }
  return { startDate, endDate }
}

const loadPersonalPerformance = async () => {
  appStore.loading = true
  try {
    let params = getFormattedStartAndEndParams(personalPerformanceDateRange.value, personalPerformancePeriod.value, performanceCustom.value)

    const { data } = await getRequestWithParams('/setterDashboard/getPerformanceReport', { params }, 'blueraven')
    rankingData.value = data

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving personal performance data')

  }
}

const loadOfficePerformance = async () => {
  appStore.loading = true

  try {
    let params = getFormattedStartAndEndParams(officePerformanceDateRange.value, officePerformancePeriod.value, officePerformanceCustom.value)


      const {data} = await getRequestWithParams('/setterDashboard/getOfficePerformanceReport',
          {
            params
          }, 'blueraven')
    officePerformanceData.value = data

      appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving personal performance data')

  }
}

/* PERSONAL PERFORMANCE-RELATED CODE END */

/* RANKING TABLES-RELATED CODE START */
const getTopReps = async () => {
  try {
    appStore.loading = true
    topRepsLoading.value = true
    officeRankingLoading.value = true
    let params = getFormattedStartAndEndParams(repDateRange.value, topRepsPeriod.value, repCustom.value)

    params = { ...params, limit: 15}
    const {data} = await getRequestWithParams('/setterDashboard/topReps', {params}, 'blueraven')
    repsData.value = data

    topRepsDataLoaded.value = true
    topRepsLoading.value = false
    appStore.loading = false
  } catch (e) {
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving top reps data')
  }
}

const getOfficeRanking = async () => {  try {
  appStore.loading = true
  officeRankingLoading.value = true
  let params = getFormattedStartAndEndParams(closerOfficeDateRange.value, officePeriod.value, officeCustom.value)
  params = { ...params, limit: 500}

  const {data} = await getRequestWithParams('/setterDashboard/officeRanking',
    {params},
      'blueraven', [])
  officeRankingData.value = data
  officeRankDataLoaded.value = true

  officeRankingLoading.value = false
  appStore.loading = false
} catch (e) {
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving office ranking data')

  }
}

/* RANKING TABLES-RELATED CODE END */

</script>

<style lang="scss" scoped>
div#setter-dash-container {
  padding-right: 0px;
  padding-left: 0px;
  overflow-x: hidden;
}
.hidden-box{
  visibility: hidden!important;
}
@media (min-width: 960px) {
  .show-medium{
    display: none!important;
  }
  .show-small{
    display: none!important;
  }
}
@media (min-width: 601px) and (max-width: 959px) {
  //.show-large{
  //  display: none!important;
  //}
  .show-small{
    display: none!important;
  }
}
@media (max-width: 600px) {
  .show-large{
    display: none!important;
  }
  .show-medium{
    display: none!important;
  }
}
.placeholder-option{
  color: var(--v-grey-darken2) !important;
}
.performance-header{
  padding-bottom: 16px;
}
.company-header{
  padding-top: 40px;
  padding-bottom: 16px;
}
.performance-card-icon{
  border-radius: 8px!important;
  padding: 8px;
  background: #E3EFF7;
  color: #2C5893!important;
}
.performance-card-header{
  padding-left: 12px;
}
.performance-card-contents{
  padding-left: 42px;
}

.performance-row {
  flex-direction: row;
  display: flex;
  gap: 16px;
  padding-left: 16px;
}

.personal-performance-box {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 12px!important;
  gap: 10px;
  background-color: #fff;
  border-radius: 12px;
  margin: 5px 0;
  width: 326px;
  height: 130px;
  overflow-y: auto;
}

.ranking-tables-card{
  margin-bottom: 24px;
  width: 100%;
  min-width: 40%;
}
.ranking-table-left{
  margin-right: 16px;
}
.disabled-export{
  color: var(--v-grey-lighten1) !important;
}
.export-button{
  display: flex;
  margin: auto 30px auto auto;
}

.export-icon{
  color: #1F3C73;
}

.dashboard-menu-option{
  display: flex;
  min-height: 48px;
  align-items: center!important;
  padding-right: 16px;
  padding-left: 16px;
  cursor: pointer;
}

.table-title{
  padding-left: 16px;
}

.filter-row{
  padding-top: 20px;
}

@media (min-width: 600px) {
  .top-row {
    display: flex;
  }

  .hide-large{
    display: none;
  }
}
.ranking-table{
  background-color: white;
}

.ranking-tables-section{
  width: 100%;
}

.selected-option{
  color: var(--v-primary-base) !important;
  padding-right: 16px;
}

.dropdown-header{
  border: 1px solid var(--v-grey-lighten1);
  text-transform: unset !important;
  background-color: transparent !important;
  box-shadow: none;
  height: 40px !important;
  width: 200px;
  justify-content: left;
  margin-left: 24px;
  padding-left: 8px!important;
  letter-spacing: normal;
}

.fdc-dropdown-header{
  border: 1px solid var(--v-grey-lighten1);
  text-transform: unset !important;
  background-color: transparent !important;
  box-shadow: none;
  height: 40px !important;
  min-width: 200px;
  justify-content: left;
  margin-left: 24px;
  padding-left: 8px!important;
}
</style>

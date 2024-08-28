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
              v-model="openRoundRobinMenu"
              :close-on-content-click="true">
        <template v-slot:activator="{ on }">
          <a-btn class="dropdown-header body-small"
                 :activation-handler="on">
                    <span v-if="getDropdownById(personalPerformanceDateRange)?.name === 'CUSTOM' && performanceCustom.name != null" class="selected-option body-small">
                            {{performanceCustom.name}}</span>
            <span v-else-if="getDropdownById(personalPerformanceDateRange)?.name === 'PERIOD'" class="selected-option body-small">
                    {{ getDropdownById(personalPerformanceDateRange).periodList[performancePeriod].shortLabel}}
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
                                   @click="personalPerformanceDateRange = item.id; performancePeriod = index; loadPersonalPerformance(); openRoundRobinMenu = false">
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
    <div class="d-flex personal-performance-boxes-container show-large">
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-month</v-icon><span class="performance-card-header">Total Appointments</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.total_appointments ? rankingData.total_appointments : 0 }}
        </span>
        <span class="body-small performance-card-contents">
          (not cancelled)
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-check</v-icon><span class="performance-card-header">Total Pitches</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.total_pitches ? rankingData.total_pitches : 0 }}
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-circle-slice-1</v-icon><span class="performance-card-header">Pitch Percentage</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.pitch_percentage ? rankingData.pitch_percentage : 0 }}%
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-poll</v-icon><span class="performance-card-header">Company Rank</span></span>
        <span v-if="isSetterMgr" class="headline-large performance-card-contents">
            {{ rankBoxData.current_office_rank ? rankBoxData.current_office_rank : 'TBD' }}
          </span>
        <span v-if="!isSetterMgr" class="headline-large performance-card-contents">
            {{ rankBoxData.current_user_rank ? rankBoxData.current_user_rank : 'TBD' }}
          </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-account</v-icon><span class="performance-card-header">{{ isSetterMgr ? 'Office' : 'Rep' }} to Beat</span></span>
        <div class="headline-large">
            <span v-if="isSetterMgr" class="performance-card-contents">
              {{ rankBoxData.setter_office_to_beat_name ? rankBoxData.setter_office_to_beat_name : 'TBD' }}
            </span>
          <span v-if="!isSetterMgr" id="rep-to-beat-name" class="performance-card-contents">
              {{ rankBoxData.setter_to_beat_name ? rankBoxData.setter_to_beat_name : 'TBD' }}
            </span>
        <br>
        </div>
        <span v-if="rankBoxData.current_office_rank !== '1' && rankBoxData.current_user_rank !== '1'"
              class="body-small performance-card-contents">
              {{ rankBoxData.pitches_to_go ? rankBoxData.pitches_to_go : 0 }} {{ rankBoxData.pitches_to_go === 1 ? 'Pitch' : 'Pitches' }} to beat {{ isSetterMgr ? 'office' : 'rep' }}
            </span>
      </div>
    </div>
    <div class="d-flex personal-performance-boxes-container show-medium">
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-month</v-icon><span class="performance-card-header">Total Appointments</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.total_appointments ? rankingData.total_appointments : 0 }}
        </span>
        <span class="body-small performance-card-contents">
          (not cancelled)
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-check</v-icon><span class="performance-card-header">Total Pitches</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.total_pitches ? rankingData.total_pitches : 0 }}
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-circle-slice-1</v-icon><span class="performance-card-header">Pitch Percentage</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.pitch_percentage ? rankingData.pitch_percentage : 0 }}%
        </span>
      </div>
    </div>
    <div class="d-flex personal-performance-boxes-container show-medium">
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-poll</v-icon><span class="performance-card-header">Company Rank</span></span>
        <span v-if="isSetterMgr" class="headline-large performance-card-contents">
            {{ rankBoxData.current_office_rank ? rankBoxData.current_office_rank : 'TBD' }}
          </span>
        <span v-if="!isSetterMgr" class="headline-large performance-card-contents">
            {{ rankBoxData.current_user_rank ? rankBoxData.current_user_rank : 'TBD' }}
          </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-account</v-icon><span class="performance-card-header">{{ isSetterMgr ? 'Office' : 'Rep' }} to Beat</span></span>
        <div class="headline-large">
            <span v-if="isSetterMgr" class="performance-card-contents">
              {{ rankBoxData.setter_office_to_beat_name ? rankBoxData.setter_office_to_beat_name : 'TBD' }}
            </span>
          <span v-if="!isSetterMgr" id="rep-to-beat-name" class="performance-card-contents">
              {{ rankBoxData.setter_to_beat_name ? rankBoxData.setter_to_beat_name : 'TBD' }}
            </span>
          <br>
        </div>
        <span v-if="rankBoxData.current_office_rank !== '1' && rankBoxData.current_user_rank !== '1'"
              class="body-small performance-card-contents">
              {{ rankBoxData.pitches_to_go ? rankBoxData.pitches_to_go : 0 }} {{ rankBoxData.pitches_to_go === 1 ? 'Pitch' : 'Pitches' }} to beat {{ isSetterMgr ? 'office' : 'rep' }}
            </span>
      </div>
      <div class="personal-performance-box elevation-2 hidden-box">

      </div>
    </div>
    <div class="d-flex personal-performance-boxes-container show-small">
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-month</v-icon><span class="performance-card-header">Total Appointments</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.total_appointments ? rankingData.total_appointments : 0 }}
        </span>
        <span class="body-small performance-card-contents">
          (not cancelled)
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-calendar-check</v-icon><span class="performance-card-header">Total Pitches</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.total_pitches ? rankingData.total_pitches : 0 }}
        </span>
      </div>
    </div>
    <div class="d-flex personal-performance-boxes-container show-small">
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-circle-slice-1</v-icon><span class="performance-card-header">Pitch Percentage</span></span>
        <span class="headline-large performance-card-contents">
          {{ rankingData.pitch_percentage ? rankingData.pitch_percentage : 0 }}%
        </span>
      </div>
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-poll</v-icon><span class="performance-card-header">Company Rank</span></span>
        <span v-if="isSetterMgr" class="headline-large performance-card-contents">
            {{ rankBoxData.current_office_rank ? rankBoxData.current_office_rank : 'TBD' }}
          </span>
        <span v-if="!isSetterMgr" class="headline-large performance-card-contents">
            {{ rankBoxData.current_user_rank ? rankBoxData.current_user_rank : 'TBD' }}
          </span>
      </div>
    </div>
    <div class="d-flex personal-performance-boxes-container show-small">
      <div class="personal-performance-box elevation-2">
        <span class="label-small"><v-icon size="16" class="performance-card-icon">mdi-account</v-icon><span class="performance-card-header">{{ isSetterMgr ? 'Office' : 'Rep' }} to Beat</span></span>
        <div class="headline-large">
            <span v-if="isSetterMgr" class="performance-card-contents">
              {{ rankBoxData.setter_office_to_beat_name ? rankBoxData.setter_office_to_beat_name : 'TBD' }}
            </span>
          <span v-if="!isSetterMgr" id="rep-to-beat-name" class="performance-card-contents">
              {{ rankBoxData.setter_to_beat_name ? rankBoxData.setter_to_beat_name : 'TBD' }}
            </span>
          <br>
        </div>
        <span v-if="rankBoxData.current_office_rank !== '1' && rankBoxData.current_user_rank !== '1'"
              class="body-small performance-card-contents">
              {{ rankBoxData.pitches_to_go ? rankBoxData.pitches_to_go : 0 }} {{ rankBoxData.pitches_to_go === 1 ? 'Pitch' : 'Pitches' }} to beat {{ isSetterMgr ? 'office' : 'rep' }}
            </span>
      </div>
      <div class="personal-performance-box elevation-2 hidden-box">

      </div>
    </div>
    <!-- PERSONAL PERFORMANCE SECTION END -->

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
              <a v-if="repsData?.length > 0" class="export-button" @click="exportCsv('reps')">
                <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
                Export
              </a>
              <div v-else class="export-button" :class="{'disabled-export': true}">
                <v-icon class="export-icon disabled-export">mdi-tray-arrow-down</v-icon>
                Export
              </div>          </v-row>
            <SetterRankingTable
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
                      <v-list-item-title v-else
                                         @click="closerOfficeDateRange = item.id; getOfficeRanking();"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                    </v-list-item>
                  </v-list>
                </div>
              </v-menu>
              <a v-if="officeRankingData?.length > 0" class="export-button" @click="exportCsv('office')">
                <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
                Export
              </a>
              <div v-else class="export-button" :class="{'disabled-export': true}">
                <v-icon class="export-icon disabled-export">mdi-tray-arrow-down</v-icon>
                Export
              </div>          </v-row>
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
const performancePeriod = ref(null)
const topRepsPeriod = ref(null)
const officePeriod = ref(null)
const openRepMenu = ref(false)
const openCloserOfficeMenu = ref(false)
const selectingCustomDates = ref(false)
const customDate = ref({startDate: "",endDate: "",trendStart: "",trendEnd: ""})
const performanceCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const repCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const officeCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const repRankingHeaders = ref([])
const officeRankingHeaders = ref([])
const repDateRange = ref(null)
const openRoundRobinMenu = ref(false)
const roundRobins = ref([])
const dropdownValues = ref([])
const topRepsDataLoaded = ref(false)
const officeRankDataLoaded = ref(false)
const personalPerformanceDateRange = ref(6)
const closerOfficeDateRange = ref(null)
const isLoading = ref(false)
const isSetter = ref(false)
const isSetterMgr = ref(false)
const isSetterRegional = ref(false)
const officeRankingLoading = ref(false)
const performanceDataLoading = ref(false)
const topRepsLoading = ref(false)
const officeRankLoaded = ref(false)
const timeIntervalBtnGroup = ref(3)
const timeIntervalString = ref('MTD')
const timeInterval = ref(moment().format('DD') - 1)
const tabNum = ref(1)
const setterDashContainer = ref(null)
const performanceDataLoaded = ref(false)
const rankingTablesLoaded = ref(false)
const rankingData = ref({})
const rankBoxData = ref({})
const offices = ref([])
const reps = ref([])
const officeRankingData = ref([])
const repsData = ref([])
const userOffice = ref('')
const userOfficeId = ref(null)
const userRow = ref([])
const userRowIndex = ref(-1)
const numOffices = ref(0)
const timeIntervalBtns = ref([
  { name: 'Today', timeInterval: 'Today'},
  { name: 'Yesterday', timeInterval: 'Yesterday'},
  { name: 'WTD', timeInterval: 'WTD'},
  { name: 'MTD', timeInterval: 'MTD'},
  { name: 'QTD', timeInterval: 'QTD'},
  { name: 'YTD', timeInterval: 'YTD'},
])

const currentUserId = computed(() => {
  return userStore.details.id
})
const windowInnerWidth = computed(() => {
  return window.innerWidth
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
  repRankingHeaders.value = [
    { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true, width: '69px' },
    { text: 'Rep', value: 'name', sortable: false, class: 'total-col-th milestone-col-th data-width', show: !isBrCorporateUser.value },
    { text: 'Total Pitched Appointments', value: 'pitches', sortable: false, align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
  ]
  officeRankingHeaders.value = [
    { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true, width: '69px' },
    { text: 'Office', value: 'org', sortable: false, class: 'total-col-th milestone-col-th data-width', show: !isBrCorporateUser.value },
    { text: 'Total Appointments', value: 'total_appointments', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
    { text: 'Total Pitched Appointments', value: 'total_pitches', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
  ]
  // setTimeInterval('MTD') // MTD is the default

  let requests = [
    loadPersonalPerformance(),
    // getTopReps(),
    // getTopOffices(),
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
        csvData += dropdownValues.value.find(x => x.id === repDateRange.value).periodList[repPeriod.value].shortLabel;
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
        csvData += dropdownValues.value.find(x => x.id === closerOfficeDateRange.value).periodList[officeFdcPeriod.value].shortLabel;
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
  }
  else if(customTable.value === 'Rep') {
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

const resetScrollBarPosition = () => {
  // reset scroll bar positioning to top
  setterDashContainer.value.scrollTop = 0
}

const getDropdownById = (id) => {
  return dropdownValues.value.find(x => x.id === id)
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

    const {data, status} = await getRequestWithParams('/closerDashboard/dropdownValues', {params}, 'blueraven', [])
    dropdownValues.value = data
    isLoading.value = false
    handleHidingGlobalLoader(this, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving data')
    isLoading.value = false
  }
}

const loadPersonalPerformance = async () => {
  appStore.loading = true

  try {
    let startDate = moment(getDropdownById(personalPerformanceDateRange.value).startDate).format('YYYY-MM-DD')
    let endDate = moment(getDropdownById(personalPerformanceDateRange.value).endDate).format('YYYY-MM-DD')
    if(getDropdownById(personalPerformanceDateRange.value).name === 'PERIOD'){
      startDate = getDropdownById(personalPerformanceDateRange.value).periodList[performancePeriod.value].startDate
      endDate = getDropdownById(personalPerformanceDateRange.value).periodList[performancePeriod.value].endDate
    }
    else if(getDropdownById(personalPerformanceDateRange.value).name === 'CUSTOM'){
      startDate = performanceCustom.value.startDate.format('MM/DD/YY')
      endDate = performanceCustom.value.endDate.format('MM/DD/YY')
    }

    if (isSetterMgr.value) {
      let performanceData = await getRequestWithParams('/setterDashboard/getMgrPerformanceReport',
          {
            params: {
              officeId: userOfficeId.value,
              startDate,
              endDate
            }
          }, 'blueraven')
      rankingData.value = performanceData.data

      let officeToBeatData = await getRequestWithParams('/setterDashboard/officeToBeat',
          {
            params: {
              officeId: userOfficeId.value,
              startDate,
              endDate
            }
          }, 'blueraven')
      rankBoxData.value = officeToBeatData.data

      if (rankBoxData.value.setter_office_to_beat_name && rankBoxData.value.current_office_rank) {
        if (rankBoxData.value.current_office_rank === "1") {
          rankBoxData.value.setter_office_to_beat_name = 'Your office is #1!'
        } else if (rankBoxData.value.current_office_rank === 'T1') {
          let tiedOffices = offices.value.filter(office => office.rank === 'T1' && office.org_id !== userOfficeId.value)

          if (tiedOffices.length > 0) {
            let officeToBeat

            if (tiedOffices.length === 1) {
              officeToBeat = tiedOffices[0]
            } else {
              // randomly selects an office that's tied for 1st with current manager's office
              officeToBeat = tiedOffices[Math.floor(Math.random() * tiedOffices.length)]
            }

            if (officeToBeat.name.includes(' ()')) {
              officeToBeat.name = officeToBeat.name.substr(0, officeToBeat.name.length - 3)
            }

            rankBoxData.value.setter_office_to_beat_name = officeToBeat.name
            rankBoxData.value.pitches_to_go = 1
          }
        } else {
          if (rankBoxData.value.setter_office_to_beat_name.includes(' ()')) {
            rankBoxData.value.setter_office_to_beat_name = rankBoxData.value.setter_office_to_beat_name.substr(0, rankBoxData.value.setter_office_to_beat_name.length - 3)
          }
        }
      }

      appStore.loading = false
    } else {
      let performanceData = await getRequestWithParams('/setterDashboard/getPerformanceReport', {params: {startDate, endDate}}, 'blueraven')
      rankingData.value = performanceData.data

      let repToBeatData = await getRequestWithParams('/setterDashboard/repToBeat',
          {
            params: {
              userId: currentUserId.value,
              startDate,
              endDate
            }
          }, 'blueraven')
      rankBoxData.value = repToBeatData.data

      if (rankBoxData.value) {
        if (rankBoxData.value.setter_to_beat_id) {
          await getRepToBeatImage(rankBoxData.value.setter_to_beat_id)
        } else if (!rankBoxData.value.setter_to_beat_name && rankBoxData.value.current_user_rank) {
          if (rankBoxData.value.current_user_rank === "1") {
            rankBoxData.value.setter_to_beat_name = 'You’re #1!'
            await getRepToBeatImage(currentUserId.value) // gets current user's picture
          } else if (rankBoxData.value.current_user_rank === 'T1' && reps.value.length > 0) {
            let tiedReps = reps.value.filter(rep => rep.rank === 'T1' && rep.user_id !== currentUserId.value)

            if (tiedReps.length > 0) {
              let repToBeat

              if (tiedReps.length === 1) {
                repToBeat = tiedReps[0]
              } else {
                // randomly selects one of the reps who is tied for 1st with the current rep
                repToBeat = tiedReps[Math.floor(Math.random() * tiedReps.length)]
              }

              await getRepToBeatImage(repToBeat.user_id)
              rankBoxData.value.setter_to_beat_name = repToBeat.name
              rankBoxData.value.pitches_to_go = 1
            } else {
              rankBoxData.value.imageUrl = null
              rankBoxData.value.imageAltText = 'User photo placeholder'
            }
          }
        }
      }

      appStore.loading = false
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving personal performance data')

  }
}

const getRepToBeatImage = async (repToBeatId) => {
  appStore.loading = true
  try {
    const params = {sourceId: repToBeatId, attachmentTypeId: 9}
    const {data, status} = await getRequestWithParams('/attachment/getOne', {params})

    if (data?.presignedUrl) {
      rankBoxData.value.imageUrl = data.presignedUrl

      if (rankBoxData.value.setter_to_beat_name) {
        rankBoxData.value.imageAltText = 'Photo of ' + rankBoxData.value.setter_to_beat_name + ', a Blue Raven Solar employee'
      } else {
        rankBoxData.value.imageAltText = 'User photo placeholder'
      }

      handleHidingGlobalLoader( status)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving rep to beat image')

    appStore.loading = false
  }
}
/* PERSONAL PERFORMANCE-RELATED CODE END */

/* RANKING TABLES-RELATED CODE START */
const getTopReps = async () => {
  try {
    appStore.loading = true
    topRepsLoading.value = true
    officeRankingLoading.value = true
    let startDate = moment(getDropdownById(repDateRange.value).startDate).format('YYYY-MM-DD')
    let endDate = moment(getDropdownById(repDateRange.value).endDate).format('YYYY-MM-DD')
    if(getDropdownById(repDateRange.value).name === 'PERIOD'){
      startDate = getDropdownById(repDateRange.value).periodList[topRepsPeriod.value].startDate
      endDate = getDropdownById(repDateRange.value).periodList[topRepsPeriod.value].endDate
    }
    else if(getDropdownById(repDateRange.value).name === 'CUSTOM'){
      startDate = repCustom.value.startDate.format('MM/DD/YY')
      endDate = repCustom.value.endDate.format('MM/DD/YY')
    }
    const params = {limit: 15, startDate: startDate, endDate: endDate}
    const {data} = await getRequestWithParams('/setterDashboard/topReps', {params}, 'blueraven')
    topRepsDataLoaded.value = true
    if(data === ""){
      repsData.value = [];
      appStore.loading = false
      return;
    }
    repsData.value = data

    if (repsData.value.length > 0) {
      let userIds = []

      repsData.value.forEach(rep => {
        if (rep.user_id) {
          userIds.push(rep.user_id)
        }
      })

      if (userIds.length > 0) {
        userIds = encodeURI(userIds)

        let params = {
          sourceIds: userIds,
          attachmentTypeId: 9
        }

        const {data} = await getRequestWithParams('/attachment/getAttachmentPresignedUrlsForUserList', {params})

        if (data) {
          repsData.value.forEach(rep => {
            if (rep.user_id && data[rep.user_id]) {
              rep.userImageUrl = data[rep.user_id]
            }

            if (rep.userImageUrl && rep.name) {
              rep.userImageAltText = 'Photo of ' + rep.name + ', a Blue Raven Solar employee'
            } else {
              rep.userImageAltText = 'User photo placeholder'
            }
          })
        }
      }
    }

    topRepsLoading.value = false
    appStore.loading = false
  } catch (e) {
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving top reps data')

  }
}

const getTopOffices = async () => {
  try {
    topOfficesLoading.value = true
    const {data} = await getRequestWithParams('/setterDashboard/topOffices',
        {
          params: {
            limit: 5,
            days: timeInterval.value,
            interval: timeIntervalString.value
          }
        }, 'blueraven', [])
    offices.value = data || []

    // removes empty parentheses from missing metro areas
    offices.value?.forEach(office => {
      if (office.name.includes(' ()')) {
        office.name = office.name.substr(0, office.name.length - 3)
      }
    })
    topOfficesLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving top offices data')

  }
}

const getOfficeRanking = async () => {  try {
  appStore.loading = true
  officeRankingLoading.value = true
  let startDate = moment(getDropdownById(closerOfficeDateRange.value).startDate).format('YYYY-MM-DD')
  let endDate = moment(getDropdownById(closerOfficeDateRange.value).endDate).format('YYYY-MM-DD')
  if(getDropdownById(closerOfficeDateRange.value).name === 'PERIOD'){
    startDate = getDropdownById(closerOfficeDateRange.value).periodList[officePeriod.value].startDate
    endDate = getDropdownById(closerOfficeDateRange.value).periodList[officePeriod.value].endDate
  }
  else if(getDropdownById(closerOfficeDateRange.value).name === 'CUSTOM'){
    startDate = officeCustom.value.startDate.format('MM/DD/YY')
    endDate = officeCustom.value.endDate.format('MM/DD/YY')
  }
  const {data} = await getRequestWithParams('/setterDashboard/officeRanking',
    {
      params: {
        startDate: startDate,
        endDate: endDate,
        limit: 500,
      }
    }, 'blueraven', [])
  officeRankingData.value = data || []
  officeRankDataLoaded.value = true
  officeRankingData.value?.forEach(office => {
    if (office.org.includes(' ()')) {
      office.org = office.org.substr(0, office.org.length - 3)
    }
  })
  officeRankingLoading.value = false
  appStore.loading = false
} catch (e) {
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving office ranking data')

  }
}
const getTimeIntervalText =() => {
  return timeInterval.value === 0 ? 'Today' : timeInterval.value === 1 ? 'Since yesterday' : 'Last ' + timeInterval.value + ' days'
}
const setTimeInterval = (tis) => {
  try {
    rankingTablesLoaded.value = false
    timeIntervalString.value = tis
    rankingData.value = {}

    switch (tis) {
      case 'Today':
        timeInterval.value = 0 // TODAY
        break
      case 'Yesterday':
        timeInterval.value = 1 // YESTERDAY
        break
      case 'WTD':
        //gets # day of week. -1 because BR week starts on monday
        timeInterval.value = moment().day() - 1 // WTD
        break
      case 'MTD':
        //gets current # day of month (-1 so that we dont go down to 0)
        timeInterval.value = moment().format('DD') - 1 // MTD
        break
      case 'QTD':
        timeInterval.value =  moment().diff(moment().startOf('quarter'), 'days')// QTD
        break
      case 'YTD':
        //gets current # day of year (-1 so that we dont go down to 0)
        timeInterval.value = moment().dayOfYear() - 1 // YTD
        break
    }

    //i dont think there is any reason to wait for the previous requests to finish
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving ranking table data')

    rankingTablesLoaded.value = true
    appStore.loading = false
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
  .show-large{
    display: none!important;
  }
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
.personal-performance-boxes-container{
  gap: 16px;
  padding: 0px!important;
}
.personal-performance-box {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 16px!important;
  gap: 10px;
  background-color: #fff;
  border-radius: 12px;
  margin: 5px 0;
  width: 100%;
  height: 130px;
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
  color: #1F3C73;
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

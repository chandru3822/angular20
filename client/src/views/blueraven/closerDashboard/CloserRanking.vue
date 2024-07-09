<template>
  <div>
    <div class="top-row">
      <v-card class="ranking-tables-card ranking-table-left">
        <div class="ranking-tables-section">
          <!-- ROUND ROBIN LEAD ALLOCATION RANK START -->
          <div class="ranking-table">
            <v-row class="filter-row">
              <div class="headline-small table-title">
                Round Robin Lead Allocation Rank
              </div>
              <v-menu data-app left
                      offset-y
                      :max-height="`calc(100vh - 20px)`"
                      :close-on-content-click="true">
                <template v-slot:activator="{ on }">
                  <v-btn class="dropdown-header body-small"
                         v-on="on"
                  >
                    <div v-if="selectedRoundRobin" class="selected-option body-small"> {{ selectedRoundRobin.roundRobinName }} </div>
                    <div v-else class="selected-option body-small">Round Robin</div>
                    <v-spacer></v-spacer>
                    <v-icon>mdi-menu-down</v-icon>
                  </v-btn>
                </template>
                <div>
                  <v-list style="height: 400px; overflow-y:auto">
                    <v-list-item v-for="(item, index) in roundRobins" @click="changeRoundRobin(item)" class="body-large">
                      {{ item.roundRobinName }}
                    </v-list-item>
                  </v-list>
                </div>
              </v-menu>
              <v-menu data-app left
                      offset-y
                      :max-height="`calc(100vh - 20px)`"
                      class="dropdown-header body-small"
                      v-model="openRoundRobinMenu"
                      :close-on-content-click="true">
                <template v-slot:activator="{ on }">
                  <a-btn class="dropdown-header body-small"
                         :activation-handler="on">
                    <span v-if="getDropdownById(roundRobinDateRange)?.name === 'CUSTOM' && roundRobinCustom.name != null" class="selected-option body-small">
                            {{roundRobinCustom.name}}</span>
                    <span v-else-if="getDropdownById(roundRobinDateRange)?.name === 'PERIOD'" class="selected-option body-small">
                    {{ getDropdownById(roundRobinDateRange).periodList[roundRobinPeriod].shortLabel}}
                    </span>
                    <span v-else class="selected-option body-small">
                    {{ getDropdownById(roundRobinDateRange)?.friendlyName}}
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
                                           @click="roundRobinDateRange = item.id; roundRobinPeriod = index; changeRoundRobinDate(item); openRoundRobinMenu = false">
                                <v-list-item-title>
                                  {{ period.label }}
                                </v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </div>
                        </v-menu>

                      </v-list-item-title>
                      <v-list-item-title v-else-if="item.name === 'CUSTOM'"
                                         @click="selectingCustomDates = true; roundRobinDateRange = item.id; customTable = 'Round Robin'"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                      <v-list-item-title v-else
                                         @click="roundRobinDateRange = item.id; changeRoundRobinDate(item);"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                    </v-list-item>
                  </v-list>
                </div>
              </v-menu>
              <a v-if="leadAllocationRankingData?.length > 0" class="export-button" @click="exportCsv('roundRobin')">
                <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
                Export
              </a>
              <div v-else class="export-button" :class="{'disabled-export': true}">
                <v-icon class="export-icon disabled-export">mdi-tray-arrow-down</v-icon>
                Export
              </div>
            </v-row>
            <CloserRankingTable
              title="Round Robin Lead Allocation Rank"
              :tableData=leadAllocationRankingData
              :tableHeaders=leadAllocationRankingHeaders
              :noDataText="'Please select a Round Robin'"
              id="round-robin-table"
            />
          </div>
          <!-- ROUND ROBIN LEAD ALLOCATION RANK END -->
        </div>
      </v-card>
      <br class="hide-large">
      <v-card class="ranking-tables-card">
        <div class="ranking-tables-section">
          <!-- Office FDC RANK START -->
          <div class="ranking-table">
            <v-row class="filter-row">
              <div class="headline-small table-title">
                Office FDC Rank
              </div>
              <v-menu data-app left
                      offset-y
                      :max-height="`calc(100vh - 20px)`"
                      :close-on-content-click="true">
                <template v-slot:activator="{ on }">
                  <v-btn class="fdc-dropdown-header body-small"
                         v-on="on"
                  >
                    <div v-if="selectedCloserOffice" class="selected-option body-small"> {{ selectedCloserOffice.orgName }} </div>
                    <div v-else class="selected-option body-small">Closer Office</div>
                    <v-spacer></v-spacer>
                    <v-icon>mdi-menu-down</v-icon>
                  </v-btn>
                </template>
                <div>
                  <v-list style="height: 400px; overflow-y:auto">
                    <v-list-item v-for="(item, index) in closerOffices" @click="changeCloserOfficeFdc(item)" class="body-large">
                      {{ item.orgName }}
                    </v-list-item>
                  </v-list>
                </div>
              </v-menu>
              <v-menu data-app left
                      offset-y
                      :max-height="`calc(100vh - 20px)`"
                      class="dropdown-header body-small"
                      v-model="openCloserOfficeFdcMenu"
                      :close-on-content-click="true">
                <template v-slot:activator="{ on }">
                  <a-btn class="dropdown-header body-small"
                         :activation-handler="on">
                    <span v-if="getDropdownById(closerOfficeFdcDateRange)?.name === 'CUSTOM' && officeFdcCustom.name != null" class="selected-option body-small">
                            {{officeFdcCustom.name}}</span>
                    <span v-else-if="getDropdownById(closerOfficeFdcDateRange)?.name === 'PERIOD'" class="selected-option body-small">
                    {{ getDropdownById(closerOfficeFdcDateRange).periodList[officeFdcPeriod].shortLabel}}
                    </span>
                    <span v-else class="selected-option body-small">
                    {{ getDropdownById(closerOfficeFdcDateRange)?.friendlyName}}
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
                                           @click="closerOfficeFdcDateRange = item.id; officeFdcPeriod = index; changeCloserOfficeFdcDate(item); openCloserOfficeFdcMenu = false">
                                <v-list-item-title>
                                  {{ period.label }}
                                </v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </div>
                        </v-menu>

                      </v-list-item-title>
                      <v-list-item-title v-else-if="item.name === 'CUSTOM'"
                                         @click="selectingCustomDates = true; closerOfficeFdcDateRange = item.id; customTable = 'FDC'"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                      <v-list-item-title v-else
                                         @click="closerOfficeFdcDateRange = item.id; changeCloserOfficeFdcDate(item);"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                    </v-list-item>
                  </v-list>
                </div>
              </v-menu>
              <a v-if="officeFdcRankingData?.length > 0" class="export-button" @click="exportCsv('officeFdc')">
                <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
                Export
              </a>
              <div v-else class="export-button" :class="{'disabled-export': true}">
                <v-icon class="export-icon disabled-export">mdi-tray-arrow-down</v-icon>
                Export
              </div>          </v-row>
            <CloserRankingTable
              title="Round Robin Lead Allocation Rank"
              id="office-fdc-table"
              :tableData=officeFdcRankingData
              :tableHeaders=officeFdcRankingHeaders
              :noDataText="'Please select a Closer Office'"
            />
          </div>
        </div>
      </v-card>
    </div>
    <div class="top-row">
      <v-card class="ranking-tables-card ranking-table-left">
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
                    {{ getDropdownById(closerOfficeDateRange).periodList[closerOfficePeriod].shortLabel}}
                    </span>
                    <span v-else class="selected-option body-small">
                    {{ getDropdownById(closerOfficeDateRange)?.friendlyName}}
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
                                           @click="closerOfficeDateRange = item.id; closerOfficePeriod = index; changeCloserOffice(); openCloserOfficeMenu = false">
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
                                         @click="closerOfficeDateRange = item.id; changeCloserOffice();"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                    </v-list-item>
                  </v-list>
                </div>
              </v-menu>
              <a v-if="officeRankingData?.length > 0" class="export-button" @click="exportCsv('officeRank')">
                <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
                Export
              </a>
              <div v-else class="export-button" :class="{'disabled-export': true}">
                <v-icon class="export-icon disabled-export">mdi-tray-arrow-down</v-icon>
                Export
              </div>          </v-row>
            <CloserRankingTable
              :tableData=officeRankingData
              :tableHeaders=officeRankingHeaders
              :noDataText="'Please select a date'"
              id="office-rank-table"
            />
          </div>
        </div>
      </v-card>
      <br class="hide-large">
      <v-card class="ranking-tables-card">
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
                    {{ getDropdownById(repDateRange).periodList[repPeriod].shortLabel}}
                    </span>
                    <span v-else class="selected-option body-small">
                    {{ getDropdownById(repDateRange)?.friendlyName}}
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
                                           @click="repDateRange = item.id; repPeriod = index; changeRepDate(); openRepMenu = false">
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
                                         @click="repDateRange = item.id; changeRepDate(item);"
                                         class="dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                      </v-list-item-title>
                    </v-list-item>
                  </v-list>
                </div>
              </v-menu>
              <a v-if="repsData?.length > 0" class="export-button" @click="exportCsv('topReps')">
                <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
                Export
              </a>
              <div v-else class="export-button" @click="exportCsv" :class="{'disabled-export': true}">
                <v-icon class="export-icon disabled-export">mdi-tray-arrow-down</v-icon>
                Export
              </div>          </v-row>
            <CloserRankingTable
              title="Top Reps Table"
              id="top-reps-table"
              :tableData=repsData
              :tableHeaders=repRankingHeaders
              :noDataText="'Please select a Closer Office'"
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

  </div>
</template>

<script setup>
import CloserRankingTable from "./CloserRankingTable.vue";
import moment from "moment/moment.js";
import { useUserStore } from "@/stores/UserStore.js";
import {computed, getCurrentInstance, onMounted, ref} from "vue";
import {handleHidingGlobalLoader, getRequest, postRequest,  getRequestWithParams} from '@/helpers/helpers'
import groupBy from "lodash.groupby";
import orderBy from "lodash.orderby";
import cloneDeep from "lodash.clonedeep";
import {useAppStore} from "../../../stores/AppStore.js";
import {saveAs} from 'file-saver'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const appStore = useAppStore()
const userStore = useUserStore()
const userOffice = ref('')
const rankingTablesLoaded = ref(false)
const repsLoading = ref(false)
const roundRobins = ref([])
const selectedRoundRobin = ref(null)
const dropdownValues = ref([])
const isLoading = ref(false)
const roundRobinRanksLoading = ref(false)
const officeFdcRankLoading = ref(true)
const leadAllocationRankingData = ref([])
const leadAllocationRankingHeaders = ref([])
const officeFdcRankingHeaders = ref([])
const repRankingHeaders = ref([])
const officeRankingHeaders = ref([])
const isBrCorporateUser = ref(userStore.details.companyId === 2)
const closerOffices = ref([])
const officeFdcRankingData = ref([])
const officeRankingData = ref([])
const repsData = ref([])
const selectedCloserOffice = ref(null)
const timeInterval = ref(102)
const openRoundRobinMenu = ref(false)
const openCloserOfficeFdcMenu = ref(false)
const openCloserOfficeMenu = ref(false)
const openRepMenu = ref(false)
const currentUserOrgId = ref(null)
const roundRobinDateRange = ref(6)
const closerOfficeDateRange = ref(6)
const closerOfficeFdcDateRange = ref(6)
const repDateRange = ref(6)
const selectingCustomDates = ref(false)
const customDate = ref({startDate: "",endDate: "",trendStart: "",trendEnd: ""})
const roundRobinCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const officeFdcCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const officeCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const repCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const customTable = ref(null)
const timezone = ref('US/Mountain')
const roundRobinPeriod = ref(null)
const officeFdcPeriod = ref(null)
const closerOfficePeriod = ref(null)
const repPeriod = ref(null)
const userRow = ref([])
const userRowIndex = ref(-1)
const numOffices = ref(0)



onMounted(async() => {

  if (userStore.details.userPositions?.length > 0) {
    let usersPrimaryPosition = userStore.details.userPositions.find(p => {
      return (!p.archived && p.primaryFlag)
    })

    if(null != usersPrimaryPosition && [1, 2, 3, 517, 326].includes(usersPrimaryPosition.positionId)) {
      currentUserOrgId.value = usersPrimaryPosition.orgId
    }

  }

  await loadCloserOffices()
  await getDropdownValues()
  await loadRoundRobins()
  await loadRankingTables(0)

  leadAllocationRankingHeaders.value = [
    { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true, width: '69px' },
    { text: 'Rep', value: 'closerName', class: 'total-col-th milestone-col-th data-width', show: !isBrCorporateUser.value},
    { text: 'Lead-Gen FDC %', value: 'leadGenFdcPercentage', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Self-Gen FDC', value: 'selfGenFdc', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Average Availability', value: 'averageAvailability', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Lead Allocation %', value: 'score', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
  ]

  officeFdcRankingHeaders.value = [
    { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true },
    { text: 'Rep', value: 'closerName', class: 'milestone-col-th data-width', show: !isBrCorporateUser.value},
    { text: 'Lead-Gen FDC %', value: 'leadGenFdcPercentage', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Self-Gen FDC', value: 'selfGenFdc', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Total FDC', value: 'totalFdc', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
  ]

  officeRankingHeaders.value = [
    { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true, width: '69px' },
    { text: 'Office', value: 'officeName', class: 'total-col-th milestone-col-th data-width', show: !isBrCorporateUser.value},
    { text: 'Metro Area', value: 'metroArea', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Region', value: 'region', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Lead-Gen FDC %', value: 'leadGenFdcPercentage', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Self-Gen FDC', value: 'selfGenFdc', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Total FDC', value: 'totalFdc', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
  ]

  repRankingHeaders.value = [
    { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true, width: '69px' },
    { text: 'Rep', value: 'closerName', class: 'total-col-th milestone-col-th data-width', show: !isBrCorporateUser.value },
    { text: 'Current Office', value: 'officeName', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
    { text: 'Metro Area', value: 'metroArea', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
    { text: 'Lead-Gen FDC %', value: 'leadGenFdcPercentage', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
    { text: 'Self-Gen FDC', value: 'selfGenFdc', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value},
    { text: 'Total FDC', value: 'totalFdc', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value },
  ]
})

const currentUserId = computed(() => {
  return userStore.details.id
})

const changeRoundRobinDate = async(dateItem) => {
  if(selectedRoundRobin.value != null){
    await loadRoundRobinLeadAllocationRankData()
  }
}

const changeCloserOfficeFdcDate = async(dateItem) => {
  if(selectedCloserOffice.value != null){
    await loadOfficeFdcRankData()
  }
}

const getDropdownById = (id) => {
  return dropdownValues.value.find(x => x.id === id)
}

const changeRoundRobin = async(roundRobin) => {
  selectedRoundRobin.value = roundRobin
  await loadRoundRobinLeadAllocationRankData()
}

const changeCloserOfficeFdc = async(closerOffice) => {
  selectedCloserOffice.value = closerOffice
  await loadOfficeFdcRankData()
}

const changeCloserOffice = async() => {
  await loadRankingTables(1)
}

const changeRepDate = async() => {
  await loadRankingTables(2)
}

const loadRoundRobins = async() => {
  roundRobinRanksLoading.value = true
  try {
    const {data, status} = await getRequest('/closerDashboard/getRoundRobins', 'blueraven')
    roundRobins.value = data

    // if there's only one Round Robin for the current user, this auto-selects it
    if (roundRobins?.value.length === 1) {
      selectedRoundRobin.value = roundRobins?.value[0]
    }
    //REMOVE THIS
    timeInterval.value = 102
    //END REMOVE
    roundRobinRanksLoading.value = false

    handleHidingGlobalLoader(this, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving list of round robins')
    roundRobinRanksLoading.value = false
  }
}

const loadOfficeFdcRankData = async() => {
  officeFdcRankLoading.value = true
  try {
    let startDate = moment(getDropdownById(closerOfficeFdcDateRange.value).startDate).format('YYYY-MM-DD')
    let endDate = moment(getDropdownById(closerOfficeFdcDateRange.value).endDate).format('YYYY-MM-DD')
    if(getDropdownById(closerOfficeFdcDateRange.value).name === 'PERIOD'){
      startDate = getDropdownById(closerOfficeFdcDateRange.value).periodList[officeFdcPeriod.value].startDate
      endDate = getDropdownById(closerOfficeFdcDateRange.value).periodList[officeFdcPeriod.value].endDate
    }
    else if(getDropdownById(closerOfficeFdcDateRange.value).name === 'CUSTOM'){
      startDate = officeFdcCustom.value.startDate.format('MM/DD/YY')
      endDate = officeFdcCustom.value.endDate.format('MM/DD/YY')
    }
    let params = {
      startDate: startDate,
      endDate: endDate,
      officeFdcRank: true,
      selectedOrgId: selectedCloserOffice.value.id
    }
    const {data} = await getRequestWithParams('/closerDashboard/getRepRankings', {params}, 'blueraven')
    processRankingData(cloneDeep(data), 'Office FDC Rank')
    for(let rankingData of officeFdcRankingData.value){
      rankingData.leadGenFdcPercentage = rankingData.leadGenFdcPercentage + '%'
      rankingData.score = rankingData.score + '%'
    }
    officeFdcRankLoading.value = false
  } catch (e) {
    snackbar('ERROR', 'Error retrieving office FDC rank data')
    officeFdcRankLoading.value = false
  }
}

const loadCloserOffices  = async() => {
  officeFdcRankLoading.value = true
  try {
    const params = {
      userOrgId: currentUserOrgId.value
    }
    const {data} = await getRequestWithParams('/closerDashboard/getCloserOffices', {params}, 'blueraven')
    closerOffices.value = data

    // if there's only one Closer Office for the current user, this auto-selects it
    if (closerOffices?.value.length === 1) {
      selectedCloserOffice.value = closerOffices?.value[0].id
      await loadOfficeFdcRankData()
    }
    officeFdcRankLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving list of closer offices')
    officeFdcRankLoading.value = false
  }
}

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

const loadRoundRobinLeadAllocationRankData = async() =>
{
  roundRobinRanksLoading.value = true
  try {
    // const params = {roundRobinId: selectedRoundRobin.value, timeInterval: timeInterval.value}
    let startDate = moment(getDropdownById(roundRobinDateRange.value).startDate).format('YYYY-MM-DD')
    let endDate = moment(getDropdownById(roundRobinDateRange.value).endDate).format('YYYY-MM-DD')
    if(getDropdownById(roundRobinDateRange.value).name === 'PERIOD'){
      startDate = getDropdownById(roundRobinDateRange.value).periodList[roundRobinPeriod.value].startDate
      endDate = getDropdownById(roundRobinDateRange.value).periodList[roundRobinPeriod.value].endDate
    }
    else if(getDropdownById(roundRobinDateRange.value).name === 'CUSTOM'){
      startDate = roundRobinCustom.value.startDate.format('MM/DD/YY')
      endDate = roundRobinCustom.value.endDate.format('MM/DD/YY')
    }
    const params = {roundRobinId: selectedRoundRobin.value.id, startDate: startDate, endDate: endDate}
    const {data} = await getRequestWithParams('/closerDashboard/getRoundRobinLeadAllocationRank', {params}, 'blueraven')
    processRankingData(data, 'Round Robin Lead Allocation Rank')
    for(let rankingData of leadAllocationRankingData.value){
      rankingData.leadGenFdcPercentage = rankingData.leadGenFdcPercentage + '%'
      rankingData.score =rankingData.score+ '%'
    }
    roundRobinRanksLoading.value = false
  } catch (e) {
    snackbar('ERROR', 'Error retrieving round robin lead allocation rank data')
    roundRobinRanksLoading.value = false
  }
}

const processRankingData  = (rankingData, currentTable) => {
  if (currentTable === 'Round Robin Lead Allocation Rank') {
    leadAllocationRankingData.value = assignCloserRanks(rankingData, 'score')
  } else {
    switch (currentTable) {
      case 'Office FDC Rank':
        officeFdcRankingData.value = assignCloserRanks(rankingData, 'totalFdc')
        break
      case 'Office Ranking':
        rankingData = groupBy(rankingData, 'officeName')

        Object.keys(rankingData).forEach(group => {
          let leadGenFdcPercentageSum = 0
          let selfGenFdcSum = 0
          let totalFdcSum = 0
          let numRepsInGroup = 0

          rankingData[group].forEach(rep => {
            leadGenFdcPercentageSum += parseInt(rep.leadGenFdcPercentage)
            selfGenFdcSum += rep.selfGenFdc
            totalFdcSum += rep.totalFdc
            numRepsInGroup++
          })

          officeRankingData.value.push({
            officeName: rankingData[group][0].officeName,
            metroArea: rankingData[group][0].metroArea,
            region: rankingData[group][0].region,
            leadGenFdcPercentage: Math.round(leadGenFdcPercentageSum / numRepsInGroup),
            selfGenFdc: selfGenFdcSum,
            totalFdc: totalFdcSum
          })
        })

        officeRankingData.value = assignCloserRanks(officeRankingData.value, 'totalFdc')
        break
      case 'Top Reps':
        userRow.value = null
        numOffices.value = officeRankingData.value.length
        repsData.value = assignCloserRanks(rankingData, 'totalFdc')

        // determine whether current user's row is one of the visible rows
        userRowIndex.value = repsData.value.findIndex(row => row.userId === currentUserId.value)
        if (userRowIndex.value !== -1 && userRowIndex.value > numOffices.value - 1) {
          userRow.value = repsData.value.filter(row => row.userId === currentUserId.value)[0]
        }
    }
  }
}

const assignCloserRanks  = (rankingData, fieldName) => {
  let currentRank = 1
  let tiedRowNums = []
  rankingData?.forEach(row => row[fieldName] = row[fieldName] ? row[fieldName] : 0)
  rankingData = orderBy(rankingData, fieldName, 'desc')

  // handles ties & assigns rank #'s
  rankingData?.forEach((row, index) => {
    if ((index < rankingData.length - 1) && (rankingData[index][fieldName] === rankingData[index + 1][fieldName])) { // makes sure we're not out of bounds & checks if current row is tied with next row
      tiedRowNums.push(index) // adds current row # to list of tied row #'s
    } else {
      if (tiedRowNums.length > 0) {
        if (tiedRowNums.indexOf(index) === -1) tiedRowNums.push(index) // adds row # for last tied row in current set
        tiedRowNums.forEach(tiedRowNum => rankingData[tiedRowNum].rank = 'T' + currentRank) // adds T-prefixed rank labels to all tied rows
        currentRank += tiedRowNums.length // skips rank #'s based on # of tied rows
        tiedRowNums = [] // clears out #'s of tied rows since they've already been taken care of
      } else {
        rankingData[index].rank = currentRank++ // adds 1 to currentRank after assigning current rank # to current row
      }
    }
  })

  return rankingData
}

//1 for closer rank, 2 for reps, 0 for both
const loadRankingTables = async(selectedTable) => {
  rankingTablesLoaded.value = false
  repsLoading.value = true
  let startDate = moment(getDropdownById(closerOfficeDateRange.value).startDate).format('YYYY-MM-DD')
  let endDate = moment(getDropdownById(closerOfficeDateRange.value).endDate).format('YYYY-MM-DD')
  if(getDropdownById(closerOfficeDateRange.value).name === 'PERIOD'){
    startDate = getDropdownById(closerOfficeDateRange.value).periodList[closerOfficePeriod.value].startDate
    endDate = getDropdownById(closerOfficeDateRange.value).periodList[closerOfficePeriod.value].endDate
  }
  else if(getDropdownById(closerOfficeDateRange.value).name === 'CUSTOM'){
    startDate = officeCustom.value.startDate.format('MM/DD/YY')
    endDate = officeCustom.value.endDate.format('MM/DD/YY')
  }
  if(selectedTable === 2){
    startDate = moment(getDropdownById(repDateRange.value).startDate).format('YYYY-MM-DD')
    endDate = moment(getDropdownById(repDateRange.value).endDate).format('YYYY-MM-DD')
    if(getDropdownById(repDateRange.value).name === 'PERIOD'){
      startDate = getDropdownById(repDateRange.value).periodList[repPeriod.value].startDate
      endDate = getDropdownById(repDateRange.value).periodList[repPeriod.value].endDate
    }
    else if(getDropdownById(repDateRange.value).name === 'CUSTOM'){
      startDate = repCustom.value.startDate.format('MM/DD/YY')
      endDate = repCustom.value.endDate.format('MM/DD/YY')
    }
  }
  try {
    let params = {
      startDate: startDate,
      endDate: endDate
    }
    const {data} = await getRequestWithParams('/closerDashboard/getRepRankings', {params}, 'blueraven', [])

    if (data?.companyRankingValues?.filter(row => row.userId === currentUserId.value)[0] !== undefined) {
      userOffice.value = data?.companyRankingValues?.filter(row => row.userId === currentUserId.value)[0].officeName
    }

    if(selectedTable === 1 || selectedTable === 0) {
     officeRankingData.value = []
      processRankingData(cloneDeep(data), 'Office Ranking')
    }
    if(selectedTable === 2 || selectedTable === 0) {
      repsData.value = []
      processRankingData(cloneDeep(data), 'Top Reps')
      console.log(dropdownValues.value)
    }

    rankingTablesLoaded.value = true
    repsLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving ranking table data')
    rankingTablesLoaded.value = true
    repsLoading.value = false
  }
}

const exportCsv = async (tableName) => {
  appStore.loading = true
  try {
    if(tableName === 'roundRobin') {
      let filename = 'Closer Dashboard - Round Robin Lead Allocation.csv'
      let csvData = ' , '
      if (dropdownValues.value.find(x => x.id === roundRobinDateRange.value).name === 'PERIOD') {
        csvData += dropdownValues.value.find(x => x.id === roundRobinDateRange.value).periodList[roundRobinPeriod.value].shortLabel;
      } else {
        csvData += ((dropdownValues.value.find(x => x.id === roundRobinDateRange.value).name === 'CUSTOM') ? roundRobinCustom.value.name : dropdownValues.value.find(x => x.id === roundRobinDateRange.value).friendlyName);
      }
      csvData += '\n';

      csvData += 'Rank, Rep, Lead-Gen FDC %, Self-Gen FDC, Average Availability, Lead-Allocation %';
      csvData += '\n';
      leadAllocationRankingData.value.forEach((p, i) => {
        csvData += p.rank + ',' + p.closerName + ',' + p.leadGenFdcPercentage + ',' + p.selfGenFdc + ',' + p.averageAvailability + ',' + p.score;
        csvData += '\n';
      })
      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      });

      saveAs(blob, filename);
    }
    else if(tableName === 'officeFdc') {
      let filename = 'Closer Dashboard - Office FDC Rank.csv'
      let csvData = ' , '
      if (dropdownValues.value.find(x => x.id === closerOfficeFdcDateRange.value).name === 'PERIOD') {
        csvData += dropdownValues.value.find(x => x.id === closerOfficeFdcDateRange.value).periodList[officeFdcPeriod.value].shortLabel;
      } else {
        csvData += ((dropdownValues.value.find(x => x.id === closerOfficeFdcDateRange.value).name === 'CUSTOM') ? officeFdcCustom.value.name : dropdownValues.value.find(x => x.id === closerOfficeFdcDateRange.value).friendlyName);
      }
      csvData += '\n';

      csvData += 'Rank, Rep, Lead-Gen FDC %, Self-Gen FDC, Total FDC';
      csvData += '\n';
      officeFdcRankingData.value.forEach((p, i) => {
        csvData += p.rank + ',' + p.closerName + ',' + p.leadGenFdcPercentage + ',' + p.selfGenFdc + ',' + p.totalFdc;
        csvData += '\n';
      })
      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      });

      saveAs(blob, filename);
    }
    else if(tableName === 'officeRank') {
      let filename = 'Closer Dashboard - Office Rank.csv'
      let csvData = ' , '
      if (dropdownValues.value.find(x => x.id === closerOfficeDateRange.value).name === 'PERIOD') {
        csvData += dropdownValues.value.find(x => x.id === closerOfficeDateRange.value).periodList[closerOfficePeriod.value].shortLabel;
      } else {
        csvData += ((dropdownValues.value.find(x => x.id === closerOfficeDateRange.value).name === 'CUSTOM') ? officeCustom.value.name : dropdownValues.value.find(x => x.id === closerOfficeDateRange.value).friendlyName);
      }
      csvData += '\n';

      csvData += 'Rank, Office, Metro Area, Region, Lead-Gen FDC %, Self-Gen FDC, Total FDC';
      csvData += '\n';
      officeRankingData.value.forEach((p, i) => {
        csvData += p.rank + ',' + p.officeName + ',' + p.metroArea + ',' + p.region + ',' + p.leadGenFdcPercentage + ',' + p.selfGenFdc + ',' + p.totalFdc;
        csvData += '\n';
      })
      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      });

      saveAs(blob, filename);
    }
    else if(tableName === 'topReps') {
      let filename = 'Closer Dashboard - Top Reps.csv'
      let csvData = ' , '
      if (dropdownValues.value.find(x => x.id === repDateRange.value).name === 'PERIOD') {
        csvData += dropdownValues.value.find(x => x.id === repDateRange.value).periodList[repPeriod.value].shortLabel;
      } else {
        csvData += ((dropdownValues.value.find(x => x.id === repDateRange.value).name === 'CUSTOM') ? repCustom.value.name : dropdownValues.value.find(x => x.id === repDateRange.value).friendlyName);
      }
      csvData += '\n';

      csvData += 'Rank, Rep, Current Office, Metro Area, Lead-Gen FDC %, Self-Gen FDC, Total FDC';
      csvData += '\n';
      repsData.value.forEach((p, i) => {
        csvData += p.rank + ',' + p.closerName + ',' + p.officeName + ',' + p.metroArea + ',' + p.leadGenFdcPercentage + ',' + p.selfGenFdc + ',' + p.totalFdc;
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
  if(customTable.value === 'Round Robin') {
    roundRobinCustom.value.startDate = moment(customDate.value.startDate);
    roundRobinCustom.value.endDate = moment(customDate.value.endDate);
    roundRobinCustom.value.name=moment(roundRobinCustom.value.startDate).format('MM/DD/YY') + '-' + moment(roundRobinCustom.value.endDate).format('MM/DD/YY');
    await loadRoundRobinLeadAllocationRankData()
  }
  else if(customTable.value === 'FDC') {
    officeFdcCustom.value.startDate = moment(customDate.value.startDate);
    officeFdcCustom.value.endDate = moment(customDate.value.endDate);
    officeFdcCustom.value.name=moment(officeFdcCustom.value.startDate).format('MM/DD/YY') + '-' + moment(officeFdcCustom.value.endDate).format('MM/DD/YY');
    await loadOfficeFdcRankData()
  }
  else if(customTable.value === 'Office') {
    officeCustom.value.startDate = moment(customDate.value.startDate);
    officeCustom.value.endDate = moment(customDate.value.endDate);
    officeCustom.value.name=moment(officeCustom.value.startDate).format('MM/DD/YY') + '-' + moment(officeCustom.value.endDate).format('MM/DD/YY');
    await loadRankingTables(1)
  }
  else if(customTable.value === 'Rep') {
    repCustom.value.startDate = moment(customDate.value.startDate);
    repCustom.value.endDate = moment(customDate.value.endDate);
    repCustom.value.name=moment(repCustom.value.startDate).format('MM/DD/YY') + '-' + moment(repCustom.value.endDate).format('MM/DD/YY');
    await loadRankingTables(2)
  }
  // else if(customColumn.value === 2){
  //   secondCustom.value.startDate = moment(customDate.value.startDate);
  //   secondCustom.value.endDate = moment(customDate.value.endDate);
  //   let dateDiff = secondCustom.value.endDate.diff(secondCustom.value.startDate, 'days');
  //   secondCustom.value.trendEnd = secondCustom.value.startDate.clone().subtract(1, 'days');
  //   secondCustom.value.trendStart = secondCustom.value.trendEnd.clone().subtract(dateDiff, 'days');
  //   getDropdownById(secondDateRange.value).trendText = moment(secondCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(secondCustom.value.trendEnd).format('MM/DD/YYYY');
  //   secondCustom.value.name=moment(secondCustom.value.startDate).format('MM/DD/YY') + '-' + moment(secondCustom.value.endDate).format('MM/DD/YY');
  // }
  // else if(customColumn.value === 3){
  //   thirdCustom.value.startDate = moment(customDate.value.startDate);
  //   thirdCustom.value.endDate = moment(customDate.value.endDate);
  //   let dateDiff = thirdCustom.value.endDate.diff(thirdCustom.value.startDate, 'days');
  //   thirdCustom.value.trendEnd = thirdCustom.value.startDate.clone().subtract(1, 'days');
  //   thirdCustom.value.trendStart = thirdCustom.value.trendEnd.clone().subtract(dateDiff, 'days');
  //   getDropdownById(thirdDateRange.value).trendText = moment(thirdCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(thirdCustom.value.trendEnd).format('MM/DD/YYYY');
  //   thirdCustom.value.name=moment(thirdCustom.value.startDate).format('MM/DD/YY') + '-' + moment(thirdCustom.value.endDate).format('MM/DD/YY');
  // }

}
</script>

<style lang="scss" scoped>
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

<style lang="scss">
#round-robin-table > div > div > table > thead > tr > th.text-start.milestone-col-th,
#round-robin-table > div > div > table > tbody > tr > td.text-start{
  position: sticky!important;
  left: 0;
  z-index: 2 !important;
  background-color: white;
  min-width: 69px;
}

#round-robin-table > div > div > table > tbody > tr > td:nth-child(2).text-start,
#round-robin-table > div > div > table > thead > tr > th.text-start.data-width{
  left: 69px!important;
}

#round-robin-table > div > div > table > thead > tr > th.text-start.data-width,
#round-robin-table > div > div > table > tbody > tr > td.text-left.data-col-th{
  min-width: 140px;
}

#round-robin-table > div > div > table > tbody > tr > td:nth-child(1){
  padding: 0px;
}

#top-reps-table > div > div > table > thead > tr > th.text-start.milestone-col-th,
#top-reps-table > div > div > table > tbody > tr > td.text-start{
  position: sticky!important;
  left: 0;
  z-index: 2 !important;
  background-color: white;
  min-width: 69px;
}

#top-reps-table > div > div > table > tbody > tr > td:nth-child(2).text-start,
#top-reps-table > div > div > table > thead > tr > th.text-start.data-width{
  left: 69px!important;
}

#top-reps-table > div > div > table > thead > tr > th.text-start.data-width,
#top-reps-table > div > div > table > tbody > tr > td.text-left.data-col-th{
  min-width: 140px;
}

#top-reps-table > div > div > table > tbody > tr > td:nth-child(1){
  padding: 0px;
}

#office-fdc-table > div > div > table > thead > tr > th.text-start.milestone-col-th,
#office-fdc-table > div > div > table > tbody > tr > td.text-start{
  position: sticky!important;
  left: 0;
  z-index: 2 !important;
  background-color: white;
  min-width: 69px;
}

#office-fdc-table > div > div > table > tbody > tr > td:nth-child(2).text-start,
#office-fdc-table > div > div > table > thead > tr > th.text-start.data-width{
  left: 69px!important;
}

#office-fdc-table > div > div > table > thead > tr > th.text-start.data-width,
#office-fdc-table > div > div > table > tbody > tr > td.text-left.data-col-th{
  min-width: 140px;
}

#office-fdc-table > div > div > table > tbody > tr > td:nth-child(1){
  padding: 0px;
}

#office-rank-table > div > div > table > thead > tr > th.text-start.milestone-col-th,
#office-rank-table > div > div > table > tbody > tr > td.text-start{
  position: sticky!important;
  left: 0;
  z-index: 2 !important;
  background-color: white;
  min-width: 69px;
}

#office-rank-table > div > div > table > tbody > tr > td:nth-child(2).text-start,
#office-rank-table > div > div > table > thead > tr > th.text-start.data-width{
  left: 69px!important;
}

#office-rank-table > div > div > table > thead > tr > th.text-start.data-width,
#office-rank-table > div > div > table > tbody > tr > td.text-left.data-col-th{
  min-width: 140px;
}

#office-rank-table > div > div > table > tbody > tr > td:nth-child(1){
  padding: 0px;
}

</style>

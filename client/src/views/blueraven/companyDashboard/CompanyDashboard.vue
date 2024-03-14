<template>
  <v-container id="company-dash-container">
    <v-card class="filter-bar">
      <v-row align="center">
        <div class="title-large company-dashboard-header">
          Company Dashboard
        </div>
        <div class="checkbox-container">
          <v-checkbox label="View Trends" v-model="viewTrends"></v-checkbox>
        </div>
        <div class="checkbox-container">

          <v-checkbox label="Only View Major Milestones" v-model="viewMajorMilestones"></v-checkbox>
        </div>
        <a class="export-button" @click="exportCsv">
          <v-icon class="export-icon mr-2">mdi-tray-arrow-down</v-icon>
          Export
        </a>
      </v-row>
    </v-card>

    <v-card class="filter-bar-mini">
      <v-row>
        <div class="dashboard-header">
          Company Dashboard
        </div>
      </v-row>
      <v-row>
        <div class="checkbox-container-mini">
          <v-checkbox label="View Trends" v-model="viewTrends"></v-checkbox>
        </div>
        <a class="export-button" @click="exportCsv"><v-icon class="export-icon">mdi-tray-arrow-down</v-icon></a>
      </v-row>
      <v-row>
        <div class="checkbox-container-mini">
          <v-checkbox label="Only View Major Milestones" v-model="viewMajorMilestones"></v-checkbox>
        </div>
      </v-row>
    </v-card>
    <br>
    <v-data-table
        id="company-dash-table"
        class="elevation-1"
        :items="filteredDashValues"
        :headers="headers"
        ref="pageable-table"
        disable-sort
        :item-class="itemRowBackground"
        :footer-props="footerProps"
        :loading="isLoading"
        :hide-default-footer="true"
        :mobile-breakpoint="0"
    >

      <template #no-data>
        <span class="default-text-color">No available data</span>
      </template>


      <template #header.milestone="{}" id="milestones-header">Milestones</template>
      <template #header.actualTotal="{}" >
        <v-menu data-app left
                offset-y
                :max-height="`calc(100vh - 20px)`"
                class="dropdown-header body-small"
                v-model="openFirstMenu"
                :close-on-content-click="true">
          <template v-slot:activator="{ on }">
            <AlbatrossButton class="dropdown-header body-small"
                   :activation-handler="on">
              <template v-slot:default>
                <span v-if="getDropdownById(firstDateRange)?.name === 'CUSTOM' && firstCustom.name != null" class="selected-option body-small">
                        {{firstCustom.name}}</span>
                <span v-else-if="getDropdownById(firstDateRange)?.name === 'PERIOD'" class="selected-option body-small">
                {{ getDropdownById(firstDateRange).periodList[firstPeriod].shortLabel}}
                </span>
                <span v-else class="selected-option body-small">
                {{ getDropdownById(firstDateRange)?.friendlyName}}
                </span>
                <v-spacer></v-spacer>
                <v-icon color="primary">mdi-menu-down</v-icon>
              </template>
            </AlbatrossButton>
          </template>
          <div>
            <v-list style="height: 400px; overflow-y:auto">
              <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                <v-list-item-title v-if="item.name === 'PERIOD'">
                  <v-menu open-on-hover v-model="openFirstPeriodMenu" offset-x>
                    <template v-slot:activator="{ on }">
                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                        <v-icon style="display: flex">mdi-chevron-right</v-icon>
                      </span>
                    </template>
                    <div>
                      <v-list style="height: 300px; overflow-y:auto">
                        <v-list-item v-for="(period, index) in item.periodList" @click="firstDateRange = item.id; firstPeriod = index; changeDropdownSelection(1); firstCustom.isActive = (item.name === 'CUSTOM'); openFirstMenu = false">
                          <v-list-item-title class="body-large">
                            {{ period.label }}
                          </v-list-item-title>
                        </v-list-item>
                      </v-list>
                    </div>
                  </v-menu>

                </v-list-item-title>
                <v-list-item-title v-else @click="firstDateRange = item.id; changeDropdownSelection(1); firstCustom.isActive = (item.name === 'CUSTOM');" class="dashboard-menu-option">{{item.friendlyName}}</v-list-item-title>
              </v-list-item>
            </v-list>
          </div>
        </v-menu>

      </template>
      <template #header.actualTotal2="{}" >
        <v-menu data-app left
                offset-y
                :max-height="`calc(100vh - 20px)`"
                class="dropdown-header body-small"
                v-model="openSecondMenu"
                :close-on-content-click="true">
          <template v-slot:activator="{ on }">
            <AlbatrossButton class="dropdown-header body-small"
                   :activation-handler="on"
            >
              <span v-if="getDropdownById(secondDateRange)?.name === 'CUSTOM' && secondCustom.name != null" class="selected-option body-small">
                      {{secondCustom.name}}</span>
              <span v-else-if="getDropdownById(secondDateRange)?.name === 'PERIOD'" class="selected-option body-small">
              {{ getDropdownById(secondDateRange).periodList[secondPeriod].shortLabel}}
              </span>
              <span v-else-if="secondDateRange != null" class="selected-option body-small">
              {{ getDropdownById(secondDateRange)?.friendlyName}}
              </span>
              <span v-else class="placeholder-option body-small">
                Select Date Range
              </span>
              <v-spacer></v-spacer>
              <v-icon color="primary">mdi-menu-down</v-icon>
            </AlbatrossButton>
          </template>
          <div>
            <v-list style="height: 400px; overflow-y:auto">
              <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                <v-list-item-title v-if="item.name === 'PERIOD'">
                  <v-menu open-on-hover location="end" :offset-x="true">
                    <template v-slot:activator="{ on }">
                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                        <v-icon>mdi-chevron-right</v-icon>
                      </span>
                    </template>
                    <div>
                      <v-list style="height: 300px; overflow-y:auto">
                        <v-list-item v-for="(period, index) in item.periodList" @click="secondDateRange = item.id; secondPeriod = index; changeDropdownSelection(2); secondCustom.isActive = (item.name === 'CUSTOM'); openSecondMenu = false">
                          <v-list-item-title class="body-large">
                            {{ period.label }}
                          </v-list-item-title>
                        </v-list-item>
                      </v-list>
                    </div>
                  </v-menu>

                </v-list-item-title>
                <v-list-item-title v-else @click="secondDateRange = item.id; changeDropdownSelection(2); secondCustom.isActive = (item.name === 'CUSTOM');" class="dashboard-menu-option">{{item.friendlyName}}</v-list-item-title>
              </v-list-item>
            </v-list>
          </div>
        </v-menu>
      </template>
      <template #header.actualTotal3="{}" >
        <v-menu data-app left
                offset-y
                :max-height="`calc(100vh - 20px)`"
                class="dropdown-header body-small"
                v-model="openThirdMenu"
                :close-on-content-click="true">
          <template v-slot:activator="{ on }">
            <AlbatrossButton class="dropdown-header body-small"
                   :activation-handler="on"
            >
              <span v-if="getDropdownById(thirdDateRange)?.name === 'CUSTOM' && thirdCustom.name != null" class="selected-option body-small">
                      {{thirdCustom.name}}</span>
              <span v-else-if="getDropdownById(thirdDateRange)?.name === 'PERIOD'" class="selected-option body-small">
              {{ getDropdownById(thirdDateRange).periodList[thirdPeriod].shortLabel}}
              </span>
              <span v-else-if="thirdDateRange != null" class="selected-option body-small">
              {{ getDropdownById(thirdDateRange)?.friendlyName}}
              </span>
              <span v-else class="placeholder-option body-small">
                Select Date Range
              </span>
              <v-spacer></v-spacer>
              <v-icon color="primary">mdi-menu-down</v-icon>
            </AlbatrossButton>
          </template>
          <div>
            <v-list style="height: 400px; overflow-y:auto">
              <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                <v-list-item-title v-if="item.name === 'PERIOD'">
                  <v-menu open-on-hover location="end">
                    <template v-slot:activator="{ on }">
                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option body-large">
                        {{ item.friendlyName }}
                        <v-icon>mdi-chevron-right</v-icon>
                      </span>
                    </template>
                    <div>
                      <v-list style="height: 300px; overflow-y:auto">
                        <v-list-item v-for="(period, index) in item.periodList" @click="thirdDateRange = item.id; thirdPeriod = index; changeDropdownSelection(3); thirdCustom.isActive = (item.name === 'CUSTOM'); openThirdMenu = false">
                          <v-list-item-title class="body-large">
                            {{ period.label }}
                          </v-list-item-title>
                        </v-list-item>
                      </v-list>
                    </div>
                  </v-menu>

                </v-list-item-title>
                <v-list-item-title v-else @click="thirdDateRange = item.id; changeDropdownSelection(3); thirdCustom.isActive = (item.name === 'CUSTOM');" class="dashboard-menu-option">{{item.friendlyName}}</v-list-item-title>
              </v-list-item>
            </v-list>
          </div>
        </v-menu>
      </template>


      <template #item.milestone="{item, index}" id="milestones-col" class="milestone-name-col-td"><span :class="{'label-medium': item.major_milestone}">{{ item.name }}</span></template>
      <template #item.actualTotal="{item, index}" class="milestone-col-td" >
        <v-tooltip bottom>
          <template v-slot:activator="{ on }">
              <span @click="openDrilldown(item, 1)" class="clickable">
                {{ item.company_count?item.company_count:0 }}
                <span v-if="getDropdownById(firstDateRange)?.name != 'ALL_TIME'" v-on="viewTrends ? on : null">
                  <span v-if="viewTrends && item.trend_count>0" class="positive-percentage">+{{item.trend_count/100 | percent}}<v-icon class="positive-trendline">trending_up</v-icon></span>
                  <span v-if="viewTrends && item.trend_count<0" class="negative-percentage">{{item.trend_count/100 | percent}}<v-icon class="negative-trendline">trending_down</v-icon></span>
                  <span v-if="viewTrends && (item.trend_count ===null || item.trend_count===0)" class="neutral-percentage">{{item.trend_count/100 | percent}}<v-icon class="neutral-trendline">trending_flat</v-icon></span>
                </span>
              </span>
          </template>
          <span v-if="viewTrends && item.trend_count>0"> {{Math.abs(item.trend_count)/100 | percent}} more than {{getDropdownById(firstDateRange).trendText}}</span>
          <span v-if="viewTrends && item.trend_count<0"> {{Math.abs(item.trend_count)/100 | percent}} less than {{getDropdownById(firstDateRange).trendText}}</span>
          <span v-if="viewTrends && (item.trend_count ===null || item.trend_count===0)"> Same as {{getDropdownById(firstDateRange).trendText}}</span>
        </v-tooltip>
      </template>

      <template #item.actualTotal2="{item, index}" class="milestone-col-td" v-if="secondDateRange != null && filteredColumn2Values != null && filteredColumn2Values.length > 0">
        <v-tooltip bottom>
          <template v-slot:activator="{ on }">
            <span @click="openDrilldown(item, 2)" class="clickable">
              {{filteredColumn2Values[index].company_count?filteredColumn2Values[index].company_count:0}}
              <span v-if="getDropdownById(secondDateRange)?.name != 'ALL_TIME'" v-on="viewTrends?on:null">
                <span v-if="viewTrends && filteredColumn2Values[index].trend_count>0" class="positive-percentage">+{{filteredColumn2Values[index].trend_count/100 | percent}}<v-icon class="positive-trendline">trending_up</v-icon></span>
                <span v-if="viewTrends && filteredColumn2Values[index].trend_count<0" class="negative-percentage">{{filteredColumn2Values[index].trend_count/100 | percent}}<v-icon class="negative-trendline">trending_down</v-icon></span>
                <span v-if="viewTrends && (filteredColumn2Values[index].trend_count === null || filteredColumn2Values[index].trend_count==0)" class="neutral-percentage">{{filteredColumn2Values[index].trend_count/100 | percent}}<v-icon class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
          </template>
          <span v-if="viewTrends && filteredColumn2Values[index].trend_count>0"> {{Math.abs(filteredColumn2Values[index].trend_count)/100 | percent}} more than {{getDropdownById(secondDateRange).trendText}}</span>
          <span v-if="viewTrends && filteredColumn2Values[index].trend_count<0"> {{Math.abs(filteredColumn2Values[index].trend_count)/100 | percent}} less than {{getDropdownById(secondDateRange).trendText}}</span>
          <span v-if="viewTrends && (filteredColumn2Values[index].trend_count ===null || filteredColumn2Values[index].trend_count===0)"> Same as {{getDropdownById(secondDateRange).trendText}}</span>
        </v-tooltip>
      </template>
      <template #item.actualTotal3="{item, index}" class="milestone-col-td" v-if="thirdDateRange != null && filteredColumn3Values != null && filteredColumn3Values.length > 0">
        <v-tooltip bottom>
          <template v-slot:activator="{ on }">
            <span @click="openDrilldown(item, 3)" class="clickable">
            {{filteredColumn3Values[index]?.company_count ? filteredColumn3Values[index].company_count : 0}}
              <span v-if="getDropdownById(thirdDateRange)?.name != 'ALL_TIME'" v-on="viewTrends?on:null">
                <span v-if="viewTrends && filteredColumn3Values[index].trend_count>0" class="positive-percentage">+{{filteredColumn3Values[index].trend_count/100 | percent}}<v-icon class="positive-trendline">trending_up</v-icon></span>
                <span v-if="viewTrends && filteredColumn3Values[index].trend_count<0" class="negative-percentage">{{filteredColumn3Values[index].trend_count/100 | percent}}<v-icon class="negative-trendline">trending_down</v-icon></span>
                <span v-if="viewTrends && (filteredColumn3Values[index].trend_count === null || filteredColumn3Values[index].trend_count === 0)" class="neutral-percentage">{{filteredColumn3Values[index].trend_count/100 | percent}}<v-icon class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
          </template>
          <span v-if="viewTrends && filteredColumn3Values[index].trend_count>0"> {{Math.abs(filteredColumn3Values[index].trend_count)/100 | percent}} more than {{getDropdownById(thirdDateRange).trendText}}</span>
          <span v-if="viewTrends && filteredColumn3Values[index].trend_count<0"> {{Math.abs(filteredColumn3Values[index].trend_count)/100 | percent}} less than {{getDropdownById(thirdDateRange).trendText}}</span>
          <span v-if="viewTrends && (filteredColumn3Values[index].trend_count ===null || filteredColumn3Values[index].trend_count===0)"> Same as {{getDropdownById(thirdDateRange).trendText}}</span>
        </v-tooltip>
      </template>
    </v-data-table>
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
    <v-dialog v-model="showDrilldown">
      <CompanyDashboardDrilldown v-if="!drilldownIsLoading" :milestone="selectedMilestone"
                                 :load-partners="false"
                                 :drilldown-data="drilldownData"
                                 :start-date="startDate"
                                 :end-date="endDate"
                                 :additionalHeaders="drilldownHeaders"
                                 :close-callback="closeDrilldown">

      </CompanyDashboardDrilldown>
    </v-dialog>
  </v-container>
</template>

<script setup>
import constants from '@/helpers/constants'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import moment from 'moment'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import CompanyDashboardDrilldown from './CompanyDashboardDrilldown.vue'

import {handleHidingGlobalLoader, getRequestWithParams,  logError, postRequest} from '@/helpers/helpers'
import cloneDeep from 'lodash.clonedeep'
import {DateTime} from "luxon";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const showDrilldown = ref(false)
const openFirstPeriodMenu = ref(false)
const openFirstMenu = ref(false)
const openSecondMenu = ref(false)
const openThirdMenu = ref(false)
const selectedMilestone = ref({})
const loadPartners = ref(false)
const dividerForSingleDayTargets = ref(6)
const headers = ref([])
const timezone = ref('US/Mountain')
const selectedDateRange = ref('Today')
const startDate = ref(moment().format('YYYY-MM-DD'))
const startDateColumn2 = ref(moment().format('YYYY-MM-DD'))
const startDateColumn3 = ref(moment().format('YYYY-MM-DD'))
const endDate = ref(moment().format('YYYY-MM-DD'))
const endDateColumn2 = ref(moment().format('YYYY-MM-DD'))
const endDateColumn3 = ref(moment().format('YYYY-MM-DD'))
const weekNum = ref(1)
const currentPeriod = ref(Math.ceil((moment().isoWeek() - (moment().isoWeek()%13 === 0)) / 4))
const dateRanges = ref(['Yesterday', 'Today', 'Tomorrow', 'Current Week', 'Current Period', 'Last Week', 'Last 30 Days', 'Last Period', 'Custom', 'This Month', 'This Quarter', 'This Year', 'All Time'])
const isLoading = ref(true)
const loadingData = ref(false)
const viewTrends = ref(false)
const viewMajorMilestones = ref(false)
const selectingCustomDates = ref(false)
const drilldownIsLoading = ref(true)
const dropdownValues = ref([])
const dashValues = ref([])
const column2Values = ref([])
const column3Values = ref([])
const drilldownData = ref([])
const drilldownHeaders = ref([])
const targetTypeId = ref(null)
const customDate = ref({startDate: "",endDate: "",trendStart: "",trendEnd: ""})
const firstDateRange = ref(2)
const secondDateRange = ref(null)
const thirdDateRange = ref(null)
const previousSelection = ref(2)
const secondColPreviousSelection = ref(null)
const thirdColPreviousSelection = ref(null)
const firstCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const secondCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: "",isActive: false})
const thirdCustom = ref({startDate: "",endDate: "",trendStart: "",trendEnd: ""})
const firstPeriod = ref(null)
const secondPeriod = ref(null)
const thirdPeriod = ref(null)
const singleDateRange = ref(false)
const singleDateRanges = ref(['Yesterday', 'Today', 'Tomorrow'])
const loadTargetsRanges = ref(['Yesterday', 'Today', 'Tomorrow', 'Current Week', 'Last Week'])
const footerProps = ref({showFirstLastPage: !constants.IS_MOBILE,firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',itemsPerPageText: constants.IS_MOBILE ? '' : 'Rows per page:',itemsPerPageOptions: [100, 500, 1000, 2000]})

watch(firstDateRange, (value) => {
  firstCustom.value.isActive = (getDropdownById(value)?.name === 'CUSTOM')
  if(!firstCustom.value.isActive){
    previousSelection.value = value;
  }
})
watch(secondDateRange, (value) => {
  secondCustom.value.isActive = (getDropdownById(value)?.name === 'CUSTOM')
  if(!secondCustom.value.isActive){
    secondColPreviousSelection.value = value;
  }
})
watch(thirdDateRange, (value) => {
  thirdCustom.value.isActive = (getDropdownById(value)?.name === 'CUSTOM')
  if(!thirdCustom.value.isActive){
    thirdColPreviousSelection.value = value;
  }
})


const isBrCorporateUser = computed(() => {
  return userStore.details.companyId === 2
})
const is7oaksAdmin = computed(() => {
  return userStore.isSystemAdmin
})
const filteredDashValues = computed(() => {
  if(viewMajorMilestones.value){
    return dashValues.value.filter(dv => dv.major_milestone)
  }
  return dashValues.value
})
const filteredColumn2Values = computed(() => {
  if(viewMajorMilestones.value){
    return column2Values.value.filter(dv => dv.major_milestone)
  }
  return column2Values.value
})
const filteredColumn3Values = computed(() => {
  if(viewMajorMilestones.value){
    return column3Values.value.filter(dv => dv.major_milestone)
  }
  return column3Values.value
})
const additionalStartWeek = computed( () => {
  if (currentPeriod.value > 9) {
    return 1;
  }
  return 0;
})
const additionalEndWeek = computed( () => {
  if (currentPeriod.value % 3 === 0) {
    return 1;
  }
  return 0;
})
const additionalStartWeekLastPeriod = computed( () => {
  if (currentPeriod.value > 10) {
    return 1;
  }
  return 0;
})
const additionalEndWeekLastPeriod = computed( () => {
  if ((currentPeriod.value -1) % 3 === 0) {
    return 1;
  }
  return 0;
})
const momentStartOfPeriod = computed( () => {
  return moment().startOf('isoWeek').isoWeek((currentPeriod.value) * 4 - 3 + Math.floor((currentPeriod.value - 1) / 3))
})
const startOfPeriod = computed( () => {
  return moment().startOf('isoWeek').isoWeek((currentPeriod.value) * 4 - 3 + Math.floor((currentPeriod.value - 1) / 3)).format('YYYY-MM-DD')
})
const endOfPeriod = computed( () => {
  return moment(momentStartOfPeriod.value).clone().add(3 + additionalEndWeek.value, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
})
const startOfQuarter = computed(() => {
  return moment().startOf('isoWeek').isoWeek(Math.floor((moment().isoWeek()-1) / 13)*13 + 1).format('YYYY-MM-DD')
})
const endOfQuarter = computed(() => {
  return moment().endOf('isoWeek').isoWeek(Math.floor((moment().isoWeek()-1) / 13)*13 + 13).format('YYYY-MM-DD')
})
const startOfWeek = computed( () => {
  return moment().startOf('isoWeek').format('YYYY-MM-DD')
})
const endOfWeek = computed( () => {
  return moment().endOf('week').add(1, 'days').format('YYYY-MM-DD')
})

onMounted(() => {
  headers.value = [
    { text: 'Milestones', value: 'milestone', sortable: false, class: 'milestone-col-th', show: true, width: '25%' },
    { text: 'Today', value: 'actualTotal', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value, width: '25%' },
    { text: 'Today2', value: 'actualTotal2', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value, width: '25%' },
    { text: 'Today3', value: 'actualTotal3', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value, width: '25%' },
  ]

  timezone.value = userStore.timezone.value

  getWeekNum()
  getWeekNum()
  getDropdownValues()
  getDashboardValues()
})

const getDropdownById =(id)=> {
  return dropdownValues.value.find(x => x.id === id)
}
const getClass =(total) => {
  let calcTotal = singleDateRange.value ? total / dividerForSingleDayTargets.value : total
  return calcTotal < 0 ? 'neg_diff' : 'pos_diff'
}
const itemRowBackground =(item)=> {
  return item.major_milestone ? 'shaded-row' : ''
}
const closeDrilldown =() => {
  selectedMilestone.value = {}
  drilldownData.value = []
  loadPartners.value = false
  drilldownIsLoading.value = false
  showDrilldown.value = false
}
const openDrilldown = async(item, column) => {
  if(column === 1){
    if(dropdownValues.value.find(x => x.id === firstDateRange.value).name === 'PERIOD'){
      startDate.value = moment(dropdownValues.value.find(x => x.id === firstDateRange.value).periodList[firstPeriod.value].startDate).format('YYYY-MM-DDTHH:mm:ss');
      endDate.value = moment(dropdownValues.value.find(x => x.id === firstDateRange.value).periodList[firstPeriod.value].endDate).format('YYYY-MM-DDTHH:mm:ss');
    }
    else {
      startDate.value = dropdownValues.value.find(x => x.id === firstDateRange.value).startDate ? dropdownValues.value.find(x => x.id === firstDateRange.value).startDate : moment(firstCustom.value.startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = dropdownValues.value.find(x => x.id === firstDateRange.value).endDate ? dropdownValues.value.find(x => x.id === firstDateRange.value).endDate : moment(firstCustom.value.endDate).format('YYYY-MM-DDTHH:mm:ss')
    }
  }
  else if(column === 2){
    if(dropdownValues.value.find(x => x.id === secondDateRange.value).name === 'PERIOD'){
      startDate.value = moment(dropdownValues.value.find(x => x.id === secondDateRange.value).periodList[secondPeriod.value].startDate).format('YYYY-MM-DDTHH:mm:ss');
      endDate.value = moment(dropdownValues.value.find(x => x.id === secondDateRange.value).periodList[secondPeriod.value].endDate).format('YYYY-MM-DDTHH:mm:ss');
    }
    else {
      startDate.value = dropdownValues.value.find(x => x.id === secondDateRange.value).startDate ? dropdownValues.value.find(x => x.id === secondDateRange.value).startDate : moment(secondCustom.value.startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = dropdownValues.value.find(x => x.id === secondDateRange.value).endDate ? dropdownValues.value.find(x => x.id === secondDateRange.value).endDate : moment(secondCustom.value.endDate).format('YYYY-MM-DDTHH:mm:ss')
    }
  }
  else if(column === 3){
    if(dropdownValues.value.find(x => x.id === thirdDateRange.value).name === 'PERIOD'){
      startDate.value = moment(dropdownValues.value.find(x => x.id === thirdDateRange.value).periodList[thirdPeriod.value].startDate).format('YYYY-MM-DDTHH:mm:ss');
      endDate.value = moment(dropdownValues.value.find(x => x.id === thirdDateRange.value).periodList[thirdPeriod.value].endDate).format('YYYY-MM-DDTHH:mm:ss');
    }
    else {
      startDate.value = dropdownValues.value.find(x => x.id === thirdDateRange.value).startDate ? dropdownValues.value.find(x => x.id === thirdDateRange.value).startDate : moment(thirdCustom.value.startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = dropdownValues.value.find(x => x.id === thirdDateRange.value).endDate ? dropdownValues.value.find(x => x.id === thirdDateRange.value).endDate : moment(thirdCustom.value.endDate).format('YYYY-MM-DDTHH:mm:ss')
    }
  }
  if((moment(endDate.value).diff(moment(startDate.value), 'days')+1) > 100){
    return;
  }
  selectedMilestone.value = item
  await getDrilldownHeaders()
  await getDrilldownData(column)
  showDrilldown.value = true
}
const getDrilldownHeaders = async() => {
  appStore.loading = true
  try {
    const params = {
      milestoneTypeId: selectedMilestone.value.milestone_type_id,
    }

    const {data, status} = await getRequestWithParams('/companyDashboard/drilldownHeaders', {params}, 'blueraven', [])
    drilldownHeaders.value = data;
    drilldownIsLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving drilldown data')
    drilldownIsLoading.value = false
    appStore.loading = false
  }
}
const getDrilldownData = async(column) => {
  //i couldn't get the v-dialog to reload the data every time it opened so i load it here but this is dumb
  drilldownIsLoading.value = true
  appStore.loading = true
  try {
    const params = {
      startDate: startDate.value,
      endDate: endDate.value,
      milestoneTypeId: selectedMilestone.value.milestone_type_id,
    }

    const {data, status} = await getRequestWithParams('/companyDashboard/drilldownData', {params}, 'blueraven', [])
    drilldownData.value = data
    drilldownIsLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving drilldown data')
    drilldownIsLoading.value = false
    appStore.loading = false
  }
}
const getWeekNum = () => {
  for (let i = 0; i <= 3; i++) {
    let startOfWeek = moment(momentStartOfPeriod.value).clone().add(i, 'weeks').startOf('isoWeek').valueOf()
    let endOfWeek = moment(momentStartOfPeriod.value).clone().add(i, 'weeks').endOf('isoWeek').valueOf()

    if (moment().isBetween(startOfWeek, endOfWeek)) {
      weekNum.value = i + 1
    }
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
    case 'Tomorrow':
      startDate.value = moment().startOf('day').add(1, 'days').format('YYYY-MM-DD')
      endDate.value = moment().endOf('day').add(1, 'days').format('YYYY-MM-DD')
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
      startDate.value = moment().startOf('isoWeek').subtract(7, 'days').format('YYYY-MM-DD')
      endDate.value = moment().startOf('isoWeek').subtract(1, 'days').format('YYYY-MM-DD')
      break
    case 'Last 30 Days':
      startDate.value = moment().subtract(30, 'days').format('YYYY-MM-DD')
      endDate.value = moment().format('YYYY-MM-DD')
      break
    case 'Last Period':
      momentStartOfLastPeriod.value = moment().clone().startOf('isoWeek').isoWeek((currentPeriod.value - 1) * 4 - 3 + Math.floor((currentPeriod.value - 2) / 3))
      startDate.value = moment().clone().startOf('isoWeek').isoWeek((currentPeriod.value - 1) * 4 - 3  + Math.floor((currentPeriod.value - 2) / 3)).format('YYYY-MM-DD')
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
      break
    case 'This Quarter':
      startDate.value = startOfQuarter.value
      endDate.value = endOfQuarter.value
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
const resetFilters = async() => {
  viewTrends.value = false;
  firstDateRange.value = 2;
  secondDateRange.value = null;
  thirdDateRange.value = null;
  await getDashboardValues();
}
const changeDropdownSelection = async (dropdown) => {
  if (dropdown === 1) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === firstDateRange.value))
    if (result === null) {
      return null;
    }
    if (result.startDate === null) {
      if (!firstCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          customColumn.value = 1;
          if (firstCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = firstCustom.value.startDate.format('YYYY-MM-DD').toString();
          }
          if (firstCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = firstCustom.value.endDate.format('YYYY-MM-DD').toString();
          }
          selectingCustomDates.value = true;
          return;
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[firstPeriod.value].startDate;
          result.endDate = result.periodList[firstPeriod.value].endDate;
          if (firstPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[firstPeriod.value + 1].startDate;
            result.trendEnd = result.periodList[firstPeriod.value + 1].endDate;
          } else {
            delete result.trendStart;
            delete result.trendEnd;
          }
        }
      } else {
        result = cloneDeep(firstCustom.value);
        resetCustomDate();
        firstCustom.value.isActive = false;
      }
    }
    else if(result.name === 'ALL_TIME'){
      delete result.trendStart;
      delete result.trendEnd;
    }
    dashValues.value = await getDashBoardData(moment(result.startDate).format('YYYY-MM-DD'), moment(result.endDate).format('YYYY-MM-DD'), moment(result.trendStart).format('YYYY-MM-DD'), moment(result.trendEnd).format('YYYY-MM-DD'));
  } else if (dropdown === 2) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === secondDateRange.value))
    if (result === null) {
      return null;
    }
    if (result.startDate === null) {
      if (!secondCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          customColumn.value = 2;
          if (secondCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = secondCustom.value.startDate.format('YYYY-MM-DD').toString();
          }
          if (secondCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = secondCustom.value.endDate.format('YYYY-MM-DD').toString();
          }
          selectingCustomDates.value = true;
          return;
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[secondPeriod.value].startDate;
          result.endDate = result.periodList[secondPeriod.value].endDate;
          if (secondPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[secondPeriod.value + 1].startDate;
            result.trendEnd = result.periodList[secondPeriod.value + 1].endDate;
          } else {
            delete result.trendStart;
            delete result.trendEnd;
          }
        }
      } else {
        result = cloneDeep(secondCustom.value);
        resetCustomDate();
        secondCustom.value.isActive = false;
      }
    }
    else if(result.name === 'ALL_TIME'){
      delete result.trendStart;
      delete result.trendEnd;
    }
    column2Values.value = await getDashBoardData(moment(result.startDate).format('YYYY-MM-DD'), moment(result.endDate).format('YYYY-MM-DD'), moment(result.trendStart).format('YYYY-MM-DD'), moment(result.trendEnd).format('YYYY-MM-DD'));
  } else if (dropdown === 3) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === thirdDateRange.value))
    if (result == null) {
      return null;
    }
    if (result.startDate === null) {
      if (!thirdCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          customColumn.value = 3;
          if (thirdCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = thirdCustom.value.startDate.format('YYYY-MM-DD').toString();
          }
          if (thirdCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = thirdCustom.value.endDate.format('YYYY-MM-DD').toString();
          }
          selectingCustomDates.value = true;
          return;
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[thirdPeriod.value].startDate;
          result.endDate = result.periodList[thirdPeriod.value].endDate;
          if (thirdPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[thirdPeriod.value + 1].startDate;
            result.trendEnd = result.periodList[thirdPeriod.value + 1].endDate;
          } else {
            delete result.trendStart;
            delete result.trendEnd;
          }
        }
      } else {
        result = cloneDeep(thirdCustom.value);
        resetCustomDate();
      }
    }
    else if(result.name === 'ALL_TIME'){
      delete result.trendStart;
      delete result.trendEnd;
    }
    column3Values.value = await getDashBoardData(moment(result.startDate).format('YYYY-MM-DD'), moment(result.endDate).format('YYYY-MM-DD'), moment(result.trendStart).format('YYYY-MM-DD'), moment(result.trendEnd).format('YYYY-MM-DD'));
  }
}
const resetCustomDate = () => {
  customDate.value.startDate = "";
  customDate.value.endDate = "";
  customDate.value.trendStart = "";
  customDate.value.trendEnd = "";
}
const cancelCustomDialogue = async() => {
  if(customColumn.value === 1) {
    firstDateRange.value = previousSelection.value
  }
  else if(customColumn.value === 2) {
    secondDateRange.value = secondColPreviousSelection.value
  }
  else if(customColumn.value === 3) {
    thirdDateRange.value = thirdColPreviousSelection.value
  }
}
const applyCustomDates = async()=> {
  if(customColumn.value === 1) {
    firstCustom.value.startDate = moment(customDate.value.startDate);
    firstCustom.value.endDate = moment(customDate.value.endDate);
    let dateDiff = firstCustom.value.endDate.diff(firstCustom.value.startDate, 'days');
    firstCustom.value.trendEnd = firstCustom.value.startDate.clone().subtract(1, 'days');
    firstCustom.value.trendStart = firstCustom.value.trendEnd.clone().subtract(dateDiff, 'days');
    getDropdownById(firstDateRange.value).trendText = moment(firstCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(firstCustom.value.trendEnd).format('MM/DD/YYYY');
    firstCustom.value.name=moment(firstCustom.value.startDate).format('MM/DD/YY') + '-' + moment(firstCustom.value.endDate).format('MM/DD/YY');
  }
  else if(customColumn.value === 2){
    secondCustom.value.startDate = moment(customDate.value.startDate);
    secondCustom.value.endDate = moment(customDate.value.endDate);
    let dateDiff = secondCustom.value.endDate.diff(secondCustom.value.startDate, 'days');
    secondCustom.value.trendEnd = secondCustom.value.startDate.clone().subtract(1, 'days');
    secondCustom.value.trendStart = secondCustom.value.trendEnd.clone().subtract(dateDiff, 'days');
    getDropdownById(secondDateRange.value).trendText = moment(secondCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(secondCustom.value.trendEnd).format('MM/DD/YYYY');
    secondCustom.value.name=moment(secondCustom.value.startDate).format('MM/DD/YY') + '-' + moment(secondCustom.value.endDate).format('MM/DD/YY');
  }
  else if(customColumn.value === 3){
    thirdCustom.value.startDate = moment(customDate.value.startDate);
    thirdCustom.value.endDate = moment(customDate.value.endDate);
    let dateDiff = thirdCustom.value.endDate.diff(thirdCustom.value.startDate, 'days');
    thirdCustom.value.trendEnd = thirdCustom.value.startDate.clone().subtract(1, 'days');
    thirdCustom.value.trendStart = thirdCustom.value.trendEnd.clone().subtract(dateDiff, 'days');
    getDropdownById(thirdDateRange.value).trendText = moment(thirdCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(thirdCustom.value.trendEnd).format('MM/DD/YYYY');
    thirdCustom.value.name=moment(thirdCustom.value.startDate).format('MM/DD/YY') + '-' + moment(thirdCustom.value.endDate).format('MM/DD/YY');
  }

  await getDashboardValues();
}
const exportCsv = async () => {
  appStore.loading = true
  try {
    let filename = 'CompanyDashboard.csv'
    let csvData = ' , '
    if(dropdownValues.value.find(x => x.id === firstDateRange.value).name==='PERIOD'){
      csvData += dropdownValues.value.find(x => x.id === firstDateRange.value).periodList[firstPeriod.value].shortLabel;
    }
    else
    {
      csvData += ((dropdownValues.value.find(x => x.id === firstDateRange.value).name === 'CUSTOM') ? firstCustom.value.name : dropdownValues.value.find(x => x.id === firstDateRange.value).friendlyName);
    }
    if(viewTrends.value){
      csvData += ', ' +  'Trend 1'
    }
    if(secondDateRange.value){
      if(dropdownValues.value.find(x => x.id === secondDateRange.value).name==='PERIOD'){
        csvData += ' , ' + dropdownValues.value.find(x => x.id === secondDateRange.value).periodList[secondPeriod.value].shortLabel;
      }
      else
      {
        csvData += ', ' + ((dropdownValues.value.find(x => x.id === secondDateRange.value).name === 'CUSTOM') ? secondCustom.value.name : dropdownValues.value.find(x => x.id === secondDateRange.value).friendlyName);
      }
      if(viewTrends.value){
        csvData += ', ' +  'Trend 2'
      }
    }
    if(thirdDateRange.value){
      if(dropdownValues.value.find(x => x.id === thirdDateRange.value).name==='PERIOD'){
        csvData += ' , ' + dropdownValues.value.find(x => x.id === thirdDateRange.value).periodList[thirdPeriod.value].shortLabel;
      }
      else
      {
        csvData += ', ' + ((dropdownValues.value.find(x => x.id === thirdDateRange.value).name === 'CUSTOM') ? thirdCustom.value.name : dropdownValues.value.find(x => x.id === thirdDateRange.value).friendlyName);
      }
      if(viewTrends.value){
        csvData += ', ' +  'Trend 3'
      }
    }
    csvData += '\n';

    dashValues.value.forEach((p, i) => {
      if (p.major_milestone || !viewMajorMilestones.value) {
        csvData += p.name + ',' + (p.company_count ? p.company_count : 0);
        if (viewTrends.value) {
          csvData += ', ' + (p.trend_count ? p.trend_count : 0) + '%';
        }
        if (secondDateRange.value) {
          csvData += ', ' + (column2Values.value[i].company_count ? column2Values.value[i].company_count : 0)
          if (viewTrends.value) {
            csvData += ', ' + (column2Values.value[i].trend_count ? column2Values.value[i].trend_count : 0) + '%';
          }
        }
        if (thirdDateRange.value) {
          csvData += ', ' + (column3Values.value[i].company_count ? column3Values.value[i].company_count : 0)
          if (viewTrends.value) {
            csvData += ', ' + (column3Values.value[i].trend_count ? column3Values.value[i].trend_count : 0) + '%';
          }
        }
        csvData += '\n';
      }
    })


    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Residual Review')

    appStore.loading = false
  }
}
const getDashBoardData = async(startDate, endDate, trendStart, trendEnd)=> {
  try {
    // appStore.loading = true

    let params = {
      startDate: startDate,
      endDate: endDate,
      targetTypeId: targetTypeId.value,
      trendStart: trendStart,
      trendEnd: trendEnd
    }

    const {data, status} = await getRequestWithParams('/companyDashboard/dashboardValues', {params}, 'blueraven', [])
    return data;

    handleHidingGlobalLoader( status)

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving data')
    isLoading.value = false
    appStore.loading = false
  }
  return null;
}

const getDashboardValues = async (dateWasManuallyEntered) => {
  if (dateWasManuallyEntered) {
    selectedDateRange.value = 'Custom'
  } else {
    setDateRange()
    if (selectedDateRange.value === 'Custom') return // wait for the user to enter a custom date
  }

  singleDateRange.value = singleDateRanges.value.includes(selectedDateRange.value)
  targetTypeId.value = singleDateRange.value ? 1 :
      loadTargetsRanges.value.includes(selectedDateRange.value) ? 2 : null

      loadingData.value = true;
      if(dropdownValues.value != null && dropdownValues.value.length > 0){
        await changeDropdownSelection(1);
      }
      else {
        dashValues.value = await getDashBoardData(startDate.value, endDate.value, moment(startDate.value).subtract(1, "days").format('YYYY-MM-DD'), moment(endDate.value).subtract(1, "days").format('YYYY-MM-DD'));
      }
      if(secondDateRange.value != null) {
        await changeDropdownSelection(2);

  }

  if(thirdDateRange.value != null){
    await changeDropdownSelection(3);
  }

  // startDate.value = moment().subtract(30, "days").format('YYYY-MM-DD');
  // startDateColumn2.value = moment().subtract(60, "days").format('YYYY-MM-DD');
  // startDateColumn3.value = moment().subtract(90, "days").format('YYYY-MM-DD');

  loadingData.value = false;
}
const getDropdownValues = async() => {
  try {
    appStore.loading = true

    const params = {
      today: moment().format('YYYY-MM-DD')
    }

    const {data, status} = await getRequestWithParams('/companyDashboard/dropdownValues', {params}, 'blueraven', [])
    dropdownValues.value = data;
    isLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving data')
    isLoading.value = false
    appStore.loading = false
  }


}
</script>

<style lang="scss" scoped>
.v-list-item__title.dashboard-menu-option{
  font-family: lato;
  font-weight: 400;
  line-height: 1.563rem;
  font-size: 1rem;
}
.dashboard-menu-option{
  display: flex;
  min-height: 48px;
  align-items: center!important;
  padding-right: 16px;
  padding-left: 16px;
}
.selected-option{
  color: var(--v-primary-base) !important;
}
.placeholder-option{
  color: var(--v-grey-darken2) !important;
}
.dropdown-header{
  border: 1px solid var(--v-grey-lighten1);
  text-transform: unset !important;
  background-color: transparent !important;
  box-shadow: none;
  height: 40px !important;
  width: 210px;
  justify-content: left;
}
.v-data-table{
  overflow-x: auto;
}
.dashboard-header{
  padding-left: 20px;
  padding-right: 16px;
  font-weight: bold;
}
.checkbox-container{
  padding-right: 12px;
}
.export-button{
  display: flex;
  margin: auto 50px auto auto;
  color: #1F3C73;
}
.export-icon{
  color: #1F3C73;
}
.positive-percentage{
  color: green;
}
.negative-percentage{
  padding-left: 4px;
  color: red;
}
.negative-trendline{
  color: red;
}
.positive-percentage{
  padding-left: 4px;
  color: green;
}
.positive-trendline{
  color: green;
}
.neutral-percentage{
  padding-left: 4px;
  color: grey;
}
.neutral-trendline{
  color: grey;
}
.date-range-dropdown {
  min-width: 200px;
}

#company-dash-container {
  overflow: auto;
}


//.v-select ::v-deep .v-select__selection {
//  color: var(--v-primaryText-base) !important;
//}

.company-dashboard-header{
  margin-left: 28px;
  margin-right: 12px;
}



.light-blue-row {
  background-color: var(--v-primary-lighten9) !important;

  //&:hover {
  //  background-color: var(--v-primary-lighten9);
  //}
}

.v-card__title {
  display: flex;
  flex-flow: row nowrap;
  justify-content: space-between;
  align-items: center;
}


@media (min-width: 600px){
  .filter-bar-mini{
    display: none;
  }
}
@media(max-width: 600px){
  .filter-bar{
    display: none;
  }
  .checkbox-container-mini{
    padding-left: 20px;
  }

  #company-dash-container {
    overflow: auto;
    padding: 4px;
  }
}
</style>
<style lang="scss">
#company-dash-table > div > table > thead > tr > th > div > div > div.v-input__slot > div.v-select__slot > div.v-select__selections > div, .selected-option{
  color: var(--v-primary-base) !important;
}

#company-dash-table > div > table > thead > tr > th {
  z-index: 1 !important;
  height: 68px;
}

#company-dash-table > div > table > thead > tr > th.text-start.milestone-col-th,
#company-dash-table > div > table > tbody > tr > td.text-start{
  position: sticky;
  left: 0;
  z-index: 2 !important;
  background-color: white;
}

#company-dash-table > div > table > thead > tr:hover,
#company-dash-table > div > table > tbody > tr:hover{
  background-color: transparent;
}

#company-dash-table > div > table > tbody > tr.shaded-row > td.text-start{
  background-color: var(--v-primary-lighten9);
}

</style>

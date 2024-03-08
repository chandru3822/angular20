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
        <a class="export-button" @click="exportCsv"><v-icon class="export-icon">mdi-tray-arrow-down</v-icon>Export</a>
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
            <v-btn class="dropdown-header body-small"
                   v-on="on"
            >
              <span v-if="getDropdownById(firstDateRange)?.name === 'CUSTOM' && firstCustom.name != null" class="selected-option body-small">
                      {{firstCustom.name}}</span>
              <span v-else-if="getDropdownById(firstDateRange)?.name === 'PERIOD'" class="selected-option body-small">
              {{ getDropdownById(firstDateRange).periodList[firstPeriod].shortLabel}}
              </span>
              <span v-else class="selected-option body-small">
              {{ getDropdownById(firstDateRange)?.friendlyName}}
              </span>
              <v-spacer></v-spacer>
              <v-icon>mdi-menu-down</v-icon>
            </v-btn>
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
            <v-btn class="dropdown-header body-small"
                   v-on="on"
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
              <v-icon>mdi-menu-down</v-icon>
            </v-btn>
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
            <v-btn class="dropdown-header body-small"
                   v-on="on"
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
              <v-icon>mdi-menu-down</v-icon>
            </v-btn>
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
              <span @click="openDrilldown(item, 1)">
              {{ item.company_count?item.company_count:0 }}
              <span v-if="getDropdownById(firstDateRange)?.name != 'ALL_TIME'" v-on="viewTrends?on:null">
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
            <span @click="openDrilldown(item, 2)">
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
            <span @click="openDrilldown(item, 3)">
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

<script>
import constants from '@/helpers/constants'
import moment from 'moment'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import Snackbar from '@/components/Snackbar.vue'
import CompanyDashboardDrilldown from './CompanyDashboardDrilldown.vue'
import { AppMutations } from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequestWithParams, getSnackbar, logError, postRequest} from '@/helpers/helpers'
import cloneDeep from 'lodash.clonedeep'
import {DateTime} from "luxon";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import { mapStores } from 'pinia'
import { useUserStore } from '@/stores/UserStorePinia.js'


export default {
  name: 'CompanyDashboard',
  components: {
    DatetimePickerInput,
    CompanyDashboardDrilldown,
    Snackbar,
    ConfirmationDialog
  },
  data () {
    return {
      snackbar: {},
      constants,
      showDrilldown: false,
      openFirstPeriodMenu: false,
      openFirstMenu: false,
      openSecondMenu: false,
      openThirdMenu: false,
      selectedMilestone: {},
      loadPartners: false,
      dividerForSingleDayTargets: 6,
      headers: [],
      timezone: 'US/Mountain',
      selectedDateRange: 'Today',
      startDate: moment().format('YYYY-MM-DD'),
      startDateColumn2: moment().format('YYYY-MM-DD'),
      startDateColumn3: moment().format('YYYY-MM-DD'),
      endDate: moment().format('YYYY-MM-DD'),
      endDateColumn2: moment().format('YYYY-MM-DD'),
      endDateColumn3: moment().format('YYYY-MM-DD'),
      weekNum: 1,
      currentPeriod: Math.ceil((moment().isoWeek() - (moment().isoWeek()%13 === 0)) / 4),
      dateRanges: ['Yesterday', 'Today', 'Tomorrow', 'Current Week', 'Current Period', 'Last Week', 'Last 30 Days', 'Last Period', 'Custom', 'This Month', 'This Quarter', 'This Year', 'All Time'],
      isLoading: true,
      loadingData: false,
      viewTrends: false,
      viewMajorMilestones: false,
      selectingCustomDates: false,
      drilldownIsLoading: true,
      dropdownValues: [],
      dashValues: [],
      column2Values: [],
      column3Values: [],
      drilldownData: [],
      drilldownHeaders: [],
      customDate: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: ""
      },
      firstDateRange: 2,
      secondDateRange: null,
      thirdDateRange: null,
      previousSelection: 2,
      secondColPreviousSelection: null,
      thirdColPreviousSelection: null,
      firstCustom: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: "",
        isActive: false
      },
      secondCustom: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: "",
        isActive: false
      },
      thirdCustom: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: ""
      },
      firstPeriod: null,
      secondPeriod: null,
      thirdPeriod: null,
      singleDateRange: false,
      singleDateRanges: ['Yesterday', 'Today', 'Tomorrow'],
      loadTargetsRanges:  ['Yesterday', 'Today', 'Tomorrow', 'Current Week', 'Last Week'],
      footerProps: {
        showFirstLastPage: !constants.IS_MOBILE,
        firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
        lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
        itemsPerPageText: constants.IS_MOBILE ? '' : 'Rows per page:',
        itemsPerPageOptions: [100, 500, 1000, 2000]
      }
    }
  },
  watch: {
    firstDateRange(value) {
      this.firstCustom.isActive = (this.getDropdownById(value)?.name === 'CUSTOM')
      if(!this.firstCustom.isActive){
        this.previousSelection = value;
      }
    },
    secondDateRange(value) {
      this.secondCustom.isActive = (this.getDropdownById(value)?.name === 'CUSTOM')
      if(!this.secondCustom.isActive){
        this.secondColPreviousSelection = value;
      }
    },
    thirdDateRange(value) {
      this.thirdCustom.isActive = (this.getDropdownById(value)?.name === 'CUSTOM')
      if(!this.thirdCustom.isActive){
        this.thirdColPreviousSelection = value;
      }
    }
  },
  computed: {
    ...mapStores(useUserStore),
    isBrCorporateUser() {
      return this.userStore.details.companyId === 2
    },
    is7oaksAdmin() {
      return this.userStore.isSystemAdmin
    },
    // visibleHeaders () {
    //   return this.headers.filter(header => header.show === true)
    // },
    filteredDashValues(){
      if(this.viewMajorMilestones){
        return this.dashValues.filter(dv => dv.major_milestone)
      }
      return this.dashValues
    },
    filteredColumn2Values(){
      if(this.viewMajorMilestones){
        return this.column2Values.filter(dv => dv.major_milestone)
      }
      return this.column2Values
    },
    filteredColumn3Values(){
      if(this.viewMajorMilestones){
        return this.column3Values.filter(dv => dv.major_milestone)
      }
      return this.column3Values
    },
    additionalStartWeek () {
      if (this.currentPeriod > 9) {
        return 1;
      }
      return 0;
    },
    additionalEndWeek () {
      if (this.currentPeriod % 3 === 0) {
        return 1;
      }
      return 0;
    },
    additionalStartWeekLastPeriod () {
      if (this.currentPeriod > 10) {
        return 1;
      }
      return 0;
    },
    additionalEndWeekLastPeriod () {
      if ((this.currentPeriod -1) % 3 === 0) {
        return 1;
      }
      return 0;
    },
    momentStartOfPeriod () {
      return moment().startOf('isoWeek').isoWeek((this.currentPeriod) * 4 - 3 + Math.floor((this.currentPeriod - 1) / 3))
    },
    startOfPeriod () {
      return moment().startOf('isoWeek').isoWeek((this.currentPeriod) * 4 - 3 + Math.floor((this.currentPeriod - 1) / 3)).format('YYYY-MM-DD')
    },
    endOfPeriod () {
      return moment(this.momentStartOfPeriod).clone().add(3 + this.additionalEndWeek, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
      return moment(this.momentStartOfPeriod).clone().add(3 + this.additionalEndWeek, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
    },
    startOfQuarter(){
      return moment().startOf('isoWeek').isoWeek(Math.floor((moment().isoWeek()-1) / 13)*13 + 1).format('YYYY-MM-DD')
    },
    endOfQuarter(){
      return moment().endOf('isoWeek').isoWeek(Math.floor((moment().isoWeek()-1) / 13)*13 + 13).format('YYYY-MM-DD')
    },
    startOfWeek () {
      return moment().startOf('isoWeek').format('YYYY-MM-DD')
    },
    endOfWeek () {
      return moment().endOf('week').add(1, 'days').format('YYYY-MM-DD')
    }
  },
  methods: {
    getDropdownById(id){
      return this.dropdownValues.find(x => x.id === id)
    },
    getClass(total) {
      let calcTotal = this.singleDateRange ? total / this.dividerForSingleDayTargets : total
      return calcTotal < 0 ? 'neg_diff' : 'pos_diff'
    },
    itemRowBackground(item){
      return item.major_milestone ? 'shaded-row' : ''
    },
    closeDrilldown() {
      this.selectedMilestone = {}
      this.drilldownData = []
      this.loadPartners = false
      this.drilldownIsLoading = false
      this.showDrilldown = false
    },
    async openDrilldown(item, column) {
      if(column === 1){
        if(this.dropdownValues.find(x => x.id === this.firstDateRange).name === 'PERIOD'){
          this.startDate = moment(this.dropdownValues.find(x => x.id === this.firstDateRange).periodList[this.firstPeriod].startDate).format('YYYY-MM-DDTHH:mm:ss');
          this.endDate = moment(this.dropdownValues.find(x => x.id === this.firstDateRange).periodList[this.firstPeriod].endDate).format('YYYY-MM-DDTHH:mm:ss');
        }
        else {
          this.startDate = this.dropdownValues.find(x => x.id === this.firstDateRange).startDate ? this.dropdownValues.find(x => x.id === this.firstDateRange).startDate : moment(this.firstCustom.startDate).format('YYYY-MM-DDTHH:mm:ss')
          this.endDate = this.dropdownValues.find(x => x.id === this.firstDateRange).endDate ? this.dropdownValues.find(x => x.id === this.firstDateRange).endDate : moment(this.firstCustom.endDate).format('YYYY-MM-DDTHH:mm:ss')
        }
      }
      else if(column === 2){
        if(this.dropdownValues.find(x => x.id === this.secondDateRange).name === 'PERIOD'){
          this.startDate = moment(this.dropdownValues.find(x => x.id === this.secondDateRange).periodList[this.secondPeriod].startDate).format('YYYY-MM-DDTHH:mm:ss');
          this.endDate = moment(this.dropdownValues.find(x => x.id === this.secondDateRange).periodList[this.secondPeriod].endDate).format('YYYY-MM-DDTHH:mm:ss');
        }
        else {
          this.startDate = this.dropdownValues.find(x => x.id === this.secondDateRange).startDate ? this.dropdownValues.find(x => x.id === this.secondDateRange).startDate : moment(this.secondCustom.startDate).format('YYYY-MM-DDTHH:mm:ss')
          this.endDate = this.dropdownValues.find(x => x.id === this.secondDateRange).endDate ? this.dropdownValues.find(x => x.id === this.secondDateRange).endDate : moment(this.secondCustom.endDate).format('YYYY-MM-DDTHH:mm:ss')
        }
      }
      else if(column === 3){
        if(this.dropdownValues.find(x => x.id === this.thirdDateRange).name === 'PERIOD'){
          this.startDate = moment(this.dropdownValues.find(x => x.id === this.thirdDateRange).periodList[this.thirdPeriod].startDate).format('YYYY-MM-DDTHH:mm:ss');
          this.endDate = moment(this.dropdownValues.find(x => x.id === this.thirdDateRange).periodList[this.thirdPeriod].endDate).format('YYYY-MM-DDTHH:mm:ss');
        }
        else {
          this.startDate = this.dropdownValues.find(x => x.id === this.thirdDateRange).startDate ? this.dropdownValues.find(x => x.id === this.thirdDateRange).startDate : moment(this.thirdCustom.startDate).format('YYYY-MM-DDTHH:mm:ss')
          this.endDate = this.dropdownValues.find(x => x.id === this.thirdDateRange).endDate ? this.dropdownValues.find(x => x.id === this.thirdDateRange).endDate : moment(this.thirdCustom.endDate).format('YYYY-MM-DDTHH:mm:ss')
        }
      }
      if((moment(this.endDate).diff(moment(this.startDate), 'days')+1) > 100){
        return;
      }
      this.selectedMilestone = item
      await this.getDrilldownHeaders()
      await this.getDrilldownData(column)
      this.showDrilldown = true
    },
    async getDrilldownHeaders() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {
          milestoneTypeId: this.selectedMilestone.milestone_type_id,
        }

        const {data, status} = await getRequestWithParams('/companyDashboard/drilldownHeaders', {params}, 'blueraven', [])
        this.drilldownHeaders = data;
        this.drilldownIsLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving drilldown data')
        this.drilldownIsLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getDrilldownData(column) {
      //i couldn't get the v-dialog to reload the data every time it opened so i load it here but this is dumb
      this.drilldownIsLoading = true
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {
          startDate: this.startDate,
          endDate: this.endDate,
          milestoneTypeId: this.selectedMilestone.milestone_type_id,
        }

        const {data, status} = await getRequestWithParams('/companyDashboard/drilldownData', {params}, 'blueraven', [])
        this.drilldownData = data
        this.drilldownIsLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving drilldown data')
        this.drilldownIsLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getWeekNum () {
      for (let i = 0; i <= 3; i++) {
        let startOfWeek = moment(this.momentStartOfPeriod).clone().add(i, 'weeks').startOf('isoWeek').valueOf()
        let endOfWeek = moment(this.momentStartOfPeriod).clone().add(i, 'weeks').endOf('isoWeek').valueOf()

        if (moment().isBetween(startOfWeek, endOfWeek)) {
          this.weekNum = i + 1
        }
      }
    },

    setDateRange: function () {
      switch (this.selectedDateRange) {
        case 'Yesterday':
          this.startDate = moment().startOf('day').add(-1, 'days').format('YYYY-MM-DD')
          this.endDate = moment().endOf('day').add(-1, 'days').format('YYYY-MM-DD')
          break
        case 'Today':
          this.startDate = moment().startOf('day').format('YYYY-MM-DD')
          this.endDate = moment().endOf('day').format('YYYY-MM-DD')
          break
        case 'Tomorrow':
          this.startDate = moment().startOf('day').add(1, 'days').format('YYYY-MM-DD')
          this.endDate = moment().endOf('day').add(1, 'days').format('YYYY-MM-DD')
          break
        case 'Current Week':
          this.startDate = this.startOfWeek
          this.endDate = this.endOfWeek
          break
        case 'Current Period':
          this.startDate = this.startOfPeriod
          this.endDate = this.endOfPeriod
          break
        case 'Last Week':
          this.startDate = moment().startOf('isoWeek').subtract(7, 'days').format('YYYY-MM-DD')
          this.endDate = moment().startOf('isoWeek').subtract(1, 'days').format('YYYY-MM-DD')
          break
        case 'Last 30 Days':
          this.startDate = moment().subtract(30, 'days').format('YYYY-MM-DD')
          this.endDate = moment().format('YYYY-MM-DD')
          break
        case 'Last Period':
          this.momentStartOfLastPeriod = moment().clone().startOf('isoWeek').isoWeek((this.currentPeriod - 1) * 4 - 3 + Math.floor((this.currentPeriod - 2) / 3))
          this.startDate = moment().clone().startOf('isoWeek').isoWeek((this.currentPeriod - 1) * 4 - 3  + Math.floor((this.currentPeriod - 2) / 3)).format('YYYY-MM-DD')
          this.endDate = moment(this.momentStartOfLastPeriod).clone().add(3 + this.additionalEndWeekLastPeriod, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
          break
        case 'Custom':
          this.startDate = moment(this.startDate).format('YYYY-MM-DD')
          this.endDate = moment(this.startDate).format('YYYY-MM-DD')
          break
        case 'This Month':
          this.startDate = moment().startOf('month').format('YYYY-MM-DD')
          this.endDate = moment().endOf('month').format('YYYY-MM-DD')
          break
        case 'This Year':
          this.startDate = moment().startOf('year').format('YYYY-MM-DD')
          this.endDate = moment().format('YYYY-MM-DD')
          break
        case 'This Quarter':
          this.startDate = this.startOfQuarter
          this.endDate = this.endOfQuarter
          break;
        case 'All Time':
          this.startDate = moment('2000-01-01').format('YYYY-MM-DD')
          this.endDate = moment().format('YYYY-MM-DD')
          break
        default:
          this.startDate = this.startOfWeek
          this.endDate = this.endOfWeek
          break
      }
    },
    async resetFilters(){
      this.viewTrends = false;
      this.firstDateRange = 2;
      this.secondDateRange = null;
      this.thirdDateRange = null;
      await this.getDashboardValues();
    },
    changeDropdownSelection: async function (dropdown) {
      if (dropdown === 1) {
        let result = cloneDeep(this.dropdownValues.find(x => x.id === this.firstDateRange))
        if (result === null) {
          return null;
        }
        if (result.startDate === null) {
          if (!this.firstCustom.isActive) {
            if (result.name === 'CUSTOM') {
              this.customColumn = 1;
              if (this.firstCustom.startDate.toString().length > 0) {
                this.customDate.startDate = this.firstCustom.startDate.format('YYYY-MM-DD').toString();
              }
              if (this.firstCustom.endDate.toString().length > 0) {
                this.customDate.endDate = this.firstCustom.endDate.format('YYYY-MM-DD').toString();
              }
              this.selectingCustomDates = true;
              return;
            } else if (result.name === 'PERIOD') {
              result.startDate = result.periodList[this.firstPeriod].startDate;
              result.endDate = result.periodList[this.firstPeriod].endDate;
              if (this.firstPeriod != result.periodList.length - 1) {
                result.trendStart = result.periodList[this.firstPeriod + 1].startDate;
                result.trendEnd = result.periodList[this.firstPeriod + 1].endDate;
              } else {
                delete result.trendStart;
                delete result.trendEnd;
              }
            }
          } else {
            result = cloneDeep(this.firstCustom);
            this.resetCustomDate();
            this.firstCustom.isActive = false;
          }
        }
        else if(result.name === 'ALL_TIME'){
          delete result.trendStart;
          delete result.trendEnd;
        }
        this.dashValues = await this.getDashBoardData(moment(result.startDate).format('YYYY-MM-DD'), moment(result.endDate).format('YYYY-MM-DD'), moment(result.trendStart).format('YYYY-MM-DD'), moment(result.trendEnd).format('YYYY-MM-DD'));
      } else if (dropdown === 2) {
        let result = cloneDeep(this.dropdownValues.find(x => x.id === this.secondDateRange))
        if (result === null) {
          return null;
        }
        if (result.startDate === null) {
          if (!this.secondCustom.isActive) {
            if (result.name === 'CUSTOM') {
              this.customColumn = 2;
              if (this.secondCustom.startDate.toString().length > 0) {
                this.customDate.startDate = this.secondCustom.startDate.format('YYYY-MM-DD').toString();
              }
              if (this.secondCustom.endDate.toString().length > 0) {
                this.customDate.endDate = this.secondCustom.endDate.format('YYYY-MM-DD').toString();
              }
              this.selectingCustomDates = true;
              return;
            } else if (result.name === 'PERIOD') {
              result.startDate = result.periodList[this.secondPeriod].startDate;
              result.endDate = result.periodList[this.secondPeriod].endDate;
              if (this.secondPeriod != result.periodList.length - 1) {
                result.trendStart = result.periodList[this.secondPeriod + 1].startDate;
                result.trendEnd = result.periodList[this.secondPeriod + 1].endDate;
              } else {
                delete result.trendStart;
                delete result.trendEnd;
              }
            }
          } else {
            result = cloneDeep(this.secondCustom);
            this.resetCustomDate();
            this.secondCustom.isActive = false;
          }
        }
        else if(result.name === 'ALL_TIME'){
          delete result.trendStart;
          delete result.trendEnd;
        }
        this.column2Values = await this.getDashBoardData(moment(result.startDate).format('YYYY-MM-DD'), moment(result.endDate).format('YYYY-MM-DD'), moment(result.trendStart).format('YYYY-MM-DD'), moment(result.trendEnd).format('YYYY-MM-DD'));
      } else if (dropdown === 3) {
        let result = cloneDeep(this.dropdownValues.find(x => x.id === this.thirdDateRange))
        if (result == null) {
          return null;
        }
        if (result.startDate === null) {
          if (!this.thirdCustom.isActive) {
            if (result.name === 'CUSTOM') {
              this.customColumn = 3;
              if (this.thirdCustom.startDate.toString().length > 0) {
                this.customDate.startDate = this.thirdCustom.startDate.format('YYYY-MM-DD').toString();
              }
              if (this.thirdCustom.endDate.toString().length > 0) {
                this.customDate.endDate = this.thirdCustom.endDate.format('YYYY-MM-DD').toString();
              }
              this.selectingCustomDates = true;
              return;
            } else if (result.name === 'PERIOD') {
              result.startDate = result.periodList[this.thirdPeriod].startDate;
              result.endDate = result.periodList[this.thirdPeriod].endDate;
              if (this.thirdPeriod != result.periodList.length - 1) {
                result.trendStart = result.periodList[this.thirdPeriod + 1].startDate;
                result.trendEnd = result.periodList[this.thirdPeriod + 1].endDate;
              } else {
                delete result.trendStart;
                delete result.trendEnd;
              }
            }
          } else {
            result = cloneDeep(this.thirdCustom);
            this.resetCustomDate();
          }
        }
        else if(result.name === 'ALL_TIME'){
          delete result.trendStart;
          delete result.trendEnd;
        }
        this.column3Values = await this.getDashBoardData(moment(result.startDate).format('YYYY-MM-DD'), moment(result.endDate).format('YYYY-MM-DD'), moment(result.trendStart).format('YYYY-MM-DD'), moment(result.trendEnd).format('YYYY-MM-DD'));
      }
    },
    resetCustomDate(){
      this.customDate.startDate = "";
      this.customDate.endDate = "";
      this.customDate.trendStart = "";
      this.customDate.trendEnd = "";
    },
    async cancelCustomDialogue() {
      if(this.customColumn === 1) {
        this.firstDateRange = this.previousSelection
      }
      else if(this.customColumn === 2) {
        this.secondDateRange = this.secondColPreviousSelection
      }
      else if(this.customColumn === 3) {
        this.thirdDateRange = this.thirdColPreviousSelection
      }
    },
    async applyCustomDates(){
      if(this.customColumn === 1) {
        this.firstCustom.startDate = moment(this.customDate.startDate);
        this.firstCustom.endDate = moment(this.customDate.endDate);
        let dateDiff = this.firstCustom.endDate.diff(this.firstCustom.startDate, 'days');
        this.firstCustom.trendEnd = this.firstCustom.startDate.clone().subtract(1, 'days');
        this.firstCustom.trendStart = this.firstCustom.trendEnd.clone().subtract(dateDiff, 'days');
        this.getDropdownById(this.firstDateRange).trendText = moment(this.firstCustom.trendStart).format('MM/DD/YYYY') + ' - ' + moment(this.firstCustom.trendEnd).format('MM/DD/YYYY');
        this.firstCustom.name=moment(this.firstCustom.startDate).format('MM/DD/YY') + '-' + moment(this.firstCustom.endDate).format('MM/DD/YY');
      }
      else if(this.customColumn === 2){
        this.secondCustom.startDate = moment(this.customDate.startDate);
        this.secondCustom.endDate = moment(this.customDate.endDate);
        let dateDiff = this.secondCustom.endDate.diff(this.secondCustom.startDate, 'days');
        this.secondCustom.trendEnd = this.secondCustom.startDate.clone().subtract(1, 'days');
        this.secondCustom.trendStart = this.secondCustom.trendEnd.clone().subtract(dateDiff, 'days');
        this.getDropdownById(this.secondDateRange).trendText = moment(this.secondCustom.trendStart).format('MM/DD/YYYY') + ' - ' + moment(this.secondCustom.trendEnd).format('MM/DD/YYYY');
        this.secondCustom.name=moment(this.secondCustom.startDate).format('MM/DD/YY') + '-' + moment(this.secondCustom.endDate).format('MM/DD/YY');
      }
      else if(this.customColumn === 3){
        this.thirdCustom.startDate = moment(this.customDate.startDate);
        this.thirdCustom.endDate = moment(this.customDate.endDate);
        let dateDiff = this.thirdCustom.endDate.diff(this.thirdCustom.startDate, 'days');
        this.thirdCustom.trendEnd = this.thirdCustom.startDate.clone().subtract(1, 'days');
        this.thirdCustom.trendStart = this.thirdCustom.trendEnd.clone().subtract(dateDiff, 'days');
        this.getDropdownById(this.thirdDateRange).trendText = moment(this.thirdCustom.trendStart).format('MM/DD/YYYY') + ' - ' + moment(this.thirdCustom.trendEnd).format('MM/DD/YYYY');
        this.thirdCustom.name=moment(this.thirdCustom.startDate).format('MM/DD/YY') + '-' + moment(this.thirdCustom.endDate).format('MM/DD/YY');
      }

      await this.getDashboardValues();
    },
    async exportCsv () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let filename = 'CompanyDashboard.csv'
        let csvData = ' , '
        if(this.dropdownValues.find(x => x.id === this.firstDateRange).name==='PERIOD'){
          csvData += this.dropdownValues.find(x => x.id === this.firstDateRange).periodList[this.firstPeriod].shortLabel;
        }
        else
        {
          csvData += ((this.dropdownValues.find(x => x.id === this.firstDateRange).name === 'CUSTOM') ? this.firstCustom.name : this.dropdownValues.find(x => x.id === this.firstDateRange).friendlyName);
        }
        if(this.viewTrends){
          csvData += ', ' +  'Trend 1'
        }
        if(this.secondDateRange){
          if(this.dropdownValues.find(x => x.id === this.secondDateRange).name==='PERIOD'){
            csvData += ' , ' + this.dropdownValues.find(x => x.id === this.secondDateRange).periodList[this.secondPeriod].shortLabel;
          }
          else
          {
            csvData += ', ' + ((this.dropdownValues.find(x => x.id === this.secondDateRange).name === 'CUSTOM') ? this.secondCustom.name : this.dropdownValues.find(x => x.id === this.secondDateRange).friendlyName);
          }
          if(this.viewTrends){
            csvData += ', ' +  'Trend 2'
          }
        }
        if(this.thirdDateRange){
          if(this.dropdownValues.find(x => x.id === this.thirdDateRange).name==='PERIOD'){
            csvData += ' , ' + this.dropdownValues.find(x => x.id === this.thirdDateRange).periodList[this.thirdPeriod].shortLabel;
          }
          else
          {
            csvData += ', ' + ((this.dropdownValues.find(x => x.id === this.thirdDateRange).name === 'CUSTOM') ? this.thirdCustom.name : this.dropdownValues.find(x => x.id === this.thirdDateRange).friendlyName);
          }
          if(this.viewTrends){
            csvData += ', ' +  'Trend 3'
          }
        }
        csvData += '\n';

        this.dashValues.forEach((p, i) => {
          if (p.major_milestone || !this.viewMajorMilestones) {
            csvData += p.name + ',' + (p.company_count ? p.company_count : 0);
            if (this.viewTrends) {
              csvData += ', ' + (p.trend_count ? p.trend_count : 0) + '%';
            }
            if (this.secondDateRange) {
              csvData += ', ' + (this.column2Values[i].company_count ? this.column2Values[i].company_count : 0)
              if (this.viewTrends) {
                csvData += ', ' + (this.column2Values[i].trend_count ? this.column2Values[i].trend_count : 0) + '%';
              }
            }
            if (this.thirdDateRange) {
              csvData += ', ' + (this.column3Values[i].company_count ? this.column3Values[i].company_count : 0)
              if (this.viewTrends) {
                csvData += ', ' + (this.column3Values[i].trend_count ? this.column3Values[i].trend_count : 0) + '%';
              }
            }
            csvData += '\n';
          }
        })


        let blob = new Blob([csvData], {
          type: 'text/csv;charset=utf-8'
        });

        saveAs(blob, filename);
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Exporting Residual Review')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getDashBoardData(startDate, endDate, trendStart, trendEnd){
      try {
        // this.$store.commit(AppMutations.SET_LOADING, true)

        let params = {
          startDate: startDate,
          endDate: endDate,
          targetTypeId: this.targetTypeId,
          trendStart: trendStart,
          trendEnd: trendEnd
        }

        const {data, status} = await getRequestWithParams('/companyDashboard/dashboardValues', {params}, 'blueraven', [])
        return data;

        handleHidingGlobalLoader(this, status)

      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
        this.isLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      return null;
    },

    async getDashboardValues (dateWasManuallyEntered) {
      if (dateWasManuallyEntered) {
        this.selectedDateRange = 'Custom'
      } else {
        this.setDateRange()
        if (this.selectedDateRange === 'Custom') return // wait for the user to enter a custom date
      }

      this.singleDateRange = this.singleDateRanges.includes(this.selectedDateRange)
      this.targetTypeId = this.singleDateRange ? 1 :
        this.loadTargetsRanges.includes(this.selectedDateRange) ? 2 : null

      this.loadingData = true;
      if(this.dropdownValues != null && this.dropdownValues.length > 0){
        await this.changeDropdownSelection(1);
      }
      else {
        this.dashValues = await this.getDashBoardData(this.startDate, this.endDate, moment().subtract(60, "days").format('YYYY-MM-DD'), moment().subtract(31, "days").format('YYYY-MM-DD'));
      }
      if(this.secondDateRange != null) {
        await this.changeDropdownSelection(2);

      }

      if(this.thirdDateRange != null){
        await this.changeDropdownSelection(3);
      }

      // this.startDate = moment().subtract(30, "days").format('YYYY-MM-DD');
      // this.startDateColumn2 = moment().subtract(60, "days").format('YYYY-MM-DD');
      // this.startDateColumn3 = moment().subtract(90, "days").format('YYYY-MM-DD');

      this.loadingData = false;
    },
    async getDropdownValues() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const params = {
          today: moment().format('YYYY-MM-DD')
        }

        const {data, status} = await getRequestWithParams('/companyDashboard/dropdownValues', {params}, 'blueraven', [])
        this.dropdownValues = data;
        this.isLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
        this.isLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  },
  created () {
    this.headers = [
      { text: 'Milestones', value: 'milestone', sortable: false, class: 'milestone-col-th', show: true, width: '25%' },
      { text: 'Today', value: 'actualTotal', align: 'left', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser, width: '25%' },
      { text: 'Today2', value: 'actualTotal2', align: 'left', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser, width: '25%' },
      { text: 'Today3', value: 'actualTotal3', align: 'left', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser, width: '25%' },
    ]

    // { text: 'Total', value: 'actualTotal', align: 'center', class: 'total-col-th data-col-th', show: this.isBrCorporateUser },
    // { text: 'BRS', value: 'actualBrs', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
    // { text: 'Partners', value: 'actualPartner', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
    // { text: 'Total', value: 'plannedTotal', align: 'center', class: 'total-col-th data-col-th', show: this.isBrCorporateUser },
    // { text: 'BRS', value: 'plannedBrs', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
    // { text: 'Partners', value: 'plannedPartner', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
    // { text: 'Total', value: 'differenceTotal', align: 'center', class: 'total-col-th data-col-th', show: this.isBrCorporateUser },
    // { text: 'BRS', value: 'differenceBrs', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
    // { text: 'Partners', value: 'differencePartner', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser }


    if (this.userStore.details?.timezone?.value) {
      this.timezone = this.userStore.details.timezone?.value
    }

    this.getWeekNum()
    this.getWeekNum()
    this.getDropdownValues()
    this.getDashboardValues()
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

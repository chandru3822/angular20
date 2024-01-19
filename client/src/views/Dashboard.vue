<template>
  <v-container id="company-dash-container">
    <v-card class="filter-bar">
      <v-row align="center">
        <div class="dashboard-header">
          Company Dashboard
        </div>
        <div class="checkbox-container">
          <v-checkbox label="View Trends" v-model="viewTrends" @change="toggleTrends()"></v-checkbox>
        </div>
        <div class="checkbox-container">
          <v-checkbox label="Only View Major Milestones" v-model="viewMajorMilestones"></v-checkbox>
        </div>
        <a class="export-button" @click="exportCsv"><v-icon class="export-icon">download</v-icon>Export</a>
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
          <v-checkbox label="View Trends" v-model="viewTrends" @change="toggleTrends()"></v-checkbox>
        </div>
        <a class="export-button" @click="exportCsv"><v-icon class="export-icon">download</v-icon></a>
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
      :items="dashValues"
      :headers="headers"
      fixed-header
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
      <template #header.actualTotal="{}" ><v-select :items="dropdownValues" outlined item-text="friendlyName" item-value="id" v-model="firstDateRange" v-on:change="changeDropdownSelection(1)" name="hI"></v-select></template>
      <template #header.actualTotal2="{}" ><v-select placeholder="Select Date Range" outlined :items="dropdownValues" item-text="friendlyName" item-value="id" v-model="secondDateRange" v-on:change="changeDropdownSelection(2)"></v-select></template>
      <template #header.actualTotal3="{}" ><v-select placeholder="Select Date Range" outlined :items="dropdownValues" item-text="friendlyName" item-value="id" v-model="thirdDateRange" v-on:change="changeDropdownSelection(3)"></v-select></template>


      <template #item.milestone="{item, index}" id="milestones-col" class="milestone-name-col-td">{{ item.name }}</template>
      <template #item.actualTotal="{item, index}" class="milestone-col-td" >
        <div @click="openDrilldown(item, 1)">{{ item.company_count?item.company_count:0 }}
        <span v-if="viewTrends && item.trend_count>0" class="positive-percentage">{{item.trend_count/100 | percent}}<v-icon class="positive-trendline">trending_up</v-icon></span>
        <span v-if="viewTrends && item.trend_count<0" class="negative-percentage">{{item.trend_count/100 | percent}}<v-icon class="negative-trendline">trending_down</v-icon></span>
        <span v-if="viewTrends && (item.trend_count ===null || item.trend_count===0)" class="neutral-percentage">{{item.trend_count/100 | percent}}<v-icon class="neutral-trendline">trending_flat</v-icon></span>
      </div>
      </template>

      <template #item.actualTotal2="{item, index}" class="milestone-col-td" v-if="secondDateRange != null && column2Values != null && column2Values.length > 0">
        <div @click="openDrilldown(item, 2)">{{column2Values[index].company_count?column2Values[index].company_count:0}}
        <span v-if="viewTrends && column2Values[index].trend_count>0" class="positive-percentage">{{column2Values[index].trend_count/100 | percent}}<v-icon class="positive-trendline">trending_up</v-icon></span>
        <span v-if="viewTrends && column2Values[index].trend_count<0" class="negative-percentage">{{column2Values[index].trend_count/100 | percent}}<v-icon class="negative-trendline">trending_down</v-icon></span>
        <span v-if="viewTrends && (column2Values[index].trend_count === null || column2Values[index].trend_count==0)" class="neutral-percentage">{{column2Values[index].trend_count/100 | percent}}<v-icon class="neutral-trendline">trending_flat</v-icon></span>
        </div>
      </template>
      <template #item.actualTotal3="{item, index}" class="milestone-col-td" v-if="thirdDateRange != null && column3Values != null && column3Values.length > 0">
        <div @click="openDrilldown(item, 3)">{{column3Values[index]?.company_count ? column3Values[index].company_count : 0}}
        <span v-if="viewTrends && column3Values[index].trend_count>0" class="positive-percentage">{{column3Values[index].trend_count/100 | percent}}<v-icon class="positive-trendline">trending_up</v-icon></span>
        <span v-if="viewTrends && column3Values[index].trend_count<0" class="negative-percentage">{{column3Values[index].trend_count/100 | percent}}<v-icon class="negative-trendline">trending_down</v-icon></span>
        <span v-if="viewTrends && (column3Values[index].trend_count === null || column3Values[index].trend_count === 0)" class="neutral-percentage">{{column3Values[index].trend_count/100 | percent}}<v-icon class="neutral-trendline">trending_flat</v-icon></span>
        </div>
      </template>
    </v-data-table>
    <ConfirmationDialog v-if="selectingCustomDates" :disableConfirm="customDate.startDate === null || customDate.endDate === null || customDate.startDate?.length === 0 || customDate.endDate?.length === 0" :open-dialog="selectingCustomDates" @confirm="applyCustomDates()" @close-dialog="selectingCustomDates = false">
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
  import CompanyDashboardDrilldown from './blueraven/companyDashboard/CompanyDashboardDrilldown.vue'
  import { AppMutations } from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequestWithParams, getSnackbar, logError, postRequest} from '@/helpers/helpers'
  import cloneDeep from 'lodash.clonedeep'
  import {DateTime} from "luxon";
  import ConfirmationDialog from "@/components/ConfirmationDialog.vue";


  export default {
    name: 'Dashboard',
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
        selectedMilestone: {},
        loadPartners: false,
        dividerForSingleDayTargets: 6,
        isBrCorporateUser: this.$store.state.user.details.companyId === 2,
        is7oaksAdmin: this.$store.getters.isFullAdmin,
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
        firstCustom: {
          startDate: "",
          endDate: "",
          trendStart: "",
          trendEnd: ""
        },
        secondCustom: {
          startDate: "",
          endDate: "",
          trendStart: "",
          trendEnd: ""
        },
        thirdCustom: {
          startDate: "",
          endDate: "",
          trendStart: "",
          trendEnd: ""
        },
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
      secondDateRange(value) {
        if (!value) {
          console.log("Column 2 has been cleared");
        }
        else{
          console.log("Column 2 has been changed");
        }
      }
    },
    computed: {
      // visibleHeaders () {
      //   return this.headers.filter(header => header.show === true)
      // },
      filteredDashValues(){
        if(this.viewMajorMilestones){
          return this.dashValues.filter(dv => dv.major_milestone)
        }
        return this.dashValues
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
        this.selectedMilestone = item
        console.log(this.selectedMilestone);
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

        if(column === 1){
          this.startDate = this.dropdownValues.find(x => x.id === this.firstDateRange).startDate? this.dropdownValues.find(x => x.id === this.firstDateRange).startDate : moment(this.firstCustom.startDate).format('YYYY-MM-DDTHH:mm:ss')
          this.endDate = this.dropdownValues.find(x => x.id === this.firstDateRange).endDate ? this.dropdownValues.find(x => x.id === this.firstDateRange).endDate : moment(this.firstCustom.endDate).format('YYYY-MM-DDTHH:mm:ss')
        }
        else if(column === 2){
          this.startDate = this.dropdownValues.find(x => x.id === this.secondDateRange).startDate? this.dropdownValues.find(x => x.id === this.secondDateRange).startDate : moment(this.secondCustom.startDate).format('YYYY-MM-DDTHH:mm:ss')
          this.endDate = this.dropdownValues.find(x => x.id === this.secondDateRange).endDate ? this.dropdownValues.find(x => x.id === this.secondDateRange).endDate : moment(this.secondCustom.endDate).format('YYYY-MM-DDTHH:mm:ss')
        }
        else if(column === 3){
          this.startDate = this.dropdownValues.find(x => x.id === this.thirdDateRange).startDate? this.dropdownValues.find(x => x.id === this.thirdDateRange).startDate : moment(this.thirdCustom.startDate).format('YYYY-MM-DDTHH:mm:ss')
          this.endDate = this.dropdownValues.find(x => x.id === this.thirdDateRange).endDate ? this.dropdownValues.find(x => x.id === this.thirdDateRange).endDate : moment(this.thirdCustom.endDate).format('YYYY-MM-DDTHH:mm:ss')
        }
        try {
          const params = {
            startDate: this.startDate,
            endDate: this.endDate,
            milestoneTypeId: this.selectedMilestone.milestone_type_id,
          }

          const {data, status} = await getRequestWithParams('/companyDashboard/drilldownData', {params}, 'blueraven', [])
          this.drilldownData = data
          console.log(this.drilldownData)
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

      async toggleTrends(){
        // if(this.viewTrends){
        //   await this.getDashboardValues();
        // }
      },
      async resetFilters(){
        this.viewTrends = false;
        this.firstDateRange = 2;
        this.secondDateRange = null;
        this.thirdDateRange = null;
        await this.getDashboardValues();
      },
      async changeDropdownSelection(dropdown){
        if(dropdown === 1){
          let result = this.dropdownValues.find(x => x.id === this.firstDateRange)
          if(result === null){
            return null;
          }
          if(result.startDate === null){
            if(this.firstCustom.startDate.length === 0) {
              this.customColumn = 1;
              this.selectingCustomDates = true;
              return;
            }
            else{
              result = cloneDeep(this.firstCustom);
              this.resetCustomDate();
            }
          }
          this.dashValues = await this.getDashBoardData(moment(result.startDate).format('YYYY-MM-DD'), moment(result.endDate).format('YYYY-MM-DD'), moment(result.trendStart).format('YYYY-MM-DD'), moment(result.trendEnd).format('YYYY-MM-DD'));
        }
        else if(dropdown === 2){
          let result = this.dropdownValues.find(x => x.id === this.secondDateRange)
          if(result === null){
            return null;
          }
          if(result.startDate === null){
            if(this.secondCustom.startDate.length === 0) {
              this.customColumn = 2;
              this.selectingCustomDates = true;
              return;
            }
            else{
              result = cloneDeep(this.secondCustom);
              this.resetCustomDate();
            }
          }
          this.column2Values = await this.getDashBoardData(moment(result.startDate).format('YYYY-MM-DD'), moment(result.endDate).format('YYYY-MM-DD'), moment(result.trendStart).format('YYYY-MM-DD'), moment(result.trendEnd).format('YYYY-MM-DD'));
        }
        else if(dropdown === 3){
          let result = this.dropdownValues.find(x => x.id === this.thirdDateRange)
          if(result == null){
            return null;
          }
          if(result.startDate === null){
            if(this.thirdCustom.startDate.length === 0) {
              this.customColumn = 3;
              this.selectingCustomDates = true;
              return;
            }
            else{
              result = cloneDeep(this.thirdCustom);
              this.resetCustomDate();
            }
          }
          this.column3Values = await this.getDashBoardData(moment(result.startDate).format('YYYY-MM-DD'), moment(result.endDat).format('YYYY-MM-DD'), moment(result.trendStart).format('YYYY-MM-DD'), moment(result.trendEnd).format('YYYY-MM-DD'));
        }
      },
      resetCustomDate(){
        this.customDate.startDate = "";
        this.customDate.endDate = "";
        this.customDate.trendStart = "";
        this.customDate.trendEnd = "";
      },
      async applyCustomDates(){
        if(this.customColumn === 1) {
          this.firstCustom.startDate = moment(this.customDate.startDate);
          this.firstCustom.endDate = moment(this.customDate.endDate);
          let dateDiff = this.firstCustom.endDate.diff(this.firstCustom.startDate, 'days');
          this.firstCustom.trendEnd = this.firstCustom.startDate.clone().subtract(1, 'days');
          this.firstCustom.trendStart = this.firstCustom.trendEnd.clone().subtract(dateDiff, 'days');
        }
        else if(this.customColumn === 2){
          this.secondCustom.startDate = moment(this.customDate.startDate);
          this.secondCustom.endDate = moment(this.customDate.endDate);
          let dateDiff = this.secondCustom.endDate.diff(this.secondCustom.startDate, 'days');
          this.secondCustom.trendEnd = this.secondCustom.startDate.clone().subtract(1, 'days');
          this.secondCustom.trendStart = this.secondCustom.trendEnd.clone().subtract(dateDiff, 'days');
        }
        else if(this.customColumn === 3){
          this.thirdCustom.startDate = moment(this.customDate.startDate);
          this.thirdCustom.endDate = moment(this.customDate.endDate);
          let dateDiff = this.thirdCustom.endDate.diff(this.thirdCustom.startDate, 'days');
          this.thirdCustom.trendEnd = this.thirdCustom.startDate.clone().subtract(1, 'days');
          this.thirdCustom.trendStart = this.thirdCustom.trendEnd.clone().subtract(dateDiff, 'days');
        }

        await this.getDashboardValues();
      },
      async exportCsv () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let filename = 'CompanyDashboard.csv'

          let csvData = ' , ' + this.dropdownValues.find(x => x.id === this.firstDateRange).friendlyName;
          if(this.viewTrends){
            csvData += ', ' +  'Trend 1'
          }
          if(this.secondDateRange){
            csvData += ', ' + this.dropdownValues.find(x => x.id === this.secondDateRange).friendlyName;
            if(this.viewTrends){
              csvData += ', ' +  'Trend 2'
            }
          }
          if(this.thirdDateRange){
            csvData += ', ' + this.dropdownValues.find(x => x.id === this.thirdDateRange).friendlyName;
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
            today: moment().format('YYYY-MM-DDTHH:mm:ss')
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
        { text: 'Milestones', value: 'milestone', sortable: false, class: 'milestone-col-th', show: true },
        { text: 'Today', value: 'actualTotal', align: 'center', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser },
        { text: 'Today2', value: 'actualTotal2', align: 'center', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser },
        { text: 'Today3', value: 'actualTotal3', align: 'center', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser },
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


      if (this.$store?.state?.user?.details?.timezone?.value) {
        this.timezone = this.$store.state.user.details.timezone.value
      }

      this.getWeekNum()
      this.getDropdownValues()
      this.getDashboardValues()
    }
  }
</script>

<style lang="scss" scoped>
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


  .v-select ::v-deep .v-select__selection {
    color: var(--v-primaryText-base) !important;
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
      flex-wrap: wrap;
    }
  }
  @media(max-width: 600px){
    .filter-bar{
      display: none;
    }
    .checkbox-container-mini{
      padding-left: 20px;
    }
  }
</style>
<style lang="scss">

#company-dash-table > div > table > thead > tr > th {
  z-index: 1 !important;
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

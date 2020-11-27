<template>
  <v-row>
    <v-col cols="12">
      <v-row id="company-dash-toolbar-container">
        <v-col cols="12" id="company-dash-toolbar">
          <v-app-bar class="elevation-1" fixed style="top: 48px">
            <v-toolbar-title>Company Dashboard</v-toolbar-title>
            <div id="toolbar-right-side">
              <v-select class="date-range-dropdown"
                        v-model="selectedDateRange"
                        :items="dateRanges"
                        label="Date Range"
                        @change="getDashboardValues(false)"
                        hide-details
                        dense
                        outlined
              ></v-select>
              <DatetimePickerInput :custom-class="'date-range-date'"
                                   v-model="startDate"
                                   :timezone="timezone"
                                   :max="endDate"
                                   :type="'date'"
                                   label="Start Date"
                                   @input="getDashboardValues(true)"
                                   hide-details
                                   :hide-prepend-icon="true"
                                   :dense="'dense'"
                                   :outlined="'outlined'"
              ></DatetimePickerInput>
              <DatetimePickerInput :custom-class="'date-range-date'"
                                   v-model="endDate"
                                   :timezone="timezone"
                                   :min="startDate"
                                   :type="'date'"
                                   label="End Date"
                                   @input="getDashboardValues(true)"
                                   hide-details
                                   :hide-prepend-icon="true"
                                   :dense="'dense'"
                                   :outlined="'outlined'"
              ></DatetimePickerInput>
              <v-btn v-if="$store.getters.userHasFeatureAccessLevel('COMPANY_DASHBOARD', 'ADMIN') && isBrCorporateUser"
                     id="targets-btn" class="white--text text-capitalize" color="primaryCustom"
                     to="/companyDashboardTargets" title="View company dashboard targets">
                Targets
              </v-btn>
            </div>
          </v-app-bar>
        </v-col>
      </v-row>

      <v-row>
        <v-col cols="12">
          <v-data-table id="company-dash-table"
                        class="elevation-1 mx-1"
                        :headers="visibleHeaders"
                        :items="dashValues"
                        :loading="isLoading"
                        loading-text="Loading data..."
                        hide-default-footer
                        disable-pagination
                        disable-sort
                        mobile-breakpoint=""
                        dense>
            <template v-slot:header>
              <thead id="main-table-header">
                <tr>
                  <th id="milestone-col-header" colspan="1">Milestone</th>
                  <th v-if="isBrCorporateUser" colspan="3">Actual</th>
                  <th v-if="isBrCorporateUser" colspan="3">Planned</th>
                  <th v-if="isBrCorporateUser" colspan="3">Difference</th>
                  <th v-if="!isBrCorporateUser" colspan="3">Total</th>
                </tr>
              </thead>
            </template>
            <template #item="{ item, index }" class="table-body">
              <tr :class="[{'light-blue-row': !(index % 2) && item.milestone !== 'Substantial Completions'}, {'blue-row': ['Bookings','Final Designs Approved','Substantial Completions','Final Completions'].indexOf(item.milestone) !== -1}]"
                  :style="{'background-color': index === 0 ? '#e9f2ff' : ''}">
                <td class="milestone-col-td">{{ item.milestone }}</td>
                <td class="data-col-td total-col-td clickable"
                    @click="getDrilldownData(item.milestone, 'Total')">{{ item.actualTotal }}</td>
                <td v-if="isBrCorporateUser" class="data-col-td clickable"
                    @click="getDrilldownData(item.milestone, 'BRS')">{{ item.actualBrs }}</td>
                <td v-if="isBrCorporateUser" class="data-col-td clickable"
                    @click="getDrilldownData(item.milestone, 'Partner')">{{ item.actualPartner }}</td>
                <td v-if="isBrCorporateUser" class="data-col-td total-col-td">{{ item.plannedTotal }}</td>
                <td v-if="isBrCorporateUser" class="data-col-td">{{ item.plannedBrs }}</td>
                <td v-if="isBrCorporateUser" class="data-col-td">{{ item.plannedPartner }}</td>
                <td v-if="isBrCorporateUser" class="data-col-td total-col-td" :class="(item.differenceTotal >= 0 || item.differenceTotal === '-') ? 'pos_diff' : 'neg_diff'">{{ item.differenceTotal }}</td>
                <td v-if="isBrCorporateUser" class="data-col-td" :class="(item.differenceBrs >= 0 || item.differenceBrs === '-') ? 'pos_diff' : 'neg_diff'">{{ item.differenceBrs }}</td>
                <td v-if="isBrCorporateUser" class="data-col-td" :class="(item.differencePartner >= 0 || item.differencePartner === '-') ? 'pos_diff' : 'neg_diff'">{{ item.differencePartner }}</td>
              </tr>
            </template>
            <template v-slot:footer>
              <div id="company-funnel-background"></div>
            </template>
          </v-data-table>
        </v-col>
      </v-row>
    </v-col>
    <v-dialog v-model="drilldownDialog" max-width="950">
      <v-card>
        <v-card-title class="mb-1">
          <span id="drilldown-title">{{ drilldownTitle }}</span>
          <a class="close-modal-x pb-3" title="Close" @click="close">×</a>
        </v-card-title>

        <v-card-text>
          <v-data-table
            id="drilldown-table"
            :headers="visibleDrilldownHeaders"
            :items="drilldownData"
            :footer-props="footerProps"
            :items-per-page="500"
            :mobile-breakpoint="0"
            fixed-header
            dense
            class="elevation-1"
          >
            <template v-if="drilldownData.length > 0" #item="{ item, index }" class="table-body">
              <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
                <td class="text-left">{{ index + 1 }}</td>
                <td class="text-left">{{ item.projectId ? item.projectId : '' }}</td>
                <td class="text-left customer-name">{{ item.customerName ? item.customerName : '' }}</td>
                <td v-if="drilldownHeaders[3].show" class="text-left">
                  {{ item.appointmentDateFormatted ? item.appointmentDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[4].show" class="text-left">
                  {{ item.appointmentOutcome ? item.appointmentOutcome : '' }}
                </td>
                <td v-if="drilldownHeaders[5].show" class="text-left">
                  {{ item.installationAgreementSignedDateFormatted ? item.installationAgreementSignedDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[6].show" class="text-left">
                  {{ item.siteSurveyVerifiedDateFormatted ? item.siteSurveyVerifiedDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[7].show" class="text-left">
                  {{ item.finalDesignQADateFormatted ? item.finalDesignQADateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[8].show" class="text-left">
                  {{ item.finalDesignSentToHomeownerDateFormatted ? item.finalDesignSentToHomeownerDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[9].show" class="text-left">
                  {{ item.finalDesignSignedDateFormatted ? item.finalDesignSignedDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[10].show" class="text-left">
                  {{ item.planSetCreatedDateFormatted ? item.planSetCreatedDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[11].show" class="text-left">
                  {{ item.permitPackCompleteDateFormatted ? item.permitPackCompleteDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[12].show" class="text-left">
                  {{ item.permitPackSubmittalVerifiedDateFormatted ? item.permitPackSubmittalVerifiedDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[13].show" class="text-left">
                  {{ item.permitApprovedDateFormatted ? item.permitApprovedDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[14].show" class="text-left">
                  {{ item.installationScheduledDateFormatted ? item.installationScheduledDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[15].show" class="text-left">
                  {{ item.installationDateFormatted ? item.installationDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[16].show" class="text-left">
                  {{ item.installationCloseoutDateFormatted ? item.installationCloseoutDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[17].show" class="text-left">
                  {{ item.substantialCompletionDateFormatted ? item.substantialCompletionDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[18].show" class="text-left">
                  {{ item.ahjInspectionScheduledDateFormatted ? item.ahjInspectionScheduledDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[19].show" class="text-left">
                  {{ item.ahjReinspectionScheduledDateFormatted ? item.ahjReinspectionScheduledDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[20].show" class="text-left">
                  {{ item.ahjInspectionDateFormatted ? item.ahjInspectionDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[21].show" class="text-left">
                  {{ item.ahjReinspectionDateFormatted ? item.ahjReinspectionDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[22].show" class="text-left">
                  {{ item.ahjFinalInspectionVerifiedDateFormatted ? item.ahjFinalInspectionVerifiedDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[23].show" class="text-left">
                  {{ item.verifiedInspectionApprovalReceivedByUtilityDateFormatted ? item.verifiedInspectionApprovalReceivedByUtilityDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[24].show" class="text-left">
                  {{ item.ahjInspectionApprovalSubmittedDateFormatted ? item.ahjInspectionApprovalSubmittedDateFormatted : '' }}
                </td>
                <td v-if="drilldownHeaders[25].show" class="text-left">
                  {{ item.finalCompletionSubmittedDateFormatted ? item.finalCompletionSubmittedDateFormatted : '' }}
                </td>
              </tr>
            </template>

            <template #no-data>
              <div class="my-3">
                No data was found for the specified date range.
              </div>
            </template>
          </v-data-table>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn id="drilldown-close-btn" class="white--text text-capitalize mr-4 mb-2"
                 color="primaryButton" @click="close">Close</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-row>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import orderBy from "lodash.orderby"
  import constants from '@/helpers/constants'
  import moment from 'moment'
  import DatetimePickerInput from "@/components/DatetimePickerInput"
  import Snackbar from '@/components/Snackbar.vue'
  import { AppMutations } from '@/stores/AppStore'
  import { getRequestWithParams, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'companyDashboard',
    components: {
      DatetimePickerInput,
      Snackbar
    },
    data: () => ({
      snackbar: {},
      constants,
      isBrCorporateUser: false,
      headers: [],
      timezone: 'US/Mountain',
      selectedDateRange: 'Today',
      startDate: moment().format('YYYY-MM-DD'),
      endDate: moment().format('YYYY-MM-DD'),
      weekNum: 1,
      currentPeriod: Math.ceil(moment().isoWeek() / 4),
      dateRanges: ['Yesterday', 'Today', 'Current Week', 'Current Period', 'Last Week', 'Last Period', 'Custom', 'This Month', 'This Year', 'All Time'],
      isLoading: true,
      dashValues: [],
      drilldownDialog: false,
      drilldownTitle: '',
      drilldownHeaders: [
        { text: '', value: '', show: true, sortable: false }, // 0
        { text: 'Project ID', value: 'projectId', show: true }, // 1
        { text: 'Customer Name', value: 'customerName', show: true }, // 2
        { text: 'Appointment Date', value: 'appointmentDateFormatted', show: false }, // 3
        { text: 'Appointment Outcome', value: 'appointmentOutcome', show: false }, // 4
        { text: 'Installation Agreement Signed Date', value: 'installationAgreementSignedDateFormatted', show: false }, // 5
        { text: 'Site Survey Verified Date', value: 'siteSurveyVerifiedDateFormatted', show: false }, // 6
        { text: 'Final Design QA Date', value: 'finalDesignQADateFormatted', show: false }, // 7
        { text: 'Final Design Sent to Homeowner Date', value: 'finalDesignSentToHomeownerDateFormatted', show: false }, // 8
        { text: 'Final Design Approved Date', value: 'finalDesignApprovedDateFormatted', show: false }, // 9
        { text: 'Plan Set Created Date', value: 'planSetCreatedDateFormatted', show: false }, // 10
        { text: 'Permit Pack Complete Date', value: 'permitPackCompleteDateFormatted', show: false }, // 11
        { text: 'Permit Pack Submittal Verified Date', value: 'permitPackSubmittalVerifiedDateFormatted', show: false }, // 12
        { text: 'Permit Approved Date', value: 'permitApprovedDateFormatted', show: false }, // 13
        { text: 'Installation Scheduled Date', value: 'installationScheduledDateFormatted', show: false }, // 14
        { text: 'Installation Date', value: 'installationDateFormatted', show: false }, // 15
        { text: 'Installation Closeout Date', value: 'installationCloseoutDateFormatted', show: false }, // 16
        { text: 'Substantial Completion Date', value: 'substantialCompletionDateFormatted', show: false }, // 17
        { text: 'AHJ Inspection Scheduled Date', value: 'ahjInspectionScheduledDateFormatted', show: false }, // 18
        { text: 'AHJ Reinspection Scheduled', value: 'ahjReinspectionScheduledDateFormatted', show: false }, // 19
        { text: 'AHJ Inspection Date', value: 'ahjInspectionDateFormatted', show: false }, // 20
        { text: 'AHJ Reinspection Date', value: 'ahjReinspectionDateFormatted', show: false }, // 21
        { text: 'AHJ Final Inspection Verified Date', value: 'ahjFinalInspectionVerifiedDateFormatted', show: false }, // 22
        { text: 'Verified Inspection Approval Received by Utility Date', value: 'verifiedInspectionApprovalReceivedByUtilityDateFormatted', show: false }, // 23
        { text: 'AHJ Inspection Approval Submitted Date', value: 'ahjInspectionApprovalSubmittedDateFormatted', show: false }, // 24
        { text: 'Final Completion Submitted Date', value: 'finalCompletionSubmittedDateFormatted', show: false } // 25
      ],
      drilldownData: [],
      footerProps: {
        showFirstLastPage: !constants.IS_MOBILE,
        firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
        lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
        'items-per-page-options': [100, 500, 1000, 2000]
      }
    }),
    computed: {
      visibleHeaders () {
        return this.headers.filter(header => header.show === true)
      },
      momentStartOfPeriod () {
        return moment().startOf('isoWeek').isoWeek((this.currentPeriod - 1) * 4 + 1)
      },
      startOfPeriod () {
        return moment().startOf('isoWeek').isoWeek((this.currentPeriod - 1) * 4 + 1).format('YYYY-MM-DD')
      },
      endOfPeriod () {
        return moment(this.momentStartOfPeriod).clone().add(3, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
      },
      startOfWeek () {
        return moment(this.momentStartOfPeriod).clone().add((this.weekNum - 1), 'weeks').startOf('isoWeek').format('YYYY-MM-DD')
      },
      endOfWeek () {
        return moment(this.momentStartOfPeriod).clone().add((this.weekNum - 1), 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
      },
      visibleDrilldownHeaders () {
        return this.drilldownHeaders.filter(header => header.show === true)
      }
    },
    watch: {
      drilldownDialog (val) {
        val || this.close()
      }
    },
    methods: {
      getWeekNum () {
        for (let i = 0; i <= 3; i++) {
          let startOfWeek = moment(this.momentStartOfPeriod).clone().add(i, 'weeks').startOf('isoWeek').valueOf()
          let endOfWeek = moment(this.momentStartOfPeriod).clone().add(i, 'weeks').endOf('isoWeek').valueOf()

          if (moment().isBetween(startOfWeek, endOfWeek)) {
            this.weekNum = i + 1
          }
        }
      },

      setDateRange () {
        switch (this.selectedDateRange) {
          case 'Yesterday':
            this.startDate = moment().startOf('day').add(-1, 'days').format('YYYY-MM-DD')
            this.endDate = moment().endOf('day').add(-1, 'days').format('YYYY-MM-DD')
            break
          case 'Today':
            this.startDate = moment().startOf('day').format('YYYY-MM-DD')
            this.endDate = moment().endOf('day').format('YYYY-MM-DD')
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
            this.startDate = moment(this.momentStartOfPeriod).clone().add((this.weekNum - 2), 'weeks').startOf('isoWeek').format('YYYY-MM-DD')
            this.endDate = moment(this.momentStartOfPeriod).clone().add((this.weekNum - 2), 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
            break
          case 'Last Period':
            this.momentStartOfLastPeriod = moment().clone().startOf('isoWeek').isoWeek((this.currentPeriod - 2) * 4 + 1)
            this.startDate = moment().clone().startOf('isoWeek').isoWeek((this.currentPeriod - 2) * 4 + 1).format('YYYY-MM-DD')
            this.endDate = moment(this.momentStartOfLastPeriod).clone().add(3, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
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

      async getDashboardValues (dateWasManuallyEntered) {
        if (dateWasManuallyEntered) {
          this.selectedDateRange = 'Custom'
        } else {
          this.setDateRange()
          if (this.selectedDateRange === 'Custom') return // wait for the user to enter a custom date
        }

        try {
          this.$store.commit(AppMutations.SET_LOADING, true)

          const params = {
            startDate: this.startDate,
            endDate: this.endDate
          }

          const {data} = await getRequestWithParams('/companyDashboard/dashboardValues', {params}, 'blueraven')
          this.dashValues = cloneDeep(data)

          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async getDrilldownData (milestone, column) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          this.getColumnHeaders(milestone)

          const params = {
            startDate: this.startDate,
            endDate: this.endDate,
            milestone,
            column
          }

          const {data} = await getRequestWithParams('/companyDashboard/drilldownData', {params}, 'blueraven')
          this.drilldownData = cloneDeep(data)

          if (this.drilldownData?.length > 0) {
            this.drilldownData.forEach(row => row.customerName = row.customerName.toLowerCase())
            this.drilldownData = orderBy(this.drilldownData, row => row.customerName)
            this.reformatDrilldownDates()
          }

          this.drilldownTitle = milestone
          this.drilldownDialog = true
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving drilldown data')
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      getColumnHeaders (milestone) {
        switch (milestone) {
          case 'Appointments Created':
          case 'Planned Appointments':
            this.drilldownHeaders[3].show = true // Appointment Date
            break
          case 'Pitches':
            this.drilldownHeaders[3].show = true // Appointment Date
            this.drilldownHeaders[4].show = true // Appointment Outcome
            break
          case 'Bookings':
            this.drilldownHeaders[5].show = true // Installation Agreement Signed Date
            break
          case 'Site Surveys Verified':
            this.drilldownHeaders[6].show = true // Site Survey Verified Date
            break
          case 'Final Designs QA\'d':
            this.drilldownHeaders[7].show = true // Final Design QA Date
            break
          case 'Final Designs Sent':
            this.drilldownHeaders[8].show = true // Final Design Sent to Customer Date
            break
          case 'Final Designs Approved':
            this.drilldownHeaders[9].show = true // Final Design Approved Date
            break
          case 'Plan Sets Created':
            this.drilldownHeaders[10].show = true // Plan Set Created Date
            break
          case 'Permit Packs Created':
            this.drilldownHeaders[11].show = true // Permit Pack Complete
            break
          case 'Permits Submitted':
            this.drilldownHeaders[12].show = true // Permit Pack Submittal Verified
            break
          case 'Permits Approved':
            this.drilldownHeaders[13].show = true // Permit Approved Date
            break
          case 'Installations Scheduled':
            this.drilldownHeaders[14].show = true // Scheduled Installation Date
            break
          case 'Planned Installations':
            this.drilldownHeaders[15].show = true // Installation Date
            this.drilldownHeaders[16].show = true // Installation Closeout Date
            break
          case 'Substantial Completions':
            this.drilldownHeaders[17].show = true // Substantial Completion Date
            break
          case 'Inspections Scheduled':
            this.drilldownHeaders[18].show = true // AHJ Inspection Scheduled Date
            this.drilldownHeaders[19].show = true // AHJ Reinspection Scheduled
            break
          case 'Planned Inspections':
            this.drilldownHeaders[20].show = true // AHJ Inspection Date
            this.drilldownHeaders[21].show = true // AHJ Reinspection Date
            break
          case 'Inspections Passed':
            this.drilldownHeaders[22].show = true // AHJ Inspection Passed Date
            break
          case 'Inspection Results Submitted':
            this.drilldownHeaders[23].show = true // Verified Inspection Approval Received by Utility Date
            this.drilldownHeaders[24].show = true // AHJ Inspection Approval Submitted Date
            break
          case 'Final Completions':
            this.drilldownHeaders[25].show = true // Final Completion Submitted Date
            break
        }
      },

      reformatDrilldownDates () {
        this.drilldownData.forEach(row => {
          if (row.appointmentDate) {
            row.appointmentDateFormatted = moment(row.appointment_date).format('MMM D, YYYY')
          }

          if (row.installationAgreementSignedDate) {
            row.installationAgreementSignedDateFormatted = moment(row.installationAgreementSignedDate).format('MMM D, YYYY')
          }

          if (row.siteSurveyVerifiedDate) {
            row.siteSurveyVerifiedDateFormatted = moment(row.siteSurveyVerifiedDate).format('MMM D, YYYY')
          }

          if (row.finalDesignQADate) {
            row.finalDesignQADateFormatted = moment(row.finalDesignQADate).format('MMM D, YYYY')
          }

          if (row.finalDesignSentToHomeownerDate) {
            row.finalDesignSentToHomeownerDateFormatted = moment(row.finalDesignSentToHomeownerDate).format('MMM D, YYYY')
          }

          if (row.finalDesignSignedDate) {
            row.finalDesignSignedDateFormatted = moment(row.finalDesignSignedDate).format('MMM D, YYYY')
          }

          if (row.planSetCreatedDate) {
            row.planSetCreatedDateFormatted = moment(row.planSetCreatedDate).format('MMM D, YYYY')
          }

          if (row.permitPackCompleteDate) {
            row.permitPackCompleteDateFormatted = moment(row.permitPackCompleteDate).format('MMM D, YYYY')
          }

          if (row.permitPackSubmittalVerifiedDate) {
            row.permitPackSubmittalVerifiedDateFormatted = moment(row.permitPackSubmittalVerifiedDate).format('MMM D, YYYY')
          }

          if (row.permitApprovedDate) {
            row.permitApprovedDateFormatted = moment(row.permitApprovedDate).format('MMM D, YYYY')
          }

          if (row.installationScheduledDate) {
            row.installationScheduledDateFormatted = moment(row.installationScheduledDate).format('MMM D, YYYY')
          }

          if (row.installationDate) {
            row.installationDateFormatted = moment(row.installationDate).format('MMM D, YYYY')
          }

          if (row.installationCloseoutDate) {
            row.installationCloseoutDateFormatted = moment(row.installationCloseoutDate).format('MMM D, YYYY')
          }

          if (row.substantialCompletionDate) {
            row.substantialCompletionDateFormatted = moment(row.substantialCompletionDate).format('MMM D, YYYY')
          }

          if (row.ahjInspectionScheduledDate) {
            row.ahjInspectionScheduledDateFormatted = moment(row.ahjInspectionScheduledDate).format('MMM D, YYYY')
          }

          if (row.ahjReinspectionScheduledDate) {
            row.ahjReinspectionScheduledDateFormatted = moment(row.ahjReinspectionScheduledDate).format('MMM D, YYYY')
          }

          if (row.ahjInspectionDate) {
            row.ahjInspectionDateFormatted = moment(row.ahjInspectionDate).format('MMM D, YYYY')
          }

          if (row.ahjReinspectionDate) {
            row.ahjReinspectionDateFormatted = moment(row.ahjReinspectionDate).format('MMM D, YYYY')
          }

          if (row.ahjFinalInspectionVerifiedDate) {
            row.ahjFinalInspectionVerifiedDateFormatted = moment(row.ahjFinalInspectionVerifiedDate).format('MMM D, YYYY')
          }

          if (row.verifiedInspectionApprovalReceivedByUtilityDate) {
            row.verifiedInspectionApprovalReceivedByUtilityDateFormatted = moment(row.verifiedInspectionApprovalReceivedByUtilityDate).format('MMM D, YYYY')
          }

          if (row.ahjInspectionApprovalSubmittedDate) {
            row.ahjInspectionApprovalSubmittedDateFormatted = moment(row.ahjInspectionApprovalSubmittedDate).format('MMM D, YYYY')
          }

          if (row.finalCompletionSubmittedDate) {
            row.finalCompletionSubmittedDateFormatted = moment(row.finalCompletionSubmittedDate).format('MMM D, YYYY')
          }
        })
      },

      close () {
        this.drilldownDialog = false

        // reset column header visibility
        for (let i = 3; i < this.drilldownHeaders.length; i++) {
          this.drilldownHeaders[i].show = false
        }

        // reset scroll bar positioning to top
        document.getElementsByClassName('v-dialog--active')[0].scrollTop = 0
      },
    },
    created () {
      this.isBrCorporateUser = this.$store.state.user.details.companyId === 2

      // populating headers here instead of in "data" b/c I can't seem to check the companyId there
      this.headers = [
        { text: null, value: 'milestone', sortable: false, class: 'milestone-col-th', show: true },
        { text: null, value: 'actualTotal', align: 'center', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser },
        { text: 'Total', value: 'actualTotal', align: 'center', class: 'total-col-th data-col-th', show: this.isBrCorporateUser },
        { text: 'BRS', value: 'actualBrs', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
        { text: 'Partners', value: 'actualPartner', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
        { text: 'Total', value: 'plannedTotal', align: 'center', class: 'total-col-th data-col-th', show: this.isBrCorporateUser },
        { text: 'BRS', value: 'plannedBrs', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
        { text: 'Partners', value: 'plannedPartner', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
        { text: 'Total', value: 'differenceTotal', align: 'center', class: 'total-col-th data-col-th', show: this.isBrCorporateUser },
        { text: 'BRS', value: 'differenceBrs', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser },
        { text: 'Partners', value: 'differencePartner', align: 'center', class: 'data-col-th', show: this.isBrCorporateUser }
      ]

      if (this.$store?.state?.user?.details?.timezone?.value) {
        this.timezone = this.$store.state.user.details.timezone.value
      }

      this.getWeekNum()
      this.getDashboardValues()
    }
  }
</script>

<style lang="scss" scoped>
  #company-dash-toolbar-container {
    #company-dash-toolbar {
      z-index: 2;
      display: flex;
      flex-flow: row nowrap;
      justify-content: space-between;

      header {
        background-color: #fff !important;
      }

      ::v-deep {
        .v-toolbar__title {
          font-size: 10px;
          min-width: 30%;
        }

        #toolbar-right-side {
          display: flex;
          justify-content: flex-end;
          width: 100%;

          .v-input {
            font-size: 7px;
            max-width: 65px;

            label {
              font-size: 8px;
            }

            .v-input__append-inner {
              display: none;
            }
          }

          .date-range-date {
            margin-left: 5px !important;
          }

          #targets-btn {
            box-shadow: none;
            font-size: 9px;
            margin-left: 5px;
            height: 40px;
          }
        }
      }
    }
  }

  .v-select ::v-deep .v-select__selection {
    color: var(--v-primaryText-base) !important;
  }

  #company-funnel-background {
    display: none;
  }

  #company-dash-table {
    border-top-left-radius: 0;
    border-top-right-radius: 0;
    margin: 12px auto 0 auto !important;
    width: 100%;

    #main-table-header {
      #milestone-col-header {
        text-align: left;
      }

      tr:hover {
        background-color: initial !important;
      }

      th {
        border-top: 3px solid var(--v-primaryCustom-base);
        border-bottom: none;
        color: var(--v-primaryText-base);
        font-size: 12px !important;
        text-align: center;
        padding-top: 10px;
      }
    }

    .light-blue-row {
      background-color: #e9f2ff;

      &:hover {
        background-color: #e9f2ff;
      }
    }

    .blue-row {
      background-color: #aed5ee;
      font-weight: bold;

      &:hover {
        background-color: #aed5ee;
      }
    }

    ::v-deep {
      table {
        border-collapse: collapse !important;
      }

      tbody > tr > td {
        height: 26px;
      }

      .milestone-col-th, .milestone-col-td {
        min-width: 175px;
      }

      .milestone-col-td {
        text-align: left;
      }

      .total-col-th, .total-col-td {
        border-left: 2px solid var(--v-primaryCustom-base) !important;
      }

      .data-col-th, .data-col-td {
        padding: 0 3px;
        min-width: 50px;
      }

      .data-col-td {
        border-left: 1px solid rgba(240, 240, 240, 0.75);
      }

      tr:hover {
        background-color: transparent;
      }

      th, td, span {
        color: black;
        text-align: center;
        font-size: 10px;
      }

      .pos_diff {
        color: var(--v-primaryText-base);
      }

      .neg_diff {
        color: red;
      }
    }
  }

  .v-card__title {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: center;
  }

  #drilldown-title {
    font-family: "Roboto Condensed", sans-serif;
    font-size: 14px;
  }

  .close-modal-x {
    font-size: 20px;

    &:hover {
      font-weight: bolder;
    }
  }

  #drilldown-table {
    th, td {
      font-family: "Roboto Condensed", sans-serif;
      font-size: 10px;
    }

    .customer-name {
      text-transform: capitalize;
    }

    ::v-deep {
      .v-data-footer {
        padding: 15px 0 25px 0;
        width: 100%;
      }
    }
  }

  #drilldown-close-btn {
    font-size: 10px;
    height: 25px;
  }

  @media (min-width: 450px) {
    #company-dash-toolbar-container {
      #company-dash-toolbar {
        ::v-deep {
          .v-toolbar__title {
            font-size: 12px;
          }

          #toolbar-right-side {
            .v-input {
              font-size: 10px;
              max-width: 90px;

              label {
                font-size: 10px;
              }
            }

            .date-range-date {
              margin-left: 10px !important;
            }

            #targets-btn {
              font-size: 10px;
              margin-left: 10px;
            }
          }
        }
      }
    }
  }

  @media (min-width: 600px) {
    #company-dash-toolbar-container {
      #company-dash-toolbar {
        ::v-deep {
          .v-toolbar__title {
            font-size: 14px;
          }

          #toolbar-right-side {
            .v-input {
              font-size: 12px;
              max-width: 100px;

              label {
                font-size: 12px;
              }
            }

            #targets-btn {
              font-size: 12px;
            }
          }
        }
      }
    }

    #company-dash-table {
      #main-table-header {
        th {
          font-size: 14px !important;
        }
      }

      ::v-deep {
        th, td, span {
          position: relative;
          z-index: 1;
          font-size: 12px !important;
        }
      }
    }
  }

  @media (min-width: 769px) {
    #company-dash-toolbar-container {
      #company-dash-toolbar {
        ::v-deep {
          .v-toolbar__title {
            font-size: 16px;
          }

          #toolbar-right-side {
            .v-input {
              font-size: 14px;
              max-width: 110px;

              label {
                font-size: 14px;
              }
            }

            #targets-btn {
              font-size: 14px;
            }
          }
        }
      }
    }

    #company-funnel-background {
      display: block;
      position: relative;
      border-top-style: solid;
      border-top-color: rgba(0, 110, 200, 0.05);
      border-top-width: 520px;
      border-left: 40px solid transparent;
      border-right: 40px solid transparent;
      margin-top: -520px;
      margin-bottom: -48px;
      left: 9px;
      width: 250px;
      height: 0;
    }

    #company-dash-table {
      margin: 24px auto !important;
      height: 100%;

      #main-table-header {
        #milestone-col-header {
          text-align: center;
        }

        th {
          padding-top: 15px;
        }
      }

      ::v-deep {
        .milestone-col-th, .milestone-col-td {
          text-align: center;
          width: 270px;
        }

        .data-col-th, .data-col-td {
          padding: 0 2px;
          min-width: 50px;
        }

        th, td {
          font-size: 12px !important;
        }
      }
    }

    #drilldown-title {
      font-size: 18px;
    }

    #drilldown-table {
      th, td {
        font-size: 12px;
      }

      ::v-deep {
        .v-data-footer {
          padding: initial;
        }
      }
    }

    #drilldown-close-btn {
      font-size: 14px;
      height: 35px;
    }
  }

  @media (min-width: 1070px) {
    #company-dash-toolbar-container {
      #company-dash-toolbar {
        ::v-deep {
          .v-toolbar__title {
            font-size: 20px;
          }
        }
      }
    }

    #company-funnel-background {
      border-left: 120px solid transparent;
      border-right: 120px solid transparent;
      left: 40px;
      width: 420px;
    }

    #company-dash-table {
      ::v-deep {
        .milestone-col-th, .milestone-col-td {
          width: 500px;
        }

        th, td {
          font-size: 12px !important;
        }
      }
    }
  }

  @media (min-width: 1135px) {
    #company-funnel-background {
      left: 80px;
      width: 440px;
    }

    #company-dash-table {
      max-width: 1130px;

      #main-table-header {
        th {
          font-size: 20px !important;
        }
      }

      ::v-deep {
        .milestone-col-th, .milestone-col-td {
          width: 600px;
        }
      }
    }
  }
</style>

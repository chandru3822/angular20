<template>
  <v-container id="company-dash-container">
    <v-row>
      <v-col cols="12" class="pt-0">
        <v-row id="company-dash-toolbar-container">
          <v-col cols="12" id="company-dash-toolbar">
            <v-toolbar class="elevation-1 toolbar-z-index-override">
              <v-toolbar-title>Company Dashboard</v-toolbar-title>
              <div id="toolbar-right-side">
                <v-select attach class="date-range-dropdown"
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
                                     :maxDate="endDate"
                                     :type="'date'"
                                     label="Start Date"
                                     hide-details
                                     :hide-prepend-icon="true"
                                     :dense="'dense'"
                                     :outlined="'outlined'"
                ></DatetimePickerInput>
                <DatetimePickerInput :custom-class="'date-range-date'"
                                     v-model="endDate"
                                     :timezone="timezone"
                                     :minDate="startDate"
                                     :type="'date'"
                                     label="End Date"
                                     hide-details
                                     :hide-prepend-icon="true"
                                     :dense="'dense'"
                                     :outlined="'outlined'"
                ></DatetimePickerInput>
                <v-btn color="primary" dark class="white--text dash-btn"
                  @click="getDashboardValues(true)">
                  Go
                </v-btn>
                <v-btn outlined color="primary" v-if="$store.getters.userHasFeatureAccessLevel('COMPANY_DASHBOARD', 'ADMIN') && (is7oaksAdmin || isBrCorporateUser) && !constants.IS_MOBILE"
                       id="targets-btn" class="dash-btn text-capitalize"
                       to="/companyDashboardTargets" title="View company dashboard targets">
                  Targets
                </v-btn>
              </div>
            </v-toolbar>
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
              <template #item="{ item, index }">
                <tr :class="[{'light-blue-row': !(index % 2)}, {'blue-row': item.show_targets}]"
                    :style="{'background-color': index === 0 ? 'var(--v-primary-lighten9)' : ''}">
                  <td class="milestone-col-td">{{ item.name }}</td>
                  <td class="data-col-td total-col-td clickable"
                      @click="openDrilldown(item, false)">{{ item.company_count + item.partner_count }}</td>
                  <td v-if="isBrCorporateUser" class="data-col-td clickable"
                      @click="openDrilldown(item, false)">{{ item.company_count }}</td>
                  <td v-if="isBrCorporateUser"
                      class="data-col-td clickable" @click="openDrilldown(item, true)">{{ item.partner_count }}</td>
                  <td v-if="isBrCorporateUser" class="data-col-td total-col-td">
                    <span v-if="item.show_targets && targetTypeId != null && singleDateRange">{{ ((item.brs_target + item.partner_target) / dividerForSingleDayTargets) | currency('', 1) }}</span>
                    <span v-else-if="item.show_targets && targetTypeId != null">{{ item.brs_target + item.partner_target }}</span>
                    <span v-else>-</span>
                  </td>
                  <td v-if="isBrCorporateUser" class="data-col-td">
                    <span v-if="item.show_targets && targetTypeId != null && singleDateRange">{{ item.brs_target / dividerForSingleDayTargets | currency('', 1) }}</span>
                    <span v-else-if="item.show_targets && targetTypeId != null">{{ item.brs_target || 0 }}</span>
                    <span v-else>-</span>
                  </td>
                  <td v-if="isBrCorporateUser" class="data-col-td">
                    <span v-if="item.show_targets && targetTypeId != null && singleDateRange">{{ (item.partner_target / dividerForSingleDayTargets) | currency('', 1) }}</span>
                    <span v-else-if="item.show_targets && targetTypeId != null">{{ item.partner_target || 0 }}</span>
                    <span v-else>-</span>
                  </td>
                  <td v-if="isBrCorporateUser" class="data-col-td total-col-td" :class="getClass((item.company_count + item.partner_count) - (item.brs_target + item.partner_target))">
                    <span v-if="item.show_targets && targetTypeId != null && singleDateRange">{{((item.company_count + item.partner_count) - (item.brs_target + item.partner_target)) / dividerForSingleDayTargets  | currency('', 1)  }}</span>
                    <span v-else-if="item.show_targets && targetTypeId != null">{{ (item.company_count + item.partner_count) - (item.brs_target + item.partner_target) }}</span>
                    <span v-else>-</span>
                  </td>
                  <td v-if="isBrCorporateUser" class="data-col-td" :class="getClass(item.company_count - item.brs_target)">
                    <span v-if="item.show_targets && targetTypeId != null && singleDateRange">{{(item.company_count - item.brs_target) / dividerForSingleDayTargets  | currency('', 1)  }}</span>
                    <span v-else-if="item.show_targets && targetTypeId != null">{{ item.company_count - item.brs_target }}</span>
                    <span v-else>-</span>
                  </td>
                  <td v-if="isBrCorporateUser" class="data-col-td" :class="getClass(item.partner_count - item.partner_target)">
                    <span v-if="item.show_targets && targetTypeId != null && singleDateRange">{{(item.partner_count - item.partner_target) / dividerForSingleDayTargets  | currency('', 1)  }}</span>
                    <span v-else-if="item.show_targets && targetTypeId != null">{{ item.partner_count - item.partner_target }}</span>
                    <span v-else>-</span>
                  </td>
                </tr>
              </template>
              <template v-slot:footer>
                <div v-if="dashValues.length > 0" id="company-funnel-background"></div>
              </template>
            </v-data-table>
          </v-col>
        </v-row>
      </v-col>
      <v-dialog v-model="showDrilldown">
        <CompanyDashboardDrilldown v-if="!drilldownIsLoading" :milestone="selectedMilestone"
                                   :load-partners="loadPartners"
                                   :drilldown-data="drilldownData"
                                   :start-date="startDate"
                                   :end-date="endDate"
                                   :close-callback="closeDrilldown">

        </CompanyDashboardDrilldown>
      </v-dialog>
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
  import constants from '@/helpers/constants'
  import moment from 'moment'
  import DatetimePickerInput from "@/components/DatetimePickerInput"
  import Snackbar from '@/components/Snackbar.vue'
  import CompanyDashboardDrilldown from './CompanyDashboardDrilldown.vue'
  import { AppMutations } from '@/stores/AppStore'
  import { handleHidingGlobalLoader, getRequestWithParams, getSnackbar } from '@/helpers/helpers'

  export default {
    name: 'companyDashboard',
    components: {
      DatetimePickerInput,
      CompanyDashboardDrilldown,
      Snackbar
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
        endDate: moment().format('YYYY-MM-DD'),
        weekNum: 1,
        currentPeriod: Math.ceil(moment().isoWeek() / 4),
        dateRanges: ['Yesterday', 'Today', 'Tomorrow', 'Current Week', 'Current Period', 'Last Week', 'Last Period', 'Custom', 'This Month', 'This Year', 'All Time'],
        isLoading: true,
        drilldownIsLoading: true,
        dashValues: [],
        drilldownData: [],
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
    computed: {
      visibleHeaders () {
        return this.headers.filter(header => header.show === true)
      },
      additionalStartWeek () {
        if (this.currentPeriod > 9) {
          return 1;
        }
        return 0;
      },
      additionalEndWeek () {
        if (this.currentPeriod === 9 || this.currentPeriod === 12) {
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
        if (this.currentPeriod === 10 || this.currentPeriod === 1) {
          return 1;
        }
        return 0;
      },
      momentStartOfPeriod () {
        return moment().startOf('isoWeek').isoWeek((this.currentPeriod) * 4 - 1 + this.additionalStartWeek)
      },
      startOfPeriod () {
        return moment().startOf('isoWeek').isoWeek((this.currentPeriod) * 4 - 1 + this.additionalStartWeek).format('YYYY-MM-DD')
      },
      endOfPeriod () {
        return moment(this.momentStartOfPeriod).clone().add(3 + this.additionalEndWeek, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
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
      closeDrilldown() {
        this.selectedMilestone = {}
        this.drilldownData = []
        this.loadPartners = false
        this.drilldownIsLoading = false
        this.showDrilldown = false
      },
      async openDrilldown(item, loadPartners) {
        this.selectedMilestone = item
        this.loadPartners = loadPartners
        await this.getDrilldownData()
        this.showDrilldown = true
      },
      async getDrilldownData() {
        //i couldn't get the v-dialog to reload the data every time it opened so i load it here but this is dumb
        this.drilldownIsLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          const params = {
            startDate: this.startDate,
            endDate: this.endDate,
            milestoneTypeId: this.selectedMilestone.milestone_type_id,
            loadPartners: this.loadPartners
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
          case 'Last Period':
            this.momentStartOfLastPeriod = moment().clone().startOf('isoWeek').isoWeek((this.currentPeriod - 1) * 4 - 1 + this.additionalStartWeekLastPeriod)
            this.startDate = moment().clone().startOf('isoWeek').isoWeek((this.currentPeriod - 1) * 4 - 1 + this.additionalStartWeekLastPeriod).format('YYYY-MM-DD')
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

        this.singleDateRange = this.singleDateRanges.includes(this.selectedDateRange)
        this.targetTypeId = this.singleDateRange ? 1 :
          this.loadTargetsRanges.includes(this.selectedDateRange) ? 2 : null

        try {
          this.$store.commit(AppMutations.SET_LOADING, true)

          const params = {
            startDate: this.startDate,
            endDate: this.endDate,
            targetTypeId: this.targetTypeId
          }

          const {data, status} = await getRequestWithParams('/companyDashboard/dashboardValues', {params}, 'blueraven', [])
          this.dashValues = data

          this.isLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    },
    created () {
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
  .date-range-dropdown {
    min-width: 200px;
  }

  #company-dash-container {
    overflow: auto;
  }

  #company-dash-toolbar-container {
    margin: 0 auto;

    #company-dash-toolbar {
      display: flex;
      flex-flow: row nowrap;
      justify-content: space-between;
      padding: 0;

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

          .dash-btn {
            box-shadow: none;
            font-size: 14px;
            font-weight: 500;
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
    margin: 0 auto 12px auto !important;

    #main-table-header {
      #milestone-col-header {
        text-align: left;
      }

      tr:hover {
        background-color: initial !important;
      }

      th {
        border-top: 3px solid var(--v-primary-base);
        border-bottom: none;
        color: var(--v-primaryText-base);
        font-size: 12px !important;
        text-align: center;
        padding-top: 10px;
      }
    }

    .light-blue-row {
      background-color: var(--v-primary-lighten9);

      &:hover {
        background-color: var(--v-primary-lighten9);
      }
    }

    .blue-row {
      background-color: var(--v-primary-lighten8);
      font-weight: bold;

      &:hover {
        background-color: var(--v-primary-lighten8);
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
        border-left: 2px solid var(--v-primary-base) !important;
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
        text-align: center;
        font-size: 10px;
      }

      .pos_diff > span {
        color: var(--v-primaryText-base);
      }

      .neg_diff > span {
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
      border-top-width: 546px;
      border-left: 40px solid transparent;
      border-right: 40px solid transparent;
      margin-top: -546px;
      margin-bottom: -48px;
      left: 9px;
      width: 250px;
      height: 0;
    }

    #company-dash-table {
      margin: 0 auto 24px auto !important;

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

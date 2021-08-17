<template>
  <v-container class="app-container">
    <v-dialog v-model="showModal" max-width="1300">
      <ProductionStatsDrilldown
                      :start-date="startDate"
                      :end-date="endDate"
                      :title="drilldownTitle"
                      :drilldown-data="drilldownData"
                      @prodStatsDrilldownDialogClosed="showModal = false"
      ></ProductionStatsDrilldown>
    </v-dialog>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Installer Dashboard</v-toolbar-title>
        </v-toolbar>
        <v-divider class="mt-3"/>
        <v-row class="px-4">
          <v-col cols="3" md="2">
            <v-autocomplete v-model="selectedRegionalManagers"
                            :items="regionalManagers"
                            label="Regional Installation Manager"
                            multiple
                            clearable
                            return-object
                            item-text="fullName"
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
              <span v-if="index === 0" class="primary--text caption">
                {{ selectedRegionalManagers.length }} selected
              </span>
              </template>
            </v-autocomplete>
          </v-col>
          <v-col cols="3" md="2">
            <v-autocomplete v-model="selectedInstallationCrews"
                            :items="installationCrew"
                            label="Installation Crews"
                            multiple
                            clearable
                            return-object
                            item-text="fullName">
              <v-list-item
                slot="prepend-item"
                ripple
                @click="toggleSelectAllCrews()"
              >
                <v-list-item-action>
                  <v-icon>{{ iconCrews }}</v-icon>
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
              <span v-if="index === 0" class="primary--text caption">
                {{ selectedInstallationCrews.length }} selected
              </span>
              </template>
            </v-autocomplete>
          </v-col>
          <v-col cols="3" md="2">
            <v-select attach class="date-range-dropdown" py-2
                      v-model="selectedDateRange"
                      :items="dateRanges"
                      label="Date Range"
                      @change="setDateRange()"
                      hide-details
            ></v-select>
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
            <v-btn color="primaryCustom" class="white--text"
                   :disabled="selectedInstallationCrews.length < 1"
                   @click="getDashboardValues()">Go</v-btn>
          </v-col>
        </v-row>
        <v-row>
          <v-toolbar flat class="app-toolbar">
            <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Production Stats</v-toolbar-title>
          </v-toolbar>
        </v-row>
        <v-row>
          <v-card tile v-for="stat in dashValues" class="ma-3 flex-display card-main"
                  width="200" height="100" >
            <div class="card-accent" :style="{'background-color': 'white'}"></div>
              <v-card-text class="pt-1 stats-tile" @click="drilldownTitle = stat.name; drilldownData= stat.drilldownData; showModal = true">
                <div class="text-left">{{stat.name}}</div>
                <div class="card-count">{{stat.value}}</div>
              </v-card-text>
          </v-card>
        </v-row>
        <v-row>
          <v-toolbar flat class="app-toolbar">
            <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">WIP</v-toolbar-title>
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
                <div class="text-left">{{wq.workQueueType}}</div>
                <div class="card-count">{{wq.workQueueCount}}</div>
              </router-link>
            </v-card-text>
          </v-card>
        </v-row>
      </v-col>
    </v-row>
    <v-row>
      <v-toolbar flat class="app-toolbar">
        <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Key Performance Metrics</v-toolbar-title>
      </v-toolbar>
      <v-col cols="3" md="2">
        <v-select attach class="date-range-dropdown" py-2
                  v-model="metricsSelectedDateRange"
                  :items="dateRanges"
                  label="Date Range"
                  @change="setMetricsDateRange()"
                  hide-details
        ></v-select>
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
          <v-btn
            color="primaryCustom"
            class="white--text mr-2 mb-3"
            @click="getPerformanceMetrics"
          >
            Go
          </v-btn>
      </v-col>
    </v-row>

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


<script>
  import {AppMutations} from '@/stores/AppStore'

  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
  import moment from "moment";
  import constants from '@/helpers/constants'
  import ProductionStatsDrilldown from "./ProductionStatsDrilldown"
  import cloneDeep from "lodash.clonedeep";

  export default {
    name: 'InstallerDashboard',
    components: {
      DatetimePickerInput,
      ProductionStatsDrilldown
    },
    data() {
      return {
        snackbar: {},
        constants,
        model: {},
        workQueues: [],
        regionalManagers: [],
        installationCrew: [],
        expanded: [],
        selectedUserPosition: {},
        selectedRegionalManagers: [],
        selectedInstallationCrews: [],
        selectedDateRange: 'Current Week',
        metricsSelectedDateRange: 'Current Period',
        startDate: moment().format('YYYY-MM-DD'),
        endDate: moment().format('YYYY-MM-DD'),
        metricsStartDate: moment().format('YYYY-MM-DD'),
        metricsEndDate: moment().format('YYYY-MM-DD'),
        weekNum: 1,
        currentPeriod: Math.ceil(moment().isoWeek() / 4),
        timezone: 'US/Mountain',
        dateRanges: ['Yesterday', 'Today', 'Current Week', 'Current Period', 'Last Week', 'Last Period', 'Custom', 'This Month', 'This Year', 'All Time'],
        workQueueOwners: [],
        dashValues: [],
        performanceMetrics: [],
        drilldownTitle: '',
        drilldownData: [],
        headers: [
          { text: 'Rank', value: 'rnk', width: 80, show: true },
          { text: 'Crew', value: 'crewname', width: 80, show: true },
          { text: 'Substantial Completions kW', value: 'substantialcompletions', width: 80, show: true },
          { text: 'Inspection Pass Rate', value: 'inspectionapproval', width: 80, show: true },
          { text: 'Score (kw x Pass rate)', value: 'score', width: 80, show: true },
        ],
        showModal: false
      }
    },
    computed: {
      selectAllManagers () {
        return this.regionalManagers.length === this.selectedRegionalManagers.length
      },
      selectSomeManagers () {
        return this.selectedRegionalManagers.length > 0 && !this.selectAllManagers
      },
      iconManagers () {
        if (this.regionalManagers.length === this.selectedRegionalManagers.length) {
          return 'check_box'
        }
        if (this.selectSomeManagers) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      selectAllCrews () {
        return this.installationCrew.length === this.selectedInstallationCrews.length
      },
      selectSomeCrews () {
        return this.selectedInstallationCrews.length > 0 && !this.selectAllCrews
      },
      iconCrews () {
        if (this.installationCrew.length === this.selectedInstallationCrews.length) {
          return 'check_box'
        }
        if (this.selectSomeCrews) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
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
        return moment().startOf('W').format('YYYY-MM-DD')
      },
      endOfWeek () {
        return moment().endOf('W').format('YYYY-MM-DD')
      },
      installationCrewIds() {
        return this.selectedInstallationCrews?.length > 0 ? this.selectedInstallationCrews.map(u => u.positionId) : [];
      }
    },
    async created() {
      this.setDateRange()
      this.setMetricsDateRange()
      this.getRegionalManagers()
    },
    methods: {
      toggleSelectAllManagers () {
        this.$nextTick(() => {
          if (this.selectAllManagers) {
            this.selectedRegionalManagers = []
          } else {
            this.selectedRegionalManagers = cloneDeep(this.regionalManagers)
            this.getInstallationCrew();
          }
        })
      },
      toggleSelectAllCrews () {
        this.$nextTick(() => {
          if (this.selectAllCrews) {
            this.selectedInstallationCrews = []
          } else {
            this.selectedInstallationCrews = cloneDeep(this.installationCrew)
          }
        })
      },
      async getRegionalManagers() {
        try {
          const {data} = await getRequest(`/installerDashboard/regionalManagers`)
          this.regionalManagers = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving Regional Managers')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getInstallationCrew() {
        try {
          let regionalManagersIds = this.selectedRegionalManagers?.length > 0 ? this.selectedRegionalManagers.map(u => u.positionId) : [];
          if (regionalManagersIds.length < 1) {
            return;
          }

          const {data} = await getRequest(`/installerDashboard/installationCrew/`+ regionalManagersIds)
          this.installationCrew = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving Installation Crew')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getDashboardValues() {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const params = {
            startDate: this.startDate,
            endDate: this.endDate
          }

          const {data} = await getRequestWithParams('/installerDashboard/dashboardValues/' + this.installationCrewIds, {params})
          this.dashValues = data

          this.getWipValues();
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getWipValues() {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data} = await getRequest('/installerDashboard/wipValues/' + this.installationCrewIds)
          this.workQueues = data

          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving WIP data')
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPerformanceMetrics() {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)

          const params = {
            startDate: this.metricsStartDate,
            endDate: this.metricsEndDate
          }

          const {data} = await getRequestWithParams('/installerDashboard/performanceMetrics', {params})
          this.performanceMetrics = data
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
          this.isLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
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
      setMetricsDateRange () {
        switch (this.metricsSelectedDateRange) {
          case 'Yesterday':
            this.metricsStartDate = moment().startOf('day').add(-1, 'days').format('YYYY-MM-DD')
            this.metricsEndDate = moment().endOf('day').add(-1, 'days').format('YYYY-MM-DD')
            break
          case 'Today':
            this.metricsStartDate = moment().startOf('day').format('YYYY-MM-DD')
            this.metricsEndDate = moment().endOf('day').format('YYYY-MM-DD')
            break
          case 'Current Week':
            this.metricsStartDate = this.startOfWeek
            this.metricsEndDate = this.endOfWeek
            break
          case 'Current Period':
            this.metricsStartDate = this.startOfPeriod
            this.metricsEndDate = this.endOfPeriod
            break
          case 'Last Week':
            this.metricsStartDate = moment(this.momentStartOfPeriod).clone().add((this.weekNum - 2), 'weeks').startOf('isoWeek').format('YYYY-MM-DD')
            this.metricsEndDate = moment(this.momentStartOfPeriod).clone().add((this.weekNum - 2), 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
            break
          case 'Last Period':
            this.momentStartOfLastPeriod = moment().clone().startOf('isoWeek').isoWeek((this.currentPeriod - 2) * 4 + 1)
            this.metricsStartDate = moment().clone().startOf('isoWeek').isoWeek((this.currentPeriod - 2) * 4 + 1).format('YYYY-MM-DD')
            this.metricsEndDate = moment(this.momentStartOfLastPeriod).clone().add(3, 'weeks').endOf('isoWeek').format('YYYY-MM-DD')
            break
          case 'Custom':
            this.metricsStartDate = moment(this.startDate).format('YYYY-MM-DD')
            this.metricsEndDate = moment(this.startDate).format('YYYY-MM-DD')
            break
          case 'This Month':
            this.metricsStartDate = moment().startOf('month').format('YYYY-MM-DD')
            this.metricsEndDate = moment().endOf('month').format('YYYY-MM-DD')
            break
          case 'This Year':
            this.metricsStartDate = moment().startOf('year').format('YYYY-MM-DD')
            this.metricsEndDate = moment().format('YYYY-MM-DD')
            break;
          case 'All Time':
            this.metricsStartDate = moment('2000-01-01').format('YYYY-MM-DD')
            this.metricsEndDate = moment().format('YYYY-MM-DD')
            break
          default:
            this.metricsStartDate = this.startOfWeek
            this.metricsEndDate = this.endOfWeek
            break
        }
      },
      setDateRangeCustom (isMetricDateRange) {
        if (isMetricDateRange) {
          this.metricsSelectedDateRange = 'Custom'
        }
        else {
          this.selectedDateRange = 'Custom'
        }
      }
    },

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
  color: #666666;
}
.stats-tile {
  cursor: pointer;
}
</style>

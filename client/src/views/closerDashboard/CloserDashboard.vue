<template>
  <v-container id="closer-dash-container">
    <v-row v-if="showDashboard" id="closer-dash-toolbar-container">
      <v-col cols="12" id="closer-dash-toolbar">
        <v-toolbar class="elevation-1">
          <v-btn-toggle v-model="timeIntervalBtnGroup" mandatory>
            <v-btn text @click="loadRankingTables('MTD')">MTD</v-btn>
            <v-btn text @click="loadRankingTables('60 days')" class="text-lowercase">60 days</v-btn>
            <v-btn text @click="loadRankingTables('90 days')" class="text-lowercase">90 days</v-btn>
            <v-btn text @click="loadRankingTables('YTD')">YTD</v-btn>
          </v-btn-toggle>
        </v-toolbar>
      </v-col>
    </v-row>

    <v-row id="closer-dash-tabs" class="mb-2" justify="center" no-gutters :class="{'mt-3': showDashboard}">
      <v-col cols="12">
        <span class="clickable" :class="{'font-weight-bold': showDashboard}" @click="switchTabs(1)">
          Dashboard
        </span>
        <div class="tab-separator mx-2"></div>
        <span class="clickable" :class="{'font-weight-bold': showFunnel}" @click="switchTabs(2)">
          Funnel
        </span>
      </v-col>
    </v-row>

    <!---------------------------------- DASHBOARD TAB START ---------------------------------->
    <!-- IRONMAN START -->
    <v-row v-if="showDashboard" class="mb-6" justify="center" no-gutters>
      <v-col cols="12" id="ironman-container">
        <v-card id="ironman-component" class="mb-4 pb-4">
          <img id="ironman-banner-mobile" src="../../assets/ironman_banner_mobile.png" alt="Mobile version of Ironman competition banner">
          <img id="ironman-banner" src="../../assets/ironman_banner.png"  alt="Desktop version of Ironman competition banner">
          <div id="milestones-container">
            <div id="swim-phase" class="milestone" :class="{'active-milestone': is_q1}"
                 @click="milestoneDrilldown(1)">
              <span class="milestone-top-label">SWIM</span>
              <div class="milestone-content mt-1">
                <div class="milestone-content-labels">
                  <span class="milestone-left-label" :style="{'letter-spacing': q1_upper_label === '——' ? '0.1em' : ''}">{{ q1_upper_label }}</span>
                  <span class="milestone-top-right-label">{{ fdcCounts.q1 }} FDC</span>
                </div>
                <div class="milestone-content-labels">
                  <span class="milestone-bottom-right-label">
                    {{ q1_points === 1 ? q1_points + ' Point' : q1_points + ' Points' }}
                  </span>
                </div>
                <img src="../../assets/ironman_swim_icon.png" alt="A person swimming">
              </div>
              <span v-if="is_q1" class="milestone-bottom-label">{{ q1_lower_label }}</span>
            </div>

            <div id="bike-phase" class="milestone" :class="{'active-milestone': is_q2}"
                 @click="milestoneDrilldown(2)">
              <span class="milestone-top-label">BIKE</span>
              <div class="milestone-content mt-1">
                <div class="milestone-content-labels">
                  <span class="milestone-left-label" :style="{'letter-spacing': q2_upper_label === '——' ? '0.1em' : ''}">{{ q2_upper_label }}</span>
                  <span v-if="currentQuarter > 1" class="milestone-top-right-label">{{ fdcCounts.q2 }} FDC</span>
                </div>
                <div class="milestone-content-labels">
                  <span v-if="currentQuarter > 1" class="milestone-bottom-right-label">
                    {{ q2_points === 1 ? q2_points + ' Point' : q2_points + ' Points' }}
                  </span>
                </div>
                <img src="../../assets/ironman_bike_icon.png" alt="A person riding a bike">
              </div>
              <span v-if="is_q2" class="milestone-bottom-label">{{ q2_lower_label }}</span>
            </div>

            <div id="run-phase" class="milestone" :class="{'active-milestone': is_q3}"
                 @click="milestoneDrilldown(3)">
              <span class="milestone-top-label">RUN</span>
              <div class="milestone-content mt-1">
                <div class="milestone-content-labels">
                  <span class="milestone-left-label" :style="{'letter-spacing': q3_upper_label === '——' ? '0.1em' : ''}">{{ q3_upper_label }}</span>
                  <span v-if="currentQuarter > 2" class="milestone-top-right-label">{{ fdcCounts.q3 }} FDC</span>
                </div>
                <div class="milestone-content-labels">
                  <span v-if="currentQuarter > 2" class="milestone-bottom-right-label">
                    {{ q3_points === 1 ? q3_points + ' Point' : q3_points + ' Points' }}
                  </span>
                </div>
                <img src="../../assets/ironman_run_icon.png" alt="A person running">
              </div>
              <span v-if="is_q3" class="milestone-bottom-label">{{ q3_lower_label }}</span>
            </div>

            <div id="finish-phase" class="milestone" :class="{'active-milestone': is_q4}"
                 @click="milestoneDrilldown(4)">
              <span class="milestone-top-label">FINISH</span>
              <div class="milestone-content mt-1">
                <div class="milestone-content-labels">
                  <span class="milestone-left-label" :style="{'letter-spacing': q4_upper_label === '——' ? '0.1em' : ''}">{{ q4_upper_label }}</span>
                  <span v-if="currentQuarter > 3" class="milestone-top-right-label">{{ fdcCounts.q4 }} FDC</span>
                </div>
                <div class="milestone-content-labels">
                  <span v-if="currentQuarter > 3" class="milestone-bottom-right-label">
                    {{ q4_points === 1 ? q4_points + ' Point' : q4_points + ' Points' }}
                  </span>
                </div>
                <img src="../../assets/ironman_finish_icon.png" alt="A person crossing a finish line">
              </div>
              <span v-if="is_q4" class="milestone-bottom-label">{{ q4_lower_label }}</span>
            </div>
          </div>

          <div id="progress-bar-container">
            <span>Cumulative Point Total</span>
            <div id="progress-bar">
              <div id="first-segment" class="progress-bar-segment"></div>
              <div id="second-segment" class="progress-bar-segment"></div>
              <div id="third-segment" class="progress-bar-segment"></div>
              <div id="fourth-segment" class="progress-bar-segment"></div>
              <div id="fifth-segment" class="progress-bar-segment"></div>
              <div id="sixth-segment" class="progress-bar-segment"></div>
              <div id="seventh-segment" class="progress-bar-segment"></div>
              <div id="eighth-segment" class="progress-bar-segment">
                <img v-if="!progressBarIsFull" src="../../assets/progress_bar_icon_blue.png"
                     alt="Blue Raven Solar logo in blue">
                <img v-if="progressBarIsFull" src="../../assets/progress_bar_icon_white.png"
                     alt="Blue Raven Solar logo in white">
              </div>
              <div id="progress-bar-fill" :style="{borderRadius: progressBarIsFull ? '5px' : '5px 0 0 5px'}"></div>
            </div>
          </div>
        </v-card>
      </v-col>
    </v-row>

    <v-dialog v-model="milestoneDialog" max-width="950">
      <v-card>
        <v-card-title class="mb-1">
          <span id="drilldown-title">{{ milestoneDrilldownTitle }}</span>
        </v-card-title>

        <v-card-text>
          <v-data-table
            id="drilldown-table"
            :headers="headers"
            :items="drilldownData"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            fixed-header
            dense
            hide-default-footer
            class="elevation-1"
          >
            <template v-if="drilldownData.length > 0" #item="{ item, index }" class="table-body">
              <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
                <td class="text-left">{{ index + 1 }}</td>
                <td class="text-left">{{ item.customer_name ? item.customer_name : '' }}</td>
                <td class="text-left">{{ item.id ? item.id : '' }}</td>
                <td class="text-left">{{ item.source_name ? item.source_name : '' }}</td>
                <td class="text-left">{{ item.system_size ? item.system_size : '' }}</td>
                <td class="text-left">
                  {{ item.final_design_signed_date_formatted ? item.final_design_signed_date_formatted : '' }}
                </td>
                <td class="text-left">
                  {{ item.agreement_signed_date_formatted ? item.agreement_signed_date_formatted : '' }}
                </td>
                <td class="text-left">{{ item.financier ? item.financier : '' }}</td>
              </tr>
            </template>

            <template #no-data>
              <div v-if="(currentQuarter < 4) && (selectedQuarter > currentQuarter)" class="my-3">
                Data is not yet available for the selected quarter.
              </div>
              <div v-else class="my-3">
                No data is available for the selected quarter.
              </div>
            </template>
          </v-data-table>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn class="white--text text-capitalize mr-4 mb-2" color="primaryButton"
                 @click="milestoneDialog = false">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <!-- IRONMAN END -->

    <!-- RANKING TABLES FIRST HEADER START -->
    <div v-if="showDashboard && leadAllocationRankingData.length > 0 && officeFdcRankingData.length > 0"
         class="ranking-tables-section-header">
      Your Office Ranking
    </div>
    <!-- RANKING TABLES FIRST HEADER END -->

    <!-- RANKING TABLES TOP ROW START -->
    <div v-if="showDashboard && leadAllocationRankingData.length > 0 && officeFdcRankingData.length > 0"
         class="ranking-tables-section">
      <!-- OFFICE LEAD ALLOCATION RANK START -->
      <div class="ranking-table">
        <div class="ranking-table-header">
          <img class="ranking-table-icon left-text" src="../../assets/sort_desc_icon.png"
               alt="Gray descending sort icon with an arrow pointing downward">
          <span>Office Lead Allocation Rank</span>
        </div>

        <table v-if="leadAllocationRankingData.length > 0">
          <tr>
            <th class="center-text">Rank</th>
            <th></th>
            <th class="left-text">Rep</th>
            <th class="center-text">Lead-Gen FDC %</th>
            <th class="center-text">Self-Gen FDC</th>
            <th class="center-text">Average Availability</th>
            <th class="center-text">Lead Allocation %</th>
          </tr>

          <tr v-for="(row, index) in leadAllocationRankingData" :key="index"
              :class="{'highlight-user-row': row.userId === currentUserId}">
            <td class="center-text">{{ row.rank }}</td>
            <td class="user-img-col">
              <img v-if="row.userImageUrl" class="ranking-table-img default-img"
                   :src="row.userImageUrl" :alt="row.userImageAltText">
              <img v-else class="ranking-table-img default-img"
                   src="../../assets/user_img_placeholder.png" :alt="row.userImageAltText">
            </td>
            <td class="left-text">{{ row.name }}</td>
            <td class="center-text">{{ row.leadGenFdcPercentage }}%</td>
            <td class="center-text">{{ row.selfGenFdc }}</td>
            <td class="center-text">{{ row.avgAvailability }}</td>
            <td class="center-text">{{ row.leadAllocationPercentage }}%</td>
          </tr>
        </table>
        <div v-else class="ranking-tables-no-data left-text">
          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
        </div>
      </div>
      <!-- OFFICE LEAD ALLOCATION RANK END -->

      <!-- OFFICE FDC RANK START -->
      <div class="ranking-table">
        <div class="ranking-table-header">
          <img class="ranking-table-icon" src="../../assets/down_arrows_icon_lighter.png"
               alt="Gray icon with two arrows pointing downward">
          <span>Office FDC Rank</span>
        </div>

        <table v-if="officeFdcRankingData.length > 0">
          <tr>
            <th class="center-text">Rank</th>
            <th></th>
            <th class="left-text">Rep</th>
            <th class="center-text">Lead-Gen FDC %</th>
            <th class="center-text">Self-Gen FDC</th>
            <th class="center-text">Total FDC</th>
          </tr>

          <tr v-for="(row, index) in officeFdcRankingData" :key="index"
              :class="{'highlight-user-row': row.userId === currentUserId}">
            <td class="center-text">{{ row.rank }}</td>
            <td class="user-img-col">
              <img v-if="row.userImageUrl" class="ranking-table-img default-img"
                   :src="row.userImageUrl" :alt="row.userImageAltText">
              <img v-else class="ranking-table-img default-img"
                   src="../../assets/user_img_placeholder.png" :alt="row.userImageAltText">
            </td>
            <td class="left-text">{{ row.name }}</td>
            <td class="center-text">{{ row.leadGenFdcPercentage }}%</td>
            <td class="center-text">{{ row.selfGenFdc }}</td>
            <td class="center-text">{{ row.totalFdc }}</td>
          </tr>
        </table>
        <div v-else class="ranking-tables-no-data left-text">
          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
        </div>
      </div>
      <!-- OFFICE FDC RANK END -->
    </div>
    <!-- RANKING TABLES TOP ROW END -->

    <!-- RANKING TABLES SECOND HEADER START -->
    <div v-if="showDashboard && officeRankingData.length > 0 && topRepsData.length > 0"
         class="ranking-tables-section-header">
      Company Ranking
    </div>
    <!-- RANKING TABLES SECOND HEADER END -->

    <!-- RANKING TABLES BOTTOM ROW START -->
    <div v-if="showDashboard && officeRankingData.length > 0 && topRepsData.length > 0"
         class="ranking-tables-section">
      <!-- OFFICE RANKING START -->
      <div class="ranking-table">
        <div class="ranking-table-header">
          <img class="ranking-table-icon" src="../../assets/office_icon.png" alt="Gray house icon">
          <span>Office Ranking</span>
        </div>

        <table v-if="officeRankingData.length > 0">
          <tr>
            <th class="center-text">Rank</th>
            <th class="left-text">Office</th>
            <th class="left-text">Metro Area</th>
            <th class="left-text">Region</th>
            <th class="center-text">Lead-Gen FDC %</th>
            <th class="center-text">Self-Gen FDC</th>
            <th class="center-text">Total FDC</th>
          </tr>

          <tr v-for="(row, index) in officeRankingData" :key="index"
              :class="{'highlight-user-row': row.officeName === userOffice}">
            <td class="center-text">{{ row.rank }}</td>
            <td class="left-text">{{ row.officeName }}</td>
            <td class="left-text">{{ row.metroArea }}</td>
            <td class="left-text">{{ row.region }}</td>
            <td class="center-text">{{ row.leadGenFdcPercentage }}%</td>
            <td class="center-text">{{ row.selfGenFdc }}</td>
            <td class="center-text">{{ row.totalFdc }}</td>
          </tr>
        </table>
        <div v-else class="ranking-tables-no-data left-text">
          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
        </div>
      </div>
      <!-- OFFICE RANKING END -->

      <!-- TOP REPS START -->
      <div class="ranking-table">
        <div class="ranking-table-header" id="top-reps-table-header">
          <div>
            <img class="ranking-table-icon default-img"
                 src="../../assets/user_img_placeholder.png"
                 alt="User photo placeholder">
            <span>Top Reps</span>
          </div>
          <input type="text" placeholder="Search" v-model="searchText">
        </div>

        <table v-if="topRepsData.length > 0">
          <tr>
            <th class="center-text">Rank</th>
            <th></th>
            <th class="left-text">Rep</th>
            <th class="left-text">Office</th>
            <th class="left-text">Metro Area</th>
            <th class="center-text">Lead-Gen FDC %</th>
            <th class="center-text">Self-Gen FDC</th>
            <th class="center-text">Total FDC</th>
          </tr>

          <tr v-for="(row, index) in filteredTopRepsData.slice(0, userRow && !searchText ? numOffices - 1 : numOffices)"
              :key="index"
              :class="{'highlight-user-row': row.userId === currentUserId}">
            <td class="center-text">{{ row.rank }}</td>
            <td class="user-img-col">
              <img v-if="row.userImageUrl" class="ranking-table-img default-img"
                   :src="row.userImageUrl" :alt="row.userImageAltText">
              <img v-else class="ranking-table-img default-img"
                   src="../../assets/user_img_placeholder.png" :alt="row.userImageAltText">
            </td>
            <td class="left-text">{{ row.name }}</td>
            <td class="left-text">{{ row.officeName }}</td>
            <td class="left-text">{{ row.metroArea }}</td>
            <td class="center-text">{{ row.leadGenFdcPercentage }}%</td>
            <td class="center-text">{{ row.selfGenFdc }}</td>
            <td class="center-text">{{ row.totalFdc }}</td>
          </tr>
          <tr v-if="userRow && !searchText"
              class="highlight-user-row">
            <td class="center-text">{{ userRow.rank }}</td>
            <td class="user-img-col">
              <img v-if="userRow.userImageUrl" class="ranking-table-img default-img"
                   :src="userRow.userImageUrl" :alt="userRow.userImageAltText">
              <img v-else class="ranking-table-img default-img"
                   src="../../assets/user_img_placeholder.png" :alt="userRow.userImageAltText">
            </td>
            <td class="left-text">{{ userRow.name }}</td>
            <td class="left-text">{{ userRow.officeName }}</td>
            <td class="left-text">{{ userRow.metroArea }}</td>
            <td class="center-text">{{ userRow.leadGenFdcPercentage }}%</td>
            <td class="center-text">{{ userRow.selfGenFdc }}</td>
            <td class="center-text">{{ userRow.totalFdc }}</td>
          </tr>
        </table>
        <div v-else class="ranking-tables-no-data left-text">
          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
        </div>
      </div>
      <!-- TOP REPS END -->
    </div>
    <!-- RANKING TABLES BOTTOM ROW END -->
    <!---------------------------------- DASHBOARD TAB END ---------------------------------->

    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import groupBy from 'lodash.groupby'
  import orderBy from 'lodash.orderby'
  import $ from 'jquery'
  import moment from 'moment'
  import Snackbar from '@/components/Snackbar.vue'
  import { getRequest, getRequestWithParams, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'

  export default {
    name: 'closerDashboard',
    components: {
      Snackbar
    },
    data: () => ({
      snackbar: {},
      milestoneDialog: false,
      currentUserId: null,
      selectedQuarter: 1,
      headers: [
        { text: '', value: '', show: true, sortable: false },
        { text: 'Name', value: 'customer_name', show: true },
        { text: 'Deal ID', value: 'id', show: true },
        { text: 'Source', value: 'source_name', show: true },
        { text: 'System Size', value: 'system_size', show: true },
        { text: 'FD Signed Date', value: 'final_design_signed_date', show: true },
        { text: 'Agreement Signed Date', value: 'agreement_signed_date', show: true },
        { text: 'Financier', value: 'financier', show: true }
      ],
      drilldownData: [],
      timeIntervalBtnGroup: 0,
      timeIntervalString: 'MTD', // MTD is selected by default
      timeInterval: +moment().format('DD'),
      tabNum: 1, // Dashboard tab is selected by default
      showDashboard: true,
      showFunnel: false,
      ironmanLoaded: false,
      rankingTablesLoaded: false,
      dashboardWasLoaded: false,
      funnelWasLoaded: false,
      currentQuarter: moment().quarter(),
      fdcCounts: {q1: 0, q2: 0, q3: 0, q4: 0},
      q1_points: 0,
      q2_points: 0,
      q3_points: 0,
      q4_points: 0,
      q1_background: '',
      q2_background: '',
      q3_background: '',
      q4_background: '',
      q1_upper_label: '——',
      q2_upper_label: '——',
      q3_upper_label: '——',
      q4_upper_label: '——',
      q1_lower_label: '',
      q2_lower_label: '',
      q3_lower_label: '',
      q4_lower_label: '',
      percentAchieved: 0,
      progressBarIsFull: false,
      rankingData: [],
      searchText: '',
      leadAllocationRankingData: [],
      officeFdcRankingData: [],
      officeRankingData: [],
      topRepsData: [],
      userOffice: '',
      userRow: [],
      userRowIndex: -1,
      numOffices: 0
    }),
    computed: {
      is_q1 () { return this.currentQuarter === 1 },
      is_q2 () { return this.currentQuarter === 2 },
      is_q3 () { return this.currentQuarter === 3 },
      is_q4 () { return this.currentQuarter === 4 },
      milestoneDrilldownTitle () {
        return this.$store.state.user.details.firstName + ' ' + this.$store.state.user.details.lastName + ' | Final Designs Completed - Q' + this.selectedQuarter
      },
      filteredTopRepsData () {
        if (this.searchText) {
          return this.topRepsData.filter(r => {
            return (r.name + r.officeName + r.metroArea).toLowerCase().includes(this.searchText.toLowerCase())
          })
        } else {
          return this.topRepsData
        }
      }
    },
    watch: {
      // the loading animation kept going away before it was supposed to, so this makes sure that it doesn't do that anymore
      '$store.state.app.loading': function () {
        if (!this.ironmanLoaded || !this.rankingTablesLoaded) {
          this.$store.commit(AppMutations.SET_LOADING, true)
        }
      }
    },
    methods: {
      async switchTabs (tabNum) {
        this.tabNum = tabNum

        switch (tabNum) {
          case 2: // Funnel tab
            this.showDashboard = false
            this.showFunnel = true
            if (!this.funnelWasLoaded) {
              // await this.loadFunnel()
              this.funnelWasLoaded = true
            }
            break
          default: // Dashboard tab
            this.showDashboard = true
            this.showFunnel = false
            if (!this.dashboardWasLoaded) {
              await this.loadIronman()
              await this.loadRankingTables('MTD') // MTD is the default
              this.dashboardWasLoaded = true
            }
        }
      },

      assignCloserRanks (rankingData, fieldName) {
        let currentRank = 1
        let tiedRowNums = []
        rankingData = orderBy(rankingData, fieldName, 'desc')

        // handles ties & assigns rank #'s
        rankingData.forEach((row, index) => {
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
      },

      /* IRONMAN-RELATED CODE START */
      async loadIronman () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.ironmanLoaded = false

        try {
          getRequest('/closerDashboard/getIronmanFdcCounts', 'blueraven').then(res => {
            this.fdcCounts = res.data

            // Calculate points for each quarter
            this.q1_points = this.calcPointsForQuarter(this.fdcCounts.q1)
            this.q2_points = this.calcPointsForQuarter(this.fdcCounts.q2)
            this.q3_points = this.calcPointsForQuarter(this.fdcCounts.q3)
            this.q4_points = this.calcPointsForQuarter(this.fdcCounts.q4)

            // Get milestone backgrounds
            this.q1_background = this.getMilestoneBackground(this.q1_points)
            this.q2_background = this.getMilestoneBackground(this.q2_points)
            this.q3_background = this.getMilestoneBackground(this.q3_points)
            this.q4_background = this.getMilestoneBackground(this.q4_points)

            // Set milestone backgrounds
            $('#swim-phase .milestone-content').addClass(this.q1_background)
            $('#bike-phase .milestone-content').addClass(this.q2_background)
            $('#run-phase .milestone-content').addClass(this.q3_background)
            $('#finish-phase .milestone-content').addClass(this.q4_background)

            // Remove black background for previous quarters where closer has < 10 FDC
            if (this.is_q2) {
              $('#swim-phase .milestone-content').addClass('unranked')
            } else if (this.is_q3) {
              $('#swim-phase .milestone-content, #bike-phase .milestone-content').addClass('unranked')
            } else if (this.is_q4) {
              $('#swim-phase .milestone-content, #bike-phase .milestone-content, #run-phase .milestone-content').addClass('unranked')
            }

            // Get upper milestone labels
            this.q1_upper_label = this.getUpperMilestoneLabel(this.fdcCounts.q1)
            this.q2_upper_label = this.currentQuarter < 2 ? 'April 1' : this.getUpperMilestoneLabel(this.fdcCounts.q2)
            this.q3_upper_label = this.currentQuarter < 3 ? 'July 1' : this.getUpperMilestoneLabel(this.fdcCounts.q3)
            this.q4_upper_label = this.currentQuarter < 4 ? 'October 1' : this.getUpperMilestoneLabel(this.fdcCounts.q4)

            // Get lower milestone labels
            this.q1_lower_label = this.getLowerMilestoneLabel(this.fdcCounts.q1)
            this.q2_lower_label = this.getLowerMilestoneLabel(this.fdcCounts.q2)
            this.q3_lower_label = this.getLowerMilestoneLabel(this.fdcCounts.q3)
            this.q4_lower_label = this.getLowerMilestoneLabel(this.fdcCounts.q4)

            // Fill progress bar based on closer's points for the year
            this.percentAchieved = ((this.q1_points + this.q2_points + this.q3_points + this.q4_points) / 8) * 100
            this.percentAchieved = this.percentAchieved > 100 ? 100 : this.percentAchieved
            this.progressBarIsFull = this.percentAchieved === 100
            $('#progress-bar-fill').css('width', this.percentAchieved + '%')

            this.ironmanLoaded = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          })
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving Ironman data')
          this.ironmanLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      checkWindowWidth () {
        if (window.innerWidth < 1135) {
          $('#swim-phase').css('align-items', 'center')
          $('#bike-phase').css('align-items', 'center')
          $('#run-phase').css('align-items', 'center')
          $('#finish-phase').css('align-items', 'center')
          $('#swim-phase.active-milestone').css('align-items', 'center')
          $('#bike-phase.active-milestone').css('align-items', 'center')
          $('#run-phase.active-milestone').css('align-items', 'center')
          $('#finish-phase.active-milestone').css('align-items', 'center')
        } else {
          if (this.is_q1) {
            $('#swim-phase').css('align-items', 'flex-start')
            $('#bike-phase').css('align-items', 'flex-end')
            $('#run-phase').css('align-items', 'flex-end')
            $('#finish-phase').css('align-items', 'flex-end')
          } else if (this.is_q2) {
            $('#swim-phase').css('align-items', 'flex-start')
            $('#bike-phase').css('align-items', 'center')
            $('#run-phase').css('align-items', 'flex-end')
            $('#finish-phase').css('align-items', 'flex-end')
          } else if (this.is_q3) {
            $('#swim-phase').css('align-items', 'flex-start')
            $('#bike-phase').css('align-items', 'flex-start')
            $('#run-phase').css('align-items', 'center')
            $('#finish-phase').css('align-items', 'flex-end')
          } else {
            $('#swim-phase').css('align-items', 'flex-start')
            $('#bike-phase').css('align-items', 'flex-start')
            $('#run-phase').css('align-items', 'flex-start')
            $('#finish-phase').css('align-items', 'flex-end')
          }
        }
      },

      calcPointsForQuarter (fdcCount) {
        switch (true) {
          case fdcCount >= 10 && fdcCount < 12:
            return 1 // Bronze
          case fdcCount >= 12 && fdcCount < 15:
            return 2 // Silver
          case fdcCount >= 15 && fdcCount < 18:
            return 3 // Gold
          case fdcCount >= 18:
            return 4 // Platinum
          default:
            return 0 // Unranked
        }
      },

      getMilestoneBackground (pointsEarned) {
        switch (pointsEarned) {
          case 1:
            return 'bronze-level'
          case 2:
            return 'silver-level'
          case 3:
            return 'gold-level'
          case 4:
            return 'platinum-level'
          default:
            return ''
        }
      },

      getUpperMilestoneLabel (fdcCount) {
        switch (true) {
          case fdcCount >= 10 && fdcCount < 12:
            return 'BRONZE'
          case fdcCount >= 12 && fdcCount < 15:
            return 'SILVER'
          case fdcCount >= 15 && fdcCount < 18:
            return 'GOLD'
          case fdcCount >= 18:
            return 'PLATINUM'
          default:
            return '——'
        }
      },

      getLowerMilestoneLabel (fdcCount) {
        switch (true) {
          case fdcCount >= 10 && fdcCount < 12:
            return (12 - fdcCount) + ' FDC to get to Silver'
          case fdcCount >= 12 && fdcCount < 15:
            return (15 - fdcCount) + ' FDC to get to Gold'
          case fdcCount >= 15 && fdcCount < 18:
            return (18 - fdcCount) + ' FDC to get to Platinum'
          case fdcCount >= 18:
            return 'Platinum'
          default:
            return (10 - fdcCount) + ' FDC to get to Bronze'
        }
      },

      async milestoneDrilldown (quarter) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          const {data} = await getRequestWithParams('/closerDashboard/finalDesignsCompletedDrilldown', {params: {quarter}}, 'blueraven')
          this.drilldownData = cloneDeep(data)

          if (this.drilldownData.length > 0) {
            this.reformatDates()
          } else {
            this.drilldownData = []
          }

          this.selectedQuarter = quarter
          this.milestoneDialog = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving drilldown data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      reformatDates () {
        this.drilldownData.forEach(row => {
          if (row.final_design_signed_date) {
            row.final_design_signed_date_formatted = moment(row.final_design_signed_date).format('MMM D, YYYY')
          }

          if (row.agreement_signed_date) {
            row.agreement_signed_date_formatted = moment(row.agreement_signed_date).format('MMM D, YYYY')
          }
        })
      },
      /* IRONMAN-RELATED CODE END */

      /* RANKING TABLES-RELATED CODE START */
      async loadRankingTables (timeIntervalString) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.rankingTablesLoaded = false
        this.timeIntervalString = timeIntervalString
        this.rankingData = []
        this.searchText = ''

        switch (timeIntervalString) {
          case 'MTD':
            this.timeInterval = +moment().format('DD') // MTD
            break
          case '60 days':
            this.timeInterval = 60
            break
          case '90 days':
            this.timeInterval = 90
            break
          case 'YTD':
            this.timeInterval = moment().dayOfYear() // YTD
            break
        }

        try {
          const params = {timeInterval: this.timeInterval}
          const {data} = await getRequestWithParams('/closerDashboard/getCloserTableScores', {params}, 'blueraven')

          if (data.companyRankingValues.filter(row => row.userId === this.currentUserId)[0] !== undefined) {
            this.userOffice = data.companyRankingValues.filter(row => row.userId === this.currentUserId)[0].officeName
          }

          this.processRankingData(cloneDeep(data.officeRankingValues), 'Office Lead Allocation Rank')
          this.processRankingData(cloneDeep(data.officeRankingValues), 'Office FDC Rank')
          this.processRankingData(cloneDeep(data.companyRankingValues), 'Office Ranking')
          this.processRankingData(cloneDeep(data.companyRankingValues), 'Top Reps')

          this.rankingTablesLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving ranking table data')
          this.rankingTablesLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      processRankingData (rankingData, currentTable) {
        if (currentTable === 'Office Lead Allocation Rank') {
          let leadAllocationScoreSum = 0
          // let startDate = moment().subtract(3, 'weeks').format('YYYY-MM-DD')
          // let endDate = moment().format('YYYY-MM-DD')
          let userIds = []
          // let closerAvgAvailMap = {}

          rankingData.forEach(row => {
            if (row.userId !== null && row.userId !== undefined) {
              userIds.push(row.userId)
            }
          })

          // TODO: Get closer availability stuff working
          // calculate average availability values for each closer
          if (userIds.length > 0) {
          //   CloserAvailabilityService.getCsvCalendarData(startDate, endDate, userIds).then(resp => {
          //     resp.forEach(closer => {
          //       let avgAvail = 0
          //       if (closer.appointments.length > 0) {
          //         closer.appointments.forEach(appointment => {
          //           // customer appointment
          //           if (!appointment.personal) {
          //             avgAvail++
          //           }
          //         })
          //       }
          //       avgAvail += closer.availabilities.length
          //       closerAvgAvailMap[closer.name] = Math.round(avgAvail / 3)
          //     })
          //
              // populate avgAvailability and calculate leadAllocationScore values
              rankingData.forEach(closer => {
          //       if (closer.name in closerAvgAvailMap) {
          //         closer.avgAvailability = closerAvgAvailMap[closer.name]
          //       } else {
                  closer.avgAvailability = 0
          //       }

                let leadAllocationScore = (closer.leadGenFdcPercentage / 100 * 1000) + (closer.selfGenFdc * 2) + closer.avgAvailability
                leadAllocationScoreSum += leadAllocationScore
                closer.leadAllocationScore = leadAllocationScore
              })

              // calculate leadAllocationPercentage
              rankingData.forEach(closer => {
                if (leadAllocationScoreSum !== 0) {
                  closer.leadAllocationPercentage = Math.round((closer.leadAllocationScore / leadAllocationScoreSum) * 100)
                } else {
                  closer.leadAllocationPercentage = 0
                }
              })

              this.leadAllocationRankingData = this.assignCloserRanks(rankingData, 'leadAllocationPercentage')
            // })
          }
        } else {
          switch (currentTable) {
            case 'Office FDC Rank':
              this.officeFdcRankingData = this.assignCloserRanks(rankingData, 'totalFdc')
              break
            case 'Office Ranking':
              this.officeRankingData = []
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

                this.officeRankingData.push({
                  officeName: rankingData[group][0].officeName,
                  metroArea: rankingData[group][0].metroArea,
                  region: rankingData[group][0].region,
                  leadGenFdcPercentage: Math.round(leadGenFdcPercentageSum / numRepsInGroup),
                  selfGenFdc: selfGenFdcSum,
                  totalFdc: totalFdcSum
                })
              })

              this.officeRankingData = this.assignCloserRanks(this.officeRankingData, 'totalFdc')
              break
            case 'Top Reps':
              this.userRow = null
              this.numOffices = this.officeRankingData.length
              this.topRepsData = this.assignCloserRanks(rankingData, 'totalFdc')

              // determine whether current user's row is one of the visible rows
              this.userRowIndex = this.topRepsData.findIndex(row => row.userId === this.currentUserId)
              if (this.userRowIndex !== -1 && this.userRowIndex > this.numOffices - 1) {
                this.userRow = this.topRepsData.filter(row => row.userId === this.currentUserId)[0]
              }
          }
        }
      }
      /* RANKING TABLES-RELATED CODE END */

      /* FUNNEL-RELATED CODE START */

      /* FUNNEL-RELATED CODE END */
    },
    created () {
      this.currentUserId = this.$store.state.user.details.id
      this.switchTabs(this.tabNum)
    },
    mounted () {
      $(window).bind('resize', this.checkWindowWidth)
      this.checkWindowWidth()
    },
    beforeDestroy () {
      $(window).unbind('resize', this.checkWindowWidth)
    }
  }
</script>

<style lang="scss" scoped>
  #closer-dash-container {
    padding: 0;
    font-family: 'Roboto Condensed', sans-serif !important;
    letter-spacing: 0.02em !important;
  }

  #closer-dash-toolbar-container {
    position: sticky;
    top: 0;
    z-index: 3;

    #closer-dash-toolbar {
      padding: 0;

      .v-toolbar {
        display: flex;
        justify-content: flex-end;
        margin-top: -12px;

        .v-btn-toggle {
          margin-right: -5px;
        }

        .v-btn-toggle .v-btn {
          border: 1px solid var(--v-primaryCustom-base) !important;
          font-size: 11px;
          letter-spacing: 0.02em !important;
          height: 25px;

          &:not(:last-child) {
            border-right: none !important;
          }

          &:hover {
            background-color: var(--v-primaryCustom-base);
            color: #fff !important;
            opacity: 75%;
          }
        }

        .v-btn--active {
          background-color: var(--v-primaryCustom-base);
          color: #fff !important;
        }
      }
    }
  }

  #closer-dash-tabs {
    width: 100%;

    .col-12 {
      display: flex;
      flex-flow: row nowrap;
      justify-content: flex-end;

      span {
        letter-spacing: 0.02em;
        font-size: 11px;
      }

      .tab-separator {
        border-right: 1px solid var(--v-primaryCustom-base);
      }
    }
  }

  #ironman-container {
    display: flex;
    flex-flow: column nowrap;
    align-items: center;
  }

  #ironman-component {
    background: linear-gradient(to bottom, #000000 -50%, #464646 50%);
    width: 100%;

    #ironman-banner-mobile {
      margin-top: 10px;
      margin-bottom: 5px;
      width: 100%;
    }

    #ironman-banner {
      display: none;
    }
  }

  #milestones-container {
    display: flex;
    flex-flow: column nowrap;
    justify-content: center;
    width: 100%;

    .milestone {
      display: flex;
      flex-flow: column nowrap;
      justify-content: center;
      align-items: center;
      width: 100%;
      margin-top: 15px;

      .milestone-top-label {
        display: inline-block;
        text-align: center;
        color: #fff;
        font-size: 11px;
        letter-spacing: 0.03em;
        width: 100%;
      }

      .milestone-content {
        background: linear-gradient(to right, #282828, #151515);
        border: 1px solid black;
        width: 270px;
        height: 150px;
        position: relative;
        text-align: center;
        display: flex;
        flex-flow: column nowrap;
        cursor: pointer;

        .milestone-content-labels {
          display: flex;
          justify-content: space-between;

          .milestone-left-label {
            color: #fff;
            text-align: left;
            font-size: 0.7em;
            margin-top: 2px;
            margin-left: 5px;
          }

          .milestone-top-right-label {
            color: #C6C6C6;
            text-align: right;
            font-size: 0.7em;
            margin-top: 2px;
            margin-right: 5px;
          }

          .milestone-bottom-right-label {
            color: #C6C6C6;
            text-align: right;
            font-size: 0.7em;
            margin-right: 5px;
            width: 100%;
          }
        }

        img {
          position: absolute;
        }
      }

      .milestone-bottom-label {
        display: inline-block;
        text-align: center;
        color: #fff;
        font-size: 12px;
        letter-spacing: 0.03em;
        width: 100%;
        margin-top: 3px;
      }
    }

    #swim-phase img {
      max-width: 190px;
      max-height: 98px;
      top: 27px;
      left: 40px;
    }

    #bike-phase img {
      max-width: 200px;
      max-height: 90px;
      top: 33px;
      left: 35px;
    }

    #run-phase img {
      max-width: 200px;
      max-height: 97px;
      top: 28px;
      left: 57px;
    }

    #finish-phase img {
      max-width: 240px;
      max-height: 117px;
      top: 15px;
      left: 85px;
    }

    .active-milestone {
      .milestone-top-label,
      .milestone-bottom-label {
        font-weight: bold;
        width: 250px;
      }

      .milestone-content {
        background: none;
        border: 1px solid white;
        font-size: 1em;
        width: 300px;
        height: 170px;

        .milestone-content-labels span {
          font-weight: bold;
        }
      }
    }

    #swim-phase.active-milestone img {
      max-width: 200px;
      max-height: 173px;
      top: 30px;
      left: 45px;
    }

    #bike-phase.active-milestone img {
      max-width: 260px;
      max-height: 120px;
      top: 29px;
      left: 18px;
    }

    #run-phase.active-milestone img {
      max-width: 250px;
      max-height: 129px;
      top: 20px;
      left: 53px;
    }

    #finish-phase.active-milestone img {
      max-width: 280px;
      max-height: 138px;
      top: 13px;
      left: 80px;
    }

    .unranked {
      background: none !important;
    }

    .bronze-level {
      background: linear-gradient(60deg, #8D4C22 60%, #472611 95%) !important;
    }

    .silver-level {
      background: linear-gradient(60deg, #9AA5AA 60%, #6B777D 95%) !important;
    }

    .gold-level {
      background: linear-gradient(60deg, #FFCD3E 10%, #584200 95%) !important;
    }

    .platinum-level {
      background: linear-gradient(60deg, #FFFFFF 50%, #787A7A 95%) !important;
    }

    .bronze-level .milestone-content-labels span,
    .silver-level .milestone-content-labels span {
      letter-spacing: 0.03em;
      color: #C6C6C6;
    }

    .gold-level .milestone-content-labels span,
    .platinum-level .milestone-content-labels span {
      letter-spacing: 0.03em;
      color: #212121 !important;
    }
  }

  #progress-bar-container {
    display: flex;
    flex-flow: column nowrap;
    justify-content: space-between;
    margin: 30px auto;
    width: 100%;
    max-width: calc(100% - 50px);
    height: 37px;

    span {
      display: inline-block;
      text-align: left;
      font-size: 12px;
      font-weight: bold;
      letter-spacing: 0.02em;
      color: #fff;
    }

    #progress-bar {
      display: flex;
      flex-flow: row nowrap;
      position: relative;
      border: 0.02em solid black;
      border-radius: 5px;
      height: 15px;
    }

    #progress-bar-fill {
      position: absolute;
      top: 0.02em;
      z-index: 1;
      background: linear-gradient(to right, #164761, #2C8EC2);
      transition: width 1s ease-out;
      opacity: 0.9;
      border-radius: 5px 0 0 5px;
      width: 0;
      height: 14px;
    }

    .progress-bar-segment {
      background-color: #D8D8D8;
      border: 0.02em solid black;
      width: 12.5%;
    }

    #first-segment {
      border-radius: 5px 0 0 5px;
      border: 0.03em solid black;
    }

    #eighth-segment {
      text-align: center;
      border-radius: 0 5px 5px 0;
      border: 0.03em solid black;
    }

    #eighth-segment img {
      position: relative;
      z-index: 2;
      max-width: 20px;
      top: -6px;
    }
  }

  #drilldown-title {
    font-family: "Roboto Condensed", sans-serif;
    font-size: 14px;
  }

  #drilldown-table {
    th, td {
      font-family: "Roboto Condensed", sans-serif;
      font-size: 10px;
    }
  }

  .ranking-tables-section-header {
    color: var(--v-primaryCustom-base);
    text-align: left;
    font-family: "Roboto", sans-serif;
    font-weight: bold;
    font-size: 20px;
    border-bottom: 2px solid var(--v-primaryCustom-base);
    margin: 0 auto 12px auto;
    padding-bottom: 3px;
    width: 100%;
  }

  .ranking-tables-section {
    display: flex;
    flex-flow: column nowrap;
    align-items: center;
    width: 100%;
  }

  .ranking-tables-no-data {
    font-family: "Roboto", sans-serif;
    font-size: 11px;
    padding: 10px 10px 15px 10px;
  }

  .ranking-table {
    font-family: "Roboto", sans-serif;
    background-color: #fff;
    box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
    margin-bottom: 15px;
    overflow-x: auto;
    width: 100%;
  }

  .ranking-table-header {
    display: flex;
    flex-flow: row nowrap;
    color: var(--v-primaryCustom-base);
    font-weight: bold;
    font-size: 16px;
    text-align: left;
    padding: 10px 5px 5px 10px;
  }

  #top-reps-table-header {
    flex-wrap: wrap;
    justify-content: space-between;
    align-items: center;
  }

  #top-reps-table-header div {
    display: flex;
    flex-flow: row nowrap;
    align-items: center;
    padding-right: 3px;
    padding-bottom: 3px;
  }

  #top-reps-table-header input {
    font-weight: normal;
    border: 1px solid #ccc;
    padding-left: 3px;
    margin-right: 5px;
    max-width: 150px;
  }

  .ranking-table-icon {
    margin-right: 4px;
    width: 20px;
    height: 20px;
  }

  .ranking-table table {
    border-collapse: collapse;
    width: 100%;
  }

  .ranking-table th {
    border-bottom: 1px solid #e6eeff;
    color: var(--v-primaryCustom-base);
    font-size: 11px;
    height: 55px;
  }

  .ranking-table td {
    border-bottom: 1px solid #e6eeff;
    font-weight: bold;
    font-size: 10px;
    height: 41px;
  }

  .ranking-table th,
  .ranking-table td {
    padding: 2px 4px;
  }

  .ranking-table .user-img-col {
    padding-top: 6px;
  }

  .ranking-table .center-text {
    text-align: center;
  }

  .ranking-table .left-text {
    text-align: left;
  }

  .highlight-user-row {
    background-color: var(--v-primaryCustom-base);
    color: #fff;
  }

  .ranking-table-img {
    width: 28px;
    height: 28px;
  }

  .default-img {
    background-color: #e9e9e9;
    padding : 1px;
    border-radius: 50%;
  }

  @media (min-width: 500px) {
    #progress-bar-container {
      span {
        font-size: 14px;
      }

      #progress-bar {
        height: 17px;
      }

      #progress-bar-fill {
        height: 16px;
      }

      #eighth-segment img {
        max-width: 22px;
        top: -4px;
      }
    }
  }

  @media (min-width: 737px) {
    #closer-dash-toolbar-container #closer-dash-toolbar .v-toolbar .v-btn-toggle {
      margin-right: 0;

      .v-btn {
        font-size: 12px;
        height: 30px;
      }
    }

    #closer-dash-tabs {
      margin: 0 auto;
      max-width: calc(100% - 50px);

      .col-12 span {
        font-size: 12px;
      }
    }

    #ironman-component {
      box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
      border-radius: 4px;
      max-width: calc(100% - 50px);
      padding: 20px 0;

      #ironman-banner-mobile {
        display: none;
      }

      #ironman-banner {
        display: block;
        width: 100%;
        margin-top: -10px;
        margin-bottom: 20px;
      }
    }

    #milestones-container {
      flex-flow: row wrap;
      margin: 0 auto;
      max-width: calc(100% - 110px);

      .milestone {
        margin-top: 0;
        margin-bottom: 10px;
        width: 300px;

        .milestone-top-label,
        .milestone-bottom-label {
          font-size: 12px;
          width: 220px;
        }

        .milestone-content {
          width: 220px;
          height: 100px;
        }
      }

      #swim-phase img {
        max-width: 140px;
        max-height: 79px;
        top: 12px;
        left: 25px;
      }

      #bike-phase img {
        max-width: 150px;
        max-height: 75px;
        top: 18px;
        left: 25px;
      }

      #run-phase img {
        max-width: 150px;
        max-height: 80px;
        top: 10px;
        left: 45px;
      }

      #finish-phase img {
        max-width: 178px;
        max-height: 93px;
        top: 2px;
        left: 65px;
      }

      .active-milestone .milestone-content {
        width: 250px;
        height: 140px;
      }

      #swim-phase.active-milestone img {
        max-width: 180px;
        max-height: 158px;
        top: 20px;
        left: 20px;
      }

      #bike-phase.active-milestone img {
        max-width: 200px;
        max-height: 176px;
        top: 25px;
        left: 25px;
      }

      #run-phase.active-milestone img {
        max-width: 190px;
        max-height: 102px;
        top: 18px;
        left: 45px;
      }

      #finish-phase.active-milestone img {
        max-width: 220px;
        max-height: 116px;
        top: 10px;
        left: 65px;
      }
    }

    #progress-bar-container {
      #progress-bar {
        height: 20px;
      }

      #progress-bar-fill {
        height: 19px;
      }

      #eighth-segment img {
        max-width: 25px;
        top: -2px;
      }
    }

    #drilldown-title {
      font-size: 18px;
    }

    #drilldown-table {
      th, td {
        font-size: 12px;
      }
    }

    .ranking-tables-section-header {
      font-size: 26px;
      margin-bottom: 20px;
      padding-bottom: 5px;
      max-width: calc(100% - 50px);
    }

    .ranking-tables-no-data {
      font-size: 14px;
    }

    .ranking-table {
      margin-bottom: 30px;
      font-size: 14px;
      max-width: calc(100% - 50px);
    }

    .ranking-table-header {
      font-size: 24px;
      padding: 20px 15px 15px 15px;
    }

    .ranking-table-icon {
      margin-right: 5px;
      width: 30px;
      height: 30px;
    }

    .ranking-table th {
      height: 50px;
    }

    .ranking-table td {
      height: 53px;
    }

    .ranking-table th,
    .ranking-table td {
      font-size: 14px;
      padding: 0 5px;
    }

    .ranking-table-img {
      width: 40px;
      height: 40px;
    }

    #top-reps-table-header div {
      padding-right: 0;
      padding-bottom: 0;
    }

    #top-reps-table-header input {
      font-size: 14px;
      max-width: 250px;
      height: 30px;
    }
  }

  @media (min-width: 1070px) {
    #closer-dash-toolbar-container #closer-dash-toolbar .v-toolbar .v-btn-toggle {
      margin-right: -2px;

      .v-btn {
        font-size: 13px;
        height: 35px;
      }
    }

    #closer-dash-tabs .col-12 span {
      font-size: 13px;
    }

    #milestones-container {
      max-width: calc(100% - 161px);

      .milestone {
        margin-bottom: 0;

        .milestone-top-label,
        .milestone-bottom-label {
          font-size: 13px;
        }
      }

      #swim-phase,
      #bike-phase {
        margin-bottom: 20px;
      }
    }

    #progress-bar-container {
      height: 42px;
    }

    #drilldown-title {
      font-size: 24px;
    }

    .ranking-tables-section-header {
      margin: 20px auto;
      max-width: calc(100% - 50px)
    }

    .ranking-tables-section {
      display: flex;
      flex-flow: row nowrap;
      justify-content: space-between;
      align-items: flex-start;
      max-width: calc(100% - 50px);
      margin: 0 auto;
    }

    .ranking-table {
      width: 100%;
      max-width: calc((100% / 2) - 10px);
    }

    .ranking-table th {
      font-size: 12px;
      height: 55px;
    }

    .ranking-table td {
      font-size: 12px;
      height: 55px;
    }

    .ranking-tables-no-data {
      font-size: 12px;
    }
  }

  @media (min-width: 1135px) {
    #closer-dash-tabs,
    #ironman-component {
      max-width: 1130px;
    }

    #milestones-container {
      max-width: calc(100% - 60px);
      flex-flow: row nowrap;

      #swim-phase,
      #bike-phase {
        margin-bottom: 0;
      }
    }

    .ranking-tables-section-header {
      max-width: 1130px;
    }

    .ranking-tables-section {
      max-width: 1130px;
      margin: 0 auto;
    }
  }
</style>

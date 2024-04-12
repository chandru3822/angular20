<template>
  <v-container id="closer-dash-container" ref="closerDashContainer">
    <v-data-table
      :items="tableData"
      :headers="tableHeaders"
      :footer-props="footerProps"
      :hide-default-footer="true"
    >

      <template #no-data>
        <span class="default-text-color">No available data</span>
      </template>


      <div>
<!--      <template #header.milestone="{}" id="milestones-header">Milestones</template>-->
<!--      <template #header.actualTotal="{}" >-->
<!--        <v-menu data-app left-->
<!--                offset-y-->
<!--                :max-height="`calc(100vh - 20px)`"-->
<!--                class="dropdown-header body-small"-->
<!--                v-model="openFirstMenu"-->
<!--                :close-on-content-click="true">-->
<!--          <template v-slot:activator="{ on }">-->
<!--            <v-btn class="dropdown-header body-small"-->
<!--                   v-on="on"-->
<!--            >-->
<!--              <span v-if="getDropdownById(firstDateRange)?.name === 'CUSTOM' && firstCustom.name != null" class="selected-option body-small">-->
<!--                      {{firstCustom.name}}</span>-->
<!--              <span v-else-if="getDropdownById(firstDateRange)?.name === 'PERIOD'" class="selected-option body-small">-->
<!--              {{ getDropdownById(firstDateRange).periodList[firstPeriod].shortLabel}}-->
<!--              </span>-->
<!--              <span v-else class="selected-option body-small">-->
<!--              {{ getDropdownById(firstDateRange)?.friendlyName}}-->
<!--              </span>-->
<!--              <v-spacer></v-spacer>-->
<!--              <v-icon>mdi-menu-down</v-icon>-->
<!--            </v-btn>-->
<!--          </template>-->
<!--          <div>-->
<!--            <v-list style="height: 400px; overflow-y:auto">-->
<!--              <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">-->
<!--                <v-list-item-title v-if="item.name === 'PERIOD'">-->
<!--                  <v-menu open-on-hover v-model="openFirstPeriodMenu" offset-x>-->
<!--                    <template v-slot:activator="{ on }">-->
<!--                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option body-large">-->
<!--                        {{ item.friendlyName }}-->
<!--                        <v-icon style="display: flex">mdi-chevron-right</v-icon>-->
<!--                      </span>-->
<!--                    </template>-->
<!--                    <div>-->
<!--                      <v-list style="height: 300px; overflow-y:auto">-->
<!--                        <v-list-item v-for="(period, index) in item.periodList" @click="firstDateRange = item.id; firstPeriod = index; changeDropdownSelection(1); firstCustom.isActive = (item.name === 'CUSTOM'); openFirstMenu = false">-->
<!--                          <v-list-item-title class="body-large">-->
<!--                            {{ period.label }}-->
<!--                          </v-list-item-title>-->
<!--                        </v-list-item>-->
<!--                      </v-list>-->
<!--                    </div>-->
<!--                  </v-menu>-->

<!--                </v-list-item-title>-->
<!--                <v-list-item-title v-else @click="firstDateRange = item.id; changeDropdownSelection(1); firstCustom.isActive = (item.name === 'CUSTOM');" class="dashboard-menu-option">{{item.friendlyName}}</v-list-item-title>-->
<!--              </v-list-item>-->
<!--            </v-list>-->
<!--          </div>-->
<!--        </v-menu>-->

<!--      </template>-->
<!--      <template #header.actualTotal2="{}" >-->
<!--        <v-menu data-app left-->
<!--                offset-y-->
<!--                :max-height="`calc(100vh - 20px)`"-->
<!--                class="dropdown-header body-small"-->
<!--                v-model="openSecondMenu"-->
<!--                :close-on-content-click="true">-->
<!--          <template v-slot:activator="{ on }">-->
<!--            <v-btn class="dropdown-header body-small"-->
<!--                   v-on="on"-->
<!--            >-->
<!--              <span v-if="getDropdownById(secondDateRange)?.name === 'CUSTOM' && secondCustom.name != null" class="selected-option body-small">-->
<!--                      {{secondCustom.name}}</span>-->
<!--              <span v-else-if="getDropdownById(secondDateRange)?.name === 'PERIOD'" class="selected-option body-small">-->
<!--              {{ getDropdownById(secondDateRange).periodList[secondPeriod].shortLabel}}-->
<!--              </span>-->
<!--              <span v-else-if="secondDateRange != null" class="selected-option body-small">-->
<!--              {{ getDropdownById(secondDateRange)?.friendlyName}}-->
<!--              </span>-->
<!--              <span v-else class="placeholder-option body-small">-->
<!--                Select Date Range-->
<!--              </span>-->
<!--              <v-spacer></v-spacer>-->
<!--              <v-icon>mdi-menu-down</v-icon>-->
<!--            </v-btn>-->
<!--          </template>-->
<!--          <div>-->
<!--            <v-list style="height: 400px; overflow-y:auto">-->
<!--              <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">-->
<!--                <v-list-item-title v-if="item.name === 'PERIOD'">-->
<!--                  <v-menu open-on-hover location="end" :offset-x="true">-->
<!--                    <template v-slot:activator="{ on }">-->
<!--                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option body-large">-->
<!--                        {{ item.friendlyName }}-->
<!--                        <v-icon>mdi-chevron-right</v-icon>-->
<!--                      </span>-->
<!--                    </template>-->
<!--                    <div>-->
<!--                      <v-list style="height: 300px; overflow-y:auto">-->
<!--                        <v-list-item v-for="(period, index) in item.periodList" @click="secondDateRange = item.id; secondPeriod = index; changeDropdownSelection(2); secondCustom.isActive = (item.name === 'CUSTOM'); openSecondMenu = false">-->
<!--                          <v-list-item-title class="body-large">-->
<!--                            {{ period.label }}-->
<!--                          </v-list-item-title>-->
<!--                        </v-list-item>-->
<!--                      </v-list>-->
<!--                    </div>-->
<!--                  </v-menu>-->

<!--                </v-list-item-title>-->
<!--                <v-list-item-title v-else @click="secondDateRange = item.id; changeDropdownSelection(2); secondCustom.isActive = (item.name === 'CUSTOM');" class="dashboard-menu-option">{{item.friendlyName}}</v-list-item-title>-->
<!--              </v-list-item>-->
<!--            </v-list>-->
<!--          </div>-->
<!--        </v-menu>-->
<!--      </template>-->
<!--      <template #header.actualTotal3="{}" >-->
<!--        <v-menu data-app left-->
<!--                offset-y-->
<!--                :max-height="`calc(100vh - 20px)`"-->
<!--                class="dropdown-header body-small"-->
<!--                v-model="openThirdMenu"-->
<!--                :close-on-content-click="true">-->
<!--          <template v-slot:activator="{ on }">-->
<!--            <v-btn class="dropdown-header body-small"-->
<!--                   v-on="on"-->
<!--            >-->
<!--              <span v-if="getDropdownById(thirdDateRange)?.name === 'CUSTOM' && thirdCustom.name != null" class="selected-option body-small">-->
<!--                      {{thirdCustom.name}}</span>-->
<!--              <span v-else-if="getDropdownById(thirdDateRange)?.name === 'PERIOD'" class="selected-option body-small">-->
<!--              {{ getDropdownById(thirdDateRange).periodList[thirdPeriod].shortLabel}}-->
<!--              </span>-->
<!--              <span v-else-if="thirdDateRange != null" class="selected-option body-small">-->
<!--              {{ getDropdownById(thirdDateRange)?.friendlyName}}-->
<!--              </span>-->
<!--              <span v-else class="placeholder-option body-small">-->
<!--                Select Date Range-->
<!--              </span>-->
<!--              <v-spacer></v-spacer>-->
<!--              <v-icon>mdi-menu-down</v-icon>-->
<!--            </v-btn>-->
<!--          </template>-->
<!--          <div>-->
<!--            <v-list style="height: 400px; overflow-y:auto">-->
<!--              <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">-->
<!--                <v-list-item-title v-if="item.name === 'PERIOD'">-->
<!--                  <v-menu open-on-hover location="end">-->
<!--                    <template v-slot:activator="{ on }">-->
<!--                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option body-large">-->
<!--                        {{ item.friendlyName }}-->
<!--                        <v-icon>mdi-chevron-right</v-icon>-->
<!--                      </span>-->
<!--                    </template>-->
<!--                    <div>-->
<!--                      <v-list style="height: 300px; overflow-y:auto">-->
<!--                        <v-list-item v-for="(period, index) in item.periodList" @click="thirdDateRange = item.id; thirdPeriod = index; changeDropdownSelection(3); thirdCustom.isActive = (item.name === 'CUSTOM'); openThirdMenu = false">-->
<!--                          <v-list-item-title class="body-large">-->
<!--                            {{ period.label }}-->
<!--                          </v-list-item-title>-->
<!--                        </v-list-item>-->
<!--                      </v-list>-->
<!--                    </div>-->
<!--                  </v-menu>-->

<!--                </v-list-item-title>-->
<!--                <v-list-item-title v-else @click="thirdDateRange = item.id; changeDropdownSelection(3); thirdCustom.isActive = (item.name === 'CUSTOM');" class="dashboard-menu-option">{{item.friendlyName}}</v-list-item-title>-->
<!--              </v-list-item>-->
<!--            </v-list>-->
<!--          </div>-->
<!--        </v-menu>-->
<!--      </template>-->


<!--      <template #item.milestone="{item, index}" id="milestones-col" class="milestone-name-col-td"><span :class="{'label-medium': item.major_milestone}">{{ item.name }}</span></template>-->
<!--      <template #item.actualTotal="{item, index}" class="milestone-col-td" >-->
<!--        <v-tooltip bottom>-->
<!--          <template v-slot:activator="{ on }">-->
<!--              <span @click="openDrilldown(item, 1)">-->
<!--              {{ item.company_count?item.company_count:0 }}-->
<!--              <span v-if="getDropdownById(firstDateRange)?.name != 'ALL_TIME'" v-on="viewTrends?on:null">-->
<!--                <span v-if="viewTrends && item.trend_count>0" class="positive-percentage">+{{item.trend_count/100 | percent}}<v-icon class="positive-trendline">trending_up</v-icon></span>-->
<!--                <span v-if="viewTrends && item.trend_count<0" class="negative-percentage">{{item.trend_count/100 | percent}}<v-icon class="negative-trendline">trending_down</v-icon></span>-->
<!--                <span v-if="viewTrends && (item.trend_count ===null || item.trend_count===0)" class="neutral-percentage">{{item.trend_count/100 | percent}}<v-icon class="neutral-trendline">trending_flat</v-icon></span>-->
<!--                </span>-->
<!--              </span>-->
<!--          </template>-->
<!--          <span v-if="viewTrends && item.trend_count>0"> {{Math.abs(item.trend_count)/100 | percent}} more than {{getDropdownById(firstDateRange).trendText}}</span>-->
<!--          <span v-if="viewTrends && item.trend_count<0"> {{Math.abs(item.trend_count)/100 | percent}} less than {{getDropdownById(firstDateRange).trendText}}</span>-->
<!--          <span v-if="viewTrends && (item.trend_count ===null || item.trend_count===0)"> Same as {{getDropdownById(firstDateRange).trendText}}</span>-->
<!--        </v-tooltip>-->
<!--      </template>-->

<!--      <template #item.actualTotal2="{item, index}" class="milestone-col-td" v-if="secondDateRange != null && filteredColumn2Values != null && filteredColumn2Values.length > 0">-->
<!--        <v-tooltip bottom>-->
<!--          <template v-slot:activator="{ on }">-->
<!--            <span @click="openDrilldown(item, 2)">-->
<!--              {{filteredColumn2Values[index].company_count?filteredColumn2Values[index].company_count:0}}-->
<!--              <span v-if="getDropdownById(secondDateRange)?.name != 'ALL_TIME'" v-on="viewTrends?on:null">-->
<!--                <span v-if="viewTrends && filteredColumn2Values[index].trend_count>0" class="positive-percentage">+{{filteredColumn2Values[index].trend_count/100 | percent}}<v-icon class="positive-trendline">trending_up</v-icon></span>-->
<!--                <span v-if="viewTrends && filteredColumn2Values[index].trend_count<0" class="negative-percentage">{{filteredColumn2Values[index].trend_count/100 | percent}}<v-icon class="negative-trendline">trending_down</v-icon></span>-->
<!--                <span v-if="viewTrends && (filteredColumn2Values[index].trend_count === null || filteredColumn2Values[index].trend_count==0)" class="neutral-percentage">{{filteredColumn2Values[index].trend_count/100 | percent}}<v-icon class="neutral-trendline">trending_flat</v-icon></span>-->
<!--              </span>-->
<!--            </span>-->
<!--          </template>-->
<!--          <span v-if="viewTrends && filteredColumn2Values[index].trend_count>0"> {{Math.abs(filteredColumn2Values[index].trend_count)/100 | percent}} more than {{getDropdownById(secondDateRange).trendText}}</span>-->
<!--          <span v-if="viewTrends && filteredColumn2Values[index].trend_count<0"> {{Math.abs(filteredColumn2Values[index].trend_count)/100 | percent}} less than {{getDropdownById(secondDateRange).trendText}}</span>-->
<!--          <span v-if="viewTrends && (filteredColumn2Values[index].trend_count ===null || filteredColumn2Values[index].trend_count===0)"> Same as {{getDropdownById(secondDateRange).trendText}}</span>-->
<!--        </v-tooltip>-->
<!--      </template>-->
<!--      <template #item.actualTotal3="{item, index}" class="milestone-col-td" v-if="thirdDateRange != null && filteredColumn3Values != null && filteredColumn3Values.length > 0">-->
<!--        <v-tooltip bottom>-->
<!--          <template v-slot:activator="{ on }">-->
<!--            <span @click="openDrilldown(item, 3)">-->
<!--            {{filteredColumn3Values[index]?.company_count ? filteredColumn3Values[index].company_count : 0}}-->
<!--              <span v-if="getDropdownById(thirdDateRange)?.name != 'ALL_TIME'" v-on="viewTrends?on:null">-->
<!--                <span v-if="viewTrends && filteredColumn3Values[index].trend_count>0" class="positive-percentage">+{{filteredColumn3Values[index].trend_count/100 | percent}}<v-icon class="positive-trendline">trending_up</v-icon></span>-->
<!--                <span v-if="viewTrends && filteredColumn3Values[index].trend_count<0" class="negative-percentage">{{filteredColumn3Values[index].trend_count/100 | percent}}<v-icon class="negative-trendline">trending_down</v-icon></span>-->
<!--                <span v-if="viewTrends && (filteredColumn3Values[index].trend_count === null || filteredColumn3Values[index].trend_count === 0)" class="neutral-percentage">{{filteredColumn3Values[index].trend_count/100 | percent}}<v-icon class="neutral-trendline">trending_flat</v-icon></span>-->
<!--              </span>-->
<!--            </span>-->
<!--          </template>-->
<!--          <span v-if="viewTrends && filteredColumn3Values[index].trend_count>0"> {{Math.abs(filteredColumn3Values[index].trend_count)/100 | percent}} more than {{getDropdownById(thirdDateRange).trendText}}</span>-->
<!--          <span v-if="viewTrends && filteredColumn3Values[index].trend_count<0"> {{Math.abs(filteredColumn3Values[index].trend_count)/100 | percent}} less than {{getDropdownById(thirdDateRange).trendText}}</span>-->
<!--          <span v-if="viewTrends && (filteredColumn3Values[index].trend_count ===null || filteredColumn3Values[index].trend_count===0)"> Same as {{getDropdownById(thirdDateRange).trendText}}</span>-->
<!--        </v-tooltip>-->
<!--      </template>-->
      </div>
    </v-data-table>

  </v-container>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import groupBy from 'lodash.groupby'
  import orderBy from 'lodash.orderby'
  import moment from 'moment'
  import constants from '@/helpers/constants'
  import { handleHidingGlobalLoader, getRequest, getRequestWithParams, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import SpinnerInline from '@/components/SpinnerInline'

  export default {
    name: 'CloserRankingTable',
    components: {
      SpinnerInline
    },
    props: {
      title: String,
      filterList: Array,
      filterTypes: Array,
      tableData: Array,
      tableHeaders: Array
    },
    data () {
      return {
        snackbar: {},
        constants,
        firstDateRange: 2,
        isLoading: false,
        openFirstMenu: false,
        openFirstPeriodMenu: false,
        currentUserId: this.$store.state.user.details.id,
        currentUserOrgId: null,
        selectedQuarter: 1,
        userCanViewAll: this.$store.getters.userHasFeatureAccessLevel('CLOSER_DASHBOARD', 'VIEW_ALL'),
        timeIntervalBtnGroup: 1, // determines which time interval button gets the active class
        timeIntervalString: '60 days', // 60 days is selected by default
        timeInterval: 60, // default time interval selection
        rankingTablesLoaded: false,
        dashboardWasLoaded: false,
        currentQuarter: moment().quarter(),
        rankingData: [],
        searchText: '',
        roundRobins: [],
        selectedRoundRobin: null,
        closerOffices: [],
        selectedCloserOffice: null,
        leadAllocationRankingData: [],
        officeFdcRankingData: [],
        officeRankingData: [],
        topRepsData: [],
        userOffice: '',
        userRow: [],
        userRowIndex: -1,
        numOffices: 0,
        roundRobinRanksLoading: true,
        officeFdcRankLoading: true,
        companyOfficeRankLoading: true,
        topRepsLoading: true,
        showOfficeRankingSection: true,
        showCompanyRankingSection: true,
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
      filteredTopRepsData () {
        if (this.searchText) {
          return this.topRepsData.filter(r => {
            return (r.name + r.officeName + r.metroArea).toLowerCase().includes(this.searchText.toLowerCase())
          })
        } else {
          return this.topRepsData
        }
      },
    },
    watch: {},
    methods: {
      itemRowBackground(item){
        return item.major_milestone ? 'shaded-row' : ''
      },
      getDropdownById(id){
        let result = this.filterList[0]
        return result?.find(x => x.id === id)
      },
      assignCloserRanks (rankingData, fieldName) {
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
      },

      resetScrollBarPosition () {
        // reset scroll bar position to top
        this.$refs.closerDashContainer.scrollTop = 0
      },

      /* RANKING TABLES-RELATED CODE START */
      async loadRoundRobins () {
        this.roundRobinRanksLoading = true
        try {
          const {data, status} = await getRequest('/closerDashboard/getRoundRobins', 'blueraven')
          this.roundRobins = data

          // if there's only one Round Robin for the current user, this auto-selects it
          if (this.roundRobins?.length === 1) {
            this.selectedRoundRobin = this.roundRobins[0]?.id
            await this.loadRoundRobinLeadAllocationRankData()
          }
          this.roundRobinRanksLoading = false

          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving list of round robins')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.roundRobinRanksLoading = false
        }
      },

      async loadRoundRobinLeadAllocationRankData () {
        this.roundRobinRanksLoading = true
        try {
          const params = {roundRobinId: this.selectedRoundRobin, timeInterval: this.timeInterval}
          const {data} = await getRequestWithParams('/closerDashboard/getRoundRobinLeadAllocationRank', {params}, 'blueraven')
          this.processRankingData(data, 'Round Robin Lead Allocation Rank')
          this.roundRobinRanksLoading = false
        } catch (e) {
          this.snackbar = getSnackbar('ERROR', 'Error retrieving round robin lead allocation rank data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.roundRobinRanksLoading = false
        }
      },

      async loadCloserOffices () {
        this.officeFdcRankLoading = true
        try {
          const params = {
            userOrgId: this.currentUserOrgId
          }
          const {data} = await getRequestWithParams('/closerDashboard/getCloserOffices', {params}, 'blueraven')
          this.closerOffices = data

          // if there's only one Closer Office for the current user, this auto-selects it
          if (this.closerOffices?.length === 1) {
            this.selectedCloserOffice = this.closerOffices[0]?.id
            await this.loadOfficeFdcRankData()
          }
          this.officeFdcRankLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving list of closer offices')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.officeFdcRankLoading = false
        }
      },

      async loadOfficeFdcRankData () {
        this.officeFdcRankLoading = true
        try {
          let params = {
            timeInterval: this.timeInterval,
            officeFdcRank: true,
            selectedOrgId: this.selectedCloserOffice
          }
          const {data} = await getRequestWithParams('/closerDashboard/getCloserTableScores', {params}, 'blueraven')

          this.processRankingData(cloneDeep(data.officeFdcRankValues), 'Office FDC Rank')
          this.officeFdcRankLoading = false
        } catch (e) {
          this.snackbar = getSnackbar('ERROR', 'Error retrieving office FDC rank data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.officeFdcRankLoading = false
        }
      },

      async setTimeInterval (timeIntervalString) {
        this.timeIntervalString = timeIntervalString

        switch (this.timeIntervalString) {
          case 'WTD':
            this.timeInterval = moment().isoWeekday() - 1 // WTD
            break
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

        if (this.selectedRoundRobin) {
          await this.loadRoundRobinLeadAllocationRankData()
        }

        if (this.selectedCloserOffice) {
          await this.loadOfficeFdcRankData()
        }

        await this.loadRankingTables()
      },

      async loadRankingTables () {
        this.rankingTablesLoaded = false
        this.rankingData = []
        this.searchText = ''
        this.topRepsLoading = true
        this.companyOfficeRankLoading = true

        try {
          let params = {
            timeInterval: this.timeInterval,
            officeFdcRank: false
          }
          const {data} = await getRequestWithParams('/closerDashboard/getCloserTableScores', {params}, 'blueraven', [])

          if (data?.companyRankingValues?.filter(row => row.userId === this.currentUserId)[0] !== undefined) {
            this.userOffice = data?.companyRankingValues?.filter(row => row.userId === this.currentUserId)[0].officeName
          }

          this.processRankingData(cloneDeep(data.companyRankingValues), 'Office Ranking')
          this.processRankingData(cloneDeep(data.companyRankingValues), 'Top Reps')

          this.rankingTablesLoaded = true
          this.topRepsLoading = false
          this.companyOfficeRankLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving ranking table data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.rankingTablesLoaded = true
          this.topRepsLoading = false
          this.companyOfficeRankLoading = false
        }
      },

      processRankingData (rankingData, currentTable) {
        if (currentTable === 'Round Robin Lead Allocation Rank') {
          this.leadAllocationRankingData = this.assignCloserRanks(rankingData, 'score')
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
      },
      /* RANKING TABLES-RELATED CODE END */
    },
    async created () {
      if (this.$store.state.user.details.userPositions?.length > 0) {
        let usersPrimaryPosition = this.$store.state.user.details.userPositions.find(p => {
          return (!p.archived && p.primaryFlag)
        })

        if(null != usersPrimaryPosition && [1, 2, 3, 517, 326].includes(usersPrimaryPosition.positionId)) {
          this.currentUserOrgId = usersPrimaryPosition.orgId
        }

      }
      let requests = [
        this.loadRoundRobins(),
        this.loadCloserOffices(),
        this.loadRankingTables()
      ]

      await Promise.all(requests).then(() => {
        this.dashboardWasLoaded = true
      })

    },
  }
</script>

<style lang="scss" scoped>
  .fix-bottom-page-issue {
    margin-bottom: 70px !important;
  }

  .expand-section {
    display: inline-block;
    position: absolute;
    right: 0;
  }

  #closer-dash-toolbar-container {
    #closer-dash-toolbar {
      #date-range-btns-toolbar {
        position: fixed;
        bottom: 0;
        z-index: 3;
        height: 45px !important;

        ::v-deep .v-toolbar__content {
          display: flex;
          justify-content: flex-end;
          padding: 5px 12px;
          width: 100%;
          height: 45px !important;

          .v-toolbar__items {
            display: flex;
            flex-flow: row nowrap;
            justify-content: flex-end;
            align-items: center;
            padding-right: 0;
          }
        }

        .v-btn-toggle .v-btn {
          border: 1px solid var(--v-primary-base) !important;
          font-size: 11px;
          letter-spacing: 0.02em !important;
          height: 25px;

          &:not(:last-child) {
            border-right: none !important;
          }

          &:hover {
            background-color: var(--v-primary-base);
            color: #fff !important;
          }
        }

        .v-btn--active {
          background-color: var(--v-primary-base);
          color: #fff !important;
        }
      }
    }
  }

  .ranking-tables-section-header {
    position: relative;
    text-align: left;
    font-family: "Roboto", sans-serif;
    font-weight: bold;
    font-size: 20px;
    border-bottom: 2px solid var(--v-primary-base);
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
    border-radius: 4px;
    margin-bottom: 15px;
    overflow-x: auto;
    width: 100%;
    position: relative;
  }

  .section-spinner {
    position: absolute;
    height: 100% !important;
    width: 100%;
    text-align: center;
    opacity: .6;
    background: white;
    display: flex;
    align-items: center;
    z-index: 1000;
  }

  .ranking-table-header {
    display: flex;
    flex-flow: row nowrap;
    font-weight: bold;
    font-size: 16px;
    text-align: left;
    padding: 10px 5px 5px 10px;
  }

  .user-office-ranking-table-header {
    justify-content: space-between;

    .table-header-dropdown {
      transform: scale(0.875);
      transform-origin: left;
      margin: 0 0 5px 5px;
      max-width: 120px;

      ::v-deep {
        .v-input__control {
          height: 25px;
        }

        label {
          color: #888 !important;
          font-size: 12px;
          font-weight: normal;
        }

        i {
          color: #888 !important;
          font-size: 20px;
        }

        .v-select__selections .v-select__selection {
          color: #888 !important;
          font-size: 12px;
          font-weight: normal;
        }
      }
    }
  }

  #top-reps-table {
    margin-bottom: 150px;

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
  }

  .ranking-table-icon {
    font-size: 16px;
  }

  .ranking-table table {
    border-collapse: collapse;
    width: 100%;
  }

  .ranking-table th {
    border-bottom: 1px solid #e6eeff;
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
    background-color: var(--v-primary-base);
    color: #fff;
  }

  .ranking-table-img,
  .placeholder-img {
    border-radius: 50%;
    padding: 1px;
    width: 28px;
    height: 28px;
  }

  .placeholder-img {
    background-color: #e9e9e9;
  }


  @media (min-width: 737px) {
    #closer-dash-toolbar-container {
      #closer-dash-toolbar {
       #date-range-btns-toolbar {
          height: 60px !important;

          ::v-deep .v-toolbar__content {
            padding: 10px 12px;
            height: 60px !important;
          }

          .v-btn-toggle {
            margin-right: 0;

            .v-btn {
              font-size: 12px;
              height: 30px;
            }
          }
        }
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
      padding: 10px 10px 15px 15px;
    }

    .ranking-table {
      margin-bottom: 30px;
      font-size: 14px;
      max-width: calc(100% - 50px);
    }

    .ranking-table-header {
      font-size: 22px;
      padding: 20px 15px 15px 15px;
    }

    .user-office-ranking-table-header {
      .table-header-dropdown {
        transform: none;
        margin: 0 0 10px 10px;
        max-width: 200px;

        ::v-deep {
          label {
            font-size: 14px;
          }

          .v-select__selections .v-select__selection {
            font-size: 14px;
          }
        }
      }
    }

    .ranking-table-icon {
      font-size: 22px;
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

    .ranking-table-img,
    .placeholder-img {
      width: 40px;
      height: 40px;
    }

    #top-reps-table {
      margin-bottom: 180px;

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
  }

  @media (min-width: 1070px) {
    #closer-dash-toolbar-container {
      #closer-dash-toolbar {
       #date-range-btns-toolbar {
          .v-btn-toggle {
            margin-right: 0;

            .v-btn {
              font-size: 13px;
              height: 35px;
            }
          }
        }
      }
    }

    .ranking-tables-section-header {
      margin: 0 auto 20px auto;
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

    .ranking-table-header {
      font-size: 15px;
    }

    .user-office-ranking-table-header {
      .table-header-dropdown {
        max-width: 135px;
      }
    }

    .ranking-table-icon {
      font-size: 15px;
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
    .ranking-tables-section-header {
      max-width: 1130px;
    }

    .ranking-tables-section {
      max-width: 1130px;
      margin: 0 auto;
    }

    .ranking-table-header, .ranking-table-icon {
      font-size: 18px;
    }
  }
</style>

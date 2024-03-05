<template>
  <v-container id="closer-dash-container" ref="closerDashContainer">
    <v-row id="closer-dash-toolbar-container">
      <v-col cols="12" id="closer-dash-toolbar" class="pt-0 pb-2">
        <v-app-bar id="date-range-btns-toolbar" class="elevation-1">
          <v-toolbar-items>
            <v-btn-toggle v-model="timeIntervalBtnGroup" mandatory>
              <v-btn text @click="setTimeInterval('WTD')">WTD</v-btn>
              <v-btn text @click="setTimeInterval('MTD')">MTD</v-btn>
              <v-btn text @click="setTimeInterval('60 days')" class="text-lowercase">60 days</v-btn>
              <v-btn text @click="setTimeInterval('90 days')" class="text-lowercase">90 days</v-btn>
              <v-btn text @click="setTimeInterval('YTD')">YTD</v-btn>
            </v-btn-toggle>
          </v-toolbar-items>
        </v-app-bar>
      </v-col>
    </v-row>
    <!---------------------------------- DASHBOARD TAB START ---------------------------------->
    <!-- RANKING TABLES FIRST HEADER START -->
    <div class="ranking-tables-section-header">
      <span v-if="!userCanViewAll">Your </span>Office Ranking
      <div class="expand-section">
        <v-btn text @click="showOfficeRankingSection = !showOfficeRankingSection">
          <v-icon v-if="!showOfficeRankingSection">mdi-chevron-down</v-icon>
          <v-icon v-else>mdi-chevron-up</v-icon>
        </v-btn>
      </div>
    </div>
    <!-- RANKING TABLES FIRST HEADER END -->

    <!-- RANKING TABLES TOP ROW START -->
    <div class="ranking-tables-section" v-if="showOfficeRankingSection">
      <!-- ROUND ROBIN LEAD ALLOCATION RANK START -->
      <div class="ranking-table">
        <div v-if="roundRobinRanksLoading" class="section-spinner">
          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
        </div>
        <div class="ranking-table-header user-office-ranking-table-header">
          <div class="user-office-ranking-table-header-left-side">
            <v-icon class="ranking-table-icon mr-2 default-text-color">mdi-sort-descending</v-icon>
            <span>Round Robin Lead Allocation Rank</span>
          </div>
          <v-autocomplete class="table-header-dropdown"
                          label="Round Robin"
                          v-model="selectedRoundRobin"
                          :items="roundRobins"
                          item-text="roundRobinName"
                          item-value="id"
                          no-data-text="No Round Robins available"
                          outlined
                          dense
                          hide-details
                          @input="loadRoundRobinLeadAllocationRankData"
          ></v-autocomplete>
        </div>

        <table v-if="leadAllocationRankingData.length > 0">
          <tr class="grey--text text--darken-2">
            <th class="center-text">Rank</th>
            <th></th>
            <th class="left-text">Rep</th>
            <th class="center-text">Lead-Gen FDC %</th>
            <th class="center-text">Self-Gen FDC</th>
            <th class="center-text">Average Availability</th>
            <!--            <th class="center-text">Future Availability</th>-->
            <th class="center-text">7-day Availability Look Ahead</th>
            <th class="center-text">Lead Allocation %</th>
          </tr>

          <tr v-for="(row, index) in leadAllocationRankingData" :key="index"
              :class="{'highlight-user-row': row.userId === currentUserId}">
            <td class="center-text">{{ row.rankLabel }}</td>
            <td class="user-img-col">
              <img v-if="row.userImageUrl" class="ranking-table-img"
                   :src="row.userImageUrl" :alt="row.userImageAltText">
              <img v-else class="placeholder-img"
                   src="../../../assets/flow/user_img_placeholder.png" :alt="row.userImageAltText">
            </td>
            <td class="left-text">{{ row.closerName || 0 }}</td>
            <td class="center-text">{{ row.leadGenFdcPercentage || 0 }}%</td>
            <td class="center-text">{{ row.selfGenFdc || 0 }}</td>
            <td class="center-text">{{ row.averageAvailability || 0 }}</td>
            <td class="center-text">{{ row.futureAvailability || 0 }}</td>
            <td class="center-text">
              <span v-if="row.score || row.score === 0">{{ row.score | percent(1) }}</span>
              <span v-else>--</span>
            </td>
          </tr>
        </table>
        <div v-if="!selectedRoundRobin" class="ranking-tables-no-data left-text">
          Please select a round robin
        </div>
        <div v-else-if="selectedRoundRobin && leadAllocationRankingData.length === 0"
             class="ranking-tables-no-data left-text">
          Data is not yet available for the selected time period. Try selecting another time period, or check back again
          at a later date.
        </div>
      </div>
      <!-- ROUND ROBIN LEAD ALLOCATION RANK END -->

      <!-- OFFICE FDC RANK START -->
      <div class="ranking-table">
        <div v-if="officeFdcRankLoading" class="section-spinner">
          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
        </div>
        <div class="ranking-table-header user-office-ranking-table-header">
          <div class="user-office-ranking-table-header-left-side">
            <v-icon class="ranking-table-icon mr-2 default-text-color">mdi-chevron-double-down</v-icon>
            <span>Office FDC Rank</span>
          </div>
          <v-autocomplete class="table-header-dropdown"
                          label="Closer Office"
                          v-model="selectedCloserOffice"
                          :items="closerOffices"
                          item-text="orgName"
                          item-value="id"
                          no-data-text="No Closer Offices available"
                          outlined
                          dense
                          hide-details
                          @input="loadRepRankingsByOrg(selectedCloserOffice)"
          ></v-autocomplete>
        </div>

        <table v-if="officeFdcRankingData.length > 0">
          <tr class="grey--text text--darken-2">
            <th class="center-text">Rank</th>
            <th></th>
            <th class="left-text">Rep</th>
            <th class="center-text">Lead-Gen FDC %</th>
            <th class="center-text">Self-Gen FDC</th>
            <th class="center-text">Total FDC</th>
          </tr>

          <tr v-for="(row, index) in officeFdcRankingData" :key="index"
              :class="{'highlight-user-row': row.userId === currentUserId}">
            <td class="center-text">{{ row.rankLabel || '' }}</td>
            <td class="user-img-col">
              <img v-if="row.userImageUrl" class="ranking-table-img"
                   :src="row.userImageUrl" :alt="row.userImageAltText">
              <img v-else class="placeholder-img"
                   src="../../../assets/flow/user_img_placeholder.png" :alt="row.userImageAltText">
            </td>
            <td class="left-text">{{ row.closerName || '' }}</td>
            <td class="center-text">{{ row.leadGenFdcPercentage || 0 }}%</td>
            <td class="center-text">{{ row.selfGenFdc || 0 }}</td>
            <td class="center-text">{{ row.totalFdc || 0 }}</td>
          </tr>
        </table>
        <div v-if="!selectedCloserOffice" class="ranking-tables-no-data left-text">
          Please select a closer office
        </div>
        <div v-else-if="selectedCloserOffice && officeFdcRankingData.length === 0"
             class="ranking-tables-no-data left-text">
          Data is not yet available for the selected time period. Try selecting another time period, or check back again
          at a later date.
        </div>
      </div>
      <!-- OFFICE FDC RANK END -->
    </div>
    <!-- RANKING TABLES TOP ROW END -->

    <!-- RANKING TABLES SECOND HEADER START -->
    <div class="ranking-tables-section-header" :class="{'fix-bottom-page-issue': !showCompanyRankingSection}">
      Company Ranking
      <div class="expand-section">
        <v-btn text @click="showCompanyRankingSection = !showCompanyRankingSection">
          <v-icon v-if="!showCompanyRankingSection">mdi-chevron-down</v-icon>
          <v-icon v-else>mdi-chevron-up</v-icon>
        </v-btn>
      </div>
    </div>
    <!-- RANKING TABLES SECOND HEADER END -->

    <!-- RANKING TABLES BOTTOM ROW START -->
    <div class="ranking-tables-section" v-if="showCompanyRankingSection">
      <!-- OFFICE RANKING START -->
      <div class="ranking-table">
        <div v-if="companyOfficeRankLoading" class="section-spinner">
          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
        </div>
        <div class="ranking-table-header">
          <v-icon class="ranking-table-icon default-text-color mr-2">mdi-office-building</v-icon>
          <span>Office Ranking</span>
        </div>

        <table v-if="officeRankingData.length > 0">
          <tr class="grey--text text--darken-2">
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
            <td class="center-text">{{ row.rankLabel }}</td>
            <td class="left-text">{{ row.officeName || '' }}</td>
            <td class="left-text">{{ row.metroArea || '' }}</td>
            <td class="left-text">{{ row.region || '' }}</td>
            <td class="center-text">{{ row.leadGenFdcPercentage || 0 }}%</td>
            <td class="center-text">{{ row.selfGenFdc || 0 }}</td>
            <td class="center-text">{{ row.totalFdc || 0 }}</td>
          </tr>
        </table>
        <div v-else class="ranking-tables-no-data left-text">
          Data is not yet available for the selected time period. Try selecting another time period, or check back again
          at a later date.
        </div>
      </div>
      <!-- OFFICE RANKING END -->

      <!-- TOP REPS START -->
      <div id="top-reps-table" class="ranking-table">
        <div v-if="topRepsLoading" class="section-spinner">
          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
        </div>
        <div class="ranking-table-header" id="top-reps-table-header">
          <div>
            <v-icon class="ranking-table-icon default-text-color mr-2">mdi-account-multiple</v-icon>
            <span>Top Reps</span>
          </div>
          <input type="text" placeholder="Search" v-model="searchText">
        </div>

        <table v-if="topRepsData.length > 0">
          <tr class="grey--text text--darken-2">
            <th class="center-text">Rank</th>
            <th></th>
            <th class="left-text">Rep</th>
            <th class="left-text">Current Office</th>
            <th class="left-text">Metro Area</th>
            <th class="center-text">Lead-Gen FDC %</th>
            <th class="center-text">Self-Gen FDC</th>
            <th class="center-text">Total FDC</th>
          </tr>

          <tr v-for="(row, index) in filteredTopRepsData"
              :key="index"
              :class="{'highlight-user-row': row.userId === currentUserId}">
            <td class="center-text">{{ row.rankLabel }}</td>
            <td class="user-img-col">
              <img v-if="row.userImageUrl" class="ranking-table-img"
                   :src="row.userImageUrl" :alt="row.userImageAltText">
              <img v-else class="placeholder-img"
                   src="../../../assets/flow/user_img_placeholder.png" :alt="row.userImageAltText">
            </td>
            <td class="left-text">{{ row.closerName || '' }}</td>
            <td class="left-text">{{ row.officeName || '' }}</td>
            <td class="left-text">{{ row.metroArea || '' }}</td>
            <td class="center-text">{{ row.leadGenFdcPercentage || 0 }}%</td>
            <td class="center-text">{{ row.selfGenFdc || 0 }}</td>
            <td class="center-text">{{ row.totalFdc || 0 }}</td>
          </tr>
          <tr v-if="userRow && !searchText"
              class="highlight-user-row">
            <td class="center-text">{{ userRow.rankLabel }}</td>
            <td class="user-img-col">
              <img v-if="userRow.userImageUrl" class="ranking-table-img"
                   :src="userRow.userImageUrl" :alt="userRow.userImageAltText">
              <img v-else class="placeholder-img"
                   src="../../../assets/flow/user_img_placeholder.png" :alt="userRow.userImageAltText">
            </td>
            <td class="left-text">{{ userRow.closerName || '' }}</td>
            <td class="left-text">{{ userRow.officeName || '' }}</td>
            <td class="left-text">{{ userRow.metroArea || '' }}</td>
            <td class="center-text">{{ userRow.leadGenFdcPercentage || 0 }}%</td>
            <td class="center-text">{{ userRow.selfGenFdc || 0 }}</td>
            <td class="center-text">{{ userRow.totalFdc || 0 }}</td>
          </tr>
        </table>
        <div v-else class="ranking-tables-no-data left-text">
          Data is not yet available for the selected time period. Try selecting another time period, or check back again
          at a later date.
        </div>
      </div>
      <!-- TOP REPS END -->
    </div>
    <!-- RANKING TABLES BOTTOM ROW END -->
    <!---------------------------------- DASHBOARD TAB END ---------------------------------->
  </v-container>
</template>

<script setup>
import moment from 'moment'
import constants from '@/helpers/constants'
import {getCloserRepRankings} from "@/services/dashboardService";
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import SpinnerInline from '@/components/SpinnerInline'
import {getCurrentInstance, ref, computed, onMounted} from "vue";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const currentUserId = ref(store.state.user.details.id)
const currentUserOrgId = ref(null)
const selectedQuarter = ref(1)
const userCanViewAll = ref(store.getters.userHasFeatureAccessLevel('CLOSER_DASHBOARD', 'VIEW_ALL'))
const timeIntervalBtnGroup = ref(1)
const timeIntervalString = ref('60 days')
const timeInterval = ref(60)
const dashboardWasLoaded = ref(false)
const currentQuarter = ref(moment().quarter())
const rankingData = ref([])
const searchText = ref('')
const roundRobins = ref([])
const selectedRoundRobin = ref(null)
const closerOffices = ref([])
const selectedCloserOffice = ref(null)
const leadAllocationRankingData = ref([])
const officeFdcRankingData = ref([])
const officeRankingData = ref([])
const topRepsData = ref([])
const userOffice = ref('')
const userRow = ref(null)
const highestTopRepRank = ref(29)
const roundRobinRanksLoading = ref(true)
const officeFdcRankLoading = ref(true)
const companyOfficeRankLoading = ref(true)
const topRepsLoading = ref(true)
const showOfficeRankingSection = ref(true)
const showCompanyRankingSection = ref(true)
const closerDashContainer = ref(null)

const filteredTopRepsData = computed(() => {
  if (searchText.value) {
    return topRepsData.value.filter(r => {
      return (r.closerName + r.officeName + r.metroArea).toLowerCase().includes(searchText.value.toLowerCase())
    })
  } else {
    return topRepsData.value.filter(r => r.rank <= highestTopRepRank.value)
  }
})

onMounted(async () => {
  if (store.state.user.details.userPositions?.length > 0) {
    let usersPrimaryPosition = store.state.user.details.userPositions.find(p => {
      return (!p.archived && p.primaryFlag)
    })

    if (null != usersPrimaryPosition && [1, 2, 3, 517, 326].includes(usersPrimaryPosition.positionId)) {
      currentUserOrgId.value = usersPrimaryPosition.orgId
    }

  }
  let requests = [
    loadRoundRobins(),
    loadCloserOffices(),
    loadOrgRankings(),
    loadRepRankingsForCompany()
  ]

  await Promise.all(requests).then(() => {
    dashboardWasLoaded.value = true
  })
})

/* RANKING TABLES-RELATED CODE START */
const loadRoundRobins = async () => {
  //get the round robins to display in the dropdown
  roundRobinRanksLoading.value = true
  try {
    const {data, status} = await getRequest('/closerDashboard/getRoundRobins', 'blueraven')
    roundRobins.value = data

    // if there's only one Round Robin for the current user, this auto-selects it
    if (roundRobins.value?.length === 1) {
      selectedRoundRobin.value = roundRobins.value[0]?.id
      await loadRoundRobinLeadAllocationRankData()
    }
    roundRobinRanksLoading.value = false

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving list of round robins')
    roundRobinRanksLoading.value = false
  }
}
const loadRoundRobinLeadAllocationRankData = async () => {
  roundRobinRanksLoading.value = true
  try {
    //this loads the Round Robin Lead Allocation Rank box (top left)
    const params = {roundRobinId: selectedRoundRobin.value, timeInterval: timeInterval.value}
    const {data} = await getRequestWithParams('/closerDashboard/getRoundRobinLeadAllocationRank', {params}, 'blueraven')
    leadAllocationRankingData.value = data
    roundRobinRanksLoading.value = false
  } catch (e) {
    snackbar('ERROR', 'Error retrieving round robin lead allocation rank data')
    roundRobinRanksLoading.value = false
  }
}
const loadCloserOffices = async () => {
  // this loads all orgs for the office fdc rank box (top right currently)
  officeFdcRankLoading.value = true
  try {
    const params = {
      userOrgId: currentUserOrgId.value
    }
    const {data} = await getRequestWithParams('/closerDashboard/getCloserOffices', {params}, 'blueraven')
    closerOffices.value = data

    // if there's only one Closer Office for the current user, this auto-selects it
    if (closerOffices.value?.length === 1) {
      selectedCloserOffice.value = closerOffices.value[0]?.id
      await loadRepRankingsByOrg(selectedCloserOffice.value)
    }
    officeFdcRankLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving list of closer offices')
    officeFdcRankLoading.value = false
  }
}
const loadRepRankingsByOrg = async (orgId) => {
  //this can load the office fdc rank OR top reps as they are the same data just by org or for the whole company
  officeFdcRankLoading.value = true
  try {
    const data = await getCloserRepRankings(timeInterval.value, orgId)
    officeFdcRankingData.value = data
    officeFdcRankLoading.value = false
  } catch (e) {
    snackbar('ERROR', 'Error retrieving Office FDC rank data')
    officeFdcRankLoading.value = false
  }
}
const loadRepRankingsForCompany = async () => {
  //this can load the office fdc rank OR top reps as they are the same data just by org or for the whole company
  topRepsLoading.value = true
  try {
    const data = await getCloserRepRankings(timeInterval.value, null)
    topRepsData.value = data

    let userRowTemp = topRepsData.value.find(row => row.userId === currentUserId.value)
    if (userRowTemp?.rank > highestTopRepRank.value) {
      userRow.value = userRowTemp
    }
    topRepsLoading.value = false
  } catch (e) {
    snackbar('ERROR', 'Error retrieving Top Reps rank data')
    topRepsLoading.value = false
  }
}
const setTimeInterval = async (timeIntervalText) => {
  timeIntervalString.value = timeIntervalText

  switch (timeIntervalString.value) {
    case 'WTD':
      timeInterval.value = moment().isoWeekday() - 1 // WTD
      break
    case 'MTD':
      timeInterval.value = +moment().format('DD') // MTD
      break
    case '60 days':
      timeInterval.value = 60
      break
    case '90 days':
      timeInterval.value = 90
      break
    case 'YTD':
      timeInterval.value = moment().dayOfYear() // YTD
      break
  }

  let requests = []
  if (selectedRoundRobin.value) {
    requests.push(loadRoundRobinLeadAllocationRankData())
  }

  if (selectedCloserOffice.value) {
    //all reps in org
    requests.push(loadRepRankingsByOrg(selectedCloserOffice.value))
  }

  //all reps in company
  requests.push(loadRepRankingsForCompany())

  //all orgs in company
  requests.push(loadOrgRankings())

  await Promise.all(requests)
}
const loadOrgRankings = async () => {
  rankingData.value = []
  companyOfficeRankLoading.value = true

  try {
    let params = {
      timeInterval: timeInterval.value
    }
    const {data} = await getRequestWithParams('/closerDashboard/getOrgRankings', {params}, 'blueraven', [])
    officeRankingData.value = data
    companyOfficeRankLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving Office Ranking data')
    companyOfficeRankLoading.value = false
  }
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

<template>
  <div>
    <div class="ranking-tables-section">
      <!-- ROUND ROBIN LEAD ALLOCATION RANK START -->
      <div class="ranking-table">
        <v-row>
          <div class="title-large table-title">
            Round Robin Lead Allocation Rank
          </div>
          <span v-for="(filter, index) in roundRobinFilterList">
<!--        <v-menu data-app left-->
<!--                offset-y-->
<!--                :max-height="`calc(100vh - 20px)`"-->
<!--                class="dropdown-header body-small"-->
<!--                v-model="openFirstMenu"-->
<!--                :close-on-content-click="true">-->
<!--        <template v-slot:activator="{ on }">-->
<!--          <v-btn class="dropdown-header body-small"-->
<!--                 v-on="on"-->
<!--          >-->
<!--              <span v-if="getDropdownById(roundRobinDateRange)?.name === 'CUSTOM' && firstCustom.name != null" class="selected-option body-small">-->
<!--                      {{firstCustom.name}}</span>-->
<!--            <span v-else-if="getDropdownById(roundRobinDateRange)?.name === 'PERIOD'" class="selected-option body-small">-->
<!--              {{ getDropdownById(roundRobinDateRange).periodList[firstPeriod].shortLabel}}-->
<!--              </span>-->
<!--            <span v-else class="selected-option body-small">-->
<!--              {{ getDropdownById(roundRobinDateRange)?.friendlyName}}-->
<!--              </span>-->
<!--            <v-spacer></v-spacer>-->
<!--            <v-icon>mdi-menu-down</v-icon>-->
<!--          </v-btn>-->
<!--        </template>-->
<!--        <div>-->
<!--          <v-list style="height: 400px; overflow-y:auto">-->
<!--            <v-list-item v-for="(item, index) in filter" style="padding: 0px">-->
<!--              <v-list-item-title v-if="item.name === 'PERIOD'">-->
<!--                <v-menu open-on-hover v-model="openFirstPeriodMenu" offset-x>-->
<!--                  <template v-slot:activator="{ on }">-->
<!--                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option body-large">-->
<!--                        {{ item.friendlyName }}-->
<!--                        <v-icon style="display: flex">mdi-chevron-right</v-icon>-->
<!--                      </span>-->
<!--                  </template>-->
<!--                  <div>-->
<!--                    <v-list style="height: 300px; overflow-y:auto">-->
<!--                      <v-list-item v-for="(period, index) in item.periodList" @click="roundRobinDateRange = item.id; firstPeriod = index; changeDropdownSelection(1); firstCustom.isActive = (item.name === 'CUSTOM'); openFirstMenu = false">-->
<!--                        <v-list-item-title class="body-large">-->
<!--                          {{ period.label }}-->
<!--                        </v-list-item-title>-->
<!--                      </v-list-item>-->
<!--                    </v-list>-->
<!--                  </div>-->
<!--                </v-menu>-->

<!--              </v-list-item-title>-->
<!--              <v-list-item-title v-else @click="roundRobinDateRange = item.id; changeDropdownSelection(1); firstCustom.isActive = (item.name === 'CUSTOM');" class="dashboard-menu-option">{{item.friendlyName}}</v-list-item-title>-->
<!--            </v-list-item>-->
<!--          </v-list>-->
<!--        </div>-->
<!--      </v-menu>-->
      </span>
          <!--      <a class="export-button" @click="exportCsv"><v-icon class="export-icon">mdi-tray-arrow-down</v-icon>Export</a>-->
        </v-row>
        <CloserRankingTable
          title="Round Robin Lead Allocation Rank"
          :tableData=leadAllocationRankingData
          :tableHeaders=leadAllocationRankingHeaders
        />
      </div>
      <!--      <div class="ranking-table">-->
      <!--        <div v-if="roundRobinRanksLoading" class="section-spinner">-->
      <!--          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>-->
      <!--        </div>-->
      <!--        <div class="ranking-table-header user-office-ranking-table-header">-->
      <!--          <div class="user-office-ranking-table-header-left-side">-->
      <!--            <v-icon class="ranking-table-icon mr-2 default-text-color">mdi-sort-descending</v-icon>-->
      <!--            <span>Round Robin Lead Allocation Rank</span>-->
      <!--          </div>-->
      <!--          <v-autocomplete class="table-header-dropdown"-->
      <!--                    label="Round Robin"-->
      <!--                    v-model="selectedRoundRobin"-->
      <!--                    :items="roundRobins"-->
      <!--                    item-text="roundRobinName"-->
      <!--                    item-value="id"-->
      <!--                    no-data-text="No Round Robins available"-->
      <!--                    outlined-->
      <!--                    dense-->
      <!--                    hide-details-->
      <!--                    @input="loadRoundRobinLeadAllocationRankData"-->
      <!--          ></v-autocomplete>-->
      <!--        </div>-->

      <!--        <table v-if="leadAllocationRankingData.length > 0">-->
      <!--          <tr class="grey--text text--darken-2">-->
      <!--            <th class="center-text">Rank</th>-->
      <!--            <th></th>-->
      <!--            <th class="left-text">Rep</th>-->
      <!--            <th class="center-text">Lead-Gen FDC %</th>-->
      <!--            <th class="center-text">Self-Gen FDC</th>-->
      <!--            <th class="center-text">Average Availability</th>-->
      <!--&lt;!&ndash;            <th class="center-text">Future Availability</th>&ndash;&gt;-->
      <!--            <th class="center-text">7-day Availability Look Ahead</th>-->
      <!--            <th class="center-text">Lead Allocation %</th>-->
      <!--          </tr>-->

      <!--          <tr v-for="(row, index) in leadAllocationRankingData" :key="index"-->
      <!--              :class="{'highlight-user-row': row.userId === currentUserId}">-->
      <!--            <td class="center-text">{{ row.rank }}</td>-->
      <!--            <td class="user-img-col">-->
      <!--              <img v-if="row.userImageUrl" class="ranking-table-img"-->
      <!--                   :src="row.userImageUrl" :alt="row.userImageAltText">-->
      <!--              <img v-else class="placeholder-img"-->
      <!--                   src="../../../assets/flow/user_img_placeholder.png" :alt="row.userImageAltText">-->
      <!--            </td>-->
      <!--            <td class="left-text">{{ row.closerName || 0 }}</td>-->
      <!--            <td class="center-text">{{ row.leadGenFdc || 0 }}%</td>-->
      <!--            <td class="center-text">{{ row.selfGen || 0 }}</td>-->
      <!--            <td class="center-text">{{ row.averageAvailability || 0 }}</td>-->
      <!--            <td class="center-text">{{ row.futureAvailability || 0 }}</td>-->
      <!--            <td class="center-text">-->
      <!--              <span v-if="row.score || row.score === 0">{{ row.score | percent(1) }}</span>-->
      <!--              <span v-else>--</span>-->
      <!--            </td>-->
      <!--          </tr>-->
      <!--        </table>-->
      <!--        <div v-if="!selectedRoundRobin" class="ranking-tables-no-data left-text">-->
      <!--          Please select a round robin-->
      <!--        </div>-->
      <!--        <div v-else-if="selectedRoundRobin && leadAllocationRankingData.length === 0"-->
      <!--             class="ranking-tables-no-data left-text">-->
      <!--          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.-->
      <!--        </div>-->
      <!--      </div>-->
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
                          @input="loadOfficeFdcRankData"
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
            <td class="center-text">{{ row.rank || '' }}</td>
            <td class="user-img-col">
              <img v-if="row.userImageUrl" class="ranking-table-img"
                   :src="row.userImageUrl" :alt="row.userImageAltText">
              <img v-else class="placeholder-img"
                   src="../../../assets/flow/user_img_placeholder.png" :alt="row.userImageAltText">
            </td>
            <td class="left-text">{{ row.name || '' }}</td>
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
          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
        </div>
      </div>
      <!-- OFFICE FDC RANK END -->
    </div>
  </div>
</template>

<script setup>
import CloserRankingTable from "./CloserRankingTable.vue";
import moment from "moment/moment.js";
import { useUserStore } from "@/stores/UserStore.js";
import {getCurrentInstance, onMounted, ref} from "vue";
import {handleHidingGlobalLoader, getRequest, postRequest,  getRequestWithParams} from '@/helpers/helpers'
import groupBy from "lodash.groupby";
import orderBy from "lodash.orderby";
import cloneDeep from "lodash.clonedeep";

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const userStore = useUserStore()
const roundRobinFilterList = ref([])
const roundRobinFilterTypes = ref(['Dates'])
const dropdownValues = ref([])
const isLoading = ref(false)
const roundRobinRanksLoading = ref(false)
const officeFdcRankLoading = ref(true)
const leadAllocationRankingData = ref([])
const leadAllocationRankingHeaders = ref([])
const isBrCorporateUser = ref(userStore.details.companyId === 2)
const closerOffices = ref([])
const officeFdcRankingData = ref([])
const selectedCloserOffice = ref(null)
const timeInterval = ref(102)
const openFirstMenu = ref(false)
const openSecondMenu = ref(false)
const openThirdMenu = ref(false)
const currentUserOrgId = ref(null)

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
  await loadRoundRobinLeadAllocationRankData()
  await loadOfficeFdcRankData()

  leadAllocationRankingHeaders.value = [
    { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true, width: '25%' },
    { text: 'Rep', value: 'closerName', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value, width: '25%' },
    { text: 'Lead-Gen FDC %', value: 'leadGenFdc', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value, width: '25%' },
    { text: 'Self-Gen FDC', value: 'selfGen', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value, width: '25%' },
    { text: 'Average Availability', value: 'averageAvailability', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value, width: '25%' },
    { text: 'Lead Allocation %', value: 'score', align: 'left', class: 'total-col-th data-col-th', show: !isBrCorporateUser.value, width: '25%' },

  ]
})

const loadOfficeFdcRankData = async() => {
  officeFdcRankLoading.value = true
  try {
    let params = {
      timeInterval: timeInterval.value,
      officeFdcRank: true,
      selectedOrgId: selectedCloserOffice.value
    }
    console.log(selectedCloserOffice.value)
    const {data} = await getRequestWithParams('/closerDashboard/getCloserTableScores', {params}, 'blueraven')

    processRankingData(cloneDeep(data.officeFdcRankValues), 'Office FDC Rank')
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
    //REMOVE
    else{
      selectedCloserOffice.value = closerOffices?.value[0].id
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
    roundRobinFilterList.value = data
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
    const params = {roundRobinId: 7, timeInterval: 102}
    const {data} = await getRequestWithParams('/closerDashboard/getRoundRobinLeadAllocationRank', {params}, 'blueraven')
    processRankingData(data, 'Round Robin Lead Allocation Rank')
    roundRobinRanksLoading.value = false
  } catch (e) {
    snackbar('ERROR', 'Error retrieving round robin lead allocation rank data')
    roundRobinRanksLoading.value = false
  }
}

const processRankingData  = (rankingData, currentTable) => {
  if (currentTable === 'Round Robin Lead Allocation Rank') {
    leadAllocationRankingData.value = assignCloserRanks(rankingData, 'score')
    console.log(leadAllocationRankingData.value)
  } else {
    // switch (currentTable) {
    //   case 'Office FDC Rank':
    //     this.officeFdcRankingData = this.assignCloserRanks(rankingData, 'totalFdc')
    //     break
    //   case 'Office Ranking':
    //     this.officeRankingData = []
    //     rankingData = groupBy(rankingData, 'officeName')
    //
    //     Object.keys(rankingData).forEach(group => {
    //       let leadGenFdcPercentageSum = 0
    //       let selfGenFdcSum = 0
    //       let totalFdcSum = 0
    //       let numRepsInGroup = 0
    //
    //       rankingData[group].forEach(rep => {
    //         leadGenFdcPercentageSum += parseInt(rep.leadGenFdcPercentage)
    //         selfGenFdcSum += rep.selfGenFdc
    //         totalFdcSum += rep.totalFdc
    //         numRepsInGroup++
    //       })
    //
    //       this.officeRankingData.push({
    //         officeName: rankingData[group][0].officeName,
    //         metroArea: rankingData[group][0].metroArea,
    //         region: rankingData[group][0].region,
    //         leadGenFdcPercentage: Math.round(leadGenFdcPercentageSum / numRepsInGroup),
    //         selfGenFdc: selfGenFdcSum,
    //         totalFdc: totalFdcSum
    //       })
    //     })
    //
    //     this.officeRankingData = this.assignCloserRanks(this.officeRankingData, 'totalFdc')
    //     break
    //   case 'Top Reps':
    //     this.userRow = null
    //     this.numOffices = this.officeRankingData.length
    //     this.topRepsData = this.assignCloserRanks(rankingData, 'totalFdc')
    //
    //     // determine whether current user's row is one of the visible rows
    //     this.userRowIndex = this.topRepsData.findIndex(row => row.userId === this.currentUserId)
    //     if (this.userRowIndex !== -1 && this.userRowIndex > this.numOffices - 1) {
    //       this.userRow = this.topRepsData.filter(row => row.userId === this.currentUserId)[0]
    //     }
    // }
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

</script>

<style lang="scss" scoped>

</style>

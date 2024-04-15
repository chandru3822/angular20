<!--<template>-->
<!--  <v-container id="closer-dash-container" ref="closerDashContainer">-->
<!--    <v-row id="closer-dash-toolbar-container">-->
<!--      <v-col cols="12" id="closer-dash-toolbar" class="pt-0 pb-2">-->
<!--        <v-app-bar id="date-range-btns-toolbar" class="elevation-1">-->
<!--          <v-toolbar-items>-->
<!--            <v-btn-toggle v-model="timeIntervalBtnGroup" mandatory>-->
<!--              <v-btn text @click="setTimeInterval('WTD')">WTD</v-btn>-->
<!--              <v-btn text @click="setTimeInterval('MTD')">MTD</v-btn>-->
<!--              <v-btn text @click="setTimeInterval('60 days')" class="text-lowercase">60 days</v-btn>-->
<!--              <v-btn text @click="setTimeInterval('90 days')" class="text-lowercase">90 days</v-btn>-->
<!--              <v-btn text @click="setTimeInterval('YTD')">YTD</v-btn>-->
<!--            </v-btn-toggle>-->
<!--          </v-toolbar-items>-->
<!--        </v-app-bar>-->
<!--      </v-col>-->
<!--    </v-row>-->
<!--    &lt;!&ndash;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45; DASHBOARD TAB START &#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&ndash;&gt;-->
<!--    &lt;!&ndash; RANKING TABLES FIRST HEADER START &ndash;&gt;-->
<!--    <div class="ranking-tables-section-header">-->
<!--      <span v-if="!userCanViewAll">Your </span>Office Ranking-->
<!--      <div class="expand-section">-->
<!--        <v-btn text @click="showOfficeRankingSection = !showOfficeRankingSection">-->
<!--          <v-icon v-if="!showOfficeRankingSection">mdi-chevron-down</v-icon>-->
<!--          <v-icon v-else>mdi-chevron-up</v-icon>-->
<!--        </v-btn>-->
<!--      </div>-->
<!--    </div>-->
<!--    &lt;!&ndash; RANKING TABLES FIRST HEADER END &ndash;&gt;-->

<!--    &lt;!&ndash; RANKING TABLES TOP ROW START &ndash;&gt;-->
<!--    <div class="ranking-tables-section" v-if="showOfficeRankingSection">-->
<!--      &lt;!&ndash; ROUND ROBIN LEAD ALLOCATION RANK START &ndash;&gt;-->
<!--      <div class="ranking-table">-->
<!--        <v-row>-->
<!--          <div class="title-large table-title">-->
<!--            Round Robin Lead Allocation Rank-->
<!--          </div>-->
<!--          <span v-for="(filter, index) in roundRobinFilterList">-->
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
<!--      </span>-->
<!--          &lt;!&ndash;      <a class="export-button" @click="exportCsv"><v-icon class="export-icon">mdi-tray-arrow-down</v-icon>Export</a>&ndash;&gt;-->
<!--        </v-row>-->
<!--        <CloserRankingTable-->
<!--          v-if="roundRobinFilterList.length > 0"-->
<!--          title="Round Robin Lead Allocation Rank"-->
<!--          :filterList=roundRobinFilterList-->
<!--          :filterTypes=roundRobinFilterTypes-->
<!--          :tableData=leadAllocationRankingData-->
<!--          :tableHeaders=leadAllocationRankingHeaders-->
<!--        />-->
<!--      </div>-->
<!--&lt;!&ndash;      <div class="ranking-table">&ndash;&gt;-->
<!--&lt;!&ndash;        <div v-if="roundRobinRanksLoading" class="section-spinner">&ndash;&gt;-->
<!--&lt;!&ndash;          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>&ndash;&gt;-->
<!--&lt;!&ndash;        </div>&ndash;&gt;-->
<!--&lt;!&ndash;        <div class="ranking-table-header user-office-ranking-table-header">&ndash;&gt;-->
<!--&lt;!&ndash;          <div class="user-office-ranking-table-header-left-side">&ndash;&gt;-->
<!--&lt;!&ndash;            <v-icon class="ranking-table-icon mr-2 default-text-color">mdi-sort-descending</v-icon>&ndash;&gt;-->
<!--&lt;!&ndash;            <span>Round Robin Lead Allocation Rank</span>&ndash;&gt;-->
<!--&lt;!&ndash;          </div>&ndash;&gt;-->
<!--&lt;!&ndash;          <v-autocomplete class="table-header-dropdown"&ndash;&gt;-->
<!--&lt;!&ndash;                    label="Round Robin"&ndash;&gt;-->
<!--&lt;!&ndash;                    v-model="selectedRoundRobin"&ndash;&gt;-->
<!--&lt;!&ndash;                    :items="roundRobins"&ndash;&gt;-->
<!--&lt;!&ndash;                    item-text="roundRobinName"&ndash;&gt;-->
<!--&lt;!&ndash;                    item-value="id"&ndash;&gt;-->
<!--&lt;!&ndash;                    no-data-text="No Round Robins available"&ndash;&gt;-->
<!--&lt;!&ndash;                    outlined&ndash;&gt;-->
<!--&lt;!&ndash;                    dense&ndash;&gt;-->
<!--&lt;!&ndash;                    hide-details&ndash;&gt;-->
<!--&lt;!&ndash;                    @input="loadRoundRobinLeadAllocationRankData"&ndash;&gt;-->
<!--&lt;!&ndash;          ></v-autocomplete>&ndash;&gt;-->
<!--&lt;!&ndash;        </div>&ndash;&gt;-->

<!--&lt;!&ndash;        <table v-if="leadAllocationRankingData.length > 0">&ndash;&gt;-->
<!--&lt;!&ndash;          <tr class="grey&#45;&#45;text text&#45;&#45;darken-2">&ndash;&gt;-->
<!--&lt;!&ndash;            <th class="center-text">Rank</th>&ndash;&gt;-->
<!--&lt;!&ndash;            <th></th>&ndash;&gt;-->
<!--&lt;!&ndash;            <th class="left-text">Rep</th>&ndash;&gt;-->
<!--&lt;!&ndash;            <th class="center-text">Lead-Gen FDC %</th>&ndash;&gt;-->
<!--&lt;!&ndash;            <th class="center-text">Self-Gen FDC</th>&ndash;&gt;-->
<!--&lt;!&ndash;            <th class="center-text">Average Availability</th>&ndash;&gt;-->
<!--&lt;!&ndash;&lt;!&ndash;            <th class="center-text">Future Availability</th>&ndash;&gt;&ndash;&gt;-->
<!--&lt;!&ndash;            <th class="center-text">7-day Availability Look Ahead</th>&ndash;&gt;-->
<!--&lt;!&ndash;            <th class="center-text">Lead Allocation %</th>&ndash;&gt;-->
<!--&lt;!&ndash;          </tr>&ndash;&gt;-->

<!--&lt;!&ndash;          <tr v-for="(row, index) in leadAllocationRankingData" :key="index"&ndash;&gt;-->
<!--&lt;!&ndash;              :class="{'highlight-user-row': row.userId === currentUserId}">&ndash;&gt;-->
<!--&lt;!&ndash;            <td class="center-text">{{ row.rank }}</td>&ndash;&gt;-->
<!--&lt;!&ndash;            <td class="user-img-col">&ndash;&gt;-->
<!--&lt;!&ndash;              <img v-if="row.userImageUrl" class="ranking-table-img"&ndash;&gt;-->
<!--&lt;!&ndash;                   :src="row.userImageUrl" :alt="row.userImageAltText">&ndash;&gt;-->
<!--&lt;!&ndash;              <img v-else class="placeholder-img"&ndash;&gt;-->
<!--&lt;!&ndash;                   src="../../../assets/flow/user_img_placeholder.png" :alt="row.userImageAltText">&ndash;&gt;-->
<!--&lt;!&ndash;            </td>&ndash;&gt;-->
<!--&lt;!&ndash;            <td class="left-text">{{ row.closerName || 0 }}</td>&ndash;&gt;-->
<!--&lt;!&ndash;            <td class="center-text">{{ row.leadGenFdc || 0 }}%</td>&ndash;&gt;-->
<!--&lt;!&ndash;            <td class="center-text">{{ row.selfGen || 0 }}</td>&ndash;&gt;-->
<!--&lt;!&ndash;            <td class="center-text">{{ row.averageAvailability || 0 }}</td>&ndash;&gt;-->
<!--&lt;!&ndash;            <td class="center-text">{{ row.futureAvailability || 0 }}</td>&ndash;&gt;-->
<!--&lt;!&ndash;            <td class="center-text">&ndash;&gt;-->
<!--&lt;!&ndash;              <span v-if="row.score || row.score === 0">{{ row.score | percent(1) }}</span>&ndash;&gt;-->
<!--&lt;!&ndash;              <span v-else>&#45;&#45;</span>&ndash;&gt;-->
<!--&lt;!&ndash;            </td>&ndash;&gt;-->
<!--&lt;!&ndash;          </tr>&ndash;&gt;-->
<!--&lt;!&ndash;        </table>&ndash;&gt;-->
<!--&lt;!&ndash;        <div v-if="!selectedRoundRobin" class="ranking-tables-no-data left-text">&ndash;&gt;-->
<!--&lt;!&ndash;          Please select a round robin&ndash;&gt;-->
<!--&lt;!&ndash;        </div>&ndash;&gt;-->
<!--&lt;!&ndash;        <div v-else-if="selectedRoundRobin && leadAllocationRankingData.length === 0"&ndash;&gt;-->
<!--&lt;!&ndash;             class="ranking-tables-no-data left-text">&ndash;&gt;-->
<!--&lt;!&ndash;          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.&ndash;&gt;-->
<!--&lt;!&ndash;        </div>&ndash;&gt;-->
<!--&lt;!&ndash;      </div>&ndash;&gt;-->
<!--      &lt;!&ndash; ROUND ROBIN LEAD ALLOCATION RANK END &ndash;&gt;-->

<!--      &lt;!&ndash; OFFICE FDC RANK START &ndash;&gt;-->
<!--      <div class="ranking-table">-->
<!--        <div v-if="officeFdcRankLoading" class="section-spinner">-->
<!--          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>-->
<!--        </div>-->
<!--        <div class="ranking-table-header user-office-ranking-table-header">-->
<!--          <div class="user-office-ranking-table-header-left-side">-->
<!--            <v-icon class="ranking-table-icon mr-2 default-text-color">mdi-chevron-double-down</v-icon>-->
<!--            <span>Office FDC Rank</span>-->
<!--          </div>-->
<!--          <v-autocomplete class="table-header-dropdown"-->
<!--                    label="Closer Office"-->
<!--                    v-model="selectedCloserOffice"-->
<!--                    :items="closerOffices"-->
<!--                    item-text="orgName"-->
<!--                    item-value="id"-->
<!--                    no-data-text="No Closer Offices available"-->
<!--                    outlined-->
<!--                    dense-->
<!--                    hide-details-->
<!--                    @input="loadOfficeFdcRankData"-->
<!--          ></v-autocomplete>-->
<!--        </div>-->

<!--        <table v-if="officeFdcRankingData.length > 0">-->
<!--          <tr class="grey&#45;&#45;text text&#45;&#45;darken-2">-->
<!--            <th class="center-text">Rank</th>-->
<!--            <th></th>-->
<!--            <th class="left-text">Rep</th>-->
<!--            <th class="center-text">Lead-Gen FDC %</th>-->
<!--            <th class="center-text">Self-Gen FDC</th>-->
<!--            <th class="center-text">Total FDC</th>-->
<!--          </tr>-->

<!--          <tr v-for="(row, index) in officeFdcRankingData" :key="index"-->
<!--              :class="{'highlight-user-row': row.userId === currentUserId}">-->
<!--            <td class="center-text">{{ row.rank || '' }}</td>-->
<!--            <td class="user-img-col">-->
<!--              <img v-if="row.userImageUrl" class="ranking-table-img"-->
<!--                   :src="row.userImageUrl" :alt="row.userImageAltText">-->
<!--              <img v-else class="placeholder-img"-->
<!--                   src="../../../assets/flow/user_img_placeholder.png" :alt="row.userImageAltText">-->
<!--            </td>-->
<!--            <td class="left-text">{{ row.name || '' }}</td>-->
<!--            <td class="center-text">{{ row.leadGenFdcPercentage || 0 }}%</td>-->
<!--            <td class="center-text">{{ row.selfGenFdc || 0 }}</td>-->
<!--            <td class="center-text">{{ row.totalFdc || 0 }}</td>-->
<!--          </tr>-->
<!--        </table>-->
<!--        <div v-if="!selectedCloserOffice" class="ranking-tables-no-data left-text">-->
<!--          Please select a closer office-->
<!--        </div>-->
<!--        <div v-else-if="selectedCloserOffice && officeFdcRankingData.length === 0"-->
<!--             class="ranking-tables-no-data left-text">-->
<!--          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.-->
<!--        </div>-->
<!--      </div>-->
<!--      &lt;!&ndash; OFFICE FDC RANK END &ndash;&gt;-->
<!--    </div>-->
<!--    &lt;!&ndash; RANKING TABLES TOP ROW END &ndash;&gt;-->

<!--    &lt;!&ndash; RANKING TABLES SECOND HEADER START &ndash;&gt;-->
<!--    <div class="ranking-tables-section-header" :class="{'fix-bottom-page-issue': !showCompanyRankingSection}">-->
<!--      Company Ranking-->
<!--      <div class="expand-section">-->
<!--        <v-btn text @click="showCompanyRankingSection = !showCompanyRankingSection">-->
<!--          <v-icon v-if="!showCompanyRankingSection">mdi-chevron-down</v-icon>-->
<!--          <v-icon v-else>mdi-chevron-up</v-icon>-->
<!--        </v-btn>-->
<!--      </div>-->
<!--    </div>-->
<!--    &lt;!&ndash; RANKING TABLES SECOND HEADER END &ndash;&gt;-->

<!--    &lt;!&ndash; RANKING TABLES BOTTOM ROW START &ndash;&gt;-->
<!--    <div class="ranking-tables-section" v-if="showCompanyRankingSection">-->
<!--      &lt;!&ndash; OFFICE RANKING START &ndash;&gt;-->
<!--      <div class="ranking-table">-->
<!--        <div v-if="companyOfficeRankLoading" class="section-spinner">-->
<!--          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>-->
<!--        </div>-->
<!--        <div class="ranking-table-header">-->
<!--          <v-icon class="ranking-table-icon default-text-color mr-2">mdi-office-building</v-icon>-->
<!--          <span>Office Ranking</span>-->
<!--        </div>-->

<!--        <table v-if="officeRankingData.length > 0">-->
<!--          <tr class="grey&#45;&#45;text text&#45;&#45;darken-2">-->
<!--            <th class="center-text">Rank</th>-->
<!--            <th class="left-text">Office</th>-->
<!--            <th class="left-text">Metro Area</th>-->
<!--            <th class="left-text">Region</th>-->
<!--            <th class="center-text">Lead-Gen FDC %</th>-->
<!--            <th class="center-text">Self-Gen FDC</th>-->
<!--            <th class="center-text">Total FDC</th>-->
<!--          </tr>-->

<!--          <tr v-for="(row, index) in officeRankingData" :key="index"-->
<!--              :class="{'highlight-user-row': row.officeName === userOffice}">-->
<!--            <td class="center-text">{{ row.rank }}</td>-->
<!--            <td class="left-text">{{ row.officeName || '' }}</td>-->
<!--            <td class="left-text">{{ row.metroArea || '' }}</td>-->
<!--            <td class="left-text">{{ row.region || '' }}</td>-->
<!--            <td class="center-text">{{ row.leadGenFdcPercentage || 0 }}%</td>-->
<!--            <td class="center-text">{{ row.selfGenFdc || 0 }}</td>-->
<!--            <td class="center-text">{{ row.totalFdc || 0 }}</td>-->
<!--          </tr>-->
<!--        </table>-->
<!--        <div v-else class="ranking-tables-no-data left-text">-->
<!--          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.-->
<!--        </div>-->
<!--      </div>-->
<!--      &lt;!&ndash; OFFICE RANKING END &ndash;&gt;-->

<!--      &lt;!&ndash; TOP REPS START &ndash;&gt;-->
<!--      <div id="top-reps-table" class="ranking-table">-->
<!--        <div v-if="topRepsLoading" class="section-spinner">-->
<!--          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>-->
<!--        </div>-->
<!--        <div class="ranking-table-header" id="top-reps-table-header">-->
<!--          <div>-->
<!--            <v-icon class="ranking-table-icon default-text-color mr-2">mdi-account-multiple</v-icon>-->
<!--            <span>Top Reps</span>-->
<!--          </div>-->
<!--          <input type="text" placeholder="Search" v-model="searchText">-->
<!--        </div>-->

<!--        <table v-if="topRepsData.length > 0">-->
<!--          <tr class="grey&#45;&#45;text text&#45;&#45;darken-2">-->
<!--            <th class="center-text">Rank</th>-->
<!--            <th></th>-->
<!--            <th class="left-text">Rep</th>-->
<!--            <th class="left-text">Current Office</th>-->
<!--            <th class="left-text">Metro Area</th>-->
<!--            <th class="center-text">Lead-Gen FDC %</th>-->
<!--            <th class="center-text">Self-Gen FDC</th>-->
<!--            <th class="center-text">Total FDC</th>-->
<!--          </tr>-->

<!--          <tr v-for="(row, index) in filteredTopRepsData.slice(0, userRow && !searchText ? numOffices - 1 : numOffices)"-->
<!--              :key="index"-->
<!--              :class="{'highlight-user-row': row.userId === currentUserId}">-->
<!--            <td class="center-text">{{ row.rank }}</td>-->
<!--            <td class="user-img-col">-->
<!--              <img v-if="row.userImageUrl" class="ranking-table-img"-->
<!--                   :src="row.userImageUrl" :alt="row.userImageAltText">-->
<!--              <img v-else class="placeholder-img"-->
<!--                   src="../../../assets/flow/user_img_placeholder.png" :alt="row.userImageAltText">-->
<!--            </td>-->
<!--            <td class="left-text">{{ row.name || '' }}</td>-->
<!--            <td class="left-text">{{ row.officeName || '' }}</td>-->
<!--            <td class="left-text">{{ row.metroArea || '' }}</td>-->
<!--            <td class="center-text">{{ row.leadGenFdcPercentage || 0 }}%</td>-->
<!--            <td class="center-text">{{ row.selfGenFdc || 0 }}</td>-->
<!--            <td class="center-text">{{ row.totalFdc || 0 }}</td>-->
<!--          </tr>-->
<!--          <tr v-if="userRow && !searchText"-->
<!--              class="highlight-user-row">-->
<!--            <td class="center-text">{{ userRow.rank }}</td>-->
<!--            <td class="user-img-col">-->
<!--              <img v-if="userRow.userImageUrl" class="ranking-table-img"-->
<!--                   :src="userRow.userImageUrl" :alt="userRow.userImageAltText">-->
<!--              <img v-else class="placeholder-img"-->
<!--                   src="../../../assets/flow/user_img_placeholder.png" :alt="userRow.userImageAltText">-->
<!--            </td>-->
<!--            <td class="left-text">{{ userRow.name || '' }}</td>-->
<!--            <td class="left-text">{{ userRow.officeName || '' }}</td>-->
<!--            <td class="left-text">{{ userRow.metroArea || '' }}</td>-->
<!--            <td class="center-text">{{ userRow.leadGenFdcPercentage || 0 }}%</td>-->
<!--            <td class="center-text">{{ userRow.selfGenFdc || 0 }}</td>-->
<!--            <td class="center-text">{{ userRow.totalFdc || 0 }}</td>-->
<!--          </tr>-->
<!--        </table>-->
<!--        <div v-else class="ranking-tables-no-data left-text">-->
<!--          Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.-->
<!--        </div>-->
<!--      </div>-->
<!--      &lt;!&ndash; TOP REPS END &ndash;&gt;-->
<!--    </div>-->
<!--    &lt;!&ndash; RANKING TABLES BOTTOM ROW END &ndash;&gt;-->
<!--    &lt;!&ndash;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45; DASHBOARD TAB END &#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&#45;&ndash;&gt;-->
<!--  </v-container>-->
<!--</template>-->

<!--<script>-->
<!--  import cloneDeep from 'lodash.clonedeep'-->
<!--  import groupBy from 'lodash.groupby'-->
<!--  import orderBy from 'lodash.orderby'-->
<!--  import moment from 'moment'-->
<!--  import constants from '@/helpers/constants'-->
<!--  import { handleHidingGlobalLoader, getRequest, getRequestWithParams, getSnackbar } from '@/helpers/helpers'-->
<!--  import { AppMutations } from '@/stores/AppStore'-->
<!--  import SpinnerInline from '@/components/SpinnerInline'-->
<!--  import CloserRankingTable from "./CloserRankingTable.vue";-->

<!--  export default {-->
<!--    name: 'closerDashboard',-->
<!--    components: {-->
<!--      SpinnerInline,-->
<!--      CloserRankingTable-->
<!--    },-->
<!--    data () {-->
<!--      return {-->
<!--        snackbar: {},-->
<!--        constants,-->
<!--        roundRobinFilterList: [],-->
<!--        roundRobinFilterTypes: ['Dates'],-->
<!--        dropdownValues: [],-->
<!--        currentUserId: this.$store.state.user.details.id,-->
<!--        currentUserOrgId: null,-->
<!--        selectedQuarter: 1,-->
<!--        userCanViewAll: this.$store.getters.userHasFeatureAccessLevel('CLOSER_DASHBOARD', 'VIEW_ALL'),-->
<!--        timeIntervalBtnGroup: 1, // determines which time interval button gets the active class-->
<!--        timeIntervalString: '60 days', // 60 days is selected by default-->
<!--        timeInterval: 60, // default time interval selection-->
<!--        rankingTablesLoaded: false,-->
<!--        dashboardWasLoaded: false,-->
<!--        currentQuarter: moment().quarter(),-->
<!--        rankingData: [],-->
<!--        searchText: '',-->
<!--        roundRobins: [],-->
<!--        selectedRoundRobin: null,-->
<!--        closerOffices: [],-->
<!--        selectedCloserOffice: null,-->
<!--        leadAllocationRankingData: [],-->
<!--        leadAllocationRankingHeaders: [],-->
<!--        officeFdcRankingData: [],-->
<!--        officeRankingData: [],-->
<!--        topRepsData: [],-->
<!--        userOffice: '',-->
<!--        userRow: [],-->
<!--        userRowIndex: -1,-->
<!--        numOffices: 0,-->
<!--        roundRobinRanksLoading: true,-->
<!--        officeFdcRankLoading: true,-->
<!--        companyOfficeRankLoading: true,-->
<!--        topRepsLoading: true,-->
<!--        showOfficeRankingSection: true,-->
<!--        showCompanyRankingSection: true,-->
<!--      }-->
<!--    },-->
<!--    computed: {-->
<!--      filteredTopRepsData () {-->
<!--        if (this.searchText) {-->
<!--          return this.topRepsData.filter(r => {-->
<!--            return (r.name + r.officeName + r.metroArea).toLowerCase().includes(this.searchText.toLowerCase())-->
<!--          })-->
<!--        } else {-->
<!--          return this.topRepsData-->
<!--        }-->
<!--      },-->
<!--    },-->
<!--    watch: {},-->
<!--    methods: {-->
<!--      getDropdownById(id){-->
<!--        return this.dropdownValues.find(x => x.id === id)-->
<!--      },-->
<!--      assignCloserRanks (rankingData, fieldName) {-->
<!--        let currentRank = 1-->
<!--        let tiedRowNums = []-->
<!--        rankingData?.forEach(row => row[fieldName] = row[fieldName] ? row[fieldName] : 0)-->
<!--        rankingData = orderBy(rankingData, fieldName, 'desc')-->

<!--        // handles ties & assigns rank #'s-->
<!--        rankingData?.forEach((row, index) => {-->
<!--          if ((index < rankingData.length - 1) && (rankingData[index][fieldName] === rankingData[index + 1][fieldName])) { // makes sure we're not out of bounds & checks if current row is tied with next row-->
<!--            tiedRowNums.push(index) // adds current row # to list of tied row #'s-->
<!--          } else {-->
<!--            if (tiedRowNums.length > 0) {-->
<!--              if (tiedRowNums.indexOf(index) === -1) tiedRowNums.push(index) // adds row # for last tied row in current set-->
<!--              tiedRowNums.forEach(tiedRowNum => rankingData[tiedRowNum].rank = 'T' + currentRank) // adds T-prefixed rank labels to all tied rows-->
<!--              currentRank += tiedRowNums.length // skips rank #'s based on # of tied rows-->
<!--              tiedRowNums = [] // clears out #'s of tied rows since they've already been taken care of-->
<!--            } else {-->
<!--              rankingData[index].rank = currentRank++ // adds 1 to currentRank after assigning current rank # to current row-->
<!--            }-->
<!--          }-->
<!--        })-->

<!--        return rankingData-->
<!--      },-->

<!--      resetScrollBarPosition () {-->
<!--        // reset scroll bar position to top-->
<!--        this.$refs.closerDashContainer.scrollTop = 0-->
<!--      },-->

<!--      /* RANKING TABLES-RELATED CODE START */-->
<!--      async loadRoundRobins () {-->
<!--        this.roundRobinRanksLoading = true-->
<!--        try {-->
<!--          const {data, status} = await getRequest('/closerDashboard/getRoundRobins', 'blueraven')-->
<!--          this.roundRobins = data-->

<!--          // if there's only one Round Robin for the current user, this auto-selects it-->
<!--          if (this.roundRobins?.length === 1) {-->
<!--            this.selectedRoundRobin = this.roundRobins[0]?.id-->
<!--          }-->
<!--          //REMOVE THIS-->
<!--          this.selectedRoundRobin = 7-->
<!--          this.timeInterval = 102-->
<!--          await this.loadRoundRobinLeadAllocationRankData()-->
<!--          console.log(this.leadAllocationRankingData)-->

<!--          //END REMOVE-->
<!--          this.roundRobinRanksLoading = false-->

<!--          handleHidingGlobalLoader(this, status)-->
<!--        } catch (e) {-->
<!--          console.error('*** ERROR ***', e)-->
<!--          this.snackbar = getSnackbar('ERROR', 'Error retrieving list of round robins')-->
<!--          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)-->
<!--          this.roundRobinRanksLoading = false-->
<!--        }-->
<!--      },-->

<!--      async loadRoundRobinLeadAllocationRankData () {-->
<!--        this.roundRobinRanksLoading = true-->
<!--        try {-->
<!--          const params = {roundRobinId: this.selectedRoundRobin, timeInterval: this.timeInterval}-->
<!--          const {data} = await getRequestWithParams('/closerDashboard/getRoundRobinLeadAllocationRank', {params}, 'blueraven')-->
<!--          this.processRankingData(data, 'Round Robin Lead Allocation Rank')-->
<!--          this.roundRobinRanksLoading = false-->
<!--        } catch (e) {-->
<!--          this.snackbar = getSnackbar('ERROR', 'Error retrieving round robin lead allocation rank data')-->
<!--          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)-->
<!--          this.roundRobinRanksLoading = false-->
<!--        }-->
<!--      },-->

<!--      async loadCloserOffices () {-->
<!--        this.officeFdcRankLoading = true-->
<!--        try {-->
<!--          const params = {-->
<!--            userOrgId: this.currentUserOrgId-->
<!--          }-->
<!--          const {data} = await getRequestWithParams('/closerDashboard/getCloserOffices', {params}, 'blueraven')-->
<!--          this.closerOffices = data-->

<!--          // if there's only one Closer Office for the current user, this auto-selects it-->
<!--          if (this.closerOffices?.length === 1) {-->
<!--            this.selectedCloserOffice = this.closerOffices[0]?.id-->
<!--            await this.loadOfficeFdcRankData()-->
<!--          }-->
<!--          this.officeFdcRankLoading = false-->
<!--        } catch (e) {-->
<!--          console.error('*** ERROR ***', e)-->
<!--          this.snackbar = getSnackbar('ERROR', 'Error retrieving list of closer offices')-->
<!--          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)-->
<!--          this.officeFdcRankLoading = false-->
<!--        }-->
<!--      },-->

<!--      async loadOfficeFdcRankData () {-->
<!--        this.officeFdcRankLoading = true-->
<!--        try {-->
<!--          let params = {-->
<!--            timeInterval: this.timeInterval,-->
<!--            officeFdcRank: true,-->
<!--            selectedOrgId: this.selectedCloserOffice-->
<!--          }-->
<!--          const {data} = await getRequestWithParams('/closerDashboard/getCloserTableScores', {params}, 'blueraven')-->

<!--          this.processRankingData(cloneDeep(data.officeFdcRankValues), 'Office FDC Rank')-->
<!--          this.officeFdcRankLoading = false-->
<!--        } catch (e) {-->
<!--          this.snackbar = getSnackbar('ERROR', 'Error retrieving office FDC rank data')-->
<!--          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)-->
<!--          this.officeFdcRankLoading = false-->
<!--        }-->
<!--      },-->

<!--      async setTimeInterval (timeIntervalString) {-->
<!--        this.timeIntervalString = timeIntervalString-->

<!--        switch (this.timeIntervalString) {-->
<!--          case 'WTD':-->
<!--            this.timeInterval = moment().isoWeekday() - 1 // WTD-->
<!--            break-->
<!--          case 'MTD':-->
<!--            this.timeInterval = +moment().format('DD') // MTD-->
<!--            break-->
<!--          case '60 days':-->
<!--            this.timeInterval = 60-->
<!--            break-->
<!--          case '90 days':-->
<!--            this.timeInterval = 90-->
<!--            break-->
<!--          case 'YTD':-->
<!--            this.timeInterval = moment().dayOfYear() // YTD-->
<!--            break-->
<!--        }-->

<!--        if (this.selectedRoundRobin) {-->
<!--          await this.loadRoundRobinLeadAllocationRankData()-->
<!--        }-->

<!--        if (this.selectedCloserOffice) {-->
<!--          await this.loadOfficeFdcRankData()-->
<!--        }-->

<!--        await this.loadRankingTables()-->
<!--      },-->

<!--      async loadRankingTables () {-->
<!--        this.rankingTablesLoaded = false-->
<!--        this.rankingData = []-->
<!--        this.searchText = ''-->
<!--        this.topRepsLoading = true-->
<!--        this.companyOfficeRankLoading = true-->

<!--        try {-->
<!--          let params = {-->
<!--            timeInterval: this.timeInterval,-->
<!--            officeFdcRank: false-->
<!--          }-->
<!--          const {data} = await getRequestWithParams('/closerDashboard/getCloserTableScores', {params}, 'blueraven', [])-->

<!--          if (data?.companyRankingValues?.filter(row => row.userId === this.currentUserId)[0] !== undefined) {-->
<!--            this.userOffice = data?.companyRankingValues?.filter(row => row.userId === this.currentUserId)[0].officeName-->
<!--          }-->

<!--          this.processRankingData(cloneDeep(data.companyRankingValues), 'Office Ranking')-->
<!--          this.processRankingData(cloneDeep(data.companyRankingValues), 'Top Reps')-->

<!--          this.rankingTablesLoaded = true-->
<!--          this.topRepsLoading = false-->
<!--          this.companyOfficeRankLoading = false-->
<!--        } catch (e) {-->
<!--          console.error('*** ERROR ***', e)-->
<!--          this.snackbar = getSnackbar('ERROR', 'Error retrieving ranking table data')-->
<!--          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)-->
<!--          this.rankingTablesLoaded = true-->
<!--          this.topRepsLoading = false-->
<!--          this.companyOfficeRankLoading = false-->
<!--        }-->
<!--      },-->

<!--      processRankingData (rankingData, currentTable) {-->
<!--        if (currentTable === 'Round Robin Lead Allocation Rank') {-->
<!--          this.leadAllocationRankingData = this.assignCloserRanks(rankingData, 'score')-->
<!--        } else {-->
<!--          switch (currentTable) {-->
<!--            case 'Office FDC Rank':-->
<!--              this.officeFdcRankingData = this.assignCloserRanks(rankingData, 'totalFdc')-->
<!--              break-->
<!--            case 'Office Ranking':-->
<!--              this.officeRankingData = []-->
<!--              rankingData = groupBy(rankingData, 'officeName')-->

<!--              Object.keys(rankingData).forEach(group => {-->
<!--                let leadGenFdcPercentageSum = 0-->
<!--                let selfGenFdcSum = 0-->
<!--                let totalFdcSum = 0-->
<!--                let numRepsInGroup = 0-->

<!--                rankingData[group].forEach(rep => {-->
<!--                  leadGenFdcPercentageSum += parseInt(rep.leadGenFdcPercentage)-->
<!--                  selfGenFdcSum += rep.selfGenFdc-->
<!--                  totalFdcSum += rep.totalFdc-->
<!--                  numRepsInGroup++-->
<!--                })-->

<!--                this.officeRankingData.push({-->
<!--                  officeName: rankingData[group][0].officeName,-->
<!--                  metroArea: rankingData[group][0].metroArea,-->
<!--                  region: rankingData[group][0].region,-->
<!--                  leadGenFdcPercentage: Math.round(leadGenFdcPercentageSum / numRepsInGroup),-->
<!--                  selfGenFdc: selfGenFdcSum,-->
<!--                  totalFdc: totalFdcSum-->
<!--                })-->
<!--              })-->

<!--              this.officeRankingData = this.assignCloserRanks(this.officeRankingData, 'totalFdc')-->
<!--              break-->
<!--            case 'Top Reps':-->
<!--              this.userRow = null-->
<!--              this.numOffices = this.officeRankingData.length-->
<!--              this.topRepsData = this.assignCloserRanks(rankingData, 'totalFdc')-->

<!--              // determine whether current user's row is one of the visible rows-->
<!--              this.userRowIndex = this.topRepsData.findIndex(row => row.userId === this.currentUserId)-->
<!--              if (this.userRowIndex !== -1 && this.userRowIndex > this.numOffices - 1) {-->
<!--                this.userRow = this.topRepsData.filter(row => row.userId === this.currentUserId)[0]-->
<!--              }-->
<!--          }-->
<!--        }-->
<!--      },-->
<!--      async getDropdownValues() {-->
<!--        try {-->
<!--          this.$store.commit(AppMutations.SET_LOADING, true)-->

<!--          const params = {-->
<!--            today: moment().format('YYYY-MM-DD')-->
<!--          }-->

<!--          const {data, status} = await getRequestWithParams('/closerDashboard/dropdownValues', {params}, 'blueraven', [])-->
<!--          this.dropdownValues = data-->
<!--          this.roundRobinFilterList[0] = data-->
<!--          this.isLoading = false-->
<!--          handleHidingGlobalLoader(this, status)-->
<!--        } catch (e) {-->
<!--          console.error('*** ERROR ***', e)-->
<!--          this.snackbar = getSnackbar('ERROR', 'Error retrieving data')-->
<!--          this.isLoading = false-->
<!--          this.$store.commit(AppMutations.SET_LOADING, false)-->
<!--        }-->
<!--      },-->
<!--      /* RANKING TABLES-RELATED CODE END */-->
<!--    },-->
<!--    async created () {-->
<!--      this.leadAllocationRankingHeaders = [-->
<!--        { text: 'Rank', value: 'rank', sortable: false, class: 'milestone-col-th', show: true, width: '25%' },-->
<!--        { text: 'Rep', value: 'closerName', align: 'left', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser, width: '25%' },-->
<!--        { text: 'Lead-Gen FDC %', value: 'leadGenFdc', align: 'left', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser, width: '25%' },-->
<!--        { text: 'Self-Gen FDC', value: 'selfGen', align: 'left', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser, width: '25%' },-->
<!--        { text: 'Average Availability', value: 'averageAvailability', align: 'left', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser, width: '25%' },-->
<!--        { text: 'Lead Allocation %', value: 'score', align: 'left', class: 'total-col-th data-col-th', show: !this.isBrCorporateUser, width: '25%' },-->

<!--      ]-->
<!--      await this.getDropdownValues()-->
<!--      if (this.$store.state.user.details.userPositions?.length > 0) {-->
<!--        let usersPrimaryPosition = this.$store.state.user.details.userPositions.find(p => {-->
<!--          return (!p.archived && p.primaryFlag)-->
<!--        })-->

<!--        if(null != usersPrimaryPosition && [1, 2, 3, 517, 326].includes(usersPrimaryPosition.positionId)) {-->
<!--          this.currentUserOrgId = usersPrimaryPosition.orgId-->
<!--        }-->

<!--      }-->
<!--      let requests = [-->
<!--        this.loadRoundRobins(),-->
<!--        this.loadCloserOffices(),-->
<!--        this.loadRankingTables()-->
<!--      ]-->

<!--      await Promise.all(requests).then(() => {-->
<!--        this.dashboardWasLoaded = true-->
<!--      })-->

<!--    },-->
<!--  }-->
<!--</script>-->

<!--<style lang="scss" scoped>-->
<!--  .table-title{-->
<!--    padding-left:16px-->
<!--  }-->
<!--  .fix-bottom-page-issue {-->
<!--    margin-bottom: 70px !important;-->
<!--  }-->

<!--  .expand-section {-->
<!--    display: inline-block;-->
<!--    position: absolute;-->
<!--    right: 0;-->
<!--  }-->

<!--  #closer-dash-toolbar-container {-->
<!--    #closer-dash-toolbar {-->
<!--      #date-range-btns-toolbar {-->
<!--        position: fixed;-->
<!--        bottom: 0;-->
<!--        z-index: 3;-->
<!--        height: 45px !important;-->

<!--        ::v-deep .v-toolbar__content {-->
<!--          display: flex;-->
<!--          justify-content: flex-end;-->
<!--          padding: 5px 12px;-->
<!--          width: 100%;-->
<!--          height: 45px !important;-->

<!--          .v-toolbar__items {-->
<!--            display: flex;-->
<!--            flex-flow: row nowrap;-->
<!--            justify-content: flex-end;-->
<!--            align-items: center;-->
<!--            padding-right: 0;-->
<!--          }-->
<!--        }-->

<!--        .v-btn-toggle .v-btn {-->
<!--          border: 1px solid var(&#45;&#45;v-primary-base) !important;-->
<!--          font-size: 11px;-->
<!--          letter-spacing: 0.02em !important;-->
<!--          height: 25px;-->

<!--          &:not(:last-child) {-->
<!--            border-right: none !important;-->
<!--          }-->

<!--          &:hover {-->
<!--            background-color: var(&#45;&#45;v-primary-base);-->
<!--            color: #fff !important;-->
<!--          }-->
<!--        }-->

<!--        .v-btn&#45;&#45;active {-->
<!--          background-color: var(&#45;&#45;v-primary-base);-->
<!--          color: #fff !important;-->
<!--        }-->
<!--      }-->
<!--    }-->
<!--  }-->

<!--  .ranking-tables-section-header {-->
<!--    position: relative;-->
<!--    text-align: left;-->
<!--    font-family: "Roboto", sans-serif;-->
<!--    font-weight: bold;-->
<!--    font-size: 20px;-->
<!--    border-bottom: 2px solid var(&#45;&#45;v-primary-base);-->
<!--    margin: 0 auto 12px auto;-->
<!--    padding-bottom: 3px;-->
<!--    width: 100%;-->
<!--  }-->

<!--  .ranking-tables-section {-->
<!--    display: flex;-->
<!--    flex-flow: column nowrap;-->
<!--    align-items: center;-->
<!--    width: 100%;-->
<!--  }-->

<!--  .ranking-tables-no-data {-->
<!--    font-family: "Roboto", sans-serif;-->
<!--    font-size: 11px;-->
<!--    padding: 10px 10px 15px 10px;-->
<!--  }-->

<!--  .ranking-table {-->
<!--    font-family: "Roboto", sans-serif;-->
<!--    background-color: #fff;-->
<!--    box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);-->
<!--    border-radius: 4px;-->
<!--    margin-bottom: 15px;-->
<!--    overflow-x: auto;-->
<!--    width: 100%;-->
<!--    position: relative;-->
<!--  }-->

<!--  .section-spinner {-->
<!--    position: absolute;-->
<!--    height: 100% !important;-->
<!--    width: 100%;-->
<!--    text-align: center;-->
<!--    opacity: .6;-->
<!--    background: white;-->
<!--    display: flex;-->
<!--    align-items: center;-->
<!--    z-index: 1000;-->
<!--  }-->

<!--  .ranking-table-header {-->
<!--    display: flex;-->
<!--    flex-flow: row nowrap;-->
<!--    font-weight: bold;-->
<!--    font-size: 16px;-->
<!--    text-align: left;-->
<!--    padding: 10px 5px 5px 10px;-->
<!--  }-->

<!--  .user-office-ranking-table-header {-->
<!--    justify-content: space-between;-->

<!--    .table-header-dropdown {-->
<!--      transform: scale(0.875);-->
<!--      transform-origin: left;-->
<!--      margin: 0 0 5px 5px;-->
<!--      max-width: 120px;-->

<!--      ::v-deep {-->
<!--        .v-input__control {-->
<!--          height: 25px;-->
<!--        }-->

<!--        label {-->
<!--          color: #888 !important;-->
<!--          font-size: 12px;-->
<!--          font-weight: normal;-->
<!--        }-->

<!--        i {-->
<!--          color: #888 !important;-->
<!--          font-size: 20px;-->
<!--        }-->

<!--        .v-select__selections .v-select__selection {-->
<!--          color: #888 !important;-->
<!--          font-size: 12px;-->
<!--          font-weight: normal;-->
<!--        }-->
<!--      }-->
<!--    }-->
<!--  }-->

<!--  #top-reps-table {-->
<!--    margin-bottom: 150px;-->

<!--    #top-reps-table-header {-->
<!--      flex-wrap: wrap;-->
<!--      justify-content: space-between;-->
<!--      align-items: center;-->
<!--    }-->

<!--    #top-reps-table-header div {-->
<!--      display: flex;-->
<!--      flex-flow: row nowrap;-->
<!--      align-items: center;-->
<!--      padding-right: 3px;-->
<!--      padding-bottom: 3px;-->
<!--    }-->

<!--    #top-reps-table-header input {-->
<!--      font-weight: normal;-->
<!--      border: 1px solid #ccc;-->
<!--      padding-left: 3px;-->
<!--      margin-right: 5px;-->
<!--      max-width: 150px;-->
<!--    }-->
<!--  }-->

<!--  .ranking-table-icon {-->
<!--    font-size: 16px;-->
<!--  }-->

<!--  .ranking-table table {-->
<!--    border-collapse: collapse;-->
<!--    width: 100%;-->
<!--  }-->

<!--  .ranking-table th {-->
<!--    border-bottom: 1px solid #e6eeff;-->
<!--    font-size: 11px;-->
<!--    height: 55px;-->
<!--  }-->

<!--  .ranking-table td {-->
<!--    border-bottom: 1px solid #e6eeff;-->
<!--    font-weight: bold;-->
<!--    font-size: 10px;-->
<!--    height: 41px;-->
<!--  }-->

<!--  .ranking-table th,-->
<!--  .ranking-table td {-->
<!--    padding: 2px 4px;-->
<!--  }-->

<!--  .ranking-table .user-img-col {-->
<!--    padding-top: 6px;-->
<!--  }-->

<!--  .ranking-table .center-text {-->
<!--    text-align: center;-->
<!--  }-->

<!--  .ranking-table .left-text {-->
<!--    text-align: left;-->
<!--  }-->

<!--  .highlight-user-row {-->
<!--    background-color: var(&#45;&#45;v-primary-base);-->
<!--    color: #fff;-->
<!--  }-->

<!--  .ranking-table-img,-->
<!--  .placeholder-img {-->
<!--    border-radius: 50%;-->
<!--    padding: 1px;-->
<!--    width: 28px;-->
<!--    height: 28px;-->
<!--  }-->

<!--  .placeholder-img {-->
<!--    background-color: #e9e9e9;-->
<!--  }-->


<!--  @media (min-width: 737px) {-->
<!--    #closer-dash-toolbar-container {-->
<!--      #closer-dash-toolbar {-->
<!--       #date-range-btns-toolbar {-->
<!--          height: 60px !important;-->

<!--          ::v-deep .v-toolbar__content {-->
<!--            padding: 10px 12px;-->
<!--            height: 60px !important;-->
<!--          }-->

<!--          .v-btn-toggle {-->
<!--            margin-right: 0;-->

<!--            .v-btn {-->
<!--              font-size: 12px;-->
<!--              height: 30px;-->
<!--            }-->
<!--          }-->
<!--        }-->
<!--      }-->
<!--    }-->

<!--    .ranking-tables-section-header {-->
<!--      font-size: 26px;-->
<!--      margin-bottom: 20px;-->
<!--      padding-bottom: 5px;-->
<!--      max-width: calc(100% - 50px);-->
<!--    }-->

<!--    .ranking-tables-no-data {-->
<!--      font-size: 14px;-->
<!--      padding: 10px 10px 15px 15px;-->
<!--    }-->

<!--    .ranking-table {-->
<!--      margin-bottom: 30px;-->
<!--      font-size: 14px;-->
<!--      max-width: calc(100% - 50px);-->
<!--    }-->

<!--    .ranking-table-header {-->
<!--      font-size: 22px;-->
<!--      padding: 20px 15px 15px 15px;-->
<!--    }-->

<!--    .user-office-ranking-table-header {-->
<!--      .table-header-dropdown {-->
<!--        transform: none;-->
<!--        margin: 0 0 10px 10px;-->
<!--        max-width: 200px;-->

<!--        ::v-deep {-->
<!--          label {-->
<!--            font-size: 14px;-->
<!--          }-->

<!--          .v-select__selections .v-select__selection {-->
<!--            font-size: 14px;-->
<!--          }-->
<!--        }-->
<!--      }-->
<!--    }-->

<!--    .ranking-table-icon {-->
<!--      font-size: 22px;-->
<!--    }-->

<!--    .ranking-table th {-->
<!--      height: 50px;-->
<!--    }-->

<!--    .ranking-table td {-->
<!--      height: 53px;-->
<!--    }-->

<!--    .ranking-table th,-->
<!--    .ranking-table td {-->
<!--      font-size: 14px;-->
<!--      padding: 0 5px;-->
<!--    }-->

<!--    .ranking-table-img,-->
<!--    .placeholder-img {-->
<!--      width: 40px;-->
<!--      height: 40px;-->
<!--    }-->

<!--    #top-reps-table {-->
<!--      margin-bottom: 180px;-->

<!--      #top-reps-table-header div {-->
<!--        padding-right: 0;-->
<!--        padding-bottom: 0;-->
<!--      }-->

<!--      #top-reps-table-header input {-->
<!--        font-size: 14px;-->
<!--        max-width: 250px;-->
<!--        height: 30px;-->
<!--      }-->
<!--    }-->
<!--  }-->

<!--  @media (min-width: 1070px) {-->
<!--    #closer-dash-toolbar-container {-->
<!--      #closer-dash-toolbar {-->
<!--       #date-range-btns-toolbar {-->
<!--          .v-btn-toggle {-->
<!--            margin-right: 0;-->

<!--            .v-btn {-->
<!--              font-size: 13px;-->
<!--              height: 35px;-->
<!--            }-->
<!--          }-->
<!--        }-->
<!--      }-->
<!--    }-->

<!--    .ranking-tables-section-header {-->
<!--      margin: 0 auto 20px auto;-->
<!--      max-width: calc(100% - 50px)-->
<!--    }-->

<!--    .ranking-tables-section {-->
<!--      display: flex;-->
<!--      flex-flow: row nowrap;-->
<!--      justify-content: space-between;-->
<!--      align-items: flex-start;-->
<!--      max-width: calc(100% - 50px);-->
<!--      margin: 0 auto;-->
<!--    }-->

<!--    .ranking-table {-->
<!--      width: 100%;-->
<!--      max-width: calc((100% / 2) - 10px);-->
<!--    }-->

<!--    .ranking-table-header {-->
<!--      font-size: 15px;-->
<!--    }-->

<!--    .user-office-ranking-table-header {-->
<!--      .table-header-dropdown {-->
<!--        max-width: 135px;-->
<!--      }-->
<!--    }-->

<!--    .ranking-table-icon {-->
<!--      font-size: 15px;-->
<!--    }-->

<!--    .ranking-table th {-->
<!--      font-size: 12px;-->
<!--      height: 55px;-->
<!--    }-->

<!--    .ranking-table td {-->
<!--      font-size: 12px;-->
<!--      height: 55px;-->
<!--    }-->

<!--    .ranking-tables-no-data {-->
<!--      font-size: 12px;-->
<!--    }-->
<!--  }-->

<!--  @media (min-width: 1135px) {-->
<!--    .ranking-tables-section-header {-->
<!--      max-width: 1130px;-->
<!--    }-->

<!--    .ranking-tables-section {-->
<!--      max-width: 1130px;-->
<!--      margin: 0 auto;-->
<!--    }-->

<!--    .ranking-table-header, .ranking-table-icon {-->
<!--      font-size: 18px;-->
<!--    }-->
<!--  }-->
<!--</style>-->

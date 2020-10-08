<template>
  <v-container id="closer-dash-container">
    <v-row v-if="showDashboard" id="closer-dash-toolbar-container">
      <v-col cols="12" id="closer-dash-toolbar">
        <v-app-bar class="elevation-1" fixed style="top: 48px">
          <v-btn-toggle v-model="timeIntervalBtnGroup" mandatory>
            <v-btn text @click="loadRankingTables('MTD')">MTD</v-btn>
            <v-btn text @click="loadRankingTables('60 days')" class="text-lowercase">60 days</v-btn>
            <v-btn text @click="loadRankingTables('90 days')" class="text-lowercase">90 days</v-btn>
            <v-btn text @click="loadRankingTables('YTD')">YTD</v-btn>
          </v-btn-toggle>
        </v-app-bar>
      </v-col>
    </v-row>

    <v-row id="closer-dash-tabs" class="mb-2" justify="center" no-gutters
           :class="{'dashboard-tab-max-width': showDashboard, 'funnel-tab-max-width': !showDashboard}"
           :style="{'padding-top': showDashboard ? '60px' : ''}">
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
          <img id="ironman-banner-mobile" src="../../../assets/ironman_banner_mobile.png" alt="Mobile version of Ironman competition banner">
          <img id="ironman-banner" src="../../../assets/ironman_banner.png" alt="Desktop version of Ironman competition banner">
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
                <img src="../../../assets/ironman_swim_icon.png" alt="A person swimming">
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
                <img src="../../../assets/ironman_bike_icon.png" alt="A person riding a bike">
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
                <img src="../../../assets/ironman_run_icon.png" alt="A person running">
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
                <img src="../../../assets/ironman_finish_icon.png" alt="A person crossing a finish line">
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
                <img v-if="!progressBarIsFull" src="../../../assets/progress_bar_icon_blue.png"
                     alt="Blue Raven Solar logo in blue">
                <img v-if="progressBarIsFull" src="../../../assets/progress_bar_icon_white.png"
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
          <a class="close-modal-x pb-3" title="Close" @click="milestoneDialog = false">×</a>
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
                <td class="text-left customer-name">{{ item.customer_name ? item.customer_name : '' }}</td>
                <td class="text-left">{{ item.id ? item.id : '' }}</td>
                <td class="text-left">{{ item.source_name ? item.source_name : '' }}</td>
                <td class="text-left">{{ item.system_size ? item.system_size : '' }}</td>
                <td class="text-left">
                  {{ item.final_design_signed_date_formatted ? item.final_design_signed_date_formatted : '' }}
                </td>
                <td class="text-left">
                  {{ item.financial_agreement_signed_date_formatted ? item.financial_agreement_signed_date_formatted : '' }}
                </td>
                <td class="text-left">
                  {{ item.utility_bill_verified_date_formatted ? item.utility_bill_verified_date_formatted : '' }}
                </td>
                <td class="text-left">
                  {{ item.first_cash_payment_paid_date_formatted ? item.first_cash_payment_paid_date_formatted : '' }}
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
          <v-icon class="ranking-table-icon mr-2">mdi-sort-descending</v-icon>
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
                   src="../../../assets/user_img_placeholder.png" :alt="row.userImageAltText">
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
          <v-icon class="ranking-table-icon mr-2">mdi-chevron-double-down</v-icon>
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
                   src="../../../assets/user_img_placeholder.png" :alt="row.userImageAltText">
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
          <v-icon class="ranking-table-icon mr-2">mdi-office-building</v-icon>
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
            <v-icon class="ranking-table-icon mr-2">mdi-account-multiple</v-icon>
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
                   src="../../../assets/user_img_placeholder.png" :alt="row.userImageAltText">
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
                   src="../../../assets/user_img_placeholder.png" :alt="userRow.userImageAltText">
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

    <!---------------------------------- FUNNEL TAB START ---------------------------------->
    <!-- APPOINTMENTS CREATED PIPELINE START -->
    <div v-show="showFunnel" id="appts-created-pipeline-container" class="mb-8">
      <div class="pipeline-header-container">
        <v-icon class="pipeline-icon">mdi-poll</v-icon>
        <div class="pipeline-title">Appointments Created Pipeline</div>
      </div>

      <!-- FUNNEL -->
      <div class="funnel-container">
        <div v-show="apptsCreatedPipelineData.length > 0"
             id="appts-created-pipeline-funnel-background"></div>
        <table class="funnel-table">
          <tr class="funnel-tr">
            <th class="funnel-th"></th>
            <th class="funnel-th">SOURCE</th>
            <th class="funnel-th">TODAY</th>
            <th class="funnel-th">WEEK TO DATE</th>
            <th class="funnel-th">
              <div v-show="showApptsCreatedPipelineCustomDates" class="custom-dates-container">
                <v-menu v-model="appts_created_pipeline_menu1" transition="scale-transition" offset-y
                        min-width="290px" :close-on-content-click="false">
                  <template v-slot:activator="{ on }">
                    <v-text-field class="custom-date-input" v-model="appts_created_pipeline_dt1_formatted"
                                  readonly outlined dense v-on="on"></v-text-field>
                  </template>
                  <v-date-picker v-model="appts_created_pipeline_dt1" :max="appts_created_pipeline_dt2"
                                 @input="updateApptsCreatedPipelineCalendar"></v-date-picker>
                </v-menu>
                <span class="custom-date-span">-</span>
                <v-menu v-model="appts_created_pipeline_menu2" transition="scale-transition" offset-y
                        min-width="290px" :close-on-content-click="false">
                  <template v-slot:activator="{ on }">
                    <v-text-field class="custom-date-input" v-model="appts_created_pipeline_dt2_formatted"
                                  readonly outlined dense v-on="on"></v-text-field>
                  </template>
                  <v-date-picker v-model="appts_created_pipeline_dt2" :min="appts_created_pipeline_dt1"
                                 @input="updateApptsCreatedPipelineCalendar"></v-date-picker>
                </v-menu>
              </div>

              <v-menu v-model="apptsCreatedPipelineCustomSelectorIsOpen"
                      :close-on-content-click="true"
                      transition="scale-transition"
                      offset-y>
                <template v-slot:activator="{ on }">
                  <v-btn v-on="on" class="custom-dates-btn">{{ apptsCreatedPipelineDateRange.label }}<v-icon>mdi-menu-down</v-icon></v-btn>
                </template>
                <v-list>
                  <v-list-item v-for="(dateRange, index) in apptsCreatedPipelineDateRanges"
                               :key="index"
                               @click="chooseApptsCreatedPipelineDateRange(dateRange)">
                    <v-list-item-title>{{ dateRange.label }}</v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-menu>
            </th>
          </tr>

          <tr class="funnel-tr" v-for="line in apptsCreatedPipelineData" :key="line.id"
              :class="{'main-row': line.id === 10, 'blue-sub-row': line.id === 13}"
              :style="{'border-top': line.id === 12 ? '2px solid #000' : ''}">
            <td class="funnel-td funnel-line-name">{{line.name}}</td>
            <td class="funnel-td" :class="{'funnel-source': line.id === 12 || line.id === 13}">
              <v-select v-if="line.id === 12"
                        class="appts-created-pipeline-dropdown"
                        v-model="brsProvidedSourceModel"
                        :items="brsProvidedSourceData"
                        item-text="sourceName"
                        item-value="sourceId"
                        placeholder="Select"
                        multiple
                        outlined
                        background-color="white"
                        dense
                        @input="apptsCreatedPipelineLoad(appts_created_pipeline_dt1, appts_created_pipeline_dt2)">
                <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="grey--text caption">
                    {{ brsProvidedSourceModel.length }} Checked
                  </span>
                </template>
                <template v-if="brsProvidedSourceData.length > 0" v-slot:prepend-item>
                  <v-list-item @click="toggleSelectAllBrsProvidedSources">
                    <v-list-item-action>
                      <v-icon>{{ brsProvidedSourcesSelectIcon }}</v-icon>
                    </v-list-item-action>
                    <v-list-item-content>
                      <v-list-item-title>Select All</v-list-item-title>
                    </v-list-item-content>
                  </v-list-item>
                  <v-divider class="mt-2"></v-divider>
                </template>
              </v-select>

              <v-select v-if="line.id === 13"
                        class="appts-created-pipeline-dropdown"
                        v-model="selfGenSourceModel"
                        :items="selfGenSourceData"
                        item-text="sourceName"
                        item-value="sourceId"
                        placeholder="Select"
                        multiple
                        outlined
                        background-color="white"
                        dense
                        @input="apptsCreatedPipelineLoad(appts_created_pipeline_dt1, appts_created_pipeline_dt2)">
                <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="grey--text caption">
                    {{ selfGenSourceModel.length }} Checked
                  </span>
                </template>
                <template v-if="selfGenSourceData.length > 0" v-slot:prepend-item>
                  <v-list-item @click="toggleSelectAllSelfGenSources">
                    <v-list-item-action>
                      <v-icon>{{ selfGenSourcesSelectIcon }}</v-icon>
                    </v-list-item-action>
                    <v-list-item-content>
                      <v-list-item-title>Select All</v-list-item-title>
                    </v-list-item-content>
                  </v-list-item>
                  <v-divider class="mt-2"></v-divider>
                </template>
              </v-select>
            </td>
            <td class="funnel-td" @click="funnelDrilldown(line.id, 'today', line.name, 'apptsCreatedPipeline', false)">
              {{line.today_count}}
            </td>
            <td class="funnel-td" @click="funnelDrilldown(line.id, 'wtd', line.name, 'apptsCreatedPipeline', false)">
              {{line.week_to_date_count}}
            </td>
            <td class="funnel-td" @click="funnelDrilldown(line.id, 'custom', line.name, 'apptsCreatedPipeline', false)">
              {{line.custom_date_range_count}}
            </td>
          </tr>
        </table>
      </div>
    </div>
    <!-- APPOINTMENTS CREATED PIPELINE END -->

    <!-- APPOINTMENTS TO FDC PIPELINE START -->
    <div v-show="showFunnel" id="appts-to-fdc-pipeline-container"
         :class="{'mb-8': apptsToFdcPipelineData.length > 0}">
      <div class="pipeline-header-container">
        <div id="pipeline-header-left-side">
          <v-icon class="pipeline-icon">mdi-poll</v-icon>
          <div class="pipeline-title">Appointments to FDC Pipeline</div>
        </div>

        <!-- DROPDOWNS -->
        <div id="pipeline-header-right-side">
          <v-select class="appts-to-fdc-pipeline-dropdown"
                    v-model="districtModel"
                    :items="districtData"
                    item-text="org_name"
                    item-value="org_id"
                    label="District"
                    no-data-text="No districts available"
                    outlined
                    multiple
                    dense
                    hide-details
                    return-object
                    @input="regionLoad(false)">
            <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="grey--text caption">
                {{ districtModel.length }} Checked
              </span>
            </template>
            <template v-if="districtData.length > 0" v-slot:prepend-item>
              <v-list-item @click="toggleSelectAllDistricts">
                <v-list-item-action>
                  <v-icon>{{ districtSelectIcon }}</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>Select All</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-divider class="mt-2"></v-divider>
            </template>
            <template v-slot:item="data">
              <v-list-item-action>
                <v-icon v-if="data.attrs.inputValue">check_box</v-icon>
                <v-icon v-else>check_box_outline_blank</v-icon>
              </v-list-item-action>
              <v-list-item-content>
                <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">
                  {{ data.item.org_name }}
                </v-list-item-title>
              </v-list-item-content>
            </template>
          </v-select>

          <v-select class="appts-to-fdc-pipeline-dropdown"
                    v-model="regionModel"
                    :items="regionData"
                    item-text="org_name"
                    item-value="org_id"
                    label="Region"
                    no-data-text="No regions available"
                    outlined
                    multiple
                    dense
                    hide-details
                    return-object
                    @input="officeLoad(false)">
            <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="grey--text caption">
                {{ regionModel.length }} Checked
              </span>
            </template>
            <template v-if="regionData.length > 0" v-slot:prepend-item>
              <v-list-item @click="toggleSelectAllRegions">
                <v-list-item-action>
                  <v-icon>{{ regionSelectIcon }}</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>Select All</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-divider class="mt-2"></v-divider>
            </template>
            <template v-slot:item="data">
              <v-list-item-action>
                <v-icon v-if="data.attrs.inputValue">check_box</v-icon>
                <v-icon v-else>check_box_outline_blank</v-icon>
              </v-list-item-action>
              <v-list-item-content>
                <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">
                  {{ data.item.org_name }}
                </v-list-item-title>
              </v-list-item-content>
            </template>
          </v-select>

          <v-select class="appts-to-fdc-pipeline-dropdown"
                    v-model="officeModel"
                    :items="officeData"
                    item-text="org_name"
                    item-value="org_id"
                    label="Office"
                    no-data-text="No offices available"
                    outlined
                    multiple
                    dense
                    hide-details
                    return-object
                    @input="repLoad(false)">
            <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="grey--text caption">
                {{ officeModel.length }} Checked
              </span>
            </template>
            <template v-if="officeData.length > 0" v-slot:prepend-item>
              <v-list-item @click="toggleSelectAllOffices">
                <v-list-item-action>
                  <v-icon>{{ officeSelectIcon }}</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>Select All</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-divider class="mt-2"></v-divider>
            </template>
            <template v-slot:item="data">
              <v-list-item-action>
                <v-icon v-if="data.attrs.inputValue">check_box</v-icon>
                <v-icon v-else>check_box_outline_blank</v-icon>
              </v-list-item-action>
              <v-list-item-content>
                <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">
                  {{ data.item.org_name }}
                </v-list-item-title>
              </v-list-item-content>
            </template>
          </v-select>

          <v-select class="appts-to-fdc-pipeline-dropdown"
                    v-model="repModel"
                    :items="repData"
                    item-text="name"
                    item-value="user_id"
                    label="Rep"
                    no-data-text="No reps available"
                    outlined
                    multiple
                    dense
                    hide-details
                    return-object
                    @input="apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1, appts_to_fdc_pipeline_dt2)">
            <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="grey--text caption">
                {{ repModel.length }} Checked
              </span>
            </template>
            <template v-if="repData.length > 0" v-slot:prepend-item>
              <v-list-item @click="toggleSelectAllReps()">
                <v-list-item-action>
                  <v-icon>{{ repSelectIcon }}</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>Select All</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-divider class="mt-2"></v-divider>
            </template>
            <template v-slot:item="data">
              <v-list-item-action>
                <v-icon v-if="data.attrs.inputValue">check_box</v-icon>
                <v-icon v-else>check_box_outline_blank</v-icon>
              </v-list-item-action>
              <v-list-item-content>
                <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">
                  {{ data.item.name }}
                </v-list-item-title>
              </v-list-item-content>
            </template>
          </v-select>

          <v-btn id="all-reps-btn" outlined @click="funnelAllReps">All Reps</v-btn>
        </div>
      </div>

      <!-- FUNNEL -->
      <div class="funnel-container">
        <!-- FUNNEL BACKGROUND -->
        <div v-show="apptsToFdcPipelineData.length > 0" id="appts-to-fdc-pipeline-funnel-background"></div>

        <!-- TODAY PERCENTAGE LINES -->
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="today-upper-percentage-line" class="upper-percentage-line"></div>
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="today-lower-percentage-line" class="lower-percentage-line"></div>
        <!-- TODAY PERCENTAGES -->
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="today-upper-percentage" class="upper-percentage">{{todayUpperPercentage}}%</div>
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="today-lower-percentage" class="lower-percentage">{{todayLowerPercentage}}%</div>

        <!-- WTD PERCENTAGE LINES -->
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="wtd-upper-percentage-line" class="upper-percentage-line"></div>
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="wtd-lower-percentage-line" class="lower-percentage-line"></div>
        <!-- WTD PERCENTAGES -->
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="wtd-upper-percentage" class="upper-percentage">{{wtdUpperPercentage}}%</div>
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="wtd-lower-percentage" class="lower-percentage">{{wtdLowerPercentage}}%</div>

        <!-- CUSTOM DATE RANGE PERCENTAGE LINES -->
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="cdr-upper-percentage-line" class="upper-percentage-line"></div>
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="cdr-lower-percentage-line" class="lower-percentage-line"></div>
        <!-- CUSTOM DATE RANGE PERCENTAGES -->
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="cdr-upper-percentage" class="upper-percentage">{{cdrUpperPercentage}}%</div>
        <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
             id="cdr-lower-percentage" class="lower-percentage">{{cdrLowerPercentage}}%</div>

        <table class="funnel-table">
          <!-- FUNNEL COLUMN HEADERS -->
          <tr class="funnel-tr">
            <th class="funnel-th view-btns">
              <div class="view-btns-container">
                <v-btn class="funnel-btn" @click="viewSelected('standard')"
                       :class="{'white--text': viewSelect === 'standard', 'elevation-2': viewSelect !== 'standard'}"
                       :color="viewSelect === 'standard' ? 'primaryCustom' : 'secondaryCustom'">
                  Standard View
                </v-btn>
                <v-btn class="funnel-btn" @click="viewSelected('apptDateCohort')"
                       :class="{'white--text': viewSelect === 'apptDateCohort', 'elevation-2': viewSelect !== 'apptDateCohort'}"
                       :color="viewSelect === 'apptDateCohort' ? 'primaryCustom' : 'secondaryCustom'">
                  Appt Date Cohort
                </v-btn>
              </div>
            </th>
            <th class="funnel-th">TODAY</th>
            <th class="funnel-th">WEEK TO DATE</th>
            <th class="funnel-th">
              <div v-show="showApptsToFdcPipelineCustomDates" class="custom-dates-container">
                <v-menu v-model="appts_to_fdc_pipeline_menu1" transition="scale-transition" offset-y
                        min-width="290px" :close-on-content-click="false">
                  <template v-slot:activator="{ on }">
                    <v-text-field class="custom-date-input" v-model="appts_to_fdc_pipeline_dt1_formatted" readonly
                                  outlined dense v-on="on"></v-text-field>
                  </template>
                  <v-date-picker v-model="appts_to_fdc_pipeline_dt1" :max="appts_to_fdc_pipeline_dt2"
                                 @input="updateApptsToFdcPipelineCalendar()"></v-date-picker>
                </v-menu>
                <span class="custom-date-span">-</span>
                <v-menu v-model="appts_to_fdc_pipeline_menu2" transition="scale-transition" offset-y
                        min-width="290px" :close-on-content-click="false">
                  <template v-slot:activator="{ on }">
                    <v-text-field class="custom-date-input" v-model="appts_to_fdc_pipeline_dt2_formatted" readonly
                                  outlined dense v-on="on"></v-text-field>
                  </template>
                  <v-date-picker v-model="appts_to_fdc_pipeline_dt2" :min="appts_to_fdc_pipeline_dt1"
                                 @input="updateApptsToFdcPipelineCalendar()"></v-date-picker>
                </v-menu>
              </div>

              <v-menu v-model="apptsToFdcPipelineCustomSelectorIsOpen"
                      :close-on-content-click="true"
                      transition="scale-transition"
                      offset-y>
                <template v-slot:activator="{ on }">
                  <v-btn v-on="on" class="custom-dates-btn">{{ apptsToFdcPipelineDateRange.label }}<v-icon>mdi-menu-down</v-icon></v-btn>
                </template>
                <v-list>
                  <v-list-item v-for="(dateRange, index) in apptsToFdcPipelineDateRanges"
                               :key="index"
                               @click="chooseApptsToFdcPipelineDateRange(dateRange)">
                    <v-list-item-title>{{ dateRange.label }}</v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-menu>
            </th>
          </tr>
          <!-- FUNNEL ROWS -->
          <tr class="funnel-tr" v-for="line in apptsToFdcPipelineData" :key="line.id"
              :class="{'main-row': [14,17,11,4,21,8].indexOf(line.id) !== -1, 'blue-sub-row': [16,18,20,24,3,6].indexOf(line.id) !== -1}">
            <!-- FUNNEL NAME -->
            <td class="funnel-td funnel-line-name">{{line.name}}</td>

            <!-- TODAY COUNT -->
            <td class="funnel-td">
              <div v-if="[14,15,16,17,8].indexOf(line.id) === -1" class="funnel-data-container">
                <!-- CHECKED-IN COUNT -->
                <div v-if="line.id === 25" class="checked-in-column-top">Checked-in</div>
                <div v-if="[18,19,20,22,24,23,11,9,3,4,5,6,7].indexOf(line.id) !== -1"
                     class="checked-in-column-center"
                     :class="{'checked-in-column-line-overlap': [11,4].indexOf(line.id) !== -1}"
                     @click="funnelDrilldown(line.id, 'today', line.name, viewSelect, true)">
                  {{line.id === 21 ? '' : line.checked_in_today_count}}
                </div>
                <div v-if="line.id === 21"
                     class="checked-in-column-bottom checked-in-column-line-overlap"
                     @click="funnelDrilldown(line.id, 'today', line.name, viewSelect, true)">
                  {{line.checked_in_today_count}}
                </div>

                <!-- COUNT -->
                <div @click="funnelDrilldown(line.id, 'today', line.name, viewSelect, false)">
                  {{line.today_count}}
                </div>
              </div>
              <div v-else @click="funnelDrilldown(line.id, 'today', line.name, viewSelect, false)">
                {{line.today_count}}
              </div>
            </td>

            <!-- WTD COUNT -->
            <td class="funnel-td">
              <div v-if="[14,15,16,17,8].indexOf(line.id) === -1" class="funnel-data-container">
                <!-- CHECKED-IN COUNT -->
                <div v-if="line.id === 25" class="checked-in-column-top">Checked-in</div>
                <div v-if="[18,19,20,22,23,24,11,9,3,4,5,6,7].indexOf(line.id) !== -1"
                     class="checked-in-column-center"
                     :class="{'checked-in-column-line-overlap': [11,4].indexOf(line.id) !== -1}"
                     @click="funnelDrilldown(line.id, 'wtd', line.name, viewSelect, true)">
                  {{line.id === 21 ? '' : line.checked_in_week_to_date_count}}
                </div>
                <div v-if="line.id === 21"
                     class="checked-in-column-bottom checked-in-column-line-overlap"
                     @click="funnelDrilldown(line.id, 'wtd', line.name, viewSelect, true)">
                  {{line.checked_in_week_to_date_count}}
                </div>

                <!-- COUNT -->
                <div @click="funnelDrilldown(line.id, 'wtd', line.name, viewSelect, false)">
                  {{line.week_to_date_count}}
                </div>
              </div>
              <div v-else @click="funnelDrilldown(line.id, 'wtd', line.name, viewSelect, false)">
                {{line.week_to_date_count}}
              </div>
            </td>


            <!-- CUSTOM DATE RANGE COUNT -->
            <td class="funnel-td">
              <div v-if="[14,15,16,17,8].indexOf(line.id) === -1" class="funnel-data-container">
                <!-- CHECKED-IN COUNT -->
                <div v-if="line.id === 25" class="checked-in-column-top">Checked-in</div>
                <div v-if="[18,19,20,22,23,24,11,9,3,4,5,6,7].indexOf(line.id) !== -1"
                     class="checked-in-column-center"
                     :class="{'checked-in-column-line-overlap': [11,4,21].indexOf(line.id) !== -1}"
                     @click="funnelDrilldown(line.id, 'custom', line.name, viewSelect, true)">
                  {{line.id === 21 ? '' : line.checked_in_custom_date_range_count}}
                </div>
                <div v-if="line.id === 21"
                     class="checked-in-column-bottom checked-in-column-line-overlap"
                     @click="funnelDrilldown(line.id, 'custom', line.name, viewSelect, true)">
                  {{line.checked_in_custom_date_range_count}}
                </div>

                <!-- COUNT -->
                <div @click="funnelDrilldown(line.id, 'custom', line.name, viewSelect, false)">
                  {{line.custom_date_range_count}}
                </div>
              </div>
              <div v-else @click="funnelDrilldown(line.id, 'custom', line.name, viewSelect, false)">
                {{line.custom_date_range_count}}
              </div>
            </td>
          </tr>
        </table>
      </div>
    </div>
    <!-- APPOINTMENTS TO FDC PIPELINE END -->

    <!-- FUNNEL DRILLDOWN START -->
    <v-dialog v-model="funnelDrilldownDialog">
      <v-card id="funnel-drilldown">
        <v-card-title class="mb-1">
          <span id="funnel-drilldown-title">{{ funnelDrilldownTitle }}</span>
          <a class="close-modal-x pb-3" title="Close" @click="funnelDrilldownDialog = false">×</a>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-title v-if="funnelDrilldownData.length > 0" id="funnel-drilldown-search" class="pt-2">
          <v-text-field v-model="funnelDrilldownSearch"
                        placeholder="Type to filter..."
                        single-line
                        hide-details
                        outlined
                        dense
          ></v-text-field>
          <span id="funnel-drilldown-row-count">
            Records: {{ funnelDrilldownRowCount + '/' + funnelDrilldownData.length }}
          </span>
        </v-card-title>

        <v-card-text>
          <v-data-table
            id="funnel-drilldown-table"
            class="elevation-1"
            :class="{'mt-6': funnelDrilldownData.length === 0}"
            :mobile-breakpoint="0"
            :headers="visibleFunnelDrilldownHeaders"
            fixed-header
            :items="funnelDrilldownData"
            @current-items="filteredFunnelDrilldownItems"
            :search="funnelDrilldownSearch"
            :height="funnelDrilldownRowCount > 0 ? (constants.IS_MOBILE ? 'calc(100vh - 250px)' : 'calc(100vh - 355px)') : '105px'"
            dense
            multi-sort
            :sort-by="[]"
            :sort-desc="[]"
            hide-default-footer
            disable-pagination
          >
            <template v-if="funnelDrilldownData.length > 0" #item="{ item, index }" class="table-body">
              <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]"
                  :style="{'text-decoration': item.cancelled_date_formatted ? 'line-through' : ''}">
                <td style="text-align: center">
                  {{ funnelDrilldownSearch ? index + 1 : item.rowNum }}
                </td>
                <td>{{ item.owner_name ? item.owner_name : '' }}</td>
                <td>{{ item.employee_id ? item.employee_id : '' }}</td>
                <td>{{ item.state ? item.state : '' }}</td>
                <td class="customer-name">{{ item.customer_name ? item.customer_name : '' }}</td>
                <td>{{ item.deal_id ? item.deal_id : '' }}</td>
                <td :class="item.source_name_class">{{ item.source_name ? item.source_name : '' }}</td>
                <td :class="item.system_size_class">{{ item.system_size ? item.system_size : '' }}</td>
                <td :class="item.financier_class">{{ item.financier ? item.financier : '' }}</td>
                <td>{{ item.appointment_date_formatted ? item.appointment_date_formatted : '' }}</td>
                <td>{{ item.cancelled_date_formatted ? item.cancelled_date_formatted : '' }}</td>
                <td v-if="funnelDrilldownHeaders[11].show">
                  {{ item.added_on_date_formatted ? item.added_on_date_formatted : '' }}
                </td>
                <td :class="item.appointment_outcome_class" v-if="funnelDrilldownHeaders[12].show">
                  {{ item.appointment_outcome ? item.appointment_outcome : '' }}
                </td>
                <td :class="item.credit_decision_date_class" v-if="funnelDrilldownHeaders[13].show">
                  {{ item.credit_decision_date_formatted ? item.credit_decision_date_formatted : '' }}
                </td>
                <td :class="item.credit_check_class" v-if="funnelDrilldownHeaders[14].show">
                  {{ item.credit_check ? item.credit_check : '' }}
                </td>
                <td :class="item.installation_agreement_signed_date_class"
                    v-if="funnelDrilldownHeaders[15].show">
                  {{ item.installation_agreement_signed_date_formatted ? item.installation_agreement_signed_date_formatted : '' }}
                </td>
                <td :class="item.site_survey_verified_date_class"
                    v-if="funnelDrilldownHeaders[16].show">
                  {{ item.site_survey_verified_date_formatted ? item.site_survey_verified_date_formatted : '' }}
                </td>
                <td :class="item.site_survey_completed_date_class"
                    v-if="funnelDrilldownHeaders[17].show">
                  {{ item.site_survey_completed_date_formatted ? item.site_survey_completed_date_formatted : '' }}
                </td>
                <td :class="item.final_design_sent_to_customer_date_class"
                    v-if="funnelDrilldownHeaders[18].show">
                  {{ item.final_design_sent_to_customer_date_formatted ? item.final_design_sent_to_customer_date_formatted : '' }}
                </td>
                <td :class="item.final_design_signed_date_class"
                    v-if="funnelDrilldownHeaders[19].show">
                  {{ item.final_design_signed_date_formatted ? item.final_design_signed_date_formatted : '' }}
                </td>
                <td :class="item.proof_of_homeowners_insurance_obtained_date_class"
                    v-if="funnelDrilldownHeaders[20].show">
                  {{ item.proof_of_homeowners_insurance_obtained_date_formatted ? item.proof_of_homeowners_insurance_obtained_date_formatted : '' }}
                </td>
                <td :class="item.utility_bill_verified_date_class"
                    v-if="funnelDrilldownHeaders[21].show">
                  {{ item.utility_bill_verified_date_formatted ? item.utility_bill_verified_date_formatted : '' }}
                </td>
                <td :class="item.financial_agreement_signed_date_class"
                    v-if="funnelDrilldownHeaders[22].show">
                  {{ item.agreement_signed_date_formatted ? item.agreement_signed_date_formatted : '' }}
                </td>
                <td :class="item.cash_down_payment_class"
                    v-if="funnelDrilldownHeaders[23].show">
                  {{ item.cash_down_payment_date_formatted ? item.cash_down_payment_date_formatted : '' }}
                </td>
                <td :class="item.substantial_completion_date_class"
                    v-if="funnelDrilldownHeaders[24].show">
                  {{ item.substantial_completion_date_formatted ? item.substantial_completion_date_formatted : '' }}
                </td>
              </tr>
            </template>
            <template v-if="showTotalSystemSize" #footer="{ props: {} }">
              <tr id="total-system-size-row">
                <td style="width: 25px"></td>
                <td style="width: 90px"></td>
                <td style="width: 115px"></td>
                <td style="width: 75px"></td>
                <td style="width: 90px"></td>
                <td style="width: 40px"></td>
                <td id="total-system-size-label">Total Size:</td>
                <td style="width: 110px">{{ totalSystemSize ? totalSystemSize : 0 }}</td>
              </tr>
            </template>

            <template #no-data>
              <div class="my-3 funnel-drilldown-no-data-msg">
                No data is available for the selected date range.
              </div>
            </template>

            <template #no-results>
              <div class="my-3 funnel-drilldown-no-data-msg">
                No matching records found.
              </div>
            </template>
          </v-data-table>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn class="white--text text-capitalize mr-4 mb-2" color="primaryButton"
                 @click="funnelDrilldownDialog = false">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <!-- FUNNEL DRILLDOWN END -->
    <!----------------------------------- PIPELINE TAB END ----------------------------------->

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
  import constants from '@/helpers/constants'
  import { getRequest, getRequestWithParams, postRequest, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import { getCloserDistricts, getCloserRegions, getCloserOffices, getCloserReps } from '@/services/dashboardService'

  export default {
    name: 'closerDashboard',
    components: {
      Snackbar
    },
    data: () => ({
      snackbar: {},
      constants,
      milestoneDialog: false,
      funnelDrilldownDialog: false,
      currentUserId: null,
      isCloser: false,
      selectedQuarter: 1,
      headers: [
        { text: '', value: '', show: true, sortable: false },
        { text: 'Name', value: 'customer_name', show: true },
        { text: 'Deal ID', value: 'id', show: true },
        { text: 'Source', value: 'source_name', show: true },
        { text: 'System Size', value: 'system_size', show: true },
        { text: 'FD Signed Date', value: 'final_design_signed_date', show: true },
        { text: 'Financial Agreement Signed Date', value: 'financial_agreement_signed_date', show: true },
        { text: 'Utility Bill Verified Date', value: 'utility_bill_verified_date', show: true },
        { text: 'First Cash Payment Paid Date', value: 'first_cash_payment_paid_date', show: true },
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
      funnelsWereLoaded: false,
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
      numOffices: 0,
      apptsCreatedPipelineData: [],
      // TODO: Remove test data below
      apptsToFdcPipelineData: [
        // {id: 14, name: 'Total Planned Appointments', checked_in_today_count: null, today_count: 0, checked_in_week_to_date_count: null, week_to_date_count: 0, checked_in_custom_date_range_count: null, custom_date_range_count: 0, display_order: 4},
        // {id: 15, name: 'Cancelled in advance', checked_in_today_count: null, today_count: 0, checked_in_week_to_date_count: null, week_to_date_count: 0, checked_in_custom_date_range_count: null, custom_date_range_count: 0, display_order: 5},
        // {id: 16, name: 'Ineligible for solar', checked_in_today_count: null, today_count: 0, checked_in_week_to_date_count: null, week_to_date_count: 0, checked_in_custom_date_range_count: null, custom_date_range_count: 0, display_order: 6},
        // {id: 17, name: 'Total Eligible Planned Appointments', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 8},
        // {id: 25, name: 'Rescheduled', checked_in_today_count: null, today_count: 0, checked_in_week_to_date_count: null, week_to_date_count: 0, checked_in_custom_date_range_count: null, custom_date_range_count: 0, display_order: 7},
        // {id: 18, name: 'Homeowner no show', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 9},
        // {id: 19, name: 'Closer missed appointment', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 10},
        // {id: 20, name: 'Turned away at the door', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 11},
        // {id: 22, name: 'No utility bill', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 12},
        // {id: 24, name: 'Non-dispositioned appointments', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 13},
        // {id: 23, name: 'Yet to occur', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 14},
        // {id: 11, name: 'Pitched', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 15},
        // {id: 9, name: 'Credits run', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 16},
        // {id: 3, name: 'Credits passed', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 17},
        // {id: 4, name: 'Bookings Complete', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 18},
        // {id: 5, name: 'Site Surveys Verified', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 19},
        // {id: 6, name: 'Final Designs sent to Homeowner', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 20},
        // {id: 7, name: 'Final Designs Approved', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 21},
        // {id: 21, name: 'Final Designs Completed', checked_in_today_count: 0, today_count: 0, checked_in_week_to_date_count: 0, week_to_date_count: 0, checked_in_custom_date_range_count: 0, custom_date_range_count: 0, display_order: 22},
        // {id: 8, name: 'Installations Completed', checked_in_today_count: null, today_count: 0, checked_in_week_to_date_count: null, week_to_date_count: 0, checked_in_custom_date_range_count: null, custom_date_range_count: 0, display_order: 23}
      ],
      apptsCreatedPipelineCustomSelectorIsOpen: false,
      apptsToFdcPipelineCustomSelectorIsOpen: false,
      todayUpperPercentage: 99,
      todayLowerPercentage: 99,
      wtdUpperPercentage: 99,
      wtdLowerPercentage: 99,
      cdrUpperPercentage: 99,
      cdrLowerPercentage: 99,
      brsProvidedSourceModel: [],
      brsProvidedSourceData: [],
      selfGenSourceModel: [],
      selfGenSourceData: [],
      districtModel: [],
      districtData: [],
      regionModel: [],
      regionData: [],
      officeModel: [],
      officeData: [],
      repModel: [],
      repData: [],
      apptsCreatedPipelineDateRanges: [
        {
          label: 'Yesterday',
          value: 'yesterday'
        },
        {
          label: 'Last Week',
          value: 'lastWeek'
        },
        {
          label: 'Month to Date',
          value: 'MTD'
        },
        {
          label: 'Last 60 days',
          value: 60
        },
        {
          label: 'Last 90 days',
          value: 90
        },
        {
          label: 'Year to Date',
          value: 'YTD'
        },
        {
          label: 'Custom',
          value: 'Custom'
        }
      ],
      apptsCreatedPipelineDateRange: {
        label: 'Month to Date',
        value: 'MTD'
      },
      showApptsCreatedPipelineCustomDates: false,
      apptsToFdcPipelineDateRanges: [
        {
          label: 'Yesterday',
          value: 'yesterday'
        },
        {
          label: 'Last Week',
          value: 'lastWeek'
        },
        {
          label: 'Month to Date',
          value: 'MTD'
        },
        {
          label: 'Last 60 days',
          value: 60
        },
        {
          label: 'Last 90 days',
          value: 90
        },
        {
          label: 'Year to Date',
          value: 'YTD'
        },
        {
          label: 'Custom',
          value: 'Custom'
        }
      ],
      apptsToFdcPipelineDateRange: {
        label: 'Month to Date',
        value: 'MTD'
      },
      showApptsToFdcPipelineCustomDates: false,
      viewSelect: 'standard',
      appts_created_pipeline_dt1: moment().startOf('month').format('YYYY-MM-DD'),
      appts_created_pipeline_dt1_formatted: moment().startOf('month').format('M/D/YY'),
      appts_created_pipeline_menu1: false,
      appts_created_pipeline_dt2: moment().format('YYYY-MM-DD'),
      appts_created_pipeline_dt2_formatted: moment().format('M/D/YY'),
      appts_created_pipeline_menu2: false,
      appts_to_fdc_pipeline_dt1: moment().startOf('month').format('YYYY-MM-DD'),
      appts_to_fdc_pipeline_dt1_formatted: moment().startOf('month').format('M/D/YY'),
      appts_to_fdc_pipeline_menu1: false,
      appts_to_fdc_pipeline_dt2: moment().format('YYYY-MM-DD'),
      appts_to_fdc_pipeline_dt2_formatted: moment().format('M/D/YY'),
      appts_to_fdc_pipeline_menu2: false,
      funnelDrilldownTitle: '',
      funnelDrilldownHeaders: [
        { text: '', value: '', show: true, sortable: false, width: 25, optional: false },
        { text: 'Owner', value: 'owner_name', show: true, width: 90, optional: false },
        { text: 'Employee ID', value: 'employee_id', show: true, width: 115, optional: false },
        { text: 'State', value: 'state', show: true, width: 75, optional: false },
        { text: 'Name', value: 'customer_name', show: true, width: 90, optional: false },
        { text: 'Deal ID', value: 'deal_id', show: true, width: 85, optional: false },
        { text: 'Source', value: 'source_name', show: true, width: 85, optional: false },
        { text: 'System Size', value: 'system_size', show: true, width: 110, optional: false },
        { text: 'Financier', value: 'financier', show: true, width: 95, optional: false },
        { text: 'Appointment Date', value: 'appointment_date_formatted', show: true, width: 145, optional: false },
        { text: 'Cancelled Date', value: 'cancelled_date_formatted', show: true, width: 130, optional: false },
        { text: 'Added On', value: 'added_on', show: false, width: 100, optional: true },
        { text: 'Appointment Outcome', value: 'appointment_outcome', show: false, width: 170, optional: true },
        { text: 'Credit Decision Date', value: 'credit_decision_date_formatted', show: false, width: 160, optional: true },
        { text: 'Credit Check', value: 'credit_check', show: false, width: 115, optional: true },
        { text: 'Installation Agreement Signed Date', value: 'installation_agreement_signed_date', show: false, width: 215, optional: true },
        { text: 'Site Survey Verified Date', value: 'site_survey_verified_date_formatted', show: false, width: 160, optional: true },
        { text: 'Site Survey Date', value: 'site_survey_completed_date_formatted', show: false, width: 155, optional: true },
        { text: 'FD Sent to Customer Date', value: 'final_design_sent_to_customer_date_formatted', show: false, width: 165, optional: true },
        { text: 'Final Design Approved', value: 'final_design_signed_date_formatted', show: false, width: 165, optional: true },
        { text: 'Proof of HOI Obtained Date', value: 'proof_of_homeowners_insurance_obtained_date_formatted', show: false, width: 200, optional: true },
        { text: 'Utility Bill Verified Date', value: 'utility_bill_verified_date_formatted', show: false, width: 175, optional: true },
        { text: 'Financial Agreement Signed', value: 'financial_agreement_signed_date_formatted', show: false, width: 195, optional: true },
        { text: 'Cash Down Payment', value: 'cash_down_payment_date_formatted', show: false, width: 160, optional: true },
        { text: 'Substantial Completion Date', value: 'substantial_completion_date_formatted', show: false, width: 175, optional: true }
      ],
      funnelDrilldownData: [],
      funnelDrilldownSearch: '',
      filteredFunnelDrilldownData: [],
      funnelDrilldownRowCount: 0,
      totalSystemSize: 0
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
      },
      selectAllBrsProvidedSources () {
        return this.brsProvidedSourceModel.length === this.brsProvidedSourceData.length
      },
      selectSomeBrsProvidedSources () {
        return this.brsProvidedSourceModel.length > 0 && !this.selectAllBrsProvidedSources
      },
      brsProvidedSourcesSelectIcon () {
        if (this.brsProvidedSourceModel.length === this.brsProvidedSourceData.length) {
          return 'check_box'
        }
        if (this.selectSomeBrsProvidedSources) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      selectAllSelfGenSources () {
        return this.selfGenSourceModel.length === this.selfGenSourceData.length
      },
      selectSomeSelfGenSources () {
        return this.selfGenSourceModel.length > 0 && !this.selectAllSelfGenSources
      },
      selfGenSourcesSelectIcon () {
        if (this.selfGenSourceModel.length === this.selfGenSourceData.length) {
          return 'check_box'
        }
        if (this.selectSomeSelfGenSources) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      selectAllDistricts () {
        return this.districtModel.length === this.districtData.length
      },
      selectSomeDistricts () {
        return this.districtModel.length > 0 && !this.selectAllDistricts
      },
      districtSelectIcon () {
        if (this.districtModel.length === this.districtData.length) {
          return 'check_box'
        }
        if (this.selectSomeDistricts) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      selectAllRegions () {
        return this.regionModel.length === this.regionData.length
      },
      selectSomeRegions () {
        return this.regionModel.length > 0 && !this.selectAllRegions
      },
      regionSelectIcon () {
        if (this.regionModel.length === this.regionData.length) {
          return 'check_box'
        }
        if (this.selectSomeRegions) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      selectAllOffices () {
        return this.officeModel.length === this.officeData.length
      },
      selectSomeOffices () {
        return this.officeModel.length > 0 && !this.selectAllOffices
      },
      officeSelectIcon () {
        if (this.officeModel.length === this.officeData.length) {
          return 'check_box'
        }
        if (this.selectSomeOffices) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      selectAllReps () {
        return this.repModel.length === this.repData.length
      },
      selectSomeReps () {
        return this.repModel.length > 0 && !this.selectAllReps
      },
      repSelectIcon () {
        if (this.repModel.length === this.repData.length) {
          return 'check_box'
        }
        if (this.selectSomeReps) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      visibleFunnelDrilldownHeaders () {
        return this.funnelDrilldownHeaders.filter(header => header.show === true)
      },
      showTotalSystemSize () {
        return this.funnelDrilldownRowCount > 0
      }
    },
    watch: {
      // the loading animation kept going away before it was supposed to, so this makes sure that it doesn't do that anymore
      '$store.state.app.loading': function () {
        if (!this.ironmanLoaded || !this.rankingTablesLoaded) {
          this.$store.commit(AppMutations.SET_LOADING, true)
        }
      },
      appts_created_pipeline_dt1 () {
        this.appts_created_pipeline_dt1_formatted = this.formatFunnelDate(this.appts_created_pipeline_dt1)
      },
      appts_created_pipeline_dt2 () {
        this.appts_created_pipeline_dt2_formatted = this.formatFunnelDate(this.appts_created_pipeline_dt2)
      },
      appts_to_fdc_pipeline_dt1 () {
        this.appts_to_fdc_pipeline_dt1_formatted = this.formatFunnelDate(this.appts_to_fdc_pipeline_dt1)
      },
      appts_to_fdc_pipeline_dt2 () {
        this.appts_to_fdc_pipeline_dt2_formatted = this.formatFunnelDate(this.appts_to_fdc_pipeline_dt2)
      },
      funnelDrilldownDialog (val) {
        if (!val) {
          this.funnelDrilldownSearch = ''

          // resets the visibility of the optional headers
          this.funnelDrilldownHeaders.forEach(header => {
            if (header.optional) header.show = false
          })
        }
      },
      filteredFunnelDrilldownData () {
        this.calcTotalSystemSize()
      }
    },
    methods: {
      async switchTabs (tabNum) {
        this.tabNum = tabNum

        switch (tabNum) {
          case 2: // Funnel tab
            this.showDashboard = false
            this.showFunnel = true
            if (!this.funnelsWereLoaded) {
              await this.loadFunnels()
              this.funnelsWereLoaded = true
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
            this.reformatMilestoneDrilldownDates()
            this.drilldownData.forEach(row => {
              if (row.customer_name) {
                row.customer_name = row.customer_name.toLowerCase()
              }
            })
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

      reformatMilestoneDrilldownDates () {
        this.drilldownData.forEach(row => {
          if (row.final_design_signed_date) {
            row.final_design_signed_date_formatted = moment(row.final_design_signed_date).format('MMM D, YYYY')
          }

          if (row.financial_agreement_signed_date) {
            row.financial_agreement_signed_date_formatted = moment(row.financial_agreement_signed_date).format('MMM D, YYYY')
          }

          if (row.utility_bill_verified_date) {
            row.utility_bill_verified_date_formatted = moment(row.utility_bill_verified_date).format('MMM D, YYYY')
          }

          if (row.first_cash_payment_paid_date) {
            row.first_cash_payment_paid_date_formatted = moment(row.first_cash_payment_paid_date).format('MMM D, YYYY')
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
      },
      /* RANKING TABLES-RELATED CODE END */

      /* FUNNEL-RELATED CODE START */
      chooseApptsCreatedPipelineDateRange (dateRange) {
        if (this.showApptsCreatedPipelineCustomDates) {
          this.showApptsCreatedPipelineCustomDates = false
          this.fixApptsCreatedFunnelTopMargin()
        }

        this.apptsCreatedPipelineDateRange = dateRange

        switch (dateRange.value) {
          case 'yesterday':
            this.yesterday('apptsCreatedPipeline')
            break
          case 'lastWeek':
            this.lastWeek('apptsCreatedPipeline')
            break
          case 'MTD':
            this.monthToDate('apptsCreatedPipeline')
            break
          case 'YTD':
            this.yearToDate('apptsCreatedPipeline')
            break
          case 'Custom':
            this.showApptsCreatedPipelineCustomDates = true
            this.fixApptsCreatedFunnelTopMargin()
            this.$store.commit(AppMutations.SET_LOADING, false)
            break
          default:
            this.previousNumberOfDays('apptsCreatedPipeline', dateRange.value)
            break
        }
      },

      chooseApptsToFdcPipelineDateRange (dateRange) {
        if (this.showApptsToFdcPipelineCustomDates) {
          this.showApptsToFdcPipelineCustomDates = false
          this.fixApptsToFdcFunnelTopMargin()

          if (this.viewSelect === 'apptDateCohort') {
            this.fixApptDateCohortBlueLinePosition()
          }
        }

        this.apptsToFdcPipelineDateRange = dateRange

        switch (dateRange.value) {
          case 'yesterday':
            this.yesterday('apptsToFdcPipeline')
            break
          case 'lastWeek':
            this.lastWeek('apptsToFdcPipeline')
            break
          case 'MTD':
            this.monthToDate('apptsToFdcPipeline')
            break
          case 'YTD':
            this.yearToDate('apptsToFdcPipeline')
            break
          case 'Custom':
            this.showApptsToFdcPipelineCustomDates = true
            this.fixApptsToFdcFunnelTopMargin()

            if (this.viewSelect === 'apptDateCohort') {
              this.fixApptDateCohortBlueLinePosition()
            }

            this.$store.commit(AppMutations.SET_LOADING, false)
            break
          default:
            this.previousNumberOfDays('apptsToFdcPipeline', dateRange.value)
            break
        }
      },

      viewSelected (view) {
        if (this.viewSelect !== view) {
          this.viewSelect = view
          this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2)
        }
      },

      fixApptsCreatedFunnelTopMargin () {
        if (this.showApptsCreatedPipelineCustomDates) {
          if (window.innerWidth >= 737 && window.innerWidth < 1070) {
            $('#appts-created-pipeline-funnel-background').css('margin-top', '76px')
          } else if (window.innerWidth >= 1070 && window.innerWidth < 1135) {
            $('#appts-created-pipeline-funnel-background').css('margin-top', '78px')
          } else if (window.innerWidth >= 1135) {
            $('#appts-created-pipeline-funnel-background').css('margin-top', '83px')
          }
        } else {
          if (window.innerWidth >= 737 && window.innerWidth < 1070) {
            $('#appts-created-pipeline-funnel-background').css('margin-top', '58px')
          } else if (window.innerWidth >= 1070 && window.innerWidth < 1135) {
            $('#appts-created-pipeline-funnel-background').css('margin-top', '60px')
          } else if (window.innerWidth >= 1135) {
            $('#appts-created-pipeline-funnel-background').css('margin-top', '59px')
          }
        }
      },

      fixApptsToFdcFunnelTopMargin () {
        if (this.showApptsToFdcPipelineCustomDates) {
          if (window.innerWidth >= 1070 && window.innerWidth < 1135) {
            $('#appts-to-fdc-pipeline-funnel-background').css('margin-top', '82px')
          } else if (window.innerWidth >= 1135) {
            $('#appts-to-fdc-pipeline-funnel-background').css('margin-top', '87px')
          }
        } else {
          if (window.innerWidth <= 1070) {
            $('#appts-to-fdc-pipeline-funnel-background').css('margin-top', '60px')
          }
        }
      },

      fixApptDateCohortBlueLinePosition () {
        if (this.showApptsToFdcPipelineCustomDates) {
          if (window.innerWidth < 500) {
            $('.upper-percentage-line').css('top', '156px')
            $('.lower-percentage-line').css('top', '421px')
            $('.upper-percentage').css('top', '281px')
            $('.lower-percentage').css('top', '548px')
          } else if (window.innerWidth >= 500 && window.innerWidth < 737) {
            $('.upper-percentage-line').css('top', '142px')
            $('.lower-percentage-line').css('top', '407px')
            $('.upper-percentage').css('top', '267px')
            $('.lower-percentage').css('top', '534px')
          } else if (window.innerWidth >= 737 && window.innerWidth < 1070) {
            $('.upper-percentage-line').css('top', '218px')
            $('.lower-percentage-line').css('top', '556px')
            $('.upper-percentage').css('top', '383px')
            $('.lower-percentage').css('top', '706px')
          } else if (window.innerWidth >= 1070 && window.innerWidth < 1135) {
            $('.upper-percentage-line').css('top', '222px')
            $('.lower-percentage-line').css('top', '585px')
            $('.upper-percentage').css('top', '390px')
            $('.lower-percentage').css('top', '753px')
          } else if (window.innerWidth >= 1135) {
            $('.upper-percentage-line').css('top', '226px')
            $('.lower-percentage-line').css('top', '602px')
            $('.upper-percentage').css('top', '407px')
            $('.lower-percentage').css('top', '770px')
          }
        } else {
          if (window.innerWidth < 500) {
            $('.upper-percentage-line').css('top', '151px')
            $('.lower-percentage-line').css('top', '416px')
            $('.upper-percentage').css('top', '276px')
            $('.lower-percentage').css('top', '543px')
          } else if (window.innerWidth >= 500 && window.innerWidth < 737) {
            $('.upper-percentage-line').css('top', '129px')
            $('.lower-percentage-line').css('top', '394px')
            $('.upper-percentage').css('top', '254px')
            $('.lower-percentage').css('top', '521px')
          } else if (window.innerWidth >= 737 && window.innerWidth < 1070) {
            $('.upper-percentage-line').css('top', '197px')
            $('.lower-percentage-line').css('top', '534px')
            $('.upper-percentage').css('top', '362px')
            $('.lower-percentage').css('top', '686px')
          } else if (window.innerWidth >= 1070 && window.innerWidth < 1135) {
            $('.upper-percentage-line').css('top', '201px')
            $('.lower-percentage-line').css('top', '564px')
            $('.upper-percentage').css('top', '370px')
            $('.lower-percentage').css('top', '732px')
          } else if (window.innerWidth >= 1135) {
            $('.upper-percentage-line').css('top', '201px')
            $('.lower-percentage-line').css('top', '576px')

            if (window.innerWidth >= 1410) {
              $('.upper-percentage').css('top', '383px')
              $('.lower-percentage').css('top', '745px')
            } else {
              $('.upper-percentage').css('top', '382px')
              $('.lower-percentage').css('top', '744px')
            }
          }
        }
      },

      formatFunnelDate (date) {
        if (!date) return null

        return moment(date).format('M/D/YY')
      },

      parseFunnelDate (date) {
        if (!date) return null

        return moment(date, 'M/D/YY').format('YYYY-MM-DD')
      },

      loadFunnels () {
        if (this.apptsCreatedPipelineData?.length === 0) {
          this.loadSources()
        }

        if (this.apptsToFdcPipelineData?.length === 0) {
          if (this.isCloser) {
            this.districtLoad(true)
          } else {
            this.districtLoad(false)
          }
        }
      },

      funnelAllReps () {
        this.districtModel = []
        this.regionModel = []
        this.officeModel = []

        this.repModel = [
          {user_id: -1, name: 'All Reps', active: true}
        ]

        this.repData = [
          {user_id: -1, name: 'All Reps', active: true}
        ]

        this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2)
      },

      loadSources () {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          getRequest('/closerDashboard/getBrsProvidedSources', 'blueraven').then(res => {
            this.brsProvidedSourceData = res.data
            this.brsProvidedSourceModel = cloneDeep(this.brsProvidedSourceData)

            getRequest('/closerDashboard/getSelfGenSources', 'blueraven').then(res => {
              this.selfGenSourceData = res.data
              this.selfGenSourceModel = cloneDeep(this.selfGenSourceData)

              this.apptsCreatedPipelineLoad(this.appts_created_pipeline_dt1, this.appts_created_pipeline_dt2)
            })
          })
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving lists of sources')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async apptsCreatedPipelineLoad (start, end) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        let brsProvidedSources = this.brsProvidedSourceModel.map(brsProvidedSource => brsProvidedSource.sourceId)
        let selfGenSources = this.selfGenSourceModel.map(selfGenSource => selfGenSource.sourceId)

        if (brsProvidedSources.length === 0 && selfGenSources.length === 0) {
          this.apptsCreatedPipelineData = [
            {id: 12, name: 'BRS provided appointments created', today_count: 0, week_to_date_count: 0, custom_date_range_count: 0},
            {id: 13, name: 'Self-gen appointments created', today_count: 0, week_to_date_count: 0, custom_date_range_count: 0},
            {id: 10, name: 'Total Appointments Created', today_count: 0, week_to_date_count: 0, custom_date_range_count: 0}
          ]

          this.$store.commit(AppMutations.SET_LOADING, false)
          return
        }

        const requestBody = {
          brsProvidedSources: brsProvidedSources,
          selfGenSources: selfGenSources,
          start: moment(start).format('YYYY-MM-DD'),
          end: moment(end).format('YYYY-MM-DD')
        }

        try {
          await postRequest('/closerDashboard/funnel/apptsCreatedPipeline', requestBody, 'blueraven').then(res => {
            this.apptsCreatedPipelineData = orderBy(res.data, row => row.display_order)
          })

          if (this.isCloser) {
            if (this.apptsToFdcPipelineData.length > 0) {
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          } else {
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving Appointments Created Pipeline data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async apptsToFdcPipelineLoad (start, end) {
        let reps = []
        let orgs = []

        if (this.repModel.length === 0) {
          this.apptsToFdcPipelineData = []
          return
        }

        this.repModel.forEach(rep => reps.push(rep.user_id))
        this.officeModel.forEach(org => orgs.push(org.org_id))

        const requestBody = {
          users: reps,
          orgs: orgs,
          start: moment(start).format('YYYY-MM-DD'),
          end: moment(end).format('YYYY-MM-DD')
        }

        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await postRequest('/closerDashboard/funnel/' + this.viewSelect, requestBody, 'blueraven').then(res => {
            this.apptsToFdcPipelineData = orderBy(res.data, row => row.display_order)

            let todayUpperNumerator = 0
            let todayUpperDenominator = 0
            let wtdUpperNumerator = 0
            let wtdUpperDenominator = 0
            let customDateRangeUpperNumerator = 0
            let customDateRangeUpperDenominator = 0
            let todayLowerNumerator = 0
            let todayLowerDenominator = 0
            let wtdLowerNumerator = 0
            let wtdLowerDenominator = 0
            let customDateRangeLowerNumerator = 0
            let customDateRangeLowerDenominator = 0

            this.apptsToFdcPipelineData.forEach(row => {
              if (row.id === 17) {
                todayUpperDenominator = row.today_count
                wtdUpperDenominator = row.week_to_date_count
                customDateRangeUpperDenominator = row.custom_date_range_count
              }

              if (row.id === 11) {
                todayUpperNumerator = row.today_count
                wtdUpperNumerator = row.week_to_date_count
                customDateRangeUpperNumerator = row.custom_date_range_count
                todayLowerDenominator = row.today_count
                wtdLowerDenominator = row.week_to_date_count
                customDateRangeLowerDenominator = row.custom_date_range_count
              }

              if (row.id === 21) {
                todayLowerNumerator = row.today_count
                wtdLowerNumerator = row.week_to_date_count
                customDateRangeLowerNumerator = row.custom_date_range_count
              }
            })

            this.todayUpperPercentage = this.getPercentage(todayUpperNumerator, todayUpperDenominator)
            this.wtdUpperPercentage = this.getPercentage(wtdUpperNumerator, wtdUpperDenominator)
            this.cdrUpperPercentage = this.getPercentage(customDateRangeUpperNumerator, customDateRangeUpperDenominator)
            this.todayLowerPercentage = this.getPercentage(todayLowerNumerator, todayLowerDenominator)
            this.wtdLowerPercentage = this.getPercentage(wtdLowerNumerator, wtdLowerDenominator)
            this.cdrLowerPercentage = this.getPercentage(customDateRangeLowerNumerator, customDateRangeLowerDenominator)

            if (this.apptsCreatedPipelineData.length > 0) {
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          })
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving Appointments to FDC Pipeline data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      getPercentage (numerator, denominator) {
        if (denominator !== 0) {
          return Math.round((numerator / denominator) * 100)
        } else {
          return 0
        }
      },

      async districtLoad (preSelectLists) {
        if (!this.currentUserId) return

        this.$store.commit(AppMutations.SET_LOADING, true)
        await getCloserDistricts(this.currentUserId, false).then(res => {
          this.districtData = res

          if (preSelectLists) {
            this.districtModel = cloneDeep(this.districtData)
          }

          if (this.districtModel.length > 0) {
            this.regionLoad(preSelectLists)
          }
        })

        this.apptsToFdcPipelineData = []
        this.$store.commit(AppMutations.SET_LOADING, false)
      },

      async regionLoad (preSelectLists) {
        if (!this.currentUserId) return

        let districts = this.districtModel.map(function (district) {
          return {
            district_id: district.org_id
          }
        })

        if (!this.selectAllDistricts) {
          this.regionModel = []
          this.regionData = []
          this.officeModel = []
          this.officeData = []
          this.repModel = []
          this.repData = []
          this.funnelStats = []

          if (districts?.length === 0) return
        }

        this.repModel = [] // in case the user previously clicked the 'All Reps' button

        this.$store.commit(AppMutations.SET_LOADING, true)
        await getCloserRegions(this.currentUserId, JSON.stringify(districts), false).then(res => {
          this.regionData = res

          if (preSelectLists) {
            this.regionModel = cloneDeep(this.regionData)
          }

          if (this.regionModel.length > 0) {
            this.officeLoad(preSelectLists)
          }
        })

        this.apptsToFdcPipelineData = []
        this.$store.commit(AppMutations.SET_LOADING, false)
      },

      async officeLoad (preSelectLists) {
        if (!this.currentUserId) return

        let regions = this.regionModel.map(function (region) {
          return {
            region_id: region.org_id
          }
        })

        if (!this.selectAllRegions) {
          this.officeModel = []
          this.officeData = []
          this.repModel = []
          this.repData = []
          this.funnelStats = []

          if (regions?.length === 0) return
        }

        this.$store.commit(AppMutations.SET_LOADING, true)
        await getCloserOffices(this.currentUserId, JSON.stringify(regions), false).then(res => {
          this.officeData = res

          if (preSelectLists) {
            this.officeModel = cloneDeep(this.officeData)
          }

          if (this.officeModel.length > 0) {
            this.repLoad(preSelectLists)
          }
        })

        this.apptsToFdcPipelineData = []
        this.repData = []
        this.repModel = []
        this.$store.commit(AppMutations.SET_LOADING, false)
      },

      async repLoad (preSelectLists) {
        if (!this.currentUserId) return

        let regions = this.regionModel.map(function (region) {
          return {
            region_id: region.org_id
          }
        })

        let offices = this.officeModel.map(function (office) {
          return {
            office_id: office.org_id
          }
        })

        if (!this.selectAllOffices) {
          this.repModel = []
          this.repData = []
          this.funnelStats = []

          if (offices?.length === 0) return
        }

        this.$store.commit(AppMutations.SET_LOADING, true)
        await getCloserReps(this.currentUserId, JSON.stringify(regions), JSON.stringify(offices)).then(res => {
          this.repData = res

          if (preSelectLists) {
            this.repModel = cloneDeep(this.repData)
          }

          this.apptsToFdcPipelineData = []

          if (this.repModel.length > 0) {
            this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2)
          }
        })

        this.$store.commit(AppMutations.SET_LOADING, false)
      },

      updateApptsCreatedPipelineCalendar () {
        this.appts_created_pipeline_menu1 = false
        this.appts_created_pipeline_menu2 = false
        this.apptsCreatedPipelineLoad(this.appts_created_pipeline_dt1, this.appts_created_pipeline_dt2)
      },

      updateApptsToFdcPipelineCalendar () {
        this.appts_to_fdc_pipeline_menu1 = false
        this.appts_to_fdc_pipeline_menu2 = false
        this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2)
      },

      yesterday (pipelineName) {
        if (pipelineName === 'apptsCreatedPipeline') {
          this.appts_created_pipeline_dt1 = moment().subtract(1, 'd').format('YYYY-MM-DD')
          this.appts_created_pipeline_dt2 = moment().subtract(1, 'd').format('YYYY-MM-DD')
          this.updateApptsCreatedPipelineCalendar(true)
        } else {
          this.appts_to_fdc_pipeline_dt1 = moment().subtract(1, 'd').format('YYYY-MM-DD')
          this.appts_to_fdc_pipeline_dt2 = moment().subtract(1, 'd').format('YYYY-MM-DD')
          this.updateApptsToFdcPipelineCalendar(true)
        }
      },

      lastWeek (pipelineName) {
        if (pipelineName === 'apptsCreatedPipeline') {
          this.appts_created_pipeline_dt1 = moment().startOf('W').subtract(1, 'w').format('YYYY-MM-DD')
          this.appts_created_pipeline_dt2 = moment().endOf('W').subtract(1, 'w').format('YYYY-MM-DD')
          this.updateApptsCreatedPipelineCalendar(true)
        } else {
          this.appts_to_fdc_pipeline_dt1 = moment().startOf('W').subtract(1, 'w').format('YYYY-MM-DD')
          this.appts_to_fdc_pipeline_dt2 = moment().endOf('W').subtract(1, 'w').format('YYYY-MM-DD')
          this.updateApptsToFdcPipelineCalendar(true)
        }
      },

      monthToDate (pipelineName) {
        if (pipelineName === 'apptsCreatedPipeline') {
          this.appts_created_pipeline_dt1 = moment().startOf('month').format('YYYY-MM-DD')
          this.appts_created_pipeline_dt2 = moment().format('YYYY-MM-DD')
          this.updateApptsCreatedPipelineCalendar(true)
        } else {
          this.appts_to_fdc_pipeline_dt1 = moment().startOf('month').format('YYYY-MM-DD')
          this.appts_to_fdc_pipeline_dt2 = moment().format('YYYY-MM-DD')
          this.updateApptsToFdcPipelineCalendar(true)
        }
      },

      previousNumberOfDays (pipelineName, days) {
        if (pipelineName === 'apptsCreatedPipeline') {
          this.appts_created_pipeline_dt1 = moment().subtract(days, 'days').format('YYYY-MM-DD')
          this.appts_created_pipeline_dt2 = moment().format('YYYY-MM-DD')
          this.updateApptsCreatedPipelineCalendar()
        } else {
          this.appts_to_fdc_pipeline_dt1 = moment().subtract(days, 'days').format('YYYY-MM-DD')
          this.appts_to_fdc_pipeline_dt2 = moment().format('YYYY-MM-DD')
          this.updateApptsToFdcPipelineCalendar()
        }
      },

      yearToDate (pipelineName) {
        if (pipelineName === 'apptsCreatedPipeline') {
          this.appts_created_pipeline_dt1 = moment().startOf('year').format('YYYY-MM-DD')
          this.appts_created_pipeline_dt2 = moment().format('YYYY-MM-DD')
          this.updateApptsCreatedPipelineCalendar()
        } else {
          this.appts_to_fdc_pipeline_dt1 = moment().startOf('year').format('YYYY-MM-DD')
          this.appts_to_fdc_pipeline_dt2 = moment().format('YYYY-MM-DD')
          this.updateApptsToFdcPipelineCalendar()
        }
      },

      async funnelDrilldown (funnelId, dateRange, funnelName, pipelineName, isCheckedInColumn) {
        let sourceIds = []
        let userIds = []
        let orgIds = []
        let start, end
        let datesMatch = false

        if (pipelineName === 'apptsCreatedPipeline') {
          if (funnelId === 12) { // BRS-provided sources
            sourceIds = this.brsProvidedSourceModel.map(brsProvidedSource => brsProvidedSource.sourceId)
          } else { // Self-gen sources
            sourceIds = this.selfGenSourceModel.map(selfGenSource => selfGenSource.sourceId)
          }

          switch (dateRange) {
            case 'today':
              start = moment().startOf('day').format('YYYY-MM-DD')
              end = moment().format('YYYY-MM-DD')
              break
            case 'wtd':
              start = moment().startOf('W').format('YYYY-MM-DD')
              end = moment().format('YYYY-MM-DD')
              break
            default:
              start = this.appts_created_pipeline_dt1
              end = this.appts_created_pipeline_dt2
              break
          }
        } else {
          userIds = this.repModel.map(rep => rep.user_id)
          orgIds = this.officeModel.map(org => org.org_id)

          switch (dateRange) {
            case 'today':
              start = moment().startOf('day').format('YYYY-MM-DD')
              end = moment().format('YYYY-MM-DD')
              break
            case 'wtd':
              start = moment().startOf('W').format('YYYY-MM-DD')
              end = moment().format('YYYY-MM-DD')
              break
            default:
              start = this.appts_to_fdc_pipeline_dt1
              end = this.appts_to_fdc_pipeline_dt2
              break
          }
        }

        datesMatch = moment(start).format('YYYY-MM-DD') === moment(end).format('YYYY-MM-DD')

        if (datesMatch) {
          this.funnelDrilldownTitle = funnelName + ' on ' + moment(start).format('M/D/YYYY')
        } else {
          this.funnelDrilldownTitle = funnelName + ' ' + moment(start).format('M/D/YYYY') + ' - ' + moment(end).format('M/D/YYYY')
        }

        switch (funnelId) {
          // Appointments Created Pipeline
          case 12: // BRS-provided appointments created
            this.funnelDrilldownHeaders[11].show = true // added_on
            break
          case 13: // Self-gen appointments created
            this.funnelDrilldownHeaders[11].show = true // added_on
            break
          case 10: // Total Appointments Created
            this.funnelDrilldownHeaders[11].show = true // added_on
            break

          // Appointments to FDC Pipeline
          case 14: // Total Planned Appointments
            break
          case 15: // Cancelled in advance
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 16: // Ineligible for solar
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 17: // Total Eligible Planned Appointments
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 25: // Rescheduled
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 18: // Homeowner no show
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 19: // Closer missed appointment
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 20: // Turned away at the door
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 22: // No utility bill
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 24: // Non-dispositioned appointments
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 23: // Yet to occur
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 11: // Pitched
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            break
          case 9: // Credits run
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            this.funnelDrilldownHeaders[13].show = true // credit_decision_date
            break
        case 3: // Credits passed
            this.funnelDrilldownHeaders[12].show = true // appointment_outcome
            this.funnelDrilldownHeaders[13].show = true // credit_decision_date
            this.funnelDrilldownHeaders[14].show = true // credit_check
            break
          case 4: // Bookings Complete
            this.funnelDrilldownHeaders[15].show = true // installation_agreement_signed_date
            this.funnelDrilldownHeaders[17].show = true // site_survey_completed_date
            break
          case 5: // Site Surveys Verified
            this.funnelDrilldownHeaders[16].show = true // site_survey_verified_date
            break
          case 6: // Final Designs sent to Homeowner
            this.funnelDrilldownHeaders[18].show = true // final_design_sent_to_customer_date
            this.funnelDrilldownHeaders[19].show = true // final_design_signed_date
            break
          case 7: // Final Designs Approved
            this.funnelDrilldownHeaders[19].show = true // final_design_signed_date
            this.funnelDrilldownHeaders[22].show = true // financial_agreement_signed_date
            this.funnelDrilldownHeaders[20].show = true // proof_of_homeowners_insurance_obtained_date
            this.funnelDrilldownHeaders[23].show = true // cash_down_payment
            this.funnelDrilldownHeaders[21].show = true // utility_bill_verified_date
            break
          case 21: // Final Designs Completed
            this.funnelDrilldownHeaders[19].show = true // final_design_signed_date
            this.funnelDrilldownHeaders[22].show = true // financial_agreement_signed_date
            this.funnelDrilldownHeaders[20].show = true // proof_of_homeowners_insurance_obtained_date
            this.funnelDrilldownHeaders[23].show = true // cash_down_payment
            this.funnelDrilldownHeaders[21].show = true // utility_bill_verified_date
            break
          case 8: // Installations Completed
            this.funnelDrilldownHeaders[24].show = true // substantial_completion_date
            break
        }

        const requestBody = {
          start: start,
          end: end,
          funnelId: funnelId
        }

        if (pipelineName === 'apptsCreatedPipeline') {
          requestBody.sources = sourceIds
        } else {
          requestBody.users = userIds
          requestBody.orgs = orgIds
          requestBody.isCheckedInColumn = isCheckedInColumn
        }

        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await postRequest(`/closerDashboard/funnelDrilldown/${pipelineName}`, requestBody, 'blueraven').then(({data}) => {
            this.funnelDrilldownData = data?.length > 0 ? data : []

            if (this.funnelDrilldownData?.length > 0) {
              for (let i = 0; i < this.funnelDrilldownData.length; i++) {
                this.funnelDrilldownData[i].rowNum = i + 1
              }

              this.markMissingDrilldownData()
              this.reformatFunnelDrilldownDates()
            }

            this.funnelDrilldownDialog = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          })
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving drilldown data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      markMissingDrilldownData() {
        this.funnelDrilldownData = this.funnelDrilldownData.map(function (line) {
          let newLine = {}

          Object.keys(line).forEach(function (key) {
            newLine[key] = line[key]
            if (key === 'cash_down_payment') {
              if (line.financier && line.financier.includes("Cash")) {
                newLine[key + '_class'] = line[key] == null ? 'missing' : ''
              }
            } else if (key === 'credit_decision_date') {
              if (line.financier && !line.financier.includes("Cash")) {
                newLine[key + '_class'] = line[key] == null ? 'missing' : ''
              }
            } else {
              newLine[key + '_class'] = !line[key] ? 'missing' : ''
            }

            if (key === 'credit_check' && line[key] && line[key] !== 'Pass' && line[key] !== 'Pending Review') {
              newLine.strike = true
            }
          })
          return newLine
        })
      },

      reformatFunnelDrilldownDates () {
        this.funnelDrilldownData.forEach(row => {
          if (row.appointment_date) {
            row.appointment_date_formatted = moment(row.appointment_date).format('MMM D, YYYY')
          }

          if (row.cancelled_date) {
            row.cancelled_date_formatted = moment(row.cancelled_date).format('MMM D, YYYY')
          }

          if (row.added_on) {
            row.added_on_date_formatted = moment(row.added_on).format('MMM D, YYYY')
          }

          if (row.credit_decision_date) {
            row.credit_decision_date_formatted = moment(row.credit_decision_date).format('MMM D, YYYY')
          }

          if (row.installation_agreement_signed_date) {
            row.installation_agreement_signed_date_formatted = moment(row.installation_agreement_signed_date).format('MMM D, YYYY')
          }

          if (row.site_survey_verified_date) {
            row.site_survey_verified_date_formatted = moment(row.site_survey_verified_date).format('MMM D, YYYY')
          }

          if (row.site_survey_completed_date) {
            row.site_survey_completed_date_formatted = moment(row.site_survey_completed_date).format('MMM D, YYYY')
          }

          if (row.final_design_sent_to_customer_date) {
            row.final_design_sent_to_customer_date_formatted = moment(row.final_design_sent_to_customer_date).format('MMM D, YYYY')
          }

          if (row.final_design_signed_date) {
            row.final_design_signed_date_formatted = moment(row.final_design_signed_date).format('MMM D, YYYY')
          }

          if (row.proof_of_homeowners_insurance_obtained_date) {
            row.proof_of_homeowners_insurance_obtained_date_formatted = moment(row.proof_of_homeowners_insurance_obtained_date).format('MMM D, YYYY')
          }

          if (row.utility_bill_verified_date) {
            row.utility_bill_verified_date_formatted = moment(row.utility_bill_verified_date).format('MMM D, YYYY')
          }

          if (row.financial_agreement_signed_date) {
            row.agreement_signed_date_formatted = moment(row.financial_agreement_signed_date).format('MMM D, YYYY')
          }

          if (row.cash_down_payment) {
            row.cash_down_payment_date_formatted = moment(row.cash_down_payment).format('MMM D, YYYY')
          }

          if (row.substantial_completion_date) {
            row.substantial_completion_date_formatted = moment(row.substantial_completion_date).format('MMM D, YYYY')
          }
        })
      },

      calcTotalSystemSize () {
        if (this.funnelDrilldownData.length > 0 && this.filteredFunnelDrilldownData.length > 0) {
          let total = 0

          this.filteredFunnelDrilldownData.forEach(row => {
            if (row.system_size) {
              total += row.system_size
            }
          })

          this.totalSystemSize = +total.toFixed(2)
        } else {
          this.totalSystemSize = 0
        }
      },

      filteredFunnelDrilldownItems (filteredItems) {
        this.filteredFunnelDrilldownData = filteredItems
        this.funnelDrilldownRowCount = filteredItems.length
      },

      toggleSelectAllBrsProvidedSources () {
        this.$nextTick(() => {
          if (this.selectAllBrsProvidedSources) {
            this.brsProvidedSourceModel = []
          } else {
            this.brsProvidedSourceModel = cloneDeep(this.brsProvidedSourceData)
            this.apptsCreatedPipelineLoad(this.appts_created_pipeline_dt1, this.appts_created_pipeline_dt2)
          }
        })
      },

      toggleSelectAllSelfGenSources () {
        this.$nextTick(() => {
          if (this.selectAllSelfGenSources) {
            this.selfGenSourceModel = []
          } else {
            this.selfGenSourceModel = cloneDeep(this.selfGenSourceData)
            this.apptsCreatedPipelineLoad(this.appts_created_pipeline_dt1, this.appts_created_pipeline_dt2)
          }
        })
      },

      toggleSelectAllDistricts () {
        this.$nextTick(() => {
          if (this.selectAllDistricts) {
            this.districtModel = []
            this.regionData = []
            this.regionModel = []
            this.officeData = []
            this.officeModel = []
            this.repData = []
            this.repModel = []
            this.funnelStats = []
          } else {
            this.districtModel = cloneDeep(this.districtData)
            this.repModel = [] // in case the user previously clicked the 'All Reps' button
            this.regionLoad(false)
          }
        })
      },

      toggleSelectAllRegions () {
        this.$nextTick(() => {
          if (this.selectAllRegions) {
            this.regionModel = []
            this.officeData = []
            this.officeModel = []
            this.repData = []
            this.repModel = []
            this.funnelStats = []
          } else {
            this.regionModel = cloneDeep(this.regionData)
            this.officeLoad(false)
          }
        })
      },

      toggleSelectAllOffices () {
        this.$nextTick(() => {
          if (this.selectAllOffices) {
            this.officeModel = []
            this.repData = []
            this.repModel = []
            this.funnelStats = []
          } else {
            this.officeModel = cloneDeep(this.officeData)
            this.repLoad(false)
          }
        })
      },

      toggleSelectAllReps () {
        this.$nextTick(() => {
          if (this.selectAllReps) {
            this.repModel = []
            this.funnelStats = []
          } else {
            this.repModel = cloneDeep(this.repData)
            this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2)
          }
        })
      }
      /* FUNNEL-RELATED CODE END */
    },
    created () {
      this.currentUserId = this.$store.state.user.details.id

      if (this.$store.state.user.details.userPositions?.length > 0) {
        this.isCloser = this.$store.state.user.details.userPositions.filter(position => {
          return (position.position === 'Closer' && !position.endDate && !position.archived && position.primaryFlag)
        }).length > 0
      }

      this.switchTabs(this.tabNum)
    },
    mounted () {
      $(window).bind('resize', this.checkWindowWidth)
      this.checkWindowWidth()
      $(window).bind('resize', this.fixApptsCreatedFunnelTopMargin)
      $(window).bind('resize', this.fixApptsToFdcFunnelTopMargin)
    },
    beforeDestroy () {
      $(window).unbind('resize')
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
    font-size: 24px;
    color: var(--v-primaryText-base) !important;
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

  #appts-created-pipeline-funnel-background,
  #appts-to-fdc-pipeline-funnel-background {
    display: none;
  }

  .upper-percentage-line,
  .lower-percentage-line {
    display: block;
    position: absolute;
    z-index: 8;
    border-top: 1px solid blue;
    border-right: 1px solid blue;
    border-bottom: 1px solid blue;
    border-top-right-radius: 2px;
    border-bottom-right-radius: 2px;
    width: 8px;
  }

  .upper-percentage-line {
    top: 151px;
    height: 263px;
  }

  .lower-percentage-line {
    top: 416px;
    height: 230px;
  }

  #today-upper-percentage-line,
  #today-lower-percentage-line {
    left: 42%;
  }

  #wtd-upper-percentage-line,
  #wtd-lower-percentage-line {
    left: 68%;
  }

  #cdr-upper-percentage-line,
  #cdr-lower-percentage-line {
    left: 93%;
  }

  .upper-percentage,
  .lower-percentage {
    position: absolute;
    z-index: 8;
    font-size: 7px;
    color: blue;
  }

  .upper-percentage {
    top: 276px;
  }

  .lower-percentage {
    top: 543px;
  }

  #today-upper-percentage,
  #today-lower-percentage {
    left: 45%;
  }

  #wtd-upper-percentage,
  #wtd-lower-percentage {
    left: 71%;
  }

  #cdr-upper-percentage,
  #cdr-lower-percentage {
    left: 96%;
  }

  #appts-created-pipeline-container {
    background-color: #fff;
    box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
    width: 100%;

    .pipeline-header-container {
      display: flex;
      flex-flow: row nowrap;
      align-items: center;
      border-bottom: 1px solid var(--v-primaryCustom-base);
      padding: 5px;
      width: 100%;

      .pipeline-icon {
        color: var(--v-primaryText-base) !important;
        font-size: 24px;
      }

      .pipeline-title {
        font-size: 18px;
        font-weight: bold;
        color: var(--v-primaryCustom-base);
        margin-left: 8px;
      }
    }

    .appts-created-pipeline-dropdown {
      font-size: 10px;
      transform: scale(0.875);
      margin: 0 auto 12px auto;
      width: 80px;
      height: 25px;

      ::v-deep label {
        color: #888 !important;
      }

      ::v-deep i {
        color: #888 !important;
        font-size: 16px;
      }

      ::v-deep .v-text-field__details {
        display: none;
      }
    }

    .funnel-container {
      position: relative;

      .funnel-table {
        border-collapse: collapse;
        width: 100%;

        .main-row {
          border-top: 1px solid #000;
          background-color: #aed5ee;
          font-weight: bold;
          padding: 5px;
        }

        .blue-sub-row {
          background-color: #e9f2ff;
        }

        .custom-dates-container {
          display: flex;
          flex-flow: row wrap;
          justify-content: center;
          margin: 0 auto;
          max-width: 65px;

          .custom-date-input {
            font-size: 8px;
            margin-bottom: 2px;
            max-width: 40px;
            height: 12px;

            ::v-deep .v-input__control {
              max-width: 40px;
              height: 14px;
            }

            ::v-deep .v-input__slot {
              padding: 0;
              width: 40px;
              height: 12px;
              min-height: 12px;
            }

            ::v-deep .v-text-field__slot input {
              text-align: center;
            }

            ::v-deep .v-text-field__details {
              display: none;
            }
          }

          .custom-date-span {
            margin: 0 2px 3px 2px;
          }
        }

        .funnel-th {
          padding: 2px;
          color: var(--v-primaryCustom-base);
          font-size: 8px;
          font-weight: normal;
          text-align: center;

          .custom-dates-btn {
            display: flex;
            flex-flow: row nowrap;
            justify-content: space-between;
            align-items: center;
            font-size: 7px;
            text-transform: capitalize;
            padding: 4px 1px;
            margin: 4px auto;
            width: 100%;
            min-width: 40px;
            max-width: 65px;
            height: 20px;

            .v-icon {
              font-size: 12px;
              margin-left: 0;
            }
          }
        }

        .funnel-line-name {
          cursor: default !important;
          position: relative;
          z-index: 7;
          text-align: left !important;
          padding-left: 5px !important;
          height: 35px;
        }

        .funnel-td {
          cursor: pointer;
          font-size: 8px;
          text-align: center;
        }

        .funnel-source {
          cursor: default !important;
          padding: 0 3px;
          height: 50px;
        }
      }
    }
  }

  #appts-to-fdc-pipeline-container {
    background-color: #fff;
    box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
    width: 100%;

    .pipeline-header-container {
      display: flex;
      flex-flow: row wrap;
      justify-content: space-between;
      align-items: center;
      border-bottom: 1px solid var(--v-primaryCustom-base);
      padding: 5px 5px 0 5px;
      width: 100%;

      .pipeline-icon {
        color: var(--v-primaryText-base) !important;
        font-size: 24px;
      }

      .pipeline-title {
        font-size: 18px;
        font-weight: bold;
        color: var(--v-primaryCustom-base);
        margin-left: 8px;
      }

      #pipeline-header-left-side,
      #pipeline-header-right-side {
        display: flex;
        flex-flow: row wrap;
        align-items: center;
      }

      #pipeline-header-right-side {
        margin-bottom: 5px;
        width: 100%;

        .appts-to-fdc-pipeline-dropdown {
          transform: scale(0.875);
          transform-origin: left;
          margin: 2px;
          max-width: 135px;

          ::v-deep {
            .v-input__slot {
              margin: 0;
            }

            label {
              color: #888 !important;
              font-size: 10px;
            }

            i {
              color: #888 !important;
              font-size: 16px;
            }
          }
        }

        #all-reps-btn {
          text-transform: capitalize;
          font-size: 10px;
          margin: 2px;
          width: 87px;
          height: 35px;
        }
      }
    }

    .funnel-container {
      position: relative;

      .funnel-table {
        border-collapse: collapse;
        width: 100%;

        .main-row {
          border-top: 1px solid #000;
          background-color: #aed5ee;
          font-weight: bold;
          padding: 5px;

          .funnel-line-name {
            padding-left: 5px !important;
          }
        }

        .blue-sub-row {
          background-color: #e9f2ff;
        }

        .view-btns-container {
          display: flex;
          flex-flow: row wrap;
          align-items: center;

          .funnel-btn {
            text-transform: capitalize;
            font-size: 6px;
            padding: 3px;
            margin: 3px;
            min-width: 50px;
            max-width: 75px;
            height: 20px;
          }

          .funnel-btn.primaryCustom {
            box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3) inset;
          }
        }

        .custom-dates-container {
          display: flex;
          flex-flow: row wrap;
          justify-content: center;
          margin: 0 auto;
          max-width: 65px;

          .custom-date-input {
            font-size: 8px;
            margin-bottom: 2px;
            max-width: 40px;
            height: 12px;

            ::v-deep .v-input__control {
              max-width: 40px;
              height: 14px;
            }

            ::v-deep .v-input__slot {
              padding: 0;
              width: 40px;
              height: 12px;
              min-height: 12px;
            }

            ::v-deep .v-text-field__slot input {
              text-align: center;
            }

            ::v-deep .v-text-field__details {
              display: none;
            }
          }

          .custom-date-span {
            margin: 0 2px 3px 2px;
          }
        }

        .funnel-th {
          color: var(--v-primaryCustom-base);
          font-size: 8px;
          font-weight: normal;
          text-align: center;
          padding: 2px;

          .custom-dates-btn {
            display: flex;
            flex-flow: row nowrap;
            justify-content: space-between;
            align-items: center;
            font-size: 7px;
            text-transform: capitalize;
            padding: 4px 3px;
            margin: 4px auto;
            width: 100%;
            min-width: 40px;
            max-width: 70px;
            height: 20px;

            .v-icon {
              font-size: 12px;
              margin-left: 0;
            }
          }
        }

        .funnel-line-name {
          cursor: default !important;
          position: relative;
          z-index: 7;
          text-align: left !important;
          padding-left: 15px !important;
          width: 30%;
          max-width: 130px;
          height: 27px;
        }

        .funnel-td {
          cursor: pointer;
          text-align: center;
          font-size: 7px;
          width: 90px;
        }

        .funnel-count {
          cursor: pointer;
        }

        .funnel-data-container {
          cursor: pointer;
          display: flex;
          flex-flow: row nowrap;
          align-items: center;
          padding: 0 5px;
          width: 90px;
        }

        .checked-in-column-top,
        .checked-in-column-center,
        .checked-in-column-bottom {
          background-color: rgba(100, 100, 100, 0.5);
          color: #fff;
          border: 1px solid #fff;
          font-weight: normal;
          text-align: center;
          margin-right: 5px;
          width: 38px;
        }

        .checked-in-column-top {
          border-bottom: none;
          border-top-left-radius: 5px;
          border-top-right-radius: 5px;
          padding: 3px 2px 5.5px 2px;
          margin-top: 3px;
        }

        .checked-in-column-center {
          border-top: none;
          border-bottom: none;
          padding: 11.4px 2px;
        }

        .checked-in-column-bottom {
          border-top: none;
          border-bottom-left-radius: 5px;
          border-bottom-right-radius: 5px;
          padding: 8px 2px 4px 2px !important;
          margin-bottom: 3px;
        }

        .checked-in-column-line-overlap {
          padding: 12.9px 2px 10.9px 2px;
          margin-top: -1px;
        }
      }
    }
  }

  #funnel-drilldown {
    .missing {
      background-color: rgba(204, 0, 0, 0.5);
    }

    .v-card__title {
      display: flex;
      flex-flow: row nowrap;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 10px;
      padding: 0 24px;

      #funnel-drilldown-title {
        font-family: "Roboto Condensed", sans-serif;
        font-size: 14px;
        line-height: 24px;
        word-break: normal;
        padding-top: 5px;
      }
    }

    .close-modal-x {
      font-size: 20px;
      margin-left: 15px;

      &:hover {
        font-weight: bolder;
      }
    }

    #funnel-drilldown-search {
      display: flex;
      flex-flow: row nowrap;
      justify-content: space-between;
      align-items: center;

      ::v-deep .v-input {
        max-width: 70%;
      }

      ::v-deep input,
      #funnel-drilldown-row-count {
        font-size: 11px;
      }
    }

    #funnel-drilldown-table {
      ::v-deep th, ::v-deep td {
        font-size: 10px;
        padding: 5px;
      }

      ::v-deep th {
        line-height: 14px;

        .v-data-table-header__icon {
          font-size: 12px !important;
          padding-bottom: 2px;
        }
      }

      #total-system-size-row:hover {
        background-color: transparent !important;
      }

      #total-system-size-label {
        font-weight: bold;
        text-align: right;
        min-width: 130px;
      }

      .customer-name {
        text-transform: capitalize;
      }

      .funnel-drilldown-no-data-msg {
        text-align: left;
        margin-left: 25px;
      }
    }

    .v-card__text {
      padding-bottom: 0;
    }

    .v-btn {
      font-size: 10px;
      width: 50px;
      min-width: 50px;
      height: 25px;
    }
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

    .upper-percentage-line {
      top: 129px;
    }

    .lower-percentage-line {
      top: 394px;
    }

    #today-upper-percentage-line,
    #today-lower-percentage-line {
      left: 56%;
    }

    #wtd-upper-percentage-line,
    #wtd-lower-percentage-line {
      left: 77%;
    }

    #cdr-upper-percentage-line,
    #cdr-lower-percentage-line {
      left: 95%;
    }

    .upper-percentage {
      top: 254px;
    }

    .lower-percentage {
      top: 521px;
    }

    #today-upper-percentage,
    #today-lower-percentage {
      left: 58%;
    }

    #wtd-upper-percentage,
    #wtd-lower-percentage {
      left: 79%;
    }

    #cdr-upper-percentage,
    #cdr-lower-percentage {
      left: 97%;
    }

    #appts-created-pipeline-container {
     .funnel-container {
       .funnel-table {
         .custom-dates-container {
           max-width: 120px;
         }
       }
     }
    }

    #appts-to-fdc-pipeline-container {
      .funnel-container {
        .funnel-table {
          .view-btns-container {
            flex-flow: row nowrap;

            .funnel-btn {
              font-size: 7px;
              margin: 5px;
              width: 100px;
            }
          }

          .custom-dates-container {
            max-width: 120px;
          }

          .funnel-data-container {
            margin-left: 8%;
          }
        }
      }
    }

    #funnel-drilldown {
      .v-card__title {
        align-items: center;
      }

      #funnel-drilldown-search {
        ::v-deep .v-input {
          max-width: 75%;
        }
      }
    }
  }

  @media (min-width: 650px) {
    #appts-to-fdc-pipeline-container {
      .funnel-container {
        .funnel-table {
          .funnel-data-container {
            margin-left: 15%;
          }
        }
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

      .col-12 span {
        font-size: 12px;
      }
    }

    .dashboard-tab-max-width,
    .funnel-tab-max-width {
      max-width: calc(100% - 50px);
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
      font-size: 30px;
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

    #appts-created-pipeline-funnel-background {
      display: block;
      position: absolute;
      z-index: 200;
      border-top-style: solid;
      border-top-color: rgba(0, 110, 200, 0.05);
      border-top-width: 137px;
      border-right: 40px solid transparent;
      border-left: 40px solid transparent;
      margin-top: 58px;
      margin-left: 5px;
      width: 260px;
      height: 0;
    }

    #appts-created-pipeline-container {
      margin: 0 auto;
      max-width: calc(100% - 50px);

      .pipeline-header-container {
        border-bottom: 2px solid var(--v-primaryCustom-base);
        padding: 10px;

        .pipeline-icon {
          font-size: 32px;
        }

        .pipeline-title {
          font-size: 24px;
          margin-left: 10px;
        }
      }

      .appts-created-pipeline-dropdown {
        font-size: 12px;
        transform: none;
        margin-bottom: 0;
        width: 100px;
        height: 40px;
      }

      .funnel-container {
        .funnel-table {
          .main-row {
            border-top: 2px solid #000;
            padding: 5px;
          }

          .custom-dates-container {
            justify-content: space-between;
            max-width: 110px;

            .custom-date-input {
              font-size: 10px;
              margin-bottom: 3px;
              max-width: 50px;
              height: 15px;

              ::v-deep .v-input__control {
                max-width: 50px;
                height: 15px;
              }

              ::v-deep .v-input__slot {
                width: 50px;
                height: 15px;
                min-height: 15px;
              }
            }

            .custom-date-span {
              margin: -2px 2px 0 2px;
            }
          }

          .funnel-th,
          .funnel-td {
            font-size: 12px;
            padding: 5px 2px;
          }

          .funnel-th {
            .custom-dates-btn {
              font-size: 10px;
              padding: 5px 5px 5px 8px;
              min-width: 70px;
              max-width: 110px;
              height: 40px;

              .v-icon {
                font-size: 18px;
              }
            }
          }

          .funnel-line-name {
            padding-left: 50px !important;
          }
        }
      }
    }

    .upper-percentage-line,
    .lower-percentage-line {
      width: 11px;
    }

    .upper-percentage-line {
      top: 197px;
      height: 334px;
    }

    .lower-percentage-line {
      top: 534px;
      height: 287px;
    }

    #today-upper-percentage-line,
    #today-lower-percentage-line {
      left: 55.5%;
    }

    #wtd-upper-percentage-line,
    #wtd-lower-percentage-line {
      left: 76%;
    }

    #cdr-upper-percentage-line,
    #cdr-lower-percentage-line {
      left: 94.5%;
    }

    .upper-percentage,
    .lower-percentage {
      font-size: 12px;
    }

    .upper-percentage {
      top: 362px;
    }

    .lower-percentage {
      top: 686px;
    }

    #today-upper-percentage,
    #today-lower-percentage {
      left: 57.5%;
    }

    #wtd-upper-percentage,
    #wtd-lower-percentage {
      left: 78%;
    }

    #cdr-upper-percentage,
    #cdr-lower-percentage {
      left: 96.5%;
    }

    #appts-to-fdc-pipeline-container {
      margin: 0 auto;
      max-width: calc(100% - 50px);

      .pipeline-header-container {
        border-bottom: 2px solid var(--v-primaryCustom-base);
        padding: 10px 10px 5px 10px;

        .pipeline-icon {
          font-size: 32px;
        }

        .pipeline-title {
          font-size: 24px;
          margin-left: 10px;
        }

        #pipeline-header-left-side {
          margin-bottom: 10px;
        }

        #pipeline-header-right-side {
          margin: 0;

          .appts-to-fdc-pipeline-dropdown {
            transform: none;
            margin: 0 10px 10px 0;

            ::v-deep {
              label {
                font-size: 14px;
              }

              i {
                font-size: 20px;
              }
            }
          }

          #all-reps-btn {
            font-size: 14px;
            margin: 0 0 10px 0;
            height: 40px;
          }
        }
      }

      .funnel-container {
        .funnel-table {
          .main-row {
            border-top: 2px solid #000;

            .funnel-line-name {
              padding-left: 10px !important;
            }
          }

          .view-btns-container {
            .funnel-btn {
              font-size: 10px;
              margin: 0 10px 0 2px;
              max-width: 100px;
              height: 40px;
            }
          }

          .custom-dates-container {
            justify-content: space-between;
            margin-bottom: 3px;
            max-width: 110px;

            .custom-date-input {
              font-size: 10px;
              margin-bottom: 3px;
              max-width: 50px;
              height: 15px;

              ::v-deep .v-input__control {
                max-width: 50px;
                height: 15px;
              }

              ::v-deep .v-input__slot {
                width: 50px;
                height: 15px;
                min-height: 15px;
              }
            }

            .custom-date-span {
              margin: -2px 2px 0 2px;
            }
          }

          .funnel-th {
            font-size: 12px;
            padding: 8px;

            .custom-dates-btn {
              font-size: 10px;
              padding-left: 5px;
              margin: 0 auto;
              max-width: 100px;
              height: 40px;

              .v-icon {
                font-size: 18px;
              }
            }
          }

          .funnel-line-name {
            padding-left: 20px !important;
            height: 40px;
          }

          .funnel-td {
            font-size: 12px;
            padding: 0 10px;
            width: 105px;
          }

          .funnel-data-container {
            margin-left: 0;
            width: 105px;
          }

          .checked-in-column-top,
          .checked-in-column-center,
          .checked-in-column-bottom {
            margin-right: 10px;
            width: 60px;
          }

          .checked-in-column-top {
            padding: 6px 1px;
            margin-top: 5px;
          }

          .checked-in-column-center {
            padding: 11px 2px;
          }

          .checked-in-column-bottom {
            padding: 15px 2px 9px 2px !important;
            margin-bottom: 5px;
          }

          .checked-in-column-line-overlap {
            margin-top: -2px;
            padding: 13px 2px 11px 2px;
          }
        }
      }
    }

    #funnel-drilldown {
      .v-card__title {
        padding: 10px 24px 0 24px;

        #funnel-drilldown-title {
          font-size: 18px;
          padding-bottom: 10px;
        }
      }

      .close-modal-x {
        font-size: 24px;
      }

      #funnel-drilldown-search {
        ::v-deep input,
        #funnel-drilldown-row-count {
          font-size: 12px;
        }

        ::v-deep .v-input {
          width: 80%;
        }

        #funnel-drilldown-row-count {
          text-align: right;
          width: 20%;
        }
      }

      #funnel-drilldown-table {
        ::v-deep th, ::v-deep td {
          font-size: 11px;
        }

        ::v-deep th {
          line-height: 16px;

          .v-data-table-header__icon {
            font-size: 14px !important;
            padding-bottom: 3px;
          }
        }
      }

      .v-card__text {
        padding-bottom: 10px;
      }

      .v-btn {
        font-size: 12px;
        width: 75px;
        height: 30px;
      }
    }
  }

  @media (min-width: 900px) {
    #today-upper-percentage-line,
    #today-lower-percentage-line {
      left: 49%;
    }

    #wtd-upper-percentage-line,
    #wtd-lower-percentage-line {
      left: 72%;
    }

    #today-upper-percentage,
    #today-lower-percentage {
      left: 51%;
    }

    #wtd-upper-percentage,
    #wtd-lower-percentage {
      left: 74%;
    }

    #appts-to-fdc-pipeline-container {
      .funnel-container {
        .funnel-table {
          .funnel-td {
            width: 150px;
          }

          .funnel-data-container {
            margin-left: 15%;
            width: 150px;
          }
        }
      }
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

    .ranking-table-icon {
      font-size: 35px;
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

    #appts-created-pipeline-funnel-background {
      border-top-width: 162px;
      border-right: 80px solid transparent;
      border-left: 80px solid transparent;
      margin-top: 60px;
      margin-left: 15px;
      width: 390px;
    }

    #appts-created-pipeline-container {
      .pipeline-header-container {
        .pipeline-icon {
          font-size: 35px;
        }

        .pipeline-title {
          margin-left: 15px;
        }
      }

      .appts-created-pipeline-dropdown {
        font-size: 14px;
        width: 150px;
      }

      .funnel-container {
        .funnel-table {
          .main-row {
            border-top: 2px solid #000;
            padding: 10px;
          }

          .custom-dates-container {
            max-width: 125px;

            .custom-date-span {
              margin: -3px 2px 0 2px;
            }
          }

          .funnel-th,
          .funnel-td {
            font-size: 14px;
          }

          .funnel-th {
            padding: 5px;

            .custom-dates-btn {
              font-size: 12px;
              padding: 8px 10px;
              min-width: 80px;
              max-width: 125px;

              .v-icon {
                font-size: 20px;
                margin-left: 0;
              }
            }
          }

          .funnel-line-name {
            padding-left: 112px !important;
          }

          .funnel-td {
            padding: 10px;
          }
        }
      }
    }

    #appts-to-fdc-pipeline-funnel-background {
      display: block;
      position: absolute;
      z-index: 200;
      border-top-style: solid;
      border-top-color: rgba(0, 110, 200, 0.05);
      border-top-width: 886px;
      border-right: 60px solid transparent;
      border-left: 60px solid transparent;
      margin-top: 60px;
      margin-left: 15px;
      width: 385px;
      height: 0;
    }

    .upper-percentage-line,
    .lower-percentage-line {
      width: 14px;
    }

    .upper-percentage-line {
      top: 201px;
      height: 357px;
    }

    .lower-percentage-line {
      top: 564px;
      height: 317px;
    }

    #today-upper-percentage-line,
    #today-lower-percentage-line {
      left: 58%;
    }

    #wtd-upper-percentage-line,
    #wtd-lower-percentage-line {
      left: 77%;
    }

    #cdr-upper-percentage-line,
    #cdr-lower-percentage-line {
      left: 95.4%;
    }

    .upper-percentage,
    .lower-percentage {
      font-size: 14px;
    }

    .upper-percentage {
      top: 370px;
    }

    .lower-percentage {
      top: 732px;
    }

    #today-upper-percentage,
    #today-lower-percentage {
      left: 60%;
    }

    #wtd-upper-percentage,
    #wtd-lower-percentage {
      left: 79%;
    }

    #cdr-upper-percentage,
    #cdr-lower-percentage {
      left: 97%;
    }

    #appts-to-fdc-pipeline-container {
      .pipeline-header-container {
        flex-flow: row nowrap;

        .pipeline-icon {
          font-size: 35px;
        }

        .pipeline-title {
          margin-left: 15px;
        }

        #pipeline-header-right-side {
          justify-content: flex-end;
          width: 58%;

          .appts-to-fdc-pipeline-dropdown,
          #all-reps-btn {
            margin: 0 0 10px 10px;
          }
        }
      }

      .funnel-container {
        .funnel-table {
          .main-row {
            .funnel-line-name {
              padding-left: 117px !important;
            }
          }

          .view-btns-container {
            .funnel-btn {
              font-size: 12px;
              margin: 0 5px;
              width: 175px;
              max-width: none;
            }
          }

          .custom-dates-container {
            max-width: 125px;

            .custom-date-span {
              margin: -3px 2px 0 2px;
            }
          }

          .funnel-th,
          .funnel-td {
            font-size: 14px;
          }

          .funnel-th {
            padding: 10px;

            .custom-dates-btn {
              font-size: 12px;
              padding: 8px 10px;
              min-width: 80px;
              max-width: 125px;

              .v-icon {
                font-size: 20px;
                margin-left: 0;
              }
            }
          }

          .funnel-line-name {
            padding-left: 129px !important;
          }

          .funnel-td {
            padding: 0 10px;
          }

          .funnel-data-container {
            margin-left: 0;
          }

          .checked-in-column-top,
          .checked-in-column-center,
          .checked-in-column-bottom {
            width: 90px;
          }

          .checked-in-column-top {
            padding: 10px 5px;
            margin-top: 5px;
          }

          .checked-in-column-center {
            padding: 12px;
          }

          .checked-in-column-bottom {
            padding: 12px 5px;
            margin-bottom: 5px;
          }

          .checked-in-column-line-overlap {
            margin-top: -2.5px !important;
            padding-top: 15px;
            padding-bottom: 11.5px;
          }
        }
      }
    }

    #funnel-drilldown {
      .v-card__title {
        #funnel-drilldown-title {
          font-size: 20px;
          line-height: 26px;
        }
      }

      #funnel-drilldown-search {
        ::v-deep input,
        #funnel-drilldown-row-count {
          font-size: 12px;
        }
      }

      .v-btn {
        font-size: 14px;
        width: 80px;
        height: 35px;
      }
    }
  }

  @media (min-width: 1135px) {
    .dashboard-tab-max-width {
      max-width: 1130px;
    }

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

    #appts-created-pipeline-funnel-background {
      border-top-width: 163px;
      width: 440px;
    }

    #appts-created-pipeline-container {
      .appts-created-pipeline-dropdown {
        width: 175px;
      }

      .funnel-container {
        .funnel-table {
          .custom-dates-container {
            max-width: 143px;

            .custom-date-input {
              font-size: 12px;
              max-width: 60px;
              height: 20px;

              ::v-deep .v-input__control {
                max-width: 60px;
                height: 20px;
              }

              ::v-deep .v-input__slot {
                width: 60px;
                height: 20px;
                min-height: 20px;
              }
            }

            .custom-date-span {
              margin: -1px 4px 0 4px;
            }
          }

          .funnel-line-name {
            padding-left: 135px !important;
          }

          .funnel-th {
            .custom-dates-btn {
              font-size: 14px;
              min-width: 100px;
              max-width: 143px;
            }
          }
        }
      }
    }

    #appts-to-fdc-pipeline-funnel-background {
      border-top-width: 899px;
      width: 425px;
    }

    .upper-percentage-line,
    .lower-percentage-line {
      width: 15px;
    }

    .upper-percentage-line {
      height: 370px;
    }

    .lower-percentage-line {
      top: 576px;
    }

    #today-upper-percentage-line,
    #today-lower-percentage-line {
      left: 60.5%;
    }

    #wtd-upper-percentage-line,
    #wtd-lower-percentage-line {
      left: 78.5%;
    }

    #cdr-upper-percentage-line,
    #cdr-lower-percentage-line {
      left: 95.6%;
    }

    .upper-percentage {
      top: 382px;
    }

    .lower-percentage {
      top: 744px;
    }

    #today-upper-percentage,
    #today-lower-percentage {
      left: 62.5%;
    }

    #wtd-upper-percentage,
    #wtd-lower-percentage {
      left: 80.5%;
    }

    #cdr-upper-percentage,
    #cdr-lower-percentage {
      left: 97.2%;
    }

    #appts-to-fdc-pipeline-container {
      .pipeline-header-container {
        #pipeline-header-right-side {
          margin: 5px 5px 0 0;
        }
      }

      .funnel-container {
        .funnel-table {
          .main-row {
            .funnel-line-name {
              padding-left: 142px !important;
            }
          }

          .view-btns-container {
            .funnel-btn {
              font-size: 14px;
              width: 200px;
            }
          }

          .custom-dates-container {
            max-width: 143px;

            .custom-date-input {
              font-size: 12px;
              max-width: 60px;
              height: 20px;

              ::v-deep .v-input__control {
                max-width: 60px;
                height: 20px;
              }

              ::v-deep .v-input__slot {
                width: 60px;
                height: 20px;
                min-height: 20px;
              }
            }

            .custom-date-span {
              margin: -1px 4px 0 4px;
            }
          }

          .funnel-th {
            .custom-dates-btn {
              font-size: 14px;
              min-width: 100px;
              max-width: 143px;
            }
          }

          .funnel-line-name {
            padding-left: 162px !important;
          }

          .checked-in-column-top,
          .checked-in-column-center,
          .checked-in-column-bottom {
            margin-right: 15px;
          }

          .checked-in-column-top {
            padding: 6px 10px;
          }

          .checked-in-column-bottom {
            padding-top: 22px;
          }
        }
      }
    }

    #funnel-drilldown {
      .v-card__title {
        #funnel-drilldown-title {
          font-size: 24px;
          line-height: 32px;
        }
      }

      #funnel-drilldown-search {
        ::v-deep input,
        #funnel-drilldown-row-count {
          font-size: 14px;
        }
      }

      #funnel-drilldown-table {
        ::v-deep th, ::v-deep td {
          font-size: 12px;
        }

        ::v-deep th {
          line-height: 18px;

          .v-data-table-header__icon {
            font-size: 16px !important;
          }
        }
      }
    }
  }

  @media (min-width: 1187px) {
    #appts-to-fdc-pipeline-funnel-background {
      border-top-width: 900px;
    }

    #appts-to-fdc-pipeline-container {
      .funnel-container {
        .funnel-table {
          .checked-in-column-top {
            padding: 17px 3px;
          }
        }
      }
    }
  }

  @media (min-width: 1410px) {
    #appts-created-pipeline-funnel-background {
      width: 445px;
    }

    #appts-created-pipeline-container {
      .appts-created-pipeline-dropdown {
        width: 200px;
      }

      .funnel-container {
        .funnel-table {
          .funnel-line-name {
            padding-left: 135px !important;
          }
        }
      }
    }

    #appts-to-fdc-pipeline-funnel-background {
      border-left-width: 120px;
      border-right-width: 120px;
      width: 520px;
    }

    .upper-percentage-line,
    .lower-percentage-line {
      width: 20px;
    }

    .lower-percentage-line {
      height: 318px;
    }

    #today-upper-percentage-line,
    #today-lower-percentage-line {
      left: 56%;
    }

    #wtd-upper-percentage-line,
    #wtd-lower-percentage-line {
      left: 76%;
    }

    #cdr-upper-percentage-line,
    #cdr-lower-percentage-line {
      left: 96%;
    }

    .upper-percentage {
      top: 383px;
    }

    .lower-percentage {
      top: 745px;
    }

    #today-upper-percentage,
    #today-lower-percentage {
      left: 58%;
    }

    #wtd-upper-percentage,
    #wtd-lower-percentage {
      left: 78%;
    }

    #cdr-upper-percentage,
    #cdr-lower-percentage {
      left: 97.7%;
    }

    #appts-to-fdc-pipeline-container {
      .funnel-container {
        .funnel-table {
          .main-row {
            .funnel-line-name {
              padding-left: 187px !important;
            }
          }

          .view-btns-container {
            .funnel-btn {
              margin: 0 10px;
            }
          }

          .funnel-line-name {
            padding-left: 207px !important;
          }

          .funnel-td {
            width: 200px;
          }

          .funnel-data-container {
            margin-left: 18%;
            width: 200px;
          }
        }
      }
    }
  }
</style>

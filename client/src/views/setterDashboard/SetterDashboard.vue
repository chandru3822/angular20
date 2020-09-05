<template>
  <v-container id="setter-dash-container">
    <v-row v-if="showDashboard" id="setter-dash-toolbar-container">
      <v-col cols="12" id="setter-dash-toolbar">
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

    <v-row id="setter-dash-tabs" class="mb-2" justify="center" no-gutters
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
          <img id="ironman-banner-mobile" src="../../assets/ironman_banner_mobile.png" alt="Mobile version of Ironman competition banner">
          <img id="ironman-banner" src="../../assets/ironman_banner.png"  alt="Desktop version of Ironman competition banner">
          <div id="milestones-container">
            <div id="swim-phase" class="milestone" :class="{'active-milestone': is_q1}"
                 @click="milestoneDrilldown(1)">
              <span class="milestone-top-label">SWIM</span>
              <div class="milestone-content mt-1">
                <div class="milestone-content-labels">
                  <span class="milestone-left-label" :style="{'letter-spacing': q1_upper_label === '——' ? '0.1em' : ''}">{{ q1_upper_label }}</span>
                  <span class="milestone-top-right-label">{{ pitchCounts.q1 }} Pitches</span>
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
                  <span v-if="currentQuarter > 1" class="milestone-top-right-label">{{ pitchCounts.q2 }} Pitches</span>
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
                  <span v-if="currentQuarter > 2" class="milestone-top-right-label">{{ pitchCounts.q3 }} Pitches</span>
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
                  <span v-if="currentQuarter > 3" class="milestone-top-right-label">{{ pitchCounts.q4 }} Pitches</span>
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

    <!-- PERSONAL PERFORMANCE SECTION START -->
    <div v-if="showDashboard" class="ranking-tables-section-header">
      Personal Performance
    </div>
    <div v-if="showDashboard && performanceDataLoaded" id="personal-performance-boxes-container" class="mb-6">
      <div class="personal-performance-box">
        <span class="personal-performance-box-title">Total Appointments</span>
        <span class="personal-performance-box-number">
          {{ rankingData.total_appointments ? rankingData.total_appointments : 0 }}
        </span>
        <span class="personal-performance-box-subtitle">
          {{ timeInterval === 1 ? 'Since yesterday' : 'Last ' + timeInterval + ' days' }} (not cancelled)
        </span>
      </div>
      <div class="personal-performance-box">
        <span class="personal-performance-box-title">Total Pitches</span>
        <span class="personal-performance-box-number">
          {{ rankingData.total_pitches ? rankingData.total_pitches : 0 }}
        </span>
        <span class="personal-performance-box-subtitle">
          {{ timeInterval === 1 ? 'Since yesterday' : 'Last ' + timeInterval + ' days' }}
        </span>
      </div>
      <div class="personal-performance-box">
        <span class="personal-performance-box-title">Pitch %</span>
        <span class="personal-performance-box-number">
          {{ rankingData.pitch_percentage ? rankingData.pitch_percentage : 0 }}%
        </span>
        <span class="personal-performance-box-subtitle">
          {{ timeInterval === 1 ? 'Since yesterday' : 'Last ' + timeInterval + ' days' }}
        </span>
      </div>
      <div id="personal-performance-rank-box">
        <div id="rank-box-left-side">
          <span class="personal-performance-box-title">Company Rank</span>
          <span v-if="isSetterMgr" class="personal-performance-box-number">
            {{ rankBoxData.current_office_rank ? rankBoxData.current_office_rank : 'TBD' }}
          </span>
          <span v-if="!isSetterMgr" class="personal-performance-box-number">
            {{ rankBoxData.current_user_rank ? rankBoxData.current_user_rank : 'TBD' }}
          </span>
          <span class="personal-performance-box-subtitle">
            {{ timeInterval === 1 ? 'Since yesterday' : 'Last ' + timeInterval + ' days' }}
          </span>
        </div>
        <div id="rank-box-separator"></div>
        <div id="rank-box-right-side">
          <span class="personal-performance-box-title">
            {{ isSetterMgr ? 'Office' : 'Rep' }} to Beat
          </span>
          <div id="rank-box-content" :style="{'justify-content': rankBoxData.current_office_rank === '1' || rankBoxData.current_user_rank === '1' ? 'space-around' : 'space-between'}">
            <span v-if="isSetterMgr" id="office-to-beat-name"
                  :style="{'font-size': (rankBoxData.setter_office_to_beat_name && rankBoxData.current_office_rank !== '1') ? '10px' : '14px'}">
              {{ rankBoxData.setter_office_to_beat_name ? rankBoxData.setter_office_to_beat_name : 'TBD' }}
            </span>
            <v-icon v-if="isSetterMgr" class="office-to-beat-icon">mdi-office-building</v-icon>

            <span v-if="!isSetterMgr" id="rep-to-beat-name"
                  :style="{'font-size': (rankBoxData.setter_to_beat_name && rankBoxData.current_user_rank !== '1') ? '10px' : '14px'}">
              {{ rankBoxData.setter_to_beat_name ? rankBoxData.setter_to_beat_name : 'TBD' }}
            </span>
            <img v-if="!isSetterMgr && rankBoxData.imageUrl" class="rep-to-beat-img"
                 :style="{'width': rankBoxData.current_user_rank !== '1' ? '' : '50px', 'height': rankBoxData.current_user_rank !== '1' ? '' : '50px'}"
                 :alt="rankBoxData.imageAltText" :src="rankBoxData.imageUrl">
            <v-icon v-if="!isSetterMgr && !rankBoxData.imageUrl" class="rep-to-beat-icon">mdi-account</v-icon>

            <span v-if="rankBoxData.current_office_rank !== '1' && rankBoxData.current_user_rank !== '1'"
                  id="rank-box-subtitle">
              {{ rankBoxData.pitches_to_go ? rankBoxData.pitches_to_go : 0 }} {{ rankBoxData.pitches_to_go === 1 ? 'Pitch' : 'Pitches' }} to beat {{ isSetterMgr ? 'office' : 'rep' }}
            </span>
          </div>
        </div>
      </div>
    </div>
    <!-- PERSONAL PERFORMANCE SECTION END -->

    <!-- RANKING TABLES HEADER START -->
    <div v-if="showDashboard" class="ranking-tables-section-header">
      Company Performance
    </div>
    <!-- RANKING TABLES HEADER END -->

    <!-- RANKING TABLES SECTION START -->
    <div v-if="showDashboard" id="setter-ranking-tables-section">
      <!-- RANKING TABLES LEFT COLUMN START -->
      <div id="setter-ranking-tables-left-col">
        <!-- TOP OFFICES -->
        <div id="setter-ranking-top-offices-table" class="ranking-table">
          <div class="ranking-table-header">
            <v-icon class="ranking-table-icon mr-2">mdi-flag-variant</v-icon>
            <span>Top Offices</span>
          </div>
          <table v-if="offices.length > 0">
            <tr>
              <th class="center-text">Rank</th>
              <th class="left-text">Office</th>
              <th class="center-text">
                Total Pitched Appointments<br/>
                {{ timeInterval === 1 ? 'Since yesterday' : 'Last ' + timeInterval + ' days' }}
              </th>
            </tr>
            <tr v-for="office in offices"
                :key="office.org_id"
                :class="{'highlight-user-row': office.org_id === userOfficeId}">
              <td class="center-text">{{ office.rank }}</td>
              <td class="left-text">{{ office.name }}</td>
              <td class="center-text">{{ office.pitches }}</td>
            </tr>
          </table>
          <div v-if="offices.length === 0" class="ranking-tables-no-data">
            Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
          </div>
        </div>

        <!-- TOP REPS -->
        <div class="ranking-table">
          <div class="ranking-table-header">
            <v-icon class="mr-2 ranking-table-icon">mdi-account-multiple</v-icon>
            <span>Top Reps</span>
          </div>
          <table v-if="reps.length > 0">
            <tr>
              <th class="center-text">Rank</th>
              <th></th>
              <th class="left-text">Rep</th>
              <th class="center-text">
                Total Pitched Appointments<br/>
                {{ timeInterval === 1 ? 'Since yesterday' : 'Last ' + timeInterval + ' days' }}
              </th>
            </tr>
            <tr v-for="rep in reps" :key="rep.user_id"
                :class="{'highlight-user-row': rep.user_id === currentUserId}">
              <td class="center-text">{{ rep.rank }}</td>
              <td>
                <img class="ranking-table-img"
                     :class="{'round-img': rep.userImageUrl, 'default-img': !rep.userImageUrl}"
                     :src="rep.userImageUrl ? rep.userImageUrl : '../../assets/user_img_placeholder.png'"
                     :alt="rep.userImageAltText ? rep.userImageAltText : 'User photo placeholder'">
              </td>
              <td class="left-text">{{ rep.name }}</td>
              <td class="center-text">{{ rep.pitches }}</td>
            </tr>
          </table>
          <div v-if="reps.length === 0" class="ranking-tables-no-data">
            Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
          </div>
        </div>
      </div>
      <!-- RANKING TABLES LEFT COLUMN END -->

      <!-- RANKING TABLES RIGHT COLUMN START -->
      <div id="setter-ranking-tables-right-col">
        <!-- OFFICE RANKING -->
        <div class="ranking-table">
          <div class="ranking-table-header">
            <v-icon class="mr-2 ranking-table-icon">mdi-office-building</v-icon>
            <span>Office Ranking</span>
          </div>
          <table v-if="officeRankingData.length > 0">
            <tr>
              <th class="center-text">Rank</th>
              <th class="left-text">Office</th>
              <th class="center-text">
                Total Appointments<br/>
                {{ timeInterval === 1 ? 'Since yesterday' : 'Last ' + timeInterval + ' days' }}
              </th>
              <th class="center-text">Pitches</th>
              <th class="center-text">Pitch %</th>
            </tr>
            <tr v-for="office in officeRankingData" :key="office.org_id"
                :class="{'highlight-user-row': office.org_id === userOfficeId}">
              <td class="center-text">{{ office.rank }}</td>
              <td class="left-text">{{ office.org }}</td>
              <td class="center-text">{{ office.total_appointments }}</td>
              <td class="center-text">{{ office.pitches }}</td>
              <td class="center-text">{{ office.pitch_percentage }}%</td>
            </tr>
          </table>
          <div v-if="officeRankingData.length === 0"
               class="ranking-tables-no-data">
            Data is not yet available for the selected time period. Try selecting another time period, or check back again at a later date.
          </div>
        </div>
      </div>
      <!-- RANKING TABLES RIGHT COLUMN END -->
    </div>
    <!-- RANKING TABLES SECTION END -->
    <!---------------------------------- DASHBOARD TAB END ---------------------------------->

    <!---------------------------------- FUNNEL TAB START ---------------------------------->
    <!-- FUNNEL -->
    <div v-show="showFunnel" id="pipeline-container"
         :class="{'mb-8': funnelStats.length > 0}">
      <div class="pipeline-header-container">
        <div id="pipeline-header-top">
          <v-icon class="pipeline-icon">mdi-poll</v-icon>
          <div class="pipeline-title">Pipeline</div>
        </div>

        <!-- PIPELINE CONTROLS -->
        <div id="pipeline-header-controls">
          <!-- VIEW BUTTONS -->
          <div id="pipeline-header-left-side">
            <v-radio-group v-model="viewSelect">
              <v-radio label="Standard View" value="standard" class="funnel-radio-btn"
                       @click="viewSelected('standard')"
                       :class="{'white--text': viewSelect === 'standard'}"
                       :color="viewSelect === 'standard' ? 'primaryCustom' : 'secondaryCustom'">
              </v-radio>
              <v-radio label="Cohort View" value="cohort" class="funnel-radio-btn"
                       @click="viewSelected('cohort')"
                       :class="{'white--text': viewSelect === 'cohort'}"
                       :color="viewSelect === 'cohort' ? 'primaryCustom' : 'secondaryCustom'">
              </v-radio>
            </v-radio-group>
          </div>

          <!-- DROPDOWNS -->
          <div id="pipeline-header-right-side">
            <v-select class="pipeline-dropdown"
                      v-model="districtModel"
                      :items="districtData"
                      label="District"
                      solo
                      multiple
                      dense>
              <template v-slot:prepend-item>
                <v-list-item ripple @click="toggle">
                  <v-list-item-action>
                    <v-icon :color="districtModel.length > 0 ? 'indigo darken-4' : ''">{{ icon }}</v-icon>
                  </v-list-item-action>
                  <v-list-item-content>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-divider class="mt-2"></v-divider>
              </template>
              <template v-slot:append-item>
                <v-divider class="mb-2"></v-divider>
                <v-list-item disabled>
                  <v-list-item-content>
                    <v-list-item-title>{{ districtModel.length }} districts selected</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </template>
            </v-select>

            <v-select class="pipeline-dropdown"
                      v-model="regionModel"
                      :items="regionData"
                      label="Region"
                      solo
                      multiple
                      dense>
              <template v-slot:prepend-item>
                <v-list-item ripple @click="toggle">
                  <v-list-item-action>
                    <v-icon :color="regionModel.length > 0 ? 'indigo darken-4' : ''">{{ icon }}</v-icon>
                  </v-list-item-action>
                  <v-list-item-content>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-divider class="mt-2"></v-divider>
              </template>
              <template v-slot:append-item>
                <v-divider class="mb-2"></v-divider>
                <v-list-item disabled>
                  <v-list-item-content>
                    <v-list-item-title>{{ regionModel.length }} regions selected</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </template>
            </v-select>

            <v-select class="pipeline-dropdown"
                      v-model="officeModel"
                      :items="officeData"
                      label="Office"
                      solo
                      multiple
                      dense>
              <template v-slot:prepend-item>
                <v-list-item ripple @click="toggle">
                  <v-list-item-action>
                    <v-icon :color="officeModel.length > 0 ? 'indigo darken-4' : ''">{{ icon }}</v-icon>
                  </v-list-item-action>
                  <v-list-item-content>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-divider class="mt-2"></v-divider>
              </template>
              <template v-slot:append-item>
                <v-divider class="mb-2"></v-divider>
                <v-list-item disabled>
                  <v-list-item-content>
                    <v-list-item-title>{{ officeModel.length }} offices selected</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </template>
            </v-select>

            <v-select class="pipeline-dropdown"
                      v-model="repModel"
                      :items="repData"
                      label="Rep"
                      solo
                      multiple
                      dense>
              <template v-slot:prepend-item>
                <v-list-item ripple @click="toggle">
                  <v-list-item-action>
                    <v-icon :color="repModel.length > 0 ? 'indigo darken-4' : ''">{{ icon }}</v-icon>
                  </v-list-item-action>
                  <v-list-item-content>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-divider class="mt-2"></v-divider>
              </template>
              <template v-slot:append-item>
                <v-divider class="mb-2"></v-divider>
                <v-list-item disabled>
                  <v-list-item-content>
                    <v-list-item-title>{{ repModel.length }} reps selected</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </template>
            </v-select>

            <v-btn id="all-reps-btn" @click="funnelAllReps">All Reps</v-btn>
          </div>
        </div>
      </div>

      <!-- FUNNEL -->
      <div class="funnel-container">
        <div v-show="funnelStats.length > 0" id="funnel-background"></div>
        <table class="funnel-table">
          <!-- FUNNEL COLUMN HEADERS -->
          <tr class="funnel-tr">
            <th class="funnel-th">EXPECTATION</th>
            <th class="funnel-th"></th>
            <th class="funnel-th">TODAY</th>
            <th class="funnel-th">LAST 7 DAYS</th>
            <th class="funnel-th">LAST 30 DAYS</th>
            <th class="funnel-th">
              <div v-show="showPipelineCustomDates" class="custom-dates-container">
                <v-menu v-model="pipeline_menu1" transition="scale-transition" offset-y
                        min-width="290px" :close-on-content-click="false">
                  <template v-slot:activator="{ on }">
                    <v-text-field class="custom-date-input" v-model="pipeline_dt1_formatted" readonly
                                  outlined dense v-on="on"></v-text-field>
                  </template>
                  <v-date-picker v-model="pipeline_dt1"
                                 @input="updatePipelineCalendar()"></v-date-picker>
                </v-menu>
                <span class="custom-date-span">-</span>
                <v-menu v-model="pipeline_menu2" transition="scale-transition" offset-y
                        min-width="290px" :close-on-content-click="false">
                  <template v-slot:activator="{ on }">
                    <v-text-field class="custom-date-input" v-model="pipeline_dt2_formatted" readonly
                                  outlined dense v-on="on"></v-text-field>
                  </template>
                  <v-date-picker v-model="pipeline_dt2"
                                 @input="updatePipelineCalendar()"></v-date-picker>
                </v-menu>
              </div>

              <v-menu v-model="customDateSelectorIsOpen"
                      :close-on-content-click="true"
                      transition="scale-transition"
                      offset-y>
                <template v-slot:activator="{ on }">
                  <v-btn v-on="on" class="custom-dates-btn">
                    {{ pipelineDateRange.label }}<v-icon>mdi-menu-down</v-icon>
                  </v-btn>
                </template>
                <v-list>
                  <v-list-item v-for="(dateRange, index) in pipelineDateRanges"
                               :key="index"
                               @click="choosePipelineDateRange(dateRange)">
                    <v-list-item-title>{{ dateRange.label }}</v-list-item-title>
                  </v-list-item>
                </v-list>
              </v-menu>
            </th>
          </tr>
          <!-- FUNNEL ROWS -->
          <tr class="funnel-tr" :class="{'blue-sub-row': [3,2].indexOf(line.id) !== -1}"
              v-for="(line, index) in funnelStats" :key="line.id">
            <td v-if="showExpectationInput(index)" id="expectation-input"
                class="funnel-td funnel-expectation">
              <v-text-field @change="expectationChanged(this)"
                            v-model="expectedInstalls"
                            solo
                            dense>
              </v-text-field>
            </td>

            <!-- FUNNEL EXPECTATION -->
            <td v-if="!showExpectationInput(index)" class="funnel-td funnel-expectation">
              {{line.expectation}}
            </td>

            <!-- FUNNEL NAME -->
            <td class="funnel-td funnel-line-name">{{line.name}}</td>

            <!-- TODAY COUNT -->
            <td class="funnel-td" style="cursor: pointer"
                @click="drillDown(line.id, 'yesterday', line.name)">
              <div class="dash_cell_contents funnel_data">
                <div class="funnel_count" :style="{color: line.countTodayState}"
                     :title="line.todayHover">
                  {{line.today_day_count}}{{line.id === 4 ? '%' : ''}}
                </div>

                <div class="desktop funnel_percent">
                  <span style="font-size:12px;font-weight:normal;"
                        :style="{color: line.percentTodayState}"
                        :title="line.percentTodayHover">
                    {{line.percentToday}}
                  </span>
                </div>

                <div :class="line.percentTodayState + '_arrow'" class="desktop funnel_arrow"></div>
              </div>
            </td>

            <!-- LAST 7 DAYS COUNT -->
            <td class="funnel-td" style="cursor: pointer"
                @click="drillDown(line.id, '7days', line.name)">
              <div class="dash_cell_contents funnel_data">
                <div class="funnel_count" :style="{color: line.count7state}"
                     :title="line.sevenDayHover">
                  {{line.seven_day_count}}{{line.id === 4 ? '%' : ''}}
                </div>

                <div class="desktop funnel_percent">
                  <span style="font-size:12px;font-weight:normal;"
                        :style="{color: line.percent7state}"
                        :title="line.percent7hover">
                    {{line.percent7}}
                  </span>
                </div>

                <div :class="line.percent7state + '_arrow'" class="desktop funnel_arrow"></div>
              </div>
            </td>

            <!-- LAST 30 DAYS COUNT -->
            <td class="funnel-td" style="cursor: pointer"
                @click="drillDown(line.id, '30days', line.name)">
              <div class="dash_cell_contents funnel_data">
                <div class="funnel_count" :style="{color: line.count30state}"
                     :title="line.thirtyDayHover">
                  {{line.thirty_day_count}}{{line.id === 4 ? '%' : ''}}
                </div>

                <div class="desktop funnel_percent">
                  <span style="font-size:12px;font-weight:normal;"
                        :style="{color: line.percent30state}"
                        :title="line.percent30hover">
                    {{line.percent30}}
                  </span>
                </div>

                <div :class="line.percent30state + '_arrow'" class="desktop funnel_arrow"></div>
              </div>
            </td>

            <!-- CUSTOM DATE RANGE COUNT -->
            <td v-show="!showCustomPercentage"
                class="funnel-td"
                :style="{color: line.customCountState}"
                style="width:15%; cursor: pointer"
                :title="line.customDayHover"
                @click="drillDown(line.id, 'custom', line.name)">
              {{line.custom_date_range_count}}{{line.id === 4 ? '%' : ''}}
            </td>

            <td v-show="showCustomPercentage"
                class="funnel-td"
                :style="{color: line.customCountState}"
                style="width: 15%; cursor: pointer"
                @click="drillDown(line.id, 'custom', line.name)">
              <div class="dash_cell_contents funnel_data">
                <div class="funnel_count" :style="{color: line.count30state}"
                     :title="line.customDayHover">
                  {{line.custom_date_range_count}}{{line.id === 4 ? '%' : ''}}
                </div>

                <div class="desktop funnel_percent">
                  <span style="font-size:12px;font-weight:normal"
                        :style="{color: line.percentCustomState}"
                        :title="line.percentCustomHover">
                    {{line.percentCustom}}
                  </span>
                </div>

                <div :class="line.percentCustomState + '_arrow'" class="desktop funnel_arrow"
                     :title="line.percentCustomHover"></div>
              </div>
            </td>
          </tr>
        </table>
      </div>
    </div>
    <!----------------------------------- PIPELINE TAB END ----------------------------------->

    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import orderBy from 'lodash.orderby'
  import $ from 'jquery'
  import moment from 'moment'
  import Snackbar from '@/components/Snackbar.vue'
  import { getRequestWithParams, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import { getDistricts, getRegions, getOffices, getReps } from '@/services/dashboardService'

  export default {
    name: 'setterDashboard',
    components: {
      Snackbar
    },
    data: () => ({
      snackbar: {},
      milestoneDialog: false,
      currentUserId: null,
      isSetterMgr: false,
      selectedQuarter: 1,
      headers: [
        { text: '', value: '', show: true, sortable: false },
        { text: 'Name', value: 'customer_name', show: true },
        { text: 'Deal ID', value: 'id', show: true },
        { text: 'Source', value: 'source_name', show: true },
        { text: 'Appointment Date', value: 'appointment_date', show: true },
        { text: 'Appointment Outcome', value: 'appointment_outcome', show: true }
      ],
      drilldownData: [],
      timeIntervalBtnGroup: 0,
      timeIntervalString: 'MTD', // MTD is selected by default
      timeInterval: +moment().format('DD') - 1,
      tabNum: 1, // Dashboard tab is selected by default
      showDashboard: true,
      showFunnel: false,
      ironmanLoaded: false,
      performanceDataLoaded: false,
      rankingTablesLoaded: false,
      dashboardWasLoaded: false,
      funnelWasLoaded: false,
      currentQuarter: moment().quarter(),
      pitchCounts: {q1: 0, q2: 0, q3: 0, q4: 0},
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
      rankingData: {},
      rankBoxData: {},
      offices: [],
      reps: [],
      officeRankingData: [],
      userOffice: '',
      userOfficeId: null,
      userRow: [],
      userRowIndex: -1,
      numOffices: 0,
      districtModel: [],
      districtData: [],
      checkAllDistricts: false,
      regionModel: [],
      regionData: [],
      checkAllRegions: false,
      officeModel: [],
      officeData: [],
      checkAllOffices: false,
      repModel: [],
      repData: [],
      checkAllReps: false,
      pipelineDateRanges: [
        {
          label: 'Yesterday',
          value: 'yesterday'
        },
        {
          label: 'Last Week',
          value: 'previousWeek'
        },
        {
          label: 'Last Month',
          value: 'previousMonth'
        },
        {
          label: 'Last 90 days',
          value: 90
        },
        {
          label: 'Week to Date',
          value: 'WTD'
        },
        {
          label: 'Month to Date',
          value: 'MTD'
        },
        {
          label: 'Quarter to Date',
          value: 'QTD'
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
      pipelineDateRange: {
        label: 'Week to Date',
        value: 'WTD'
      },
      showPipelineCustomDates: false,
      customDateSelectorIsOpen: false,
      viewSelect: 'standard',
      pipeline_dt1: moment().startOf('month').format('YYYY-MM-DD'),
      pipeline_dt1_formatted: moment().startOf('month').format('M/D/YY'),
      pipeline_menu1: false,
      pipeline_dt2: moment().format('YYYY-MM-DD'),
      pipeline_dt2_formatted: moment().format('M/D/YY'),
      pipeline_menu2: false,
      showCustomPercentage: false,
      expectedInstalls: 1,
      expectationTimeout: 0,
      funnelStats: [
        {id: 3, name: 'Appointments Created', ratio: 4.17, expectation: 4.17, display_order: 1, today_day_count: 0, yesterday_day_count: 0, today_percent: 0, seven_day_count: 992, prev_seven_day_count: 1526, seven_percent: -35.00, thirty_day_count: 4644, prev_thirty_day_count: 4639, thirty_day_percent: 0.00, custom_date_range_count: 0},
        {id: 1, name: 'Appointments Occurred', ratio: 1.67,expectation: 1.67,display_order: 2,today_day_count: 127,yesterday_day_count: 8,today_percent: 1488.00,seven_day_count: 1310,prev_seven_day_count: 1493,seven_percent: -12.00,thirty_day_count: 4836,prev_thirty_day_count: 4638,thirty_day_percent: 4.00,custom_date_range_count: 127},
        {id: 2,name:  'Appointments Pitched',ratio: 1.00,expectation: 1.00,display_order: 3,today_day_count: 1,yesterday_day_count: 0,today_percent: 0,seven_day_count: 507,prev_seven_day_count: 866,seven_percent: -41.00,thirty_day_count: 2546,prev_thirty_day_count: 2463,thirty_day_percent: 3.00,custom_date_range_count: 1}
      ],
      funnelDrilldownTitle: '',
      funnelDrilldownHeaders: [],
      funnelDrilldownData: [],
      funnelDrilldownSearch: '',
      filteredFunnelDrilldownData: [],
      funnelDrilldownRowCount: 0
    }),
    computed: {
      is_q1 () { return this.currentQuarter === 1 },
      is_q2 () { return this.currentQuarter === 2 },
      is_q3 () { return this.currentQuarter === 3 },
      is_q4 () { return this.currentQuarter === 4 },
      milestoneDrilldownTitle () {
        return this.$store.state.user.details.firstName + ' ' + this.$store.state.user.details.lastName + ' | Pitches - Q' + this.selectedQuarter
      },
      allDistrictsSelected () {
        return this.districtModel.length === this.districtData.length
      },
      someDistrictsSelected () {
        return this.districtModel.length > 0 && !this.allDistrictsSelected
      },
      icon () {
        if (this.allDistrictsSelected) return 'mdi-close-box'
        if (this.someDistrictsSelected) return 'mdi-minus-box'
        return 'mdi-checkbox-blank-outline'
      },
      visibleFunnelDrilldownHeaders () {
        return this.funnelDrilldownHeaders.filter(header => header.show === true)
      }
    },
    watch: {
      // the loading animation kept going away before it was supposed to, so this makes sure that it doesn't do that anymore
      '$store.state.app.loading': function () {
        if (!this.ironmanLoaded || !this.performanceDataLoaded || !this.rankingTablesLoaded) {
          this.$store.commit(AppMutations.SET_LOADING, true)
        }
      },
      pipeline_dt1 () {
        this.pipeline_dt1_formatted = this.formatFunnelDate(this.pipeline_dt1)
      },
      pipeline_dt2 () {
        this.pipeline_dt2_formatted = this.formatFunnelDate(this.pipeline_dt2)
      },
      funnelDrilldownDialog () {
        this.funnelDrilldownSearch = ''
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

      /* IRONMAN-RELATED CODE START */
      async loadIronman () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.ironmanLoaded = false

        try {
          const params = {
            isSetterMgr: this.isSetterMgr,
            setterMgrOfficeId: this.isSetterMgr && this.userOfficeId ? this.userOfficeId : null
          }

          const {data} = await getRequestWithParams('/setterDashboard/getIronmanPitchCounts', {params}, 'blueraven')
            this.pitchCounts = data

            // Calculate points for each quarter
            this.q1_points = this.calcPointsForQuarter(this.pitchCounts.q1)
            this.q2_points = this.calcPointsForQuarter(this.pitchCounts.q2)
            this.q3_points = this.calcPointsForQuarter(this.pitchCounts.q3)
            this.q4_points = this.calcPointsForQuarter(this.pitchCounts.q4)

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

            // Remove black background for previous quarters where setter has < 48 (or setter mgr has < 225) pitches
            if (this.is_q2) {
              $('#swim-phase .milestone-content').addClass('unranked')
            } else if (this.is_q3) {
              $('#swim-phase .milestone-content, #bike-phase .milestone-content').addClass('unranked')
            } else if (this.is_q4) {
              $('#swim-phase .milestone-content, #bike-phase .milestone-content, #run-phase .milestone-content').addClass('unranked')
            }

            // Get upper milestone labels
            this.q1_upper_label = this.getUpperMilestoneLabel(this.pitchCounts.q1)
            this.q2_upper_label = this.currentQuarter < 2 ? 'April 1' : this.getUpperMilestoneLabel(this.pitchCounts.q2)
            this.q3_upper_label = this.currentQuarter < 3 ? 'July 1' : this.getUpperMilestoneLabel(this.pitchCounts.q3)
            this.q4_upper_label = this.currentQuarter < 4 ? 'October 1' : this.getUpperMilestoneLabel(this.pitchCounts.q4)

            // Get lower milestone labels
            this.q1_lower_label = this.getLowerMilestoneLabel(this.pitchCounts.q1)
            this.q2_lower_label = this.getLowerMilestoneLabel(this.pitchCounts.q2)
            this.q3_lower_label = this.getLowerMilestoneLabel(this.pitchCounts.q3)
            this.q4_lower_label = this.getLowerMilestoneLabel(this.pitchCounts.q4)

            // Fill progress bar based on setter's points for the year
            this.percentAchieved = ((this.q1_points + this.q2_points + this.q3_points + this.q4_points) / 8) * 100
            this.percentAchieved = this.percentAchieved > 100 ? 100 : this.percentAchieved
            this.progressBarIsFull = this.percentAchieved === 100
            $('#progress-bar-fill').css('width', this.percentAchieved + '%')

            this.ironmanLoaded = true
            this.$store.commit(AppMutations.SET_LOADING, false)
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

      calcPointsForQuarter (pitchCount) {
        if (!this.isSetterMgr) {
          switch (true) {
            case pitchCount >= 10 && pitchCount < 12:
              return 1 // Bronze
            case pitchCount >= 12 && pitchCount < 15:
              return 2 // Silver
            case pitchCount >= 15 && pitchCount < 18:
              return 3 // Gold
            case pitchCount >= 18:
              return 4 // Platinum
            default:
              return 0 // Unranked
          }
        } else {
          switch (true) {
            case pitchCount >= 225 && pitchCount < 275:
              return 1 // Bronze
            case pitchCount >= 275 && pitchCount < 350:
              return 2 // Silver
            case pitchCount >= 350 && pitchCount < 425:
              return 3 // Gold
            case pitchCount >= 425:
              return 4 // Platinum
            default:
              return 0 // Unranked
          }
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
            return 'default'
        }
      },

      getUpperMilestoneLabel (pitchCount) {
        if (!this.isSetterMgr) {
          switch (true) {
            case pitchCount >= 48 && pitchCount < 60:
              return 'BRONZE'
            case pitchCount >= 60 && pitchCount < 72:
              return 'SILVER'
            case pitchCount >= 72 && pitchCount < 84:
              return 'GOLD'
            case pitchCount >= 84:
              return 'PLATINUM'
            default:
              return '——'
          }
        } else {
          switch (true) {
            case pitchCount >= 225 && pitchCount < 275:
              return 'BRONZE'
            case pitchCount >= 275 && pitchCount < 350:
              return 'SILVER'
            case pitchCount >= 350 && pitchCount < 425:
              return 'GOLD'
            case pitchCount >= 425:
              return 'PLATINUM'
            default:
              return '——'
          }
        }
      },

      getLowerMilestoneLabel (pitchCount) {
        if (!this.isSetterMgr) {
          switch (true) {
            case pitchCount >= 48 && pitchCount < 60:
              return (60 - pitchCount) + ' Pitches to get to Silver'
            case pitchCount >= 60 && pitchCount < 72:
              return (72 - pitchCount) + ' Pitches to get to Gold'
            case pitchCount >= 72 && pitchCount < 84:
              return (84 - pitchCount) + ' Pitches to get to Platinum'
            case pitchCount >= 84:
              return 'Platinum'
            default:
              return (48 - pitchCount) + ' Pitches to get to Bronze'
          }
        } else {
          switch (true) {
            case pitchCount >= 225 && pitchCount < 275:
              return (275 - pitchCount) + ' Pitches to get to Silver'
            case pitchCount >= 275 && pitchCount < 350:
              return (350 - pitchCount) + ' Pitches to get to Gold'
            case pitchCount >= 350 && pitchCount < 425:
              return (425 - pitchCount) + ' Pitches to get to Platinum'
            case pitchCount >= 425:
              return 'Platinum'
            default:
              return (225 - pitchCount) + ' Pitches to get to Bronze'
          }
        }
      },

      async milestoneDrilldown (quarter) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          const params = {
            quarter,
            isSetterMgr: this.isSetterMgr,
            setterMgrOfficeId: this.setterMgrOfficeId
          }
          const {data} = await getRequestWithParams('/setterDashboard/pitchesDrilldown', {params}, 'blueraven')
          this.drilldownData = cloneDeep(data)

          if (this.drilldownData.length > 0) {
            this.reformatDates()
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

      reformatDates () {
        this.drilldownData.forEach(row => {
          if (row.appointment_date) {
            row.appointment_date_formatted = moment(row.appointment_date).format('MMM D, YYYY')
          }
        })
      },
      /* IRONMAN-RELATED CODE END */

      /* PERSONAL PERFORMANCE-RELATED CODE START */
      async loadPersonalPerformance () {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          this.performanceDataLoaded = false
          let startDate = moment().subtract(this.timeInterval, 'd').format('YYYY-MM-DD')
          let endDate = moment().format('YYYY-MM-DD')

          if (this.isSetterMgr) {
            let performanceData = await getRequestWithParams('/setterDashboard/getMgrPerformanceReport',
              {
                params: {
                  officeId: this.userOfficeId,
                  startDate,
                  endDate
                }
              }, 'blueraven')
            this.rankingData = performanceData.data

            let officeToBeatData = await getRequestWithParams('/setterDashboard/officeToBeat',
            {
              params: {
                officeId: this.userOfficeId,
                startDate,
                endDate
              }
            }, 'blueraven')
            this.rankBoxData = officeToBeatData.data

            if (this.rankBoxData.setter_office_to_beat_name && this.rankBoxData.current_office_rank) {
              if (this.rankBoxData.current_office_rank === "1") {
                this.rankBoxData.setter_office_to_beat_name = 'Your office is #1!'
              } else if (this.rankBoxData.current_office_rank === 'T1') {
                let tiedOffices = this.offices.filter(office => office.rank === 'T1' && office.org_id !== this.userOfficeId)

                if (tiedOffices.length > 0) {
                  let officeToBeat

                  if (tiedOffices.length === 1) {
                    officeToBeat = tiedOffices[0]
                  } else {
                    // randomly selects an office that's tied for 1st with current manager's office
                    officeToBeat = tiedOffices[Math.floor(Math.random() * tiedOffices.length)]
                  }

                  this.rankBoxData.setter_office_to_beat_name = officeToBeat.name
                  this.rankBoxData.pitches_to_go = 1
                }
              }
            }

            this.performanceDataLoaded = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          } else {
            let performanceData = await getRequestWithParams('/setterDashboard/getPerformanceReport', {params: {startDate, endDate}}, 'blueraven')
            this.rankingData = performanceData.data

            let repToBeatData = await getRequestWithParams('/setterDashboard/repToBeat',
              {
                params: {
                  userId: this.currentUserId,
                  startDate,
                  endDate
                }
              }, 'blueraven')
            this.rankBoxData = repToBeatData.data

            if (this.rankBoxData) {
              if (this.rankBoxData.setter_to_beat_id) {
                await this.getRepToBeatImage(this.rankBoxData.setter_to_beat_id)
              } else if (!this.rankBoxData.setter_to_beat_name && this.rankBoxData.current_user_rank) {
                if (this.rankBoxData.current_user_rank === "1") {
                  this.rankBoxData.setter_to_beat_name = 'You’re #1!'
                  await this.getRepToBeatImage(this.currentUserId) // gets current user's picture
                } else if (this.rankBoxData.current_user_rank === 'T1' && this.reps.length > 0) {
                  let tiedReps = this.reps.filter(rep => rep.rank === 'T1' && rep.user_id !== this.currentUserId)

                  if (tiedReps.length > 0) {
                    let repToBeat

                    if (tiedReps.length === 1) {
                      repToBeat = tiedReps[0]
                    } else {
                      // randomly selects one of the reps who is tied for 1st with the current rep
                      repToBeat = tiedReps[Math.floor(Math.random() * tiedReps.length)]
                    }

                    await this.getRepToBeatImage(repToBeat.user_id)
                    this.rankBoxData.setter_to_beat_name = repToBeat.name
                    this.rankBoxData.pitches_to_go = 1
                  } else {
                    this.rankBoxData.imageUrl = null
                    this.rankBoxData.imageAltText = 'User photo placeholder'
                  }
                }
              }
            }

            this.performanceDataLoaded = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving personal performance data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async getRepToBeatImage (repToBeatId) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          const params = {sourceId: repToBeatId, attachmentSourceTypeId: 9}
          const {data} = await getRequestWithParams('/attachment/', {params}, 'blueraven')

          if (data && data[0] && data[0].presignedUrl) {
            this.rankBoxData.imageUrl = data[0].presignedUrl

            if (this.rankBoxData.setter_to_beat_name) {
              this.rankBoxData.imageAltText = 'Photo of ' + this.rankBoxData.setter_to_beat_name + ', a Blue Raven Solar employee'
            } else {
              this.rankBoxData.imageAltText = 'User photo placeholder'
            }

            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving rep to beat image')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      /* PERSONAL PERFORMANCE-RELATED CODE END */

      /* RANKING TABLES-RELATED CODE START */
      async getTopReps () {
        try {
          const params = {limit: 5, days: this.timeInterval}
          const {data} = await getRequestWithParams('/setterDashboard/topReps', {params}, 'blueraven')
          this.reps = data

          if (this.reps.length > 0 && data.companyRankingValues.filter(row => row.userId === this.currentUserId)[0] !== undefined) {
            this.userOffice = data.companyRankingValues.filter(row => row.userId === this.currentUserId)[0].officeName
            let userIds = []

            this.reps.forEach(rep => {
              if (rep.user_id) {
                userIds.push(rep.user_id)
              }
            })

            if (userIds.length > 0) {
              const {attachmentUrlData} = await getRequestWithParams('/attachment/getAttachmentPresignedUrlForUserList',
                {
                  params: {
                    sourceIds: userIds,
                    attachmentSourceTypeId: 9
                  }
                }, 'blueraven')

              if (attachmentUrlData) {
                this.reps.forEach(rep => {
                  if (rep.user_id && attachmentUrlData[rep.user_id]) {
                    rep.userImageUrl = attachmentUrlData[rep.user_id]
                  }

                  if (rep.userImageUrl && rep.name) {
                    rep.userImageAltText = 'Photo of ' + rep.name + ', a Blue Raven Solar employee'
                  } else {
                    rep.userImageAltText = 'User photo placeholder'
                  }
                })
              }
            }
          }

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving top reps data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async getTopOffices () {
        try {
          const {data} = await getRequestWithParams('/setterDashboard/topOffices',
            {
              params: {
                limit: 5,
                days: this.timeInterval
              }
            }, 'blueraven')
          this.offices = data

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving top offices data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async getOfficeRanking () {
        try {
          const {data} = await getRequestWithParams('/setterDashboard/officeRanking',
            {
              params: {
                limit: 13,
                days: this.timeInterval
              }
            }, 'blueraven')
          this.officeRankingData = data

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving office ranking data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async loadRankingTables (timeIntervalString) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          this.rankingTablesLoaded = false
          this.timeIntervalString = timeIntervalString
          this.rankingData = {}

          switch (timeIntervalString) {
            case 'MTD':
              this.timeInterval = +moment().format('DD') - 1 // MTD
              break
            case '60 days':
              this.timeInterval = 60
              break
            case '90 days':
              this.timeInterval = 90
              break
            case 'YTD':
              this.timeInterval = moment().dayOfYear() - 1 // YTD
              break
          }

          await this.loadPersonalPerformance()
          await this.getTopReps()
          await this.getTopOffices()
          await this.getOfficeRanking()
          this.rankingTablesLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving ranking table data')
          this.rankingTablesLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      /* RANKING TABLES-RELATED CODE END */

      /* FUNNEL-RELATED CODE START */
      getPercentColor (percent) {
        if (percent < 0) return 'red'
        return 'green'
      },

      getPercentHover (percent, dayNum) {
        let state = ''
        if (percent < 0) state = 'worse'
        else if (percent > 0) state = 'better'
        else return ''
        let previousTime = 'last ' + dayNum + ' days'
        if (dayNum === 1) {
          previousTime = 'yesterday'
        }
        return '% ' + state + ' than ' + previousTime
      },

      getCountHover (count, expectation) {
        return count < expectation
          ? 'Worse than Expectation'
          : 'Better than Expectation'
      },

      funnelAllReps () {
        this.repModel = [
          {id: -1, label: 'All Reps'}
        ]

        this.repData = [
          {id: -1, label: 'All Reps'}
        ]

        this.pipelineLoad(this.pipeline_dt1, this.pipeline_dt2)
      },

      pipelineLoad (start, end) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        let reps = this.repModel.map(rep => rep.id)
        let orgs = this.officeModel.map(org => org.id)

        if (!reps || reps.length === 0) {
          this.funnelStats = []
          this.$store.commit(AppMutations.SET_LOADING, false)
          return
        }

        const params = {
          users: reps,
          orgs: orgs,
          start: moment(start).format('YYYY-MM-DD'),
          end: moment(end).format('YYYY-MM-DD')
        }

        getRequestWithParams('/setterDashboard/funnel/' + this.viewSelect, {params}, 'blueraven').then(res => {
          this.funnelStats = orderBy(res.data, row => row.display_order)
        })
      },

      toggle () {
        this.$nextTick(() => {
          if (this.allDistrictsSelected) {
            this.districtModel = []
          } else {
            this.districtModel = this.districtData.slice()
          }
        })
      },

      showExpectationInput (index) {
        if (this.viewSelect === 'standard' && this.funnelStats.length - 1 === index) {
          return true
        }
        if (this.viewSelect === 'cohort' && this.funnelStats.length - 2 === index) {
          return true
        }
        return false
      },

      choosePipelineDateRange (dateRange) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        if (this.showPipelineCustomDates) {
          this.showPipelineCustomDates = false
          this.fixFunnelTopMargin()
        }

        this.pipelineDateRange = dateRange

        switch (dateRange.value) {
          case 'yesterday':
            this.yesterday()
            break
          case 'WTD':
            this.weekToDate()
            break
          case 'MTD':
            this.monthToDate()
            break
          case 'QTD':
            this.quarterToDate()
            break
          case 'YTD':
            this.yearToDate()
            break
          case 'lastMonth':
            this.lastMonth()
            break
          case 'lastWeek':
            this.lastWeek()
            break
          case 'Custom':
            this.showPipelineCustomDates = true
            this.fixFunnelTopMargin()
            this.$store.commit(AppMutations.SET_LOADING, false)
            break
          default:
            this.previousNumberOfDays(dateRange.value)
            break
        }
      },

      updateInstalls (installs) {
        this.expectedInstalls = installs
        this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2)
      },

      updatePipelineCalendar (showCustom) {
        this.showCustomPercentage = showCustom
        this.pipeline_menu1 = false
        this.pipeline_menu2 = false
        this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2)
      },

      yesterday () {
        this.pipeline_dt1 = moment().subtract(1, 'd').toDate()
        this.pipeline_dt2 = moment().subtract(1, 'd').toDate()
        this.updatePipelineCalendar(true)
      },

      weekToDate () {
        this.timeFrame = 'WTD'
        this.pipeline_dt1 = moment().startOf('isoWeek').toDate()
        this.pipeline_dt2 = moment().toDate()
        this.updatePipelineCalendar(true)
      },

      monthToDate () {
        this.timeFrame = 'MTD'
        this.pipeline_dt1 = moment().startOf('month').toDate()
        this.pipeline_dt2 = moment().toDate()
        this.updatePipelineCalendar(true)
      },

      quarterToDate () {
        this.timeFrame = 'QTD'
        let quarter = moment().quarter()
        this.pipeline_dt1 = moment().startOf('year').quarter(quarter).toDate()
        this.pipeline_dt2 = moment().toDate()
        this.updatePipelineCalendar(true)
      },

      yearToDate () {
        this.timeFrame = 'NTF'
        this.pipeline_dt1 = moment().startOf('year').toDate()
        this.pipeline_dt2 = moment().toDate()
        this.updatePipelineCalendar()
      },

      lastMonth () {
        this.timeFrame = 'LAST_MONTH'
        this.pipeline_dt1 = moment().subtract(1, 'month').startOf('month').toDate()
        this.pipeline_dt2 = moment().subtract(1, 'month').endOf('month').toDate()
        this.updatePipelineCalendar(true)
      },

      lastWeek () {
        this.timeFrame = 'LAST_WEEK'
        this.pipeline_dt1 = moment().subtract(1, 'week').startOf('week').add(1, 'day').toDate()
        this.pipeline_dt2 = moment().subtract(1, 'week').endOf('week').add(1, 'day').toDate()
        this.updatePipelineCalendar(true)
      },

      previousNumberOfDays (days) {
        this.timeFrame = 'NTF'
        this.pipeline_dt1 = moment().subtract(days, 'days').toDate()
        this.pipeline_dt2 = moment().subtract(1, 'days').toDate()
        this.updatePipelineCalendar()
      },

      expectationChanged () {
        clearTimeout(this.expectationTimeout)
        let expectedInstalls = this.expectedInstalls
        if (!/^(\d+|\d*(\.\d+){1})$/.test(expectedInstalls)) return
        this.expectationTimeout = setTimeout(function () {
          this.expectedInstalls = expectedInstalls
          this.pipelineLoad(expectedInstalls, this.pipeline_dt1, this.pipeline_dt2)
        }, 500)
      },

      viewSelected (view) {
        if (this.viewSelect !== view) {
          this.viewSelect = view
          this.$store.commit(AppMutations.SET_LOADING, true)
          this.pipelineLoad(this.pipeline_dt1, this.pipeline_dt2)
        }
      },

      fixFunnelTopMargin () {
        if (this.showPipelineCustomDates) {
          if (window.innerWidth >= 737 && window.innerWidth < 1070) {
            $('#funnel-background').css('margin-top', '80px')
          } else if (window.innerWidth >= 1070 && window.innerWidth < 1135) {
            $('#funnel-background').css('margin-top', '82px')
          } else if (window.innerWidth >= 1135) {
            $('#funnel-background').css('margin-top', '84px')
          }
        } else {
          if (window.innerWidth >= 737) {
            $('#funnel-background').css('margin-top', '63px')
          } else if (window.innerWidth >= 1070 && window.innerWidth < 1135) {
            $('#funnel-background').css('margin-top', '63px')
          } else if (window.innerWidth >= 1135) {
            $('#funnel-background').css('margin-top', '69px')
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
      }
      /* FUNNEL-RELATED CODE END */
    },
    created () {
      this.currentUserId = this.$store.state.user.details.id
      let userPositions = this.$store.state.user.details.userPositions

      if (userPositions.length > 0) {
        this.userOfficeId = userPositions.filter(position => position.primaryFlag && !position.endDate && ([4,5,6].indexOf(position.positionId) !== -1))[0].orgId
        this.userOffice = userPositions.filter(position => position.orgId === this.userOfficeId)[0].hierarchy.filter(orgLevel => orgLevel.orgId === this.userOfficeId)[0].orgName
        this.isSetterMgr = userPositions.filter(position => position.primaryFlag && !position.endDate && ([5,6].indexOf(position.positionId) !== -1)).length > 0
      }

      this.switchTabs(this.tabNum)
    },
    mounted () {
      $(window).bind('resize', this.checkWindowWidth)
      this.checkWindowWidth()
      $(window).bind('resize', this.fixFunnelTopMargin)
    },
    beforeDestroy () {
      $(window).unbind('resize')
    }
  }
</script>

<style lang="scss" scoped>
  #setter-dash-container {
    padding: 0;
    font-family: 'Roboto Condensed', sans-serif !important;
    letter-spacing: 0.02em !important;
  }

  #setter-dash-toolbar-container {
    position: sticky;
    top: 0;
    z-index: 3;

    #setter-dash-toolbar {
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

  #setter-dash-tabs {
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

  #personal-performance-boxes-container {
    display: flex;
    flex-flow: column nowrap;
    align-items: center;
    text-align: center;
    font-family: "Roboto", sans-serif;
    font-weight: bold;

    .personal-performance-box {
      display: flex;
      flex-flow: column nowrap;
      justify-content: center;
      background-color: #fff;
      color: var(--v-primaryCustom-base);
      box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
      padding: 5px 10px;
      margin: 5px 0;
      width: 100%;
      height: 110px;
    }

    .personal-performance-box-title {
      font-size: 12px;
    }

    .personal-performance-box-number {
      font-size: 50px;
    }

    .personal-performance-box-subtitle {
      font-size: 10px;
    }

    #personal-performance-rank-box {
      display: flex;
      flex-flow: row nowrap;
      background-color: #fff;
      color: var(--v-primaryCustom-base);
      box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
      padding: 0 10px;
      margin: 5px 0;
      width: 100%;
      height: 110px;

      #rank-box-left-side {
        display: flex;
        flex-flow: column nowrap;
        align-items: center;
        padding-top: 3px;
        width: 49%;
      }

      #rank-box-separator {
        background-color: #ddd;
        margin: 0 5px;
        width: 2px;
      }

      #rank-box-right-side {
        width: 49%;

        #rank-box-content {
          display: flex;
          flex-flow: column nowrap;
          align-items: center;
          justify-content: space-between;
          height: 80px;

          #office-to-beat-name,
          #rep-to-beat-name {
            font-size: 10px;
            color: var(--v-primaryText-base) !important;
          }

          .office-to-beat-icon,
          .rep-to-beat-icon {
            color: var(--v-primaryText-base) !important;
            font-size: 30px;
          }

          .rep-to-beat-img {
            border-radius: 50%;
            margin: 5px 0;
            width: 40px;
            height: 40px;
          }

          #rank-box-subtitle {
            font-size: 9px;
          }
        }
      }
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
    margin: 0 auto 12px auto;
    width: 100%;
  }

  #setter-ranking-tables-section {
    display: flex;
    flex-flow: column nowrap;
    align-items: center;
    width: 100%;

    #setter-ranking-tables-left-col,
    #setter-ranking-tables-right-col {
      display: flex;
      flex-flow: column nowrap;
      align-items: center;
      width: 100%;

      .ranking-table {
        margin-bottom: 10px;
      }
    }

    #setter-ranking-tables-left-col {
      margin-top: 5px;
    }
  }

  .ranking-tables-no-data {
    font-family: "Roboto", sans-serif;
    font-size: 11px;
    text-align: left;
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

  #funnel-background {
    display: none;
  }

  #pipeline-container {
    background-color: #fff;
    box-shadow: 2px 2px 6px 0 rgba(0, 0, 0, 0.3);
    width: 100%;

    .pipeline-header-container {
      display: flex;
      flex-flow: column nowrap;
      border-bottom: 1px solid var(--v-primaryCustom-base);
      width: 100%;

      #pipeline-header-top {
        display: flex;
        flex-flow: row nowrap;
        text-align: left;
        border-bottom: 1px solid var(--v-primaryCustom-base);
        padding: 5px;

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

      #pipeline-header-controls {
        display: flex;
        flex-flow: row wrap;
        padding: 3px 5px;
        width: 100%;

        #pipeline-header-left-side {
          display: flex;
          flex-flow: row nowrap;
          align-items: center;

          .v-input {
            padding-top: 0;
            margin-top: 0;

            ::v-deep {
              .v-input__slot {
                margin-bottom: 0;
              }

              .v-input--radio-group__input {
                display: flex;
                flex-flow: row nowrap;
              }
            }
          }

          .funnel-radio-btn {
            margin: 3px 13px 3px 0;

            ::v-deep {
              .v-input--selection-controls__input {
                transform: scale(0.75);
                transform-origin: left;
                margin-right: -3px;
              }

              .v-label {
                font-size: 10px;
              }
            }
          }

          ::v-deep .v-messages {
            display: none !important;
          }
        }

        #pipeline-header-right-side {
          display: flex;
          flex-flow: row wrap;
          justify-content: flex-start;
          align-items: center;

          .pipeline-dropdown {
            transform: scale(0.875);
            transform-origin: left;
            margin: 2px 0;
            max-width: 100px;

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

              .v-text-field__details {
                display: none;
              }
            }
          }

          #all-reps-btn {
            text-transform: capitalize;
            font-size: 10px;
            margin: 2px;
            width: 87px;
            height: 33px;
          }
        }
      }
    }

    .funnel-container {
      position: relative;

      .funnel-table {
        border-collapse: collapse;
        width: 100%;

        .blue-sub-row {
          background-color: #e9f2ff;
        }

        .custom-dates-container {
          display: flex;
          flex-flow: row wrap;
          justify-content: center;
          align-items: center;
          margin: 2px auto 0 auto;

          .custom-date-input {
            font-size: 8px;
            margin-bottom: 2px;
            max-width: 40px;
            height: 12px;

            ::v-deep {
              .v-input__control {
                max-width: 40px;
                height: 14px;
              }

              .v-input__slot {
                padding: 0;
                width: 40px;
                height: 12px;
                min-height: 12px;
              }

              .v-text-field__slot input {
                text-align: center;
              }

              .v-text-field__details {
                display: none;
              }
            }
          }

          .custom-date-span {
            font-size: 8px;
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

        .funnel-expectation {
          width: 150px;
        }

        .funnel-line-name {
          cursor: default !important;
          position: relative;
          z-index: 7;
          height: 38px;
        }

        #expectation-input {
          .v-input {
            transform: scale(0.75);
            transform-origin: center;
            font-size: 10px;
            margin: 0 auto;
            max-width: 50px;

            ::v-deep {
              .v-input__slot {
                margin-bottom: 0;
              }

              input {
                text-align: center;
              }

              .v-text-field__details,
              .v-messages {
                display: none;
              }
            }
          }
        }

        .funnel-td {
          font-size: 7px;
        }
      }
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
  }

  @media (min-width: 737px) {
    #setter-dash-toolbar-container #setter-dash-toolbar .v-toolbar .v-btn-toggle {
      margin-right: 0;

      .v-btn {
        font-size: 12px;
        height: 30px;
      }
    }

    #setter-dash-tabs {
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

    #personal-performance-boxes-container {
      flex-flow: row wrap;
      justify-content: space-between;
      margin: -10px auto 0 auto;
      max-width: calc(100% - 50px);

      .personal-performance-box {
        margin: 15px 0;
        width: 48%;
        height: 130px;
      }

      .personal-performance-box-title {
        font-size: 16px;
      }

      .personal-performance-box-number {
        font-size: 56px;
      }

      .personal-performance-box-subtitle {
        font-size: 14px;
      }

      #personal-performance-rank-box {
        margin: 15px 0;
        width: 48%;
        height: 130px;

        #rank-box-right-side {
          padding-top: 2px;

          #rank-box-content {
            height: 95px;

            #rep-to-beat-name {
              font-size: 12px;
            }

            .office-to-beat-icon,
            .rep-to-beat-icon {
              font-size: 35px;
            }

            #rank-box-subtitle {
              font-size: 11px;
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

    #setter-ranking-tables-section {
      flex-flow: row wrap;
      align-items: flex-start;

      #setter-ranking-tables-left-col,
      #setter-ranking-tables-right-col {
        .ranking-table {
          margin-bottom: 30px;
          font-size: 14px;
        }
      }
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

    #funnel-background {
      display: block;
      position: absolute;
      z-index: 200;
      border-top-style: solid;
      border-top-color: rgba(0, 110, 200, 0.05);
      border-top-width: 120px;
      border-right: 20px solid transparent;
      border-left: 20px solid transparent;
      margin-top: 63px;
      margin-left: 110px;
      width: 170px;
      height: 0;
    }

    #pipeline-container {
      margin: 0 auto;
      max-width: calc(100% - 50px);

      .pipeline-header-container {
        border-bottom: 2px solid var(--v-primaryCustom-base);

        #pipeline-header-top {
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

        #pipeline-header-controls {
          #pipeline-header-left-side {
            .v-input ::v-deep .v-input--radio-group__input {
              flex-flow: column nowrap;
            }

            .funnel-radio-btn {
              ::v-deep {
                .v-input--selection-controls__input {
                  transform: scale(0.8);
                  margin-right: 0;
                }

                .v-label {
                  font-size: 12px;
                }
              }
            }
          }

          #pipeline-header-right-side {
            flex-flow: row nowrap;
            margin-bottom: 0;

            .pipeline-dropdown {
              transform: none;
              margin: 3px;

              ::v-deep {
                label {
                  font-size: 12px;
                }

                i {
                  font-size: 20px;
                }
              }
            }

            #all-reps-btn {
              font-size: 12px;
              margin: 3px;
              width: 100px;
              height: 38px;
            }
          }
        }
      }

      .funnel-container {
        .funnel-table {
          .custom-dates-container {
            flex-flow: row nowrap;
            margin: 0 auto;

            .custom-date-input {
              font-size: 10px;
              margin-bottom: 1px;
              max-width: 45px;
              height: 16px;

              ::v-deep {
                .v-input__control {
                  max-width: 45px;
                  height: 16px;
                }

                .v-input__slot {
                  width: 45px;
                  height: 16px;
                  min-height: 16px;
                }
              }
            }

            .custom-date-span {
              font-size: 12px;
              margin: 0 3px;
            }
          }

          .funnel-th {
            font-size: 12px;
            padding: 8px;

            .custom-dates-btn {
              font-size: 10px;
              padding: 5px 5px 5px 8px;
              margin: 4px auto;
              min-width: 60px;
              max-width: 100px;
              height: 38px;

              .v-icon {
                font-size: 16px;
              }
            }
          }

          .funnel-expectation {
            width: 120px;
          }

          .funnel-line-name {
            width: 150px;
            height: 40px;
          }

          #expectation-input {
            .v-input {
              transform: scale(0.8);
              font-size: 15px;
              max-width: 70px;
            }
          }

          .funnel-td {
            font-size: 12px;
          }
        }
      }
    }
  }

  @media (min-width: 1070px) {
    #setter-dash-toolbar-container #setter-dash-toolbar .v-toolbar .v-btn-toggle {
      margin-right: -2px;

      .v-btn {
        font-size: 13px;
        height: 35px;
      }
    }

    #setter-dash-tabs .col-12 span {
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

    #personal-performance-boxes-container {
      flex-flow: row nowrap;

      .personal-performance-box {
        margin: 10px 0;
        padding: 5px;
        width: calc(25% - 15px);
        height: 140px;
      }

      .personal-performance-box-title {
        font-size: 14px;
      }

      .personal-performance-box-number {
        font-size: 50px;
      }

      .personal-performance-box-subtitle {
        font-size: 12px;
      }

      #personal-performance-rank-box {
        margin: 10px 0;
        padding: 5px;
        width: calc(25% - 15px);
        height: 140px;

        #rank-box-left-side,
        #rank-box-right-side {
          padding-top: 10px;
        }

        #rank-box-right-side {
          #rank-box-content {
            .office-to-beat-icon,
            .rep-to-beat-icon {
              font-size: 40px;
            }
          }
        }
      }
    }

    .ranking-tables-section-header {
      margin: 20px auto;
      max-width: calc(100% - 50px)
    }

    #setter-ranking-tables-section {
      display: flex;
      flex-flow: row nowrap;
      justify-content: space-between;
      align-items: flex-start;
      max-width: calc(100% - 50px);
      margin: 0 auto;

      #setter-ranking-tables-left-col,
      #setter-ranking-tables-right-col {
        max-width: calc((100% / 2) - 14px);

        .ranking-table {
          width: 100%;
          max-width: 100%;
        }
      }

      #setter-ranking-tables-left-col {
        margin-top: 0;

        #setter-ranking-top-offices-table {
          margin-bottom: 33px;
        }
      }
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

    #funnel-background {
      border-top-width: 180px;
      border-right: 80px solid transparent;
      border-left: 80px solid transparent;
      margin-top: 63px;
      margin-left: 140px;
      width: 320px;
    }

    #pipeline-container {
      .pipeline-header-container {
        #pipeline-header-top {
          .pipeline-icon {
            font-size: 35px;
          }

          .pipeline-title {
            margin-left: 15px;
          }
        }

        #pipeline-header-controls {
          padding: 5px 10px;

          #pipeline-header-left-side {
            .funnel-radio-btn {
              ::v-deep {
                .v-input--selection-controls__input {
                  transform: none;
                  margin-right: 4px;
                }

                .v-label {
                  font-size: 14px;
                }
              }
            }
          }

          #pipeline-header-right-side {
            .pipeline-dropdown {
              margin: 5px;

              ::v-deep {
                label {
                  font-size: 14px;
                }

                i {
                  font-size: 24px;
                }
              }
            }

            #all-reps-btn {
              font-size: 14px;
            }
          }
        }
      }

      .funnel-container {
        .funnel-table {
          .custom-dates-container {
            .custom-date-input {
              font-size: 12px;
              max-width: 55px;
              height: 18px;

              ::v-deep {
                .v-input__control {
                  max-width: 55px;
                  height: 18px;
                }

                .v-input__slot {
                  width: 55px;
                  height: 18px;
                  min-height: 18px;
                }
              }
            }

            .custom-date-span {
              font-size: 13px;
              margin: 0 5px;
            }
          }

          .funnel-th {
            font-size: 14px;
            padding: 10px;

            .custom-dates-btn {
              font-size: 12px;
              padding: 8px 10px;
              margin: 5px auto 0 auto;
              min-width: 80px;
              max-width: 125px;

              .v-icon {
                font-size: 20px;
              }
            }
          }

          .funnel-expectation {
            width: 150px;
          }

          .funnel-line-name {
            width: 300px;
          }

          #expectation-input {
            .v-input {
              transform: none;
              font-size: 14px;
              max-width: 80px;
            }
          }

          .funnel-td {
            font-size: 14px;
            height: 60px;
          }
        }
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

    #personal-performance-boxes-container {
      max-width: 1130px;
    }

    .ranking-tables-section-header {
      max-width: 1130px;
    }

    .ranking-tables-section {
      max-width: 1130px;
    }

    #setter-ranking-tables-section {
      max-width: 1130px;
    }

    #funnel-background {
      width: 370px;
    }

    #pipeline-container {
      .funnel-container {
        .funnel-table {
          .custom-dates-container {
            .custom-date-input {
              max-width: 60px;
              height: 20px;

              ::v-deep {
                .v-input__control {
                  max-width: 60px;
                  height: 20px;
                }

                .v-input__slot {
                  width: 60px;
                  height: 20px;
                  min-height: 20px;
                }
              }
            }

            .custom-date-span {
              font-size: 14px;
              margin: 0 10px;
            }
          }

          .funnel-th {
            .custom-dates-btn {
              font-size: 14px;
              min-width: 100px;
              max-width: 143px;
            }
          }

          .funnel-expectation {
            width: 150px;
          }

          .funnel-line-name {
            width: 350px;
          }
        }
      }
    }
  }
</style>

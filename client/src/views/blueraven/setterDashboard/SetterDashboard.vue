<template>
  <v-container id="setter-dash-container">
    <v-row v-if="showDashboard" id="setter-dash-toolbar-container">
      <v-col cols="12" id="setter-dash-toolbar">
        <v-app-bar class="elevation-1">
          <v-toolbar-title>Setter Dashboard</v-toolbar-title>
          <v-toolbar-items>
            <v-btn-toggle v-model="timeIntervalBtnGroup" mandatory>
              <v-btn text @click="loadRankingTables('MTD')">MTD</v-btn>
              <v-btn text @click="loadRankingTables('60 days')" class="text-lowercase">60 days</v-btn>
              <v-btn text @click="loadRankingTables('90 days')" class="text-lowercase">90 days</v-btn>
              <v-btn text @click="loadRankingTables('YTD')">YTD</v-btn>
            </v-btn-toggle>
          </v-toolbar-items>
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
          <img id="ironman-banner-mobile" src="../../../assets/blueraven/ironman_banner_mobile.png" alt="Mobile version of Ironman competition banner">
          <img id="ironman-banner" src="../../../assets/blueraven/ironman_banner.png" alt="Desktop version of Ironman competition banner">
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
                <img src="../../../assets/blueraven/ironman_swim_icon.png" alt="A person swimming">
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
                <img src="../../../assets/blueraven/ironman_bike_icon.png" alt="A person riding a bike">
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
                <img src="../../../assets/blueraven/ironman_run_icon.png" alt="A person running">
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
                <img src="../../../assets/blueraven/ironman_finish_icon.png" alt="A person crossing a finish line">
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
                <img v-if="!progressBarIsFull" src="../../../assets/blueraven/progress_bar_icon_blue.png"
                     alt="Blue Raven Solar logo in blue">
                <img v-if="progressBarIsFull" src="../../../assets/blueraven/progress_bar_icon_white.png"
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
            :items="milestoneDrilldownData"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            fixed-header
            dense
            hide-default-footer
            class="elevation-1"
          >
            <template v-if="milestoneDrilldownData.length > 0" #item="{ item, index }" class="table-body">
              <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
                <td class="text-left">{{ index + 1 }}</td>
                <td class="text-left customer-name">{{ item.customer_name ? item.customer_name : '' }}</td>
                <td class="text-left">{{ item.id ? item.id : '' }}</td>
                <td class="text-left">{{ item.source ? item.source : '' }}</td>
                <td class="text-left">{{ item.appointment_date_formatted ? item.appointment_date_formatted : '' }}</td>
                <td class="text-left">{{ item.appointment_outcome ? item.appointment_outcome : '' }}</td>
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
                 @click="closeMilestoneDialog">
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
              <td class="user-img-col">
                <img v-if="rep.userImageUrl" class="ranking-table-img"
                     :src="rep.userImageUrl" :alt="rep.userImageAltText">
                <img v-else class="placeholder-img"
                     src="../../../assets/flow/user_img_placeholder.png" :alt="rep.userImageAltText">
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
                       @change="viewSelected('standard')"
                       :class="{'white--text': viewSelect === 'standard'}"
                       :color="viewSelect === 'standard' ? 'primaryCustom' : 'secondaryCustom'">
              </v-radio>
              <v-radio label="Cohort View" value="cohort" class="funnel-radio-btn"
                       @change="viewSelected('cohort')"
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
                      item-text="org_name"
                      item-value="org_id"
                      label="District"
                      no-data-text="No districts available"
                      outlined
                      multiple
                      dense
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

            <v-select class="pipeline-dropdown"
                      v-model="regionModel"
                      :items="regionData"
                      item-text="org_name"
                      item-value="org_id"
                      label="Region"
                      no-data-text="No regions available"
                      outlined
                      multiple
                      dense
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

            <v-select class="pipeline-dropdown"
                      v-model="officeModel"
                      :items="officeData"
                      item-text="org_name"
                      item-value="org_id"
                      label="Office"
                      no-data-text="No offices available"
                      outlined
                      multiple
                      dense
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

            <v-select class="pipeline-dropdown"
                      v-model="repModel"
                      :items="repData"
                      item-text="name"
                      item-value="user_id"
                      label="Rep"
                      no-data-text="No reps available"
                      outlined
                      multiple
                      dense
                      return-object
                      @input="pipelineLoad(expectedInstalls, pipeline_dt1, pipeline_dt2, false)"
                      :menu-props="{closeOnContentClick: true}">
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="grey--text caption">
                  {{ repModel.length }} Checked
                </span>
              </template>
              <template v-if="repData.length > 0" v-slot:prepend-item>
                <v-list-item @click="toggleSelectAllReps">
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

            <v-btn v-if="!isSetter && !isSetterMgr" id="all-reps-btn" outlined @click="funnelAllReps">
              All Reps
            </v-btn>
          </div>
        </div>
      </div>

      <!-- FUNNEL -->
      <div class="funnel-container">
        <div v-show="funnelStats.length > 0" id="funnel-background"
             :class="{'standard-view': viewSelect === 'standard', 'cohort-view': viewSelect === 'cohort'}"></div>
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
                  <v-date-picker v-model="pipeline_dt1" :max="pipeline_dt2"
                                 @input="updatePipelineCalendar()"></v-date-picker>
                </v-menu>
                <span class="custom-date-span">-</span>
                <v-menu v-model="pipeline_menu2" transition="scale-transition" offset-y
                        min-width="290px" :close-on-content-click="false">
                  <template v-slot:activator="{ on }">
                    <v-text-field class="custom-date-input" v-model="pipeline_dt2_formatted" readonly
                                  outlined dense v-on="on"></v-text-field>
                  </template>
                  <v-date-picker v-model="pipeline_dt2" :min="pipeline_dt1"
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
              <v-text-field @change="expectationChanged"
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
            <td class="funnel-td" :style="{'cursor': line.id !== 4 ? 'pointer' : ''}"
                @click="line.id !== 4 ? funnelDrilldown(line.id, 'today', line.name) : ''">
              <div>
                <div class="funnel-count" :style="{color: line.countTodayState}"
                     :title="line.todayHover">
                  {{line.today_day_count}}{{line.id === 4 ? '%' : ''}}
                </div>

                <div class="funnel-percentage" :style="{color: line.percentTodayState}"
                     :title="line.percentTodayHover">
                  {{line.percentToday}}
                </div>

                <v-icon v-show="line.percentToday !== '0%'" :color="line.percentTodayState"
                        :style="{'transform': line.percentTodayState === 'green' ? 'none' : 'rotateX(180deg)'}"
                        class="funnel-arrow">
                  mdi-triangle
                </v-icon>
              </div>
            </td>

            <!-- LAST 7 DAYS COUNT -->
            <td class="funnel-td" :style="{'cursor': line.id !== 4 ? 'pointer' : ''}"
                @click="line.id !== 4 ? funnelDrilldown(line.id, '7days', line.name) : ''">
              <div>
                <div class="funnel-count" :style="{color: line.count7state}"
                     :title="line.sevenDayHover">
                  {{line.seven_day_count}}{{line.id === 4 ? '%' : ''}}
                </div>

                <div class="funnel-percentage" :style="{color: line.percent7state}"
                     :title="line.percent7hover">
                  {{line.percent7}}
                </div>

                <v-icon v-show="line.percent7 !== '0%'" :color="line.percent7state"
                        :style="{'transform': line.percent7state === 'green' ? 'none' : 'rotateX(180deg)'}"
                        class="funnel-arrow">
                  mdi-triangle
                </v-icon>
              </div>
            </td>

            <!-- LAST 30 DAYS COUNT -->
            <td class="funnel-td" :style="{'cursor': line.id !== 4 ? 'pointer' : ''}"
                @click="line.id !== 4 ? funnelDrilldown(line.id, '30days', line.name) : ''">
              <div>
                <div class="funnel-count" :style="{color: line.count30state}"
                     :title="line.thirtyDayHover">
                  {{line.thirty_day_count}}{{line.id === 4 ? '%' : ''}}
                </div>

                <div class="funnel-percentage" :style="{color: line.percent30state}"
                     :title="line.percent30hover">
                  {{line.percent30}}
                </div>

                <v-icon v-show="line.percent30 !== '0%'" :color="line.percent30state"
                        :style="{'transform': line.percent30state === 'green' ? 'none' : 'rotateX(180deg)'}"
                        class="funnel-arrow">
                  mdi-triangle
                </v-icon>
              </div>
            </td>

            <!-- CUSTOM DATE RANGE COUNT -->
            <td class="funnel-td"
                :style="{color: line.customCountState, 'cursor': line.id !== 4 ? 'pointer' : ''}"
                :title="line.customDayHover"
                @click="line.id !== 4 ? funnelDrilldown(line.id, 'custom', line.name) : ''">
              {{line.custom_date_range_count}}{{line.id === 4 ? '%' : ''}}
            </td>
          </tr>
        </table>
      </div>
    </div>
    <!-- FUNNEL END -->

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
            :height="funnelDrilldownRowCount > 0 ? (constants.IS_MOBILE ? 'calc(100vh - 250px)' : 'calc(100vh - 365px)') : '105px'"
            dense
            multi-sort
            :sort-by="[]"
            :sort-desc="[]"
            :loading="funnelDrilldownLoading"
            :items-per-page="500"
            :footer-props="footerProps"
          >
            <template v-if="funnelDrilldownData.length > 0" #item="{ item, index }" class="table-body">
              <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
                <td style="text-align: center">
                  {{ funnelDrilldownSearch ? index + 1 : item.rowNum }}
                </td>
                <td>{{ item.setter_name ? item.setter_name : '' }}</td>
                <td>{{ item.employee_id ? item.employee_id : '' }}</td>
                <td class="customer-name">{{ item.customer_name ? item.customer_name : '' }}</td>
                <td>{{ item.project_id ? item.project_id : '' }}</td>
                <td>{{ item.appointment_date_formatted ? item.appointment_date_formatted : '' }}</td>
                <td>{{ item.owner_name ? item.owner_name : '' }}</td>
                <td>{{ item.verified_setter_lead ? item.verified_setter_lead : '' }}</td>
                <td :class="item.appointment_outcome_class">
                  {{ item.appointment_outcome ? item.appointment_outcome : '' }}
                </td>
                <td>{{ item.date_created_formatted ? item.date_created_formatted : '' }}</td>
                <td>{{ item.state ? item.state : '' }}</td>
                <td>{{ item.office ? item.office : '' }}</td>
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
                 @click="closeFunnelDrilldownDialog">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <!----------------------------------- PIPELINE TAB END ----------------------------------->


  </v-container>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import $ from 'jquery'
  import moment from 'moment'
  import constants from '@/helpers/constants'
  import { getRequestWithParams, postRequest, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import { getSetterDistricts, getSetterRegions, getSetterOffices, getSetterReps } from '@/services/dashboardService'

  export default {
    name: 'setterDashboard',
    data: () => ({
      snackbar: {},
      constants,
      milestoneDialog: false,
      funnelDrilldownDialog: false,
      currentUserId: null,
      isSetter: false,
      isSetterMgr: false,
      isSetterRegional: false,
      selectedQuarter: 1,
      headers: [
        { text: '', value: '', show: true, sortable: false },
        { text: 'Name', value: 'customer_name', show: true },
        { text: 'Project ID', value: 'id', show: true },
        { text: 'Source', value: 'source_name', show: true },
        { text: 'Appointment Date', value: 'appointment_date', show: true },
        { text: 'Appointment Outcome', value: 'appointment_outcome', show: true }
      ],
      milestoneDrilldownData: [],
      timeIntervalBtnGroup: 0,
      timeIntervalString: 'MTD', // MTD is selected by default
      timeInterval: +moment().format('DD') - 1,
      tabNum: 1, // Dashboard tab is selected by default
      showDashboard: true,
      showFunnel: false,
      performanceDataLoaded: false,
      rankingTablesLoaded: false,
      funnelDataLoaded: false,
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
      regionModel: [],
      regionData: [],
      officeModel: [],
      officeData: [],
      repModel: [],
      repData: [],
      pipelineDateRanges: [
        { label: 'Yesterday', value: 'yesterday' },
        { label: 'Last Week', value: 'lastWeek' },
        { label: 'Last Month', value: 'lastMonth' },
        { label: 'Last 90 days', value: 90 },
        { label: 'Week to Date', value: 'WTD' },
        { label: 'Month to Date', value: 'MTD' },
        { label: 'Quarter to Date', value: 'QTD' },
        { label: 'Year to Date', value: 'YTD' },
        { label: 'Custom', value: 'Custom' }
      ],
      pipelineDateRange: { label: 'Week to Date', value: 'WTD' },
      showPipelineCustomDates: false,
      customDateSelectorIsOpen: false,
      viewSelect: 'standard',
      pipeline_dt1: moment().startOf('W').format('YYYY-MM-DD'),
      pipeline_dt1_formatted: moment().startOf('W').format('M/D/YY'),
      pipeline_menu1: false,
      pipeline_dt2: moment().format('YYYY-MM-DD'),
      pipeline_dt2_formatted: moment().format('M/D/YY'),
      pipeline_menu2: false,
      expectedInstalls: 1,
      expectationTimeout: 0,
      funnelStats: [],
      funnelDrilldownTitle: '',
      funnelDrilldownHeaders: [
        { text: '', value: '', show: true, sortable: false, width: 25 },
        { text: 'Setter', value: 'setter_name', show: true, width: 90 },
        { text: 'Employee ID', value: 'employee_id', show: true, width: 120 },
        { text: 'Name', value: 'customer_name', show: true, width: 90 },
        { text: 'Project ID', value: 'project_id', show: true, width: 95 },
        { text: 'Appointment Date', value: 'appointment_date_formatted', show: true, width: 150 },
        { text: 'Closer', value: 'owner_name', show: true, width: 90 },
        { text: 'Verified Setter Lead', value: 'verified_setter_lead', show: true, width: 170 },
        { text: 'Appointment Outcome', value: 'appointment_outcome', show: true, width: 175 },
        { text: 'Date Created', value: 'date_created_formatted', show: true, width: 115 },
        { text: 'State', value: 'state', show: true, width: 80 },
        { text: 'Office', value: 'office', show: true, width: 90 }
      ],
      funnelDrilldownData: [],
      funnelDrilldownLoading: false,
      funnelDrilldownSearch: '',
      filteredFunnelDrilldownData: [],
      funnelDrilldownRowCount: 0,
      footerProps: {
        showFirstLastPage: !constants.IS_MOBILE,
        firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
        lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
        'items-per-page-options': [100, 500, 1000, 2500, 5000, 10000]
      }
    }),
    computed: {
      is_q1 () { return this.currentQuarter === 1 },
      is_q2 () { return this.currentQuarter === 2 },
      is_q3 () { return this.currentQuarter === 3 },
      is_q4 () { return this.currentQuarter === 4 },
      milestoneDrilldownTitle () {
        return this.$store.state.user.details.firstName + ' ' + this.$store.state.user.details.lastName + ' | Pitches - Q' + this.selectedQuarter
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
      }
    },
    watch: {
      // the loading animation kept going away before it was supposed to, so this makes sure that it doesn't do that anymore
      '$store.state.app.loading': function () {
        if ((this.showDashboard && !this.performanceDataLoaded || !this.rankingTablesLoaded) || (this.showFunnel && !this.funnelDataLoaded)) {
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
              await this.loadFunnel()
              this.funnelWasLoaded = true
            }
            break
          default: // Dashboard tab
            this.showDashboard = true
            this.showFunnel = false
            await this.loadIronman()

            if (!this.dashboardWasLoaded) {
              await this.loadRankingTables('MTD') // MTD is the default
              this.dashboardWasLoaded = true
            }
        }
      },

      /* IRONMAN-RELATED CODE START */
      async loadIronman () {
        this.$store.commit(AppMutations.SET_LOADING, true)
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

            this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving Ironman data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
            case pitchCount >= 48 && pitchCount < 60:
              return 1 // Bronze
            case pitchCount >= 60 && pitchCount < 72:
              return 2 // Silver
            case pitchCount >= 72 && pitchCount < 84:
              return 3 // Gold
            case pitchCount >= 84:
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
            setterMgrOfficeId: this.isSetterMgr && this.userOfficeId ? this.userOfficeId : null
          }
          const {data} = await getRequestWithParams('/setterDashboard/pitchesDrilldown', {params}, 'blueraven')
          this.milestoneDrilldownData = cloneDeep(data)

          if (this.milestoneDrilldownData.length > 0) {
            this.reformatDates()
            this.milestoneDrilldownData.forEach(row => {
              if (row.customer_name) {
                row.customer_name = row.customer_name.toLowerCase()
              }
            })
          } else {
            this.milestoneDrilldownData = []
          }

          this.selectedQuarter = quarter
          this.milestoneDialog = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving drilldown data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      reformatDates () {
        this.milestoneDrilldownData.forEach(row => {
          if (row.appointment_date) {
            row.appointment_date_formatted = moment(row.appointment_date).format('MMM D, YYYY')
          }
        })
      },

      closeMilestoneDialog () {
        this.milestoneDialog = false

        // reset scroll bar positioning to top
        document.getElementsByClassName('v-dialog--active')[0].scrollTop = 0
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

                  if (officeToBeat.name.includes(' ()')) {
                    officeToBeat.name = officeToBeat.name.substr(0, officeToBeat.name.length - 3)
                  }

                  this.rankBoxData.setter_office_to_beat_name = officeToBeat.name
                  this.rankBoxData.pitches_to_go = 1
                }
              } else {
                if (this.rankBoxData.setter_office_to_beat_name.includes(' ()')) {
                  this.rankBoxData.setter_office_to_beat_name = this.rankBoxData.setter_office_to_beat_name.substr(0, this.rankBoxData.setter_office_to_beat_name.length - 3)
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
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async getRepToBeatImage (repToBeatId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {sourceId: repToBeatId, attachmentTypeId: 9}
          const {data} = await getRequestWithParams('/attachment/getOne', {params})

          if (data?.presignedUrl) {
            this.rankBoxData.imageUrl = data.presignedUrl

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
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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

          if (this.reps.length > 0) {
            let userIds = []

            this.reps.forEach(rep => {
              if (rep.user_id) {
                userIds.push(rep.user_id)
              }
            })

            if (userIds.length > 0) {
              userIds = encodeURI(userIds)

              let params = {
                sourceIds: userIds,
                attachmentTypeId: 9
              }

              const {data} = await getRequestWithParams('/attachment/getAttachmentPresignedUrlsForUserList', {params})

              if (data) {
                this.reps.forEach(rep => {
                  if (rep.user_id && data[rep.user_id]) {
                    rep.userImageUrl = data[rep.user_id]
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
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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

          // removes empty parentheses from missing metro areas
          this.offices.forEach(office => {
            if (office.name.includes(' ()')) {
              office.name = office.name.substr(0, office.name.length - 3)
            }
          })

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving top offices data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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

          this.officeRankingData.forEach(office => {
            if (office.org.includes(' ()')) {
              office.org = office.org.substr(0, office.org.length - 3)
            }
          })

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving office ranking data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.rankingTablesLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      /* RANKING TABLES-RELATED CODE END */

      /* FUNNEL-RELATED CODE START */
      async districtLoad (preSelectLists) {
        if (!this.currentUserId) return

        this.$store.commit(AppMutations.SET_LOADING, true)
        await getSetterDistricts(this.currentUserId).then(res => {
          if (res?.length > 0) {
            this.districtData = res
          }

          if (preSelectLists) {
            this.districtModel = cloneDeep(this.districtData)
          } else {
            this.funnelDataLoaded = true
          }

          if (this.districtModel.length > 0) {
            this.regionLoad(preSelectLists)
          }
        })

        this.funnelStats = []
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
        await getSetterRegions(this.currentUserId, JSON.stringify(districts)).then(res => {
          this.regionData = res

          if (preSelectLists) {
            this.regionModel = cloneDeep(this.regionData)
          }

          if (this.regionModel.length > 0) {
            this.officeLoad(preSelectLists)
          }
        })

        this.funnelStats = []
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
        await getSetterOffices(this.currentUserId, JSON.stringify(regions)).then(res => {
          this.officeData = res

          if (preSelectLists) {
            this.officeModel = cloneDeep(this.officeData)
          }

          if (this.officeModel.length > 0) {
            this.repLoad(preSelectLists)
          }
        })

        this.funnelStats = []
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
        await getSetterReps(this.currentUserId, JSON.stringify(regions), JSON.stringify(offices)).then(res => {
          this.repData = res

          if (preSelectLists) {
            this.repModel = cloneDeep(this.repData)
          }

          this.funnelStats = []

          if (this.repModel.length > 0) {
            this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
          }
        })

        this.$store.commit(AppMutations.SET_LOADING, false)
      },

      roundTenth (value) {
        if (typeof value !== 'number') {
          return value
        }
        let precision = Math.max(Math.ceil(Math.log10(value)) + 1, 2)
        if (value < 1) precision = 1
        if (value === 0) precision = 2
        return value.toPrecision(precision)
      },

      daysBetween (start, end) {
        let a = moment(start)
        let b = moment(end)
        return b.diff(a, 'days')
      },

      getCountHover (count, expectation) {
        return count < expectation ? 'Worse than expectation' : 'Better than expectation'
      },

      getPercentColor (percent) {
        if (percent < 0) return 'red'
        return 'green'
      },

      getPercentHover (percent, dayNum) {
        let state = ''
        if (percent < 0) {
          state = 'worse'
        } else if (percent > 0) {
          state = 'better'
        } else {
          return ''
        }

        let previousTime = 'last ' + dayNum + ' days'
        if (dayNum === 1) {
          previousTime = 'yesterday'
        }

        return '% ' + state + ' than ' + previousTime
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

        this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
      },

      async pipelineLoad (targetInstallations, start, end, useRepDataInstead) {
        this.funnelDataLoaded = false
        let reps = []
        let orgs = []

        if ((this.repModel.length === 0 && !useRepDataInstead) || (useRepDataInstead && this.repData.length === 0)) {
          this.funnelStats = []
          this.funnelDataLoaded = true
          return
        }

        this.officeModel.forEach(org => orgs.push(org.org_id))

        if (useRepDataInstead) {
          this.repData.forEach((rep, index) => {
            reps.push(rep.user_id)

            if (index === this.repData.length - 1) {
              this.districtModel = []
              this.regionModel = []
              this.officeModel = []

              this.repModel = [
                {user_id: -1, name: 'All Reps', active: true}
              ]

              this.repData = [
                {user_id: -1, name: 'All Reps', active: true}
              ]
            }
          })
        } else {
          this.repModel.forEach(rep => reps.push(rep.user_id))
        }

        const requestBody = {
          targetInstallations: targetInstallations,
          users: reps,
          orgs: orgs,
          start: moment(start).format('YYYY-MM-DD'),
          end: moment(end).format('YYYY-MM-DD')
        }

        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await postRequest('/setterDashboard/funnel/' + this.viewSelect, requestBody, 'blueraven').then(({data}) => {
            data.forEach(row => {
              // EXPECTATION column
              row.expectation = this.roundTenth(row.expectation)

              // TODAY column
              row.countTodayState = row.today_day_count < row.expectation ? 'red' : 'green'
              row.todayHover = this.getCountHover(row.today_day_count, row.expectation)
              row.percentToday = row.today_percent ? row.today_percent + '%' : '0%'
              row.percentTodayState = this.getPercentColor(row.today_percent)
              row.percentTodayHover = this.getPercentHover(row.today_percent, 1)

              // LAST 7 DAYS column
              row.count7state = row.seven_day_count < row.expectation ? 'red' : 'green'
              row.sevenDayHover = this.getCountHover(row.seven_day_count, row.expectation)
              row.percent7 = row.seven_percent ? row.seven_percent + '%' : '0%'
              row.percent7state = this.getPercentColor(row.seven_percent)
              row.percent7hover = this.getPercentHover(row.seven_percent, 7)

              // LAST 30 DAYS column
              row.count30state = row.thirty_day_count < row.expectation ? 'red' : 'green'
              row.thirtyDayHover = this.getCountHover(row.thirty_day_count, row.expectation)
              row.percent30 = row.thirty_day_percent ? row.thirty_day_percent + '%' : '0%'
              row.percent30state = this.getPercentColor(row.thirty_day_percent)
              row.percent30hover = this.getPercentHover(row.thirty_day_percent, 30)

              // CUSTOM DATE RANGE column
              row.custom_date_range_count = Math.round(row.custom_date_range_count)
              row.customCountState = row.custom_date_range_count < row.expectation ? 'red' : 'green'
              row.customDayHover = this.getCountHover(row.custom_date_range_count, row.expectation)
            })

            this.funnelStats = data
            this.funnelDataLoaded = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          })
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving pipeline data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.funnelDataLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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
        if (this.showPipelineCustomDates) {
          this.showPipelineCustomDates = false
          this.fixFunnelTopMargin()
        }

        this.pipelineDateRange = dateRange

        switch (dateRange.value) {
          case 'yesterday':
            this.yesterday()
            break
          case 'lastWeek':
            this.lastWeek()
            break
          case 'lastMonth':
            this.lastMonth()
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
        this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
      },

      updatePipelineCalendar () {
        this.pipeline_menu1 = false
        this.pipeline_menu2 = false
        this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
      },

      yesterday () {
        this.pipeline_dt1 = moment().subtract(1, 'd').format('YYYY-MM-DD')
        this.pipeline_dt2 = moment().subtract(1, 'd').format('YYYY-MM-DD')
        this.updatePipelineCalendar(true)
      },

      lastWeek () {
        this.pipeline_dt1 = moment().subtract(1, 'week').startOf('week').add(1, 'day').format('YYYY-MM-DD')
        this.pipeline_dt2 = moment().subtract(1, 'week').endOf('week').add(1, 'day').format('YYYY-MM-DD')
        this.updatePipelineCalendar(true)
      },

      lastMonth () {
        this.pipeline_dt1 = moment().subtract(1, 'month').startOf('month').format('YYYY-MM-DD')
        this.pipeline_dt2 = moment().subtract(1, 'month').endOf('month').format('YYYY-MM-DD')
        this.updatePipelineCalendar(true)
      },

      weekToDate () {
        this.pipeline_dt1 = moment().startOf('isoWeek').format('YYYY-MM-DD')
        this.pipeline_dt2 = moment().format('YYYY-MM-DD')
        this.updatePipelineCalendar(true)
      },

      monthToDate () {
        this.pipeline_dt1 = moment().startOf('month').format('YYYY-MM-DD')
        this.pipeline_dt2 = moment().format('YYYY-MM-DD')
        this.updatePipelineCalendar(true)
      },

      quarterToDate () {
        let quarter = moment().quarter()
        this.pipeline_dt1 = moment().startOf('year').quarter(quarter).format('YYYY-MM-DD')
        this.pipeline_dt2 = moment().format('YYYY-MM-DD')
        this.updatePipelineCalendar(true)
      },

      yearToDate () {
        this.pipeline_dt1 = moment().startOf('year').format('YYYY-MM-DD')
        this.pipeline_dt2 = moment().format('YYYY-MM-DD')
        this.updatePipelineCalendar()
      },

      previousNumberOfDays (days) {
        this.pipeline_dt1 = moment().subtract(days, 'days').format('YYYY-MM-DD')
        this.pipeline_dt2 = moment().subtract(1, 'days').format('YYYY-MM-DD')
        this.updatePipelineCalendar()
      },

      expectationChanged () {
        clearTimeout(this.expectationTimeout)
        let expectedInstalls = this.expectedInstalls
        if (!/^(\d+|\d*(\.\d+){1})$/.test(expectedInstalls)) return
        this.expectedInstalls = expectedInstalls
        this.pipelineLoad(expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
      },

      viewSelected (view) {
        if (this.viewSelect !== view) {
          this.viewSelect = view

          if ((this.districtModel.length > 0 && this.regionModel.length > 0 && this.officeModel.length > 0 && this.repModel.length > 0) || this.repModel[0]?.user_id === -1) {
            this.$store.commit(AppMutations.SET_LOADING, true)
            this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
          }
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
      },

      loadFunnel () {
        if (!this.showDashboard && this.funnelStats?.length === 0) {
          if (this.isSetter) {
            this.districtLoad(true)
          } else {
            this.districtLoad(false)
          }
        }
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
          } else if (!this.selectAllReps && (this.isSetter || this.isSetterMgr || this.isSetterRegional)) {
            this.$store.commit(AppMutations.SET_LOADING, true)
            this.repModel = cloneDeep(this.repData)
            this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
          } else {
            this.$store.commit(AppMutations.SET_LOADING, true)
            this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, true)
          }
        })
      },

      async funnelDrilldown (funnelId, dateRange, funnelName) {
        let reps = []
        let orgs = []
        let start, end
        let datesMatch = false

        reps = this.repModel.map(rep => rep.user_id)
        orgs = this.officeModel.map(org => org.org_id)

        switch (dateRange) {
          case 'today':
            start = moment().format('YYYY-MM-DD')
            end = moment().format('YYYY-MM-DD')
            break
          case '7days':
            start = moment().subtract(7, 'days').format('YYYY-MM-DD')
            end = moment().format('YYYY-MM-DD')
            break
          case '30days':
            start = moment().subtract(30, 'days').format('YYYY-MM-DD')
            end = moment().format('YYYY-MM-DD')
            break
          default:
            start = this.pipeline_dt1
            end = this.pipeline_dt2
            break
        }

        if (moment(start).format('YYYY-MM-DD') === moment(end).format('YYYY-MM-DD')) {
          datesMatch = true
          this.funnelDrilldownTitle = funnelName + ' on ' + moment(start).format('M/D/YYYY')
        } else {
          this.funnelDrilldownTitle = funnelName + ' ' + moment(start).format('M/D/YYYY') + ' - ' + moment(end).format('M/D/YYYY')
        }

        const requestBody = {
          start: start,
          end: end,
          funnelId: funnelId,
          users: reps,
          orgs: orgs
        }

        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await postRequest(`/setterDashboard/funnelDrilldown/${this.viewSelect}`, requestBody, 'blueraven').then(({data}) => {
            this.funnelDrilldownData = data?.length > 0 ? data : []

            if (this.funnelDrilldownData?.length > 0) {
              for (let i = 0; i < this.funnelDrilldownData.length; i++) {
                this.funnelDrilldownData[i].rowNum = i + 1
              }

              this.markMissingDrilldownData()
              this.reformatFunnelDrilldownDates()

              this.funnelDrilldownData.forEach(row => {
                if (row.verified_setter_lead !== null && row.verified_setter_lead === true) {
                  row.verified_setter_lead = 'Yes'
                } else if (row.verified_setter_lead !== null && row.verified_setter_lead === false) {
                  row.verified_setter_lead = 'No'
                }
              })
            }

            this.funnelDrilldownDialog = true
            this.$store.commit(AppMutations.SET_LOADING, false)
          })
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving drilldown data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      markMissingDrilldownData() {
        this.funnelDrilldownData = this.funnelDrilldownData.map(function (line) {
          let newLine = {}

          Object.keys(line).forEach(function (key) {
            newLine[key] = line[key]
            newLine[key + '_class'] = !line[key] ? 'missing' : ''
          })

          return newLine
        })
      },

      reformatFunnelDrilldownDates () {
        this.funnelDrilldownData?.forEach(row => {
          if (row.appointment_date) {
            row.appointment_date_formatted = moment(row.appointment_date).format('MMM D, YYYY')
          }

          if (row.date_created) {
            row.date_created_formatted = moment(row.date_created).format('MMM D, YYYY')
          }
        })
      },

      filteredFunnelDrilldownItems (filteredItems) {
        this.filteredFunnelDrilldownData = filteredItems
        this.funnelDrilldownRowCount = filteredItems.length
      },

      closeFunnelDrilldownDialog () {
        this.funnelDrilldownDialog = false

        // reset scroll bar positioning to top
        document.getElementsByClassName('v-dialog--active')[0].scrollTop = 0
      }
      /* FUNNEL-RELATED CODE END */
    },
    created () {
      this.currentUserId = this.$store.state.user.details.id
      let userPositions = this.$store.state.user.details.userPositions

      if (userPositions?.length > 0) {
        this.userOfficeId = userPositions.filter(position => position.primaryFlag && !position.endDate)[0].orgId
        this.userOffice = userPositions.filter(position => position.orgId === this.userOfficeId)[0].hierarchy.filter(orgLevel => orgLevel.orgId === this.userOfficeId)[0].orgName
        this.isSetter = userPositions.filter(position => (position.positionId === 4) && !position.endDate && !position.archived && position.primaryFlag).length > 0
        this.isSetterMgr = userPositions.filter(position => (position.positionId === 5) && !position.endDate && !position.archived && position.primaryFlag).length > 0
        this.isSetterRegional = userPositions.filter(position => (position.positionId === 6) && !position.endDate && !position.archived && position.primaryFlag).length > 0
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

      header {
        background-color: #fff !important;
      }

      .v-toolbar {
        margin-top: -12px;

        ::v-deep .v-toolbar__content {
          display: flex;
          justify-content: space-between;
          width: 100%;

          .v-toolbar__title {
            font-size: 13px;
          }

          .v-toolbar__items {
            display: flex;
            flex-flow: column nowrap;
            justify-content: center;
          }
        }

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
            opacity: .75;
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

        #pipeline-header-left-side,
        #pipeline-header-right-side {
          display: flex;
          align-items: center;
        }

        #pipeline-header-left-side {
          flex-flow: row nowrap;

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
          flex-flow: row wrap;

          .pipeline-dropdown {
            transform: scale(0.875);
            transform-origin: left;
            margin: 2px 0;
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

              .v-text-field__details {
                display: none;
              }
            }
          }

          #all-reps-btn {
            text-transform: capitalize;
            font-size: 10px;
            margin: 2px 0;
            width: 87px;
            height: 35px;
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
            padding: 4px 1px;
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
          text-align: center;
          width: 75px;
        }

        .funnel-line-name {
          cursor: default !important;
          position: relative;
          z-index: 7;
          text-align: center;
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
          text-align: center;

          div {
            display: flex;
            justify-content: center;
          }

          .funnel-count,
          .funnel-percentage {
            margin: 3px;
          }

          .funnel-arrow {
            font-size: 6px;
          }
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
    #setter-dash-toolbar-container #setter-dash-toolbar .v-toolbar .v-toolbar__content .v-toolbar__title {
      font-size: 16px;
    }

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

  @media (min-width: 737px) {
    #setter-dash-toolbar-container #setter-dash-toolbar .v-toolbar .v-toolbar__content {
      .v-toolbar__title {
        font-size: 18px;
      }

      .v-btn-toggle {
        margin-right: 0;

        .v-btn {
          font-size: 12px;
          height: 30px;
        }
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

    .ranking-table-img,
    .placeholder-img {
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
      z-index: 6;
      border-top-style: solid;
      border-top-color: rgba(0, 110, 200, 0.05);
      border-right: 20px solid transparent;
      border-left: 20px solid transparent;
      margin-top: 63px;
      margin-left: 110px;
      width: 170px;
      height: 0;
    }

    #funnel-background.standard-view {
      border-top-width: 120px;
    }

    #funnel-background.cohort-view {
      border-top-width: 160px;
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
          justify-content: space-between;

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
              height: 40px;
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
              padding: 5px 2px;
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

            .funnel-count,
            .funnel-percentage {
              margin: 5px;
            }

            .funnel-arrow {
              font-size: 10px;
            }
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

  @media (min-width: 1070px) {
    #setter-dash-toolbar-container #setter-dash-toolbar .v-toolbar .v-toolbar__content {
      .v-toolbar__title {
        font-size: 20px;
      }

      .v-btn-toggle {
        margin-right: -2px;

        .v-btn {
          font-size: 13px;
          height: 35px;
        }
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
    }

    .ranking-tables-no-data {
      font-size: 12px;
    }

    #funnel-background {
      border-right: 80px solid transparent;
      border-left: 80px solid transparent;
      margin-top: 63px;
      margin-left: 140px;
      width: 320px;
    }

    #funnel-background.standard-view {
      border-top-width: 180px;
    }

    #funnel-background.cohort-view {
      border-top-width: 240px;
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
              margin: 5px 0 5px 5px;
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
              padding: 8px 4px;
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

            .funnel-count,
            .funnel-percentage {
              margin: 10px;
            }

            .funnel-arrow {
              font-size: 12px;
            }
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
</style>

<template>
  <v-container id="setter-dash-container" ref="setterDashContainer">
    <!---------------------------------- FUNNEL TAB START ---------------------------------->
    <!-- FUNNEL -->
    <div id="pipeline-container" class="funnel-relative"
         :class="{'mb-8': funnelStats.length > 0}">
      <div v-if="dropdownValuesLoading || setterPipelineLoading" class="funnel-spinner">
        <SpinnerInline :size="50" :spinner-color="`primaryCustom`" :transparent="true" :centered="true"/>
      </div>
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
            <v-autocomplete class="appts-to-fdc-pipeline-dropdown"
                            ref="areaSelect"
                            v-model="areaModel"
                            :items="areaData"
                            item-text="org_name"
                            item-value="org_id"
                            label="Area"
                            no-data-text="No areas available"
                            outlined
                            multiple
                            dense
                            hide-details
                            @input="areaValuesChanged = true"
                            return-object>
              <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="grey--text text-caption">
                {{ areaModel.length }} Checked
              </span>
              </template>
              <template v-if="areaData.length > 0" v-slot:prepend-item>
                <v-list-item @click="[areaValuesChanged = true, toggleSelectAllAreas()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ areaSelectIcon }}</v-icon>
                  </v-list-item-action>
                  <v-list-item-content>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-divider class="mt-2"></v-divider>
              </template>
              <template v-slot:item="data">
                <v-list-item-action class="mr-2">
                  <v-icon v-if="data.attrs.inputValue">check_box</v-icon>
                  <v-icon v-else>check_box_outline_blank</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">
                    {{ data.item.org_name }}
                  </v-list-item-title>
                </v-list-item-content>
              </template>
            </v-autocomplete>

            <v-autocomplete class="pipeline-dropdown"
                            v-model="regionModel"
                            ref="regionSelect"
                            :items="regionData"
                            item-text="org_name"
                            item-value="org_id"
                            label="Region"
                            no-data-text="No regions available"
                            outlined
                            multiple
                            dense
                            return-object
                            @input="regionValuesChanged = true">
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="grey--text text-caption">
                  {{ regionModel.length }} Checked
                </span>
              </template>
              <template v-if="regionData.length > 0" v-slot:prepend-item>
                <v-list-item @click="[regionValuesChanged = true, toggleSelectAllRegions()]">
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
            </v-autocomplete>

            <v-autocomplete class="pipeline-dropdown"
                            ref="districtSelect"
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
                            @input="districtValuesChanged = true">
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="grey--text text-caption">
                  {{ districtModel.length }} Checked
                </span>
              </template>
              <template v-if="districtData.length > 0" v-slot:prepend-item>
                <v-list-item @click="[districtValuesChanged = true, toggleSelectAllDistricts()]">
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
            </v-autocomplete>


            <v-autocomplete class="pipeline-dropdown"
                            ref="officeSelect"
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
                            @input="officeValuesChanged = true">
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="grey--text text-caption">
                  {{ officeModel.length }} Checked
                </span>
              </template>
              <template v-if="officeData.length > 0" v-slot:prepend-item>
                <v-list-item @click="[officeValuesChanged = true, toggleSelectAllOffices()]">
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
            </v-autocomplete>

            <v-autocomplete class="pipeline-dropdown"
                            v-model="repModel"
                            :items="repData"
                            ref="repSelect"
                            item-text="name"
                            item-value="user_id"
                            label="Rep"
                            no-data-text="No reps available"
                            outlined
                            multiple
                            dense
                            hide-details
                            return-object
                            :disabled="repsLoading"
                            @input="repValuesChanged = true">

              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="grey--text text-caption">
                  {{ repModel.length }} Checked
                </span>
              </template>
              <template v-if="repData.length > 0" v-slot:prepend-item>
                <v-list-item @click="[repValuesChanged = true, repDataSelectAll = !repDataSelectAll, toggleSelectAllReps()]">
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
            </v-autocomplete>

            <v-btn v-if="!isSetter && !isSetterMgr" id="all-reps-btn" outlined @click="funnelAllReps">
              All Reps
            </v-btn>
          </div>
        </div>
      </div>

      <!-- FUNNEL -->
      <div class="funnel-relative funnel-container">
        <div v-show="funnelStats.length > 0" id="funnel-background"
             :class="{'standard-view': viewSelect === 'standard', 'cohort-view': viewSelect === 'cohort'}"
             :stype="{'margin-top': showPipelineCustomDates && windowInnerWidth < 1135 ? '81px' :
                                    showPipelineCustomDates && windowInnerWidth >= 1135 ? '84px' :
                                    windowInnerWidth < 1135 ? '63px' : '69px'}"
        ></div>
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
          <tr class="funnel-tr" :class="{'blue-sub-row': index % 2 === 0}"
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
            <td class="funnel-td" :style="{'cursor': line.id !== 30 ? 'pointer' : ''}"
                @click="line.id !== 30 ? funnelDrilldown(line.id, 'today', line.name) : ''">
              <div>
                <div class="funnel-count" :style="{color: line.countTodayState}"
                     :title="line.todayHover">
                  {{line.today_day_count}}{{line.id === 30 ? '%' : ''}}
                </div>

                <div v-if="line.id !== 30" class="funnel-percentage" :style="{color: line.percentTodayState}"
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
            <td class="funnel-td" :style="{'cursor': line.id !== 30 ? 'pointer' : ''}"
                @click="line.id !== 30 ? funnelDrilldown(line.id, '7days', line.name) : ''">
              <div>
                <div class="funnel-count" :style="{color: line.count7state}"
                     :title="line.sevenDayHover">
                  {{line.seven_day_count}}{{line.id === 30 ? '%' : ''}}
                </div>

                <div v-if="line.id !== 30" class="funnel-percentage" :style="{color: line.percent7state}"
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
            <td class="funnel-td" :style="{'cursor': line.id !== 30 ? 'pointer' : ''}"
                @click="line.id !== 30 ? funnelDrilldown(line.id, '30days', line.name) : ''">
              <div>
                <div class="funnel-count" :style="{color: line.count30state}"
                     :title="line.thirtyDayHover">
                  {{line.thirty_day_count}}{{line.id === 30 ? '%' : ''}}
                </div>

                <div v-if="line.id !== 30" class="funnel-percentage" :style="{color: line.percent30state}"
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
                :style="{color: line.customCountState, 'cursor': line.id !== 30 ? 'pointer' : ''}"
                :title="line.customDayHover"
                @click="line.id !== 30 ? funnelDrilldown(line.id, 'custom', line.name) : ''">
              {{line.custom_date_range_count}}{{line.id === 30 ? '%' : ''}}
            </td>
          </tr>
        </table>
      </div>
    </div>
    <!-- FUNNEL END -->

    <v-dialog v-model="funnelDrilldownDialog" @input="closeFunnelDrilldownDialog">
      <v-card id="funnel-drilldown">
        <v-card-title class="mb-1">
          <span id="funnel-drilldown-title">{{ funnelDrilldownTitle }}</span>
          <a class="close-modal-x pb-3" title="Close" @click="closeFunnelDrilldownDialog">×</a>
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
            <template v-if="funnelDrilldownData.length > 0" #item="{ item, index }">
              <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]">
                <td style="text-align: center">
                  {{ funnelDrilldownSearch ? index + 1 : item.rowNum }}
                </td>
                <td>{{ item.setter_name || '' }}</td>
                <td class="customer-name">{{ item.customer_name || '' }}</td>
                <td>
                  <router-link text v-if="item.project_id && $store.getters.userHasFeature('PROJECTS')" :to="`/project/${item.project_id}`">
                    {{ item.project_id }}
                  </router-link>
                  <div v-else>{{ item.project_id || '' }}</div>
                </td>
                <td>{{ item.appointment_date | formatDate('timestamp', 'MM/DD/YYYY') }}</td>
                <td>{{ item.owner_name || '' }}</td>
                <td>{{ item.verified_setter_lead || '' }}</td>
                <td :class="item.appointment_outcome_class">
                  {{ item.appointment_outcome || '' }}
                </td>
                <td>{{ item.checked_in_time | formatDate('timestamp', 'MM/DD/YYYY h:mm a') }}</td>
                <td>{{ item.date_created | formatDate('timestamp', 'MM/DD/YYYY') }}</td>
                <td>{{ item.state || '' }}</td>
                <td>{{ item.office || '' }}</td>
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
    <!------------------------------------- FUNNEL TAB END ------------------------------------>
  </v-container>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import moment from 'moment'
  import constants from '@/helpers/constants'
  import { postRequest, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import SpinnerInline from '@/components/SpinnerInline'
  import {
    getSetterAreas,
    getSetterRegions,
    getSetterDistricts,
    getSetterOffices,
    getSetterReps
  } from '@/services/dashboardService'

  export default {
    name: 'setterFunnel',
    components: {
      SpinnerInline,
    },
    data: () => ({
      snackbar: {},
      constants,
      setterPipelineLoading: false,
      repsLoading: true,
      dropdownValuesLoading: true,
      funnelDrilldownDialog: false,
      currentUserId: null,
      isSetter: false,
      isSetterMgr: false,
      isSetterRegional: false,
      headers: [
        { text: '', value: '', show: true, sortable: false },
        { text: 'Name', value: 'customer_name', show: true },
        { text: 'Project ID', value: 'id', show: true },
        { text: 'Source', value: 'source_name', show: true },
        { text: 'Appointment Date', value: 'appointment_date', show: true },
        { text: 'Appointment Outcome', value: 'appointment_outcome', show: true }
      ],
      //without these the ui keeps reloading the dropdowns when nothing has changed
      areaValuesChanged: false,
      regionValuesChanged: false,
      districtValuesChanged: false,
      officeValuesChanged: false,
      repValuesChanged: false,
      funnelStatsLoading: false,
      areaModel: [],
      areaData: [],
      regionModel: [],
      regionData: [],
      districtModel: [],
      districtData: [],
      officeModel: [],
      officeData: [],
      repModel: [],
      repData: [],
      repDataMaster: [],
      modelOverride: false,
      //if we allow users to "Select All" when there are more than this the UI slows to a halt
      maxRepLimit: 1000,
      repLengthOverride: false,
      repDataSelectAll: false,
      initialPageLoad: true,
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
        { text: 'Name', value: 'customer_name', show: true, width: 90 },
        { text: 'Project ID', value: 'project_id', show: true, width: 95 },
        { text: 'Appointment Date', value: 'appointment_date', show: true, width: 150 },
        { text: 'Closer', value: 'owner_name', show: true, width: 90 },
        { text: 'Verified Setter Lead', value: 'verified_setter_lead', show: true, width: 170 },
        { text: 'Appointment Outcome', value: 'appointment_outcome', show: true, width: 175 },
        { text: 'Checked In Time', value: 'checked_in_time', show: true, width: 175 },
        { text: 'Date Created', value: 'date_created', show: true, width: 115 },
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
      windowInnerWidth () { return window.innerWidth},
      selectAllAreas() {
        return this.areaModel.length === this.areaData.length
      },
      selectSomeAreas() {
        return this.areaModel.length > 0 && !this.selectAllAreas
      },
      areaSelectIcon() {
        if (this.areaModel.length === this.areaData.length) {
          return 'check_box'
        }
        if (this.selectSomeAreas) {
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
        return this.repModel.length === this.repData.length || this.repLengthOverride
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
      doRepWatcher() {
        // console.log('CCCC')
        if(this.repValuesChanged) {
          if (this.isSetter) {
            this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2,  false)
          } else if (this.selectAllReps) {
            this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2,  true)
          } else {
            this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2,  false)
          }
          this.repValuesChanged = false
        }
      },

      resetScrollBarPosition () {
        // reset scroll bar positioning to top
        this.$refs.setterDashContainer.scrollTop = 0
      },

      /* FUNNEL-RELATED CODE START */
      async areaLoad(preSelectLists) {
        if (!this.currentUserId) return

        await getSetterAreas(this.currentUserId, false).then(res => {
          if (res?.length > 0) {
            this.areaData = res
          }

          if (preSelectLists && (this.isSetterMgr || this.isSetterRegional)) {
            this.areaModel = this.areaData.filter(od => od.active)
          } else if (preSelectLists) {
            this.areaModel = cloneDeep(this.areaData)
          }

          // reset these values when the areas change
          this.regionModel = []
          this.districtModel = []
          this.officeModel = []
          this.repModel = []

          if (!this.initialPageLoad) {
            this.regionLoad(preSelectLists, true)
            // this.officeLoad(preSelectLists, true)
            // this.repLoad(preSelectLists, true)
          }
        })

        this.funnelStats = []
      },

      async regionLoad (preSelectLists) {
        if (!this.currentUserId) return

        let areas = this.areaModel.map(function (area) {
          return {
            area_id: area.org_id
          }
        })

        // reset these values when the regions change
        this.districtModel = []
        this.officeModel = []
        this.repModel = []

        // this.$store.commit(AppMutations.SET_LOADING, true)

        await getSetterRegions(this.currentUserId, JSON.stringify(areas)).then(res => {
          this.regionData = res

          if (preSelectLists) {
            this.regionModel = cloneDeep(this.regionData)
          }

          if (!this.initialPageLoad) {
            this.districtLoad(preSelectLists)
          }
        })

        this.funnelStats = []
        // this.$store.commit(AppMutations.SET_LOADING, false)
      },

      async districtLoad (preSelectLists) {
        if (!this.currentUserId) return

        let areas = this.areaModel.map(function (area) {
          return {
            area_id: area.org_id
          }
        })

        let regions = this.regionModel.map(function (region) {
          return {
            region_id: region.org_id
          }
        })

        // this.$store.commit(AppMutations.SET_LOADING, true)
        await getSetterDistricts(this.currentUserId, JSON.stringify(areas), JSON.stringify(regions)).then(res => {
          if (res?.length > 0) {
            this.districtData = res
          }

          if (preSelectLists) {
            this.districtModel = cloneDeep(this.districtData)
          } else {
            this.funnelDataLoaded = true
          }

          if (this.districtModel.length > 0) {
            this.officeLoad(preSelectLists)
          }

          // reset these values when the districts change
          this.officeModel = []
          this.repModel = []

          if (!this.initialPageLoad) {
            this.officeLoad(preSelectLists, true)
            // this.officeLoad(preSelectLists, true)
            // this.repLoad(preSelectLists, true)
          }
          // this.$store.commit(AppMutations.SET_LOADING, false)
        })

        this.funnelStats = []
      },

      async officeLoad (preSelectLists) {
        if (!this.currentUserId) return

        let areas = this.areaModel.map(function (area) {
          return {
            area_id: area.org_id
          }
        })

        let regions = this.regionModel.map(function (region) {
          return {
            region_id: region.org_id
          }
        })

        let districts = this.districtModel.map(function (district) {
          return {
            district_id: district.org_id
          }
        })

        // if (!this.selectAllRegions) {
        //   this.officeModel = []
        //   this.officeData = []
        //   this.repModel = []
        //   this.repData = []
        //   this.funnelStats = []
        //
        //   if (regions?.length === 0) return
        // }

        // reset these values when the offices change
        this.repModel = []
        this.repData = []

        // this.$store.commit(AppMutations.SET_LOADING, true)
        await getSetterOffices(this.currentUserId, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts)).then(res => {
          this.officeData = res

          if (preSelectLists) {
            this.officeModel = cloneDeep(this.officeData)
          }

          if (!this.initialPageLoad) {
            this.repLoad(preSelectLists)
          }
        })

        this.funnelStats = []
        // this.$store.commit(AppMutations.SET_LOADING, false)
      },

      async repLoad (preSelectLists, loadFilterOnFirstLoad) {
        //reset these any time we are reloading reps or things get weird
        this.repModel = []
        this.repData = []
        this.repLengthOverride = false

        this.repsLoading = true
        if (!this.currentUserId) return

        let areas = this.areaModel.map(function (area) {
          return {
            area_id: area.org_id
          }
        })

        let regions = this.regionModel.map(function (region) {
          return {
            region_id: region.org_id
          }
        })

        let districts = this.districtModel.map(function (district) {
          return {
            district_id: district.org_id
          }
        })

        let offices = this.officeModel.map(function (office) {
          return {
            office_id: office.org_id
          }
        })

        // if (!this.selectAllOffices) {
        //   this.repModel = []
        //   this.repData = []
        //   this.funnelStats = []
        //
        //   if (offices?.length === 0) return
        // }

        // this.$store.commit(AppMutations.SET_LOADING, true)
        await getSetterReps(this.currentUserId, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts), JSON.stringify(offices)).then(res => {
          this.repData = res
          this.repDataMaster = cloneDeep(res)

          if (preSelectLists) {
            this.repModel = cloneDeep(this.repData)
          }

          this.funnelStats = []

          if (!this.initialPageLoad || loadFilterOnFirstLoad) {
            this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
          }
        })

        this.dropdownValuesLoading = false
        this.initialPageLoad = false
        this.repsLoading = false
        // this.$store.commit(AppMutations.SET_LOADING, false)
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
          {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
        ]

        this.repData = [
          {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
        ]

        this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
      },

      async pipelineLoad (targetInstallations, start, end, useRepDataInstead) {
        this.setterPipelineLoading = true
        let reps = []
        let orgs = []

        if ((this.repModel.length === 0 && !useRepDataInstead) || (useRepDataInstead && this.repData.length === 0)) {
          this.funnelStats = []
          this.setterPipelineLoading = false
          return
        }

        this.officeModel.forEach(org => orgs.push(org.org_id))

        this.modelOverride = false
        if (useRepDataInstead) {
          this.repData.forEach((rep, index) => {
            reps.push(rep.user_position_id)

            if (index === this.repData.length - 1) {
              // this.districtModel = []
              // this.regionModel = []
              // this.officeModel = []

              if (this.repDataSelectAll && this.repDataMaster?.length > this.maxRepLimit) {
                this.modelOverride = true
                this.repModel = [
                  {user_id: -2, user_position_id: -2, name: 'All Filtered Reps', active: true}
                ]
                this.repData = [
                  {user_id: -2, user_position_id: -2, name: 'All Filtered Reps', active: true}
                ]
              }
            }
          })
        } else {
          this.repModel.forEach(rep => reps.push(rep.user_position_id))
        }

        if(this.modelOverride) {
          reps = []
          //this gets used when there are more than 1000 users selected
          this.repDataMaster.forEach(rep => reps.push(rep.user_position_id))
        }
        // this.funnelStatsLoading = true
        try {
          const requestBody = {
            targetInstallations: targetInstallations,
            users: reps,
            orgs: orgs,
            start: moment(start).format('YYYY-MM-DD'),
            end: moment(end).format('YYYY-MM-DD')
          }
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
            this.setterPipelineLoading = false
          })
        } catch (e) {
          this.setterPipelineLoading = false
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

          if ((this.repModel.length > 0) || this.repModel[0]?.user_position_id === -1) {
            this.pipelineLoad(this.expectedInstalls, this.pipeline_dt1, this.pipeline_dt2, false)
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

      async loadFunnel () {
        if (this.funnelStats?.length === 0) {
          if (this.isSetter) {
            await this.areaLoad(true)
            await this.regionLoad(true)
            await this.districtLoad(true)
            await this.officeLoad(true)
            this.repLoad(true, true)
          } else {
            await this.areaLoad(false)
            await this.regionLoad(false)
            await this.districtLoad(false)
            await this.officeLoad(false)
            this.repLoad(false, false)
          }
        }
      },

      toggleSelectAllAreas() {
        this.$nextTick(() => {
          if (this.selectAllAreas) {
            this.areaModel = []
            this.regionData = []
            this.regionModel = []
            this.districtData = []
            this.districtModel = []
            this.officeData = []
            this.officeModel = []
            this.repData = []
            this.repModel = []
          } else {
            this.areaModel = cloneDeep(this.areaData)
            this.repModel = [] // in case the user previously clicked the 'All Reps' button
            // this.regionLoad(false)
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
            // this.officeLoad(false)
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
            // this.regionLoad(false)
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
            // this.repLoad(false)
          }
        })
      },

      toggleSelectAllReps () {
        this.$nextTick(() => {
          if (this.selectAllReps) {
            this.repModel = []
            this.repLengthOverride = false
            this.funnelStats = []
          } else {
            if (this.repDataSelectAll && this.repData?.length > this.maxRepLimit) {
              //this is different than clicking the All Reps button and needs to be filtered.
              // -2 was updated to mean - select all reps in the selected orgs
              this.repLengthOverride = true
              this.repModel = [
                {user_id: -2, user_position_id: -2, name: 'All Filtered Reps', active: true}
              ]
              this.doRepWatcher()
            } else {
              this.repModel = cloneDeep(this.repData)
              this.doRepWatcher()
            }
          }
        })
      },

      async funnelDrilldown (funnelId, dateRange, funnelName) {
        let reps = []
        let orgs = []
        let start, end
        reps = this.modelOverride ? this.repDataMaster.map(rep => rep.user_position_id) : this.repModel.map(rep => rep.user_position_id)
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

      filteredFunnelDrilldownItems (filteredItems) {
        this.filteredFunnelDrilldownData = filteredItems
        this.funnelDrilldownRowCount = filteredItems.length
      },

      closeFunnelDrilldownDialog () {
        this.funnelDrilldownDialog = false
        this.resetScrollBarPosition()
      }
      /* FUNNEL-RELATED CODE END */
    },
    async created () {
      this.currentUserId = this.$store.state.user.details.id
      let userPositions = this.$store.state.user.details.userPositions

      if (userPositions?.length > 0) {
        this.userOfficeId = userPositions.filter(position => position.primaryFlag && !position.endDate)[0].orgId
        this.userOffice = userPositions.filter(position => position.orgId === this.userOfficeId)[0].hierarchy.filter(orgLevel => orgLevel.orgId === this.userOfficeId)[0].orgName
        this.isSetter = userPositions.filter(position => (position.positionId === 4) && !position.endDate && !position.archived && position.primaryFlag).length > 0
        this.isSetterMgr = userPositions.filter(position => (position.positionId === 5) && !position.endDate && !position.archived && position.primaryFlag).length > 0
        this.isSetterRegional = userPositions.filter(position => (position.positionId === 6) && !position.endDate && !position.archived && position.primaryFlag).length > 0
      }

      await this.loadFunnel()
    },
    mounted () {
      //vuetify selects/autocompletes have a bug with the select all feature being used at the same time as the @blur event
      //the @blur event should only be called when the menu is closed, but in a select all it is called when the select all button is clicked. wreaks havoc.
      //this sucks but fixes that issue re: https://github.com/vuetifyjs/vuetify/issues/11488
      this.myDynamicAreaWatcher = this.$watch(
        () => this.$refs.areaSelect.isMenuActive,
        (val) => {
          // if val is false = blur aka the menu is being closed. true = menu is being opened
          if (!val) {
            if (this.areaValuesChanged) {
              // reset these values when the districts change
              this.regionModel = []
              this.officeModel = []
              this.repModel = []
              this.repDataSelectAll = false
              this.regionLoad(false)
              // this.officeLoad(false)
              // this.repLoad(false)
              this.areaValuesChanged = false
            }
          }
        })
      this.myDynamicRegionWatcher = this.$watch(
        () => this.$refs.regionSelect.isMenuActive,
        (val) => {
          // if val is false = blur aka the menu is being closed. true = menu is being opened
          if (!val) {
            if (this.regionValuesChanged) {
              // reset these values when the regions change
              this.districtModel = []
              this.officeModel = []
              this.repModel = []
              this.repDataSelectAll = false
              this.districtLoad(false)
              // this.repLoad(false)
              this.regionValuesChanged = false
            }
          }
        })
      this.myDynamicDistrictWatcher = this.$watch(
        () => this.$refs.districtSelect.isMenuActive,
        (val) => {
          // if val is false = blur aka the menu is being closed. true = menu is being opened
          if (!val) {
            if (this.districtValuesChanged) {
              // reset these values when the districts change
              this.officeModel = []
              this.repModel = []
              this.repDataSelectAll = false
              this.officeLoad(false)
              // this.officeLoad(false)
              // this.repLoad(false)
              this.districtValuesChanged = false
            }
          }
        })
      this.myDynamicOfficeWatcher = this.$watch(
        () => this.$refs.officeSelect.isMenuActive,
        (val) => {
          // if val is false = blur aka the menu is being closed. true = menu is being opened
          if (!val) {
            if (this.officeValuesChanged) {
              // reset these values when the offices change
              this.repModel = []
              this.repDataSelectAll = false
              this.repLoad(false)
              this.officeValuesChanged = false
            }
          }
        })
      this.myDynamicRepWatcher = this.$watch(
        () => this.$refs.repSelect.isMenuActive,
        (val) => {
          // if val is false = blur aka the menu is being closed. true = menu is being opened
          if (!val && this.repModel.length > 0) {
            this.doRepWatcher()
          }
        })
    },
  }
</script>

<style lang="scss" scoped>
.funnel-relative {
  position: relative;
}

.funnel-spinner {
  position: absolute;
  //height: 200px !important;
  height: 100% !important;
  width: 100%;
  text-align: center;
  opacity: .6;
  background: white;
  display: flex;
  align-items: center;
  z-index: 1000;
}

  .align-items-center {
    align-items: center;
  }

  .align-items-flex-start {
    align-items: flex-start;
  }

  .align-items-flex-end {
    align-items: flex-end;
  }

  #setter-dash-container {
    font-family: 'Roboto Condensed', sans-serif !important;
    letter-spacing: 0.02em !important;
    overflow: auto;
  }

  #setter-dash-container.incentive-tab-override {
    padding: 0 !important;

    #setter-dash-toolbar-container {
      margin: 0 !important;

      #setter-dash-toolbar {
        padding: 0 !important;
      }
    }
  }

  #setter-dash-toolbar-container {
    #setter-dash-toolbar {
      header {
        background-color: #fff !important;
      }

      #setter-dash-title-container ::v-deep .v-toolbar__content {
        width: 100%;

        .v-toolbar__title {
          font-size: 13px;
        }
      }

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

  #setter-dash-tabs.incentive-tab-overrides {
    position: relative;
    z-index: 1;
    color: #fff;
    margin-bottom: -30px !important;
    padding-top: 8px;
    padding-right: 15px;

    .tab-separator {
      border-color: #fff;
    }
  }

  #incentive-container {
    background: black url("../../../assets/blueraven/title_pilot.jpg") no-repeat fixed center;
    background-size: cover;
    display: flex;
    flex-flow: column nowrap;
    align-items: center;

    #incentive-banner {
      padding-top: 15px;
      margin-bottom: -50px;
      width: 100%;
      max-width: 350px;
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
        font-size: 12px;
        font-weight: bold;
        width: 220px;
      }

      .milestone-bottom-label {
        display: inline-block;
        text-align: center;
        color: #fff;
        font-size: 10px;
        margin-top: 3px;
        width: 220px;
      }

      .milestone-content {
        cursor: pointer;
        border: 3px solid white;
        display: flex;
        flex-flow: row nowrap;
        padding: 5px;
        width: 220px;
        height: 110px;

        .milestone-content-left-side {
          align-self: center;
          width: 50%;
          height: 80%;
        }

        .milestone-content-right-side {
          display: flex;
          flex-flow: column nowrap;
          width: 50%;

          .milestone-top-right-label {
            color: white;
            text-align: right;
            font-size: 10px;
          }

          .milestone-stars-container {
            display: flex;
            flex-flow: row wrap;
            justify-content: center;
            align-items: center;
            align-content: center;
            width: 100%;
            height: 70%;

            .milestone-star {
              font-size: 22px;
              color: rgba(255, 255, 255, 0.3) !important;
              text-shadow: 0 0 0 rgba(255, 255, 255, 0.5);
              background: #222 -webkit-gradient(linear, left top, right top, from(#222), to(#222), color-stop(0.5, #fff)) 0 0 no-repeat;
              background-size: 25px;
              -webkit-background-clip: text;
              animation-name: shine;
              animation-duration: 5s;
              animation-iteration-count: infinite;
            }

            @keyframes shine {
              0% {
                background-position-x: -50px;
              }
              100% {
                background-position-x: 50px;
              }
            }

            .three-stars-padding-override {
              padding: 0 20px;
            }
          }

          .four-stars-padding-override {
            padding: 0 20px;
          }

          .five-stars-padding-override {
            padding: 0 10px;
          }
        }
      }
    }

    .active-milestone {
      .milestone-top-label,
      .milestone-bottom-label {
        width: 260px;
      }

      .milestone-top-label {
        font-size: 13px;
      }

      .milestone-bottom-label {
        font-weight: bold;
        font-size: 11px;
      }

      .milestone-content {
        border: 3px solid white;
        width: 260px;
        height: 130px;

        .milestone-content-right-side {
          .milestone-top-right-label {
            font-weight: bold;
            font-size: 11px;
          }

          .milestone-stars-container {
            .milestone-star {
              font-size: 28px;
            }

            .three-stars-padding-override {
              padding: 0 20px;
            }
          }

          .four-stars-padding-override {
            padding: 0 20px;
          }

          .five-stars-padding-override {
            padding: 0 10px;
          }
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
  }

  .no-medal {
    background: url('../../../assets/blueraven/no_medal_icon_white.svg') no-repeat scroll center;
    background-size: contain;
  }

  .a-10-level {
    background: url('../../../assets/blueraven/a10_warthog.png') no-repeat scroll center;
    background-size: contain;
  }

  .f-14-level {
    background: url('../../../assets/blueraven/f14_tomcat.png') no-repeat scroll center;
    background-size: contain;
  }

  .fa-18-level {
    background: url('../../../assets/blueraven/fa18_hornet.png') no-repeat scroll center;
    background-size: contain;
  }

  .f-22-level {
    background: url('../../../assets/blueraven/f22_raptor.png') no-repeat scroll center;
    background-size: contain;
  }

  .f-35-level {
    background: url('../../../assets/blueraven/f35_lightning.png') no-repeat scroll center;
    background-size: contain;
  }

  #progress-bar-container {
    display: flex;
    flex-flow: column nowrap;
    justify-content: space-between;
    margin: 30px auto;
    width: calc(100% - 50px);
    height: 37px;

    span {
      display: inline-block;
      text-align: left;
      font-size: 11px;
      font-weight: bold;
      color: #fff;
    }

    #progress-bar {
      display: flex;
      flex-flow: row nowrap;
      position: relative;
      border: 0.02em solid black;
      border-radius: 4px;
      height: 15px;
    }

    #progress-bar-fill {
      position: absolute;
      top: 0.02em;
      z-index: 1;
      background: linear-gradient(to right, #164761, #2C8EC2);
      transition: width 1s ease-out;
      opacity: 0.9;
      border-radius: 4px 0 0 4px;
      width: 0;
      height: 14px;
    }

    .progress-bar-segment {
      background-color: #D8D8D8;
      border: 0.02em solid black;
      width: 11.11%;
    }

    #first-segment {
      border-radius: 4px 0 0 4px;
      border: 0.03em solid black;
    }

    #ninth-segment {
      text-align: center;
      border-radius: 0 4px 4px 0;
      border: 0.03em solid black;
    }
  }

  #milestone-medals-container {
    display: flex;
    flex-flow: row nowrap;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 30px;
    width: 60%;
    height: 50px;

    .milestone-medal {
      width: 18%;
      min-height: 100%;
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
    ::v-deep .v-data-table__wrapper {
      max-height: calc(100vh - 250px);
    }

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
      border-radius: 4px;
      padding: 5px 10px;
      margin: 5px 0;
      width: 100%;
      height: 130px;
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
      border-radius: 4px;
      padding: 5px 10px;
      margin: 5px 0;
      width: 100%;
      height: 130px;

      #rank-box-left-side {
        display: flex;
        flex-flow: column nowrap;
        align-items: center;
        padding-top: 5px;
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
    }

    #setter-ranking-tables-left-col {
      margin-top: 5px;

      .ranking-table {
        margin-bottom: 10px;
      }
    }

    #setter-ranking-tables-right-col {
      .ranking-table {
        margin-bottom: 150px;
      }
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
    border-radius: 4px;
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
    border-radius: 4px;
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
        border-spacing: 0;
        border-bottom-left-radius: 4px;
        border-bottom-right-radius: 4px;
        overflow: hidden;
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
      ::v-deep .v-data-table__wrapper {
        max-height: calc(100vh - 300px);
      }

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
    #setter-dash-toolbar-container {
      #setter-dash-toolbar {
        #setter-dash-title-container {
          margin: 0 auto;

          ::v-deep .v-toolbar__content {
            .v-toolbar__title {
              font-size: 18px;
            }
          }
        }

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

    #setter-dash-tabs {
      margin: 0 auto;

      .col-12 span {
        font-size: 12px;
      }
    }

    #setter-dash-tabs.incentive-tab-overrides {
      margin-bottom: -41px !important;
    }

    #incentive-container {
      background: black url("../../../assets/blueraven/title_pilot.jpg") no-repeat scroll center -50px;
      background-size: cover;

      #incentive-banner {
        margin-bottom: -80px;
        max-width: 673px;
      }
    }

    #milestones-container {
      flex-flow: row wrap;
      margin: 0 auto;
      width: calc(100% - 110px);

      .milestone {
        margin-top: 0;
        margin-bottom: 10px;
        width: 300px;

        .milestone-top-label,
        .milestone-bottom-label {
          width: 200px;
        }

        .milestone-top-label {
          font-size: 14px;
        }

        .milestone-bottom-label {
          font-size: 13px;
        }

        .milestone-content {
          width: 200px;
          height: 130px;

          .milestone-content-right-side {
            .milestone-top-right-label {
              font-size: 12px;
            }

            .milestone-stars-container {
              .milestone-star {
                font-size: 26px;
              }

              .three-stars-padding-override {
                padding: 0 10px;
              }
            }

            .four-stars-padding-override {
              padding: 0 10px;
            }

            .five-stars-padding-override {
              padding: 0;
            }
          }
        }
      }

      .active-milestone {
        .milestone-top-label,
        .milestone-bottom-label {
          width: 240px;
        }

        .milestone-top-label {
          font-size: 15px;
        }

        .milestone-bottom-label {
          font-size: 14px;
        }

        .milestone-content {
          width: 240px;
          height: 160px;

          .milestone-content-left-side {
            height: 100%;
          }

          .milestone-content-right-side {
            .milestone-top-right-label {
              font-size: 13px;
            }

            .milestone-stars-container {
              .milestone-star {
                font-size: 32px;
              }

              .three-stars-padding-override {
                padding: 0 10px;
              }
            }

            .four-stars-padding-override {
              padding: 0 10px;
            }

            .five-stars-padding-override {
              padding: 0;
            }
          }
        }
      }
    }

    #progress-bar-container {
      width: calc(100% - 110px);

      #progress-bar {
        height: 20px;
      }

      #progress-bar-fill {
        height: 19px;
      }
    }

    #milestone-medals-container {
      width: 50%;
      height: 60px;
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
        height: 150px;
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
        height: 150px;

        #rank-box-right-side {
          padding-top: 5px;

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
          font-size: 14px;
        }
      }

      #setter-ranking-tables-left-col {
        .ranking-table {
          margin-bottom: 30px;
        }
      }

      #setter-ranking-tables-right-col {
        .ranking-table {
          margin-bottom: 180px;
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
    #setter-dash-toolbar-container {
      #setter-dash-toolbar {
        #setter-dash-title-container {
          ::v-deep .v-toolbar__content {
            .v-toolbar__title {
              font-size: 20px;
            }
          }
        }

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

    #setter-dash-tabs .col-12 span {
      font-size: 13px;
    }

    #milestones-container {
      width: 65%;

      .milestone {
        margin-bottom: 0;
      }

      #aim-high-phase,
      #fly-phase {
        margin-bottom: 20px;
      }
    }

    #progress-bar-container {
      width: 65%;
      height: 42px;
    }

    #milestone-medals-container {
      width: 45%;
      max-width: 650px;
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
        height: 170px;
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
        height: 170px;

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
    #incentive-container {
      #incentive-banner {
        margin-top: -29px;
        margin-bottom: -90px;
      }
    }

    #milestones-container {
      flex-flow: row nowrap;
      width: 75%;
      max-width: 1000px;

      #aim-high-phase,
      #fly-phase {
        margin-bottom: 0;
      }

      .milestone {
        width: 250px;

        .milestone-top-label,
        .milestone-bottom-label {
          width: 185px;
        }

        .milestone-content {
          width: 185px;
          height: 120px;
        }
      }

      .active-milestone {
        .milestone-top-label,
        .milestone-bottom-label {
          width: 210px;
        }

        .milestone-content {
          width: 210px;
          height: 140px;
        }
      }
    }

    #progress-bar-container {
      width: 75%;
      max-width: 1000px;
    }

    #personal-performance-boxes-container {
      max-width: 1130px;

      #personal-performance-rank-box {
        #rank-box-left-side {
          padding-top: 23px;
        }

        #rank-box-right-side {
          padding-top: 21px;
        }
      }
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

  @media(min-width: 1410px) {
    #incentive-container {
      height: calc(100vh - 106px);

      #incentive-banner {
        margin-top: -29px;
        margin-bottom: -90px;
      }
    }
  }
</style>

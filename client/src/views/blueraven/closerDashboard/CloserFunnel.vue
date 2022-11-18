<template>
  <v-container id="closer-dash-container" ref="closerDashContainer">
    <!---------------------------------- FUNNEL TAB START ---------------------------------->
    <!-- APPOINTMENTS CREATED PIPELINE START -->
    <!--    1: {{this.showFunnels}}-->
    <!--    2: {{this.apptsCreatedPipelineLoaded}}-->
    <!--    3: {{this.apptsToFdcPipelineLoaded}}-->
    <!--    4: {{this.showDashboard}}-->
    <!--    5: {{this.rankingTablesLoaded}}-->
    <!--    6: {{this.showIncentive}}-->
    <!--    7: {{this.incentiveDataLoaded}}-->

    <div id="appts-created-pipeline-container" class="mb-8" v-if="userCanViewAllProjects">
      <div class="pipeline-header-container">
        <div class="pipeline-title albatross-header-2">Appointments Created Pipeline</div>
      </div>

      <!-- FUNNEL -->
      <div class="funnel-container">
        <div v-if="apptsCreatedPipelineDataLoading" class="pipeline-data-loading-container">
          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
        </div>
        <div v-if="apptsCreatedPipelineData.length > 0" id="appts-created-pipeline-funnel-background"
             :style="{'margin-top': showApptsCreatedPipelineCustomDates && windowInnerWidth < 1135 ? '77px' :
                                 showApptsCreatedPipelineCustomDates && windowInnerWidth >= 1135 ? '83px' : '59px'}"></div>
        <table class="funnel-table" v-if="apptsCreatedPipelineData.length > 0">
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
                                  readonly outlined dense hide-details v-on="on"></v-text-field>
                  </template>
                  <v-date-picker v-model="appts_created_pipeline_dt1" :max="appts_created_pipeline_dt2"
                                 @input="updateApptsCreatedPipelineCalendar"></v-date-picker>
                </v-menu>
                <span class="custom-date-span">-</span>
                <v-menu v-model="appts_created_pipeline_menu2" transition="scale-transition" offset-y
                        min-width="290px" :close-on-content-click="false">
                  <template v-slot:activator="{ on }">
                    <v-text-field class="custom-date-input" v-model="appts_created_pipeline_dt2_formatted"
                                  readonly outlined dense hide-details v-on="on"></v-text-field>
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
                  <v-btn v-on="on" class="custom-dates-btn">{{ apptsCreatedPipelineDateRange.label }}
                    <v-icon>mdi-menu-down</v-icon>
                  </v-btn>
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
            <td class="funnel-td funnel-line-name">{{ line.name }}</td>
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
                        return-object
                        @input="apptsCreatedPipelineLoad(appts_created_pipeline_dt1, appts_created_pipeline_dt2)">
                <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="grey--text text-caption">
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
                        return-object
                        @input="apptsCreatedPipelineLoad(appts_created_pipeline_dt1, appts_created_pipeline_dt2)">
                <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="grey--text text-caption">
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
            <td class="funnel-td" @click="funnelDrilldown(line, 'today', 'apptsCreatedPipeline', false)">
              {{ line.today_count }}
            </td>
            <td class="funnel-td" @click="funnelDrilldown(line, 'wtd', 'apptsCreatedPipeline', false)">
              {{ line.week_to_date_count }}
            </td>
            <td class="funnel-td" @click="funnelDrilldown(line, 'custom', 'apptsCreatedPipeline', false)">
              {{ line.custom_date_range_count }}
            </td>
          </tr>
        </table>
      </div>
    </div>
    <!-- APPOINTMENTS CREATED PIPELINE END -->

    <!-- APPOINTMENTS TO FDC PIPELINE START -->
    <div class="funnel-relative">
      <div v-if="dropdownValuesLoading || apptsToFdcPipelineDataLoading" class="funnel-spinner">
        <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
      </div>
      <div id="appts-to-fdc-pipeline-container" :class="{'mb-8': apptsToFdcPipelineData.length > 0}">
        <div class="pipeline-header-container">
          <div id="pipeline-header-left-side">
            <div class="pipeline-title albatross-header-2">Appointments to FDC Pipeline</div>
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

            <v-autocomplete class="appts-to-fdc-pipeline-dropdown"
                            v-model="regionModel"
                            :items="regionData"
                            item-text="org_name"
                            item-value="org_id"
                            label="Region"
                            no-data-text="No regions available"
                            outlined
                            multiple
                            dense
                            @input="regionValuesChanged = true"
                            hide-details
                            return-object
                            ref="regionSelect">
              <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="grey--text text-caption">
                {{ regionModel.length }} Checked
              </span>
              </template>
              <template v-if="regionData.length > 0" v-slot:prepend-item>
                <v-list-item @click="[regionValuesChanged = true, toggleSelectAllRegions()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ regionSelectIcon }}</v-icon>
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

            <v-autocomplete class="appts-to-fdc-pipeline-dropdown"
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
                            hide-details
                            @input="districtValuesChanged = true"
                            return-object>
              <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="grey--text text-caption">
                {{ districtModel.length }} Checked
              </span>
              </template>
              <template v-if="districtData.length > 0" v-slot:prepend-item>
                <v-list-item @click="[districtValuesChanged = true, toggleSelectAllDistricts()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ districtSelectIcon }}</v-icon>
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

            <v-autocomplete class="appts-to-fdc-pipeline-dropdown"
                            v-model="officeModel"
                            :items="officeData"
                            item-text="org_name"
                            item-value="org_id"
                            label="Office"
                            no-data-text="No offices available"
                            outlined
                            multiple
                            dense
                            @input="officeValuesChanged = true"
                            hide-details
                            return-object
                            ref="officeSelect">
              <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="grey--text text-caption">
                {{ officeModel.length }} Checked
              </span>
              </template>
              <template v-if="officeData.length > 0" v-slot:prepend-item>
                <v-list-item @click="[officeValuesChanged = true, toggleSelectAllOffices()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ officeSelectIcon }}</v-icon>
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
            <v-autocomplete class="appts-to-fdc-pipeline-dropdown"
                            v-model="repModel"
                            :items="repData"
                            item-text="name"
                            item-value="user_position_id"
                            label="Rep"
                            no-data-text="No reps available"
                            outlined
                            multiple
                            dense
                            @input="repValuesChanged = true"
                            hide-details
                            return-object
                            ref="repSelect">
              <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="grey--text text-caption">
                {{ repModel.length }} Checked
              </span>
              </template>
              <template v-if="repData.length > 0" v-slot:prepend-item>
                <v-list-item
                  @click="[repValuesChanged = true, repDataSelectAll = !repDataSelectAll, toggleSelectAllReps()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ repSelectIcon }}</v-icon>
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
                    {{ data.item.name }}
                  </v-list-item-title>
                </v-list-item-content>
              </template>
            </v-autocomplete>

            <v-btn v-if="!isCloser && !isCloserMgr" id="all-reps-btn" outlined color="primary" @click="funnelAllReps">
              All Reps
            </v-btn>
          </div>
        </div>

        <!-- FUNNEL -->
        <div class="funnel-container">
          <!-- FUNNEL BACKGROUND -->
          <div v-show="apptsToFdcPipelineData.length > 0" id="appts-to-fdc-pipeline-funnel-background"
               :style="{'margin-top': showApptsToFdcPipelineCustomDates && windowInnerWidth >= 1135 ? '87px' :
                                 showApptsToFdcPipelineCustomDates ? '82px' : windowInnerWidth <= 1070 ? '60px' : '' }"></div>

          <!-- TODAY PERCENTAGE LINES -->
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="today-upper-percentage-line" class="upper-percentage-line"></div>
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="today-lower-percentage-line" class="lower-percentage-line"></div>
          <!-- TODAY PERCENTAGES -->
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="today-upper-percentage" class="upper-percentage">{{ todayUpperPercentage }}%
          </div>
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="today-lower-percentage" class="lower-percentage">{{ todayLowerPercentage }}%
          </div>

          <!-- WTD PERCENTAGE LINES -->
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="wtd-upper-percentage-line" class="upper-percentage-line"></div>
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="wtd-lower-percentage-line" class="lower-percentage-line"></div>
          <!-- WTD PERCENTAGES -->
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="wtd-upper-percentage" class="upper-percentage">{{ wtdUpperPercentage }}%
          </div>
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="wtd-lower-percentage" class="lower-percentage">{{ wtdLowerPercentage }}%
          </div>

          <!-- CUSTOM DATE RANGE PERCENTAGE LINES -->
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="cdr-upper-percentage-line" class="upper-percentage-line"></div>
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="cdr-lower-percentage-line" class="lower-percentage-line"></div>
          <!-- CUSTOM DATE RANGE PERCENTAGES -->
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="cdr-upper-percentage" class="upper-percentage">{{ cdrUpperPercentage }}%
          </div>
          <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"
               id="cdr-lower-percentage" class="lower-percentage">{{ cdrLowerPercentage }}%
          </div>

          <table class="funnel-table">
            <!-- FUNNEL COLUMN HEADERS -->
            <tr class="funnel-tr">
              <th class="funnel-th view-btns">
                <div class="view-btns-container">
                  <v-btn class="funnel-btn black--text" @click="viewSelected('standard')"
                         :class="{'white--text': viewSelect === 'standard', 'primary--text': viewSelect !== 'standard', 'elevation-2': viewSelect !== 'standard'}"
                         :color="viewSelect === 'standard' ? 'primary' : 'secondary'">
                    Standard View
                  </v-btn>
                  <v-btn class="funnel-btn black--text" @click="viewSelected('apptDateCohort')"
                         :class="{'white--text': viewSelect === 'apptDateCohort', 'primary--text': viewSelect !== 'apptDateCohort', 'elevation-2': viewSelect !== 'apptDateCohort'}"
                         :color="viewSelect === 'apptDateCohort' ? 'primary' : 'secondary'">
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
                                    outlined dense hide-details v-on="on"></v-text-field>
                    </template>
                    <v-date-picker v-model="appts_to_fdc_pipeline_dt1" :max="appts_to_fdc_pipeline_dt2"
                                   @input="updateApptsToFdcPipelineCalendar()"></v-date-picker>
                  </v-menu>
                  <span class="custom-date-span">-</span>
                  <v-menu v-model="appts_to_fdc_pipeline_menu2" transition="scale-transition" offset-y
                          min-width="290px" :close-on-content-click="false">
                    <template v-slot:activator="{ on }">
                      <v-text-field class="custom-date-input" v-model="appts_to_fdc_pipeline_dt2_formatted" readonly
                                    outlined dense hide-details v-on="on"></v-text-field>
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
                    <v-btn v-on="on" class="custom-dates-btn">{{ apptsToFdcPipelineDateRange.label }}
                      <v-icon>mdi-menu-down</v-icon>
                    </v-btn>
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
              <td class="funnel-td funnel-line-name">{{ line.name }}</td>

              <!-- TODAY COUNT -->
              <td class="funnel-td">
                <div v-if="[14,15,16,17,8].indexOf(line.id) === -1" class="funnel-data-container">
                  <!-- CHECKED-IN COUNT -->
                  <div v-if="line.id === 25" class="checked-in-column-top">Checked-in</div>
                  <div v-else-if="line.checked_in_today_count || line.checked_in_today_count === 0"
                       class="checked-in-column-center clickable"
                       :class="{'checked-in-column-line-overlap': [11,4].indexOf(line.id) !== -1}"
                       @click="funnelDrilldown(line, 'today', viewSelect, true)">
                    {{ line.checked_in_today_count }}
                  </div>
                  <div v-else class="no-checked-in-column-placeholder"></div>
                  <!--                  <div v-if="line.id === 21"-->
                  <!--                       class="checked-in-column-bottom checked-in-column-line-overlap"-->
                  <!--                       @click="funnelDrilldown(line.id, 'today', line.name, viewSelect, true)">-->
                  <!--                    {{ line.checked_in_today_count }}-->
                  <!--                  </div>-->

                  <!-- COUNT -->
                  <div @click="funnelDrilldown(line, 'today', viewSelect, false)" class="clickable">
                    {{ line.today_count }}
                  </div>
                </div>
                <div v-else class="funnel-data-container clickable">
                  <div class="no-checked-in-column-placeholder"></div>
                  <div class="clickable" @click="funnelDrilldown(line, 'today', viewSelect, false)">
                    {{ line.today_count }}
                  </div>
                </div>
              </td>

              <!-- WTD COUNT -->
              <td class="funnel-td">
                <div v-if="[14,15,16,17,8].indexOf(line.id) === -1" class="funnel-data-container">
                  <!-- CHECKED-IN COUNT -->
                  <div v-if="line.id === 25" class="checked-in-column-top">Checked-in</div>
                  <div v-else-if="line.checked_in_today_count || line.checked_in_today_count === 0"
                       class="checked-in-column-center clickable"
                       :class="{'checked-in-column-line-overlap': [11,4].indexOf(line.id) !== -1}"
                       @click="funnelDrilldown(line, 'wtd', viewSelect, true)">
                    {{ line.checked_in_today_count }}
                  </div>
                  <div v-else class="no-checked-in-column-placeholder"></div>

                  <!-- COUNT -->
                  <div @click="funnelDrilldown(line, 'wtd', viewSelect, false)" class="clickable">
                    {{ line.week_to_date_count }}
                  </div>
                </div>
                <div v-else class="funnel-data-container clickable">
                  <div class="no-checked-in-column-placeholder"></div>
                  <div class="clickable" @click="funnelDrilldown(line, 'wtd', viewSelect, false)">
                    {{ line.week_to_date_count }}
                  </div>
                </div>
              </td>


              <!-- CUSTOM DATE RANGE COUNT -->
              <td class="funnel-td">
                <div v-if="[14,15,16,17,8].indexOf(line.id) === -1" class="funnel-data-container">
                  <!-- CHECKED-IN COUNT -->
                  <div v-if="line.id === 25" class="checked-in-column-top">Checked-in</div>
                  <div v-else-if="line.checked_in_today_count || line.checked_in_today_count === 0"
                       class="checked-in-column-center clickable"
                       :class="{'checked-in-column-line-overlap': [11,4,21].indexOf(line.id) !== -1}"
                       @click="funnelDrilldown(line, 'custom', viewSelect, true)">
                    {{ line.id === 21 ? '' : line.checked_in_custom_date_range_count }}
                  </div>
                  <div v-else class="no-checked-in-column-placeholder"></div>

                  <!-- COUNT -->
                  <div @click="funnelDrilldown(line, 'custom', viewSelect, false)" class="clickable">
                    {{ line.custom_date_range_count }}
                  </div>
                </div>
                <div v-else class="funnel-data-container clickable">
                  <div class="no-checked-in-column-placeholder"></div>
                  <div class="clickable" @click="funnelDrilldown(line, 'custom', viewSelect, false)">
                    {{ line.custom_date_range_count }}
                  </div>
                </div>
              </td>
            </tr>
          </table>
        </div>
      </div>
      <!-- APPOINTMENTS TO FDC PIPELINE END -->

      <!-- FUNNEL DRILLDOWN START -->
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
              :headers="visibleFunnelDrilldownHeaders()"
              fixed-header
              :items="funnelDrilldownData"
              @current-items="filteredFunnelDrilldownItems"
              :search="funnelDrilldownSearch"
              :height="funnelDrilldownRowCount > 0 ? (constants.IS_MOBILE ? 'calc(100vh - 250px)' : 'calc(100vh - 395px)') : '105px'"
              dense
              multi-sort
              :sort-by="[]"
              :sort-desc="[]"
              :loading="funnelDrilldownLoading"
              :items-per-page="500"
              :footer-props="footerProps"
            >
              <template v-if="funnelDrilldownData.length > 0" #item="{ item, index }">
                <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]"
                    :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}">
                  <td style="text-align: center">
                    {{ index + 1 }}
                  </td>
                  <td>{{ item.owner_name || '' }}</td>
                  <td>{{ item.office || '' }}</td>
                  <td>{{ item.state || '' }}</td>
                  <td>{{ item.status_type || '' }}</td>
                  <td class="customer-name">{{ item.customer_name || '' }}</td>
                  <td>
                    <router-link text v-if="item.project_id && $store.getters.userHasFeature('PROJECTS')"
                                 :to="`/project/${item.project_id}/details`">
                      {{ item.project_id }}
                    </router-link>
                    <div v-else>{{ item.project_id || '' }}</div>
                  </td>
                  <td v-if="selectedFunnel.funnel_type_id === 1">
                    <router-link text v-if="item.project_id && item.project_process_step_id && item.project_process_step_event_id && $store.getters.userHasFeature('EVENTS')"
                                 :to="`/project/${item.project_id}/processStep/${item.project_process_step_id}/event/${item.project_process_step_event_id}`">
                      {{ item.project_process_step_event_id }}
                    </router-link>
                    <div v-else>{{ item.project_process_step_event_id || '' }}</div>
                  </td>
                  <!--                <td :class="item.stage">{{ item.stage || '' }}</td>-->
                  <td :class="item.source_name_class">{{ item.source_name || '' }}</td>
                  <td :class="item.system_size_class">{{ item.system_size || '' }}</td>
                  <td :class="item.financier_class">{{ item.financier || '' }}</td>
                  <td>{{ item.appointment_date | formatDate('timestamp', 'MM/DD/YYYY') }}</td>
                  <td>{{ item.cancelled_date | formatDate('date', 'MM/DD/YYYY') }}</td>
                  <td v-if="funnelDrilldownHeaders[13].show">
                    {{ item.date_created | formatDate('timestamp', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.appointment_outcome_class" v-if="funnelDrilldownHeaders[14].show">
                    {{ item.appointment_outcome || '' }}
                  </td>
                  <td :class="item.credit_decision_date_class" v-if="funnelDrilldownHeaders[15].show">
                    {{ item.credit_decision_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.credit_check_class" v-if="funnelDrilldownHeaders[16].show">
                    {{ item.credit_check || '' }}
                  </td>
                  <td :class="item.installation_agreement_signed_date_class"
                      v-if="funnelDrilldownHeaders[17].show">
                    {{ item.installation_agreement_signed_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.site_survey_verified_date_class"
                      v-if="funnelDrilldownHeaders[18].show">
                    {{ item.site_survey_verified_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.site_survey_completed_date_class"
                      v-if="funnelDrilldownHeaders[19].show">
                    {{ item.site_survey_completed_date | formatDate('timestamp', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.final_design_sent_to_homeowner_date_class"
                      v-if="funnelDrilldownHeaders[20].show">
                    {{ item.final_design_sent_to_homeowner_date | formatDate('timestamp', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.final_design_signed_date_class"
                      v-if="funnelDrilldownHeaders[21].show">
                    {{ item.final_design_signed_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.proof_of_homeowners_insurance_obtained_date_class"
                      v-if="funnelDrilldownHeaders[22].show">
                    {{ item.proof_of_homeowners_insurance_obtained_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.utility_bill_verified_date_class"
                      v-if="funnelDrilldownHeaders[23].show">
                    {{ item.utility_bill_verified_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.financial_agreement_signed_date_class"
                      v-if="funnelDrilldownHeaders[24].show">
                    {{ item.financial_agreement_signed_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.cash_down_payment_class"
                      v-if="funnelDrilldownHeaders[25].show">
                    {{ item.cash_down_payment | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.final_design_complete_date_class"
                      v-if="funnelDrilldownHeaders[26].show">
                    {{ item.final_design_complete_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.substantial_completion_date_class"
                      v-if="funnelDrilldownHeaders[27].show">
                    {{ item.substantial_completion_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.checked_in_time_date_class"
                      v-if="funnelDrilldownHeaders[28].show">
                    {{ item.checked_in_time | formatDate('timestamp', 'MM/DD/YYYY h:mm a') }}
                  </td>
                </tr>
              </template>
              <template v-if="showTotalSystemSize" v-slot:body.append>
                <tr id="total-system-size-row">
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td id="total-system-size-label">Total Size:</td>
                  <td>{{ totalSystemSize ? totalSystemSize : 0 }}</td>
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
            <v-btn class="white--text text-capitalize mr-4 mb-2" color="primary"
                   @click="closeFunnelDrilldownDialog">
              Close
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
    <!-- FUNNEL DRILLDOWN END -->
    <!------------------------------------- FUNNEL TAB END ------------------------------------>
  </v-container>
</template>

<script>
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import moment from 'moment'
import constants from '@/helpers/constants'
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import SpinnerInline from '@/components/SpinnerInline'
import {
  getCloserAreas,
  getCloserRegions,
  getCloserDistricts,
  getCloserOffices,
  getCloserReps
} from '@/services/dashboardService'

export default {
  name: 'closerDashboard',
  components: {
    SpinnerInline,
  },
  data() {
    return {
      snackbar: {},
      constants,
      funnelDrilldownDialog: false,
      currentUserId: null,
      currentUserOrgId: null,
      dropdownValuesLoading: true,
      isCloser: false,
      isCloserMgr: false,
      selectedFunnel: {},
      isCloserRegional: false,
      userCanViewAll: this.$store.getters.userHasFeatureAccessLevel('CLOSER_DASHBOARD', 'VIEW_ALL'),
      userCanViewAllProjects: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'VIEW_ALL'),
      headers: [
        {text: '', value: '', show: true, sortable: false},
        {text: 'Name', value: 'customer_name', show: true},
        {text: 'Project ID', value: 'id', show: true},
        {text: 'Source', value: 'source_name', show: true},
        {text: 'System Size', value: 'system_size', show: true},
        {text: 'Final Design Complete Date', value: 'final_design_complete_date', show: true}
      ],
      drilldownData: [],
      apptsCreatedPipelineLoaded: false,
      apptsToFdcPipelineLoaded: false,
      funnelsWereLoaded: false,
      currentQuarter: moment().quarter(),
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
      apptsCreatedPipelineDataLoading: true,
      apptsToFdcPipelineDataLoading: false,
      apptsCreatedPipelineData: [],
      apptsToFdcPipelineData: [],
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
      repDataSelectAll: false,
      apptsCreatedPipelineDateRanges: [
        {label: 'Yesterday', value: 'yesterday'},
        {label: 'Last Week', value: 'lastWeek'},
        {label: 'Month to Date', value: 'MTD'},
        {label: 'Last 60 days', value: 60},
        {label: 'Last 90 days', value: 90},
        {label: 'Year to Date', value: 'YTD'},
        {label: 'Custom', value: 'Custom'}
      ],
      apptsCreatedPipelineDateRange: {label: 'Month to Date', value: 'MTD'},
      showApptsCreatedPipelineCustomDates: false,
      apptsToFdcPipelineDateRanges: [
        {label: 'Yesterday', value: 'yesterday'},
        {label: 'Last Week', value: 'lastWeek'},
        {label: 'Month to Date', value: 'MTD'},
        {label: 'Last 60 days', value: 60},
        {label: 'Last 90 days', value: 90},
        {label: 'Year to Date', value: 'YTD'},
        {label: 'Custom', value: 'Custom'}
      ],
      initialPageLoad: true,
      //if we allow users to "Select All" when there are more than this the UI slows to a halt
      maxRepLimit: 1000,
      //without these the ui keeps reloading the dropdowns when nothing has changed
      areaValuesChanged: false,
      regionValuesChanged: false,
      districtValuesChanged: false,
      officeValuesChanged: false,
      repValuesChanged: false,
      apptsToFdcPipelineDateRange: {label: 'Month to Date', value: 'MTD'},
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
      funnelDrilldownData: [],
      funnelDrilldownLoading: false,
      funnelDrilldownSearch: '',
      filteredFunnelDrilldownData: [],
      funnelDrilldownRowCount: 0,
      totalSystemSize: 0,
      repLengthOverride: false,
      footerProps: {
        showFirstLastPage: !constants.IS_MOBILE,
        firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
        lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
        'items-per-page-options': [100, 500, 1000, 2500, 5000, 10000]
      }
    }
  },
  computed: {
    funnelDrilldownHeaders() { return [
      {text: '', value: '', show: true, sortable: false, width: 25, optional: false}, // 0
      {text: 'Owner', value: 'owner_name', show: true, width: 90, optional: false}, // 1
      {text: 'Office', value: 'office', show: true, width: 75, optional: false}, // 2
      {text: 'State', value: 'state', show: true, width: 75, optional: false}, // 3 -- new
      {text: 'Status', value: 'status_type', show: true, width: 75, optional: false}, // 4 -- new
      {text: 'Name', value: 'customer_name', show: true, width: 90, optional: false}, // 5
      {text: 'Project ID', value: 'project_id', show: true, width: 85, optional: false}, // 6
      {text: 'Event ID', value: 'project_process_step_event_id', show: this.selectedFunnel.funnel_type_id === 1, width: 85, optional: false}, // 7
      {text: 'Source', value: 'source_name', show: true, width: 85, optional: false}, // 8
      {text: 'System Size', value: 'system_size', show: true, width: 110, optional: false}, // 9
      {text: 'Financier', value: 'financier', show: true, width: 95, optional: false}, // 10
      {text: 'Appointment Date', value: 'appointment_date', show: true, width: 145, optional: false}, // 11
      {text: 'Cancelled Date', value: 'cancelled_date', show: true, width: 130, optional: false}, // 12
      {text: 'Date Created', value: 'date_created', show: false, width: 115, optional: true}, // 13
      {text: 'Appointment Outcome', value: 'appointment_outcome', show: false, width: 170, optional: true}, // 14
      {text: 'Credit Decision Date', value: 'credit_decision_date', show: false, width: 160, optional: true}, // 15
      {text: 'Credit Check', value: 'credit_check', show: false, width: 115, optional: true}, // 16
      {
        text: 'Installation Agreement Signed Date',
        value: 'installation_agreement_signed_date',
        show: false,
        width: 235,
        optional: true
      }, // 17
      {
        text: 'Site Survey Verified Date',
        value: 'site_survey_verified_date',
        show: false,
        width: 160,
        optional: true
      }, // 18
      {text: 'Site Survey Date', value: 'site_survey_completed_date', show: false, width: 155, optional: true}, // 19
      {
        text: 'FD Sent to Homeowner Date',
        value: 'final_design_sent_to_homeowner_date',
        show: false,
        width: 200,
        optional: true
      }, // 20
      {text: 'Final Design Approved', value: 'final_design_signed_date', show: false, width: 165, optional: true}, // 21
      {
        text: 'Proof of HOI Obtained Date',
        value: 'proof_of_homeowners_insurance_obtained_date',
        show: false,
        width: 200,
        optional: true
      }, // 22
      {
        text: 'Utility Bill Verified Date',
        value: 'utility_bill_verified_date',
        show: false,
        width: 175,
        optional: true
      }, // 23
      {
        text: 'Financial Agreement Signed',
        value: 'financial_agreement_signed_date',
        show: false,
        width: 195,
        optional: true
      }, // 24
      {text: 'Cash Down Payment', value: 'cash_down_payment', show: false, width: 160, optional: true}, // 25
      {text: 'Final Design Completed', value: 'final_design_complete_date', show: false, width: 160, optional: true}, // 26
      {
        text: 'Substantial Completion Date',
        value: 'substantial_completion_date',
        show: false,
        width: 175,
        optional: true
      }, // 27
      {text: 'Checked In Time', value: 'checked_in_time', show: false, width: 160, optional: true}, // 28
    ]},
    windowInnerWidth() {
      return window.innerWidth
    },
    selectAllBrsProvidedSources() {
      return this.brsProvidedSourceModel.length === this.brsProvidedSourceData.length
    },
    selectSomeBrsProvidedSources() {
      return this.brsProvidedSourceModel.length > 0 && !this.selectAllBrsProvidedSources
    },
    brsProvidedSourcesSelectIcon() {
      if (this.brsProvidedSourceModel.length === this.brsProvidedSourceData.length) {
        return 'check_box'
      }
      if (this.selectSomeBrsProvidedSources) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    selectAllSelfGenSources() {
      return this.selfGenSourceModel.length === this.selfGenSourceData.length
    },
    selectSomeSelfGenSources() {
      return this.selfGenSourceModel.length > 0 && !this.selectAllSelfGenSources
    },
    selfGenSourcesSelectIcon() {
      if (this.selfGenSourceModel.length === this.selfGenSourceData.length) {
        return 'check_box'
      }
      if (this.selectSomeSelfGenSources) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
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
    selectAllRegions() {
      return this.regionModel.length === this.regionData.length
    },
    selectSomeRegions() {
      return this.regionModel.length > 0 && !this.selectAllRegions
    },
    regionSelectIcon() {
      if (this.regionModel.length === this.regionData.length) {
        return 'check_box'
      }
      if (this.selectSomeRegions) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    selectAllDistricts() {
      return this.districtModel.length === this.districtData.length
    },
    selectSomeDistricts() {
      return this.districtModel.length > 0 && !this.selectAllDistricts
    },
    districtSelectIcon() {
      if (this.districtModel.length === this.districtData.length) {
        return 'check_box'
      }
      if (this.selectSomeDistricts) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    selectAllOffices() {
      return this.officeModel.length === this.officeData.length
    },
    selectSomeOffices() {
      return this.officeModel.length > 0 && !this.selectAllOffices
    },
    officeSelectIcon() {
      if (this.officeModel.length === this.officeData.length) {
        return 'check_box'
      }
      if (this.selectSomeOffices) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    selectAllReps() {
      return this.repModel.length === this.repData.length || this.repLengthOverride
    },
    selectSomeReps() {
      return this.repModel.length > 0 && !this.selectAllReps
    },
    repSelectIcon() {
      if (this.repModel.length === this.repData.length) {
        return 'check_box'
      }
      if (this.selectSomeReps) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    // visibleFunnelDrilldownHeaders() {
    //   return this.funnelDrilldownHeaders.filter(header => header.show === true)
    // },
    showTotalSystemSize() {
      return this.funnelDrilldownRowCount > 0
    }
  },
  watch: {
    appts_created_pipeline_dt1() {
      this.appts_created_pipeline_dt1_formatted = this.formatFunnelDate(this.appts_created_pipeline_dt1)
    },
    appts_created_pipeline_dt2() {
      this.appts_created_pipeline_dt2_formatted = this.formatFunnelDate(this.appts_created_pipeline_dt2)
    },
    appts_to_fdc_pipeline_dt1() {
      this.appts_to_fdc_pipeline_dt1_formatted = this.formatFunnelDate(this.appts_to_fdc_pipeline_dt1)
    },
    appts_to_fdc_pipeline_dt2() {
      this.appts_to_fdc_pipeline_dt2_formatted = this.formatFunnelDate(this.appts_to_fdc_pipeline_dt2)
    },
    funnelDrilldownDialog(val) {
      if (!val) {
        this.funnelDrilldownSearch = ''

        // resets the visibility of the optional headers
        this.funnelDrilldownHeaders.forEach(header => {
          if (header.optional) header.show = false
        })
      }
    },
    filteredFunnelDrilldownData() {
      this.calcTotalSystemSize()
    }
  },
  methods: {
    visibleFunnelDrilldownHeaders() {
      return this.funnelDrilldownHeaders.filter(header => header.show === true)
    },
    resetScrollBarPosition() {
      // reset scroll bar position to top
      this.$refs.closerDashContainer.scrollTop = 0
    },

    /* FUNNEL-RELATED CODE START */
    chooseApptsCreatedPipelineDateRange(dateRange) {
      if (this.showApptsCreatedPipelineCustomDates) {
        this.showApptsCreatedPipelineCustomDates = false
        // this.fixApptsCreatedFunnelTopMargin()
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
          // this.fixApptsCreatedFunnelTopMargin()
          break
        default:
          this.previousNumberOfDays('apptsCreatedPipeline', dateRange.value)
          break
      }
    },

    chooseApptsToFdcPipelineDateRange(dateRange) {
      if (this.showApptsToFdcPipelineCustomDates) {
        this.showApptsToFdcPipelineCustomDates = false
        // this.fixApptsToFdcFunnelTopMargin()

        // if (this.viewSelect === 'apptDateCohort') {
        //   this.fixApptDateCohortBlueLinePosition()
        // }
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
          // this.fixApptsToFdcFunnelTopMargin()

          // if (this.viewSelect === 'apptDateCohort') {
          //   this.fixApptDateCohortBlueLinePosition()
          // }


          break
        default:
          this.previousNumberOfDays('apptsToFdcPipeline', dateRange.value)
          break
      }
    },

    viewSelected(view) {
      if (this.viewSelect !== view) {
        this.viewSelect = view
        this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2, false)
      }
    },

    formatFunnelDate(date) {
      if (!date) return null

      return moment(date).format('M/D/YY')
    },

    parseFunnelDate(date) {
      if (!date) return null

      return moment(date, 'M/D/YY').format('YYYY-MM-DD')
    },

    async loadFunnels() {
      if (this.apptsCreatedPipelineData?.length === 0) {
        this.loadSources()
      }

      if (this.apptsToFdcPipelineData?.length === 0) {
        if (this.isCloser || this.isCloserMgr || this.isCloserRegional) {
          await this.areaLoad(true)
          await this.regionLoad(true, true)
          await this.districtLoad(true, true)
          await this.officeLoad(true, true)
          this.repLoad(true)
        } else {
          await this.areaLoad(false)
          await this.regionLoad(false, true)
          await this.districtLoad(false, true)
          await this.officeLoad(false, true)
          this.repLoad(false)
        }
      }
    },

    funnelAllReps() {
      this.areaModel = []
      this.districtModel = []
      this.regionModel = []
      this.officeModel = []

      this.repModel = [
        {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
      ]

      this.repData = [
        {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
      ]

      // this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2, false)
      this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2, false)
    },

    loadSources() {
      try {
        getRequest('/closerDashboard/getBrsProvidedSources', 'blueraven', []).then(res => {
          this.brsProvidedSourceData = res.data
          this.brsProvidedSourceModel = cloneDeep(this.brsProvidedSourceData)

          getRequest('/closerDashboard/getSelfGenSources', 'blueraven', []).then(res => {
            this.selfGenSourceData = res.data
            this.selfGenSourceModel = cloneDeep(this.selfGenSourceData)
            this.apptsCreatedPipelineLoad(this.appts_created_pipeline_dt1, this.appts_created_pipeline_dt2)
          })
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving lists of sources')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },

    async apptsCreatedPipelineLoad(start, end) {
      this.apptsCreatedPipelineLoaded = false
      let brsProvidedSources = []
      let selfGenSources = []

      this.brsProvidedSourceModel?.forEach(brsProvidedSource => {
        if (brsProvidedSource.sourceId) {
          brsProvidedSources.push(brsProvidedSource.sourceId)
        }
      })

      this.selfGenSourceModel.forEach(selfGenSource => {
        if (selfGenSource.sourceId) {
          selfGenSources.push(selfGenSource.sourceId)
        }
      })

      const requestBody = {
        brsProvidedSources: brsProvidedSources,
        selfGenSources: selfGenSources,
        start: moment(start).format('YYYY-MM-DD'),
        end: moment(end).format('YYYY-MM-DD')
      }

      this.apptsCreatedPipelineDataLoading = true
      try {
        await postRequest('/closerDashboard/funnel/apptsCreatedPipeline', requestBody, 'blueraven', []).then(res => {
          this.apptsCreatedPipelineData = orderBy(res.data, row => row.display_order)
        })

        if (this.isCloser || this.isCloserMgr || this.isCloserRegional) {
          if (this.apptsToFdcPipelineData.length > 0) {
            this.apptsCreatedPipelineLoaded = true
          }
          this.apptsCreatedPipelineDataLoading = false
        } else {
          this.apptsCreatedPipelineLoaded = true
          this.apptsCreatedPipelineDataLoading = false
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving Appointments Created Pipeline data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.apptsCreatedPipelineLoaded = true
        this.apptsCreatedPipelineDataLoading = false
      }
    },

    async apptsToFdcPipelineLoad(start, end, useRepDataInstead) {
      this.apptsToFdcPipelineLoaded = false
      this.apptsToFdcPipelineDataLoading = true
      let reps = []
      let orgs = []

      if ((this.repModel.length === 0 && !useRepDataInstead) || (useRepDataInstead && this.repData.length === 0)) {
        this.apptsToFdcPipelineData = []
        return
      }

      this.officeModel.forEach(org => orgs.push(org.org_id))

      let modelOverride = false
      if (useRepDataInstead) {
        this.repData.forEach((rep, index) => {
          reps.push(rep.user_position_id)
          if (index === this.repData.length - 1) {
            //   this.districtModel = []
            //   this.regionModel = []
            //   this.officeModel = []
            if (this.repDataSelectAll && this.repDataMaster?.length > this.maxRepLimit) {
              modelOverride = true
              this.repModel = [
                {user_id: -2, name: 'All Filtered Reps', active: true}
              ]
              this.repData = [
                {user_id: -2, name: 'All Filtered Reps', active: true}
              ]
            }
          }
        })
      } else {
        this.repModel.forEach(rep => reps.push(rep.user_position_id))
      }

      if (modelOverride) {
        reps = []
        //this gets used when there are more than 1000 users selected
        this.repDataMaster.forEach(rep => reps.push(rep.user_position_id))
      }

      const requestBody = {
        users: reps,
        orgs: orgs,
        start: moment(start).format('YYYY-MM-DD'),
        end: moment(end).format('YYYY-MM-DD')
      }

      try {
        await postRequest('/closerDashboard/funnel/' + this.viewSelect, requestBody, 'blueraven', []).then(res => {
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

          this.apptsToFdcPipelineLoaded = true
          this.apptsToFdcPipelineDataLoading = false
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving Appointments to FDC Pipeline data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.apptsToFdcPipelineLoaded = true
      }
    },

    getPercentage(numerator, denominator) {
      if (denominator !== 0) {
        return Math.round((numerator / denominator) * 100)
      } else {
        return 0
      }
    },

    async areaLoad(preSelectLists) {
      if (!this.currentUserId) return

      await getCloserAreas(this.currentUserId, false).then(res => {
        if (res?.length > 0) {
          this.areaData = res
        }

        if (preSelectLists && (this.isCloserMgr || this.isCloserRegional)) {
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


      this.apptsToFdcPipelineData = []
      this.apptsToFdcPipelineLoaded = true
    },

    async regionLoad(preSelectLists) {
      if (!this.currentUserId) return

      let areas = this.areaModel.map(function (area) {
        return {
          area_id: area.org_id
        }
      })

      // if (!this.selectAllDistricts) {
      //   this.regionModel = []
      //   this.regionData = []
      //   this.officeModel = []
      //   this.officeData = []
      //   this.repModel = []
      //   this.repData = []
      //   this.apptsToFdcPipelineData = []
      //
      //   // if (districts?.length === 0) return
      // }

      // reset these values when the regions change
      this.districtModel = []
      this.officeModel = []
      this.repModel = []


      await getCloserRegions(this.currentUserId, JSON.stringify(areas), false).then(res => {
        this.regionData = res


        if (preSelectLists && (this.isCloserMgr || this.isCloserRegional)) {
          this.regionModel = this.regionData.filter(od => od.active)
        } else if (preSelectLists) {
          this.regionModel = cloneDeep(this.regionData)
        }

        if (!this.initialPageLoad) {
          this.districtLoad(preSelectLists, true)
          // this.repLoad(preSelectLists, true)
        }
      })

      this.apptsToFdcPipelineData = []
    },

    async districtLoad(preSelectLists) {
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

      await getCloserDistricts(this.currentUserId, JSON.stringify(areas), JSON.stringify(regions), false).then(res => {
        if (res?.length > 0) {
          this.districtData = res
        }

        if (preSelectLists && (this.isCloserMgr || this.isCloserRegional)) {
          this.districtModel = this.districtData.filter(od => od.active)
        } else if (preSelectLists) {
          this.districtModel = cloneDeep(this.districtData)
        }

        // reset these values when the districts change
        // this.regionModel = []
        this.officeModel = []
        this.repModel = []

        if (!this.initialPageLoad) {
          this.officeLoad(preSelectLists, true)
          // this.officeLoad(preSelectLists, true)
          // this.repLoad(preSelectLists, true)
        }
      })


      this.apptsToFdcPipelineData = []
      this.apptsToFdcPipelineLoaded = true
    },

    async officeLoad(preSelectLists) {
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
      //   this.apptsToFdcPipelineData = []
      //
      //   // if (regions?.length === 0) return
      // }

      // reset these values when the offices change
      this.repModel = []

      await getCloserOffices(this.currentUserId, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts), false).then(res => {
        this.officeData = res

        if (preSelectLists && (this.isCloserMgr || this.isCloserRegional)) {
          this.officeModel = this.officeData.filter(od => od.active)
        } else if (preSelectLists) {
          this.officeModel = cloneDeep(this.officeData)
        }

        if (!this.initialPageLoad) {
          this.repLoad(preSelectLists, true)
        }
      })

      this.apptsToFdcPipelineData = []
      // this.repData = []
      this.repModel = []
    },

    async repLoad(preSelectLists) {
      //reset these any time we are reloading reps or things get weird
      this.repModel = []
      this.repData = []
      this.repLengthOverride = false

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
      //   this.apptsToFdcPipelineData = []
      //
      //   // if (offices?.length === 0) return
      // }

      await getCloserReps(this.currentUserId, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts), JSON.stringify(offices)).then(res => {
        this.repData = res

        this.repDataMaster = cloneDeep(res)

        if (preSelectLists) {
          this.repModel = cloneDeep(this.repData)
        }

        this.apptsToFdcPipelineData = []

        if (this.repModel.length > 0) {
          this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2, false)
        }
      })
      this.initialPageLoad = false
      this.dropdownValuesLoading = false
    },

    updateApptsCreatedPipelineCalendar() {
      this.appts_created_pipeline_menu1 = false
      this.appts_created_pipeline_menu2 = false
      this.apptsCreatedPipelineLoad(this.appts_created_pipeline_dt1, this.appts_created_pipeline_dt2)
    },

    updateApptsToFdcPipelineCalendar() {
      this.appts_to_fdc_pipeline_menu1 = false
      this.appts_to_fdc_pipeline_menu2 = false
      this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2, false)
    },

    yesterday(pipelineName) {
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

    lastWeek(pipelineName) {
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

    monthToDate(pipelineName) {
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

    previousNumberOfDays(pipelineName, days) {
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
    doRepWatcher() {
      if (this.repValuesChanged) {
        // this.repModel = cloneDeep(this.repData)
        if (this.isCloser || this.isCloserMgr || this.isCloserRegional) {
          this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2, false)
        } else if (this.selectAllReps) {
          this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2, true)
        } else {
          this.apptsToFdcPipelineLoad(this.appts_to_fdc_pipeline_dt1, this.appts_to_fdc_pipeline_dt2, false)
        }
        this.repValuesChanged = false
      }
    },
    yearToDate(pipelineName) {
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

    async funnelDrilldown(funnel, dateRange, pipelineName, isCheckedInColumn) {
      this.selectedFunnel = funnel
      let sourceIds = []
      let userIds = []
      let orgIds = []
      let start, end
      let datesMatch = false

      if (pipelineName === 'apptsCreatedPipeline') {
        let brsSourceIds = this.brsProvidedSourceModel.map(brsProvidedSource => brsProvidedSource.sourceId)
        let selfGenSourceIds = this.selfGenSourceModel.map(selfGenSource => selfGenSource.sourceId)
        if (funnel.id === 12) { // BRS-provided sources
          sourceIds = brsSourceIds
        } else if (funnel.id === 13) { // Self-gen sources
          sourceIds = selfGenSourceIds
        } else {
          sourceIds = brsSourceIds.concat(selfGenSourceIds)
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
        userIds = this.repModel.map(rep => rep.user_position_id)
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
        this.funnelDrilldownTitle = funnel.name + ' on ' + moment(start).format('M/D/YYYY')
      } else {
        this.funnelDrilldownTitle = funnel.name + ' ' + moment(start).format('M/D/YYYY') + ' - ' + moment(end).format('M/D/YYYY')
      }

      switch (funnel.id) {
        // Appointments Created Pipeline
        case 12: // BRS-provided appointments created
        case 13: // Self-gen appointments created
        case 10: // Total Appointments Created
        case 26: // Missing source
          this.funnelDrilldownHeaders[12].show = true // date_created
          break

        // Appointments to FDC Pipeline
        case 14: // Total Planned Appointments
          break
        case 15: // Cancelled in advance
        case 16: // Ineligible for solar
        case 17: // Total Eligible Planned Appointments
        case 25: // Rescheduled
        case 18: // Homeowner no show
        case 19: // Closer missed appointment
        case 20: // Turned away at the door
        case 22: // No utility bill
        case 24: // Non-dispositioned appointments
        case 23: // Yet to occur
        case 11: // Pitched
          // this.funnelDrilldownHeaders[14].show = true // appointment_outcome
          this.funnelDrilldownHeaders[14].show = true // appointment_outcome
          this.funnelDrilldownHeaders[28].show = isCheckedInColumn // check_in_time
          break
        case 9: // Credits run
          this.funnelDrilldownHeaders[14].show = true // appointment_outcome
          this.funnelDrilldownHeaders[15].show = true // credit_decision_date
          break
        case 3: // Credits passed
          this.funnelDrilldownHeaders[14].show = true // appointment_outcome
          this.funnelDrilldownHeaders[15].show = true // credit_decision_date
          this.funnelDrilldownHeaders[16].show = true // credit_check
          break
        case 4: // Bookings Complete
          this.funnelDrilldownHeaders[17].show = true // installation_agreement_signed_date
          this.funnelDrilldownHeaders[19].show = true // site_survey_completed_date
          break
        case 5: // Site Surveys Verified
          this.funnelDrilldownHeaders[18].show = true // site_survey_verified_date
          break
        case 6: // Final Designs sent to Homeowner
          this.funnelDrilldownHeaders[20].show = true // final_design_sent_to_homeowner_date
          this.funnelDrilldownHeaders[21].show = true // final_design_signed_date
          break
        case 7: // Final Designs Approved
          this.funnelDrilldownHeaders[21].show = true // final_design_signed_date
          this.funnelDrilldownHeaders[24].show = true // financial_agreement_signed_date
          this.funnelDrilldownHeaders[22].show = true // proof_of_homeowners_insurance_obtained_date
          this.funnelDrilldownHeaders[25].show = true // cash_down_payment
          this.funnelDrilldownHeaders[23].show = true // utility_bill_verified_date
          break
        case 21: // Final Designs Completed
          this.funnelDrilldownHeaders[26].show = true // final_design_complete_date
          break
        case 8: // Installations Completed
          this.funnelDrilldownHeaders[27].show = true // substantial_completion_date
          break
      }

      const requestBody = {
        start: start,
        end: end,
        funnelId: funnel.id
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
        await postRequest(`/closerDashboard/funnelDrilldown/${pipelineName}`, requestBody, 'blueraven', []).then(({data, status}) => {
          this.funnelDrilldownData = data?.length > 0 ? data : []

          if (this.funnelDrilldownData?.length > 0) {
            // for (let i = 0; i < this.funnelDrilldownData.length; i++) {
            //   this.funnelDrilldownData[i].rowNum = i + 1
            // }

            this.markMissingDrilldownData()
          }

          this.funnelDrilldownDialog = true
          handleHidingGlobalLoader(this, status)
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

    calcTotalSystemSize() {
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

    filteredFunnelDrilldownItems(filteredItems) {
      this.filteredFunnelDrilldownData = filteredItems
      this.funnelDrilldownRowCount = filteredItems.length
    },

    // goToProjectDetails (item) {
    //   this.$router.push({name: 'project', params: {id: item.project_id}})
    // },

    toggleSelectAllBrsProvidedSources() {
      this.$nextTick(() => {
        if (this.selectAllBrsProvidedSources) {
          this.brsProvidedSourceModel = []
          this.apptsCreatedPipelineData[0] = {
            id: 12,
            name: 'BRS provided appointments created',
            today_count: 0,
            week_to_date_count: 0,
            custom_date_range_count: 0
          }
        } else {
          this.brsProvidedSourceModel = cloneDeep(this.brsProvidedSourceData)
          this.apptsCreatedPipelineLoad(this.appts_created_pipeline_dt1, this.appts_created_pipeline_dt2)
        }
      })
    },

    toggleSelectAllSelfGenSources() {
      this.$nextTick(() => {
        if (this.selectAllSelfGenSources) {
          this.selfGenSourceModel = []
          this.apptsCreatedPipelineData[1] = {
            id: 13,
            name: 'Self-gen appointments created',
            today_count: 0,
            week_to_date_count: 0,
            custom_date_range_count: 0
          }
        } else {
          this.selfGenSourceModel = cloneDeep(this.selfGenSourceData)
          this.apptsCreatedPipelineLoad(this.appts_created_pipeline_dt1, this.appts_created_pipeline_dt2)
        }
      })
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
          this.apptsToFdcPipelineData = []
        } else {
          this.areaModel = cloneDeep(this.areaData)
          this.repModel = [] // in case the user previously clicked the 'All Reps' button
          // this.regionLoad(false)
        }
      })
    },

    toggleSelectAllRegions() {
      this.$nextTick(() => {
        if (this.selectAllRegions) {
          this.regionModel = []
          this.officeData = []
          this.officeModel = []
          this.repData = []
          this.repModel = []
          this.apptsToFdcPipelineData = []
        } else {
          this.regionModel = cloneDeep(this.regionData)
          // this.officeLoad(false)
        }
      })
    },

    toggleSelectAllDistricts() {
      this.$nextTick(() => {
        if (this.selectAllDistricts) {
          this.districtModel = []
          this.regionData = []
          this.regionModel = []
          this.officeData = []
          this.officeModel = []
          this.repData = []
          this.repModel = []
          this.apptsToFdcPipelineData = []
        } else {
          this.districtModel = cloneDeep(this.districtData)
          // this.repModel = [] // in case the user previously clicked the 'All Reps' button
          // this.regionLoad(false)
        }
      })
    },

    toggleSelectAllOffices() {
      this.$nextTick(() => {
        if (this.selectAllOffices) {
          this.officeModel = []
          this.repData = []
          this.repModel = []
          this.apptsToFdcPipelineData = []
        } else {
          this.officeModel = cloneDeep(this.officeData)
          // this.repLoad(false)
        }
      })
    },

    toggleSelectAllReps() {
      this.$nextTick(() => {
        if (this.selectAllReps) {
          this.repModel = []
          this.repLengthOverride = false
          this.apptsToFdcPipelineData = []
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
          }
        }
      })
    },

    closeFunnelDrilldownDialog() {
      this.funnelDrilldownDialog = false
      this.resetScrollBarPosition()
    }
    /* FUNNEL-RELATED CODE END */
  },
  async created() {
    this.currentUserId = this.$store.state.user.details.id

    if (this.$store.state.user.details.userPositions?.length > 0) {
      let positionId = null

      this.isCloser = this.$store.state.user.details.userPositions.filter(position => {
        return (position.positionId === 1 && !position.endDate && !position.archived && position.primaryFlag)
      }).length > 0

      this.isCloserMgr = this.$store.state.user.details.userPositions.filter(position => {
        return (position.positionId === 2 && !position.endDate && !position.archived && position.primaryFlag)
      }).length > 0

      this.isCloserDistrictMgr = this.$store.state.user.details.userPositions.filter(position => {
        return (position.positionId === 517 && !position.endDate && !position.archived && position.primaryFlag)
      }).length > 0

      let fakeCloserMgr = this.$store.state.user.details.userPositions.filter(position => {
        return (position.positionId === 326 && !position.endDate && !position.archived && position.primaryFlag)
      }).length > 0

      this.isCloserRegional = this.$store.state.user.details.userPositions.filter(position => {
        return (position.positionId === 3 && !position.endDate && !position.archived && position.primaryFlag)
      }).length > 0

      if (this.isCloser) {
        positionId = 1
      } else if (this.isCloserMgr) {
        positionId = 2
      } else if (this.isCloserDistrictMgr) {
        positionId = 517
      } else if (this.isCloserRegional) {
        positionId = 3
      } else if (fakeCloserMgr) {
        positionId = 326
      }

      if (this.isCloser || this.isCloserMgr || this.isCloserDistrictMgr || this.isCloserRegional) {
        this.currentUserOrgId = this.$store.state.user.details.userPositions.filter(position => {
          return (position.positionId === positionId && !position.endDate && !position.archived && position.primaryFlag)
        })[0]?.orgId
      }

      if (fakeCloserMgr || this.isCloserDistrictMgr) {
        this.isCloserMgr = true
      }
    }

    await this.loadFunnels()
    this.funnelsWereLoaded = true
  },
  mounted() {

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

#closer-dash-container {
  letter-spacing: 0.02em !important;
  overflow: auto;
}

.pipeline-data-loading-container {
  height: 225px;
}

#closer-dash-container.incentive-tab-override {
  padding: 0 !important;

  #closer-dash-toolbar-container {
    margin: 0 !important;

    #closer-dash-toolbar {
      padding: 0 !important;
    }
  }
}

#closer-dash-toolbar-container {
  #closer-dash-toolbar {
    header {
      background-color: #fff !important;
    }

    #closer-dash-title-container ::v-deep .v-toolbar__content {
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
      border-right: 1px solid var(--v-primary-base);
    }
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
  border-radius: 4px;
  width: 100%;

  .pipeline-header-container {
    display: flex;
    flex-flow: row nowrap;
    align-items: center;
    border-bottom: 1px solid var(--v-primary-base);
    padding: 5px;
    width: 100%;

    .pipeline-icon {
      color: var(--v-primary-base) !important;
      font-size: 24px;
    }

    .pipeline-title {
      margin-left: 8px;
    }
  }

  .appts-created-pipeline-dropdown {
    transform: scale(0.875);
    margin: 0 auto 12px auto;
    width: 110px;

    ::v-deep {
      .v-input__control {
        height: 25px;
      }

      label {
        color: #888 !important;
      }

      i {
        color: #888 !important;
        font-size: 16px;
      }

      .v-select__selections span {
        font-size: 10px !important;
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
        background-color: var(--v-primary-lighten8);
        font-weight: bold;
        padding: 5px;
      }

      .blue-sub-row {
        background-color: var(--v-primary-lighten9);
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
          }
        }

        .custom-date-span {
          margin: 0 2px 3px 2px;
        }
      }

      .funnel-th {
        padding: 2px;
        color: var(--v-grey-darken2);
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
  border-radius: 4px;
  width: 100%;

  .pipeline-header-container {
    display: flex;
    flex-flow: row wrap;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid var(--v-primary-base);
    padding: 5px 5px 0 5px;
    width: 100%;

    .pipeline-icon {
      color: var(--v-primary-base) !important;
      font-size: 24px;
    }

    .pipeline-title {
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

          .v-select__selections span {
            font-size: 10px !important;
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
        background-color: var(--v-primary-lighten8);
        font-weight: bold;
        padding: 5px;

        .funnel-line-name {
          padding-left: 5px !important;
        }
      }

      .blue-sub-row {
        background-color: var(--v-primary-lighten9);
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

        .funnel-btn.primary {
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
          }
        }

        .custom-date-span {
          margin: 0 2px 3px 2px;
        }
      }

      .funnel-th {
        color: var(--v-grey-darken2);
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
        text-align: center;
        font-size: 7px;
        width: 90px;
      }

      .funnel-count {
        cursor: pointer;
      }

      .funnel-data-container {
        display: flex;
        flex-flow: row nowrap;
        align-items: center;
        padding: 0 5px;
        width: 90px;
      }

      .checked-in-column-top,
      .checked-in-column-center,
      .checked-in-column-bottom {
        background-color: var(--v-grey-lighten1);
        border: 1px solid #fff;
        font-weight: normal;
        text-align: center;
        margin-right: 5px;
        width: 38px;
      }

      .no-checked-in-column-placeholder{
        text-align: center;
        margin-right: 5px;
        width: 38px;
      }


      //.weird-placeholder {
      //  margin-left: 60px;
      //}

      .checked-in-column-top {
        border-bottom: none;
        border-top: none;
        //border-top-left-radius: 5px;
        //border-top-right-radius: 5px;
        padding: 3px 2px 5.5px 2px;
        //margin-top: 3px;
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

    ::v-deep {
      .v-input {
        max-width: 70%;
      }

      input,
      #funnel-drilldown-row-count {
        font-size: 11px;
      }
    }
  }

  #funnel-drilldown-table {
    ::v-deep .v-data-table__wrapper {
      max-height: calc(100vh - 250px);
    }

    ::v-deep {
      th, td {
        font-size: 10px;
        padding: 5px;
      }

      th {
        line-height: 14px;

        .v-data-table-header__icon {
          font-size: 12px !important;
          padding-bottom: 2px;
        }
      }
    }

    #total-system-size-row:hover {
      background-color: transparent !important;
    }

    #total-system-size-label {
      font-weight: bold;
      text-align: right;
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
  #closer-dash-toolbar-container #closer-dash-toolbar .v-toolbar .v-toolbar__content .v-toolbar__title {
    font-size: 16px;
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
  #closer-dash-toolbar-container {
    #closer-dash-toolbar {
      #closer-dash-title-container {
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

  #closer-dash-tabs {
    margin: 0 auto;

    .col-12 span {
      font-size: 12px;
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
      border-bottom: 2px solid var(--v-primary-base);
      padding: 10px;

      .pipeline-icon {
        font-size: 32px;
      }

      .pipeline-title {
        margin-left: 10px;
      }
    }

    .appts-created-pipeline-dropdown {
      font-size: 12px;
      transform: none;
      margin-bottom: 0;
      width: 125px;
      height: 40px;

      ::v-deep .v-select__selections span {
        font-size: 12px !important;
      }
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

            ::v-deep {
              .v-input__control {
                max-width: 50px;
                height: 15px;
              }

              .v-input__slot {
                width: 50px;
                height: 15px;
                min-height: 15px;
              }
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
    margin-left: auto;
    margin-right: auto;
    max-width: calc(100% - 50px);

    .pipeline-header-container {
      border-bottom: 2px solid var(--v-primary-base);
      padding: 10px 10px 5px 10px;

      .pipeline-icon {
        font-size: 32px;
      }

      .pipeline-title {
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
          max-width: 145px;

          ::v-deep {
            label {
              font-size: 14px;
            }

            i {
              font-size: 20px;
            }

            .v-select__selections span {
              font-size: 12px !important;
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

            ::v-deep {
              .v-input__control {
                max-width: 50px;
                height: 15px;
              }

              .v-input__slot {
                width: 50px;
                height: 15px;
                min-height: 15px;
              }
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
        .no-checked-in-column-placeholder,
        .checked-in-column-bottom {
          margin-right: 10px;
          width: 60px;
        }

        .checked-in-column-top {
          padding: 6px 1px;
          //margin-top: 5px;
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
      ::v-deep {
        input,
        #funnel-drilldown-row-count {
          font-size: 12px;
        }

        .v-input {
          width: 80%;
        }
      }

      #funnel-drilldown-row-count {
        text-align: right;
        width: 20%;
      }
    }

    #funnel-drilldown-table {
      ::v-deep {
        th, td {
          font-size: 11px;
        }

        th {
          line-height: 16px;

          .v-data-table-header__icon {
            font-size: 14px !important;
            padding-bottom: 3px;
          }
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
  #closer-dash-toolbar-container {
    #closer-dash-toolbar {
      #closer-dash-title-container {
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

  #closer-dash-tabs .col-12 span {
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

  .ranking-table-header {
    font-size: 15px;
  }

  .user-office-ranking-table-header {
    .table-header-dropdown {
      max-width: 135px;
    }
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
        .no-checked-in-column-placeholder,
        .checked-in-column-bottom {
          width: 90px;
        }

        .checked-in-column-top {
          padding: 10px 5px;
          //margin-top: 5px;
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
        .no-checked-in-column-placeholder,
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
      ::v-deep {
        th, td {
          font-size: 12px;
        }

        th {
          line-height: 18px;

          .v-data-table-header__icon {
            font-size: 16px !important;
          }
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

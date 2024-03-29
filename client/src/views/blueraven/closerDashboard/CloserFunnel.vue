<template>
  <v-container id="closer-dash-container" ref="closerDashContainer">
    <!---------------------------------- FUNNEL TAB START ---------------------------------->
    <!-- APPOINTMENTS CREATED PIPELINE START -->
    <!--    1: {{showFunnels.value}}-->
    <!--    2: {{apptsCreatedPipelineLoaded.value}}-->
    <!--    3: {{apptsToFdcPipelineLoaded.value}}-->
    <!--    4: {{showDashboard.value}}-->
    <!--    5: {{rankingTablesLoaded.value}}-->
    <!--    6: {{showIncentive.value}}-->
    <!--    7: {{incentiveDataLoaded.value}}-->

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
                    <a-text-field class="custom-date-input" v-model="appts_created_pipeline_dt1_formatted"
                                  readonly variant="outlined" density="compact" hide-details v-on="on"></a-text-field>
                  </template>
                  <v-date-picker v-model="appts_created_pipeline_dt1" :max="appts_created_pipeline_dt2"
                                 @input="updateApptsCreatedPipelineCalendar"></v-date-picker>
                </v-menu>
                <span class="custom-date-span">-</span>
                <v-menu v-model="appts_created_pipeline_menu2" transition="scale-transition" offset-y
                        min-width="290px" :close-on-content-click="false">
                  <template v-slot:activator="{ on }">
                    <a-text-field class="custom-date-input" v-model="appts_created_pipeline_dt2_formatted"
                                  readonly  variant="outlined" density="compact" hide-details v-on="on"></a-text-field>
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
                  <a-btn
                      :activation-handler="on"
                      class="custom-dates-btn"
                      color="unset"
                      :text="apptsCreatedPipelineDateRange.label"
                      prepend-icon="mdi-menu-down"
                  ></a-btn>
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

            <a-btn
                v-if="!isCloser && !isCloserMgr"
                id="all-reps-btn"
                variant="outlined"
                color="primary"
                @click="funnelAllReps"
                text="All Reps"
            ></a-btn>

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
                  <a-btn
                      class="funnel-btn black--text"
                      @click="viewSelected('standard')"
                      :class="{'white--text': viewSelect === 'standard', 'primary--text': viewSelect !== 'standard', 'elevation-2': viewSelect !== 'standard'}"
                      :color="viewSelect === 'standard' ? 'primary' : 'secondary'"
                      text="Standard View"
                  ></a-btn>
                  <a-btn
                      class="funnel-btn black--text"
                      @click="viewSelected('apptDateCohort')"
                      :class="{'white--text': viewSelect === 'apptDateCohort', 'primary--text': viewSelect !== 'apptDateCohort', 'elevation-2': viewSelect !== 'apptDateCohort'}"
                      :color="viewSelect === 'apptDateCohort' ? 'primary' : 'secondary'"
                      text="Appt Date Cohort"
                  ></a-btn>
                </div>
              </th>
              <th class="funnel-th">TODAY</th>
              <th class="funnel-th">WEEK TO DATE</th>
              <th class="funnel-th">
                <div v-show="showApptsToFdcPipelineCustomDates" class="custom-dates-container">
                  <v-menu v-model="appts_to_fdc_pipeline_menu1" transition="scale-transition" offset-y
                          min-width="290px" :close-on-content-click="false">
                    <template v-slot:activator="{ on }">
                      <a-text-field class="custom-date-input" v-model="appts_to_fdc_pipeline_dt1_formatted" readonly
                                    density="compact" variant="outlined" hide-details v-on="on"></a-text-field>
                    </template>
                    <v-date-picker v-model="appts_to_fdc_pipeline_dt1" :max="appts_to_fdc_pipeline_dt2"
                                   @input="updateApptsToFdcPipelineCalendar()"></v-date-picker>
                  </v-menu>
                  <span class="custom-date-span">-</span>
                  <v-menu v-model="appts_to_fdc_pipeline_menu2" transition="scale-transition" offset-y
                          min-width="290px" :close-on-content-click="false">
                    <template v-slot:activator="{ on }">
                      <a-text-field class="custom-date-input" v-model="appts_to_fdc_pipeline_dt2_formatted" readonly
                                    density="compact" variant="outlined" hide-details v-on="on"></a-text-field>
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
                    <a-btn
                        :activation-handler="on"
                        class="custom-dates-btn"
                        color="unset"
                        :text="apptsToFdcPipelineDateRange.label"
                        prepend-icon="mdi-menu-down"
                    ></a-btn>
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
            <v-spacer></v-spacer>
            <a-btn
                color="primary"
                class="mr-4 mb-2"
                @click="exportDrilldownCsv()"
                text="Export"
            ></a-btn>
            <a class="close-modal-x pb-3" title="Close" @click="closeFunnelDrilldownDialog">×</a>
          </v-card-title>
          <v-divider></v-divider>
          <v-card-title v-if="funnelDrilldownData.length > 0" id="funnel-drilldown-search" class="pt-2">
            <a-text-field v-model="funnelDrilldownSearch"
                          placeholder="Type to filter..."
                          single-line
                          hide-details
                          outlined
                          dense
            ></a-text-field>
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
                  <td>{{ item.metro_area || '' }}</td>
                  <td>{{ item.status_type || '' }}</td>
                  <td class="customer-name">{{ item.customer_name || '' }}</td>
                  <td>
                    <router-link text v-if="item.project_id && $store.getters.userHasFeature('PROJECTS')"
                                 :to="`/project/${item.project_id}/${defaultProjectPage}`">
                      {{ item.project_id }}
                    </router-link>
                    <div v-else>{{ item.project_id || '' }}</div>
                  </td>
                  <td v-if="selectedFunnel.funnel_type_id === 1">
                    <router-link text v-if="item.project_id && item.project_process_step_id && item.project_process_step_event_id && userStore.userHasFeature('EVENTS')"
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
                  <td v-if="funnelDrilldownHeaders[14].show">
                    {{ item.date_created | formatDate('timestamp', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.appointment_outcome_class" v-if="funnelDrilldownHeaders[15].show">
                    {{ item.appointment_outcome || '' }}
                  </td>
                  <td :class="item.credit_decision_date_class" v-if="funnelDrilldownHeaders[16].show">
                    {{ item.credit_decision_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.credit_check_class" v-if="funnelDrilldownHeaders[17].show">
                    {{ item.credit_check || '' }}
                  </td>
                  <td :class="item.installation_agreement_signed_date_class"
                      v-if="funnelDrilldownHeaders[18].show">
                    {{ item.installation_agreement_signed_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.site_survey_verified_date_class"
                      v-if="funnelDrilldownHeaders[19].show">
                    {{ item.site_survey_verified_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.site_survey_completed_date_class"
                      v-if="funnelDrilldownHeaders[20].show">
                    {{ item.site_survey_completed_date | formatDate('timestamp', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.final_design_sent_to_homeowner_date_class"
                      v-if="funnelDrilldownHeaders[21].show">
                    {{ item.final_design_sent_to_homeowner_date | formatDate('timestamp', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.final_design_signed_date_class"
                      v-if="funnelDrilldownHeaders[22].show">
                    {{ item.final_design_signed_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.proof_of_homeowners_insurance_obtained_date_class"
                      v-if="funnelDrilldownHeaders[23].show">
                    {{ item.proof_of_homeowners_insurance_obtained_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.utility_bill_verified_date_class"
                      v-if="funnelDrilldownHeaders[24].show">
                    {{ item.utility_bill_verified_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.financial_agreement_signed_date_class"
                      v-if="funnelDrilldownHeaders[25].show">
                    {{ item.financial_agreement_signed_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.cash_down_payment_class"
                      v-if="funnelDrilldownHeaders[26].show">
                    {{ item.cash_down_payment | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.final_design_complete_date_class"
                      v-if="funnelDrilldownHeaders[27].show">
                    {{ item.final_design_complete_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.substantial_completion_date_class"
                      v-if="funnelDrilldownHeaders[28].show">
                    {{ item.substantial_completion_date | formatDate('date', 'MM/DD/YYYY') }}
                  </td>
                  <td :class="item.checked_in_time_date_class"
                      v-if="funnelDrilldownHeaders[29].show">
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
            <a-btn
                class="text-capitalize mr-4 mb-2"
                color="primary"
                @click="closeFunnelDrilldownDialog"
                text="Close"
            ></a-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
    <!-- FUNNEL DRILLDOWN END -->
    <!------------------------------------- FUNNEL TAB END ------------------------------------>
  </v-container>
</template>

<script setup>
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import moment from 'moment'
import constants from '@/helpers/constants'
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, getProjectPath} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import SpinnerInline from '@/components/SpinnerInline'
import { saveAs } from 'file-saver'
import {
  getCloserAreas,
  getCloserRegions,
  getCloserDistricts,
  getCloserOffices,
  getCloserReps
} from '@/services/dashboardService'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const defaultProjectPage = ref(getProjectPath().pathSuffix)
const funnelDrilldownDialog = ref(false)
const currentUserOrgId = ref(null)
const dropdownValuesLoading = ref(true)
const isCloser = ref(false)
const isCloserMgr = ref(false)
const selectedFunnel = ref({})
const isCloserRegional = ref(false)
const headers = ref([
  {text: '', value: '', show: true, sortable: false},
  {text: 'Name', value: 'customer_name', show: true},
  {text: 'Project ID', value: 'id', show: true},
  {text: 'Source', value: 'source_name', show: true},
  {text: 'System Size', value: 'system_size', show: true},
  {text: 'Final Design Complete Date', value: 'final_design_complete_date', show: true}
])
const drilldownData = ref([])
const apptsCreatedPipelineLoaded = ref(false)
const apptsToFdcPipelineLoaded = ref(false)
const funnelsWereLoaded = ref(false)
const currentQuarter = ref(moment().quarter())
const closerOffices = ref([])
const selectedCloserOffice = ref(null)
const leadAllocationRankingData = ref([])
const officeFdcRankingData = ref([])
const officeRankingData = ref([])
const topRepsData = ref([])
const userOffice = ref('')
const userRow = ref([])
const userRowIndex = ref(-1)
const numOffices = ref(0)
const apptsCreatedPipelineDataLoading = ref(true)
const apptsToFdcPipelineDataLoading = ref(false)
const apptsCreatedPipelineData = ref([])
const apptsToFdcPipelineData = ref([])
const apptsCreatedPipelineCustomSelectorIsOpen = ref(false)
const apptsToFdcPipelineCustomSelectorIsOpen = ref(false)
const todayUpperPercentage = ref(99)
const todayLowerPercentage = ref(99)
const wtdUpperPercentage = ref(99)
const wtdLowerPercentage = ref(99)
const cdrUpperPercentage = ref(99)
const cdrLowerPercentage = ref(99)
const brsProvidedSourceModel = ref([])
const brsProvidedSourceData = ref([])
const selfGenSourceModel = ref([])
const selfGenSourceData = ref([])
const areaModel = ref([])
const areaData = ref([])
const regionModel = ref([])
const regionData = ref([])
const districtModel = ref([])
const districtData = ref([])
const officeModel = ref([])
const officeData = ref([])
const repModel = ref([])
const repData = ref([])
const repDataMaster = ref([])
const repDataSelectAll = ref(false)
const apptsCreatedPipelineDateRanges = ref([
  {label: 'Yesterday', value: 'yesterday'},
  {label: 'Last Week', value: 'lastWeek'},
  {label: 'Month to Date', value: 'MTD'},
  {label: 'Last 60 days', value: 60},
  {label: 'Last 90 days', value: 90},
  {label: 'Year to Date', value: 'YTD'},
  {label: 'Custom', value: 'Custom'}
])
const apptsCreatedPipelineDateRange = ref({label: 'Month to Date', value: 'MTD'
})
const showApptsCreatedPipelineCustomDates = ref(false)
const apptsToFdcPipelineDateRanges = ref([
  {label: 'Yesterday', value: 'yesterday'},
  {label: 'Last Week', value: 'lastWeek'},
  {label: 'Month to Date', value: 'MTD'},
  {label: 'Last 60 days', value: 60},
  {label: 'Last 90 days', value: 90},
  {label: 'Year to Date', value: 'YTD'},
  {label: 'Custom', value: 'Custom'}
])
const initialPageLoad = ref(true)
const maxRepLimit = ref(1000)
const areaValuesChanged = ref(false)
const regionValuesChanged = ref(false)
const districtValuesChanged = ref(false)
const officeValuesChanged = ref(false)
const repValuesChanged = ref(false)
const apptsToFdcPipelineDateRange = ref({label: 'Month to Date', value: 'MTD'
})
const showApptsToFdcPipelineCustomDates = ref(false)
const viewSelect = ref('standard')
const appts_created_pipeline_dt1 = ref(moment().startOf('month').format('YYYY-MM-DD'))
const appts_created_pipeline_menu1 = ref(false)
const appts_created_pipeline_dt2 = ref(moment().format('YYYY-MM-DD'))
const appts_created_pipeline_menu2 = ref(false)
const appts_to_fdc_pipeline_dt1 = ref(moment().startOf('month').format('YYYY-MM-DD'))
const appts_to_fdc_pipeline_menu1 = ref(false)
const appts_to_fdc_pipeline_dt2 = ref(moment().format('YYYY-MM-DD'))
const appts_to_fdc_pipeline_menu2 = ref(false)
const funnelDrilldownTitle = ref('')
const funnelDrilldownData = ref([])
const funnelDrilldownLoading = ref(false)
const funnelDrilldownSearch = ref('')
const filteredFunnelDrilldownData = ref([])
const funnelDrilldownRowCount = ref(0)
const totalSystemSize = ref(0)
const repLengthOverride = ref(false)
const closerDashContainer = ref(null)
const myDynamicAreaWatcher = ref(null)
const myDynamicRegionWatcher = ref(null)
const myDynamicDistrictWatcher = ref(null)
const myDynamicOfficeWatcher = ref(null)
const myDynamicRepWatcher = ref(null)
const areaSelect = ref(null)
const regionSelect = ref(null)
const districtSelect = ref(null)
const officeSelect = ref(null)
const repSelect = ref(null)
const footerProps = ref({showFirstLastPage: !constants.IS_MOBILE,firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
  'items-per-page-options': [100, 500, 1000, 2500, 5000, 10000]})

const currentUserId = computed(() => {
  return userStore.details.id
})
const userCanViewAll = computed(() => {
  return userStore.userHasFeatureAccessLevel('CLOSER_DASHBOARD', 'VIEW_ALL')
})
const userCanViewAllProjects = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'VIEW_ALL')
})
const funnelDrilldownHeaders = computed(() => {
  return [
    {text: '', value: '', show: true, sortable: false, width: 25, optional: false}, // 0
    {text: 'Owner', value: 'owner_name', show: true, width: 90, optional: false}, // 1
    {text: 'Office', value: 'office', show: true, width: 75, optional: false}, // 2
    {text: 'State', value: 'state', show: true, width: 75, optional: false}, // 3
    {text: 'Metro', value: 'metro_area', show: true, width: 75, optional: false}, // 4
    {text: 'Status', value: 'status_type', show: true, width: 75, optional: false}, // 5
    {text: 'Name', value: 'customer_name', show: true, width: 90, optional: false}, // 6
    {text: 'Project ID', value: 'project_id', show: true, width: 85, optional: false}, // 7
    {text: 'Event ID', value: 'project_process_step_event_id', show: selectedFunnel.value.funnel_type_id === 1, width: 85, optional: false}, // 8
    {text: 'Source', value: 'source_name', show: true, width: 85, optional: false}, // 9
    {text: 'System Size', value: 'system_size', show: true, width: 110, optional: false}, // 10
    {text: 'Financier', value: 'financier', show: true, width: 95, optional: false}, // 11
    {text: 'Appointment Date', value: 'appointment_date', show: true, width: 145, optional: false, dateType: 'timestamp', dateFormat: 'MM/DD/YYYY'}, // 12
    {text: 'Cancelled Date', value: 'cancelled_date', show: true, width: 130, optional: false, dateType: 'date', dateFormat: 'MM/DD/YYYY'}, // 13
    {text: 'Date Created', value: 'date_created', show: false, width: 115, optional: true, dateType: 'timestamp', dateFormat: 'MM/DD/YYYY'}, // 14
    {text: 'Appointment Outcome', value: 'appointment_outcome', show: false, width: 170, optional: true}, // 15
    {text: 'Credit Decision Date', value: 'credit_decision_date', show: false, width: 160, optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'}, // 16
    {text: 'Credit Check', value: 'credit_check', show: false, width: 115, optional: true}, // 17
    {
      text: 'Installation Agreement Signed Date',
      value: 'installation_agreement_signed_date',
      show: false,
      width: 235,
      optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'
    }, // 18
    {
      text: 'Site Survey Verified Date',
      value: 'site_survey_verified_date',
      show: false,
      width: 160,
      optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'
    }, // 19
    {text: 'Site Survey Date', value: 'site_survey_completed_date', show: false, width: 155, optional: true, dateType: 'timestamp', dateFormat: 'MM/DD/YYYY'}, // 20
    {
      text: 'FD Sent to Homeowner Date',
      value: 'final_design_sent_to_homeowner_date',
      show: false,
      width: 200,
      optional: true, dateType: 'timestamp', dateFormat: 'MM/DD/YYYY'
    }, // 21
    {text: 'Final Design Approved', value: 'final_design_signed_date', show: false, width: 165, optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'}, // 22
    {
      text: 'Proof of HOI Obtained Date',
      value: 'proof_of_homeowners_insurance_obtained_date',
      show: false,
      width: 200,
      optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'
    }, // 23
    {
      text: 'Utility Bill Verified Date',
      value: 'utility_bill_verified_date',
      show: false,
      width: 175,
      optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'
    }, // 24
    {
      text: 'Financial Agreement Signed',
      value: 'financial_agreement_signed_date',
      show: false,
      width: 195,
      optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'
    }, // 25
    {text: 'Cash Down Payment', value: 'cash_down_payment', show: false, width: 160, optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'}, // 26
    {text: 'Final Design Completed', value: 'final_design_complete_date', show: false, width: 160, optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'}, // 27
    {
      text: 'Substantial Completion Date',
      value: 'substantial_completion_date',
      show: false,
      width: 175,
      optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'
    }, // 28
    {text: 'Checked In Time', value: 'checked_in_time', show: false, width: 160, optional: true, dateType: 'timestamp', dateFormat: 'MM/DD/YYYY h:mm a'}, // 29
  ]})
const windowInnerWidth = computed(() => {
  return window.innerWidth
})
const selectAllBrsProvidedSources = computed(() => {
  return brsProvidedSourceModel.value.length === brsProvidedSourceData.value.length
})
const selectSomeBrsProvidedSources = computed(() => {
  return brsProvidedSourceModel.value.length > 0 && !selectAllBrsProvidedSources.value
})
const brsProvidedSourcesSelectIcon = computed(() => {
  if (brsProvidedSourceModel.value.length === brsProvidedSourceData.value.length) {
    return 'check_box'
  }
  if (selectSomeBrsProvidedSources.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllSelfGenSources = computed(() => {
  return selfGenSourceModel.value.length === selfGenSourceData.value.length
})
const selectSomeSelfGenSources = computed(() => {
  return selfGenSourceModel.value.length > 0 && !selectAllSelfGenSources.value
})
const selfGenSourcesSelectIcon = computed(() => {
  if (selfGenSourceModel.value.length === selfGenSourceData.value.length) {
    return 'check_box'
  }
  if (selectSomeSelfGenSources.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllAreas = computed(() => {
  return areaModel.value.length === areaData.value.length
})
const selectSomeAreas = computed(() => {
  return areaModel.value.length > 0 && !selectAllAreas.value
})
const areaSelectIcon = computed(() => {
  if (areaModel.value.length === areaData.value.length) {
    return 'check_box'
  }
  if (selectSomeAreas.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllRegions = computed(() => {
  return regionModel.value.length === regionData.value.length
})
const selectSomeRegions = computed(() => {
  return regionModel.value.length > 0 && !selectAllRegions.value
})
const regionSelectIcon = computed(() => {
  if (regionModel.value.length === regionData.value.length) {
    return 'check_box'
  }
  if (selectSomeRegions.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllDistricts = computed(() => {
  return districtModel.value.length === districtData.value.length
})
const selectSomeDistricts = computed(() => {
  return districtModel.value.length > 0 && !selectAllDistricts.value
})
const districtSelectIcon = computed(() => {
  if (districtModel.value.length === districtData.value.length) {
    return 'check_box'
  }
  if (selectSomeDistricts.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllOffices = computed(() => {
  return officeModel.value.length === officeData.value.length
})
const selectSomeOffices = computed(() => {
  return officeModel.value.length > 0 && !selectAllOffices.value
})
const officeSelectIcon = computed(() => {
  if (officeModel.value.length === officeData.value.length) {
    return 'check_box'
  }
  if (selectSomeOffices.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllReps = computed(() => {
  return repModel.value.length === repData.value.length || repLengthOverride.value
})
const selectSomeReps = computed(() => {
  return repModel.value.length > 0 && !selectAllReps.value
})
const repSelectIcon = computed(() => {
  if (repModel.value.length === repData.value.length) {
    return 'check_box'
  }
  if (selectSomeReps.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const showTotalSystemSize = computed(() => {
  return funnelDrilldownRowCount.value > 0
})
const appts_created_pipeline_dt1_formatted = computed(() => {
  return formatFunnelDate(appts_created_pipeline_dt1.value)
})
const appts_created_pipeline_dt2_formatted = computed(() => {
  return formatFunnelDate(appts_created_pipeline_dt2.value)
})
const appts_to_fdc_pipeline_dt1_formatted = computed(() => {
  return formatFunnelDate(appts_to_fdc_pipeline_dt1.value)
})
const appts_to_fdc_pipeline_dt2_formatted = computed(() => {
  return formatFunnelDate(appts_to_fdc_pipeline_dt2.value)
})

watch(funnelDrilldownDialog, (val) => {
  if (!val) {
    funnelDrilldownSearch.value = ''

    // resets the visibility of the optional headers
    funnelDrilldownHeaders.value.forEach(header => {
      if (header.optional) header.show = false
    })
  }
})
watch(filteredFunnelDrilldownData, () => {
  calcTotalSystemSize()
})

const exportDrilldownCsv = () => {
  let csv = ''

  visibleFunnelDrilldownHeaders().forEach(h => {
    if(h.text !== '') {
      return csv += `${h.text},`
    }
  })
  csv += `\n`

  funnelDrilldownData.value.forEach(o => {

    visibleFunnelDrilldownHeaders().forEach(h => {
      if(h.text !== '') {
        if(h.dateType !== null && h.dateType !== undefined) {
          //if it is a date it needs to be formatted here
          csv += '"'+`${o[h.value] === null || o[h.value] === undefined ? '' : vueInstance.$filters.formatDate(o[h.value], h.dateType, h.dateFormat)}`+'",'
        } else {
          csv += '"'+`${o[h.value] === null || o[h.value] === undefined ? '' : o[h.value]}`+'",'
        }
      }
    })
    csv += `\n`
  })

  const blob = new Blob([csv], {type: 'text/csv;charset=utf-8'})
  saveAs(blob, `${funnelDrilldownTitle.value}.csv`)
}
const visibleFunnelDrilldownHeaders = () => {
  return funnelDrilldownHeaders.value.filter(header => header.show === true)
}
const resetScrollBarPosition = () => {
  // reset scroll bar position to top
  closerDashContainer.value.scrollTop = 0
}

/* FUNNEL-RELATED CODE START */
const chooseApptsCreatedPipelineDateRange = (dateRange) => {
  if (showApptsCreatedPipelineCustomDates.value) {
    showApptsCreatedPipelineCustomDates.value = false
    // fixApptsCreatedFunnelTopMargin()
  }

  apptsCreatedPipelineDateRange.value = dateRange

  switch (dateRange.value) {
    case 'yesterday':
      yesterday('apptsCreatedPipeline')
      break
    case 'lastWeek':
      lastWeek('apptsCreatedPipeline')
      break
    case 'MTD':
      monthToDate('apptsCreatedPipeline')
      break
    case 'YTD':
      yearToDate('apptsCreatedPipeline')
      break
    case 'Custom':
      showApptsCreatedPipelineCustomDates.value = true
      // fixApptsCreatedFunnelTopMargin()
      break
    default:
      previousNumberOfDays('apptsCreatedPipeline', dateRange.value)
      break
  }
}

const chooseApptsToFdcPipelineDateRange = (dateRange) => {
  if (showApptsToFdcPipelineCustomDates.value) {
    showApptsToFdcPipelineCustomDates.value = false
    // fixApptsToFdcFunnelTopMargin()

    // if (viewSelect.value === 'apptDateCohort') {
    //   fixApptDateCohortBlueLinePosition()
    // }
  }

  apptsToFdcPipelineDateRange.value = dateRange

  switch (dateRange.value) {
    case 'yesterday':
      yesterday('apptsToFdcPipeline')
      break
    case 'lastWeek':
      lastWeek('apptsToFdcPipeline')
      break
    case 'MTD':
      monthToDate('apptsToFdcPipeline')
      break
    case 'YTD':
      yearToDate('apptsToFdcPipeline')
      break
    case 'Custom':
      showApptsToFdcPipelineCustomDates.value = true
      // fixApptsToFdcFunnelTopMargin()

      // if (viewSelect.value === 'apptDateCohort') {
      //   fixApptDateCohortBlueLinePosition()
      // }


      break
    default:
      previousNumberOfDays('apptsToFdcPipeline', dateRange.value)
      break
  }
}

const viewSelected = (view) => {
  if (viewSelect.value !== view) {
    viewSelect.value = view
    apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1.value, appts_to_fdc_pipeline_dt2.value, false)
  }
}

const formatFunnelDate = (date) => {
  if (!date) return null

  return moment(date).format('M/D/YY')
}

const parseFunnelDate = (date) => {
  if (!date) return null

  return moment(date, 'M/D/YY').format('YYYY-MM-DD')
}

const loadFunnels = async() => {
  if (apptsCreatedPipelineData.value?.length === 0) {
    loadSources()
  }

  if (apptsToFdcPipelineData.value?.length === 0) {
    if (isCloser.value || isCloserMgr.value || isCloserRegional.value) {
      await areaLoad(true)
      await regionLoad(true, true)
      await districtLoad(true, true)
      await officeLoad(true, true)
      repLoad(true)
    } else {
      await areaLoad(false)
      await regionLoad(false, true)
      await districtLoad(false, true)
      await officeLoad(false, true)
      repLoad(false)
    }
  }
}

const funnelAllReps = () => {
  areaModel.value = []
  districtModel.value = []
  regionModel.value = []
  officeModel.value = []

  repModel.value = [
    {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
  ]

  repData.value = [
    {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
  ]

  // apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1.value, appts_to_fdc_pipeline_dt2.value, false)
  apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1.value, appts_to_fdc_pipeline_dt2.value, false)
}

const loadSources = () => {
  try {
    getRequest('/closerDashboard/getBrsProvidedSources', 'blueraven', []).then(res => {
      brsProvidedSourceData.value = res.data
      brsProvidedSourceModel.value = cloneDeep(brsProvidedSourceData.value)

      getRequest('/closerDashboard/getSelfGenSources', 'blueraven', []).then(res => {
        selfGenSourceData.value = res.data
        selfGenSourceModel.value = cloneDeep(selfGenSourceData.value)
        apptsCreatedPipelineLoad(appts_created_pipeline_dt1.value, appts_created_pipeline_dt2.value)
      })
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving lists of sources')

  }
}

const apptsCreatedPipelineLoad = async(start, end) => {
  apptsCreatedPipelineLoaded.value = false
  let brsProvidedSources = []
  let selfGenSources = []

  brsProvidedSourceModel.value?.forEach(brsProvidedSource => {
    if (brsProvidedSource.sourceId) {
      brsProvidedSources.push(brsProvidedSource.sourceId)
    }
  })

  selfGenSourceModel.value.forEach(selfGenSource => {
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

  apptsCreatedPipelineDataLoading.value = true
  try {
    await postRequest('/closerDashboard/funnel/apptsCreatedPipeline', requestBody, 'blueraven', []).then(res => {
      apptsCreatedPipelineData.value = orderBy(res.data, row => row.display_order)
    })

    if (isCloser.value || isCloserMgr.value || isCloserRegional.value) {
      if (apptsToFdcPipelineData.value.length > 0) {
        apptsCreatedPipelineLoaded.value = true
      }
      apptsCreatedPipelineDataLoading.value = false
    } else {
      apptsCreatedPipelineLoaded.value = true
      apptsCreatedPipelineDataLoading.value = false
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving Appointments Created Pipeline data')

    apptsCreatedPipelineLoaded.value = true
    apptsCreatedPipelineDataLoading.value = false
  }
}

const apptsToFdcPipelineLoad = async(start, end, useRepDataInstead) => {
  apptsToFdcPipelineLoaded.value = false
  apptsToFdcPipelineDataLoading.value = true
  let reps = []
  let orgs = []

  if ((repModel.value.length === 0 && !useRepDataInstead) || (useRepDataInstead && repData.value.length === 0)) {
    apptsToFdcPipelineData.value = []
    return
  }

  officeModel.value.forEach(org => orgs.push(org.org_id))

  let modelOverride = false
  if (useRepDataInstead) {
    repData.value.forEach((rep, index) => {
      reps.push(rep.user_position_id)
      if (index === repData.value.length - 1) {
        //   districtModel.value = []
        //   regionModel.value = []
        //   officeModel.value = []
        if (repDataSelectAll.value && repDataMaster.value?.length > maxRepLimit.value) {
          modelOverride = true
          repModel.value = [
            {user_id: -2, name: 'All Filtered Reps', active: true}
          ]
          repData.value = [
            {user_id: -2, name: 'All Filtered Reps', active: true}
          ]
        }
      }
    })
  } else {
    repModel.value.forEach(rep => reps.push(rep.user_position_id))
  }

  if (modelOverride) {
    reps = []
    //this gets used when there are more than 1000 users selected
    repDataMaster.value.forEach(rep => reps.push(rep.user_position_id))
  }

  const requestBody = {
    users: reps,
    orgs: orgs,
    start: moment(start).format('YYYY-MM-DD'),
    end: moment(end).format('YYYY-MM-DD')
  }

  try {
    await postRequest('/closerDashboard/funnel/' + viewSelect.value, requestBody, 'blueraven', []).then(res => {
      apptsToFdcPipelineData.value = orderBy(res.data, row => row.display_order)

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

      apptsToFdcPipelineData.value.forEach(row => {
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

      todayUpperPercentage.value = getPercentage(todayUpperNumerator, todayUpperDenominator)
      wtdUpperPercentage.value = getPercentage(wtdUpperNumerator, wtdUpperDenominator)
      cdrUpperPercentage.value = getPercentage(customDateRangeUpperNumerator, customDateRangeUpperDenominator)
      todayLowerPercentage.value = getPercentage(todayLowerNumerator, todayLowerDenominator)
      wtdLowerPercentage.value = getPercentage(wtdLowerNumerator, wtdLowerDenominator)
      cdrLowerPercentage.value = getPercentage(customDateRangeLowerNumerator, customDateRangeLowerDenominator)

      apptsToFdcPipelineLoaded.value = true
      apptsToFdcPipelineDataLoading.value = false
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving Appointments to FDC Pipeline data')

    apptsToFdcPipelineLoaded.value = true
  }
}
const getPercentage = (numerator, denominator) => {
  if (denominator !== 0) {
    return Math.round((numerator / denominator) * 100)
  } else {
    return 0
  }
}
const areaLoad = async(preSelectLists) => {
  if (!currentUserId.value) return

  await getCloserAreas(currentUserId.value, false).then(res => {
    if (res?.length > 0) {
      areaData.value = res
    }

    if (preSelectLists && (isCloserMgr.value || isCloserRegional.value)) {
      areaModel.value = areaData.value.filter(od => od.active)
    } else if (preSelectLists) {
      areaModel.value = cloneDeep(areaData.value)
    }

    // reset these values when the areas change
    regionModel.value = []
    districtModel.value = []
    officeModel.value = []
    repModel.value = []

    if (!initialPageLoad.value) {
      regionLoad(preSelectLists, true)
      // officeLoad(preSelectLists, true)
      // repLoad(preSelectLists, true)
    }
  })


  apptsToFdcPipelineData.value = []
  apptsToFdcPipelineLoaded.value = true
}
const regionLoad = async(preSelectLists) => {
  if (!currentUserId.value) return

  let areas = areaModel.value.map(function (area) {
    return {
      area_id: area.org_id
    }
  })

  // if (!selectAllDistricts.value) {
  //   regionModel.value = []
  //   regionData.value = []
  //   officeModel.value = []
  //   officeData.value = []
  //   repModel.value = []
  //   repData.value = []
  //   apptsToFdcPipelineData.value = []
  //
  //   // if (districts?.length === 0) return
  // }

  // reset these values when the regions change
  districtModel.value = []
  officeModel.value = []
  repModel.value = []


  await getCloserRegions(currentUserId.value, JSON.stringify(areas), false).then(res => {
    regionData.value = res


        if (preSelectLists && (this.isCloserMgr || this.isCloserRegional)) {
          this.regionModel = this.regionData.filter(od => od.active)
        } else if (preSelectLists) {
          this.regionModel = cloneDeep(this.regionData)
        }

    if (!initialPageLoad.value) {
      districtLoad(preSelectLists, true)
      // repLoad(preSelectLists, true)
    }
  })

  apptsToFdcPipelineData.value = []
}
const districtLoad = async(preSelectLists) => {
  if (!currentUserId.value) return

  let areas = areaModel.value.map(function (area) {
    return {
      area_id: area.org_id
    }
  })

  let regions = regionModel.value.map(function (region) {
    return {
      region_id: region.org_id
    }
  })
  await getCloserDistricts(currentUserId.value, JSON.stringify(areas), JSON.stringify(regions), false).then(res => {
    if (res?.length > 0) {
      districtData.value = res
    }

    if (preSelectLists && (isCloserMgr.value || isCloserRegional.value)) {
      districtModel.value = districtData.value.filter(od => od.active)
    } else if (preSelectLists) {
      districtModel.value = cloneDeep(districtData.value)
    }

    // reset these values when the districts change
    // regionModel.value = []
    officeModel.value = []
    repModel.value = []

    if (!initialPageLoad.value) {
      officeLoad(preSelectLists, true)
      // officeLoad(preSelectLists, true)
      // repLoad(preSelectLists, true)
    }
  })


  apptsToFdcPipelineData.value = []
  apptsToFdcPipelineLoaded.value = true
}
const officeLoad = async(preSelectLists) => {
  if (!currentUserId.value) return


  let areas = areaModel.value.map(function (area) {
    return {
      area_id: area.org_id
    }
  })

  let regions = regionModel.value.map(function (region) {
    return {
      region_id: region.org_id
    }
  })

  let districts = districtModel.value.map(function (district) {
    return {
      district_id: district.org_id
    }
  })

  // if (!selectAllRegions.value) {
  //   officeModel.value = []
  //   officeData.value = []
  //   repModel.value = []
  //   repData.value = []
  //   apptsToFdcPipelineData.value = []
  //
  //   // if (regions?.length === 0) return
  // }

  // reset these values when the offices change
  repModel.value = []

  await getCloserOffices(currentUserId.value, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts), false).then(res => {
    officeData.value = res

    if (preSelectLists && (isCloserMgr.value || isCloserRegional.value)) {
      officeModel.value = officeData.value.filter(od => od.active)
    } else if (preSelectLists) {
      officeModel.value = cloneDeep(officeData.value)
    }

    if (!initialPageLoad.value) {
      repLoad(preSelectLists, true)
    }
  })

  apptsToFdcPipelineData.value = []
  // repData.value = []
  repModel.value = []
}
const repLoad = async(preSelectLists) => {
  //reset these any time we are reloading reps or things get weird
  repModel.value = []
  repData.value = []
  repLengthOverride.value = false

  if (!currentUserId.value) return

  let areas = areaModel.value.map(function (area) {
    return {
      area_id: area.org_id
    }
  })

  let regions = regionModel.value.map(function (region) {
    return {
      region_id: region.org_id
    }
  })

  let districts = districtModel.value.map(function (district) {
    return {
      district_id: district.org_id
    }
  })

  let offices = officeModel.value.map(function (office) {
    return {
      office_id: office.org_id
    }
  })

  // if (!selectAllOffices.value) {
  //   repModel.value = []
  //   repData.value = []
  //   apptsToFdcPipelineData.value = []
  //
  //   // if (offices?.length === 0) return
  // }

  await getCloserReps(currentUserId.value, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts), JSON.stringify(offices)).then(res => {
    repData.value = res

    repDataMaster.value = cloneDeep(res)

    if (preSelectLists) {
      repModel.value = cloneDeep(repData.value)
    }

    apptsToFdcPipelineData.value = []

    if (repModel.value.length > 0) {
      apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1.value, appts_to_fdc_pipeline_dt2.value, false)
    }
  })
  initialPageLoad.value = false
  dropdownValuesLoading.value = false
}
const updateApptsCreatedPipelineCalendar = () => {
  appts_created_pipeline_menu1.value = false
  appts_created_pipeline_menu2.value = false
  apptsCreatedPipelineLoad(appts_created_pipeline_dt1.value, appts_created_pipeline_dt2.value)
}
const updateApptsToFdcPipelineCalendar = () => {
  appts_to_fdc_pipeline_menu1.value = false
  appts_to_fdc_pipeline_menu2.value = false
  apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1.value, appts_to_fdc_pipeline_dt2.value, false)
}
const yesterday = (pipelineName) => {
  if (pipelineName === 'apptsCreatedPipeline') {
    appts_created_pipeline_dt1.value = moment().subtract(1, 'd').format('YYYY-MM-DD')
    appts_created_pipeline_dt2.value = moment().subtract(1, 'd').format('YYYY-MM-DD')
    updateApptsCreatedPipelineCalendar(true)
  } else {
    appts_to_fdc_pipeline_dt1.value = moment().subtract(1, 'd').format('YYYY-MM-DD')
    appts_to_fdc_pipeline_dt2.value = moment().subtract(1, 'd').format('YYYY-MM-DD')
    updateApptsToFdcPipelineCalendar(true)
  }
}
const lastWeek = (pipelineName) => {
  if (pipelineName === 'apptsCreatedPipeline') {
    appts_created_pipeline_dt1.value = moment().startOf('W').subtract(1, 'w').format('YYYY-MM-DD')
    appts_created_pipeline_dt2.value = moment().endOf('W').subtract(1, 'w').format('YYYY-MM-DD')
    updateApptsCreatedPipelineCalendar(true)
  } else {
    appts_to_fdc_pipeline_dt1.value = moment().startOf('W').subtract(1, 'w').format('YYYY-MM-DD')
    appts_to_fdc_pipeline_dt2.value = moment().endOf('W').subtract(1, 'w').format('YYYY-MM-DD')
    updateApptsToFdcPipelineCalendar(true)
  }
}
const monthToDate = (pipelineName) => {
  if (pipelineName === 'apptsCreatedPipeline') {
    appts_created_pipeline_dt1.value = moment().startOf('month').format('YYYY-MM-DD')
    appts_created_pipeline_dt2.value = moment().format('YYYY-MM-DD')
    updateApptsCreatedPipelineCalendar(true)
  } else {
    appts_to_fdc_pipeline_dt1.value = moment().startOf('month').format('YYYY-MM-DD')
    appts_to_fdc_pipeline_dt2.value = moment().format('YYYY-MM-DD')
    updateApptsToFdcPipelineCalendar(true)
  }
}
const previousNumberOfDays = (pipelineName, days) => {
  if (pipelineName === 'apptsCreatedPipeline') {
    appts_created_pipeline_dt1.value = moment().subtract(days, 'days').format('YYYY-MM-DD')
    appts_created_pipeline_dt2.value = moment().format('YYYY-MM-DD')
    updateApptsCreatedPipelineCalendar()
  } else {
    appts_to_fdc_pipeline_dt1.value = moment().subtract(days, 'days').format('YYYY-MM-DD')
    appts_to_fdc_pipeline_dt2.value = moment().format('YYYY-MM-DD')
    updateApptsToFdcPipelineCalendar()
  }
}
const doRepWatcher = () => {
  if (repValuesChanged.value) {
    // repModel.value = cloneDeep(repData.value)
    if (isCloser.value || isCloserMgr.value || isCloserRegional.value) {
      apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1.value, appts_to_fdc_pipeline_dt2.value, false)
    } else if (selectAllReps.value) {
      apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1.value, appts_to_fdc_pipeline_dt2.value, true)
    } else {
      apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1.value, appts_to_fdc_pipeline_dt2.value, false)
    }
    repValuesChanged.value = false
  }
}
const yearToDate = (pipelineName) => {
  if (pipelineName === 'apptsCreatedPipeline') {
    appts_created_pipeline_dt1.value = moment().startOf('year').format('YYYY-MM-DD')
    appts_created_pipeline_dt2.value = moment().format('YYYY-MM-DD')
    updateApptsCreatedPipelineCalendar()
  } else {
    appts_to_fdc_pipeline_dt1.value = moment().startOf('year').format('YYYY-MM-DD')
    appts_to_fdc_pipeline_dt2.value = moment().format('YYYY-MM-DD')
    updateApptsToFdcPipelineCalendar()
  }
}
const funnelDrilldown = async(funnel, dateRange, pipelineName, isCheckedInColumn) => {
  selectedFunnel.value = funnel
  let sourceIds = []
  let userIds = []
  let orgIds = []
  let start, end
  let datesMatch = false

  if (pipelineName === 'apptsCreatedPipeline') {
    let brsSourceIds = brsProvidedSourceModel.value.map(brsProvidedSource => brsProvidedSource.sourceId)
    let selfGenSourceIds = selfGenSourceModel.value.map(selfGenSource => selfGenSource.sourceId)
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
        start = appts_created_pipeline_dt1.value
        end = appts_created_pipeline_dt2.value
        break
    }
  } else {
    userIds = repModel.value.map(rep => rep.user_position_id)
    orgIds = officeModel.value.map(org => org.org_id)

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
        start = appts_to_fdc_pipeline_dt1.value
        end = appts_to_fdc_pipeline_dt2.value
        break
    }
  }

  datesMatch = moment(start).format('YYYY-MM-DD') === moment(end).format('YYYY-MM-DD')

  if (datesMatch) {
    funnelDrilldownTitle.value = funnel.name + ' on ' + moment(start).format('M/D/YYYY')
  } else {
    funnelDrilldownTitle.value = funnel.name + ' ' + moment(start).format('M/D/YYYY') + ' - ' + moment(end).format('M/D/YYYY')
  }

  switch (funnel.id) {
      // Appointments Created Pipeline
    case 12: // BRS-provided appointments created
    case 13: // Self-gen appointments created
    case 10: // Total Appointments Created
    case 26: // Missing source
      funnelDrilldownHeaders.value[14].show = true // date_created
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
      // funnelDrilldownHeaders.value[14].show = true // appointment_outcome
      funnelDrilldownHeaders.value[15].show = true // appointment_outcome
      funnelDrilldownHeaders.value[29].show = isCheckedInColumn // check_in_time
      break
    case 9: // Credits run
      funnelDrilldownHeaders.value[15].show = true // appointment_outcome
      funnelDrilldownHeaders.value[16].show = true // credit_decision_date
      break
    case 3: // Credits passed
      funnelDrilldownHeaders.value[15].show = true // appointment_outcome
      funnelDrilldownHeaders.value[16].show = true // credit_decision_date
      funnelDrilldownHeaders.value[17].show = true // credit_check
      break
    case 4: // Bookings Complete
      funnelDrilldownHeaders.value[18].show = true // installation_agreement_signed_date
      funnelDrilldownHeaders.value[20].show = true // site_survey_completed_date
      break
    case 5: // Site Surveys Verified
      funnelDrilldownHeaders.value[19].show = true // site_survey_verified_date
      break
    case 6: // Final Designs sent to Homeowner
      funnelDrilldownHeaders.value[21].show = true // final_design_sent_to_homeowner_date
      funnelDrilldownHeaders.value[22].show = true // final_design_signed_date
      break
    case 7: // Final Designs Approved
      funnelDrilldownHeaders.value[22].show = true // final_design_signed_date
      funnelDrilldownHeaders.value[25].show = true // financial_agreement_signed_date
      funnelDrilldownHeaders.value[23].show = true // proof_of_homeowners_insurance_obtained_date
      funnelDrilldownHeaders.value[26].show = true // cash_down_payment
      funnelDrilldownHeaders.value[24].show = true // utility_bill_verified_date
      break
    case 21: // Final Designs Completed
      funnelDrilldownHeaders.value[27].show = true // final_design_complete_date
      break
    case 8: // Installations Completed
      funnelDrilldownHeaders.value[28].show = true // substantial_completion_date
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

  appStore.loading = true
  try {
    await postRequest(`/closerDashboard/funnelDrilldown/${pipelineName}`, requestBody, 'blueraven', []).then(({data, status}) => {
      funnelDrilldownData.value = data?.length > 0 ? data : []

      if (funnelDrilldownData.value?.length > 0) {
        // for (let i = 0; i < funnelDrilldownData.value.length; i++) {
        //   funnelDrilldownData.value[i].rowNum = i + 1
        // }

        markMissingDrilldownData()
      }

      funnelDrilldownDialog.value = true
      handleHidingGlobalLoader( status)
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving drilldown data')

    appStore.loading = false
  }
}
const markMissingDrilldownData = () => {
  funnelDrilldownData.value = funnelDrilldownData.value.map(function (line) {
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
}
const calcTotalSystemSize = () => {
  if (funnelDrilldownData.value.length > 0 && filteredFunnelDrilldownData.value.length > 0) {
    let total = 0

    filteredFunnelDrilldownData.value.forEach(row => {
      if (row.system_size) {
        total += row.system_size
      }
    })

    totalSystemSize.value = +total.toFixed(2)
  } else {
    totalSystemSize.value = 0
  }
}
const filteredFunnelDrilldownItems = (filteredItems) => {
  filteredFunnelDrilldownData.value = filteredItems
  funnelDrilldownRowCount.value = filteredItems.length
}
const toggleSelectAllBrsProvidedSources = () => {
  vueInstance.$nextTick(() => {
    if (selectAllBrsProvidedSources.value) {
      brsProvidedSourceModel.value = []
      apptsCreatedPipelineData.value[0] = {
        id: 12,
        name: 'BRS provided appointments created',
        today_count: 0,
        week_to_date_count: 0,
        custom_date_range_count: 0
      }
    } else {
      brsProvidedSourceModel.value = cloneDeep(brsProvidedSourceData.value)
      apptsCreatedPipelineLoad(appts_created_pipeline_dt1.value, appts_created_pipeline_dt2.value)
    }
  })
}
const toggleSelectAllSelfGenSources = () => {
  vueInstance.$nextTick(() => {
    if (selectAllSelfGenSources.value) {
      selfGenSourceModel.value = []
      apptsCreatedPipelineData.value[1] = {
        id: 13,
        name: 'Self-gen appointments created',
        today_count: 0,
        week_to_date_count: 0,
        custom_date_range_count: 0
      }
    } else {
      selfGenSourceModel.value = cloneDeep(selfGenSourceData.value)
      apptsCreatedPipelineLoad(appts_created_pipeline_dt1.value, appts_created_pipeline_dt2.value)
    }
  })
}
const toggleSelectAllAreas = () => {
  vueInstance.$nextTick(() => {
    if (selectAllAreas.value) {
      areaModel.value = []
      regionData.value = []
      regionModel.value = []
      districtData.value = []
      districtModel.value = []
      officeData.value = []
      officeModel.value = []
      repData.value = []
      repModel.value = []
      apptsToFdcPipelineData.value = []
    } else {
      areaModel.value = cloneDeep(areaData.value)
      repModel.value = [] // in case the user previously clicked the 'All Reps' button
      // regionLoad(false)
    }
  })
}
const toggleSelectAllRegions = () => {
  vueInstance.$nextTick(() => {
    if (selectAllRegions.value) {
      regionModel.value = []
      officeData.value = []
      officeModel.value = []
      repData.value = []
      repModel.value = []
      apptsToFdcPipelineData.value = []
    } else {
      regionModel.value = cloneDeep(regionData.value)
      // officeLoad(false)
    }
  })
}
const toggleSelectAllDistricts = () => {
  vueInstance.$nextTick(() => {
    if (selectAllDistricts.value) {
      districtModel.value = []
      regionData.value = []
      regionModel.value = []
      officeData.value = []
      officeModel.value = []
      repData.value = []
      repModel.value = []
      apptsToFdcPipelineData.value = []
    } else {
      districtModel.value = cloneDeep(districtData.value)
      // repModel.value = [] // in case the user previously clicked the 'All Reps' button
      // regionLoad(false)
    }
  })
}
const toggleSelectAllOffices = () => {
  vueInstance.$nextTick(() => {
    if (selectAllOffices.value) {
      officeModel.value = []
      repData.value = []
      repModel.value = []
      apptsToFdcPipelineData.value = []
    } else {
      officeModel.value = cloneDeep(officeData.value)
      // repLoad(false)
    }
  })
}
const toggleSelectAllReps = () => {
  vueInstance.$nextTick(() => {
    if (selectAllReps.value) {
      repModel.value = []
      repLengthOverride.value = false
      apptsToFdcPipelineData.value = []
    } else {
      if (repDataSelectAll.value && repData.value?.length > maxRepLimit.value) {
        //this is different than clicking the All Reps button and needs to be filtered.
        // -2 was updated to mean - select all reps in the selected orgs
        repLengthOverride.value = true
        repModel.value = [
          {user_id: -2, user_position_id: -2, name: 'All Filtered Reps', active: true}
        ]
        doRepWatcher()
      } else {
        repModel.value = cloneDeep(repData.value)
      }
    }
  })
}
const closeFunnelDrilldownDialog = () => {
  funnelDrilldownDialog.value = false
  resetScrollBarPosition()
}

onMounted(async () => {
  if (userStore.details.userPositions?.length > 0) {
    let positionId = null

    isCloser.value = userStore.details.userPositions.filter(position => {
      return (position.positionId === 1 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    isCloserMgr.value = userStore.details.userPositions.filter(position => {
      return (position.positionId === 2 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    isCloserDistrictMgr.value = userStore.details.userPositions.filter(position => {
      return (position.positionId === 517 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    let fakeCloserMgr = userStore.details.userPositions.filter(position => {
      return (position.positionId === 326 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    isCloserRegional.value = userStore.details.userPositions.filter(position => {
      return (position.positionId === 3 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    if (isCloser.value) {
      positionId = 1
    } else if (isCloserMgr.value) {
      positionId = 2
    } else if (isCloserDistrictMgr.value) {
      positionId = 517
    } else if (isCloserRegional.value) {
      positionId = 3
    } else if (fakeCloserMgr) {
      positionId = 326
    }

    if (isCloser.value || isCloserMgr.value || isCloserDistrictMgr.value || isCloserRegional.value) {
      currentUserOrgId.value = userStore.details.userPositions.filter(position => {
        return (position.positionId === positionId && !position.endDate && !position.archived && position.primaryFlag)
      })[0]?.orgId
    }

    if (fakeCloserMgr || isCloserDistrictMgr.value) {
      isCloserMgr.value = true
    }
  }

  await loadFunnels()
  funnelsWereLoaded.value = true

  //vuetify selects/autocompletes have a bug with the select all feature being used at the same time as the @blur event
  //the @blur event should only be called when the menu is closed, but in a select all it is called when the select all button is clicked. wreaks havoc.
  //this sucks but fixes that issue re: https://github.com/vuetifyjs/vuetify/issues/11488
  myDynamicAreaWatcher.value = vueInstance.$watch(
      () => areaSelect.value.isMenuActive,
      (val) => {
        // if val is false = blur aka the menu is being closed. true = menu is being opened
        if (!val) {
          if (areaValuesChanged.value) {
            // reset these values when the districts change
            regionModel.value = []
            officeModel.value = []
            repModel.value = []
            repDataSelectAll.value = false
            regionLoad(false)
            // officeLoad(false)
            // repLoad(false)
            areaValuesChanged.value = false
          }
        }
      })
  myDynamicRegionWatcher.value = vueInstance.$watch(
      () => regionSelect.value.isMenuActive,
      (val) => {
        // if val is false = blur aka the menu is being closed. true = menu is being opened
        if (!val) {
          if (regionValuesChanged.value) {
            // reset these values when the regions change
            districtModel.value = []
            officeModel.value = []
            repModel.value = []
            repDataSelectAll.value = false
            districtLoad(false)
            // repLoad(false)
            regionValuesChanged.value = false
          }
        }
      })
  myDynamicDistrictWatcher.value = vueInstance.$watch(
      () => districtSelect.value.isMenuActive,
      (val) => {
        // if val is false = blur aka the menu is being closed. true = menu is being opened
        if (!val) {
          if (districtValuesChanged.value) {
            // reset these values when the districts change
            officeModel.value = []
            repModel.value = []
            repDataSelectAll.value = false
            officeLoad(false)
            // officeLoad(false)
            // repLoad(false)
            districtValuesChanged.value = false
          }
        }
      })
  myDynamicOfficeWatcher.value = vueInstance.$watch(
      () => officeSelect.value.isMenuActive,
      (val) => {
        // if val is false = blur aka the menu is being closed. true = menu is being opened
        if (!val) {
          if (officeValuesChanged.value) {
            // reset these values when the offices change
            repModel.value = []
            repDataSelectAll.value = false
            repLoad(false)
            officeValuesChanged.value = false
          }
        }
      })
  myDynamicRepWatcher.value = vueInstance.$watch(
      () => repSelect.value.isMenuActive,
      (val) => {
        // if val is false = blur aka the menu is being closed. true = menu is being opened
        if (!val && repModel.value.length > 0) {
          doRepWatcher()
        }
      })
})
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

            .a-text-field__slot input {
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

            .a-text-field__slot input {
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

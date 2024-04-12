{
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
      <v-row align="center">
        <div class="title-large closer-dashboard-header">
          Appointments Created Pipeline
        </div>
        <a class="export-button" @click="exportCsv">
          <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
          Export</a>
        <v-spacer></v-spacer>
        <div class="flex-display flex-align-items-end table-collapse-button">
          <v-icon v-if="apptsCreatedExpanded" @click="apptsCreatedExpanded = !apptsCreatedExpanded">expand_less</v-icon>
          <v-icon v-else @click="apptsCreatedExpanded = !apptsCreatedExpanded">expand_more</v-icon>
        </div>
      </v-row>
      <v-row v-if="apptsCreatedExpanded" class="filter-row" align="center"> Filters:
        <div class="checkbox-container">
          <v-checkbox label="View Trends" :disabled="disableTrends" v-model="viewTrends"></v-checkbox>
        </div>
      </v-row>

      <!-- FUNNEL -->
      <div class="funnel-container">
        <div v-if="apptsCreatedPipelineDataLoading" class="pipeline-data-loading-container">
          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
        </div>
        <div v-if="apptsCreatedPipelineData.length > 0" id="appts-created-pipeline-funnel-background"
             :style="{'margin-top': showApptsCreatedPipelineCustomDates && windowInnerWidth < 1135 ? '77px' :
                                 showApptsCreatedPipelineCustomDates && windowInnerWidth >= 1135 ? '83px' : '59px'}"></div>
        <v-data-table
          v-if="apptsCreatedExpanded"
          id="company-dash-table"
          class="elevation-1"
          :items="filteredApptsCreatedPipelineData"
          :headers="headers"
          ref="pageable-table"
          disable-sort
          :item-class="itemRowBackground"
          :footer-props="footerProps"
          :loading="isLoading"
          :hide-default-footer="true"
          :mobile-breakpoint="0"
        >

          <template #no-data>
            <span class="default-text-color">No available data</span>
          </template>


          <template #header.milestone="{}" id="milestones-header">Milestones</template>
          <template #header.source="{}">Source</template>
          <template #header.actualTotal="{}">
            <v-menu data-app left
                    offset-y
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    v-model="openFirstMenu"
                    :close-on-content-click="true">
              <template v-slot:activator="{ on }">
                <v-btn class="dropdown-header body-small"
                       v-on="on"
                >
              <span v-if="getDropdownById(firstDateRange)?.name === 'CUSTOM' && firstCustom.name != null" class="selected-option body-small">
                      {{firstCustom.name}}</span>
                  <span v-else-if="getDropdownById(firstDateRange)?.name === 'PERIOD'" class="selected-option body-small">
              {{ getDropdownById(firstDateRange).periodList[firstPeriod].shortLabel}}
              </span>
                  <span v-else class="selected-option body-small">
              {{ getDropdownById(firstDateRange)?.friendlyName}}
              </span>
                  <v-spacer></v-spacer>
                  <v-icon>mdi-menu-down</v-icon>
                </v-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover offset-x>
                        <template v-slot:activator="{ on }">
                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                        {{ item.friendlyName }}
                        <v-icon style="display: flex">mdi-chevron-right</v-icon>
                      </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y:auto">
                            <v-list-item v-for="(period, index) in item.periodList"
                                         @click="firstDateRange = item.id; firstPeriod = index; changeDropdownSelection(1); firstCustom.isActive = (item.name === 'CUSTOM'); openFirstMenu = false">
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>

                    </v-list-item-title>
                    <v-list-item-title v-else
                                       @click="firstDateRange = item.id; changeDropdownSelection(1); firstCustom.isActive = (item.name === 'CUSTOM');"
                                       class="dashboard-menu-option">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>

          </template>
          <template #header.actualTotal2="{}">
            <v-menu data-app left
                    offset-y
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    v-model="openSecondMenu"
                    :close-on-content-click="true">
              <template v-slot:activator="{ on }">
                <v-btn class="dropdown-header body-small"
                       v-on="on"
                >
              <span v-if="getDropdownById(secondDateRange)?.name === 'CUSTOM' && secondCustom.name != null"
                    class="selected-option body-small">
                      {{ secondCustom.name }}</span>
                  <span v-else-if="getDropdownById(secondDateRange)?.name === 'PERIOD'"
                        class="selected-option body-small">
              {{ getDropdownById(secondDateRange).periodList[secondPeriod].shortLabel }}
              </span>
                  <span v-else-if="secondDateRange != null" class="selected-option body-small">
              {{ getDropdownById(secondDateRange)?.friendlyName }}
              </span>
                  <span v-else class="placeholder-option body-small">
                Select Date Range
              </span>
                  <v-icon>mdi-menu-down</v-icon>
                </v-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover location="end" :offset-x="true">
                        <template v-slot:activator="{ on }">
                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                        {{ item.friendlyName }}
                        <v-icon>mdi-chevron-right</v-icon>
                      </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y:auto">
                            <v-list-item v-for="(period, index) in item.periodList"
                                         @click="secondDateRange = item.id; secondPeriod = index; changeDropdownSelection(2); secondCustom.isActive = (item.name === 'CUSTOM'); openSecondMenu = false">
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>

                    </v-list-item-title>
                    <v-list-item-title v-else
                                       @click="secondDateRange = item.id; changeDropdownSelection(2); secondCustom.isActive = (item.name === 'CUSTOM');"
                                       class="dashboard-menu-option">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>
          <template #header.actualTotal3="{}">
            <v-menu data-app left
                    offset-y
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    v-model="openThirdMenu"
                    :close-on-content-click="true">
              <template v-slot:activator="{ on }">
                <v-btn class="dropdown-header body-small"
                       v-on="on"
                >
              <span v-if="getDropdownById(thirdDateRange)?.name === 'CUSTOM' && thirdCustom.name != null"
                    class="selected-option body-small">
                      {{ thirdCustom.name }}</span>
                  <span v-else-if="getDropdownById(thirdDateRange)?.name === 'PERIOD'"
                        class="selected-option body-small">
              {{ getDropdownById(thirdDateRange).periodList[thirdPeriod].shortLabel }}
              </span>
                  <span v-else-if="thirdDateRange != null" class="selected-option body-small">
              {{ getDropdownById(thirdDateRange)?.friendlyName }}
              </span>
                  <span v-else class="placeholder-option body-small">
                Select Date Range
              </span>
                  <v-icon>mdi-menu-down</v-icon>
                </v-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover location="end">
                        <template v-slot:activator="{ on }">
                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                        {{ item.friendlyName }}
                        <v-icon>mdi-chevron-right</v-icon>
                      </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y:auto">
                            <v-list-item v-for="(period, index) in item.periodList"
                                         @click="thirdDateRange = item.id; thirdPeriod = index; changeDropdownSelection(3); thirdCustom.isActive = (item.name === 'CUSTOM'); openThirdMenu = false">
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>

                    </v-list-item-title>
                    <v-list-item-title v-else
                                       @click="thirdDateRange = item.id; changeDropdownSelection(3); thirdCustom.isActive = (item.name === 'CUSTOM');"
                                       class="dashboard-menu-option">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>


          <template #item.milestone="{item, index}" id="milestones-col" class="milestone-name-col-td"><span
            :class="{'label-medium': index < 2}">
            <span v-if="index === 1">
              <v-icon v-if="milestonesExpanded" @click="hideMilestones()">expand_less</v-icon>
              <v-icon v-else @click="expandMilestones()">expand_more</v-icon>
            </span>
            {{ item.name }}</span></template>
          <template #item.source="{item, index}" class="milestone-name-col-td">
            <v-select v-if="index===0 && !isCloser"
                      class="appts-created-pipeline-dropdown"
                      v-model="leadsCreatedSourceModel"
                      :items="leadsCreatedSourceData"
                      item-text="sourceName"
                      item-value="sourceId"
                      placeholder="Select"
                      multiple
                      outlined
                      background-color="white"
                      dense
                      return-object
                      @input="changeSources()">
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="grey--text text-caption">
                    {{ leadsCreatedSourceModel.length }} Checked
                  </span>
              </template>
              <template v-if="leadsCreatedSourceData.length > 0" v-slot:prepend-item>
                <v-list-item @click="toggleSelectAllLeadsCreatedSources">
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

            <v-select
              v-if="index === 2 && !isCloser"
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
              @input="changeSources()">
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
            <v-select v-if="index===3"
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
                      @input="changeSources()">
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

          </template>
          <template #item.actualTotal="{item, index}" class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
              <span @click="funnelDrilldown(item, getDropdownById(firstDateRange), 'apptsCreatedPipeline', true)">
              {{ item.leads_created_count ? item.leads_created_count : 0 }}
              <span v-on="viewTrends?on:null">
                <span v-if="viewTrends && item.trend>0"
                      class="positive-percentage">+{{ item.trend / 100 | percent }}<v-icon
                  class="positive-trendline">trending_up</v-icon></span>
                <span v-if="viewTrends && item.trend<0"
                      class="negative-percentage">{{ item.trend / 100 | percent }}<v-icon
                  class="negative-trendline">trending_down</v-icon></span>
                <span v-if="viewTrends && (item.trend ===null || item.trend===0)"
                      class="neutral-percentage">{{ item.trend / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
                </span>
              </span>
              </template>
              <span v-if="viewTrends && item.trend>0"> {{ Math.abs(item.trend) / 100 | percent }} more than {{ getDropdownById(firstDateRange).trendText }}</span>
              <span v-if="viewTrends && item.trend<0"> {{ Math.abs(item.trend) / 100 | percent }} less than {{ getDropdownById(firstDateRange).trendText }}</span>
              <span
                v-if="viewTrends && (item.trend ===null || item.trend===0)"> Same as {{ getDropdownById(firstDateRange).trendText }}</span>
            </v-tooltip>
          </template>

          <template #item.actualTotal2="{item, index}" class="milestone-col-td"
                    v-if="secondDateRange != null && column2Values != null && column2Values.length > 0">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="openDrilldown(item, 2)">
              {{ column2Values[index].leads_created_count  ? column2Values[index].leads_created_count  : 0 }}
              <span v-on="viewTrends?on:null">
                <span v-if="viewTrends && column2Values[index].trend>0"
                      class="positive-percentage">+{{ column2Values[index].trend / 100 | percent }}<v-icon
                  class="positive-trendline">trending_up</v-icon></span>
                <span v-if="viewTrends && column2Values[index].trend<0"
                      class="negative-percentage">{{ column2Values[index].trend / 100 | percent }}<v-icon
                  class="negative-trendline">trending_down</v-icon></span>
                <span
                  v-if="viewTrends && (column2Values[index].trend === null || column2Values[index].trend==0)"
                  class="neutral-percentage">{{ column2Values[index].trend / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewTrends && column2Values[index].trend>0"> {{ Math.abs(column2Values[index].trend) / 100 | percent }} more than {{ getDropdownById(secondDateRange).trendText }}</span>
              <span
                v-if="viewTrends && column2Values[index].trend<0"> {{ Math.abs(column2Values[index].trend) / 100 | percent }} less than {{ getDropdownById(secondDateRange).trendText }}</span>
              <span
                v-if="viewTrends && (column2Values[index].trend ===null || column2Values[index].trend===0)"> Same as {{ getDropdownById(secondDateRange).trendText }}</span>
            </v-tooltip>
          </template>
          <template #item.actualTotal3="{item, index}" class="milestone-col-td"
                    v-if="thirdDateRange != null && column3Values != null && column3Values.length > 0">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="openDrilldown(item, 3)">
              {{ column3Values[index].leads_created_count ? column3Values[index].leads_created_count : 0 }}
              <span v-on="viewTrends?on:null">
                <span v-if="viewTrends && column3Values[index].trend>0"
                      class="positive-percentage">+{{ column3Values[index].trend / 100 | percent }}<v-icon
                  class="positive-trendline">trending_up</v-icon></span>
                <span v-if="viewTrends && column3Values[index].trend<0"
                      class="negative-percentage">{{ column3Values[index].trend / 100 | percent }}<v-icon
                  class="negative-trendline">trending_down</v-icon></span>
                <span
                  v-if="viewTrends && (column3Values[index].trend === null || column3Values[index].trend === 0)"
                  class="neutral-percentage">{{ column3Values[index].trend / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewTrends && column3Values[index].trend>0"> {{ Math.abs(column3Values[index].trend) / 100 | percent }} more than {{ getDropdownById(thirdDateRange).trendText }}</span>
              <span
                v-if="viewTrends && column3Values[index].trend<0"> {{ Math.abs(column3Values[index].trend) / 100 | percent }} less than {{ getDropdownById(thirdDateRange).trendText }}</span>
              <span
                v-if="viewTrends && (column3Values[index].trend ===null || column3Values[index].trend===0)"> Same as {{ getDropdownById(thirdDateRange).trendText }}</span>
            </v-tooltip>
          </template>
        </v-data-table>
      </div>
    </div>
    <!-- APPOINTMENTS CREATED PIPELINE END -->

    <!-- APPOINTMENTS TO FDC PIPELINE START -->
    <div id="appts-to-fdc-pipeline-container" class="mb-8">
      <v-row align="center">
        <div class="title-large closer-dashboard-header">
          Appointments to FDC Pipeline
        </div>
        <a class="export-button" @click="exportCsv">
          <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
          Export</a>
        <v-spacer></v-spacer>
        <div class="flex-display flex-align-items-end table-collapse-button">
          <v-icon v-if="fdcPipelineExpanded" @click="fdcPipelineExpanded = !fdcPipelineExpanded">expand_less</v-icon>
          <v-icon v-else @click="fdcPipelineExpanded = !fdcPipelineExpanded">expand_more</v-icon>
        </div>
      </v-row>
      <div class="pipeline-header-container" v-if="fdcPipelineExpanded">
      <div id="pipeline-header-right-side">
        <div>Reps: </div>
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
                  <span v-if="index === 0 && repModel[0].user_id != -1" class="grey--text text-caption">
                    {{ repModel.length }} Checked
                  </span>
                  <span v-if="index === 0 && repModel[0].user_id === -1" class="grey--text text-caption">
                        {{ repDataMaster.length }} Checked
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
        <v-label>Hide Inactive Reps</v-label> <v-switch v-model="hideInactiveReps" @click="apptsToFdcPipelineLoad(1)"></v-switch>
        <v-btn v-if="!isCloser && !isCloserMgr" class="label-medium reset-button" outlined @click="resetFilters">
          Reset Filters
        </v-btn>
      </div>
        <div class="flex-display flex-align-items-center">
<!--          <v-btn v-if="!isCloser && !isCloserMgr" id="all-reps-btn" outlined color="primary" @click="funnelAllReps">-->
<!--            View All Reps-->
<!--          </v-btn>-->
          <v-btn id="all-reps-btn" outlined color="primary" @click="funnelAllReps">
            View All Reps
          </v-btn>
        </div>
</div>
      <v-row v-if="fdcPipelineExpanded" class="pipeline-header-container">
        <div id="pipeline-header-right-side">
          Other Filters:
        <v-select
                  v-if="!isCloser"
                  class="appts-to-fdc-pipeline-dropdown"
                  v-model="fdcSourceModel"
                  :items="fdcSourceData"
                  item-text="sourceName"
                  item-value="sourceId"
                  placeholder="Select"
                  multiple
                  outlined
                  hide-details
                  background-color="white"
                  dense
                  return-object
                  @input="changeSources()">
          <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="grey--text text-caption">
                    {{ fdcSourceModel.length }} Checked
                  </span>
          </template>
          <template v-if="fdcSourceData.length > 0" v-slot:prepend-item>
            <v-list-item @click="toggleSelectAllLeadsCreatedSources">
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
        <v-autocomplete class="appts-to-fdc-pipeline-dropdown"
                        v-model="appointmentTypesModel"
                        :items="appointmentTypes"
                        item-text="name"
                        item-value="user_position_id"
                        label="Appointment Type"
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
                    {{ appointmentTypesModel.length }} Checked
                  </span>
          </template>
          <template v-if="appointmentTypes.length > 0" v-slot:prepend-item>
            <v-list-item
              @click="[repValuesChanged = true, appointmentTypesSelectAll = !appointmentTypesSelectAll, toggleSelectAppointmentTypes()]">
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
              <v-list-item-title>
                {{ data.item.name }}
              </v-list-item-title>
            </v-list-item-content>
          </template>
        </v-autocomplete>
        <div class="checkbox-container">
          <v-checkbox label="View Trends" :disabled="disableTrends" v-model="viewFdcTrends"></v-checkbox>
        </div>
        </div>
      </v-row>


      <!-- FUNNEL -->
      <div class="funnel-container">
        <div v-if="apptsCreatedPipelineDataLoading" class="pipeline-data-loading-container">
          <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
        </div>
        <div v-if="apptsCreatedPipelineData.length > 0" id="appts-created-pipeline-funnel-background"
             :style="{'margin-top': showApptsCreatedPipelineCustomDates && windowInnerWidth < 1135 ? '77px' :
                                 showApptsCreatedPipelineCustomDates && windowInnerWidth >= 1135 ? '83px' : '59px'}"></div>
        <v-data-table
          v-if="fdcPipelineExpanded"
          id="company-dash-table"
          class="elevation-1"
          :items="apptsToFdcPipelineData"
          :headers="fdcHeaders"
          ref="pageable-table"
          disable-sort
          :item-class="fdcRowBackground"
          :footer-props="footerProps"
          :loading="isLoading"
          :hide-default-footer="true"
          :mobile-breakpoint="0"
        >

          <template #no-data>
            <span class="default-text-color">No available data</span>
          </template>


          <template #header.milestone="{}" id="milestones-header">Milestones</template>
          <template #header.actualTotal="{}">
            <v-menu data-app left
                    offset-y
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    v-model="fdcOpenFirstMenu"
                    :close-on-content-click="true">
              <template v-slot:activator="{ on }">
                <v-btn class="dropdown-header body-small"
                       v-on="on"
                >
              <span v-if="getDropdownById(fdcFirstDateRange)?.name === 'CUSTOM' && fdcFirstCustom.name != null" class="selected-option body-small">
                      {{fdcFirstCustom.name}}</span>
                  <span v-else-if="getDropdownById(fdcFirstDateRange)?.name === 'PERIOD'" class="selected-option body-small">
              {{ getDropdownById(fdcFirstDateRange).periodList[firstPeriod].shortLabel}}
              </span>
                  <span v-else class="selected-option body-small">
              {{ getDropdownById(fdcFirstDateRange)?.friendlyName}}
              </span>
                  <v-spacer></v-spacer>
                  <v-icon>mdi-menu-down</v-icon>
                </v-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover offset-x>
                        <template v-slot:activator="{ on }">
                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                        {{ item.friendlyName }}
                        <v-icon style="display: flex">mdi-chevron-right</v-icon>
                      </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y:auto">
                            <v-list-item v-for="(period, index) in item.periodList"
                                         @click="fdcFirstDateRange = item.id; firstPeriod = index; changeFdcDropdownSelection(1); fdcFirstCustom.isActive = (item.name === 'CUSTOM'); fdcOpenFirstMenu = false">
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>

                    </v-list-item-title>
                    <v-list-item-title v-else
                                       @click="fdcFirstDateRange = item.id; changeFdcDropdownSelection(1); fdcFirstCustom.isActive = (item.name === 'CUSTOM');"
                                       class="dashboard-menu-option">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>

          </template>
          <template #header.actualTotal2="{}">
            <v-menu data-app left
                    offset-y
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    v-model="fdcOpenSecondMenu"
                    :close-on-content-click="true">
              <template v-slot:activator="{ on }">
                <v-btn class="dropdown-header body-small"
                       v-on="on"
                >
              <span v-if="getDropdownById(fdcSecondDateRange)?.name === 'CUSTOM' && secondCustom.name != null"
                    class="selected-option body-small">
                      {{ secondCustom.name }}</span>
                  <span v-else-if="getDropdownById(fdcSecondDateRange)?.name === 'PERIOD'"
                        class="selected-option body-small">
              {{ getDropdownById(fdcSecondDateRange).periodList[secondPeriod].shortLabel }}
              </span>
                  <span v-else-if="fdcSecondDateRange != null" class="selected-option body-small">
              {{ getDropdownById(fdcSecondDateRange)?.friendlyName }}
              </span>
                  <span v-else class="placeholder-option body-small">
                Select Date Range
              </span>
                  <v-icon>mdi-menu-down</v-icon>
                </v-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover location="end" :offset-x="true">
                        <template v-slot:activator="{ on }">
                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                        {{ item.friendlyName }}
                        <v-icon>mdi-chevron-right</v-icon>
                      </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y:auto">
                            <v-list-item v-for="(period, index) in item.periodList"
                                         @click="fdcSecondDateRange = item.id; secondPeriod = index; changeFdcDropdownSelection(2); secondCustom.isActive = (item.name === 'CUSTOM'); fdcOpenSecondMenu = false">
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>

                    </v-list-item-title>
                    <v-list-item-title v-else
                                       @click="fdcSecondDateRange = item.id; changeFdcDropdownSelection(2); secondCustom.isActive = (item.name === 'CUSTOM');"
                                       class="dashboard-menu-option">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>
          <template #header.actualTotal3="{}">
            <v-menu data-app left
                    offset-y
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    v-model="fdcOpenThirdMenu"
                    :close-on-content-click="true">
              <template v-slot:activator="{ on }">
                <v-btn class="dropdown-header body-small"
                       v-on="on"
                >
              <span v-if="getDropdownById(fdcThirdDateRange)?.name === 'CUSTOM' && thirdCustom.name != null"
                    class="selected-option body-small">
                      {{ thirdCustom.name }}</span>
                  <span v-else-if="getDropdownById(fdcThirdDateRange)?.name === 'PERIOD'"
                        class="selected-option body-small">
              {{ getDropdownById(fdcThirdDateRange).periodList[thirdPeriod].shortLabel }}
              </span>
                  <span v-else-if="fdcThirdDateRange != null" class="selected-option body-small">
              {{ getDropdownById(fdcThirdDateRange)?.friendlyName }}
              </span>
                  <span v-else class="placeholder-option body-small">
                Select Date Range
              </span>
                  <v-icon>mdi-menu-down</v-icon>
                </v-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover location="end">
                        <template v-slot:activator="{ on }">
                      <span v-on="on" class="d-flex justify-space-between dashboard-menu-option">
                        {{ item.friendlyName }}
                        <v-icon>mdi-chevron-right</v-icon>
                      </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y:auto">
                            <v-list-item v-for="(period, index) in item.periodList"
                                         @click="fdcThirdDateRange = item.id; thirdPeriod = index; changeFdcDropdownSelection(3); thirdCustom.isActive = (item.name === 'CUSTOM'); fdcOpenThirdMenu = false">
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>

                    </v-list-item-title>
                    <v-list-item-title v-else
                                       @click="fdcThirdDateRange = item.id; changeFdcDropdownSelection(3); thirdCustom.isActive = (item.name === 'CUSTOM');"
                                       class="dashboard-menu-option">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>


          <template #item.milestone="{item, index}" id="milestones-col" class="milestone-name-col-td"><span
            :class="{'label-medium': fdcExpandableMilestones.includes(index), 'blue-sub-row': fdcExpandableMilestones.includes(index)}">
            <span v-if="fdcExpandableMilestones.includes(index) && !milestonesSwitching">
              <v-icon v-if="fdcMilestonesExpanded[fdcExpandableMilestones.indexOf(index)]" @click="fdcHideMilestone(index)">expand_less</v-icon>
              <v-icon v-else @click="fdcExpandMilestone(index)">expand_more</v-icon>
            </span>
            {{ item.name }}</span></template>
          <template #item.source="{item, index}" class="milestone-name-col-td">
            <v-select v-if="index===0"
                      class="appts-created-pipeline-dropdown"
                      v-model="leadsCreatedSourceModel"
                      :items="leadsCreatedSourceData"
                      item-text="sourceName"
                      item-value="sourceId"
                      placeholder="Select"
                      multiple
                      outlined
                      background-color="white"
                      dense
                      return-object
                      @input="changeSources()">
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="grey--text text-caption">
                    {{ leadsCreatedSourceModel.length }} Checked
                  </span>
              </template>
              <template v-if="leadsCreatedSourceData.length > 0" v-slot:prepend-item>
                <v-list-item @click="toggleSelectAllLeadsCreatedSources">
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

            <v-select
              v-if="index === 2"
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
              @input="changeSources()">
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
            <v-select v-if="index===3"
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
                      @input="changeSources()">
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

          </template>
          <template #item.actualTotal="{item, index}" class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
              <span @click="funnelDrilldown(item, getDropdownById(fdcFirstDateRange), 'standard', true)">
                {{ item.custom_date_range_count ? item.custom_date_range_count : 0 }}
              <span v-if="item.checked_in_custom_date_range_count != null" class="checked_in_container body-small">
                <v-icon>
                    check_circle
                </v-icon>
                {{item.checked_in_custom_date_range_count}}
              </span>
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && item.trend_count>0"
                      class="positive-percentage">+{{ item.trend_count / 100 | percent }}<v-icon
                  class="positive-trendline">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && item.trend_count<0"
                      class="negative-percentage">{{ item.trend_count / 100 | percent }}<v-icon
                  class="negative-trendline">trending_down</v-icon></span>
                <span v-if="viewFdcTrends && (item.trend_count ===null || item.trend_count===0)"
                      class="neutral-percentage">{{ item.trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
                </span>
              </span>
              </template>
              <span v-if="viewFdcTrends && item.trend_count>0"> {{ Math.abs(item.trend_count) / 100 | percent }} more than {{ getDropdownById(fdcFirstDateRange).trendText }}</span>
              <span v-if="viewFdcTrends && item.trend_count<0"> {{ Math.abs(item.trend_count) / 100 | percent }} less than {{ getDropdownById(fdcFirstDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && (item.trend_count ===null || item.trend_count===0)"> Same as {{ getDropdownById(fdcFirstDateRange).trendText }}</span>
            </v-tooltip>
          </template>

          <template #item.actualTotal2="{item, index}" class="milestone-col-td"
                    v-if="fdcSecondDateRange != null && fdcColumn2Values != null && fdcColumn2Values.length > 0">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="openDrilldown(item, 2)">
              {{ fdcColumn2Values[index].custom_date_range_count  ? fdcColumn2Values[index].custom_date_range_count  : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && fdcColumn2Values[index].trend_count>0"
                      class="positive-percentage">+{{ fdcColumn2Values[index].trend_count / 100 | percent }}<v-icon
                  class="positive-trendline">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && fdcColumn2Values[index].trend_count<0"
                      class="negative-percentage">{{ fdcColumn2Values[index].trend_count / 100 | percent }}<v-icon
                  class="negative-trendline">trending_down</v-icon></span>
                <span
                  v-if="viewFdcTrends && (fdcColumn2Values[index].trend_count === null || fdcColumn2Values[index].trend_count==0)"
                  class="neutral-percentage">{{ fdcColumn2Values[index].trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewFdcTrends && fdcColumn2Values[index].trend_count>0"> {{ Math.abs(fdcColumn2Values[index].trend_count) / 100 | percent }} more than {{ getDropdownById(fdcSecondDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && fdcColumn2Values[index].trend_count<0"> {{ Math.abs(fdcColumn2Values[index].trend_count) / 100 | percent }} less than {{ getDropdownById(fdcSecondDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && (fdcColumn2Values[index].trend_count ===null || fdcColumn2Values[index].trend_count===0)"> Same as {{ getDropdownById(fdcSecondDateRange).trendText }}</span>
            </v-tooltip>
          </template>
          <template #item.actualTotal3="{item, index}" class="milestone-col-td"
                    v-if="fdcThirdDateRange != null && fdcColumn3Values != null && fdcColumn3Values.length > 0">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="openDrilldown(item, 3)">
              {{ fdcColumn3Values[index].custom_date_range_count ? fdcColumn3Values[index].custom_date_range_count : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && fdcColumn3Values[index].trend_count>0"
                      class="positive-percentage">+{{ fdcColumn3Values[index].trend_count / 100 | percent }}<v-icon
                  class="positive-trendline">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && fdcColumn3Values[index].trend_count<0"
                      class="negative-percentage">{{ fdcColumn3Values[index].trend_count / 100 | percent }}<v-icon
                  class="negative-trendline">trending_down</v-icon></span>
                <span
                  v-if="viewFdcTrends && (fdcColumn3Values[index].trend_count === null || fdcColumn3Values[index].trend_count === 0)"
                  class="neutral-percentage">{{ fdcColumn3Values[index].trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewFdcTrends && fdcColumn3Values[index].trend_count>0"> {{ Math.abs(fdcColumn3Values[index].trend_count) / 100 | percent }} more than {{ getDropdownById(fdcThirdDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && fdcColumn3Values[index].trend_count<0"> {{ Math.abs(fdcColumn3Values[index].trend_count) / 100 | percent }} less than {{ getDropdownById(fdcThirdDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && (fdcColumn3Values[index].trend_count ===null || fdcColumn3Values[index].trend_count===0)"> Same as {{ getDropdownById(fdcThirdDateRange).trendText }}</span>
            </v-tooltip>
          </template>
        </v-data-table>
      </div>
    </div>
        <div class="funnel-relative">
          <div v-if="dropdownValuesLoading || apptsToFdcPipelineDataLoading" class="funnel-spinner">
            <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
          </div>
<!--          <div id="appts-to-fdc-pipeline-container" :class="{'mb-8': apptsToFdcPipelineData.length > 0}">-->
<!--            <v-row align="center">-->
<!--              <div class="title-large closer-dashboard-header">-->
<!--                Appointments To FDC Pipeline-->
<!--              </div>-->
<!--              <a class="export-button">-->
<!--                <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>-->
<!--                Export</a>-->
<!--            </v-row>-->
<!--            <div class="pipeline-header-container">-->

<!--              &lt;!&ndash; DROPDOWNS &ndash;&gt;-->
<!--              <div id="pipeline-header-right-side">-->
<!--                <div>Reps: </div>-->
<!--                <v-autocomplete class="appts-to-fdc-pipeline-dropdown"-->
<!--                                ref="areaSelect"-->
<!--                                v-model="areaModel"-->
<!--                                :items="areaData"-->
<!--                                item-text="org_name"-->
<!--                                item-value="org_id"-->
<!--                                label="Area"-->
<!--                                no-data-text="No areas available"-->
<!--                                outlined-->
<!--                                multiple-->
<!--                                dense-->
<!--                                hide-details-->
<!--                                @input="areaValuesChanged = true"-->
<!--                                return-object>-->
<!--                  <template v-slot:selection="{ item, index }">-->
<!--                  <span v-if="index === 0" class="grey&#45;&#45;text text-caption">-->
<!--                    {{ areaModel.length }} Checked-->
<!--                  </span>-->
<!--                  </template>-->
<!--                  <template v-if="areaData.length > 0" v-slot:prepend-item>-->
<!--                    <v-list-item @click="[areaValuesChanged = true, toggleSelectAllAreas()]">-->
<!--                      <v-list-item-action class="mr-2">-->
<!--                        <v-icon>{{ areaSelectIcon }}</v-icon>-->
<!--                      </v-list-item-action>-->
<!--                      <v-list-item-content>-->
<!--                        <v-list-item-title>Select All</v-list-item-title>-->
<!--                      </v-list-item-content>-->
<!--                    </v-list-item>-->
<!--                    <v-divider class="mt-2"></v-divider>-->
<!--                  </template>-->
<!--                  <template v-slot:item="data">-->
<!--                    <v-list-item-action class="mr-2">-->
<!--                      <v-icon v-if="data.attrs.inputValue">check_box</v-icon>-->
<!--                      <v-icon v-else>check_box_outline_blank</v-icon>-->
<!--                    </v-list-item-action>-->
<!--                    <v-list-item-content>-->
<!--                      <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">-->
<!--                        {{ data.item.org_name }}-->
<!--                      </v-list-item-title>-->
<!--                    </v-list-item-content>-->
<!--                  </template>-->
<!--                </v-autocomplete>-->

<!--                <v-autocomplete class="appts-to-fdc-pipeline-dropdown"-->
<!--                                v-model="regionModel"-->
<!--                                :items="regionData"-->
<!--                                item-text="org_name"-->
<!--                                item-value="org_id"-->
<!--                                label="Region"-->
<!--                                no-data-text="No regions available"-->
<!--                                outlined-->
<!--                                multiple-->
<!--                                dense-->
<!--                                @input="regionValuesChanged = true"-->
<!--                                hide-details-->
<!--                                return-object-->
<!--                                ref="regionSelect">-->
<!--                  <template v-slot:selection="{ item, index }">-->
<!--                  <span v-if="index === 0" class="grey&#45;&#45;text text-caption">-->
<!--                    {{ regionModel.length }} Checked-->
<!--                  </span>-->
<!--                  </template>-->
<!--                  <template v-if="regionData.length > 0" v-slot:prepend-item>-->
<!--                    <v-list-item @click="[regionValuesChanged = true, toggleSelectAllRegions()]">-->
<!--                      <v-list-item-action class="mr-2">-->
<!--                        <v-icon>{{ regionSelectIcon }}</v-icon>-->
<!--                      </v-list-item-action>-->
<!--                      <v-list-item-content>-->
<!--                        <v-list-item-title>Select All</v-list-item-title>-->
<!--                      </v-list-item-content>-->
<!--                    </v-list-item>-->
<!--                    <v-divider class="mt-2"></v-divider>-->
<!--                  </template>-->
<!--                  <template v-slot:item="data">-->
<!--                    <v-list-item-action class="mr-2">-->
<!--                      <v-icon v-if="data.attrs.inputValue">check_box</v-icon>-->
<!--                      <v-icon v-else>check_box_outline_blank</v-icon>-->
<!--                    </v-list-item-action>-->
<!--                    <v-list-item-content>-->
<!--                      <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">-->
<!--                        {{ data.item.org_name }}-->
<!--                      </v-list-item-title>-->
<!--                    </v-list-item-content>-->
<!--                  </template>-->
<!--                </v-autocomplete>-->

<!--                <v-autocomplete class="appts-to-fdc-pipeline-dropdown"-->
<!--                                ref="districtSelect"-->
<!--                                v-model="districtModel"-->
<!--                                :items="districtData"-->
<!--                                item-text="org_name"-->
<!--                                item-value="org_id"-->
<!--                                label="District"-->
<!--                                no-data-text="No districts available"-->
<!--                                outlined-->
<!--                                multiple-->
<!--                                dense-->
<!--                                hide-details-->
<!--                                @input="districtValuesChanged = true"-->
<!--                                return-object>-->
<!--                  <template v-slot:selection="{ item, index }">-->
<!--                  <span v-if="index === 0" class="grey&#45;&#45;text text-caption">-->
<!--                    {{ districtModel.length }} Checked-->
<!--                  </span>-->
<!--                  </template>-->
<!--                  <template v-if="districtData.length > 0" v-slot:prepend-item>-->
<!--                    <v-list-item @click="[districtValuesChanged = true, toggleSelectAllDistricts()]">-->
<!--                      <v-list-item-action class="mr-2">-->
<!--                        <v-icon>{{ districtSelectIcon }}</v-icon>-->
<!--                      </v-list-item-action>-->
<!--                      <v-list-item-content>-->
<!--                        <v-list-item-title>Select All</v-list-item-title>-->
<!--                      </v-list-item-content>-->
<!--                    </v-list-item>-->
<!--                    <v-divider class="mt-2"></v-divider>-->
<!--                  </template>-->
<!--                  <template v-slot:item="data">-->
<!--                    <v-list-item-action class="mr-2">-->
<!--                      <v-icon v-if="data.attrs.inputValue">check_box</v-icon>-->
<!--                      <v-icon v-else>check_box_outline_blank</v-icon>-->
<!--                    </v-list-item-action>-->
<!--                    <v-list-item-content>-->
<!--                      <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">-->
<!--                        {{ data.item.org_name }}-->
<!--                      </v-list-item-title>-->
<!--                    </v-list-item-content>-->
<!--                  </template>-->
<!--                </v-autocomplete>-->

<!--                <v-autocomplete class="appts-to-fdc-pipeline-dropdown"-->
<!--                                v-model="officeModel"-->
<!--                                :items="officeData"-->
<!--                                item-text="org_name"-->
<!--                                item-value="org_id"-->
<!--                                label="Office"-->
<!--                                no-data-text="No offices available"-->
<!--                                outlined-->
<!--                                multiple-->
<!--                                dense-->
<!--                                @input="officeValuesChanged = true"-->
<!--                                hide-details-->
<!--                                return-object-->
<!--                                ref="officeSelect">-->
<!--                  <template v-slot:selection="{ item, index }">-->
<!--                  <span v-if="index === 0" class="grey&#45;&#45;text text-caption">-->
<!--                    {{ officeModel.length }} Checked-->
<!--                  </span>-->
<!--                  </template>-->
<!--                  <template v-if="officeData.length > 0" v-slot:prepend-item>-->
<!--                    <v-list-item @click="[officeValuesChanged = true, toggleSelectAllOffices()]">-->
<!--                      <v-list-item-action class="mr-2">-->
<!--                        <v-icon>{{ officeSelectIcon }}</v-icon>-->
<!--                      </v-list-item-action>-->
<!--                      <v-list-item-content>-->
<!--                        <v-list-item-title>Select All</v-list-item-title>-->
<!--                      </v-list-item-content>-->
<!--                    </v-list-item>-->
<!--                    <v-divider class="mt-2"></v-divider>-->
<!--                  </template>-->
<!--                  <template v-slot:item="data">-->
<!--                    <v-list-item-action class="mr-2">-->
<!--                      <v-icon v-if="data.attrs.inputValue">check_box</v-icon>-->
<!--                      <v-icon v-else>check_box_outline_blank</v-icon>-->
<!--                    </v-list-item-action>-->
<!--                    <v-list-item-content>-->
<!--                      <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">-->
<!--                        {{ data.item.org_name }}-->
<!--                      </v-list-item-title>-->
<!--                    </v-list-item-content>-->
<!--                  </template>-->
<!--                </v-autocomplete>-->
<!--                <v-autocomplete class="appts-to-fdc-pipeline-dropdown"-->
<!--                                v-model="repModel"-->
<!--                                :items="repData"-->
<!--                                item-text="name"-->
<!--                                item-value="user_position_id"-->
<!--                                label="Rep"-->
<!--                                no-data-text="No reps available"-->
<!--                                outlined-->
<!--                                multiple-->
<!--                                dense-->
<!--                                @input="repValuesChanged = true"-->
<!--                                hide-details-->
<!--                                return-object-->
<!--                                ref="repSelect">-->
<!--                  <template v-slot:selection="{ item, index }">-->
<!--                  <span v-if="index === 0" class="grey&#45;&#45;text text-caption">-->
<!--                    {{ repModel.length }} Checked-->
<!--                  </span>-->
<!--                  </template>-->
<!--                  <template v-if="repData.length > 0" v-slot:prepend-item>-->
<!--                    <v-list-item-->
<!--                      @click="[repValuesChanged = true, repDataSelectAll = !repDataSelectAll, toggleSelectAllReps()]">-->
<!--                      <v-list-item-action class="mr-2">-->
<!--                        <v-icon>{{ repSelectIcon }}</v-icon>-->
<!--                      </v-list-item-action>-->
<!--                      <v-list-item-content>-->
<!--                        <v-list-item-title>Select All</v-list-item-title>-->
<!--                      </v-list-item-content>-->
<!--                    </v-list-item>-->
<!--                    <v-divider class="mt-2"></v-divider>-->
<!--                  </template>-->
<!--                  <template v-slot:item="data">-->
<!--                    <v-list-item-action class="mr-2">-->
<!--                      <v-icon v-if="data.attrs.inputValue">check_box</v-icon>-->
<!--                      <v-icon v-else>check_box_outline_blank</v-icon>-->
<!--                    </v-list-item-action>-->
<!--                    <v-list-item-content>-->
<!--                      <v-list-item-title :style="{'text-decoration': data.item.active ? '' : 'line-through'}">-->
<!--                        {{ data.item.name }}-->
<!--                      </v-list-item-title>-->
<!--                    </v-list-item-content>-->
<!--                  </template>-->
<!--                </v-autocomplete>-->

<!--                <v-btn v-if="!isCloser && !isCloserMgr" id="all-reps-btn" outlined color="primary" @click="funnelAllReps">-->
<!--                  All Reps-->
<!--                </v-btn>-->
<!--              </div>-->
<!--            </div>-->

<!--            &lt;!&ndash; FUNNEL &ndash;&gt;-->
<!--            <div class="funnel-container">-->
<!--              &lt;!&ndash; FUNNEL BACKGROUND &ndash;&gt;-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0" id="appts-to-fdc-pipeline-funnel-background"-->
<!--                   :style="{'margin-top': showApptsToFdcPipelineCustomDates && windowInnerWidth >= 1135 ? '87px' :-->
<!--                                     showApptsToFdcPipelineCustomDates ? '82px' : windowInnerWidth <= 1070 ? '60px' : '' }"></div>-->

<!--              &lt;!&ndash; TODAY PERCENTAGE LINES &ndash;&gt;-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="today-upper-percentage-line" class="upper-percentage-line"></div>-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="today-lower-percentage-line" class="lower-percentage-line"></div>-->
<!--              &lt;!&ndash; TODAY PERCENTAGES &ndash;&gt;-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="today-upper-percentage" class="upper-percentage">{{ todayUpperPercentage }}%-->
<!--              </div>-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="today-lower-percentage" class="lower-percentage">{{ todayLowerPercentage }}%-->
<!--              </div>-->

<!--              &lt;!&ndash; WTD PERCENTAGE LINES &ndash;&gt;-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="wtd-upper-percentage-line" class="upper-percentage-line"></div>-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="wtd-lower-percentage-line" class="lower-percentage-line"></div>-->
<!--              &lt;!&ndash; WTD PERCENTAGES &ndash;&gt;-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="wtd-upper-percentage" class="upper-percentage">{{ wtdUpperPercentage }}%-->
<!--              </div>-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="wtd-lower-percentage" class="lower-percentage">{{ wtdLowerPercentage }}%-->
<!--              </div>-->

<!--              &lt;!&ndash; CUSTOM DATE RANGE PERCENTAGE LINES &ndash;&gt;-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="cdr-upper-percentage-line" class="upper-percentage-line"></div>-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="cdr-lower-percentage-line" class="lower-percentage-line"></div>-->
<!--              &lt;!&ndash; CUSTOM DATE RANGE PERCENTAGES &ndash;&gt;-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="cdr-upper-percentage" class="upper-percentage">{{ cdrUpperPercentage }}%-->
<!--              </div>-->
<!--              <div v-show="apptsToFdcPipelineData.length > 0 && viewSelect === 'apptDateCohort'"-->
<!--                   id="cdr-lower-percentage" class="lower-percentage">{{ cdrLowerPercentage }}%-->
<!--              </div>-->

<!--              <table class="funnel-table">-->
<!--                &lt;!&ndash; FUNNEL COLUMN HEADERS &ndash;&gt;-->
<!--                <tr class="funnel-tr">-->
<!--                  <th class="funnel-th view-btns">-->
<!--                    <div class="view-btns-container">-->
<!--                      <v-btn class="funnel-btn black&#45;&#45;text" @click="viewSelected('standard')"-->
<!--                             :class="{'white&#45;&#45;text': viewSelect === 'standard', 'primary&#45;&#45;text': viewSelect !== 'standard', 'elevation-2': viewSelect !== 'standard'}"-->
<!--                             :color="viewSelect === 'standard' ? 'primary' : 'secondary'">-->
<!--                        Standard View-->
<!--                      </v-btn>-->
<!--                      <v-btn class="funnel-btn black&#45;&#45;text" @click="viewSelected('apptDateCohort')"-->
<!--                             :class="{'white&#45;&#45;text': viewSelect === 'apptDateCohort', 'primary&#45;&#45;text': viewSelect !== 'apptDateCohort', 'elevation-2': viewSelect !== 'apptDateCohort'}"-->
<!--                             :color="viewSelect === 'apptDateCohort' ? 'primary' : 'secondary'">-->
<!--                        Appt Date Cohort-->
<!--                      </v-btn>-->
<!--                    </div>-->
<!--                  </th>-->
<!--                  <th class="funnel-th">TODAY</th>-->
<!--                  <th class="funnel-th">WEEK TO DATE</th>-->
<!--                  <th class="funnel-th">-->
<!--                    <div v-show="showApptsToFdcPipelineCustomDates" class="custom-dates-container">-->
<!--                      <v-menu v-model="appts_to_fdc_pipeline_menu1" transition="scale-transition" offset-y-->
<!--                              min-width="290px" :close-on-content-click="false">-->
<!--                        <template v-slot:activator="{ on }">-->
<!--                          <v-text-field class="custom-date-input" v-model="appts_to_fdc_pipeline_dt1_formatted" readonly-->
<!--                                        outlined dense hide-details v-on="on"></v-text-field>-->
<!--                        </template>-->
<!--                        <v-date-picker v-model="appts_to_fdc_pipeline_dt1" :max="appts_to_fdc_pipeline_dt2"-->
<!--                                       @input="updateApptsToFdcPipelineCalendar()"></v-date-picker>-->
<!--                      </v-menu>-->
<!--                      <span class="custom-date-span">-</span>-->
<!--                      <v-menu v-model="appts_to_fdc_pipeline_menu2" transition="scale-transition" offset-y-->
<!--                              min-width="290px" :close-on-content-click="false">-->
<!--                        <template v-slot:activator="{ on }">-->
<!--                          <v-text-field class="custom-date-input" v-model="appts_to_fdc_pipeline_dt2_formatted" readonly-->
<!--                                        outlined dense hide-details v-on="on"></v-text-field>-->
<!--                        </template>-->
<!--                        <v-date-picker v-model="appts_to_fdc_pipeline_dt2" :min="appts_to_fdc_pipeline_dt1"-->
<!--                                       @input="updateApptsToFdcPipelineCalendar()"></v-date-picker>-->
<!--                      </v-menu>-->
<!--                    </div>-->

<!--                    <v-menu v-model="apptsToFdcPipelineCustomSelectorIsOpen"-->
<!--                            :close-on-content-click="true"-->
<!--                            transition="scale-transition"-->
<!--                            offset-y>-->
<!--                      <template v-slot:activator="{ on }">-->
<!--                        <v-btn v-on="on" class="custom-dates-btn">{{ apptsToFdcPipelineDateRange.label }}-->
<!--                          <v-icon>mdi-menu-down</v-icon>-->
<!--                        </v-btn>-->
<!--                      </template>-->
<!--                      <v-list>-->
<!--                        <v-list-item v-for="(dateRange, index) in apptsToFdcPipelineDateRanges"-->
<!--                                     :key="index"-->
<!--                                     @click="chooseApptsToFdcPipelineDateRange(dateRange)">-->
<!--                          <v-list-item-title>{{ dateRange.label }}</v-list-item-title>-->
<!--                        </v-list-item>-->
<!--                      </v-list>-->
<!--                    </v-menu>-->
<!--                  </th>-->
<!--                </tr>-->
<!--                &lt;!&ndash; FUNNEL ROWS &ndash;&gt;-->
<!--                <tr class="funnel-tr" v-for="line in apptsToFdcPipelineData" :key="line.id"-->
<!--                    :class="{'main-row': [14,17,11,4,21,8].indexOf(line.id) !== -1, 'blue-sub-row': [16,18,20,24,3,6].indexOf(line.id) !== -1}">-->
<!--                  &lt;!&ndash; FUNNEL NAME &ndash;&gt;-->
<!--                  <td class="funnel-td funnel-line-name">{{ line.name }}</td>-->

<!--                  &lt;!&ndash; TODAY COUNT &ndash;&gt;-->
<!--                  <td class="funnel-td">-->
<!--                    <div v-if="[14,15,16,17,8].indexOf(line.id) === -1" class="funnel-data-container">-->
<!--                      &lt;!&ndash; CHECKED-IN COUNT &ndash;&gt;-->
<!--                      <div v-if="line.id === 25" class="checked-in-column-top">Checked-in</div>-->
<!--                      <div v-else-if="line.checked_in_today_count || line.checked_in_today_count === 0"-->
<!--                           class="checked-in-column-center clickable"-->
<!--                           :class="{'checked-in-column-line-overlap': [11,4].indexOf(line.id) !== -1}"-->
<!--                           @click="funnelDrilldown(line, 'today', viewSelect, true)">-->
<!--                        {{ line.checked_in_today_count }}-->
<!--                      </div>-->
<!--                      <div v-else class="no-checked-in-column-placeholder"></div>-->
<!--                      &lt;!&ndash;                  <div v-if="line.id === 21"&ndash;&gt;-->
<!--                      &lt;!&ndash;                       class="checked-in-column-bottom checked-in-column-line-overlap"&ndash;&gt;-->
<!--                      &lt;!&ndash;                       @click="funnelDrilldown(line.id, 'today', line.name, viewSelect, true)">&ndash;&gt;-->
<!--                      &lt;!&ndash;                    {{ line.checked_in_today_count }}&ndash;&gt;-->
<!--                      &lt;!&ndash;                  </div>&ndash;&gt;-->

<!--                      &lt;!&ndash; COUNT &ndash;&gt;-->
<!--                      <div @click="funnelDrilldown(line, 'today', viewSelect, false)" class="clickable">-->
<!--                        {{ line.today_count }}-->
<!--                      </div>-->
<!--                    </div>-->
<!--                    <div v-else class="funnel-data-container clickable">-->
<!--                      <div class="no-checked-in-column-placeholder"></div>-->
<!--                      <div class="clickable" @click="funnelDrilldown(line, 'today', viewSelect, false)">-->
<!--                        {{ line.today_count }}-->
<!--                      </div>-->
<!--                    </div>-->
<!--                  </td>-->

<!--                  &lt;!&ndash; WTD COUNT &ndash;&gt;-->
<!--                  <td class="funnel-td">-->
<!--                    <div v-if="[14,15,16,17,8].indexOf(line.id) === -1" class="funnel-data-container">-->
<!--                      &lt;!&ndash; CHECKED-IN COUNT &ndash;&gt;-->
<!--                      <div v-if="line.id === 25" class="checked-in-column-top">Checked-in</div>-->
<!--                      <div v-else-if="line.checked_in_today_count || line.checked_in_today_count === 0"-->
<!--                           class="checked-in-column-center clickable"-->
<!--                           :class="{'checked-in-column-line-overlap': [11,4].indexOf(line.id) !== -1}"-->
<!--                           @click="funnelDrilldown(line, 'wtd', viewSelect, true)">-->
<!--                        {{ line.checked_in_today_count }}-->
<!--                      </div>-->
<!--                      <div v-else class="no-checked-in-column-placeholder"></div>-->

<!--                      &lt;!&ndash; COUNT &ndash;&gt;-->
<!--                      <div @click="funnelDrilldown(line, 'wtd', viewSelect, false)" class="clickable">-->
<!--                        {{ line.week_to_date_count }}-->
<!--                      </div>-->
<!--                    </div>-->
<!--                    <div v-else class="funnel-data-container clickable">-->
<!--                      <div class="no-checked-in-column-placeholder"></div>-->
<!--                      <div class="clickable" @click="funnelDrilldown(line, 'wtd', viewSelect, false)">-->
<!--                        {{ line.week_to_date_count }}-->
<!--                      </div>-->
<!--                    </div>-->
<!--                  </td>-->


<!--                  &lt;!&ndash; CUSTOM DATE RANGE COUNT &ndash;&gt;-->
<!--                  <td class="funnel-td">-->
<!--                    <div v-if="[14,15,16,17,8].indexOf(line.id) === -1" class="funnel-data-container">-->
<!--                      &lt;!&ndash; CHECKED-IN COUNT &ndash;&gt;-->
<!--                      <div v-if="line.id === 25" class="checked-in-column-top">Checked-in</div>-->
<!--                      <div v-else-if="line.checked_in_today_count || line.checked_in_today_count === 0"-->
<!--                           class="checked-in-column-center clickable"-->
<!--                           :class="{'checked-in-column-line-overlap': [11,4,21].indexOf(line.id) !== -1}"-->
<!--                           @click="funnelDrilldown(line, 'custom', viewSelect, true)">-->
<!--                        {{ line.id === 21 ? '' : line.checked_in_custom_date_range_count }}-->
<!--                      </div>-->
<!--                      <div v-else class="no-checked-in-column-placeholder"></div>-->

<!--                      &lt;!&ndash; COUNT &ndash;&gt;-->
<!--                      <div @click="funnelDrilldown(line, 'custom', viewSelect, false)" class="clickable">-->
<!--                        {{ line.custom_date_range_count }}-->
<!--                      </div>-->
<!--                    </div>-->
<!--                    <div v-else class="funnel-data-container clickable">-->
<!--                      <div class="no-checked-in-column-placeholder"></div>-->
<!--                      <div class="clickable" @click="funnelDrilldown(line, 'custom', viewSelect, false)">-->
<!--                        {{ line.custom_date_range_count }}-->
<!--                      </div>-->
<!--                    </div>-->
<!--                  </td>-->
<!--                </tr>-->
<!--              </table>-->
<!--            </div>-->
<!--          </div>-->
    <!--      &lt;!&ndash; APPOINTMENTS TO FDC PIPELINE END &ndash;&gt;-->

    <!--      &lt;!&ndash; FUNNEL DRILLDOWN START &ndash;&gt;-->
                <v-dialog v-model="funnelDrilldownDialog" @input="closeFunnelDrilldownDialog">
                  <v-card id="funnel-drilldown">
                    <v-card-title class="mb-1">
                      <span id="funnel-drilldown-title">{{ funnelDrilldownTitle }}</span>
                      <v-spacer></v-spacer>
                      <v-btn color="primary" class="mr-4 mb-2"
                             @click="exportDrilldownCsv()">
                        Export
                      </v-btn>
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
                            <td>{{ item.metro_area || '' }}</td>
                            <td>{{ item.status_type || '' }}</td>
                            <td class="customer-name">{{ item.customer_name || '' }}</td>
                            <td>
                              <router-link text v-if="item.project_id && $store.getters.userHasFeature('PROJECTS')"
                                           :to="`/project/${item.project_id}/status`">
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
                      <v-btn class="white--text text-capitalize mr-4 mb-2" color="primary"
                             @click="closeFunnelDrilldownDialog">
                        Close
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </div>      <v-dialog v-model="funnelDrilldownDialog" @input="closeFunnelDrilldownDialog">
            <v-card id="funnel-drilldown">
              <v-card-title class="mb-1">
                <span id="funnel-drilldown-title">{{ funnelDrilldownTitle }}</span>
                <v-spacer></v-spacer>
                <v-btn color="primary" class="mr-4 mb-2"
                       @click="exportDrilldownCsv()">
                  Export
                </v-btn>
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
                      <td v-if="funnelDrilldownHeaders[1].show">{{ item.owner_name || '' }}</td>
                      <td v-if="funnelDrilldownHeaders[2].show"> {{ item.office || '' }}</td>
                      <td v-if="funnelDrilldownHeaders[3].show">{{ item.state || '' }}</td>
                      <td v-if="funnelDrilldownHeaders[4].show">{{ item.metro_area || '' }}</td>
                      <td v-if="funnelDrilldownHeaders[5].show">{{ item.status_type || '' }}</td>
                      <td v-if="funnelDrilldownHeaders[6].show" class="customer-name">{{ item.customer_name || '' }}</td>
                      <td v-if="funnelDrilldownHeaders[7].show">
                        <router-link text v-if="item.project_id && $store.getters.userHasFeature('PROJECTS')"
                                     :to="`/project/${item.project_id}/status`">
                          {{ item.project_id }}
                        </router-link>
                        <div v-else>{{ item.project_id || '' }}</div>
                      </td>
                      <td v-if="selectedFunnel.funnel_type_id === 1 && funnelDrilldownHeaders[8].show">
                        <router-link text v-if="item.project_id && item.project_process_step_id && item.project_process_step_event_id && $store.getters.userHasFeature('EVENTS')"
                                     :to="`/project/${item.project_id}/processStep/${item.project_process_step_id}/event/${item.project_process_step_event_id}`">
                          {{ item.project_process_step_event_id }}
                        </router-link>
                        <div v-else>{{ item.project_process_step_event_id || '' }}</div>
                      </td>
                      <!--                <td :class="item.stage">{{ item.stage || '' }}</td>-->
                      <td v-if="funnelDrilldownHeaders[9].show" :class="item.source_name_class">{{ item.source_name || '' }}</td>
                      <td v-if="funnelDrilldownHeaders[10].show" :class="item.system_size_class">{{ item.system_size || '' }}</td>
                      <td v-if="funnelDrilldownHeaders[11].show" :class="item.financier_class">{{ item.financier || '' }}</td>
                      <td v-if="funnelDrilldownHeaders[12].show">{{ item.appointment_date | formatDate('timestamp', 'MM/DD/YYYY') }}</td>
                      <td v-if="funnelDrilldownHeaders[13].show">{{ item.cancelled_date | formatDate('date', 'MM/DD/YYYY') }}</td>
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

    <ConfirmationDialog v-if="selectingCustomDates" :disableConfirm="customDate.startDate === null || customDate.endDate === null || customDate.startDate?.length === 0 || customDate.endDate?.length === 0" :open-dialog="selectingCustomDates" @confirm="applyCustomDates()" @cancel="cancelCustomDialogue()" @close-dialog="selectingCustomDates = false">
      <template v-slot:title>Custom Date Range</template>
      <div>
        <DatetimePickerInput
          v-model="customDate.startDate"
          :timezone="timezone"
          :type="'date'"
          :format="'MMMM DD, YYYY'"
          input-format="HH:mm:ss"
          label="Start Date"
        />
        <DatetimePickerInput
          v-model="customDate.endDate"
          :timezone="timezone"
          :type="'date'"
          :format="'MMMM DD, YYYY'"
          input-format="HH:mm:ss"
          label="End Date"
        />
      </div>
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Confirm</template>

    </ConfirmationDialog>

  </v-container>
</template>

<script>
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import moment from 'moment'
import constants from '@/helpers/constants'
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import SpinnerInline from '@/components/SpinnerInline'
import {saveAs} from 'file-saver'
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
      viewFdcTrends: false,
      viewTrends: false,
      disableTrends: false,
      firstDateRange: 2,
      secondDateRange: null,
      thirdDateRange: null,
      fdcFirstDateRange: 2,
      fdcSecondDateRange: null,
      fdcThirdDateRange: null,
      firstCustom: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: "",
        isActive: false
      },
      secondCustom: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: "",
        isActive: false
      },
      thirdCustom: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: ""
      },
      fdcFirstCustom: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: "",
        isActive: false
      },
      fdcSecondCustom: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: "",
        isActive: false
      },
      fdcThirdCustom: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: ""
      },
      firstPeriod: null,
      secondPeriod: null,
      thirdPeriod: null,
      isLoading: true,
      isBrCorporateUser: this.$store.state.user.details.companyId === 2,
      openFirstMenu: false,
      openSecondMenu: false,
      openThirdMenu: false,
      fdcOpenFirstMenu: false,
      fdcOpenSecondMenu: false,
      fdcOpenThirdMenu: false,
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
      fdcHeaders: [],
      drilldownData: [],
      apptsCreatedPipelineLoaded: false,
      apptsToFdcPipelineLoaded: false,
      appointmentTypes: [],
      appointmentTypesModel: [],
      funnelsWereLoaded: false,
      currentQuarter: moment().quarter(),
      closerOffices: [],
      selectedCloserOffice: null,
      leadAllocationRankingData: [],
      officeFdcRankingData: [],
      officeRankingData: [],
      topRepsData: [],
      customColumn: 1,
      customTable: 'apptsCreated',
      milestonesExpanded: true,
      apptsCreatedExpanded: true,
      fdcPipelineExpanded: true,
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
      fdcExpandableMilestones: [0, 3, 11, 14],
      milestonesSwitching: false,
      hideInactiveReps: false,
      fdcMilestonesExpanded: [true, true, true, true],
      brsProvidedSourceModel: [],
      leadsCreatedSourceModel: [],
      leadsCreatedSourceData: [],
      fdcSourceModel: [],
      fdcSourceData: [],
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
      appointmentTypesSelectAll: false,
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
      },
      column2Values: [],
      column3Values: [],
      fdcColumn2Values: [],
      fdcColumn3Values: [],
      selectingCustomDates: false,
      customDate: {
        startDate: "",
        endDate: "",
        trendStart: "",
        trendEnd: ""
      },
      timezone: 'US/Mountain',
    }
  },
  computed: {
    filteredApptsCreatedPipelineData() {
      if(!this.milestonesExpanded){
        return this.apptsCreatedPipelineData.filter(dv => dv.display_order < 3)
      }
      return this.apptsCreatedPipelineData
    },
    filteredFdcPipelineData() {
      return this.apptsToFdcPipelineData?.filter((data, index) => {
        return this.fdcExpandableMilestones?.includes(index)
      })
    },
    funnelDrilldownHeaders() {
      return [
        {text: '', value: '', show: true, sortable: false, width: 25, optional: false}, // 0
        {text: 'Owner', value: 'owner_name', show: true, width: 90, optional: false}, // 1
        {text: 'Office', value: 'office', show: true, width: 75, optional: false}, // 2
        {text: 'State', value: 'state', show: true, width: 75, optional: false}, // 3
        {text: 'Metro', value: 'metro_area', show: true, width: 75, optional: false}, // 4
        {text: 'Status', value: 'status_type', show: true, width: 75, optional: false}, // 5
        {text: 'Name', value: 'customer_name', show: true, width: 90, optional: false}, // 6
        {text: 'Project ID', value: 'project_id', show: true, width: 85, optional: false}, // 7
        {
          text: 'Event ID',
          value: 'project_process_step_event_id',
          show: this.selectedFunnel.funnel_type_id === 1,
          width: 85,
          optional: false
        }, // 8
        {text: 'Source', value: 'source_name', show: true, width: 85, optional: false}, // 9
        {text: 'System Size', value: 'system_size', show: true, width: 110, optional: false}, // 10
        {text: 'Financier', value: 'financier', show: true, width: 95, optional: false}, // 11
        {
          text: 'Appointment Date',
          value: 'appointment_date',
          show: true,
          width: 145,
          optional: false,
          dateType: 'timestamp',
          dateFormat: 'MM/DD/YYYY'
        }, // 12
        {
          text: 'Cancelled Date',
          value: 'cancelled_date',
          show: true,
          width: 130,
          optional: false,
          dateType: 'date',
          dateFormat: 'MM/DD/YYYY'
        }, // 13
        {
          text: 'Date Created',
          value: 'date_created',
          show: false,
          width: 115,
          optional: true,
          dateType: 'timestamp',
          dateFormat: 'MM/DD/YYYY'
        }, // 14
        {text: 'Appointment Outcome', value: 'appointment_outcome', show: false, width: 170, optional: true}, // 15
        {
          text: 'Credit Decision Date',
          value: 'credit_decision_date',
          show: false,
          width: 160,
          optional: true,
          dateType: 'date',
          dateFormat: 'MM/DD/YYYY'
        }, // 16
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
        {
          text: 'Site Survey Date',
          value: 'site_survey_completed_date',
          show: false,
          width: 155,
          optional: true,
          dateType: 'timestamp',
          dateFormat: 'MM/DD/YYYY'
        }, // 20
        {
          text: 'FD Sent to Homeowner Date',
          value: 'final_design_sent_to_homeowner_date',
          show: false,
          width: 200,
          optional: true, dateType: 'timestamp', dateFormat: 'MM/DD/YYYY'
        }, // 21
        {
          text: 'Final Design Approved',
          value: 'final_design_signed_date',
          show: false,
          width: 165,
          optional: true,
          dateType: 'date',
          dateFormat: 'MM/DD/YYYY'
        }, // 22
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
        {
          text: 'Cash Down Payment',
          value: 'cash_down_payment',
          show: false,
          width: 160,
          optional: true,
          dateType: 'date',
          dateFormat: 'MM/DD/YYYY'
        }, // 26
        {
          text: 'Final Design Completed',
          value: 'final_design_complete_date',
          show: false,
          width: 160,
          optional: true,
          dateType: 'date',
          dateFormat: 'MM/DD/YYYY'
        }, // 27
        {
          text: 'Substantial Completion Date',
          value: 'substantial_completion_date',
          show: false,
          width: 175,
          optional: true, dateType: 'date', dateFormat: 'MM/DD/YYYY'
        }, // 28
        {
          text: 'Checked In Time',
          value: 'checked_in_time',
          show: false,
          width: 160,
          optional: true,
          dateType: 'timestamp',
          dateFormat: 'MM/DD/YYYY h:mm a'
        }, // 29
      ]
    },
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
    selectAllLeadsCreatedSources() {
      return this.leadsCreatedSourceModel.length === this.leadsCreatedSourceData.length
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
    async resetFilters(){
      this.areaModel = []
      this.regionModel = []
      this.districtModel = []
      this.officeModel = []
      this.repModel = []
      this.repData = cloneDeep(this.repDataMaster)
    },
    async exportCsv () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let filename = 'CompanyDashboard.csv'
        let csvData = ' , '
        if(this.dropdownValues.find(x => x.id === this.firstDateRange).name==='PERIOD'){
          csvData += this.dropdownValues.find(x => x.id === this.firstDateRange).periodList[this.firstPeriod].shortLabel;
        }
        else
        {
          csvData += ((this.dropdownValues.find(x => x.id === this.firstDateRange).name === 'CUSTOM') ? this.firstCustom.name : this.dropdownValues.find(x => x.id === this.firstDateRange).friendlyName);
        }
        if(this.viewTrends){
          csvData += ', ' +  'Trend 1'
        }
        if(this.secondDateRange){
          if(this.dropdownValues.find(x => x.id === this.secondDateRange).name==='PERIOD'){
            csvData += ' , ' + this.dropdownValues.find(x => x.id === this.secondDateRange).periodList[this.secondPeriod].shortLabel;
          }
          else
          {
            csvData += ', ' + ((this.dropdownValues.find(x => x.id === this.secondDateRange).name === 'CUSTOM') ? this.secondCustom.name : this.dropdownValues.find(x => x.id === this.secondDateRange).friendlyName);
          }
          if(this.viewTrends){
            csvData += ', ' +  'Trend 2'
          }
        }
        if(this.thirdDateRange){
          if(this.dropdownValues.find(x => x.id === this.thirdDateRange).name==='PERIOD'){
            csvData += ' , ' + this.dropdownValues.find(x => x.id === this.thirdDateRange).periodList[this.thirdPeriod].shortLabel;
          }
          else
          {
            csvData += ', ' + ((this.dropdownValues.find(x => x.id === this.thirdDateRange).name === 'CUSTOM') ? this.thirdCustom.name : this.dropdownValues.find(x => x.id === this.thirdDateRange).friendlyName);
          }
          if(this.viewTrends){
            csvData += ', ' +  'Trend 3'
          }
        }
        csvData += '\n';

        this.apptsCreatedPipelineData.forEach((p, i) => {
            csvData += p.name + ',' + (p.leads_created_count ? p.leads_created_count : 0);
            if (this.viewTrends) {
              csvData += ', ' + (p.trend ? p.trend : 0) + '%';
            }
            if (this.secondDateRange) {
              csvData += ', ' + (this.column2Values[i].leads_created_count ? this.column2Values[i].leads_created_count : 0)
              if (this.viewTrends) {
                csvData += ', ' + (this.column2Values[i].trend ? this.column2Values[i].trend : 0) + '%';
              }
            }
            if (this.thirdDateRange) {
              csvData += ', ' + (this.column3Values[i].leads_created_count ? this.column3Values[i].leads_created_count : 0)
              if (this.viewTrends) {
                csvData += ', ' + (this.column3Values[i].trend ? this.column3Values[i].trend : 0) + '%';
              }
            }
            csvData += '\n';
        })


        let blob = new Blob([csvData], {
          type: 'text/csv;charset=utf-8'
        });

        saveAs(blob, filename);
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Exporting Residual Review')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    changeSources(){
      if(this.firstDateRange != null) {
        this.apptsCreatedPipelineLoad(1);
      }
      if(this.secondDateRange != null) {
        this.apptsCreatedPipelineLoad(2);
      }
      if(this.thirdDateRange != null) {
        this.apptsCreatedPipelineLoad(3)
      }
    },
    expandMilestones(){
      this.milestonesExpanded = true;
    },
    hideMilestones(){
      this.milestonesExpanded = false;
    },
    async getDropdownValues() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const params = {
          today: moment().format('YYYY-MM-DD')
        }

        const {data, status} = await getRequestWithParams('/closerDashboard/dropdownValues', {params}, 'blueraven', [])
        this.dropdownValues = data;
        this.isLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
        this.isLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAppointmentTypes() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        const params = {
          today: moment().format('YYYY-MM-DD')
        }

        const {data, status} = await getRequest('/closerDashboard/appointmentTypes', 'blueraven', [])
        this.appointmentTypes = data;
        this.appointmentTypesModel = cloneDeep(this.appointmentTypes)
        this.isLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving data')
        this.isLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async openDrilldown(item, column) {
      if(column === 1){
        if(this.dropdownValues.find(x => x.id === this.firstDateRange).name === 'PERIOD'){
          this.startDate = moment(this.dropdownValues.find(x => x.id === this.firstDateRange).periodList[this.firstPeriod].startDate).format('YYYY-MM-DDTHH:mm:ss');
          this.endDate = moment(this.dropdownValues.find(x => x.id === this.firstDateRange).periodList[this.firstPeriod].endDate).format('YYYY-MM-DDTHH:mm:ss');
        }
        else {
          this.startDate = this.dropdownValues.find(x => x.id === this.firstDateRange).startDate ? this.dropdownValues.find(x => x.id === this.firstDateRange).startDate : moment(this.firstCustom.startDate).format('YYYY-MM-DDTHH:mm:ss')
          this.endDate = this.dropdownValues.find(x => x.id === this.firstDateRange).endDate ? this.dropdownValues.find(x => x.id === this.firstDateRange).endDate : moment(this.firstCustom.endDate).format('YYYY-MM-DDTHH:mm:ss')
        }
      }
      else if(column === 2){
        if(this.dropdownValues.find(x => x.id === this.secondDateRange).name === 'PERIOD'){
          this.startDate = moment(this.dropdownValues.find(x => x.id === this.secondDateRange).periodList[this.secondPeriod].startDate).format('YYYY-MM-DDTHH:mm:ss');
          this.endDate = moment(this.dropdownValues.find(x => x.id === this.secondDateRange).periodList[this.secondPeriod].endDate).format('YYYY-MM-DDTHH:mm:ss');
        }
        else {
          this.startDate = this.dropdownValues.find(x => x.id === this.secondDateRange).startDate ? this.dropdownValues.find(x => x.id === this.secondDateRange).startDate : moment(this.secondCustom.startDate).format('YYYY-MM-DDTHH:mm:ss')
          this.endDate = this.dropdownValues.find(x => x.id === this.secondDateRange).endDate ? this.dropdownValues.find(x => x.id === this.secondDateRange).endDate : moment(this.secondCustom.endDate).format('YYYY-MM-DDTHH:mm:ss')
        }
      }
      else if(column === 3){
        if(this.dropdownValues.find(x => x.id === this.thirdDateRange).name === 'PERIOD'){
          this.startDate = moment(this.dropdownValues.find(x => x.id === this.thirdDateRange).periodList[this.thirdPeriod].startDate).format('YYYY-MM-DDTHH:mm:ss');
          this.endDate = moment(this.dropdownValues.find(x => x.id === this.thirdDateRange).periodList[this.thirdPeriod].endDate).format('YYYY-MM-DDTHH:mm:ss');
        }
        else {
          this.startDate = this.dropdownValues.find(x => x.id === this.thirdDateRange).startDate ? this.dropdownValues.find(x => x.id === this.thirdDateRange).startDate : moment(this.thirdCustom.startDate).format('YYYY-MM-DDTHH:mm:ss')
          this.endDate = this.dropdownValues.find(x => x.id === this.thirdDateRange).endDate ? this.dropdownValues.find(x => x.id === this.thirdDateRange).endDate : moment(this.thirdCustom.endDate).format('YYYY-MM-DDTHH:mm:ss')
        }
      }
      if((moment(this.endDate).diff(moment(this.startDate), 'days')+1) > 100){
        return;
      }
      this.selectedMilestone = item
      await this.getDrilldownHeaders()
      await this.getDrilldownData(column)
      this.showDrilldown = true
    },
    changeFdcDropdownSelection: async function (dropdown) {
      this.customTable = 'FDC'
      if (dropdown === 1) {
        let result = cloneDeep(this.dropdownValues.find(x => x.id === this.fdcFirstDateRange))
        if (result === null) {
          return null;
        }
        if (result.startDate === null) {
          if (!this.fdcFirstCustom.isActive) {
            if (result.name === 'CUSTOM') {
              this.customColumn = 1;
              if (this.fdcFirstCustom.startDate.toString().length > 0) {
                this.customDate.startDate = this.fdcFirstCustom.startDate.format('YYYY-MM-DD').toString();
              }
              if (this.fdcFirstCustom.endDate.toString().length > 0) {
                this.customDate.endDate = this.fdcFirstCustom.endDate.format('YYYY-MM-DD').toString();
              }
              this.selectingCustomDates = true;
              return;
            } else if (result.name === 'PERIOD') {
              result.startDate = result.periodList[this.firstPeriod].startDate;
              result.endDate = result.periodList[this.firstPeriod].endDate;
              if (this.firstPeriod != result.periodList.length - 1) {
                result.trendStart = result.periodList[this.firstPeriod + 1].startDate;
                result.trendEnd = result.periodList[this.firstPeriod + 1].endDate;
              } else {
                delete result.trendStart;
                delete result.trendEnd;
              }
            }
          } else {
            result = cloneDeep(this.fdcFirstCustom);
            this.resetCustomDate();
            this.fdcFirstCustom.isActive = false;
          }
        } else if (result.name === 'ALL_TIME') {
          delete result.trendStart;
          delete result.trendEnd;
        }
        await this.apptsToFdcPipelineLoad(1);
      } else if (dropdown === 2) {
        let result = cloneDeep(this.dropdownValues.find(x => x.id === this.fdcSecondDateRange))
        if (result === null) {
          return null;
        }
        if (result.startDate === null) {
          if (!this.fdcSecondCustom.isActive) {
            if (result.name === 'CUSTOM') {
              this.customColumn = 2;
              if (this.fdcSecondCustom.startDate.toString().length > 0) {
                this.customDate.startDate = this.fdcSecondCustom.startDate.format('YYYY-MM-DD').toString();
              }
              if (this.fdcSecondCustom.endDate.toString().length > 0) {
                this.customDate.endDate = this.fdcSecondCustom.endDate.format('YYYY-MM-DD').toString();
              }
              this.selectingCustomDates = true;
              return;
            } else if (result.name === 'PERIOD') {
              result.startDate = result.periodList[this.secondPeriod].startDate;
              result.endDate = result.periodList[this.secondPeriod].endDate;
              if (this.secondPeriod != result.periodList.length - 1) {
                result.trendStart = result.periodList[this.secondPeriod + 1].startDate;
                result.trendEnd = result.periodList[this.secondPeriod + 1].endDate;
              } else {
                delete result.trendStart;
                delete result.trendEnd;
              }
            }
          } else {
            result = cloneDeep(this.fdcSecondCustom);
            this.resetCustomDate();
            this.fdcSecondCustom.isActive = false;
          }
        } else if (result.name === 'ALL_TIME') {
          delete result.trendStart;
          delete result.trendEnd;
        }
        await this.apptsToFdcPipelineLoad(2);
      } else if (dropdown === 3) {
        let result = cloneDeep(this.dropdownValues.find(x => x.id === this.fdcThirdDateRange))
        if (result == null) {
          return null;
        }
        if (result.startDate === null) {
          if (!this.fdcThirdCustom.isActive) {
            if (result.name === 'CUSTOM') {
              this.customColumn = 3;
              if (this.fdcThirdCustom.startDate.toString().length > 0) {
                this.customDate.startDate = this.fdcThirdCustom.startDate.format('YYYY-MM-DD').toString();
              }
              if (this.fdcThirdCustom.endDate.toString().length > 0) {
                this.customDate.endDate = this.fdcThirdCustom.endDate.format('YYYY-MM-DD').toString();
              }
              this.selectingCustomDates = true;
              return;
            } else if (result.name === 'PERIOD') {
              result.startDate = result.periodList[this.thirdPeriod].startDate;
              result.endDate = result.periodList[this.thirdPeriod].endDate;
              if (this.thirdPeriod != result.periodList.length - 1) {
                result.trendStart = result.periodList[this.thirdPeriod + 1].startDate;
                result.trendEnd = result.periodList[this.thirdPeriod + 1].endDate;
              } else {
                delete result.trendStart;
                delete result.trendEnd;
              }
            }
          } else {
            result = cloneDeep(this.fdcThirdCustom);
            this.resetCustomDate();
          }
        } else if (result.name === 'ALL_TIME') {
          delete result.trendStart;
          delete result.trendEnd;
        }
        await this.apptsToFdcPipelineLoad(3);
      }
    },

    changeDropdownSelection: async function (dropdown) {
      this.customTable = 'apptsCreated'
      if (dropdown === 1) {
        let result = cloneDeep(this.dropdownValues.find(x => x.id === this.firstDateRange))
        if (result === null) {
          return null;
        }
        if (result.startDate === null) {
          if (!this.firstCustom.isActive) {
            if (result.name === 'CUSTOM') {
              this.customColumn = 1;
              if (this.firstCustom.startDate.toString().length > 0) {
                this.customDate.startDate = this.firstCustom.startDate.format('YYYY-MM-DD').toString();
              }
              if (this.firstCustom.endDate.toString().length > 0) {
                this.customDate.endDate = this.firstCustom.endDate.format('YYYY-MM-DD').toString();
              }
              this.selectingCustomDates = true;
              return;
            } else if (result.name === 'PERIOD') {
              result.startDate = result.periodList[this.firstPeriod].startDate;
              result.endDate = result.periodList[this.firstPeriod].endDate;
              if (this.firstPeriod != result.periodList.length - 1) {
                result.trendStart = result.periodList[this.firstPeriod + 1].startDate;
                result.trendEnd = result.periodList[this.firstPeriod + 1].endDate;
              } else {
                delete result.trendStart;
                delete result.trendEnd;
              }
            }
          } else {
            result = cloneDeep(this.firstCustom);
            this.resetCustomDate();
            this.firstCustom.isActive = false;
          }
        } else if (result.name === 'ALL_TIME') {
          delete result.trendStart;
          delete result.trendEnd;
        }
        await this.apptsCreatedPipelineLoad(1);
      } else if (dropdown === 2) {
        let result = cloneDeep(this.dropdownValues.find(x => x.id === this.secondDateRange))
        if (result === null) {
          return null;
        }
        if (result.startDate === null) {
          if (!this.secondCustom.isActive) {
            if (result.name === 'CUSTOM') {
              this.customColumn = 2;
              if (this.secondCustom.startDate.toString().length > 0) {
                this.customDate.startDate = this.secondCustom.startDate.format('YYYY-MM-DD').toString();
              }
              if (this.secondCustom.endDate.toString().length > 0) {
                this.customDate.endDate = this.secondCustom.endDate.format('YYYY-MM-DD').toString();
              }
              this.selectingCustomDates = true;
              return;
            } else if (result.name === 'PERIOD') {
              result.startDate = result.periodList[this.secondPeriod].startDate;
              result.endDate = result.periodList[this.secondPeriod].endDate;
              if (this.secondPeriod != result.periodList.length - 1) {
                result.trendStart = result.periodList[this.secondPeriod + 1].startDate;
                result.trendEnd = result.periodList[this.secondPeriod + 1].endDate;
              } else {
                delete result.trendStart;
                delete result.trendEnd;
              }
            }
          } else {
            result = cloneDeep(this.secondCustom);
            this.resetCustomDate();
            this.secondCustom.isActive = false;
          }
        } else if (result.name === 'ALL_TIME') {
          delete result.trendStart;
          delete result.trendEnd;
        }
        await this.apptsCreatedPipelineLoad(2);
      } else if (dropdown === 3) {
        let result = cloneDeep(this.dropdownValues.find(x => x.id === this.thirdDateRange))
        if (result == null) {
          return null;
        }
        if (result.startDate === null) {
          if (!this.thirdCustom.isActive) {
            if (result.name === 'CUSTOM') {
              this.customColumn = 3;
              if (this.thirdCustom.startDate.toString().length > 0) {
                this.customDate.startDate = this.thirdCustom.startDate.format('YYYY-MM-DD').toString();
              }
              if (this.thirdCustom.endDate.toString().length > 0) {
                this.customDate.endDate = this.thirdCustom.endDate.format('YYYY-MM-DD').toString();
              }
              this.selectingCustomDates = true;
              return;
            } else if (result.name === 'PERIOD') {
              result.startDate = result.periodList[this.thirdPeriod].startDate;
              result.endDate = result.periodList[this.thirdPeriod].endDate;
              if (this.thirdPeriod != result.periodList.length - 1) {
                result.trendStart = result.periodList[this.thirdPeriod + 1].startDate;
                result.trendEnd = result.periodList[this.thirdPeriod + 1].endDate;
              } else {
                delete result.trendStart;
                delete result.trendEnd;
              }
            }
          } else {
            result = cloneDeep(this.thirdCustom);
            this.resetCustomDate();
          }
        } else if (result.name === 'ALL_TIME') {
          delete result.trendStart;
          delete result.trendEnd;
        }
        await this.apptsCreatedPipelineLoad(3);
      }
    },
    getDropdownById(id) {
      return this.dropdownValues.find(x => x.id === id)
    },
    exportDrilldownCsv() {
      let csv = ''

      this.visibleFunnelDrilldownHeaders().forEach(h => {
        if (h.text !== '') {
          return csv += `${h.text},`
        }
      })
      csv += `\n`

      this.funnelDrilldownData.forEach(o => {

        this.visibleFunnelDrilldownHeaders().forEach(h => {
          if (h.text !== '') {
            if (h.dateType !== null && h.dateType !== undefined) {
              //if it is a date it needs to be formatted here
              csv += '"' + `${o[h.value] === null || o[h.value] === undefined ? '' : this.$filters.formatDate(o[h.value], h.dateType, h.dateFormat)}` + '",'
            } else {
              csv += '"' + `${o[h.value] === null || o[h.value] === undefined ? '' : o[h.value]}` + '",'
            }
          }
        })
        csv += `\n`
      })

      const blob = new Blob([csv], {type: 'text/csv;charset=utf-8'})
      saveAs(blob, `${this.funnelDrilldownTitle}.csv`)
    },
    itemRowBackground(item) {
      return item.display_order < 3 ? 'shaded-row' : ''
    },
    fdcRowBackground(item) {
      return this.fdcExpandableMilestones.includes(item.display_order-4) ? 'shaded-row' : ''
    },
    fdcExpandMilestone(index){
      this.milestonesSwitching = true
      this.fdcMilestonesExpanded[this.fdcExpandableMilestones.indexOf(index)] = true
      this.milestonesSwitching = false

    },
    fdcHideMilestone(index){
      this.milestonesSwitching = true
      this.fdcMilestonesExpanded[this.fdcExpandableMilestones.indexOf(index)] = false
      this.milestonesSwitching = false
    },
    visibleFunnelDrilldownHeaders() {
      return this.funnelDrilldownHeaders.filter(header => header.show === true)
    },
    resetScrollBarPosition() {
      // reset scroll bar position to top
      this.$refs.closerDashContainer.scrollTop = 0
    },

    /* FUNNEL-RELATED CODE START */
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
          this.apptsCreatedPipelineLoad(1)
        }
      })
    },
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
        this.apptsToFdcPipelineLoad(1)
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
      this.apptsToFdcPipelineLoad(1)
    },

    loadSources() {
      try {
        getRequest('/closerDashboard/getBrsProvidedSources', 'blueraven', []).then(res => {
          let filteredData = res.data.filter((data) => data.sourceName != 'EPC')
          if(this.isCloser || this.isCloserMgr){
            res.data = filteredData
          }
          this.brsProvidedSourceData = res.data
          this.leadsCreatedSourceData = res.data
          this.fdcSourceData = res.data
          this.brsProvidedSourceModel = cloneDeep(filteredData)
          this.leadsCreatedSourceModel = cloneDeep(filteredData);
          this.fdcSourceModel = cloneDeep(filteredData);
          getRequest('/closerDashboard/getSelfGenSources', 'blueraven', []).then(res => {
            this.selfGenSourceData = res.data
            this.selfGenSourceModel = cloneDeep(this.selfGenSourceData)
            this.apptsCreatedPipelineLoad(1)
          })
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving lists of sources')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },

    async apptsCreatedPipelineLoad(column) {
      this.apptsCreatedPipelineLoaded = false
      let brsProvidedSources = []
      let selfGenSources = []
      let leadsCreatedSources = []
      let dateSelected = null

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

      this.leadsCreatedSourceModel.forEach(leadsCreatedSource => {
        if (leadsCreatedSource.sourceId) {
          leadsCreatedSources.push(leadsCreatedSource.sourceId)
        }
      })

      if(column === 1){
        dateSelected = this.getDropdownById(this.firstDateRange)
        if(dateSelected.periodList != null){
          dateSelected.startDate = dateSelected.periodList[this.firstPeriod].startDate;
          dateSelected.endDate = dateSelected.periodList[this.firstPeriod].endDate;
          dateSelected.trendStart = dateSelected.periodList[this.firstPeriod].trendStart;
          dateSelected.trendEnd = dateSelected.periodList[this.firstPeriod].trendEnd;
        }
        else if(dateSelected.name === 'CUSTOM'){
          dateSelected = this.firstCustom;
        }
      }

      else if(column === 2){
        dateSelected = this.getDropdownById(this.secondDateRange)
        if(dateSelected.periodList != null){
          dateSelected.startDate = dateSelected.periodList[this.secondPeriod].startDate;
          dateSelected.endDate = dateSelected.periodList[this.secondPeriod].endDate;
          dateSelected.trendStart = dateSelected.periodList[this.secondPeriod].trendStart;
          dateSelected.trendEnd = dateSelected.periodList[this.secondPeriod].trendEnd;
        }
        else if(dateSelected.name === 'CUSTOM'){
          dateSelected = this.secondCustom;
        }
      }

      else if(column === 3){
        dateSelected = this.getDropdownById(this.thirdDateRange)
        if(dateSelected.periodList != null){
          dateSelected.startDate = dateSelected.periodList[this.thirdPeriod].startDate;
          dateSelected.endDate = dateSelected.periodList[this.thirdPeriod].endDate;
          dateSelected.trendStart = dateSelected.periodList[this.thirdPeriod].trendStart;
          dateSelected.trendEnd = dateSelected.periodList[this.thirdPeriod].trendEnd;
        }
        else if(dateSelected.name === 'CUSTOM'){
          dateSelected = this.thirdCustom;
        }
      }

      const requestBody = {
        brsProvidedSources: brsProvidedSources,
        selfGenSources: selfGenSources,
        leadsCreatedSources: leadsCreatedSources,
        start: dateSelected.startDate,
        end: dateSelected.endDate,
        trendStart: dateSelected.trendStart,
        trendEnd: dateSelected.trendEnd
      }

      this.apptsCreatedPipelineDataLoading = true
      try {
        await postRequest('/closerDashboard/funnel/apptsCreatedPipeline', requestBody, 'blueraven', []).then(res => {
          if(column == 1) {
            this.apptsCreatedPipelineData = orderBy(res.data, row => row.display_order)
          }
          else if(column == 2) {
            this.column2Values = orderBy(res.data, row => row.display_order)
          }
          else if(column == 3) {
            this.column3Values = orderBy(res.data, row => row.display_order)
          }
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
    async applyCustomDates(){
      if(this.customTable === 'apptsCreated') {
        if (this.customColumn === 1) {
          this.firstCustom.startDate = moment(this.customDate.startDate);
          this.firstCustom.endDate = moment(this.customDate.endDate);
          let dateDiff = this.firstCustom.endDate.diff(this.firstCustom.startDate, 'days');
          this.firstCustom.trendEnd = this.firstCustom.startDate.clone().subtract(1, 'days');
          this.firstCustom.trendStart = this.firstCustom.trendEnd.clone().subtract(dateDiff, 'days');
          this.getDropdownById(this.firstDateRange).trendText = moment(this.firstCustom.trendStart).format('MM/DD/YYYY') + ' - ' + moment(this.firstCustom.trendEnd).format('MM/DD/YYYY');
          this.firstCustom.name = moment(this.firstCustom.startDate).format('MM/DD/YY') + '-' + moment(this.firstCustom.endDate).format('MM/DD/YY');
        } else if (this.customColumn === 2) {
          this.secondCustom.startDate = moment(this.customDate.startDate);
          this.secondCustom.endDate = moment(this.customDate.endDate);
          let dateDiff = this.secondCustom.endDate.diff(this.secondCustom.startDate, 'days');
          this.secondCustom.trendEnd = this.secondCustom.startDate.clone().subtract(1, 'days');
          this.secondCustom.trendStart = this.secondCustom.trendEnd.clone().subtract(dateDiff, 'days');
          this.getDropdownById(this.secondDateRange).trendText = moment(this.secondCustom.trendStart).format('MM/DD/YYYY') + ' - ' + moment(this.secondCustom.trendEnd).format('MM/DD/YYYY');
          this.secondCustom.name = moment(this.secondCustom.startDate).format('MM/DD/YY') + '-' + moment(this.secondCustom.endDate).format('MM/DD/YY');
        } else if (this.customColumn === 3) {
          this.thirdCustom.startDate = moment(this.customDate.startDate);
          this.thirdCustom.endDate = moment(this.customDate.endDate);
          let dateDiff = this.thirdCustom.endDate.diff(this.thirdCustom.startDate, 'days');
          this.thirdCustom.trendEnd = this.thirdCustom.startDate.clone().subtract(1, 'days');
          this.thirdCustom.trendStart = this.thirdCustom.trendEnd.clone().subtract(dateDiff, 'days');
          this.getDropdownById(this.thirdDateRange).trendText = moment(this.thirdCustom.trendStart).format('MM/DD/YYYY') + ' - ' + moment(this.thirdCustom.trendEnd).format('MM/DD/YYYY');
          this.thirdCustom.name = moment(this.thirdCustom.startDate).format('MM/DD/YY') + '-' + moment(this.thirdCustom.endDate).format('MM/DD/YY');
        }

        await this.apptsCreatedPipelineLoad(this.customColumn);
      }
      else{
        if (this.customColumn === 1) {
          this.fdcFirstCustom.startDate = moment(this.customDate.startDate);
          this.fdcFirstCustom.endDate = moment(this.customDate.endDate);
          let dateDiff = this.fdcFirstCustom.endDate.diff(this.fdcFirstCustom.startDate, 'days');
          this.fdcFirstCustom.trendEnd = this.fdcFirstCustom.startDate.clone().subtract(1, 'days');
          this.fdcFirstCustom.trendStart = this.fdcFirstCustom.trendEnd.clone().subtract(dateDiff, 'days');
          this.getDropdownById(this.fdcFirstDateRange).trendText = moment(this.fdcFirstCustom.trendStart).format('MM/DD/YYYY') + ' - ' + moment(this.fdcFirstCustom.trendEnd).format('MM/DD/YYYY');
          this.fdcFirstCustom.name = moment(this.fdcFirstCustom.startDate).format('MM/DD/YY') + '-' + moment(this.fdcFirstCustom.endDate).format('MM/DD/YY');
        } else if (this.customColumn === 2) {
          this.fdcSecondCustom.startDate = moment(this.customDate.startDate);
          this.fdcSecondCustom.endDate = moment(this.customDate.endDate);
          let dateDiff = this.fdcSecondCustom.endDate.diff(this.fdcSecondCustom.startDate, 'days');
          this.fdcSecondCustom.trendEnd = this.fdcSecondCustom.startDate.clone().subtract(1, 'days');
          this.fdcSecondCustom.trendStart = this.fdcSecondCustom.trendEnd.clone().subtract(dateDiff, 'days');
          this.getDropdownById(this.fdcSecondDateRange).trendText = moment(this.fdcSecondCustom.trendStart).format('MM/DD/YYYY') + ' - ' + moment(this.fdcSecondCustom.trendEnd).format('MM/DD/YYYY');
          this.fdcSecondCustom.name = moment(this.fdcSecondCustom.startDate).format('MM/DD/YY') + '-' + moment(this.fdcSecondCustom.endDate).format('MM/DD/YY');
        } else if (this.customColumn === 3) {
          this.fdcThirdCustom.startDate = moment(this.customDate.startDate);
          this.fdcThirdCustom.endDate = moment(this.customDate.endDate);
          let dateDiff = this.fdcThirdCustom.endDate.diff(this.fdcThirdCustom.startDate, 'days');
          this.fdcThirdCustom.trendEnd = this.fdcThirdCustom.startDate.clone().subtract(1, 'days');
          this.fdcThirdCustom.trendStart = this.fdcThirdCustom.trendEnd.clone().subtract(dateDiff, 'days');
          this.getDropdownById(this.fdcThirdDateRange).trendText = moment(this.fdcThirdCustom.trendStart).format('MM/DD/YYYY') + ' - ' + moment(this.fdcThirdCustom.trendEnd).format('MM/DD/YYYY');
          this.fdcThirdCustom.name = moment(this.fdcThirdCustom.startDate).format('MM/DD/YY') + '-' + moment(this.fdcThirdCustom.endDate).format('MM/DD/YY');
        }

        await this.apptsToFdcPipelineLoad(this.customColumn);
      }
    },
    async apptsToFdcPipelineLoad(column) {
      this.apptsToFdcPipelineLoaded = false
      this.apptsToFdcPipelineDataLoading = true
      let reps = []
      let orgs = []
      let leadsCreatedSources = []
      let dateSelected = null
      let appointmentTypes = []

      if (this.repModel.length === 0) {
        this.apptsToFdcPipelineData = []
        return
      }

      this.officeModel.forEach(org => orgs.push(org.org_id))

      let modelOverride = false
      // if (useRepDataInstead) {
      //   this.repData.forEach((rep, index) => {
      //     reps.push(rep.user_position_id)
      //     if (index === this.repData.length - 1) {
      //       //   this.districtModel = []
      //       //   this.regionModel = []
      //       //   this.officeModel = []
      //       if (this.repDataSelectAll && this.repDataMaster?.length > this.maxRepLimit) {
      //         modelOverride = true
      //         this.repModel = [
      //           {user_id: -2, name: 'All Filtered Reps', active: true}
      //         ]
      //         this.repData = [
      //           {user_id: -2, name: 'All Filtered Reps', active: true}
      //         ]
      //       }
      //     }
      //   })
      // } else {
        this.repModel.forEach(rep => reps.push(rep.user_position_id))
      // }

      // if (modelOverride) {
      //   reps = []
      //   //this gets used when there are more than 1000 users selected
      //   this.repDataMaster.forEach(rep => reps.push(rep.user_position_id))
      // }

      this.fdcSourceModel.forEach(leadsCreatedSource => {
        if (leadsCreatedSource.sourceId) {
          leadsCreatedSources.push(leadsCreatedSource.sourceId)
        }
      })

      if(column === 1){
        dateSelected = this.getDropdownById(this.fdcFirstDateRange)
        if(dateSelected.periodList != null){
          dateSelected.startDate = dateSelected.periodList[this.firstPeriod].startDate;
          dateSelected.endDate = dateSelected.periodList[this.firstPeriod].endDate;
          dateSelected.trendStart = dateSelected.periodList[this.firstPeriod].trendStart;
          dateSelected.trendEnd = dateSelected.periodList[this.firstPeriod].trendEnd;
        }
        else if(dateSelected.name === 'CUSTOM'){
          dateSelected = this.fdcFirstCustom;
        }
      }

      if(column === 2){
        dateSelected = this.getDropdownById(this.fdcSecondDateRange)
        if(dateSelected.periodList != null){
          dateSelected.startDate = dateSelected.periodList[this.secondPeriod].startDate;
          dateSelected.endDate = dateSelected.periodList[this.secondPeriod].endDate;
          dateSelected.trendStart = dateSelected.periodList[this.secondPeriod].trendStart;
          dateSelected.trendEnd = dateSelected.periodList[this.secondPeriod].trendEnd;
        }
        else if(dateSelected.name === 'CUSTOM'){
          dateSelected = this.fdcSecondCustom;
        }
      }

      if(column === 3){
        dateSelected = this.getDropdownById(this.fdcThirdDateRange)
        if(dateSelected.periodList != null){
          dateSelected.startDate = dateSelected.periodList[this.thirdPeriod].startDate;
          dateSelected.endDate = dateSelected.periodList[this.thirdPeriod].endDate;
          dateSelected.trendStart = dateSelected.periodList[this.thirdPeriod].trendStart;
          dateSelected.trendEnd = dateSelected.periodList[this.thirdPeriod].trendEnd;
        }
        else if(dateSelected.name === 'CUSTOM'){
          dateSelected = this.fdcThirdCustom;
        }
      }

      if(this.appointmentTypesModel.length > 0){
        for(let appointmentType of this.appointmentTypesModel){
          appointmentTypes.push(appointmentType.id)
        }
      }
      else{
        appointmentTypes = null
      }

      const requestBody = {
        users: [-1],
        start: dateSelected.startDate,
        end: dateSelected.endDate,
        trendStart: dateSelected.trendStart,
        trendEnd: dateSelected.trendEnd,
        appointmentTypeIds: appointmentTypes,
        leadSourceIds: leadsCreatedSources,
        hideInactive: this.hideInactiveReps
      }

      try {
        await postRequest('/closerDashboard/funnel/' + this.viewSelect, requestBody, 'blueraven', []).then(res => {
          let dataTarget = orderBy(res.data, row => row.display_order);
          // this.apptsToFdcPipelineData = orderBy(res.data, row => row.display_order)
          dataTarget = orderBy(res.data, row => row.display_order)
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

          dataTarget.forEach(row => {
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

          if(column === 1){
            this.apptsToFdcPipelineData = dataTarget
          }
          else if(column === 2){
            this.fdcColumn2Values = dataTarget
          }
          else if(column === 3){
            this.fdcColumn3Values = dataTarget
          }

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
          this.apptsToFdcPipelineLoad(1)
        }
      })
      this.initialPageLoad = false
      this.dropdownValuesLoading = false
    },

    updateApptsCreatedPipelineCalendar() {
      this.appts_created_pipeline_menu1 = false
      this.appts_created_pipeline_menu2 = false
      this.apptsCreatedPipelineLoad(1)
    },

    updateApptsToFdcPipelineCalendar() {
      this.appts_to_fdc_pipeline_menu1 = false
      this.appts_to_fdc_pipeline_menu2 = false
      this.apptsToFdcPipelineLoad(1)
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
          this.apptsToFdcPipelineLoad(1)
        } else if (this.selectAllReps) {
          this.apptsToFdcPipelineLoad(1)
        } else {
          this.apptsToFdcPipelineLoad(1)
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
      // this.selectedFunnel = funnel
      let sourceIds = []
      let userIds = []
      let orgIds = []
      let appointmentTypeIds = null
      let start, end
      let datesMatch = false

      if (pipelineName === 'apptsCreatedPipeline') {
        let brsSourceIds = this.brsProvidedSourceModel.map(brsProvidedSource => brsProvidedSource.sourceId)
        let selfGenSourceIds = this.selfGenSourceModel.map(selfGenSource => selfGenSource.sourceId)
        let leadSourceIds = this.leadsCreatedSourceModel.map(leadSource => leadSource.sourceId)
        if (funnel.id === 12) { // BRS-provided sources
          sourceIds = brsSourceIds
        } else if (funnel.id === 13) { // Self-gen sources
          sourceIds = selfGenSourceIds
        } else if (funnel.id === 34){
          sourceIds = leadSourceIds
        }
        else {
          sourceIds = brsSourceIds.concat(selfGenSourceIds)
        }
      } else {
        userIds = this.repModel.map(rep => rep.user_position_id)
        orgIds = this.officeModel.map(org => org.org_id)
        if(this.appointmentTypesModel.length > 0){
          appointmentTypeIds = this.appointmentTypesModel.map(appointmentType => appointmentType.id)
        }
      }

      datesMatch = moment(dateRange.startDate).format('YYYY-MM-DD') === moment(dateRange.endDate).format('YYYY-MM-DD')

      if (datesMatch) {
        this.funnelDrilldownTitle = funnel.name + ' on ' + moment(dateRange.startDate).format('M/D/YYYY')
      } else {
        this.funnelDrilldownTitle = funnel.name + ' ' + moment(dateRange.startDate).format('M/D/YYYY') + ' - ' + moment(dateRange.endDate).format('M/D/YYYY')
      }

      this.funnelDrilldownHeaders[1].show = true
      this.funnelDrilldownHeaders[2].show = true
      this.funnelDrilldownHeaders[4].show = true
      this.funnelDrilldownHeaders[5].show = true
      this.funnelDrilldownHeaders[7].show = true
      this.funnelDrilldownHeaders[9].show = false
      this.funnelDrilldownHeaders[10].show = true
      this.funnelDrilldownHeaders[11].show = true
      switch (funnel.id) {
        // Appointments Created Pipeline
        case 12: // BRS-provided appointments created
        case 13: // Self-gen appointments created
        case 10: // Total Appointments Created
        case 26: // Missing source
          this.funnelDrilldownHeaders[14].show = true // date_created
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
          this.funnelDrilldownHeaders[15].show = true // appointment_outcome
          this.funnelDrilldownHeaders[29].show = isCheckedInColumn // check_in_time
          break
        case 9: // Credits run
          this.funnelDrilldownHeaders[15].show = true // appointment_outcome
          this.funnelDrilldownHeaders[16].show = true // credit_decision_date
          break
        case 3: // Credits passed
          this.funnelDrilldownHeaders[15].show = true // appointment_outcome
          this.funnelDrilldownHeaders[16].show = true // credit_decision_date
          this.funnelDrilldownHeaders[17].show = true // credit_check
          break
        case 4: // Bookings Complete
          this.funnelDrilldownHeaders[18].show = true // installation_agreement_signed_date
          this.funnelDrilldownHeaders[20].show = true // site_survey_completed_date
          break
        case 5: // Site Surveys Verified
          this.funnelDrilldownHeaders[19].show = true // site_survey_verified_date
          break
        case 6: // Final Designs sent to Homeowner
          this.funnelDrilldownHeaders[21].show = true // final_design_sent_to_homeowner_date
          this.funnelDrilldownHeaders[22].show = true // final_design_signed_date
          break
        case 7: // Final Designs Approved
          this.funnelDrilldownHeaders[22].show = true // final_design_signed_date
          this.funnelDrilldownHeaders[25].show = true // financial_agreement_signed_date
          this.funnelDrilldownHeaders[23].show = true // proof_of_homeowners_insurance_obtained_date
          this.funnelDrilldownHeaders[26].show = true // cash_down_payment
          this.funnelDrilldownHeaders[24].show = true // utility_bill_verified_date
          break
        case 21: // Final Designs Completed
          this.funnelDrilldownHeaders[27].show = true // final_design_complete_date
          break
        case 8: // Installations Completed
          this.funnelDrilldownHeaders[28].show = true // substantial_completion_date
          break
        case 34:
          this.funnelDrilldownHeaders[1].show = true
          this.funnelDrilldownHeaders[2].show = false
          this.funnelDrilldownHeaders[4].show = false
          this.funnelDrilldownHeaders[5].show = false
          this.funnelDrilldownHeaders[7].show = false
          this.funnelDrilldownHeaders[9].show = true
          this.funnelDrilldownHeaders[10].show = false
          this.funnelDrilldownHeaders[11].show = false

          break
      }

      const requestBody = {
        start: dateRange.startDate,
        end: dateRange.endDate,
        funnelId: funnel.id,
        hideInactive: this.hideInactiveReps,
        leadSourceIds: this.fdcSourceModel.map(leadSource => leadSource.sourceId),
      }

      if (pipelineName === 'apptsCreatedPipeline') {
        requestBody.sources = sourceIds
      } else {
        requestBody.users = userIds
        requestBody.isCheckedInColumn = isCheckedInColumn
        requestBody.appointmentTypeIds = appointmentTypeIds
      }

      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/closerDashboard/funnelDrilldown/${pipelineName}`, requestBody, 'blueraven', []).then(({
                                                                                                                    data,
                                                                                                                    status
                                                                                                                  }) => {
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

    // toggleSelectAllBrsProvidedSources() {
    //   this.$nextTick(() => {
    //     if (this.selectAllBrsProvidedSources) {
    //       this.brsProvidedSourceModel = []
    //       this.apptsCreatedPipelineData[0] = {
    //         id: 12,
    //         name: 'BRS provided appointments created',
    //         today_count: 0,
    //         week_to_date_count: 0,
    //         custom_date_range_count: 0
    //       }
    //     } else {
    //       this.brsProvidedSourceModel = cloneDeep(this.brsProvidedSourceData)
    //       this.apptsCreatedPipelineLoad(this.appts_created_pipeline_dt1, this.appts_created_pipeline_dt2)
    //     }
    //   })
    // },

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
          this.apptsCreatedPipelineLoad(1)
        }
      })
    },

    toggleSelectAllLeadsCreatedSources() {
      this.$nextTick(() => {
        if (this.selectAllLeadsCreatedSources) {
          this.leadsCreatedSourceModel = []
          this.apptsCreatedPipelineData[1] = {
            id: 13,
            name: 'Leads created',
            today_count: 0,
            week_to_date_count: 0,
            custom_date_range_count: 0
          }
        } else {
          this.leadsCreatedSourceModel = cloneDeep(this.leadsCreatedSourceData)
          this.apptsCreatedPipelineLoad(1)
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

    toggleSelectAppointmentTypes() {
      this.$nextTick(() => {
        if (this.appointmentTypesSelectAll) {
          this.appointmentTypesModel = cloneDeep(this.appointmentTypes)
        }
        else{
          this.appointmentTypesModel = []
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
    if (this.$store?.state?.user?.details?.timezone?.value) {
      this.timezone = this.$store.state.user.details.timezone.value
    }
    await this.getDropdownValues();
    await this.getAppointmentTypes();
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
    this.headers = [
      {text: 'Milestones', value: 'milestone', sortable: false, class: 'milestone-col-th', show: true},
      {text: 'Source', value: 'source', sortable: false, class: 'milestone-col-th', show: true},
      {
        text: 'Today',
        value: 'actualTotal',
        align: 'left',
        class: 'total-col-th data-col-th',
        show: !this.isBrCorporateUser
      },
      {
        text: 'Today2',
        value: 'actualTotal2',
        align: 'left',
        class: 'total-col-th data-col-th',
        show: !this.isBrCorporateUser
      },
      {
        text: 'Today3',
        value: 'actualTotal3',
        align: 'left',
        class: 'total-col-th data-col-th',
        show: !this.isBrCorporateUser
      },
    ]
    this.fdcHeaders = [
      {text: 'Milestones', value: 'milestone', sortable: false, class: 'milestone-col-th', show: true}, {
        text: 'Today',
        value: 'actualTotal',
        align: 'left',
        class: 'total-col-th data-col-th',
        show: !this.isBrCorporateUser
      },
      {
        text: 'Today2',
        value: 'actualTotal2',
        align: 'left',
        class: 'total-col-th data-col-th',
        show: !this.isBrCorporateUser
      },
      {
        text: 'Today3',
        value: 'actualTotal3',
        align: 'left',
        class: 'total-col-th data-col-th',
        show: !this.isBrCorporateUser
      },
    ]
  },
  mounted() {
    //
    //   //vuetify selects/autocompletes have a bug with the select all feature being used at the same time as the @blur event
    //   //the @blur event should only be called when the menu is closed, but in a select all it is called when the select all button is clicked. wreaks havoc.
    //   //this sucks but fixes that issue re: https://github.com/vuetifyjs/vuetify/issues/11488
    //   this.myDynamicAreaWatcher = this.$watch(
    //     () => this.$refs.areaSelect.isMenuActive,
    //     (val) => {
    //       // if val is false = blur aka the menu is being closed. true = menu is being opened
    //       if (!val) {
    //         if (this.areaValuesChanged) {
    //           // reset these values when the districts change
    //           this.regionModel = []
    //           this.officeModel = []
    //           this.repModel = []
    //           this.repDataSelectAll = false
    //           this.regionLoad(false)
    //           // this.officeLoad(false)
    //           // this.repLoad(false)
    //           this.areaValuesChanged = false
    //         }
    //       }
    //     })
    //   this.myDynamicRegionWatcher = this.$watch(
    //     () => this.$refs.regionSelect.isMenuActive,
    //     (val) => {
    //       // if val is false = blur aka the menu is being closed. true = menu is being opened
    //       if (!val) {
    //         if (this.regionValuesChanged) {
    //           // reset these values when the regions change
    //           this.districtModel = []
    //           this.officeModel = []
    //           this.repModel = []
    //           this.repDataSelectAll = false
    //           this.districtLoad(false)
    //           // this.repLoad(false)
    //           this.regionValuesChanged = false
    //         }
    //       }
    //     })
    //   this.myDynamicDistrictWatcher = this.$watch(
    //     () => this.$refs.districtSelect.isMenuActive,
    //     (val) => {
    //       // if val is false = blur aka the menu is being closed. true = menu is being opened
    //       if (!val) {
    //         if (this.districtValuesChanged) {
    //           // reset these values when the districts change
    //           this.officeModel = []
    //           this.repModel = []
    //           this.repDataSelectAll = false
    //           this.officeLoad(false)
    //           // this.officeLoad(false)
    //           // this.repLoad(false)
    //           this.districtValuesChanged = false
    //         }
    //       }
    //     })
    //   this.myDynamicOfficeWatcher = this.$watch(
    //     () => this.$refs.officeSelect.isMenuActive,
    //     (val) => {
    //       // if val is false = blur aka the menu is being closed. true = menu is being opened
    //       if (!val) {
    //         if (this.officeValuesChanged) {
    //           // reset these values when the offices change
    //           this.repModel = []
    //           this.repDataSelectAll = false
    //           this.repLoad(false)
    //           this.officeValuesChanged = false
    //         }
    //       }
    //     })
    //   this.myDynamicRepWatcher = this.$watch(
    //     () => this.$refs.repSelect.isMenuActive,
    //     (val) => {
    //       // if val is false = blur aka the menu is being closed. true = menu is being opened
    //       if (!val && this.repModel.length > 0) {
    //         this.doRepWatcher()
    //       }
    //     })
  },
}
</script>

<style lang="scss" scoped>
#all-reps-btn{
  text-transform: none;
}
.reset-button{
  color: var(--v-grey-darken2);
  border-radius: 4px;
  border: 1px solid #9E9E9E;
  text-transform: none;
}
.material-symbols-outlined {
  font-variation-settings:
    'FILL' 0,
    'wght' 400,
    'GRAD' 0,
    'opsz' 24
}
.checked_in_container{
  display: inline-block;
  background-color: var(--v-grey-lighten2);
  height: 28px;
  width: 54px;
  align-items: center;
  overflow: hidden;
}
.table-collapse-button{
  margin-right: 20px;
}
.positive-percentage{
  color: green;
}
.negative-percentage{
  padding-left: 4px;
  color: red;
}
.negative-trendline{
  color: red;
}
.positive-percentage{
  padding-left: 4px;
  color: green;
}
.positive-trendline{
  color: green;
}
.neutral-percentage{
  padding-left: 4px;
  color: grey;
}
.neutral-trendline{
  color: grey;
}
.dropdown-header{
  border: 1px solid var(--v-grey-lighten1);
  text-transform: unset !important;
  background-color: transparent !important;
  box-shadow: none;
  height: 40px !important;
  width: 210px;
  justify-content: left;
}
.dashboard-menu-option{
  display: flex;
  min-height: 48px;
  align-items: center!important;
  padding-right: 16px;
  padding-left: 16px;
}
.export-icon{
  color: #1F3C73;
}
.export-button{
  margin-top: 25px;
  color: #1F3C73;
}
.checkbox-container{
  margin-top: 0px !important;
  margin-left: 12px !important;
}
.filter-row{
  margin-left: 16px;
}
.closer-dashboard-header{
  margin-left: 28px;
  margin-right: 16px;
  margin-top: 25px;
}
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

        padding: 5px 12px;
        width: 100%;
        height: 45px !important;

        .v-toolbar__items {
          display: flex;
          flex-flow: row nowrap;

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
        text-transform: none!important;
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
        border: 1px solid #fff;
        font-weight: normal;
        text-align: center;
        margin-right: 5px;
        width: 38px;
      }

      .no-checked-in-column-placeholder {
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
          text-transform: none!important;
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

        width: 58%;

        .appts-to-fdc-pipeline-dropdown,
        #all-reps-btn {
          text-transform: none!important;
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
}

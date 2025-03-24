<template>
  <v-container id="closer-dash-container" ref="closerDashContainer">
    <div id="appts-to-fdc-pipeline-container" class="mb-8">
      <v-row align="center">
        <div class="title-large closer-dashboard-header">
          Pipeline
        </div>
        <a v-if="funnelStats?.length > 0" class="export-button" @click="exportCsv('pipeline')">
          <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
          Export
        </a>
        <div v-else :class="{'disabled-export': true}" class="export-button">
          <v-icon class="export-icon disabled-export">mdi-tray-arrow-down</v-icon>
          Export
        </div>
        <v-spacer></v-spacer>
        <div class="flex-display flex-align-items-end table-collapse-button">
          <v-icon v-if="fdcPipelineExpanded" @click="fdcPipelineExpanded = !fdcPipelineExpanded">expand_less</v-icon>
          <v-icon v-else @click="fdcPipelineExpanded = !fdcPipelineExpanded">expand_more</v-icon>
        </div>
      </v-row>
      <div v-if="!fdcPipelineExpanded" style="height: 25px"></div>
      <div v-if="fdcPipelineExpanded" class="pipeline-header-container">
        <v-col class="d-flex" cols="9">
          <div id="pipeline-header-left-side">
            <div class="reps-container"><span class="rep-filters-text label-small">Rep Filters</span></div>
            <a-autocomplete ref="areaSelect"
                            v-model="areaModel"
                            :items="areaData"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="org_name"
                            item-value="org_id"
                            label="Area"
                            multiple
                            no-data-text="No areas available"
                            return-object
                            variant="outlined"
                            @blur="areaValuesChanged = true; regionLoad()"
                            @input="repValuesChanged = true">
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">Area</span>
              </template>
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
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
            </a-autocomplete>

            <a-autocomplete ref="regionSelect"
                            v-model="regionModel"
                            :items="regionData"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="org_name"
                            item-value="org_id"
                            label="Region"
                            multiple
                            no-data-text="No regions available"
                            return-object
                            variant="outlined"
                            @blur="regionValuesChanged = true; districtLoad()"
                            @input="repValuesChanged = true">
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">Region</span>
              </template>
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
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
            </a-autocomplete>

            <a-autocomplete ref="districtSelect"
                            v-model="districtModel"
                            :items="districtData"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="org_name"
                            item-value="org_id"
                            label="District"
                            multiple
                            no-data-text="No districts available"
                            return-object
                            variant="outlined"
                            @blur="officeLoad()"
                            @input="repValuesChanged = true; districtValuesChanged = true;">
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">District</span>
              </template>
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
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
            </a-autocomplete>

            <a-autocomplete ref="officeSelect"
                            v-model="officeModel"
                            :items="officeData"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="org_name"
                            item-value="org_id"
                            label="Office"
                            multiple
                            no-data-text="No offices available"
                            return-object
                            variant="outlined"
                            @blur="officeValuesChanged = true; repLoad()"
                            @input="repValuesChanged = true">
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">Office</span>
              </template>
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
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
            </a-autocomplete>
            <a-autocomplete ref="repSelect"
                            v-model="repModel"
                            :items="repData"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="name"
                            item-value="user_position_id"
                            label="Rep"
                            multiple
                            no-data-text="No reps available"
                            return-object
                            variant="outlined"
                            @input="repValuesChanged = true; apptsToFdcPipelineData.value = []">
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0 && repModel[0].user_id != -1" class="selected-option text-caption">
                    {{ repModel.length }} Checked
                  </span>
                <span v-if="index === 0 && repModel[0].user_id === -1" class="selected-option text-caption-sm">
                        {{ filteredRepDataMaster.length }} Checked
                  </span>
              </template>
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">Rep</span>
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
            </a-autocomplete>
            <div class="d-flex hide-inactive-switch-container align-items-center">
              <v-label class="hide-inactive-label body-medium">Hide Inactive Reps</v-label>
              <v-switch v-model="hideInactiveReps" class="hide-inactive-switch" hide-details
                        @click="apptsToFdcPipelineLoad(1)"></v-switch>
            </div>
            <a-btn
              v-if="!isSetter && !isSetterMgr"
              :class="{'reset-button-inactive': !filtersSelected && repModel?.length === 0 && !hideInactiveReps, 'reset-button-active': filtersSelected || repModel?.length > 0 || hideInactiveReps}"
              class="body-small"
              color="unset"
              text="Reset Rep Filters"
              variant="outlined"
              @click="resetFilters(); repValuesChanged = true;  loadFunnels()"
            ></a-btn>
          </div>
        </v-col>
        <v-col class="d-flex justify-end" cols="3">
          <a-btn
            id="all-reps-btn"
            :text="viewAllRepsText"
            class="body-small"
            color="primary"
            variant="outlined"
            @click="funnelAllReps"
          ></a-btn>
        </v-col>
      </div>


      <!-- FUNNEL -->
      <div class="funnel-container">
        <div v-if="funnelStats.length > 0" id="appts-created-pipeline-funnel-background"
             :style="{'margin-top': showApptsCreatedPipelineCustomDates && windowInnerWidth < 1135 ? '77px' :
                                 showApptsCreatedPipelineCustomDates && windowInnerWidth >= 1135 ? '83px' : '59px'}"></div>
        <v-data-table
          v-if="fdcPipelineExpanded"
          id="fdc-dash-table"
          ref="pageable-table"
          :footer-props="footerProps"
          :headers="fdcHeaders"
          :hide-default-footer="true"
          :item-class="fdcRowBackground"
          :items="funnelStats"
          :loading="isLoading"
          :mobile-breakpoint="0"
          class="elevation-1"
          disable-sort
        >

          <template #no-data>
            <span class="default-text-color">Select Reps to View the Pipeline</span>
          </template>


          <template id="milestones-header" #header.milestone="{}"><span class="milestones-header">Milestones</span>
          </template>
          <template #header.actualTotal="{}">
            <v-menu v-model="fdcOpenFirstMenu" :close-on-content-click="true"
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    data-app
                    left
                    offset-y>
              <template v-slot:activator="{ on }">
                <a-btn :activation-handler="on"
                       class="dropdown-header body-small"
                >
              <span v-if="getDropdownById(fdcFirstDateRange)?.name === 'CUSTOM' && fdcFirstCustom.name != null"
                    class="selected-option body-small">
                      {{ fdcFirstCustom.name }}</span>
                  <span v-else-if="getDropdownById(fdcFirstDateRange)?.name === 'PERIOD'"
                        class="selected-option body-small">
              {{ getDropdownById(fdcFirstDateRange).periodList[firstPeriod].shortLabel }}
              </span>
                  <span v-else class="selected-option body-small">
              {{ getDropdownById(fdcFirstDateRange)?.friendlyName }}
              </span>
                  <v-spacer></v-spacer>
                  <v-spacer></v-spacer>
                  <v-icon color="primary">mdi-menu-down</v-icon>
                </a-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" link style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu offset-x open-on-hover>
                        <template v-slot:activator="{ on }">
                      <span class="d-flex justify-space-between dashboard-menu-option" v-on="on">
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
                                       class="dashboard-menu-option"
                                       @click="fdcFirstDateRange = item.id; changeFdcDropdownSelection(1); fdcFirstCustom.isActive = (item.name === 'CUSTOM');">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>

          </template>
          <template #header.actualTotal2="{}">
            <v-menu v-model="fdcOpenSecondMenu" :close-on-content-click="true"
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    data-app
                    left
                    offset-y>
              <template v-slot:activator="{ on }">
                <a-btn :activation-handler="on"
                       class="dropdown-header body-small"
                >
              <span v-if="getDropdownById(fdcSecondDateRange)?.name === 'CUSTOM' && fdcSecondCustom.name != null"
                    class="selected-option body-small">
                      {{ fdcSecondCustom.name }}</span>
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
                  <v-spacer></v-spacer>
                  <v-icon color="primary">mdi-menu-down</v-icon>
                </a-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" link style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu :offset-x="true" location="end" open-on-hover>
                        <template v-slot:activator="{ on }">
                      <span class="d-flex justify-space-between dashboard-menu-option" v-on="on">
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
                                       class="dashboard-menu-option"
                                       @click="fdcSecondDateRange = item.id; changeFdcDropdownSelection(2); secondCustom.isActive = (item.name === 'CUSTOM');">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>
          <template #header.actualTotal3="{}">
            <v-menu v-model="fdcOpenThirdMenu" :close-on-content-click="true"
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    data-app
                    left
                    offset-y>
              <template v-slot:activator="{ on }">
                <a-btn :activation-handler="on"
                       class="dropdown-header body-small"
                >
              <span v-if="getDropdownById(fdcThirdDateRange)?.name === 'CUSTOM' && fdcThirdCustom.name != null"
                    class="selected-option body-small">
                      {{ fdcThirdCustom.name }}</span>
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
                  <v-spacer></v-spacer>
                  <v-icon color="primary">mdi-menu-down</v-icon>
                </a-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" link style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu location="end" open-on-hover>
                        <template v-slot:activator="{ on }">
                      <span class="d-flex justify-space-between dashboard-menu-option" v-on="on">
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
                                       class="dashboard-menu-option"
                                       @click="fdcThirdDateRange = item.id; changeFdcDropdownSelection(3); thirdCustom.isActive = (item.name === 'CUSTOM');">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>
          <template #header.actualTotal4="{}">
            <v-menu v-model="fdcOpenFourthMenu" :close-on-content-click="true"
                    :max-height="`calc(100vh - 20px)`"
                    class="dropdown-header body-small"
                    data-app
                    left
                    offset-y>
              <template v-slot:activator="{ on }">
                <a-btn :activation-handler="on"
                       class="dropdown-header body-small"
                >
              <span v-if="getDropdownById(fdcFourthDateRange)?.name === 'CUSTOM' && fdcFourthCustom.name != null"
                    class="selected-option body-small">
                      {{ fdcFourthCustom.name }}</span>
                  <span v-else-if="getDropdownById(fdcFourthDateRange)?.name === 'PERIOD'"
                        class="selected-option body-small">
              {{ getDropdownById(fdcFourthDateRange).periodList[fourthPeriod].shortLabel }}
              </span>
                  <span v-else-if="fdcFourthDateRange != null" class="selected-option body-small">
              {{ getDropdownById(fdcFourthDateRange)?.friendlyName }}
              </span>
                  <span v-else class="placeholder-option body-small">
                Select Date Range
              </span>
                  <v-spacer></v-spacer>
                  <v-icon color="primary">mdi-menu-down</v-icon>
                </a-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y:auto">
                  <v-list-item v-for="(item, index) in dropdownValues" link style="padding: 0px">
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu location="end" open-on-hover>
                        <template v-slot:activator="{ on }">
                      <span class="d-flex justify-space-between dashboard-menu-option" v-on="on">
                        {{ item.friendlyName }}
                        <v-icon>mdi-chevron-right</v-icon>
                      </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y:auto">
                            <v-list-item v-for="(period, index) in item.periodList"
                                         @click="fdcFourthDateRange = item.id; fourthPeriod = index; changeFdcDropdownSelection(4); fdcFourthCustom.isActive = (item.name === 'CUSTOM'); fdcOpenFourthMenu = false">
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>

                    </v-list-item-title>
                    <v-list-item-title v-else
                                       class="dashboard-menu-option"
                                       @click="fdcFourthDateRange = item.id; changeFdcDropdownSelection(4); fdcFourthCustom.isActive = (item.name === 'CUSTOM');">{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>


          <template id="milestones-col" #item.milestone="{item, index}" class="milestone-name-col-td">
            <span>{{ item.name }}</span>
            <!--            <v-tooltip v-if="item.name === 'Pitch Percentage'" text="Test" bottom>-->
            <!--              <template v-slot:activator="{ on }">-->
            <!--                <v-icon>mdi-information</v-icon>-->
            <!--              </template>-->
            <!--              <span>Test Test</span>-->
            <!--            </v-tooltip>-->
            <v-tooltip v-if="item.name==='Pitch Percentage'" bottom>
              <template v-slot:activator="{ on }">
              <span v-on="viewFdcTrends?on:null">
                <v-icon>mdi-information</v-icon>
              </span>
              </template>
              <span> Pitch Percentage = Appointment Pitched / Appointment Occurred</span>
            </v-tooltip>
          </template>
          <template #item.actualTotal="{item, index}" class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
              <span @click="funnelDrilldown(item, getDropdownById(fdcFirstDateRange), 'standard', 1)">
                {{ item.count_count ? item.count_count : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && item.trend_count>0"
                      :class="[{'positive-percentage': !item.reverse_trend, 'negative-percentage': item.reverse_trend}]">+{{ item.trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': !item.reverse_trend, 'negative-trendline': item.reverse_trend}]">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && item.trend_count<0"
                      :class="[{'positive-percentage': item.reverse_trend, 'negative-percentage': !item.reverse_trend}]">{{ item.trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': item.reverse_trend, 'negative-trendline': !item.reverse_trend}]">trending_down</v-icon></span>
                <span v-if="viewFdcTrends && (item.trend_count ===null || item.trend_count===0)"
                      class="neutral-percentage">{{ item.trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
                </span>
              </span>
              </template>
              <span v-if="viewFdcTrends && item.trend_count>0"> {{ Math.abs(item.trend_count) / 100 | percent }} more than {{ getDropdownTrendText(fdcFirstDateRange, 1) }}</span>
              <span v-if="viewFdcTrends && item.trend_count<0"> {{ Math.abs(item.trend_count) / 100 | percent }} less than {{ getDropdownTrendText(fdcFirstDateRange, 1) }}</span>
              <span
                v-if="viewFdcTrends && (item.trend_count ===null || item.trend_count===0)"> Same as {{ getDropdownTrendText(fdcFirstDateRange, 1) }}</span>
            </v-tooltip>
          </template>

          <template v-if="fdcSecondDateRange != null && fdcColumn2Values != null && fdcColumn2Values.length > 0" #item.actualTotal2="{item, index}"
                    class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="funnelDrilldown(item, getDropdownById(fdcSecondDateRange), 'standard', 2)">
              {{ fdcColumn2Values[index].count_count ? fdcColumn2Values[index].count_count : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && fdcColumn2Values[index].trend_count>0"
                      :class="[{'positive-percentage': !fdcColumn2Values[index].reverse_trend, 'negative-percentage': fdcColumn2Values[index].reverse_trend}]">+{{ fdcColumn2Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': !fdcColumn2Values[index].reverse_trend, 'negative-trendline': fdcColumn2Values[index].reverse_trend}]">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && fdcColumn2Values[index].trend_count<0"
                      :class="[{'positive-percentage': fdcColumn2Values[index].reverse_trend, 'negative-percentage': !fdcColumn2Values[index].reverse_trend}]">{{ fdcColumn2Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': fdcColumn2Values[index].reverse_trend, 'negative-trendline': !fdcColumn2Values[index].reverse_trend}]">trending_down</v-icon></span>
                <span
                  v-if="viewFdcTrends && (fdcColumn2Values[index].trend_count === null || fdcColumn2Values[index].trend_count==0)"
                  class="neutral-percentage">{{ fdcColumn2Values[index].trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewFdcTrends && fdcColumn2Values[index].trend_count>0"> {{ Math.abs(fdcColumn2Values[index].trend_count) / 100 | percent
                }} more than {{ getDropdownTrendText(fdcSecondDateRange, 2) }}</span>
              <span
                v-if="viewFdcTrends && fdcColumn2Values[index].trend_count<0"> {{ Math.abs(fdcColumn2Values[index].trend_count) / 100 | percent
                }} less than {{ getDropdownTrendText(fdcSecondDateRange, 2) }}</span>
              <span
                v-if="viewFdcTrends && (fdcColumn2Values[index].trend_count ===null || fdcColumn2Values[index].trend_count===0)"> Same as {{ getDropdownTrendText(fdcSecondDateRange, 2) }}</span>
            </v-tooltip>
          </template>
          <template v-if="fdcThirdDateRange != null && fdcColumn3Values != null && fdcColumn3Values.length > 0" #item.actualTotal3="{item, index}"
                    class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="funnelDrilldown(item, getDropdownById(fdcSecondDateRange), 'standard', 3)">
              {{ fdcColumn3Values[index].count_count ? fdcColumn3Values[index].count_count : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && fdcColumn3Values[index].trend_count>0"
                      :class="[{'positive-percentage': !fdcColumn3Values[index].reverse_trend, 'negative-percentage': fdcColumn3Values[index].reverse_trend}]">+{{ fdcColumn3Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': !fdcColumn3Values[index].reverse_trend, 'negative-trendline': fdcColumn3Values[index].reverse_trend}]">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && fdcColumn3Values[index].trend_count<0"
                      :class="[{'positive-percentage': fdcColumn3Values[index].reverse_trend, 'negative-percentage': !fdcColumn3Values[index].reverse_trend}]">{{ fdcColumn3Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': fdcColumn3Values[index].reverse_trend, 'negative-trendline': !fdcColumn3Values[index].reverse_trend}]">trending_down</v-icon></span>
                <span
                  v-if="viewFdcTrends && (fdcColumn3Values[index].trend_count === null || fdcColumn3Values[index].trend_count === 0)"
                  class="neutral-percentage">{{ fdcColumn3Values[index].trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewFdcTrends && fdcColumn3Values[index].trend_count>0"> {{ Math.abs(fdcColumn3Values[index].trend_count) / 100 | percent
                }} more than {{ getDropdownTrendText(fdcThirdDateRange, 3) }}</span>
              <span
                v-if="viewFdcTrends && fdcColumn3Values[index].trend_count<0"> {{ Math.abs(fdcColumn3Values[index].trend_count) / 100 | percent
                }} less than {{ getDropdownTrendText(fdcThirdDateRange, 3) }}</span>
              <span
                v-if="viewFdcTrends && (fdcColumn3Values[index].trend_count ===null || fdcColumn3Values[index].trend_count===0)"> Same as {{ getDropdownTrendText(fdcThirdDateRange, 3) }}</span>
            </v-tooltip>
          </template>
          <template v-if="fdcFourthDateRange != null && fdcColumn4Values != null && fdcColumn4Values.length > 0" #item.actualTotal4="{item, index}"
                    class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="funnelDrilldown(item, getDropdownById(fdcFourthDateRange), 'standard', 4)">
              {{ fdcColumn4Values[index].count_count ? fdcColumn4Values[index].count_count : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && fdcColumn4Values[index].trend_count>0"
                      :class="[{'positive-percentage': !fdcColumn4Values[index].reverse_trend, 'negative-percentage': fdcColumn4Values[index].reverse_trend}]">+{{ fdcColumn4Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': !fdcColumn4Values[index].reverse_trend, 'negative-trendline': fdcColumn4Values[index].reverse_trend}]">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && fdcColumn4Values[index].trend_count<0"
                      :class="[{'positive-percentage': fdcColumn4Values[index].reverse_trend, 'negative-percentage': !fdcColumn4Values[index].reverse_trend}]">{{ fdcColumn4Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': fdcColumn4Values[index].reverse_trend, 'negative-trendline': !fdcColumn4Values[index].reverse_trend}]">trending_down</v-icon></span>
                <span
                  v-if="viewFdcTrends && (fdcColumn4Values[index].trend_count === null || fdcColumn4Values[index].trend_count === 0)"
                  class="neutral-percentage">{{ fdcColumn4Values[index].trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewFdcTrends && fdcColumn4Values[index].trend_count>0"> {{ Math.abs(fdcColumn4Values[index].trend_count) / 100 | percent
                }} more than {{ getDropdownTrendText(fdcFourthDateRange, 4) }}</span>
              <span
                v-if="viewFdcTrends && fdcColumn4Values[index].trend_count<0"> {{ Math.abs(fdcColumn4Values[index].trend_count) / 100 | percent
                }} less than {{ getDropdownTrendText(fdcFourthDateRange, 4) }}</span>
              <span
                v-if="viewFdcTrends && (fdcColumn4Values[index].trend_count ===null || fdcColumn4Values[index].trend_count===0)"> Same as {{ getDropdownTrendText(fdcFourthDateRange, 4) }}</span>
            </v-tooltip>
          </template>
        </v-data-table>
      </div>
    </div>
    <div class="table-gap"></div>
    <div id="appts-to-fdc-pipeline-container" class="mb-8">
      <v-row align="center">
        <div class="title-large closer-dashboard-header">
          Upcoming Appointments ({{ tomorrow | formatDate('date', 'MM/DD/YY') }})
        </div>
        <a v-if="upcomingAppointmentsData?.length > 0" class="export-button" @click="exportCsv('appts')">
          <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
          Export
        </a>
        <div v-else :class="{'disabled-export': true}" class="export-button">
          <v-icon class="export-icon disabled-export">mdi-tray-arrow-down</v-icon>
          Export
        </div>
        <v-spacer></v-spacer>
        <div class="flex-display flex-align-items-end table-collapse-button">
          <v-icon v-if="upcomingApptsExpanded" @click="upcomingApptsExpanded = !upcomingApptsExpanded">expand_less
          </v-icon>
          <v-icon v-else @click="upcomingApptsExpanded = !upcomingApptsExpanded">expand_more</v-icon>
        </div>
      </v-row>
      <div v-if="!upcomingApptsExpanded" style="height: 25px"></div>
      <div v-if="upcomingApptsExpanded" class="pipeline-header-container">
        <v-col class="d-flex" cols="9">
          <div id="pipeline-header-left-side">
            <div class="reps-container"><span class="rep-filters-text label-small">Rep Filters</span></div>
            <a-autocomplete ref="areaSelect"
                            v-model="areaModelAppts"
                            :items="areaDataAppts"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="org_name"
                            item-value="org_id"
                            label="Area"
                            multiple
                            no-data-text="No areas available"
                            return-object
                            variant="outlined"
                            @blur="areaValuesChanged = true; regionLoadAppts()"
                            @input="repValuesChangedAppts = true">
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">Area</span>
              </template>
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
                    {{ areaModelAppts.length }} Checked
                  </span>
              </template>
              <template v-if="areaDataAppts.length > 0" v-slot:prepend-item>
                <v-list-item @click="[areaValuesChanged = true, toggleSelectAllAreasAppts()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ areaSelectIconAppts }}</v-icon>
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
            </a-autocomplete>

            <a-autocomplete ref="regionSelect"
                            v-model="regionModelAppts"
                            :items="regionDataAppts"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="org_name"
                            item-value="org_id"
                            label="Region"
                            multiple
                            no-data-text="No regions available"
                            return-object
                            variant="outlined"
                            @blur="regionValuesChanged = true; districtLoadAppts()"
                            @input="repValuesChangedAppts = true">
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">Region</span>
              </template>
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
                    {{ regionModelAppts.length }} Checked
                  </span>
              </template>
              <template v-if="regionDataAppts.length > 0" v-slot:prepend-item>
                <v-list-item @click="[regionValuesChanged = true, toggleSelectAllRegionsAppts()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ regionSelectIconAppts }}</v-icon>
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
            </a-autocomplete>

            <a-autocomplete ref="districtSelect"
                            v-model="districtModelAppts"
                            :items="districtDataAppts"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="org_name"
                            item-value="org_id"
                            label="District"
                            multiple
                            no-data-text="No districts available"
                            return-object
                            variant="outlined"
                            @blur="officeLoadAppts()"
                            @input="repValuesChangedAppts = true; districtValuesChanged = true;">
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">District</span>
              </template>
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
                    {{ districtModelAppts.length }} Checked
                  </span>
              </template>
              <template v-if="districtDataAppts.length > 0" v-slot:prepend-item>
                <v-list-item @click="[districtValuesChanged = true, toggleSelectAllDistrictsAppts()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ districtSelectIconAppts }}</v-icon>
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
            </a-autocomplete>

            <a-autocomplete ref="officeSelect"
                            v-model="officeModelAppts"
                            :items="officeDataAppts"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="org_name"
                            item-value="org_id"
                            label="Office"
                            multiple
                            no-data-text="No offices available"
                            return-object
                            variant="outlined"
                            @blur="officeValuesChanged = true; repLoadAppts()"
                            @input="repValuesChangedAppts = true">
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">Office</span>
              </template>
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
                    {{ officeModelAppts.length }} Checked
                  </span>
              </template>
              <template v-if="officeDataAppts.length > 0" v-slot:prepend-item>
                <v-list-item @click="[officeValuesChanged = true, toggleSelectAllOfficesAppts()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ officeSelectIconAppts }}</v-icon>
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
            </a-autocomplete>
            <a-autocomplete ref="repSelect"
                            v-model="repModelAppts"
                            :items="repDataAppts"
                            class="appts-to-fdc-pipeline-dropdown"
                            density="compact"
                            hide-details
                            item-title="name"
                            item-value="user_position_id"
                            label="Rep"
                            multiple
                            no-data-text="No reps available"
                            return-object
                            variant="outlined"
                            @input="repValuesChangedAppts = true; apptsToFdcPipelineData.value = []">
              <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0 && repModelAppts[0].user_id != -1" class="selected-option text-caption">
                    {{ repModelAppts.length }} Checked
                  </span>
                <span v-if="index === 0 && repModelAppts[0].user_id === -1" class="selected-option text-caption-sm">
                        {{ filteredApptsRepDataMaster.length }} Checked
                  </span>
              </template>
              <template v-slot:label="{ item, index }">
                <span class="rep-filter-placeholder">Rep</span>
              </template>
              <template v-if="repModelAppts.length > 0" v-slot:prepend-item>
                <v-list-item
                  @click="[repValuesChangedAppts = true, repDataSelectAllUpcomingAppointments = !repDataSelectAllUpcomingAppointments, toggleSelectAllRepsUpcomingAppointments()]">
                  <v-list-item-action class="mr-2">
                    <v-icon>{{ repSelectIconAppts }}</v-icon>
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
            </a-autocomplete>
            <a-btn
              v-if="!isSetter && !isSetterMgr"
              :class="{'reset-button-inactive': !filtersSelectedAppts && repModelAppts?.length === 0 && !hideInactiveApptsReps, 'reset-button-active': filtersSelectedAppts || repModelAppts?.length > 0 || hideInactiveApptsReps}"
              class="body-small"
              color="unset"
              text="Reset Rep Filters"
              variant="outlined"
              @click="resetFiltersAppts"
            ></a-btn>
          </div>
        </v-col>
        <v-col class="d-flex justify-end" cols="3">
          <div class="flex-display align-right">
            <a-btn
              id="all-reps-btn"
              :text="viewAllRepsTextAppts"
              class="body-small"
              color="primary"
              variant="outlined"
              @click="funnelAllRepsUpcomingAppointments"
            ></a-btn>
          </div>
        </v-col>
      </div>


      <!-- FUNNEL -->
      <div class="funnel-container">
        <div v-if="apptsCreatedPipelineData.length > 0" id="appts-created-pipeline-funnel-background"
             :style="{'margin-top': showApptsCreatedPipelineCustomDates && windowInnerWidth < 1135 ? '77px' :
                                 showApptsCreatedPipelineCustomDates && windowInnerWidth >= 1135 ? '83px' : '59px'}"></div>
        <v-data-table
          v-if="upcomingApptsExpanded"
          id="upcoming-data-table"
          ref="pageable-table"
          :footer-props="footerProps"
          :headers="upcomingAppointmentsHeaders"
          :hide-default-footer="true"
          :items="upcomingAppointmentsData"
          :loading="isLoading"
          :mobile-breakpoint="0"
          class="elevation-1 body-medium"
        >

          <template #no-data>
            <span class="default-text-color">{{ upcomingApptsText }}</span>
          </template>


          <template id="milestones-header" #header.milestone="{}"><span class="milestones-header">Milestones</span>
          </template>


          <template id="milestones-col" #item.project_id="{item, index}" class="milestone-name-col-td">
            <router-link v-if="item.project_id && userStore.userHasFeature('PROJECTS')" :to="`/project/${item.project_id}/${defaultProjectPage}`"
                         class="body-medium" text>
              {{ item.project_id }}
            </router-link>
          </template>

          <template id="milestones-col" #item.appointment_start_time="{item, index}" class="milestone-name-col-td">
            {{ item.appointment_start_time | formatDate('timestamp', 'MM/DD/YYYY, h:mm a') }}
          </template>
          <template id="milestones-col" #item.date_created="{item, index}" class="milestone-name-col-td">
            {{ item.appointment_start_time | formatDate('date', 'MM/DD/YYYY') }}
          </template>
          <template #item.actualTotal="{item, index}" class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
              <span @click="funnelDrilldown(item, getDropdownById(fdcFirstDateRange), 'standard', true)">
                {{ item.count_count ? item.count_count : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && item.trend_count>0"
                      :class="[{'positive-percentage': !item.reverse_trend, 'negative-percentage': item.reverse_trend}]">+{{ item.trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': !item.reverse_trend, 'negative-trendline': item.reverse_trend}]">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && item.trend_count<0"
                      :class="[{'positive-percentage': item.reverse_trend, 'negative-percentage': !item.reverse_trend}]">{{ item.trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': item.reverse_trend, 'negative-trendline': !item.reverse_trend}]">trending_down</v-icon></span>
                <span v-if="viewFdcTrends && (item.trend_count ===null || item.trend_count===0)"
                      class="neutral-percentage">{{ item.trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
                </span>
              </span>
              </template>
              <span v-if="viewFdcTrends && item.trend_count>0"> {{ Math.abs(item.trend_count) / 100 | percent }} more than {{ getDropdownById(fdcFirstDateRange).trendText
                }}</span>
              <span v-if="viewFdcTrends && item.trend_count<0"> {{ Math.abs(item.trend_count) / 100 | percent }} less than {{ getDropdownById(fdcFirstDateRange).trendText
                }}</span>
              <span
                v-if="viewFdcTrends && (item.trend_count ===null || item.trend_count===0)"> Same as {{ getDropdownById(fdcFirstDateRange).trendText
                }}</span>
            </v-tooltip>
          </template>

          <template v-if="fdcSecondDateRange != null && fdcColumn2Values != null && fdcColumn2Values.length > 0" #item.actualTotal2="{item, index}"
                    class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="openDrilldown(item, 2)">
              {{ fdcColumn2Values[index].count_count ? fdcColumn2Values[index].count_count : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && fdcColumn2Values[index].trend_count>0"
                      :class="[{'positive-percentage': !fdcColumn2Values[index].reverse_trend, 'negative-percentage': fdcColumn2Values[index].reverse_trend}]">+{{ fdcColumn2Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': !fdcColumn2Values[index].reverse_trend, 'negative-trendline': fdcColumn2Values[index].reverse_trend}]">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && fdcColumn2Values[index].trend_count<0"
                      :class="[{'positive-percentage': fdcColumn2Values[index].reverse_trend, 'negative-percentage': !fdcColumn2Values[index].reverse_trend}]">{{ fdcColumn2Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': fdcColumn2Values[index].reverse_trend, 'negative-trendline': !fdcColumn2Values[index].reverse_trend}]">trending_down</v-icon></span>
                <span
                  v-if="viewFdcTrends && (fdcColumn2Values[index].trend_count === null || fdcColumn2Values[index].trend_count==0)"
                  class="neutral-percentage">{{ fdcColumn2Values[index].trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewFdcTrends && fdcColumn2Values[index].trend_count>0"> {{ Math.abs(fdcColumn2Values[index].trend_count) / 100 | percent
                }} more than {{ getDropdownById(fdcSecondDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && fdcColumn2Values[index].trend_count<0"> {{ Math.abs(fdcColumn2Values[index].trend_count) / 100 | percent
                }} less than {{ getDropdownById(fdcSecondDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && (fdcColumn2Values[index].trend_count ===null || fdcColumn2Values[index].trend_count===0)"> Same as {{ getDropdownById(fdcSecondDateRange).trendText
                }}</span>
            </v-tooltip>
          </template>
          <template v-if="fdcThirdDateRange != null && fdcColumn3Values != null && fdcColumn3Values.length > 0" #item.actualTotal3="{item, index}"
                    class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="openDrilldown(item, 3)">
              {{ fdcColumn3Values[index].count_count ? fdcColumn3Values[index].count_count : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && fdcColumn3Values[index].trend_count>0"
                      :class="[{'positive-percentage': !fdcColumn3Values[index].reverse_trend, 'negative-percentage': fdcColumn3Values[index].reverse_trend}]">+{{ fdcColumn3Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': !fdcColumn3Values[index].reverse_trend, 'negative-trendline': fdcColumn3Values[index].reverse_trend}]">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && fdcColumn3Values[index].trend_count<0"
                      :class="[{'positive-percentage': fdcColumn3Values[index].reverse_trend, 'negative-percentage': !fdcColumn3Values[index].reverse_trend}]">{{ fdcColumn3Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': fdcColumn3Values[index].reverse_trend, 'negative-trendline': !fdcColumn3Values[index].reverse_trend}]">trending_down</v-icon></span>
                <span
                  v-if="viewFdcTrends && (fdcColumn3Values[index].trend_count === null || fdcColumn3Values[index].trend_count === 0)"
                  class="neutral-percentage">{{ fdcColumn3Values[index].trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewFdcTrends && fdcColumn3Values[index].trend_count>0"> {{ Math.abs(fdcColumn3Values[index].trend_count) / 100 | percent
                }} more than {{ getDropdownById(fdcThirdDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && fdcColumn3Values[index].trend_count<0"> {{ Math.abs(fdcColumn3Values[index].trend_count) / 100 | percent
                }} less than {{ getDropdownById(fdcThirdDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && (fdcColumn3Values[index].trend_count ===null || fdcColumn3Values[index].trend_count===0)"> Same as {{ getDropdownById(fdcThirdDateRange).trendText
                }}</span>
            </v-tooltip>
          </template>
          <template v-if="fdcFourthDateRange != null && fdcColumn4Values != null && fdcColumn4Values.length > 0" #item.actualTotal4="{item, index}"
                    class="milestone-col-td">
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
            <span @click="openDrilldown(item, 4)">
              {{ fdcColumn4Values[index].count_count ? fdcColumn4Values[index].count_count : 0 }}
              <span v-on="viewFdcTrends?on:null">
                <span v-if="viewFdcTrends && fdcColumn4Values[index].trend_count>0"
                      :class="[{'positive-percentage': !fdcColumn4Values[index].reverse_trend, 'negative-percentage': fdcColumn4Values[index].reverse_trend}]">+{{ fdcColumn4Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': !fdcColumn4Values[index].reverse_trend, 'negative-trendline': fdcColumn4Values[index].reverse_trend}]">trending_up</v-icon></span>
                <span v-if="viewFdcTrends && fdcColumn4Values[index].trend_count<0"
                      :class="[{'positive-percentage': fdcColumn4Values[index].reverse_trend, 'negative-percentage': !fdcColumn4Values[index].reverse_trend}]">{{ fdcColumn4Values[index].trend_count / 100 | percent
                  }}<v-icon
                    :class="[{'positive-trendline': fdcColumn4Values[index].reverse_trend, 'negative-trendline': !fdcColumn4Values[index].reverse_trend}]">trending_down</v-icon></span>
                <span
                  v-if="viewFdcTrends && (fdcColumn4Values[index].trend_count === null || fdcColumn4Values[index].trend_count === 0)"
                  class="neutral-percentage">{{ fdcColumn4Values[index].trend_count / 100 | percent }}<v-icon
                  class="neutral-trendline">trending_flat</v-icon></span>
              </span>
            </span>
              </template>
              <span
                v-if="viewFdcTrends && fdcColumn4Values[index].trend_count>0"> {{ Math.abs(fdcColumn4Values[index].trend_count) / 100 | percent
                }} more than {{ getDropdownById(fdcFourthDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && fdcColumn4Values[index].trend_count<0"> {{ Math.abs(fdcColumn4Values[index].trend_count) / 100 | percent
                }} less than {{ getDropdownById(fdcFourthDateRange).trendText }}</span>
              <span
                v-if="viewFdcTrends && (fdcColumn4Values[index].trend_count ===null || fdcColumn4Values[index].trend_count===0)"> Same as {{ getDropdownById(fdcFourthDateRange).trendText
                }}</span>
            </v-tooltip>
          </template>
        </v-data-table>
      </div>
    </div>

    <!--  APPOINTMENTS TO FDC PIPELINE END-->

    <v-dialog v-model="funnelDrilldownDialog" @input="closeFunnelDrilldownDialog">
      <v-card id="funnel-drilldown">
        <v-card-title class="mb-1">
          <span id="funnel-drilldown-title">{{ funnelDrilldownTitle }}</span>
          <a class="close-modal-x pb-3" title="Close" @click="closeFunnelDrilldownDialog">×</a>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-title v-if="funnelDrilldownData.length > 0" id="funnel-drilldown-search" class="pt-2">
          <a-text-field v-model="funnelDrilldownSearch"
                        density="compact"
                        hide-details
                        placeholder="Type to filter..."
                        single-line
                        variant="outlined"
          ></a-text-field>
          <span id="funnel-drilldown-row-count">
            Records: {{ funnelDrilldownRowCount + '/' + funnelDrilldownData.length }}
          </span>
        </v-card-title>

        <v-card-text>
          <v-data-table
            id="funnel-drilldown-table"
            :class="{'mt-6': funnelDrilldownData.length === 0}"
            :footer-props="footerProps"
            :headers="visibleFunnelDrilldownHeaders"
            :height="funnelDrilldownRowCount > 0 ? (constants.IS_MOBILE ? 'calc(100vh - 250px)' : 'calc(100vh - 365px)') : '105px'"
            :items="funnelDrilldownData"
            :items-per-page="500"
            :loading="funnelDrilldownLoading"
            :mobile-breakpoint="0"
            :search="funnelDrilldownSearch"
            :sort-by="[]"
            :sort-desc="[]"
            class="elevation-1"
            dense
            fixed-header
            multi-sort
            @current-items="filteredFunnelDrilldownItems"
          >
            <template v-if="funnelDrilldownData.length > 0" #item="{ item, index }">
              <tr :class="['text-sm-left', 'row-hover', {'shaded-row': !(index % 2)}]"
                  :style="{'text-decoration': item.cancelled_date ? 'line-through' : ''}">
                <td style="text-align: center">
                  {{ funnelDrilldownSearch ? index + 1 : item.rowNum }}
                </td>
                <td>{{ item.setter_name || '' }}</td>
                <td class="customer-name">{{ item.customer_name || '' }}</td>
                <td>
                  <router-link v-if="item.project_id && userStore.userHasFeature('PROJECTS')" :to="`/project/${item.project_id}/${defaultProjectPage}`"
                               text>
                    {{ item.project_id }}
                  </router-link>
                  <div v-else>{{ item.project_id || '' }}</div>
                </td>
                <td>{{ item.appointment_date | formatDate('timestamp', 'MM/DD/YYYY') }}</td>
                <td>{{ item.owner_name || '' }}</td>
                <td v-if="!nonNormalFunnelIds.includes(funnelId)">{{ item.verified_setter_lead || '' }}</td>
                <td v-if="!nonNormalFunnelIds.includes(funnelId)" :class="item.appointment_outcome_class">
                  {{ item.appointment_outcome || '' }}
                </td>
                <td v-if="!nonNormalFunnelIds.includes(funnelId)">
                  {{ item.checked_in_time | formatDate('timestamp', 'MM/DD/YYYY h:mm a') }}
                </td>
                <td v-if="funnelId === 31">{{
                    item.installation_agreement_signed_date | formatDate('date', 'MM/DD/YYYY')
                  }}
                </td>
                <td v-if="funnelId === 32">{{ item.final_design_complete_date | formatDate('date', 'MM/DD/YYYY') }}</td>
                <td>{{ item.date_created | formatDate('timestamp', 'MM/DD/YYYY') }}</td>
                <td>{{ item.state || '' }}</td>
                <td>{{ item.office || '' }}</td>
              </tr>
            </template>

            <template #no-data>
              <div class="my-3 funnel-drilldown-no-data-msg default-text-color">
                No data is available for the selected date range.
              </div>
            </template>

            <template #no-results>
              <div class="my-3 funnel-drilldown-no-data-msg default-text-color">
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
            text="Close"
            @click="closeFunnelDrilldownDialog"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <!------------------------------------- FUNNEL TAB END ------------------------------------>

    <ConfirmationDialog v-if="selectingCustomDates"
                        :disableConfirm="customDate.startDate === null || customDate.endDate === null || customDate.startDate?.length === 0 || customDate.endDate?.length === 0"
                        :open-dialog="selectingCustomDates" @cancel="cancelCustomDialogue()"
                        @confirm="applyCustomDates()" @close-dialog="selectingCustomDates = false">
      <template v-slot:title>Custom Date Range</template>
      <div>
        <DatetimePickerInput
          v-model="customDate.startDate"
          :format="'MMMM DD, YYYY'"
          :timezone="timezone"
          :type="'date'"
          input-format="HH:mm:ss"
          label="Start Date"
        />
        <DatetimePickerInput
          v-model="customDate.endDate"
          :format="'MMMM DD, YYYY'"
          :timezone="timezone"
          :type="'date'"
          input-format="HH:mm:ss"
          label="End Date"
        />
      </div>
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Confirm</template>

    </ConfirmationDialog>

  </v-container>
</template>

<script setup>
import cloneDeep from 'lodash.clonedeep'
import moment from 'moment'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import constants from '@/helpers/constants'
import { getProjectPath, getRequestWithParams, handleHidingGlobalLoader, postRequest } from '@/helpers/helpers'
import { saveAs } from 'file-saver'
import {
  getSetterAreas,
  getSetterDistricts,
  getSetterOffices,
  getSetterRegions,
  getSetterReps
} from '@/services/dashboardService'

import { computed, getCurrentInstance, onMounted, ref } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useRoute, useRouter } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const filters = vueInstance.$filters
const defaultProjectPage = ref(getProjectPath().pathSuffix)

const pipeline_dt1 = ref(moment().startOf('year').format('YYYY-MM-DD'))
const pipeline_dt2 = ref(moment().format('YYYY-MM-DD'))
const setterPipelineLoading = ref(false)
const upcomingAppointmentsData = ref([])
const upcomingAppointmentsDataLoaded = ref(false)
const futureAppointmentsLoading = ref(false)
const funnelDataLoaded = ref(false)
const funnelStats = ref([])
const modelOverride = ref(false)
const viewFdcTrends = ref(true)
const viewTrends = ref(false)
const viewOnlyMajorMilestones = ref(false)
const disableTrends = ref(false)
const firstDateRange = ref(2)
const secondDateRange = ref(null)
const thirdDateRange = ref(null)
const fdcFirstDateRange = ref(2)
const fdcSecondDateRange = ref(null)
const fdcThirdDateRange = ref(null)
const fdcFourthDateRange = ref(null)
const firstCustom = ref({ startDate: '', endDate: '', trendStart: '', trendEnd: '', isActive: false })
const secondCustom = ref({ startDate: '', endDate: '', trendStart: '', trendEnd: '', isActive: false })
const thirdCustom = ref({ startDate: '', endDate: '', trendStart: '', trendEnd: '' })
const fdcFirstCustom = ref({ startDate: '', endDate: '', trendStart: '', trendEnd: '', isActive: false })
const fdcSecondCustom = ref({ startDate: '', endDate: '', trendStart: '', trendEnd: '', isActive: false })
const fdcThirdCustom = ref({ startDate: '', endDate: '', trendStart: '', trendEnd: '' })
const fdcFourthCustom = ref({ startDate: '', endDate: '', trendStart: '', trendEnd: '' })
const firstPeriod = ref(null)
const secondPeriod = ref(null)
const thirdPeriod = ref(null)
const fourthPeriod = ref(null)
const isLoading = ref(true)
const isBrCorporateUser = ref(userStore.details.companyId === 2)
const openFirstMenu = ref(false)
const openSecondMenu = ref(false)
const openThirdMenu = ref(false)
const fdcOpenFirstMenu = ref(false)
const fdcOpenSecondMenu = ref(false)
const fdcOpenThirdMenu = ref(false)
const fdcOpenFourthMenu = ref(false)
const funnelDrilldownDialog = ref(false)
const currentUserOrgId = ref(null)
const dropdownValuesLoading = ref(true)
const dropdownValues = ref([])
const isSetter = ref(false)
const isSetterMgr = ref(false)
const isSetterDistrictMgr = ref(false)
const selectedFunnel = ref({})
const isSetterRegional = ref(false)
const userCanViewAll = ref(userStore.userHasFeatureAccessLevel('CLOSER_DASHBOARD', 'VIEW_ALL'))
const userCanViewAllProjects = ref(userStore.userHasFeatureAccessLevel('PROJECTS', 'VIEW_ALL'))
const headers = ref([])
const reverseTrends = ref([
  'Cancelled in advance',
  'Ineligible for solar',
  'Rescheduled',
  'Homeowner no show',
  'Closer missed appointment',
  'Turned away at the door',
  'No utility bill',
  'Non-dispositioned appointments'
])
const fdcHeaders = ref([])
const upcomingAppointmentsHeaders = ref([])
const drilldownData = ref([])
const apptsToFdcPipelineLoaded = ref(false)
const upcomingAppointmentsLoaded = ref(false)
const pipelineLoaded = ref(false)
const appointmentTypes = ref([])
const appointmentTypesModel = ref([])
const funnelsWereLoaded = ref(false)
const currentQuarter = ref(moment().quarter())
const closerOffices = ref([])
const selectedCloserOffice = ref(null)
const leadAllocationRankingData = ref([])
const officeFdcRankingData = ref([])
const officeRankingData = ref([])
const topRepsData = ref([])
const tomorrow = ref(new Date())
const customTable = ref('apptsCreated')
const lastColumnSelected = ref(0)
const milestonesExpanded = ref(true)
const apptsCreatedExpanded = ref(true)
const fdcPipelineExpanded = ref(true)
const upcomingApptsExpanded = ref(true)
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
const nonNormalFunnelIds = ref([31, 32])
const funnelId = ref(null)
const fdcExpandableMilestones = ref([0, 3, 11, 14])
const milestonesSwitching = ref(false)
const hideInactiveReps = ref(false)
const hideInactiveApptsReps = ref(false)
const fdcMilestonesExpanded = ref([true, true, true, true])
const brsProvidedSourceModel = ref([])
const leadsCreatedSourceModel = ref([])
const leadsCreatedSourceData = ref([])
const fdcSourceModel = ref([])
const fdcSourceData = ref([])
const brsProvidedSourceData = ref([])
const selfGenSourceModel = ref([])
const selfGenSourceData = ref([])
const areaModel = ref([])
const areaData = ref([])
const areaModelAppts = ref([])
const areaDataAppts = ref([])
const regionModel = ref([])
const regionData = ref([])
const regionModelAppts = ref([])
const regionDataAppts = ref([])
const districtModel = ref([])
const districtData = ref([])
const districtModelAppts = ref([])
const districtDataAppts = ref([])
const officeModel = ref([])
const officeData = ref([])
const officeModelAppts = ref([])
const officeDataAppts = ref([])
const repModel = ref([])
const repData = ref([])
const selectedRepData = ref([])
const selectedRepDataAppts = ref([])
const repModelAppts = ref([])
const repDataAppts = ref([])
const repDataMaster = ref([])
const repDataMasterAppts = ref([])
const repDataSelectAll = ref(false)
const viewAllFilteredReps = ref(false)
const viewAllFilteredRepsAppts = ref(false)
const repDataSelectAllUpcomingAppointments = ref(false)
const appointmentTypesSelectAll = ref(false)
const apptsCreatedPipelineDateRange = ref({
  label: 'Month to Date', value: 'MTD'
})
const showApptsCreatedPipelineCustomDates = ref(false)
const apptsToFdcPipelineDateRanges = ref([
  { label: 'Yesterday', value: 'yesterday' },
  { label: 'Last Week', value: 'lastWeek' },
  { label: 'Month to Date', value: 'MTD' },
  { label: 'Last 60 days', value: 60 },
  { label: 'Last 90 days', value: 90 },
  { label: 'Year to Date', value: 'YTD' },
  { label: 'Custom', value: 'Custom' }
])
const initialPageLoad = ref(true)
const maxRepLimit = ref(1000)
const areaValuesChanged = ref(false)
const regionValuesChanged = ref(false)
const districtValuesChanged = ref(false)
const officeValuesChanged = ref(false)
const repValuesChanged = ref(false)
const repValuesChangedAppts = ref(false)
const apptsToFdcPipelineDateRange = ref({
  label: 'Month to Date', value: 'MTD'
})
const showApptsToFdcPipelineCustomDates = ref(false)
const viewSelect = ref('standard')
const appts_created_pipeline_dt1 = ref(moment().startOf('month').format('YYYY-MM-DD'))
const appts_created_pipeline_dt1_formatted = ref(moment().startOf('month').format('M/D/YY'))
const appts_created_pipeline_menu1 = ref(false)
const appts_created_pipeline_dt2 = ref(moment().format('YYYY-MM-DD'))
const appts_created_pipeline_dt2_formatted = ref(moment().format('M/D/YY'))
const appts_created_pipeline_menu2 = ref(false)
const appts_to_fdc_pipeline_dt1 = ref(moment().startOf('month').format('YYYY-MM-DD'))
const appts_to_fdc_pipeline_dt1_formatted = ref(moment().startOf('month').format('M/D/YY'))
const appts_to_fdc_pipeline_menu1 = ref(false)
const appts_to_fdc_pipeline_dt2 = ref(moment().format('YYYY-MM-DD'))
const appts_to_fdc_pipeline_dt2_formatted = ref(moment().format('M/D/YY'))
const appts_to_fdc_pipeline_menu2 = ref(false)
const funnelDrilldownTitle = ref('')
const funnelDrilldownData = ref([])
const funnelDrilldownLoading = ref(false)
const funnelDrilldownSearch = ref('')
const filteredFunnelDrilldownData = ref([])
const funnelDrilldownRowCount = ref(0)
const totalSystemSize = ref(0)
const repLengthOverride = ref(false)
const repLengthOverrideUpcomingAppointments = ref(false)
const footerProps = ref({
  showFirstLastPage: !constants.IS_MOBILE,
  firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
  lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
  'items-per-page-options': [100, 500, 1000, 2500, 5000, 10000]
})
const column2Values = ref([])
const column3Values = ref([])
const column4Values = ref([])
const fdcColumn2Values = ref([])
const fdcColumn3Values = ref([])
const fdcColumn4Values = ref([])
const selectingCustomDates = ref(false)
const customDate = ref({ startDate: '', endDate: '', trendStart: '', trendEnd: '' })
const closerDashContainer = ref(null)

const timezone = computed(() => {
  return userStore.timezone.value || 'US/Mountain'
})
const currentUserId = computed(() => {
  return userStore.details.id
})

const filtersSelected = computed(() => {
  return (areaModel.value.length > 0 || regionModel.value.length > 0 || districtModel.value.length > 0 || officeModel.value.length > 0)
})

const filtersSelectedAppts = computed(() => {
  return (areaModelAppts.value.length > 0 || regionModelAppts.value.length > 0 || districtModelAppts.value.length > 0 || officeModelAppts.value.length > 0)
})

const viewAllRepsText = computed(() => {
  if (repModel.value.length > 0) {
    return 'View Selected Reps'
  }
  if (filtersSelected.value || hideInactiveReps.value) {
    return 'View All Filtered Reps'
  } else {
    return 'View All Reps'
  }
})

const viewAllRepsTextAppts = computed(() => {
  if (repModelAppts.value.length > 0) {
    return 'View Selected Reps'
  }
  if (filtersSelectedAppts.value || hideInactiveApptsReps.value) {
    return 'View All Filtered Reps'
  } else {
    return 'View All Reps'
  }
})

const upcomingApptsText = computed(() => {
  if (upcomingAppointmentsDataLoaded.value) {
    return 'No Upcoming Appointments'
  } else {
    return 'Select Reps to View Upcoming Appointments'
  }
})

const filteredRepData = computed(() => {
  if (!hideInactiveReps.value) {
    return repData.value
  } else {
    return repData.value.filter(dv => dv.active)
  }
})

const filteredApptsCreatedPipelineData = computed(() => {
  if (!milestonesExpanded.value) {
    return apptsCreatedPipelineData.value.filter(dv => dv.display_order < 3)
  }
  return apptsCreatedPipelineData.value
})
const filteredFdcPipelineData = computed(() => {
  // return apptsToFdcPipelineData.value?.filter((data, index) => {
  //   return fdcExpandableMilestones.value?.includes(index)
  // })
  if (viewOnlyMajorMilestones.value) {
    return apptsToFdcPipelineData.value?.filter((data, index) => {
      return fdcExpandableMilestones.value?.includes(index)
    })
  } else return apptsToFdcPipelineData.value
})
const funnelDrilldownHeaders = computed(() => {
  return [
    { text: '', value: '', show: true, sortable: false, width: 25 },
    { text: 'Setter', value: 'setter_name', show: true, width: 90 },
    { text: 'Name', value: 'customer_name', show: true, width: 90 },
    { text: 'Project ID', value: 'project_id', show: true, width: 95 },
    { text: 'Appointment Date', value: 'appointment_date', show: true, width: 150 },
    { text: 'Closer', value: 'owner_name', show: true, width: 90 },
    {
      text: 'Verified Setter Lead',
      value: 'verified_setter_lead',
      show: !nonNormalFunnelIds.value.includes(funnelId.value),
      width: 170
    },
    {
      text: 'Appointment Outcome',
      value: 'appointment_outcome',
      show: !nonNormalFunnelIds.value.includes(funnelId.value),
      width: 175
    },
    {
      text: 'Checked In Time',
      value: 'checked_in_time',
      show: !nonNormalFunnelIds.value.includes(funnelId.value),
      width: 175
    },
    { text: 'Booking Date', value: 'installation_agreement_signed_date', show: funnelId.value === 31, width: 175 },
    {
      text: 'Final Design Complete Date',
      value: 'final_design_complete_date',
      show: funnelId.value === 32,
      width: 175
    },
    { text: 'Date Created', value: 'date_created', show: true, width: 115 },
    { text: 'State', value: 'state', show: true, width: 80 },
    { text: 'Office', value: 'office', show: true, width: 90 }
  ]
})
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
const selectAllLeadsCreatedSources = computed(() => {
  return leadsCreatedSourceModel.value.length === leadsCreatedSourceData.value.length
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
const selectAllAreasAppts = computed(() => {
  return areaModelAppts.value.length === areaDataAppts.value.length
})
const selectSomeAreas = computed(() => {
  return areaModel.value.length > 0 && !selectAllAreas.value
})
const selectSomeAreasAppts = computed(() => {
  return areaModelAppts.value.length > 0 && !selectAllAreasAppts.value
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
const areaSelectIconAppts = computed(() => {
  if (areaModelAppts.value.length === areaDataAppts.value.length) {
    return 'check_box'
  }
  if (selectSomeAreasAppts.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllRegions = computed(() => {
  return regionModel.value.length === regionData.value.length
})

const selectAllRegionsAppts = computed(() => {
  return regionModelAppts.value.length === regionDataAppts.value.length
})
const selectSomeRegions = computed(() => {
  return regionModel.value.length > 0 && !selectAllRegions.value
})
const selectSomeRegionsAppts = computed(() => {
  return regionModelAppts.value.length > 0 && !selectAllRegionsAppts.value
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
const regionSelectIconAppts = computed(() => {
  if (regionModelAppts.value.length === regionDataAppts.value.length) {
    return 'check_box'
  }
  if (selectSomeRegionsAppts.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllDistricts = computed(() => {
  return districtModel.value.length === districtData.value.length
})
const selectAllDistrictsAppts = computed(() => {
  return districtModelAppts.value.length === districtDataAppts.value.length
})
const selectSomeDistricts = computed(() => {
  return districtModel.value.length > 0 && !selectAllDistricts.value
})
const selectSomeDistrictsAppts = computed(() => {
  return districtModelAppts.value.length > 0 && !selectAllDistrictsAppts.value
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
const districtSelectIconAppts = computed(() => {
  if (districtModelAppts.value.length === districtDataAppts.value.length) {
    return 'check_box'
  }
  if (selectSomeDistrictsAppts.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllOffices = computed(() => {
  return officeModel.value.length === officeData.value.length
})
const selectAllOfficesAppts = computed(() => {
  return officeModelAppts.value.length === officeDataAppts.value.length
})
const selectSomeOffices = computed(() => {
  return officeModel.value.length > 0 && !selectAllOffices.value
})
const selectSomeOfficesAppts = computed(() => {
  return officeModelAppts.value.length > 0 && !selectAllOfficesAppts.value
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
const officeSelectIconAppts = computed(() => {
  if (officeModelAppts.value.length === officeDataAppts.value.length) {
    return 'check_box'
  }
  if (selectSomeOfficesAppts.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllReps = computed(() => {
  return repModel.value.length === repData.value.length || repLengthOverride.value
})
const selectAllRepsUpcomingAppointments = computed(() => {
  return repModelAppts.value.length === repDataAppts.value.length || repLengthOverrideUpcomingAppointments.value
})
const selectSomeReps = computed(() => {
  return repModel.value.length > 0 && !selectAllReps.value
})
const selectSomeRepsAppts = computed(() => {
  return repModelAppts.value.length > 0 && !selectAllRepsUpcomingAppointments.value
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
const repSelectIconAppts = computed(() => {
  if (repModelAppts.value.length === repDataAppts.value.length) {
    return 'check_box'
  }
  if (selectSomeRepsAppts.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
// visibleFunnelDrilldownHeaders() {
//   return funnelDrilldownHeaders.value.filter(header => header.show === true)
// },
const showTotalSystemSize = computed(() => {
  return funnelDrilldownRowCount.value > 0
})

onMounted(async () => {
  tomorrow.value.setDate(tomorrow.value.getDate() + 1)
  tomorrow.value = (tomorrow.value.getMonth() + 1).toString().concat('/').concat(tomorrow.value.getDate()).concat('/').concat(tomorrow.value.getFullYear())
  await getDropdownValues()
  if (userStore.details.userPositions?.length > 0) {
    let positionId = null

    isSetter.value = userStore.details.userPositions.filter(position => {
      return (position.positionId === 1 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    isSetterMgr.value = userStore.details.userPositions.filter(position => {
      return (position.positionId === 2 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    isSetterDistrictMgr.value = userStore.details.userPositions.filter(position => {
      return (position.positionId === 517 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    let fakeSetterMgr = userStore.details.userPositions.filter(position => {
      return (position.positionId === 326 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    isSetterRegional.value = userStore.details.userPositions.filter(position => {
      return (position.positionId === 3 && !position.endDate && !position.archived && position.primaryFlag)
    }).length > 0

    if (isSetter.value) {
      positionId = 1
    } else if (isSetterMgr.value) {
      positionId = 2
    } else if (isSetterDistrictMgr.value) {
      positionId = 517
    } else if (isSetterRegional.value) {
      positionId = 3
    } else if (fakeSetterMgr) {
      positionId = 326
    }

    if (isSetter.value || isSetterMgr.value || isSetterDistrictMgr.value || isSetterRegional.value) {
      currentUserOrgId.value = userStore.details.userPositions.filter(position => {
        return (position.positionId === positionId && !position.endDate && !position.archived && position.primaryFlag)
      })[0]?.orgId
    }

    if (fakeSetterMgr || isSetterDistrictMgr.value) {
      isSetterMgr.value = true
    }
  }
  headers.value = [
    { text: 'Milestones', value: 'milestone', sortable: false, class: 'milestone-col-th', show: true },
    { text: 'Source', value: 'source', align: 'left', sortable: false, class: 'total-col-th data-col-th', show: true },
    {
      text: 'Today',
      value: 'actualTotal',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    },
    {
      text: 'Today2',
      value: 'actualTotal2',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    },
    {
      text: 'Today3',
      value: 'actualTotal3',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    }
  ]
  fdcHeaders.value = [
    { text: 'Milestones', value: 'milestone', sortable: false, class: 'milestone-col-th', show: true }, {
      text: 'Today',
      value: 'actualTotal',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    },
    {
      text: 'Today2',
      value: 'actualTotal2',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    },
    {
      text: 'Today3',
      value: 'actualTotal3',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    },
    {
      text: 'Today4',
      value: 'actualTotal4',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    }
  ]
  upcomingAppointmentsHeaders.value = [
    { text: 'Setter', value: 'setter_name', sortable: true, class: 'milestone-col-th', show: true }, {
      text: 'Project Name',
      value: 'project_name',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value,
      sortable: true
    },
    {
      text: 'Project ID',
      value: 'project_id',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    },
    {
      text: 'Appointment Start Time',
      value: 'appointment_start_time',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    },
    {
      text: 'Closer',
      value: 'closer_name',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    },
    {
      text: 'Phone Number',
      value: 'phone_number',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    },
    {
      text: 'Date Created',
      value: 'date_created',
      align: 'left',
      class: 'total-col-th data-col-th',
      show: !isBrCorporateUser.value
    }
  ]
  appStore.loading = true
  await loadFunnels()
  appStore.loading = false
  // await pipelineLoad(1)
  funnelsWereLoaded.value = true
})

const resetFilters = async () => {
  areaModel.value = []
  regionModel.value = []
  districtModel.value = []
  officeModel.value = []
  repModel.value = []
  hideInactiveReps.value = false
  repData.value = cloneDeep(repDataMaster.value)
}

const resetFiltersAppts = async () => {
  areaModelAppts.value = []
  regionModelAppts.value = []
  districtModelAppts.value = []
  officeModelAppts.value = []
  repModelAppts.value = []
  hideInactiveApptsReps.value = false
  repDataAppts.value = cloneDeep(repDataMasterAppts.value)
}
const exportCsv = async (tableName) => {
  appStore.loading = true
  try {
    if (tableName === 'pipeline') {
      let filename = 'Setter Dashboard - Pipeline.csv'
      let csvData = ' , '
      if (dropdownValues.value.find(x => x.id === fdcFirstDateRange.value).name === 'PERIOD') {
        csvData += dropdownValues.value.find(x => x.id === fdcFirstDateRange.value).periodList[fdcFirstPeriod.value].shortLabel
      } else {
        csvData += ((dropdownValues.value.find(x => x.id === fdcFirstDateRange.value).name === 'CUSTOM') ? fdcFirstCustom.value.name : dropdownValues.value.find(x => x.id === fdcFirstDateRange.value).friendlyName)
      }
      csvData += ', ' + 'Trend 1'
      if (fdcSecondDateRange.value) {
        if (dropdownValues.value.find(x => x.id === fdcSecondDateRange.value).name === 'PERIOD') {
          csvData += ' , ' + dropdownValues.value.find(x => x.id === fdcSecondDateRange.value).periodList[fdcSecondPeriod.value].shortLabel
        } else {
          csvData += ', ' + ((dropdownValues.value.find(x => x.id === fdcSecondDateRange.value).name === 'CUSTOM') ? fdcSecondCustom.value.name : dropdownValues.value.find(x => x.id === fdcSecondDateRange.value).friendlyName)
        }
        csvData += ', ' + 'Trend 2'
      }
      if (fdcThirdDateRange.value) {
        if (dropdownValues.value.find(x => x.id === fdcThirdDateRange.value).name === 'PERIOD') {
          csvData += ' , ' + dropdownValues.value.find(x => x.id === fdcThirdDateRange.value).periodList[fdcThirdPeriod.value].shortLabel
        } else {
          csvData += ', ' + ((dropdownValues.value.find(x => x.id === fdcThirdDateRange.value).name === 'CUSTOM') ? fdcThirdCustom.value.name : dropdownValues.value.find(x => x.id === fdcThirdDateRange.value).friendlyName)
        }
        csvData += ', ' + 'Trend 3'
      }
      if (fdcFourthDateRange.value) {
        if (dropdownValues.value.find(x => x.id === fdcFourthDateRange.value).name === 'PERIOD') {
          csvData += ' , ' + dropdownValues.value.find(x => x.id === fdcFourthDateRange.value).periodList[fdcFourthPeriod.value].shortLabel
        } else {
          csvData += ', ' + ((dropdownValues.value.find(x => x.id === fdcFourthDateRange.value).name === 'CUSTOM') ? fdcFourthCustom.value.name : dropdownValues.value.find(x => x.id === fdcFourthDateRange.value).friendlyName)
        }
        csvData += ', ' + 'Trend 4'
      }
      csvData += '\n'

      funnelStats.value.forEach((p, i) => {
        csvData += p.name + ',' + (p.count_count ? p.count_count : 0)
        csvData += ', ' + (p.trend_count ? p.trend_count : 0) + '%'
        if (fdcSecondDateRange.value) {
          csvData += ', ' + (column2Values.value[i].count_count ? column2Values.value[i].count_count : 0)
          csvData += ', ' + (column2Values.value[i].trend_count ? column2Values.value[i].trend_count : 0) + '%'
        }
        if (fdcThirdDateRange.value) {
          csvData += ', ' + (column3Values.value[i].count_count ? column3Values.value[i].count_count : 0)
          csvData += ', ' + (column3Values.value[i].trend_count ? column3Values.value[i].trend_count : 0) + '%'
        }
        if (fdcFourthDateRange.value) {
          csvData += ', ' + (column4Values.value[i].count_count ? column4Values.value[i].count_count : 0)
          csvData += ', ' + (column4Values.value[i].trend_count ? column4Values.value[i].trend_count : 0) + '%'
        }
        csvData += '\n'
      })
      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      })

      saveAs(blob, filename)
    } else if (tableName === 'appts') {
      let filename = 'Setter Dashboard - Upcoming Appointments.csv'
      let csvData = ' , '
      csvData += moment(tomorrow.value).format('MM/DD/YYYY')
      csvData += '\n'
      csvData += 'Setter, Project Name, Project ID, Appointment Start Time, Closer, Phone Number, Date Created'
      csvData += '\n'

      upcomingAppointmentsData.value.forEach((p, i) => {
        csvData += p.setter_name + ',' + p.project_name + ',' + p.project_id + ',"' + moment(p.appointment_start_time).format('MM/DD/YYYY, h:mm a') + '",' + p.closer_name + ',' + p.phone_number + ',' + moment(p.date_created).format('MM/DD/YYYY')
        csvData += '\n'
      })

      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      })

      saveAs(blob, filename)
    }


    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Residual Review')

    appStore.loading = false
  }
}
const expandMilestones = () => {
  milestonesExpanded.value = true
}
const hideMilestones = () => {
  milestonesExpanded.value = false
}
const getDropdownValues = async () => {
  try {
    appStore.loading = true

    const params = {
      today: moment().format('YYYY-MM-DD')
    }

    const { data, status } = await getRequestWithParams('/setterDashboard/dropdownValues', { params }, 'blueraven', [])
    // Rearanging the menu here
    dropdownValues.value = data
    isLoading.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving data')
    isLoading.value = false
    appStore.loading = false
  }
}
const openDrilldown = async (item, column) => {
  if (column === 1) {
    if (dropdownValues.value.find(x => x.id === firstDateRange.value).name === 'PERIOD') {
      startDate.value = moment(dropdownValues.value.find(x => x.id === firstDateRange.value).periodList[firstPeriod.value].startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = moment(dropdownValues.value.find(x => x.id === firstDateRange.value).periodList[firstPeriod.value].endDate).format('YYYY-MM-DDTHH:mm:ss')
    } else {
      startDate.value = dropdownValues.value.find(x => x.id === firstDateRange.value).startDate ? dropdownValues.value.find(x => x.id === firstDateRange.value).startDate : moment(firstCustom.value.startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = dropdownValues.value.find(x => x.id === firstDateRange.value).endDate ? dropdownValues.value.find(x => x.id === firstDateRange.value).endDate : moment(firstCustom.value.endDate).format('YYYY-MM-DDTHH:mm:ss')
    }
  } else if (column === 2) {
    if (dropdownValues.value.find(x => x.id === secondDateRange.value).name === 'PERIOD') {
      startDate.value = moment(dropdownValues.value.find(x => x.id === secondDateRange.value).periodList[secondPeriod.value].startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = moment(dropdownValues.value.find(x => x.id === secondDateRange.value).periodList[secondPeriod.value].endDate).format('YYYY-MM-DDTHH:mm:ss')
    } else {
      startDate.value = dropdownValues.value.find(x => x.id === secondDateRange.value).startDate ? dropdownValues.value.find(x => x.id === secondDateRange.value).startDate : moment(secondCustom.value.startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = dropdownValues.value.find(x => x.id === secondDateRange.value).endDate ? dropdownValues.value.find(x => x.id === secondDateRange.value).endDate : moment(secondCustom.value.endDate).format('YYYY-MM-DDTHH:mm:ss')
    }
  } else if (column === 3) {
    if (dropdownValues.value.find(x => x.id === thirdDateRange.value).name === 'PERIOD') {
      startDate.value = moment(dropdownValues.value.find(x => x.id === thirdDateRange.value).periodList[thirdPeriod.value].startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = moment(dropdownValues.value.find(x => x.id === thirdDateRange.value).periodList[thirdPeriod.value].endDate).format('YYYY-MM-DDTHH:mm:ss')
    } else {
      startDate.value = dropdownValues.value.find(x => x.id === thirdDateRange.value).startDate ? dropdownValues.value.find(x => x.id === thirdDateRange.value).startDate : moment(thirdCustom.value.startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = dropdownValues.value.find(x => x.id === thirdDateRange.value).endDate ? dropdownValues.value.find(x => x.id === thirdDateRange.value).endDate : moment(thirdCustom.value.endDate).format('YYYY-MM-DDTHH:mm:ss')
    }
  }
  if ((moment(endDate.value).diff(moment(startDate.value), 'days') + 1) > 100) {
    return
  }
  selectedMilestone.value = item
  await getDrilldownHeaders()
  await getDrilldownData(column)
  showDrilldown.value = true
}

const changeFdcDropdownSelection = async (dropdown) => {
  customTable.value = 'FDC'
  lastColumnSelected.value = dropdown
  if (dropdown === 1) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === fdcFirstDateRange.value))
    if (result === null) {
      return null
    }
    if (result.startDate === null) {
      if (!fdcFirstCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          if (fdcFirstCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = fdcFirstCustom.value.startDate.format('YYYY-MM-DD').toString()
          }
          if (fdcFirstCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = fdcFirstCustom.value.endDate.format('YYYY-MM-DD').toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[firstPeriod.value].startDate
          result.endDate = result.periodList[firstPeriod.value].endDate
          if (firstPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[firstPeriod.value + 1].startDate
            result.trendEnd = result.periodList[firstPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(fdcFirstCustom.value)
        resetCustomDate()
        fdcFirstCustom.value.isActive = false
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await pipelineLoad(1)
  } else if (dropdown === 2) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === fdcSecondDateRange.value))
    if (result === null) {
      return null
    }
    if (result.startDate === null) {
      if (!fdcSecondCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          if (fdcSecondCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = fdcSecondCustom.value.startDate.format('YYYY-MM-DD').toString()
          }
          if (fdcSecondCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = fdcSecondCustom.value.endDate.format('YYYY-MM-DD').toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[secondPeriod.value].startDate
          result.endDate = result.periodList[secondPeriod.value].endDate
          if (secondPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[secondPeriod.value + 1].startDate
            result.trendEnd = result.periodList[secondPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(fdcSecondCustom.value)
        resetCustomDate()
        fdcSecondCustom.value.isActive = false
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await pipelineLoad(2)
  } else if (dropdown === 3) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === fdcThirdDateRange.value))
    if (result == null) {
      return null
    }
    if (result.startDate === null) {
      if (!fdcThirdCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          if (fdcThirdCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = fdcThirdCustom.value.startDate.format('YYYY-MM-DD').toString()
          }
          if (fdcThirdCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = fdcThirdCustom.value.endDate.format('YYYY-MM-DD').toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[thirdPeriod.value].startDate
          result.endDate = result.periodList[thirdPeriod.value].endDate
          if (thirdPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[thirdPeriod.value + 1].startDate
            result.trendEnd = result.periodList[thirdPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(fdcThirdCustom.value)
        resetCustomDate()
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await pipelineLoad(3)
  } else if (dropdown === 4) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === fdcFourthDateRange.value))
    if (result == null) {
      return null
    }
    if (result.startDate === null) {
      if (!fdcFourthCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          if (fdcFourthCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = fdcFourthCustom.value.startDate.format('YYYY-MM-DD').toString()
          }
          if (fdcFourthCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = fdcFourthCustom.value.endDate.format('YYYY-MM-DD').toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[fourthPeriod.value].startDate
          result.endDate = result.periodList[fourthPeriod.value].endDate
          if (fourthPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[fourthPeriod.value + 1].startDate
            result.trendEnd = result.periodList[fourthPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(fdcFourthCustom.value)
        resetCustomDate()
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await pipelineLoad(4)
  }
}

const changeDropdownSelection = async (dropdown) => {
  customTable.value = 'apptsCreated'
  if (dropdown === 1) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === firstDateRange.value))
    if (result === null) {
      return null
    }
    if (result.startDate === null) {
      if (!firstCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          if (firstCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = firstCustom.value.startDate.format('YYYY-MM-DD').toString()
          }
          if (firstCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = firstCustom.value.endDate.format('YYYY-MM-DD').toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[firstPeriod.value].startDate
          result.endDate = result.periodList[firstPeriod.value].endDate
          if (firstPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[firstPeriod.value + 1].startDate
            result.trendEnd = result.periodList[firstPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(firstCustom.value)
        resetCustomDate()
        firstCustom.value.isActive = false
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await upcomingAppointmentsLoad(1)
  } else if (dropdown === 2) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === secondDateRange.value))
    if (result === null) {
      return null
    }
    if (result.startDate === null) {
      if (!secondCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          if (secondCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = secondCustom.value.startDate.format('YYYY-MM-DD').toString()
          }
          if (secondCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = secondCustom.value.endDate.format('YYYY-MM-DD').toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[secondPeriod.value].startDate
          result.endDate = result.periodList[secondPeriod.value].endDate
          if (secondPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[secondPeriod.value + 1].startDate
            result.trendEnd = result.periodList[secondPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(secondCustom.value)
        resetCustomDate()
        secondCustom.value.isActive = false
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await upcomingAppointmentsLoad(2)
  } else if (dropdown === 3) {
    let result = cloneDeep(dropdownValues.value.find(x => x.id === thirdDateRange.value))
    if (result == null) {
      return null
    }
    if (result.startDate === null) {
      if (!thirdCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          if (thirdCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = thirdCustom.value.startDate.format('YYYY-MM-DD').toString()
          }
          if (thirdCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = thirdCustom.value.endDate.format('YYYY-MM-DD').toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[thirdPeriod.value].startDate
          result.endDate = result.periodList[thirdPeriod.value].endDate
          if (thirdPeriod.value != result.periodList.length - 1) {
            result.trendStart = result.periodList[thirdPeriod.value + 1].startDate
            result.trendEnd = result.periodList[thirdPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(thirdCustom.value)
        resetCustomDate()
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await upcomingAppointmentsLoad(3)
  }
}

const getDropdownById = (id) => {
  return dropdownValues.value.find(x => x.id === id)
}

const getDropdownTrendText = (id, columnNum) => {
  // Handle Custom case
  if (id === 12) {
    const customObjects = {
      1: fdcFirstCustom.value,
      2: fdcSecondCustom.value,
      3: fdcThirdCustom.value,
      4: fdcFourthCustom.value
    }

    // Get the appropriate custom object based on column number
    const customObj = customObjects[columnNum]

    // Return formatted date range if the custom object exists
    if (customObj) {
      return `${moment(customObj.trendStart).format('MM/DD/YYYY')} - ${moment(customObj.trendEnd).format('MM/DD/YYYY')}`
    }
  }

  // Return trend text for non-custom dropdown values
  return dropdownValues.value.find(x => x.id === id).trendText
}

const exportDrilldownCsv = () => {
  let csv = ''

  visibleFunnelDrilldownHeaders().forEach(h => {
    if (h.text !== '') {
      return csv += `${h.text},`
    }
  })
  csv += `\n`

  funnelDrilldownData.value.forEach(o => {

    visibleFunnelDrilldownHeaders().forEach(h => {
      if (h.text !== '') {
        if (h.dateType !== null && h.dateType !== undefined) {
          //if it is a date it needs to be formatted here
          csv += '"' + `${o[h.value] === null || o[h.value] === undefined ? '' : filters.formatDate(o[h.value], h.dateType, h.dateFormat)}` + '",'
        } else {
          csv += '"' + `${o[h.value] === null || o[h.value] === undefined ? '' : o[h.value]}` + '",'
        }
      }
    })
    csv += `\n`
  })

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8' })
  saveAs(blob, `${funnelDrilldownTitle.value}.csv`)
}
const itemRowBackground = (item) => {
  return item.display_order < 3 ? 'shaded-row' : ''
}
const fdcRowBackground = (item) => {
  return (item.display_order % 2) ? 'shaded-row' : ''
}

const fdcExpandMilestone = (index) => {
  milestonesSwitching.value = true
  fdcMilestonesExpanded.value[fdcExpandableMilestones.value.indexOf(index)] = true
  milestonesSwitching.value = false

}
const fdcHideMilestone = (index) => {
  milestonesSwitching.value = true
  fdcMilestonesExpanded.value[fdcExpandableMilestones.value.indexOf(index)] = false
  milestonesSwitching.value = false
}

const visibleFunnelDrilldownHeaders = computed(() => {
  return funnelDrilldownHeaders.value.filter(header => header.show === true)
})

const resetScrollBarPosition = () => {
  // reset scroll bar position to top
  closerDashContainer.value.scrollTop = 0
}

/* FUNNEL-RELATED CODE START */

const filteredRepDataMaster = computed(() => {
  if (!hideInactiveReps.value) {
    return repDataMaster.value
  } else {
    return repDataMaster.value.filter(dv => dv.active)
  }
})

const filteredApptsRepDataMaster = computed(() => {
  if (!hideInactiveApptsReps.value) {
    return repDataMasterAppts.value
  } else {
    return repDataMasterAppts.value.filter(dv => dv.active)
  }
})

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
      upcomingAppointmentsLoad(1)
    }
  })
}

const viewSelected = (view) => {
  if (viewSelect.value !== view) {
    viewSelect.value = view
    pipelineLoad(1)
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

const pipelineLoad = async (column) => {
  setterPipelineLoading.value = true
  appStore.loading = true
  let dateSelected = null
  if (column === 1) {
    dateSelected = getDropdownById(fdcFirstDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate = dateSelected.periodList[firstPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[firstPeriod.value].endDate
      dateSelected.trendStart = dateSelected.periodList[firstPeriod.value].trendStart
      dateSelected.trendEnd = dateSelected.periodList[firstPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = fdcFirstCustom.value
    }
  }
  if (column === 2) {
    dateSelected = getDropdownById(fdcSecondDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate = dateSelected.periodList[secondPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[secondPeriod.value].endDate
      dateSelected.trendStart = dateSelected.periodList[secondPeriod.value].trendStart
      dateSelected.trendEnd = dateSelected.periodList[secondPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = fdcSecondCustom.value
    }
  }

  if (column === 3) {
    dateSelected = getDropdownById(fdcThirdDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate = dateSelected.periodList[thirdPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[thirdPeriod.value].endDate
      dateSelected.trendStart = dateSelected.periodList[thirdPeriod.value].trendStart
      dateSelected.trendEnd = dateSelected.periodList[thirdPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = fdcThirdCustom.value
    }
  }
  if (column === 4) {
    dateSelected = getDropdownById(fdcFourthDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate = dateSelected.periodList[fourthPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[fourthPeriod.value].endDate
      dateSelected.trendStart = dateSelected.periodList[fourthPeriod.value].trendStart
      dateSelected.trendEnd = dateSelected.periodList[fourthPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = fdcFourthCustom.value
    }
  }
  let orgs = []

  // if ((repModel.value.length === 0 && !useRepDataInstead) || (useRepDataInstead && repData.value.length === 0)) {
  //   funnelStats.value = []
  //   setterPipelineLoading.value = false
  //   return
  // }

  officeModel.value.forEach(org => orgs.push(org.org_id))

  selectedRepData.value = []
  if (viewAllFilteredReps.value && repModel.value.length === 0) {
    filteredRepData.value.forEach(rep => selectedRepData.value.push(rep.user_position_id))
  } else {
    repModel.value.forEach(rep => selectedRepData.value.push(rep.user_position_id))
  }


  // funnelStatsLoading.value = true
  try {
    const requestBody = {
      users: selectedRepData.value,
      orgs: orgs,
      start: dateSelected.startDate,
      end: dateSelected.endDate,
      trendStart: dateSelected.trendStart,
      trendEnd: dateSelected.trendEnd,
      hideInactive: hideInactiveReps.value
    }
    await postRequest('/setterDashboard/funnel', requestBody, 'blueraven').then(({ data }) => {
      data.forEach(row => {
        // TODAY column
        row.countTodayState = row.today_day_count < 0 ? 'red' : 'green'
        row.percentToday = row.today_percent ? row.today_percent + '%' : '0%'
        row.percentTodayState = getPercentColor(row.today_percent)
        row.percentTodayHover = getPercentHover(row.today_percent, 1)

        // LAST 7 DAYS column
        row.count7state = row.seven_day_count < 0 ? 'red' : 'green'
        row.percent7 = row.seven_percent ? row.seven_percent + '%' : '0%'
        row.percent7state = getPercentColor(row.seven_percent)
        row.percent7hover = getPercentHover(row.seven_percent, 7)

        // LAST 30 DAYS column
        row.count30state = row.thirty_day_count < 0 ? 'red' : 'green'
        row.percent30 = row.thirty_day_percent ? row.thirty_day_percent + '%' : '0%'
        row.percent30state = getPercentColor(row.thirty_day_percent)
        row.percent30hover = getPercentHover(row.thirty_day_percent, 30)

        // CUSTOM DATE RANGE column
        row.count_count = Math.round(row.count_count)
        row.customCountState = row.count_count < 0 ? 'red' : 'green'
      })


      if (column === 1) {
        funnelStats.value = data
      } else if (column === 2) {
        fdcColumn2Values.value = data
      } else if (column === 3) {
        fdcColumn3Values.value = data
      } else if (column === 4) {
        fdcColumn4Values.value = data
      }
      setterPipelineLoading.value = false
      appStore.loading = false
    })
  } catch (e) {
    setterPipelineLoading.value = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving data')

    funnelDataLoaded.value = true
    appStore.loading = false
  }
}

const upcomingAppointmentsLoad = async () => {
  setterPipelineLoading.value = true
  appStore.loading = true

  let reps = []
  let orgs = []

  officeModel.value.forEach(org => orgs.push(org.org_id))

  modelOverride.value = false

  selectedRepDataAppts.value = []
  if (viewAllFilteredRepsAppts.value && repModelAppts.value.length === 0) {
    repDataAppts.value.forEach(rep => selectedRepDataAppts.value.push(rep.user_position_id))
  } else {
    repModelAppts.value.forEach(rep => selectedRepDataAppts.value.push(rep.user_position_id))
  }

  try {
    const requestBody = {
      users: selectedRepDataAppts.value,
      orgs: orgs
    }
    await postRequest('/setterDashboard/upcomingAppointments', requestBody, 'blueraven').then(({ data }) => {
      upcomingAppointmentsData.value = data
      upcomingAppointmentsDataLoaded.value = true
      setterPipelineLoading.value = false
      appStore.loading = false
    })
  } catch (e) {
    setterPipelineLoading.value = false
    appStore.loading = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving data')

    funnelDataLoaded.value = true
    appStore.loading = false
  }
}

const futureAppointmentsLoad = async (column) => {
  futureAppointmentsLoading.value = true
  let dateSelected = null

  let reps = []
  let orgs = []

  // if ((repModel.value.length === 0 && !useRepDataInstead) || (useRepDataInstead && repData.value.length === 0)) {
  //   funnelStats.value = []
  //   setterPipelineLoading.value = false
  //   return
  // }

  officeModel.value.forEach(org => orgs.push(org.org_id))

  modelOverride.value = false
  // if (useRepDataInstead) {
  repData.value.forEach((rep, index) => {
    reps.push(rep.user_position_id)

    if (index === repData.value.length - 1) {
      // districtModel.value = []
      // regionModel.value = []
      // officeModel.value = []

      if (repDataSelectAll.value && repDataMaster.value?.length > maxRepLimit.value) {
        modelOverride.value = true
        repModel.value = [
          { user_id: null, user_position_id: null, name: 'All Filtered Reps', active: true }
        ]
        repData.value = [
          { user_id: null, user_position_id: null, name: 'All Filtered Reps', active: true }
        ]
      }
    }
  })
  // } else {
  //   repModel.value.forEach(rep => reps.push(rep.user_position_id))
  // }

  if (modelOverride.value) {
    reps = []
    //this gets used when there are more than 1000 users selected
    repDataMaster.value.forEach(rep => reps.push(rep.user_position_id))
  }
  // funnelStatsLoading.value = true
  try {
    const requestBody = {
      users: reps,
      orgs: orgs,
      start: dateSelected.startDate,
      end: dateSelected.endDate,
      trendStart: dateSelected.trendStart,
      trendEnd: dateSelected.trendEnd,
      hideInactive: hideInactiveReps.value
    }
    await postRequest('/setterDashboard/funnel', requestBody, 'blueraven').then(({ data }) => {
      data.forEach(row => {
        // TODAY column
        row.countTodayState = row.today_day_count < 0 ? 'red' : 'green'
        row.percentToday = row.today_percent ? row.today_percent + '%' : '0%'
        row.percentTodayState = getPercentColor(row.today_percent)
        row.percentTodayHover = getPercentHover(row.today_percent, 1)

        // LAST 7 DAYS column
        row.count7state = row.seven_day_count < 0 ? 'red' : 'green'
        row.percent7 = row.seven_percent ? row.seven_percent + '%' : '0%'
        row.percent7state = getPercentColor(row.seven_percent)
        row.percent7hover = getPercentHover(row.seven_percent, 7)

        // LAST 30 DAYS column
        row.count30state = row.thirty_day_count < 0 ? 'red' : 'green'
        row.percent30 = row.thirty_day_percent ? row.thirty_day_percent + '%' : '0%'
        row.percent30state = getPercentColor(row.thirty_day_percent)
        row.percent30hover = getPercentHover(row.thirty_day_percent, 30)

        // CUSTOM DATE RANGE column
        row.count_count = Math.round(row.count_count)
        row.customCountState = row.count_count < 0 ? 'red' : 'green'
      })


      if (column === 1) {
        funnelStats.value = data
      } else if (column === 2) {
        fdcColumn2Values.value = data
      } else if (column === 3) {
        fdcColumn3Values.value = data
      } else if (column === 4) {
        fdcColumn4Values.value = data
      }
      setterPipelineLoading.value = false
    })
  } catch (e) {
    setterPipelineLoading.value = false
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving data')

    funnelDataLoaded.value = true
    appStore.loading = false
  }
}
const getPercentColor = (percent) => {
  if (percent < 0) return 'red'
  return 'green'
}
const getPercentHover = (percent, dayNum) => {
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
}

const loadFunnels = async () => {

  if (apptsToFdcPipelineData.value?.length === 0) {
    if (isSetter.value || isSetterMgr.value || isSetterRegional.value) {
      await areaLoad(true)
      await regionLoad(true, true)
      await districtLoad(true, true)
      await officeLoad(true, true)
      await repLoad(true)
      initialPageLoad.value = false
    } else {
      await areaLoad(false)
      await regionLoad(false, true)
      await districtLoad(false, true)
      await officeLoad(false, true)
      await repLoad(false)
      initialPageLoad.value = false
    }
  }
}

const funnelAllReps = async () => {
  viewAllFilteredReps.value = true
  pipelineLoad(1)
  if (fdcSecondDateRange.value) {
    pipelineLoad(2)
  }
  if (fdcThirdDateRange.value) {
    pipelineLoad(3)
  }
  if (fdcFourthDateRange.value) {
    pipelineLoad(4)
  }
}

const funnelAllRepsUpcomingAppointments = async () => {
  viewAllFilteredRepsAppts.value = true
  upcomingAppointmentsLoad()
}

const applyCustomDates = async () => {
  if (customTable.value === 'apptsCreated') {
    if (lastColumnSelected.value === 1) {
      firstCustom.value.startDate = moment(customDate.value.startDate)
      firstCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = firstCustom.value.endDate.diff(firstCustom.value.startDate, 'days')
      firstCustom.value.trendEnd = firstCustom.value.startDate.clone().subtract(1, 'days')
      firstCustom.value.trendStart = firstCustom.value.trendEnd.clone().subtract(dateDiff, 'days')
      getDropdownById(firstDateRange.value).trendText = moment(firstCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(firstCustom.value.trendEnd).format('MM/DD/YYYY')
      firstCustom.value.name = moment(firstCustom.value.startDate).format('MM/DD/YY') + '-' + moment(firstCustom.value.endDate).format('MM/DD/YY')
    }
    if (lastColumnSelected.value === 2) {
      secondCustom.value.startDate = moment(customDate.value.startDate)
      secondCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = secondCustom.value.endDate.diff(secondCustom.value.startDate, 'days')
      secondCustom.value.trendEnd = secondCustom.value.startDate.clone().subtract(1, 'days')
      secondCustom.value.trendStart = secondCustom.value.trendEnd.clone().subtract(dateDiff, 'days')
      getDropdownById(secondDateRange.value).trendText = moment(secondCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(secondCustom.value.trendEnd).format('MM/DD/YYYY')
      secondCustom.value.name = moment(secondCustom.value.startDate).format('MM/DD/YY') + '-' + moment(secondCustom.value.endDate).format('MM/DD/YY')
    }
    if (lastColumnSelected.value === 3) {
      thirdCustom.value.startDate = moment(customDate.value.startDate)
      thirdCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = thirdCustom.value.endDate.diff(thirdCustom.value.startDate, 'days')
      thirdCustom.value.trendEnd = thirdCustom.value.startDate.clone().subtract(1, 'days')
      thirdCustom.value.trendStart = thirdCustom.value.trendEnd.clone().subtract(dateDiff, 'days')
      getDropdownById(thirdDateRange.value).trendText = moment(thirdCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(thirdCustom.value.trendEnd).format('MM/DD/YYYY')
      thirdCustom.value.name = moment(thirdCustom.value.startDate).format('MM/DD/YY') + '-' + moment(thirdCustom.value.endDate).format('MM/DD/YY')
    }
    if (lastColumnSelected.value === 4) {
      fourthCustom.value.startDate = moment(customDate.value.startDate)
      fourthCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = fourthCustom.value.endDate.diff(fourthCustom.value.startDate, 'days')
      fourthCustom.value.trendEnd = fourthCustom.value.startDate.clone().subtract(1, 'days')
      fourthCustom.value.trendStart = fourthCustom.value.trendEnd.clone().subtract(dateDiff, 'days')
      getDropdownById(fourthDateRange.value).trendText = moment(fourthCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(fourthCustom.value.trendEnd).format('MM/DD/YYYY')
      fourthCustom.value.name = moment(fourthCustom.value.startDate).format('MM/DD/YY') + '-' + moment(fourthCustom.value.endDate).format('MM/DD/YY')
    }

    await upcomingAppointmentsLoad(lastColumnSelected.value)
  } else {
    if (lastColumnSelected.value === 1) {
      fdcFirstCustom.value.startDate = moment(customDate.value.startDate)
      fdcFirstCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = fdcFirstCustom.value.endDate.diff(fdcFirstCustom.value.startDate, 'days')
      fdcFirstCustom.value.trendEnd = fdcFirstCustom.value.startDate.clone().subtract(1, 'days')
      fdcFirstCustom.value.trendStart = fdcFirstCustom.value.trendEnd.clone().subtract(dateDiff, 'days')

      getDropdownById(fdcFirstDateRange.value).trendText = moment(fdcFirstCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(fdcFirstCustom.value.trendEnd).format('MM/DD/YYYY')
      fdcFirstCustom.value.name = moment(fdcFirstCustom.value.startDate).format('MM/DD/YY') + '-' + moment(fdcFirstCustom.value.endDate).format('MM/DD/YY')
    }
    if (lastColumnSelected.value === 2) {
      fdcSecondCustom.value.startDate = moment(customDate.value.startDate)
      fdcSecondCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = fdcSecondCustom.value.endDate.diff(fdcSecondCustom.value.startDate, 'days')
      fdcSecondCustom.value.trendEnd = fdcSecondCustom.value.startDate.clone().subtract(1, 'days')
      fdcSecondCustom.value.trendStart = fdcSecondCustom.value.trendEnd.clone().subtract(dateDiff, 'days')
      getDropdownById(fdcSecondDateRange.value).trendText = moment(fdcSecondCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(fdcSecondCustom.value.trendEnd).format('MM/DD/YYYY')
      fdcSecondCustom.value.name = moment(fdcSecondCustom.value.startDate).format('MM/DD/YY') + '-' + moment(fdcSecondCustom.value.endDate).format('MM/DD/YY')
    }
    if (lastColumnSelected.value === 3) {
      fdcThirdCustom.value.startDate = moment(customDate.value.startDate)
      fdcThirdCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = fdcThirdCustom.value.endDate.diff(fdcThirdCustom.value.startDate, 'days')
      fdcThirdCustom.value.trendEnd = fdcThirdCustom.value.startDate.clone().subtract(1, 'days')
      fdcThirdCustom.value.trendStart = fdcThirdCustom.value.trendEnd.clone().subtract(dateDiff, 'days')
      getDropdownById(fdcThirdDateRange.value).trendText = moment(fdcThirdCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(fdcThirdCustom.value.trendEnd).format('MM/DD/YYYY')
      fdcThirdCustom.value.name = moment(fdcThirdCustom.value.startDate).format('MM/DD/YY') + '-' + moment(fdcThirdCustom.value.endDate).format('MM/DD/YY')
    }
    if (lastColumnSelected.value === 4) {
      fdcFourthCustom.value.startDate = moment(customDate.value.startDate)
      fdcFourthCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = fdcFourthCustom.value.endDate.diff(fdcFourthCustom.value.startDate, 'days')
      fdcFourthCustom.value.trendEnd = fdcFourthCustom.value.startDate.clone().subtract(1, 'days')
      fdcFourthCustom.value.trendStart = fdcFourthCustom.value.trendEnd.clone().subtract(dateDiff, 'days')
      getDropdownById(fdcFourthDateRange.value).trendText = moment(fdcFourthCustom.value.trendStart).format('MM/DD/YYYY') + ' - ' + moment(fdcFourthCustom.value.trendEnd).format('MM/DD/YYYY')
      fdcFourthCustom.value.name = moment(fdcFourthCustom.value.startDate).format('MM/DD/YY') + '-' + moment(fdcFourthCustom.value.endDate).format('MM/DD/YY')
    }

    await pipelineLoad(lastColumnSelected.value)
  }
}

const getPercentage = (numerator, denominator) => {
  if (denominator !== 0) {
    return Math.round((numerator / denominator) * 100)
  } else {
    return 0
  }
}

const areaLoad = async (preSelectLists) => {
  if (repValuesChanged.value || initialPageLoad.value) {
    if (!currentUserId.value) return

    await getSetterAreas(currentUserId.value, false).then(res => {
      if (res?.length > 0) {
        areaData.value = res
        if (initialPageLoad.value) {
          areaDataAppts.value = cloneDeep(areaData.value)
        }
      }

      if (preSelectLists && (isSetterMgr.value || isSetterRegional.value)) {
        areaModel.value = areaData.value.filter(od => od.active)
        if (initialPageLoad.value) {
          areaModelAppts.value = areaData.value.filter(od => od.active)
        }
      } else if (preSelectLists) {
        areaModel.value = cloneDeep(areaData.value)
        if (initialPageLoad.value) {
          areaModelAppts.value = cloneDeep(areaData.value)
        }
      }

      regionModel.value = []
      districtModel.value = []
      officeModel.value = []
      repModel.value = []

      if (!initialPageLoad.value) {
        regionLoad(preSelectLists, true)
      }
    })


    apptsToFdcPipelineData.value = []
    apptsToFdcPipelineLoaded.value = true
  }
}
const areaLoadAppts = async (preSelectLists) => {
  if (repValuesChangedAppts.value || initialPageLoad.value) {
    if (!currentUserId.value) return

    await getSetterAreas(currentUserId.value, false).then(res => {
      if (res?.length > 0) {
        areaDataAppts.value = res
      }

      if (preSelectLists && (isSetterMgr.value || isSetterRegional.value)) {
        areaModelAppts.value = areaDataAppts.value.filter(od => od.active)
      } else if (preSelectLists) {
        areaModelAppts.value = cloneDeep(areaDataAppts.value)
      }

      regionModelAppts.value = []
      districtModelAppts.value = []
      officeModelAppts.value = []
      repModelAppts.value = []

      if (!initialPageLoad.value) {
        regionLoad(preSelectLists, true)
      }
    })


    apptsCreatedPipelineData.value = []
    upcomingAppointmentsLoaded.value = true
  }
}

const regionLoad = async (preSelectLists) => {
  if (repValuesChanged.value || initialPageLoad.value) {
    if (!currentUserId.value) return

    let areas = areaModel.value.map(function(area) {
      return {
        area_id: area.org_id
      }
    })

    districtModel.value = []
    officeModel.value = []
    repModel.value = []


    await getSetterRegions(currentUserId.value, JSON.stringify(areas), false).then(res => {
      regionData.value = res
      if (initialPageLoad.value) {
        regionDataAppts.value = cloneDeep(regionData.value)
      }

      if (preSelectLists && (isSetterMgr.value || isSetterRegional.value)) {
        regionModel.value = regionData.value.filter(od => od.active)
        if (initialPageLoad.value) {
          regionModelAppts.value = regionData.value.filter(od => od.active)
        }
      } else if (preSelectLists) {
        regionModel.value = cloneDeep(regionData.value)
        if (initialPageLoad.value) {
          regionModelAppts.value = cloneDeep(regionData.value)
        }

      }

      if (!initialPageLoad.value) {
        districtLoad(preSelectLists, true)
      }
    })

    apptsToFdcPipelineData.value = []
  }
}

const regionLoadAppts = async (preSelectLists) => {
  if (repValuesChangedAppts.value || initialPageLoad.value) {
    if (!currentUserId.value) return

    let areas = areaModelAppts.value.map(function(area) {
      return {
        area_id: area.org_id
      }
    })

    districtModelAppts.value = []
    officeModelAppts.value = []
    repModelAppts.value = []


    await getSetterRegions(currentUserId.value, JSON.stringify(areas), false).then(res => {
      regionDataAppts.value = res


      if (preSelectLists && (isSetterMgr.value || isSetterRegional.value)) {
        regionModelAppts.value = regionDataAppts.value.filter(od => od.active)
      } else if (preSelectLists) {
        regionModelAppts.value = cloneDeep(regionDataAppts.value)
      }

      if (!initialPageLoad.value) {
        districtLoadAppts(preSelectLists, true)
      }
    })

    apptsCreatedPipelineData.value = []
  }
}

const districtLoad = async (preSelectLists) => {
  if (!currentUserId.value) return

  let areas = areaModel.value.map(function(area) {
    return {
      area_id: area.org_id
    }
  })

  let regions = regionModel.value.map(function(region) {
    return {
      region_id: region.org_id
    }
  })

  await getSetterDistricts(currentUserId.value, JSON.stringify(areas), JSON.stringify(regions), false).then(res => {
    if (res?.length > 0) {
      districtData.value = res
      if (initialPageLoad.value) {
        districtDataAppts.value = cloneDeep(districtData.value)
      }
    }

    if (preSelectLists && (isSetterMgr.value || isSetterRegional.value)) {
      districtModel.value = districtData.value.filter(od => od.active)
      if (initialPageLoad.value) {
        districtModelAppts.value = districtData.value.filter(od => od.active)
      }
    } else if (preSelectLists) {
      districtModel.value = cloneDeep(districtData.value)
      if (initialPageLoad.value) {
        districtModelAppts.value = cloneDeep(districtData.value)
      }
    }

    officeModel.value = []
    repModel.value = []

    if (!initialPageLoad.value) {
      officeLoad(preSelectLists, true)
    }
  })


  apptsToFdcPipelineData.value = []
  pipelineLoaded.value = true
}

const districtLoadAppts = async (preSelectLists) => {
  if (!currentUserId.value) return

  let areas = areaModelAppts.value.map(function(area) {
    return {
      area_id: area.org_id
    }
  })

  let regions = regionModelAppts.value.map(function(region) {
    return {
      region_id: region.org_id
    }
  })

  await getSetterDistricts(currentUserId.value, JSON.stringify(areas), JSON.stringify(regions), false).then(res => {
    if (res?.length > 0) {
      districtDataAppts.value = res
    }

    if (preSelectLists && (isSetterMgr.value || isSetterRegional.value)) {
      districtModelAppts.value = districtDataAppts.value.filter(od => od.active)
    } else if (preSelectLists) {
      districtModelAppts.value = cloneDeep(districtDataAppts.value)
    }

    officeModelAppts.value = []
    repModelAppts.value = []

    if (!initialPageLoad.value) {
      officeLoadAppts(preSelectLists, true)
    }
  })


  apptsCreatedPipelineData.value = []
  pipelineLoaded.value = true
}

const officeLoad = async (preSelectLists) => {
  if (repValuesChanged.value || initialPageLoad.value) {
    if (!currentUserId.value) return


    let areas = areaModel.value.map(function(area) {
      return {
        area_id: area.org_id
      }
    })

    let regions = regionModel.value.map(function(region) {
      return {
        region_id: region.org_id
      }
    })

    let districts = districtModel.value.map(function(district) {
      return {
        district_id: district.org_id
      }
    })

    repModel.value = []
    apptsToFdcPipelineData.value = []
    await getSetterOffices(currentUserId.value, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts), false).then(res => {
      officeData.value = res
      if (initialPageLoad.value) {
        officeDataAppts.value = cloneDeep(officeData.value)
      }
      if (preSelectLists && (isSetterMgr.value || isSetterRegional.value)) {
        officeModel.value = officeData.value.filter(od => od.active)
        if (initialPageLoad.value) {
          officeModelAppts.value = officeData.value.filter(od => od.active)
        }
      } else if (preSelectLists) {
        officeModel.value = cloneDeep(officeData.value)
        if (initialPageLoad.value) {
          officeModelAppts.value = cloneDeep(officeData.value)
        }
      }

      if (!initialPageLoad.value) {
        repLoad(preSelectLists, true)
      }
    })

    repModel.value = []
  }
  repValuesChanged.value = false
}

const officeLoadAppts = async (preSelectLists) => {
  if (repValuesChangedAppts.value || initialPageLoad.value) {
    if (!currentUserId.value) return


    let areas = areaModelAppts.value.map(function(area) {
      return {
        area_id: area.org_id
      }
    })

    let regions = regionModelAppts.value.map(function(region) {
      return {
        region_id: region.org_id
      }
    })

    let districts = districtModelAppts.value.map(function(district) {
      return {
        district_id: district.org_id
      }
    })

    repModelAppts.value = []
    apptsCreatedPipelineData.value = []
    await getSetterOffices(currentUserId.value, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts), false).then(res => {
      officeDataAppts.value = res

      if (preSelectLists && (isSetterMgr.value || isSetterRegional.value)) {
        officeModelAppts.value = officeDataAppts.value.filter(od => od.active)
      } else if (preSelectLists) {
        officeModelAppts.value = cloneDeep(officeData.value)
      }

      if (!initialPageLoad.value) {
        repLoadAppts(preSelectLists, true)
      }
    })

    repModelAppts.value = []
  }
  repValuesChangedAppts.value = false
}

const repLoad = async (preSelectLists) => {
  if (repValuesChanged.value || initialPageLoad.value) {
    if (!initialPageLoad.value) {
      appStore.loading = true
    }
    repModel.value = []
    repData.value = []
    repLengthOverride.value = false

    if (!currentUserId.value) return

    let areas = areaModel.value.map(function(area) {
      return {
        area_id: area.org_id
      }
    })

    let regions = regionModel.value.map(function(region) {
      return {
        region_id: region.org_id
      }
    })

    let districts = districtModel.value.map(function(district) {
      return {
        district_id: district.org_id
      }
    })

    let offices = officeModel.value.map(function(office) {
      return {
        office_id: office.org_id
      }
    })

    apptsCreatedPipelineData.value = []
    await getSetterReps(currentUserId.value, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts), JSON.stringify(offices)).then(res => {
      repData.value = res

      repDataMaster.value = cloneDeep(res)

      if (initialPageLoad) {
        repDataAppts.value = res

        repDataMasterAppts.value = cloneDeep(res)
      }
      if (preSelectLists) {
        viewAllFilteredReps.value = true
      }
    })
    initialPageLoad.value = false
    dropdownValuesLoading.value = false
    repValuesChanged.value = false
    if (!initialPageLoad.value) {
      appStore.loading = false
    }
  }
}
const repLoadAppts = async (preSelectLists) => {
  if (repValuesChangedAppts.value || initialPageLoad.value) {
    if (!initialPageLoad.value) {
      appStore.loading = true
    }
    repModelAppts.value = []
    repDataAppts.value = []

    if (!currentUserId.value) return

    let areas = areaModelAppts.value.map(function(area) {
      return {
        area_id: area.org_id
      }
    })

    let regions = regionModelAppts.value.map(function(region) {
      return {
        region_id: region.org_id
      }
    })

    let districts = districtModelAppts.value.map(function(district) {
      return {
        district_id: district.org_id
      }
    })

    let offices = officeModelAppts.value.map(function(office) {
      return {
        office_id: office.org_id
      }
    })

    apptsToFdcPipelineData.value = []
    await getSetterReps(currentUserId.value, JSON.stringify(areas), JSON.stringify(regions), JSON.stringify(districts), JSON.stringify(offices)).then(res => {
      repDataAppts.value = res

      repDataMasterAppts.value = cloneDeep(res)

      if (preSelectLists) {
        viewAllFilteredRepsAppts.value = true
      }

      // if(initialPageLoad.value) {
      //   apptsToFdcPipelineData.value = []
      //
      //   upcomingAppointmentsLoad(1)
      // }
    })
    initialPageLoad.value = false
    dropdownValuesLoading.value = false
    repValuesChangedAppts.value = false
    if (!initialPageLoad.value) {
      appStore.loading = false
    }
  }
}

const updateApptsCreatedPipelineCalendar = () => {
  appts_created_pipeline_menu1.value = false
  appts_created_pipeline_menu2.value = false
  upcomingAppointmentsLoad(1)
}

const updateApptsToFdcPipelineCalendar = () => {
  appts_to_fdc_pipeline_menu1.value = false
  appts_to_fdc_pipeline_menu2.value = false
  pipelineLoad(1)
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
    if (isSetter.value || isSetterMgr.value || isSetterRegional.value) {
      pipelineLoad(1)
    } else if (selectAllReps.value) {
      pipelineLoad(1)
    } else {
      pipelineLoad(1)
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
const funnelDrilldown = async (funnel, dateRange, funnelName, index) => {
  if (funnel.name === 'Pitch Percentage') {
    return
  }
  funnelId.value = funnel.id
  let orgs = []
  let start, end
  orgs = officeModel.value.map(org => org.org_id)

  let datesMatch
  const customValues = {
    1: fdcFirstCustom.value,
    2: fdcSecondCustom.value,
    3: fdcThirdCustom.value,
    4: fdcFourthCustom.value
  }

  let dateRangeFinal = dateRange.name === 'CUSTOM' ? {
    ...customValues[index],
    startDate: customValues[index].startDate.format('YYYY-MM-DD'),
    endDate: customValues[index].endDate.format('YYYY-MM-DD'),
    trendEnd: customValues[index].trendEnd.format('YYYY-MM-DD'),
    trendStart: customValues[index].trendStart.format('YYYY-MM-DD')
  } : dateRange

  if (dateRangeFinal.name === 'CUSTOM') {
    datesMatch = dateRangeFinal
      ? moment(dateRangeFinal.startDate).format('YYYY-MM-DD') === moment(dateRangeFinal.endDate).format('YYYY-MM-DD')
      : false
  } else {
    datesMatch = moment(dateRangeFinal.startDate).format('YYYY-MM-DD') === moment(dateRangeFinal.endDate).format('YYYY-MM-DD')
  }

  if (datesMatch) {
    funnelDrilldownTitle.value = funnel.name + ' on ' + moment(dateRangeFinal.startDate).format('M/D/YYYY')
  } else {
    funnelDrilldownTitle.value = funnel.name + ' ' + moment(dateRangeFinal.startDate).format('M/D/YYYY') + ' - ' + moment(dateRangeFinal.endDate).format('M/D/YYYY')
  }

  const requestBody = {
    start: dateRangeFinal.startDate,
    end: dateRangeFinal.endDate,
    funnelId: funnelId.value,
    users: selectedRepData.value,
    orgs: orgs,
    hideInactive: hideInactiveReps.value
  }

  appStore.loading = true
  try {
    await postRequest(`/setterDashboard/funnelDrilldown`, requestBody, 'blueraven').then(({ data }) => {
      funnelDrilldownData.value = data?.length > 0 ? data : []

      if (funnelDrilldownData.value?.length > 0) {
        for (let i = 0; i < funnelDrilldownData.value.length; i++) {
          funnelDrilldownData.value[i].rowNum = i + 1
        }

        markMissingDrilldownData()

        funnelDrilldownData.value.forEach(row => {
          if (row.verified_setter_lead !== null && row.verified_setter_lead === true) {
            row.verified_setter_lead = 'Yes'
          } else if (row.verified_setter_lead !== null && row.verified_setter_lead === false) {
            row.verified_setter_lead = 'No'
          }
        })
      }

      funnelDrilldownDialog.value = true
      appStore.loading = false
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving drilldown data')

    appStore.loading = false
  }
}

const markMissingDrilldownData = () => {
  funnelDrilldownData.value = funnelDrilldownData.value.map(function(line) {
    let newLine = {}

    Object.keys(line).forEach(function(key) {
      newLine[key] = line[key]
      if (key === 'cash_down_payment') {
        if (line.financier && line.financier.includes('Cash')) {
          newLine[key + '_class'] = line[key] == null ? 'missing' : ''
        }
      } else if (key === 'credit_decision_date') {
        if (line.financier && !line.financier.includes('Cash')) {
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

const filteredFunnelDrilldownItems = (filteredItems) => {
  filteredFunnelDrilldownData.value = filteredItems
  funnelDrilldownRowCount.value = filteredItems.length
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
      upcomingAppointmentsLoad(1)
    }
  })
}

const toggleSelectAllLeadsCreatedSources = () => {
  vueInstance.$nextTick(() => {
    if (selectAllLeadsCreatedSources.value) {
      leadsCreatedSourceModel.value = []
      apptsCreatedPipelineData.value[1] = {
        id: 13,
        name: 'Leads created',
        today_count: 0,
        week_to_date_count: 0,
        custom_date_range_count: 0
      }
    } else {
      leadsCreatedSourceModel.value = cloneDeep(leadsCreatedSourceData.value)
      upcomingAppointmentsLoad(1)
    }
  })
}

const toggleSelectAllAreas = async () => {
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
  }
  repValuesChanged.value = true
  await regionLoad(false)
  repValuesChanged.value = false
}

const toggleSelectAllAreasAppts = async () => {
  if (selectAllAreasAppts.value) {
    areaModelAppts.value = []
    regionDataAppts.value = []
    regionModelAppts.value = []
    districtDataAppts.value = []
    districtModelAppts.value = []
    officeDataAppts.value = []
    officeModelAppts.value = []
    repDataAppts.value = []
    repModelAppts.value = []
    apptsCreatedPipelineData.value = []
  } else {
    areaModelAppts.value = cloneDeep(areaDataAppts.value)
    repModelAppts.value = [] // in case the user previously clicked the 'All Reps' button
    //
  }
  repValuesChangedAppts.value = true
  await regionLoadAppts(false)
  repValuesChangedAppts.value = false
}

const toggleSelectAllRegions = async () => {
  if (selectAllRegions.value) {
    regionModel.value = []
    officeData.value = []
    officeModel.value = []
    districtData.value = []
    districtModel.value = []
    repData.value = []
    repModel.value = []
    apptsToFdcPipelineData.value = []
  } else {
    regionModel.value = cloneDeep(regionData.value)
  }
  repValuesChanged.value = true
  await districtLoad(false)
  repValuesChanged.value = false
}

const toggleSelectAllRegionsAppts = async () => {
  if (selectAllRegionsAppts.value) {
    regionModelAppts.value = []
    officeDataAppts.value = []
    officeModelAppts.value = []
    districtDataAppts.value = []
    districtModelAppts.value = []
    repDataAppts.value = []
    repModelAppts.value = []
    apptsCreatedPipelineData.value = []
  } else {
    regionModelAppts.value = cloneDeep(regionDataAppts.value)
  }
  repValuesChangedAppts.value = true
  await districtLoadAppts(false)
  repValuesChangedAppts.value = false
}

const toggleSelectAllDistricts = async () => {
  if (selectAllDistricts.value) {
    districtModel.value = []
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
  repValuesChanged.value = true
  await officeLoad(false)
  repValuesChanged.value = false
}

const toggleSelectAllDistrictsAppts = async () => {
  if (selectAllDistrictsAppts.value) {
    districtModelAppts.value = []
    officeDataAppts.value = []
    officeModelAppts.value = []
    repDataAppts.value = []
    repModelAppts.value = []
    apptsCreatedPipelineData.value = []
  } else {
    districtModelAppts.value = cloneDeep(districtDataAppts.value)
    // repModel.value = [] // in case the user previously clicked the 'All Reps' button
    // regionLoad(false)
  }
  repValuesChangedAppts.value = true
  await officeLoadAppts(false)
  repValuesChangedAppts.value = false
}

const toggleSelectAllOffices = async () => {
  if (selectAllOffices.value) {
    officeModel.value = []
    repData.value = []
    repModel.value = []
    apptsToFdcPipelineData.value = []
  } else {
    officeModel.value = cloneDeep(officeData.value)
    // repLoad(false)
  }
  repValuesChanged.value = true
  await repLoad(false)
  repValuesChanged.value = false
}

const toggleSelectAllOfficesAppts = async () => {
  if (selectAllOfficesAppts.value) {
    officeModelAppts.value = []
    repDataAppts.value = []
    repModelAppts.value = []
    apptsCreatedPipelineData.value = []
  } else {
    officeModelAppts.value = cloneDeep(officeData.value)
    // repLoad(false)
  }
  repValuesChangedAppts.value = true
  await repLoadAppts(false)
  repValuesChangedAppts.value = false
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
          { user_id: -2, user_position_id: -2, name: 'All Filtered Reps', active: true }
        ]
        doRepWatcher()
        repModel.value = cloneDeep(repData.value)
      } else {
        repModel.value = cloneDeep(repData.value)
      }
    }
  })
}

const toggleSelectAllRepsUpcomingAppointments = () => {
  vueInstance.$nextTick(() => {
    if (selectAllRepsUpcomingAppointments.value) {
      repModelAppts.value = []
      repLengthOverrideUpcomingAppointments.value = false
      apptsToFdcPipelineData.value = []
    } else {
      if (repDataSelectAllUpcomingAppointments.value && repDataAppts.value?.length > maxRepLimit.value) {
        //this is different than clicking the All Reps button and needs to be filtered.
        // -2 was updated to mean - select all reps in the selected orgs
        repLengthOverrideUpcomingAppointments.value = true
        repModelAppts.value = [
          { user_id: -2, user_position_id: -2, name: 'All Filtered Reps', active: true }
        ]
        doRepWatcher()
        repModelAppts.value = cloneDeep(repDataAppts.value)
      } else {
        repModelAppts.value = cloneDeep(repDataAppts.value)
      }
    }
  })
}

const toggleSelectAppointmentTypes = () => {
  vueInstance.$nextTick(() => {
    if (appointmentTypesSelectAll.value) {
      appointmentTypesModel.value = cloneDeep(appointmentTypes.value)
    } else {
      appointmentTypesModel.value = []
    }
  })
}

const closeFunnelDrilldownDialog = () => {
  funnelDrilldownDialog.value = false
  resetScrollBarPosition()
}
/* FUNNEL-RELATED CODE END */
</script>

<style lang="scss" scoped>
#all-reps-btn {
  text-transform: none;
  font-size: 0.75rem !important;
  margin-right: 8px !important;
  letter-spacing: normal;
}

#closer-funnel-table {
  overflow-x: auto !important;
}

.rep-filter-placeholder {
  font-family: lato;
}

.col-9 {
  padding-left: 0px;
}

.rep-filters-text {
  margin-right: 18px;
  color: var(--v-grey-darken1);
}

.reset-button-inactive {
  color: var(--v-grey-darken2);
  border-radius: 4px;
  border: 1px solid #9E9E9E;
  text-transform: none;
  font-size: 0.75rem !important;
  margin: 0px 10px 10px 0;
  height: 40px !important;
  letter-spacing: normal;
}

.reset-button-active {
  color: var(--v-primary-base) !important;
  border-radius: 4px;
  border: 1px solid var(--v-primary-base);
  text-transform: none;
  font-size: 0.75rem !important;
  margin: 0px 10px 10px 0;
  height: 40px !important;
  letter-spacing: normal;
}

.hide-inactive-label {
  margin-right: 8px;
  margin-bottom: 10px;
  letter-spacing: normal;
}

.hide-inactive-switch-container {
  width: 200px;
}

.hide-inactive-switch {
  margin-right: 8px;
  margin-bottom: 6px;
  margin-top: -4px;
}

.checked_in_trend_hidden {
  padding-left: 200px;
}

.checked_in_trend_visible {
  padding-left: 200px;
}

.other-filters-text {
  margin-right: 12px;
}

.hide-inactive-label {
  margin-right: 8px;
  margin-bottom: 10px;
}

.reps-container {
  padding-right: 6px;
}

.hide-inactive-switch {
  margin-right: 8px;
  margin-bottom: 6px;
}

.table-gap {
  min-height: 16px;
}

.other-filters {
  padding-left: 22px !important;
}

.disabled-export {
  color: var(--v-grey-lighten1) !important;
}

.placeholder-option {
  color: var(--v-grey-darken2) !important;
}

.selected-option {
  color: var(--v-primary-base) !important;
}


.reset-button {
  color: var(--v-grey-darken2);
  border-radius: 4px;
  border: 1px solid #9E9E9E;
  text-transform: none;

}

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0,
  'wght' 400,
  'GRAD' 0,
  'opsz' 24
}

.checked_in_container {
  display: inline;
  background-color: var(--v-grey-lighten2);
  align-items: center;
  text-align: center;
  overflow: hidden;
  padding: 6px 8px 8px 8px;
  border-radius: 4px;
  margin-top: 8px;
}

.table-collapse-button {
  margin: 16px;
  padding-right: 16px;
}

.positive-percentage {
  color: green;
}

.negative-percentage {
  padding-left: 4px;
  color: red;
}

.negative-trendline {
  color: red;
}

.positive-percentage {
  padding-left: 4px;
  color: green;
}

.positive-trendline {
  color: green;
}

.neutral-percentage {
  padding-left: 4px;
  color: grey;
}

.neutral-trendline {
  color: grey;
}

.dropdown-header {
  border: 1px solid var(--v-grey-lighten1);
  text-transform: unset !important;
  background-color: transparent !important;
  box-shadow: none;
  height: 40px !important;
  width: 210px;
  justify-content: left;
  margin: 12px 0px 12px 0px;
  letter-spacing: normal;

}

.dashboard-menu-option {
  display: flex;
  min-height: 48px;
  align-items: center !important;
  padding-right: 16px;
  padding-left: 16px;
  cursor: pointer;
}

.export-icon {
  color: #1F3C73;
}

.export-button {
  margin-top: 25px;
  color: #1F3C73;
}

.checkbox-container {
  margin-top: 0px !important;
  margin-right: 12px !important;
}

.fdc-checkbox-container {
  text-align: center;
  margin-bottom: 8px;
}

.filter-row {
  margin-left: 16px;
}

.closer-dashboard-header {
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
  padding: 0px !important;
  overflow-x: hidden;
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
  font-family: "Lato", sans-serif;
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
    font-family: "Lato", sans-serif;
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
  padding-left: 0px !important;
  margin: 0px !important;

  .pipeline-header-container {
    display: flex;
    flex-flow: row nowrap;
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
    margin: 12px 0 12px 0 !important;
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
  margin: 0px !important;

  .pipeline-header-container {
    display: flex;
    flex-flow: row wrap;
    justify-content: space-between;
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
      padding-left: 6px;
    }

    #pipeline-header-left-side {
      margin-bottom: 5px;
      width: 100%;

      .appts-to-fdc-pipeline-dropdown {
        transform: scale(0.875);
        transform-origin: left;
        margin: 2px;
        max-width: 135px;
        text-align: center;

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
        text-transform: none !important;
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
      font-family: "Lato", sans-serif;
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

      #pipeline-header-left-side {
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
          text-transform: none !important;
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
          text-transform: none !important;
          margin: 0 10px 10px 0;
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
<style lang="scss">
#closer-funnel-table > div > table > thead > tr > th {
  z-index: 1 !important;
}

#closer-funnel-table > div > table > thead > tr > th.text-start.milestone-col-th,
#closer-funnel-table > div > table > tbody > tr > td.text-start {
  position: sticky !important;
  left: 0;
  z-index: 2 !important;
  background-color: white;
  min-width: 220px;
}

#closer-funnel-table > div > table > tbody > tr.shaded-row > td.text-start {
  background-color: var(--v-primary-lighten9) !important;
}

#closer-funnel-table > div > table > thead > tr:hover,
#closer-funnel-table > div > table > tbody > tr:hover {
  background-color: transparent;
}

#closer-funnel-table > div > table > thead > tr > th.text-left.data-col-th {
  min-width: 220px !important;
}

#fdc-dash-table > div > table > thead > tr > th.text-start.milestone-col-th,
#fdc-dash-table > div > table > tbody > tr > td.text-start {
  position: sticky !important;
  left: 0;
  z-index: 2 !important;
  background-color: white;
  min-width: 220px;
}

#fdc-dash-table > div > table > tbody > tr.shaded-row > td.text-start {
  background-color: var(--v-primary-lighten9) !important;
}

#fdc-dash-table > div > table > thead > tr:hover,
#fdc-dash-table > div > table > tbody > tr:hover {
  background-color: transparent;
}

#fdc-dash-table > div > table > thead > tr > th.text-left.data-col-th {
  min-width: 220px !important;
}

#upcoming-data-table > div > table > thead > tr > th.text-start.milestone-col-th,
#upcoming-data-table > div > table > tbody > tr > td.text-start {
  position: sticky !important;
  left: 0;
  z-index: 2 !important;
  min-width: 220px;
}

#upcoming-data-table > div > table > tbody > tr:nth-of-type(even) {
  background-color: var(--v-primary-lighten9) !important;
}


#upcoming-data-table > div > table > thead > tr:hover,
#upcoming-data-table > div > table > tbody > tr:hover {
  background-color: transparent;
}

#upcoming-data-table > div > table > thead > tr > th.text-left.data-col-th {
  min-width: 220px !important;
}
</style>
}

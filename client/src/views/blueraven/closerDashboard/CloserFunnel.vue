<template>
  <v-container id="closer-dash-container" ref="closerDashContainer">
    <!---------------------------------- FUNNEL TAB START ---------------------------------->
    <!-- APPOINTMENTS CREATED PIPELINE START -->

    <div id="appts-created-pipeline-container" v-if="userCanViewAllProjects">
      <v-row align="center">
        <div class="title-large closer-dashboard-header">
          Appointments Created Pipeline
        </div>
        <a class="export-button" @click="exportCsv('created')">
          <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
          Export
        </a>
        <v-spacer></v-spacer>
        <div class="flex-display flex-align-items-end table-collapse-button">
          <v-icon
            v-if="apptsCreatedExpanded"
            @click="apptsCreatedExpanded = !apptsCreatedExpanded"
          >
            expand_less
          </v-icon>
          <v-icon v-else @click="apptsCreatedExpanded = !apptsCreatedExpanded">
            expand_more
          </v-icon>
        </div>
      </v-row>
      <v-row v-if="apptsCreatedExpanded" class="filter-row" align="center">
        <span class="other-filters-text">Filters:</span>
        <div class="checkbox-container">
          <v-checkbox
            label="View Trends"
            :disabled="disableTrends"
            v-model="viewTrends"
          ></v-checkbox>
        </div>
      </v-row>

      <!-- FUNNEL -->
      <div class="funnel-container">
        <div
          v-if="apptsCreatedPipelineData.length > 0"
          id="appts-created-pipeline-funnel-background"
          :style="{
            'margin-top':
              showApptsCreatedPipelineCustomDates && windowInnerWidth < 1135
                ? '77px'
                : showApptsCreatedPipelineCustomDates &&
                    windowInnerWidth >= 1135
                  ? '83px'
                  : '59px'
          }"
        ></div>
        <v-data-table
          v-if="apptsCreatedExpanded"
          id="closer-funnel-table"
          class="elevation-1"
          :items="filteredApptsCreatedPipelineData"
          :headers="headers"
          ref="pageable-table"
          disable-sort
          :item-class="itemRowBackground"
          :footer-props="footerProps"
          :loading="apptsCreatedPipelineDataLoading"
          :hide-default-footer="true"
          :mobile-breakpoint="0"
        >
          <template #no-data>
            <span class="default-text-color">No available data</span>
          </template>

          <template #header.milestone="{}" id="milestones-header">
            Milestones
          </template>
          <template #header.source="{}">Source</template>
          <template #header.actualTotal="{}">
            <v-menu
              data-app
              left
              offset-y
              :max-height="`calc(100vh - 20px)`"
              class="dropdown-header body-small"
              v-model="openFirstMenu"
              :close-on-content-click="true"
            >
              <template v-slot:activator="{ on }">
                <a-btn
                  class="dropdown-header body-small"
                  :activation-handler="on"
                >
                  <span
                    v-if="
                      getDropdownById(firstDateRange)?.name === 'CUSTOM' &&
                      firstCustom.name != null
                    "
                    class="selected-option body-small"
                  >
                    {{ firstCustom.name }}</span
                  >
                  <span
                    v-else-if="
                      getDropdownById(firstDateRange)?.name === 'PERIOD'
                    "
                    class="selected-option body-small"
                  >
                    {{
                      getDropdownById(firstDateRange).periodList[firstPeriod]
                        .shortLabel
                    }}
                  </span>
                  <span v-else class="selected-option body-small">
                    {{ getDropdownById(firstDateRange)?.friendlyName }}
                  </span>
                  <v-spacer></v-spacer>
                  <v-spacer></v-spacer>
                  <v-icon color="primary">mdi-menu-down</v-icon>
                </a-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y: auto">
                  <v-list-item
                    v-for="(item, index) in dropdownValues"
                    style="padding: 0px"
                    link
                  >
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover offset-x>
                        <template v-slot:activator="{ on }">
                          <span
                            v-on="on"
                            class="d-flex justify-space-between dashboard-menu-option"
                          >
                            {{ item.friendlyName }}
                            <v-icon style="display: flex"
                              >mdi-chevron-right</v-icon
                            >
                          </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y: auto">
                            <v-list-item
                              v-for="(period, index) in item.periodList"
                              @click="
                                firstDateRange = item.id
                                firstPeriod = index
                                changeDropdownSelection(1)
                                firstCustom.isActive = item.name === 'CUSTOM'
                                openFirstMenu = false
                              "
                            >
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>
                    </v-list-item-title>
                    <v-list-item-title
                      v-else
                      @click="
                        firstDateRange = item.id
                        changeDropdownSelection(1)
                        firstCustom.isActive = item.name === 'CUSTOM'
                      "
                      class="dashboard-menu-option"
                      >{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>
          <template #header.actualTotal2="{}">
            <v-menu
              data-app
              left
              offset-y
              :max-height="`calc(100vh - 20px)`"
              class="dropdown-header body-small"
              v-model="openSecondMenu"
              :close-on-content-click="true"
            >
              <template v-slot:activator="{ on }">
                <a-btn
                  class="dropdown-header body-small"
                  :activation-handler="on"
                >
                  <span
                    v-if="
                      getDropdownById(secondDateRange)?.name === 'CUSTOM' &&
                      secondCustom.name != null
                    "
                    class="selected-option body-small"
                  >
                    {{ secondCustom.name }}
                  </span>
                  <span
                    v-else-if="
                      getDropdownById(secondDateRange)?.name === 'PERIOD'
                    "
                    class="selected-option body-small"
                  >
                    {{
                      getDropdownById(secondDateRange).periodList[secondPeriod]
                        .shortLabel
                    }}
                  </span>
                  <span
                    v-else-if="secondDateRange != null"
                    class="selected-option body-small"
                  >
                    {{ getDropdownById(secondDateRange)?.friendlyName }}
                  </span>
                  <span v-else class="placeholder-option body-small">
                    Select Date Range
                  </span>
                  <v-spacer></v-spacer>
                  <v-icon color="primary">mdi-menu-down</v-icon>
                </a-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y: auto">
                  <v-list-item
                    v-for="(item, index) in dropdownValues"
                    style="padding: 0px"
                    link
                  >
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover location="end" :offset-x="true">
                        <template v-slot:activator="{ on }">
                          <span
                            v-on="on"
                            class="d-flex justify-space-between dashboard-menu-option"
                          >
                            {{ item.friendlyName }}
                            <v-icon>mdi-chevron-right</v-icon>
                          </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y: auto">
                            <v-list-item
                              v-for="(period, index) in item.periodList"
                              @click="
                                secondDateRange = item.id
                                secondPeriod = index
                                changeDropdownSelection(2)
                                secondCustom.isActive = item.name === 'CUSTOM'
                                openSecondMenu = false
                              "
                            >
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>
                    </v-list-item-title>
                    <v-list-item-title
                      v-else
                      @click="
                        secondDateRange = item.id
                        changeDropdownSelection(2)
                        secondCustom.isActive = item.name === 'CUSTOM'
                      "
                      class="dashboard-menu-option"
                      >{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>
          <template #header.actualTotal3="{}">
            <v-menu
              data-app
              left
              offset-y
              :max-height="`calc(100vh - 20px)`"
              class="dropdown-header body-small"
              v-model="openThirdMenu"
              :close-on-content-click="true"
            >
              <template v-slot:activator="{ on }">
                <a-btn
                  class="dropdown-header body-small"
                  :activation-handler="on"
                >
                  <span
                    v-if="
                      getDropdownById(thirdDateRange)?.name === 'CUSTOM' &&
                      thirdCustom.name != null
                    "
                    class="selected-option body-small"
                  >
                    {{ thirdCustom.name }}
                  </span>
                  <span
                    v-else-if="
                      getDropdownById(thirdDateRange)?.name === 'PERIOD'
                    "
                    class="selected-option body-small"
                  >
                    {{
                      getDropdownById(thirdDateRange).periodList[thirdPeriod]
                        .shortLabel
                    }}
                  </span>
                  <span
                    v-else-if="thirdDateRange != null"
                    class="selected-option body-small"
                  >
                    {{ getDropdownById(thirdDateRange)?.friendlyName }}
                  </span>
                  <span v-else class="placeholder-option body-small">
                    Select Date Range
                  </span>
                  <v-spacer></v-spacer>
                  <v-icon color="primary">mdi-menu-down</v-icon>
                </a-btn>
              </template>
              <div>
                <v-list style="height: 400px; overflow-y: auto">
                  <v-list-item
                    v-for="(item, index) in dropdownValues"
                    style="padding: 0px"
                    link
                  >
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover location="end">
                        <template v-slot:activator="{ on }">
                          <span
                            v-on="on"
                            class="d-flex justify-space-between dashboard-menu-option"
                          >
                            {{ item.friendlyName }}
                            <v-icon>mdi-chevron-right</v-icon>
                          </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y: auto">
                            <v-list-item
                              v-for="(period, index) in item.periodList"
                              @click="
                                thirdDateRange = item.id
                                thirdPeriod = index
                                changeDropdownSelection(3)
                                thirdCustom.isActive = item.name === 'CUSTOM'
                                openThirdMenu = false
                              "
                            >
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>
                    </v-list-item-title>
                    <v-list-item-title
                      v-else
                      @click="
                        thirdDateRange = item.id
                        changeDropdownSelection(3)
                        thirdCustom.isActive = item.name === 'CUSTOM'
                      "
                      class="dashboard-menu-option"
                      >{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>

          <template
            #item.milestone="{ item, index }"
            id="milestones-col"
            class="milestone-name-col-td"
            ><span
              :class="{ 'label-medium': index < 2 }"
              class="milestone-name-col-td"
            >
              <span v-if="index === 1">
                <v-icon v-if="milestonesExpanded" @click="hideMilestones()"
                  >expand_less</v-icon
                >
                <v-icon v-else @click="expandMilestones()">expand_more</v-icon>
              </span>
              {{ item.name }}
            </span></template
          >
          <template #item.source="{ item, index }">
            <a-select
              v-if="index === 0 && !isCloser"
              class="appts-created-pipeline-dropdown"
              v-model="leadsCreatedSourceModel"
              :items="leadsCreatedSourceData"
              item-title="sourceName"
              item-value="sourceId"
              placeholder="Select"
              multiple
              background-color="white"
              variant="outlined"
              density="compact"
              return-object
              @blur="changeSources()"
            >
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="selected-option">
                  {{ leadsCreatedSourceModel.length }} Checked
                </span>
              </template>
              <template
                v-if="leadsCreatedSourceData.length > 0"
                v-slot:prepend-item
              >
                <v-list-item @click="toggleSelectAllLeadsCreatedSources">
                  <v-list-item-action>
                    <v-icon>{{ leadsCreatedSourcesSelectIcon }}</v-icon>
                  </v-list-item-action>
                  <v-list-item-content>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-divider class="mt-2"></v-divider>
              </template>
            </a-select>

            <a-select
              v-if="index === 2 && !isCloser"
              class="appts-created-pipeline-dropdown"
              v-model="brsProvidedSourceModel"
              :items="brsProvidedSourceData"
              item-title="sourceName"
              item-value="sourceId"
              placeholder="Select"
              multiple
              background-color="white"
              variant="outlined"
              density="compact"
              return-object
              @blur="changeSources()"
            >
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="selected-option">
                  {{ brsProvidedSourceModel.length }} Checked
                </span>
              </template>
              <template
                v-if="brsProvidedSourceData.length > 0"
                v-slot:prepend-item
              >
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
            </a-select>
            <a-select
              v-if="index === 3"
              class="appts-created-pipeline-dropdown"
              v-model="selfGenSourceModel"
              :items="selfGenSourceData"
              item-title="sourceName"
              item-value="sourceId"
              placeholder="Select"
              multiple
              background-color="white"
              variant="outlined"
              density="compact"
              return-object
              @blur="changeSources()"
            >
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="selected-option">
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
            </a-select>
          </template>
          <template
            #item.actualTotal="{ item, index }"
            class="milestone-col-td"
          >
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
                <span
                  @click="
                    funnelDrilldown(
                      item,
                      getDropdownById(firstDateRange),
                      'apptsCreatedPipeline',
                      true,
                      firstCustom
                    )
                  "
                  class="appts-data"
                >
                  {{ item.leads_created_count ? item.leads_created_count : 0 }}
                  <span v-on="viewTrends ? on : null">
                    <span
                      v-if="viewTrends && item.trend > 0"
                      class="positive-percentage"
                      >+{{ (item.trend / 100) | percent }}
                      <v-icon class="positive-trendline"> trending_up </v-icon>
                    </span>
                    <span
                      v-if="viewTrends && item.trend < 0"
                      class="negative-percentage"
                    >
                      {{ (item.trend / 100) | percent }}
                      <v-icon class="negative-trendline">
                        trending_down
                      </v-icon>
                    </span>
                    <span
                      v-if="
                        viewTrends && (item.trend === null || item.trend === 0)
                      "
                      class="neutral-percentage"
                    >
                      {{ (item.trend / 100) | percent }}
                      <v-icon class="neutral-trendline"> trending_flat </v-icon>
                    </span>
                  </span>
                </span>
              </template>
              <span v-if="viewTrends && item.trend > 0">
                {{ (Math.abs(item.trend) / 100) | percent }} more than
                {{ getDropdownById(firstDateRange).trendText }}
              </span>
              <span v-if="viewTrends && item.trend < 0">
                {{ (Math.abs(item.trend) / 100) | percent }} less than
                {{ getDropdownById(firstDateRange).trendText }}
              </span>
              <span
                v-if="viewTrends && (item.trend === null || item.trend === 0)"
              >
                Same as {{ getDropdownById(firstDateRange).trendText }}
              </span>
            </v-tooltip>
          </template>

          <template
            #item.actualTotal2="{ item, index }"
            class="milestone-col-td"
            v-if="
              secondDateRange != null &&
              column2Values != null &&
              column2Values.length > 0
            "
          >
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
                <span
                  @click="
                    funnelDrilldown(
                      item,
                      getDropdownById(secondDateRange),
                      'apptsCreatedPipeline',
                      true,
                      secondCustom
                    )
                  "
                  class="appts-data"
                >
                  {{
                    column2Values[index].leads_created_count
                      ? column2Values[index].leads_created_count
                      : 0
                  }}
                  <span v-on="viewTrends ? on : null">
                    <span
                      v-if="viewTrends && column2Values[index].trend > 0"
                      class="positive-percentage"
                    >
                      +{{ (column2Values[index].trend / 100) | percent }}
                      <v-icon class="positive-trendline"> trending_up </v-icon>
                    </span>
                    <span
                      v-if="viewTrends && column2Values[index].trend < 0"
                      class="negative-percentage"
                    >
                      {{ (column2Values[index].trend / 100) | percent }}
                      <v-icon class="negative-trendline">
                        trending_down
                      </v-icon>
                    </span>
                    <span
                      v-if="
                        viewTrends &&
                        (column2Values[index].trend === null ||
                          column2Values[index].trend == 0)
                      "
                      class="neutral-percentage"
                    >
                      {{ (column2Values[index].trend / 100) | percent }}
                      <v-icon class="neutral-trendline"> trending_flat </v-icon>
                    </span>
                  </span>
                </span>
              </template>
              <span v-if="viewTrends && column2Values[index].trend > 0">
                {{ (Math.abs(column2Values[index].trend) / 100) | percent }}
                more than {{ getDropdownById(secondDateRange).trendText }}</span
              >
              <span v-if="viewTrends && column2Values[index].trend < 0">
                {{ (Math.abs(column2Values[index].trend) / 100) | percent }}
                less than {{ getDropdownById(secondDateRange).trendText }}</span
              >
              <span
                v-if="
                  viewTrends &&
                  (column2Values[index].trend === null ||
                    column2Values[index].trend === 0)
                "
              >
                Same as {{ getDropdownById(secondDateRange).trendText }}</span
              >
            </v-tooltip>
          </template>
          <template
            #item.actualTotal3="{ item, index }"
            class="milestone-col-td"
            v-if="
              thirdDateRange != null &&
              column3Values != null &&
              column3Values.length > 0
            "
          >
            <v-tooltip bottom>
              <template v-slot:activator="{ on }">
                <span
                  @click="
                    funnelDrilldown(
                      item,
                      getDropdownById(thirdDateRange),
                      'apptsCreatedPipeline',
                      true,
                      thirdCustom
                    )
                  "
                  class="appts-data"
                >
                  {{
                    column3Values[index].leads_created_count
                      ? column3Values[index].leads_created_count
                      : 0
                  }}
                  <span v-on="viewTrends ? on : null">
                    <span
                      v-if="viewTrends && column3Values[index].trend > 0"
                      class="positive-percentage"
                    >
                      +{{ (column3Values[index].trend / 100) | percent }}
                      <v-icon class="positive-trendline"> trending_up </v-icon>
                    </span>
                    <span
                      v-if="viewTrends && column3Values[index].trend < 0"
                      class="negative-percentage"
                    >
                      {{ (column3Values[index].trend / 100) | percent }}
                      <v-icon class="negative-trendline">
                        trending_down
                      </v-icon>
                    </span>
                    <span
                      v-if="
                        viewTrends &&
                        (column3Values[index].trend === null ||
                          column3Values[index].trend === 0)
                      "
                      class="neutral-percentage"
                    >
                      {{ (column3Values[index].trend / 100) | percent }}
                      <v-icon class="neutral-trendline"> trending_flat </v-icon>
                    </span>
                  </span>
                </span>
              </template>
              <span v-if="viewTrends && column3Values[index].trend > 0">
                {{ (Math.abs(column3Values[index].trend) / 100) | percent }}
                more than {{ getDropdownById(thirdDateRange).trendText }}</span
              >
              <span v-if="viewTrends && column3Values[index].trend < 0">
                {{ (Math.abs(column3Values[index].trend) / 100) | percent }}
                less than {{ getDropdownById(thirdDateRange).trendText }}</span
              >
              <span
                v-if="
                  viewTrends &&
                  (column3Values[index].trend === null ||
                    column3Values[index].trend === 0)
                "
              >
                Same as {{ getDropdownById(thirdDateRange).trendText }}</span
              >
            </v-tooltip>
          </template>
        </v-data-table>
      </div>
    </div>
    <!-- APPOINTMENTS CREATED PIPELINE END -->
    <div class="table-gap"></div>

    <!-- APPOINTMENTS TO FDC PIPELINE START -->
    <div id="appts-to-fdc-pipeline-container" class="mb-8">
      <v-row align="center">
        <div class="title-large closer-dashboard-header">
          Appointments to FDC Pipeline
        </div>
        <a
          v-if="filteredFdcPipelineData?.length > 0"
          class="export-button"
          @click="exportCsv('fdc')"
        >
          <v-icon class="export-icon">mdi-tray-arrow-down</v-icon>
          Export
        </a>
        <div v-else class="export-button" :class="{ 'disabled-export': true }">
          <v-icon class="export-icon disabled-export">
            mdi-tray-arrow-down
          </v-icon>
          Export
        </div>
        <v-spacer></v-spacer>
        <div class="flex-display flex-align-items-end table-collapse-button">
          <v-icon
            v-if="fdcPipelineExpanded"
            @click="fdcPipelineExpanded = !fdcPipelineExpanded"
            >expand_less</v-icon
          >
          <v-icon v-else @click="fdcPipelineExpanded = !fdcPipelineExpanded">
            expand_more
          </v-icon>
        </div>
      </v-row>
      <v-row>
        <div class="pipeline-header-container" v-if="fdcPipelineExpanded">
          <v-col cols="9" class="d-flex">
            <div id="pipeline-header-left-side">
              <div class="reps-container">
                <span class="rep-filters-text label-small">Rep Filters</span>
              </div>
              <a-autocomplete
                class="appts-to-fdc-pipeline-dropdown"
                ref="areaSelect"
                v-model="areaModel"
                :items="areaData"
                item-title="org_name"
                item-value="org_id"
                label="Area"
                no-data-text="No areas available"
                variant="outlined"
                density="compact"
                multiple
                hide-details
                @input="repValuesChanged = true"
                @blur="
                  areaValuesChanged = true
                  regionLoad()
                "
                return-object
              >
                <template v-slot:label="{ item, index }">
                  <span class="text-caption-lg">Area</span>
                </template>
                <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
                    {{ areaModel.length }} Checked
                  </span>
                </template>
                <template v-if="areaData.length > 0" v-slot:prepend-item>
                  <v-list-item
                    @click="
                      [(areaValuesChanged = true), toggleSelectAllAreas()]
                    "
                  >
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
                    <v-list-item-title
                      :style="{
                        'text-decoration': data.item.active
                          ? ''
                          : 'line-through'
                      }"
                    >
                      {{ data.item.org_name }}
                    </v-list-item-title>
                  </v-list-item-content>
                </template>
              </a-autocomplete>

              <a-autocomplete
                class="appts-to-fdc-pipeline-dropdown"
                v-model="regionModel"
                :items="regionData"
                item-title="org_name"
                item-value="org_id"
                label="Region"
                no-data-text="No regions available"
                variant="outlined"
                density="compact"
                multiple
                @input="repValuesChanged = true"
                @blur="
                  regionValuesChanged = true
                  districtLoad()
                "
                hide-details
                return-object
                ref="regionSelect"
              >
                <template v-slot:label="{ item, index }">
                  <span class="text-caption-md">Region</span>
                </template>
                <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
                    {{ regionModel.length }} Checked
                  </span>
                </template>
                <template v-if="regionData.length > 0" v-slot:prepend-item>
                  <v-list-item
                    @click="
                      [(regionValuesChanged = true), toggleSelectAllRegions()]
                    "
                  >
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
                    <v-list-item-title
                      :style="{
                        'text-decoration': data.item.active
                          ? ''
                          : 'line-through'
                      }"
                    >
                      {{ data.item.org_name }}
                    </v-list-item-title>
                  </v-list-item-content>
                </template>
              </a-autocomplete>

              <a-autocomplete
                class="appts-to-fdc-pipeline-dropdown"
                ref="districtSelect"
                v-model="districtModel"
                :items="districtData"
                item-title="org_name"
                item-value="org_id"
                label="District"
                no-data-text="No districts available"
                multiple
                variant="outlined"
                density="compact"
                hide-details
                @input="
                  repValuesChanged = true
                  districtValuesChanged = true
                "
                @blur="officeLoad()"
                return-object
              >
                <template v-slot:label="{ item, index }">
                  <span class="text-caption-md">District</span>
                </template>
                <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
                    {{ districtModel.length }} Checked
                  </span>
                </template>
                <template v-if="districtData.length > 0" v-slot:prepend-item>
                  <v-list-item
                    @click="
                      [
                        (districtValuesChanged = true),
                        toggleSelectAllDistricts()
                      ]
                    "
                  >
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
                    <v-list-item-title
                      :style="{
                        'text-decoration': data.item.active
                          ? ''
                          : 'line-through'
                      }"
                    >
                      {{ data.item.org_name }}
                    </v-list-item-title>
                  </v-list-item-content>
                </template>
              </a-autocomplete>

              <a-autocomplete
                class="appts-to-fdc-pipeline-dropdown"
                v-model="officeModel"
                :items="officeData"
                item-title="org_name"
                item-value="org_id"
                label="Office"
                no-data-text="No offices available"
                multiple
                variant="outlined"
                density="compact"
                @input="repValuesChanged = true"
                @blur="
                  officeValuesChanged = true
                  repLoad()
                "
                hide-details
                return-object
                ref="officeSelect"
              >
                <template v-slot:label="{ item, index }">
                  <span class="text-caption-md">Office</span>
                </template>
                <template v-slot:selection="{ item, index }">
                  <span v-if="index === 0" class="selected-option text-caption">
                    {{ officeModel.length }} Checked
                  </span>
                </template>
                <template v-if="officeData.length > 0" v-slot:prepend-item>
                  <v-list-item
                    @click="
                      [(officeValuesChanged = true), toggleSelectAllOffices()]
                    "
                  >
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
                    <v-list-item-title
                      :style="{
                        'text-decoration': data.item.active
                          ? ''
                          : 'line-through'
                      }"
                    >
                      {{ data.item.org_name }}
                    </v-list-item-title>
                  </v-list-item-content>
                </template>
              </a-autocomplete>
              <a-autocomplete
                class="appts-to-fdc-pipeline-dropdown"
                v-model="repModel"
                :items="filteredRepData"
                item-title="name"
                item-value="user_position_id"
                label="Rep"
                no-data-text="No reps available"
                multiple
                variant="outlined"
                density="compact"
                @input="
                  repValuesChanged = true
                  apptsToFdcPipelineData.value = []
                "
                hide-details
                return-object
                ref="repSelect"
              >
                <template v-slot:selection="{ item, index }">
                  <span
                    v-if="index === 0 && repModel[0].user_id != -1"
                    class="selected-option text-caption"
                  >
                    {{ repModel.length }} Checked
                  </span>
                  <span
                    v-if="index === 0 && repModel[0].user_id === -1"
                    class="selected-option text-caption-sm"
                  >
                    {{ filteredRepDataMaster.length }} Checked
                  </span>
                </template>
                <template v-slot:label="{ item, index }">
                  <span class="text-caption-lg">Rep</span>
                </template>
                <template v-slot:item="data">
                  <v-list-item-action class="mr-2">
                    <v-icon v-if="data.attrs.inputValue">check_box</v-icon>
                    <v-icon v-else>check_box_outline_blank</v-icon>
                  </v-list-item-action>
                  <v-list-item-content>
                    <v-list-item-title
                      :style="{
                        'text-decoration': data.item.active
                          ? ''
                          : 'line-through'
                      }"
                    >
                      {{ data.item.name }}
                    </v-list-item-title>
                  </v-list-item-content>
                </template>
              </a-autocomplete>
              <div
                class="d-flex hide-inactive-switch-container align-items-center"
              >
                <v-label class="hide-inactive-label">
                  Hide Inactive Reps
                </v-label>
                <v-switch
                  hide-details
                  v-model="hideInactiveReps"
                  @click="switchInactiveReps()"
                  class="hide-inactive-switch"
                ></v-switch>
              </div>
              <a-btn
                v-if="!isCloser && !isCloserMgr"
                class="body-small"
                :class="{
                  'reset-button-inactive':
                    !filtersSelected &&
                    repModel?.length === 0 &&
                    !hideInactiveReps,
                  'reset-button-active':
                    filtersSelected || repModel?.length > 0 || hideInactiveReps
                }"
                variant="outlined"
                @click="
                  resetFilters()
                  repValuesChanged = true
                  loadFunnels()
                "
                color="unset"
                text="Reset Rep Filters"
              ></a-btn>
            </div>
          </v-col>
          <v-col cols="3" class="d-flex justify-end">
            <a-btn
              id="all-reps-btn"
              variant="outlined"
              color="primary"
              class="body-small"
              @click="funnelAllReps"
              :text="viewAllRepsText"
            ></a-btn>
          </v-col>
        </div>
      </v-row>
      <v-row
        v-if="fdcPipelineExpanded"
        class="pipeline-header-container other-filters"
      >
        <div id="pipeline-header-left-side">
          <span class="other-filters-text label-small"> Other Filters </span>
          <a-select
            v-if="!isCloser"
            class="appts-to-fdc-pipeline-dropdown"
            v-model="fdcSourceModel"
            :items="fdcSourceData"
            item-title="sourceName"
            item-value="sourceId"
            placeholder="Select"
            multiple
            hide-details
            background-color="white"
            variant="outlined"
            density="compact"
            return-object
            label="Lead Source"
            @input="repValuesChanged = true"
          >
            <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="selected-option text-caption">
                {{ fdcSourceModel.length }} Checked
              </span>
            </template>
            <template v-if="fdcSourceData.length > 0" v-slot:prepend-item>
              <v-list-item @click="toggleSelectAllFdcLeadsCreatedSources">
                <v-list-item-action>
                  <v-icon>{{ fdcSourcesSelectIcon }}</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                  <v-list-item-title>Select All</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-divider class="mt-2"></v-divider>
            </template>
          </a-select>
          <a-autocomplete
            class="appts-to-fdc-pipeline-dropdown"
            v-model="appointmentTypesModel"
            :items="appointmentTypes"
            :menu-props="{ bottom: true, offsetY: true }"
            item-title="name"
            item-value="user_position_id"
            label="Appointment Type"
            no-data-text="No reps available"
            multiple
            variant="outlined"
            density="compact"
            @input="repValuesChanged = true"
            hide-details
            return-object
            ref="repSelect"
          >
            <template v-slot:selection="{ item, index }">
              <span v-if="index === 0" class="selected-option text-caption">
                {{ appointmentTypesModel.length }} Checked
              </span>
            </template>
            <template v-if="appointmentTypes.length > 0" v-slot:prepend-item>
              <v-list-item
                @click="
                  [
                    (repValuesChanged = true),
                    (appointmentTypesSelectAll = !appointmentTypesSelectAll),
                    toggleSelectAppointmentTypes()
                  ]
                "
              >
                <v-list-item-action class="mr-2">
                  <v-icon>{{ appointmentTypesIcon }}</v-icon>
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
          </a-autocomplete>
          <div class="checkbox-container fdc-checkbox-container">
            <v-checkbox
              label="View Trends"
              :disabled="disableTrends"
              v-model="viewFdcTrends"
            ></v-checkbox>
          </div>
          <div class="checkbox-container fdc-checkbox-container">
            <v-checkbox
              label="Only View Major Milestones"
              v-model="viewOnlyMajorMilestones"
            ></v-checkbox>
          </div>
        </div>
      </v-row>

      <!-- FUNNEL -->
      <div class="funnel-container">
        <div
          v-if="apptsCreatedPipelineData.length > 0"
          id="appts-created-pipeline-funnel-background"
          :style="{
            'margin-top':
              showApptsCreatedPipelineCustomDates && windowInnerWidth < 1135
                ? '77px'
                : showApptsCreatedPipelineCustomDates &&
                    windowInnerWidth >= 1135
                  ? '83px'
                  : '59px'
          }"
        ></div>
        <v-data-table
          v-if="fdcPipelineExpanded"
          id="fdc-dash-table"
          class="elevation-1"
          :items="filteredFdcPipelineData"
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
            <span class="default-text-color">
              Select Reps to View the Pipeline
            </span>
          </template>

          <template #header.milestone="{}" id="milestones-header">
            <span class="milestones-header">Milestones</span>
          </template>
          <template #header.actualTotal="{}">
            <v-menu
              data-app
              left
              offset-y
              :max-height="`calc(100vh - 20px)`"
              class="dropdown-header body-small"
              v-model="fdcOpenFirstMenu"
              :close-on-content-click="true"
            >
              <template v-slot:activator="{ on }">
                <a-btn
                  class="dropdown-header body-small"
                  :activation-handler="on"
                >
                  <span
                    v-if="
                      getDropdownById(fdcFirstDateRange)?.name === 'CUSTOM' &&
                      fdcFirstCustom.name != null
                    "
                    class="selected-option body-small"
                  >
                    {{ fdcFirstCustom.name }}
                  </span>
                  <span
                    v-else-if="
                      getDropdownById(fdcFirstDateRange)?.name === 'PERIOD'
                    "
                    class="selected-option body-small"
                  >
                    {{
                      getDropdownById(fdcFirstDateRange).periodList[firstPeriod]
                        .shortLabel
                    }}
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
                <v-list style="height: 400px; overflow-y: auto">
                  <v-list-item
                    v-for="(item, index) in dropdownValues"
                    style="padding: 0px"
                  >
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover offset-x>
                        <template v-slot:activator="{ on }">
                          <span
                            v-on="on"
                            class="d-flex justify-space-between dashboard-menu-option"
                          >
                            {{ item.friendlyName }}
                            <v-icon style="display: flex"
                              >mdi-chevron-right
                            </v-icon>
                          </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y: auto">
                            <v-list-item
                              v-for="(period, index) in item.periodList"
                              @click="
                                fdcFirstDateRange = item.id
                                firstPeriod = index
                                changeFdcDropdownSelection(1)
                                fdcFirstCustom.isActive = item.name === 'CUSTOM'
                                fdcOpenFirstMenu = false
                              "
                            >
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>
                    </v-list-item-title>
                    <v-list-item-title
                      v-else
                      @click="
                        fdcFirstDateRange = item.id
                        changeFdcDropdownSelection(1)
                        fdcFirstCustom.isActive = item.name === 'CUSTOM'
                      "
                      class="dashboard-menu-option"
                    >
                      {{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>
          <template #header.actualTotal2="{}">
            <v-menu
              data-app
              left
              offset-y
              :max-height="`calc(100vh - 20px)`"
              class="dropdown-header body-small"
              v-model="fdcOpenSecondMenu"
              :close-on-content-click="true"
            >
              <template v-slot:activator="{ on }">
                <a-btn
                  class="dropdown-header body-small"
                  :activation-handler="on"
                >
                  <span
                    v-if="
                      getDropdownById(fdcSecondDateRange)?.name === 'CUSTOM' &&
                      fdcSecondCustom.name != null
                    "
                    class="selected-option body-small"
                  >
                    {{ fdcSecondCustom.name }}
                  </span>
                  <span
                    v-else-if="
                      getDropdownById(fdcSecondDateRange)?.name === 'PERIOD'
                    "
                    class="selected-option body-small"
                  >
                    {{
                      getDropdownById(fdcSecondDateRange).periodList[
                        secondPeriod
                      ].shortLabel
                    }}
                  </span>
                  <span
                    v-else-if="fdcSecondDateRange != null"
                    class="selected-option body-small"
                  >
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
                <v-list style="height: 400px; overflow-y: auto">
                  <v-list-item
                    v-for="(item, index) in dropdownValues"
                    style="padding: 0px"
                  >
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover location="end" :offset-x="true">
                        <template v-slot:activator="{ on }">
                          <span
                            v-on="on"
                            class="d-flex justify-space-between dashboard-menu-option"
                          >
                            {{ item.friendlyName }}
                            <v-icon>mdi-chevron-right</v-icon>
                          </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y: auto">
                            <v-list-item
                              v-for="(period, index) in item.periodList"
                              @click="
                                fdcSecondDateRange = item.id
                                secondPeriod = index
                                changeFdcDropdownSelection(2)
                                secondCustom.isActive = item.name === 'CUSTOM'
                                fdcOpenSecondMenu = false
                              "
                            >
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>
                    </v-list-item-title>
                    <v-list-item-title
                      v-else
                      @click="
                        fdcSecondDateRange = item.id
                        changeFdcDropdownSelection(2)
                        secondCustom.isActive = item.name === 'CUSTOM'
                      "
                      class="dashboard-menu-option"
                      >{{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>
          <template #header.actualTotal3="{}">
            <v-menu
              data-app
              left
              offset-y
              :max-height="`calc(100vh - 20px)`"
              class="dropdown-header body-small"
              v-model="fdcOpenThirdMenu"
              :close-on-content-click="true"
            >
              <template v-slot:activator="{ on }">
                <a-btn
                  class="dropdown-header body-small"
                  :activation-handler="on"
                >
                  <span
                    v-if="
                      getDropdownById(fdcThirdDateRange)?.name === 'CUSTOM' &&
                      fdcThirdCustom.name != null
                    "
                    class="selected-option body-small"
                  >
                    {{ fdcThirdCustom.name }}
                  </span>
                  <span
                    v-else-if="
                      getDropdownById(fdcThirdDateRange)?.name === 'PERIOD'
                    "
                    class="selected-option body-small"
                  >
                    {{
                      getDropdownById(fdcThirdDateRange).periodList[thirdPeriod]
                        .shortLabel
                    }}
                  </span>
                  <span
                    v-else-if="fdcThirdDateRange != null"
                    class="selected-option body-small"
                  >
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
                <v-list style="height: 400px; overflow-y: auto">
                  <v-list-item
                    v-for="(item, index) in dropdownValues"
                    style="padding: 0px"
                  >
                    <v-list-item-title v-if="item.name === 'PERIOD'">
                      <v-menu open-on-hover location="end">
                        <template v-slot:activator="{ on }">
                          <span
                            v-on="on"
                            class="d-flex justify-space-between dashboard-menu-option"
                          >
                            {{ item.friendlyName }}
                            <v-icon>mdi-chevron-right</v-icon>
                          </span>
                        </template>
                        <div>
                          <v-list style="height: 300px; overflow-y: auto">
                            <v-list-item
                              v-for="(period, index) in item.periodList"
                              @click="
                                fdcThirdDateRange = item.id
                                thirdPeriod = index
                                changeFdcDropdownSelection(3)
                                thirdCustom.isActive = item.name === 'CUSTOM'
                                fdcOpenThirdMenu = false
                              "
                            >
                              <v-list-item-title>
                                {{ period.label }}
                              </v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </div>
                      </v-menu>
                    </v-list-item-title>
                    <v-list-item-title
                      v-else
                      @click="
                        fdcThirdDateRange = item.id
                        changeFdcDropdownSelection(3)
                        thirdCustom.isActive = item.name === 'CUSTOM'
                      "
                      class="dashboard-menu-option"
                    >
                      {{ item.friendlyName }}
                    </v-list-item-title>
                  </v-list-item>
                </v-list>
              </div>
            </v-menu>
          </template>

          <template
            #item.milestone="{ item, index }"
            id="milestones-col"
            class="milestone-name-col-td"
          >
            <span
              :class="{
                'label-medium': fdcExpandableMilestones.includes(
                  item.display_order - 4
                ),
                'blue-sub-row': fdcExpandableMilestones.includes(index)
              }"
            >
              {{ item.name }}
            </span>
          </template>
          <template
            #item.source="{ item, index }"
            class="milestone-name-col-td"
          >
            <a-select
              v-if="index === 0"
              class="appts-created-pipeline-dropdown"
              v-model="leadsCreatedSourceModel"
              :items="leadsCreatedSourceData"
              item-text="sourceName"
              item-value="sourceId"
              placeholder="Select"
              multiple
              background-color="white"
              variant="outlined"
              density="compact"
              return-object
              @input="repValuesChanged = true"
            >
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="selected-option text-caption">
                  {{ leadsCreatedSourceModel.length }} Checked
                </span>
              </template>
              <template
                v-if="leadsCreatedSourceData.length > 0"
                v-slot:prepend-item
              >
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
            </a-select>

            <a-select
              v-if="index === 2"
              class="appts-created-pipeline-dropdown"
              v-model="brsProvidedSourceModel"
              :items="brsProvidedSourceData"
              item-text="sourceName"
              item-value="sourceId"
              placeholder="Select"
              multiple
              background-color="white"
              variant="outlined"
              density="compact"
              return-object
              @input="repValuesChanged = true"
            >
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="selected-option text-caption">
                  {{ brsProvidedSourceModel.length }} Checked
                </span>
              </template>
              <template
                v-if="brsProvidedSourceData.length > 0"
                v-slot:prepend-item
              >
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
            </a-select>
            <a-select
              v-if="index === 3"
              class="appts-created-pipeline-dropdown"
              v-model="selfGenSourceModel"
              :items="selfGenSourceData"
              item-text="sourceName"
              item-value="sourceId"
              placeholder="Select"
              multiple
              background-color="white"
              variant="outlined"
              density="compact"
              return-object
              @input="repValuesChanged = true"
            >
              <template v-slot:selection="{ item, index }">
                <span v-if="index === 0" class="selected-option text-caption">
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
            </a-select>
          </template>
          <template
            #item.actualTotal="{ item, index }"
            class="milestone-col-td"
          >
            <span class="d-flex align-items-center">
              <span
                @click="
                  funnelDrilldown(
                    item,
                    getDropdownById(fdcFirstDateRange),
                    'standard',
                    false,
                    fdcFirstCustom
                  )
                "
                class="fdc-data"
              >
                {{
                  item.custom_date_range_count
                    ? item.custom_date_range_count
                    : 0
                }}
              </span>
              <v-tooltip bottom v-if="viewFdcTrends">
                <template v-slot:activator="{ on }">
                  <span
                    v-on="viewFdcTrends ? on : null"
                    class="trends-container"
                  >
                    <span
                      v-if="viewFdcTrends && item.trend_count > 0"
                      :class="[
                        {
                          'positive-percentage': !item.inverse_trend,
                          'negative-percentage': item.inverse_trend
                        }
                      ]"
                    >
                      +{{ (item.trend_count / 100) | percent }}

                      <v-icon
                        :class="[
                          {
                            'positive-trendline': !item.inverse_trend,
                            'negative-trendline': item.inverse_trend
                          }
                        ]"
                      >
                        trending_up
                      </v-icon>
                    </span>
                    <span
                      v-if="viewFdcTrends && item.trend_count < 0"
                      :class="[
                        {
                          'positive-percentage': item.inverse_trend,
                          'negative-percentage': !item.inverse_trend
                        }
                      ]"
                    >
                      {{ (item.trend_count / 100) | percent }}
                      <v-icon
                        :class="[
                          {
                            'positive-trendline': item.inverse_trend,
                            'negative-trendline': !item.inverse_trend
                          }
                        ]"
                      >
                        trending_down
                      </v-icon>
                    </span>
                    <span
                      v-if="
                        viewFdcTrends &&
                        (item.trend_count === null || item.trend_count === 0)
                      "
                      class="neutral-percentage"
                    >
                      {{ (item.trend_count / 100) | percent }}
                      <v-icon class="neutral-trendline"> trending_flat </v-icon>
                    </span>
                  </span>
                </template>
                <span v-if="viewFdcTrends && item.trend_count > 0">
                  {{ (Math.abs(item.trend_count) / 100) | percent }} more than
                  {{ getDropdownById(fdcFirstDateRange).trendText }}</span
                >
                <span v-if="viewFdcTrends && item.trend_count < 0">
                  {{ (Math.abs(item.trend_count) / 100) | percent }} less than
                  {{ getDropdownById(fdcFirstDateRange).trendText }}</span
                >
                <span
                  v-if="
                    viewFdcTrends &&
                    (item.trend_count === null || item.trend_count === 0)
                  "
                >
                  Same as
                  {{ getDropdownById(fdcFirstDateRange).trendText }}</span
                >
              </v-tooltip>
              <span
                v-if="
                  item.checked_in_custom_date_range_count != null &&
                  item.show_checked_in_column
                "
                class="checked_in_container body-small"
                @click="
                  funnelDrilldown(
                    item,
                    getDropdownById(fdcFirstDateRange),
                    'standard',
                    true,
                    fdcFirstCustom
                  )
                "
              >
                <v-icon size="20" class="checked_in_icon">
                  mdi-check-circle-outline
                </v-icon>
                {{ item.checked_in_custom_date_range_count }}
              </span>
            </span>
          </template>

          <template
            #item.actualTotal2="{ item, index }"
            class="milestone-col-td"
            v-if="
              fdcSecondDateRange != null &&
              filteredFdcColumn2Values != null &&
              filteredFdcColumn2Values.length > 0
            "
          >
            <span class="d-flex align-items-center">
              <span
                @click="
                  funnelDrilldown(
                    filteredFdcColumn2Values[index],
                    getDropdownById(fdcSecondDateRange),
                    'standard',
                    false,
                    fdcSecondCustom
                  )
                "
                class="fdc-data"
              >
                {{
                  filteredFdcColumn2Values[index].custom_date_range_count
                    ? filteredFdcColumn2Values[index].custom_date_range_count
                    : 0
                }}
              </span>
              <v-tooltip bottom v-if="viewFdcTrends">
                <template v-slot:activator="{ on }">
                  <span
                    v-on="viewFdcTrends ? on : null"
                    class="trends-container"
                  >
                    <span
                      v-if="
                        viewFdcTrends &&
                        filteredFdcColumn2Values[index].trend_count > 0
                      "
                      :class="[
                        {
                          'positive-percentage':
                            !filteredFdcColumn2Values[index].inverse_trend,
                          'negative-percentage':
                            filteredFdcColumn2Values[index].inverse_trend
                        }
                      ]"
                    >
                      +{{
                        (filteredFdcColumn2Values[index].trend_count / 100)
                          | percent
                      }}
                      <v-icon
                        :class="[
                          {
                            'positive-trendline':
                              !filteredFdcColumn2Values[index].inverse_trend,
                            'negative-trendline':
                              filteredFdcColumn2Values[index].inverse_trend
                          }
                        ]"
                      >
                        trending_up
                      </v-icon>
                    </span>
                    <span
                      v-if="
                        viewFdcTrends &&
                        filteredFdcColumn2Values[index].trend_count < 0
                      "
                      :class="[
                        {
                          'positive-percentage':
                            filteredFdcColumn2Values[index].inverse_trend,
                          'negative-percentage':
                            !filteredFdcColumn2Values[index].inverse_trend
                        }
                      ]"
                    >
                      {{
                        (filteredFdcColumn2Values[index].trend_count / 100)
                          | percent
                      }}
                      <v-icon
                        :class="[
                          {
                            'positive-trendline':
                              filteredFdcColumn2Values[index].inverse_trend,
                            'negative-trendline':
                              !filteredFdcColumn2Values[index].inverse_trend
                          }
                        ]"
                      >
                        trending_down
                      </v-icon>
                    </span>
                    <span
                      v-if="
                        viewFdcTrends &&
                        (filteredFdcColumn2Values[index].trend_count === null ||
                          filteredFdcColumn2Values[index].trend_count === 0)
                      "
                      class="neutral-percentage"
                    >
                      {{
                        (filteredFdcColumn2Values[index].trend_count / 100)
                          | percent
                      }}
                      <v-icon class="neutral-trendline"> trending_flat </v-icon>
                    </span>
                  </span>
                </template>
                <span
                  v-if="
                    viewFdcTrends &&
                    filteredFdcColumn2Values[index].trend_count > 0
                  "
                >
                  {{
                    (Math.abs(filteredFdcColumn2Values[index].trend_count) /
                      100)
                      | percent
                  }}
                  more than
                  {{ getDropdownById(fdcSecondDateRange).trendText }}</span
                >
                <span
                  v-if="
                    viewFdcTrends &&
                    filteredFdcColumn2Values[index].trend_count < 0
                  "
                >
                  {{
                    (Math.abs(filteredFdcColumn2Values[index].trend_count) /
                      100)
                      | percent
                  }}
                  less than
                  {{ getDropdownById(fdcSecondDateRange).trendText }}</span
                >
                <span
                  v-if="
                    viewFdcTrends &&
                    (filteredFdcColumn2Values[index].trend_count === null ||
                      filteredFdcColumn2Values[index].trend_count === 0)
                  "
                >
                  Same as
                  {{ getDropdownById(fdcSecondDateRange).trendText }}</span
                >
              </v-tooltip>
              <span
                v-if="
                  filteredFdcColumn2Values[index]
                    .checked_in_custom_date_range_count != null &&
                  filteredFdcColumn2Values[index].show_checked_in_column
                "
                class="checked_in_container body-small"
                @click="
                  funnelDrilldown(
                    filteredFdcColumn2Values[index],
                    getDropdownById(fdcSecondDateRange),
                    'standard',
                    true,
                    fdcSecondCustom
                  )
                "
              >
                <v-icon size="20" class="checked_in_icon">
                  mdi-check-circle-outline
                </v-icon>
                {{
                  filteredFdcColumn2Values[index]
                    .checked_in_custom_date_range_count
                }}
              </span>
            </span>
          </template>
          <template
            #item.actualTotal3="{ item, index }"
            class="milestone-col-td"
            v-if="
              fdcThirdDateRange != null &&
              filteredFdcColumn3Values != null &&
              filteredFdcColumn3Values.length > 0
            "
          >
            <span class="d-flex align-items-center">
              <span
                @click="
                  funnelDrilldown(
                    filteredFdcColumn3Values[index],
                    getDropdownById(fdcThirdDateRange),
                    'standard',
                    false,
                    fdcThirdCustom
                  )
                "
                class="fdc-data"
              >
                {{
                  filteredFdcColumn3Values[index].custom_date_range_count
                    ? filteredFdcColumn3Values[index].custom_date_range_count
                    : 0
                }}
              </span>
              <v-tooltip bottom v-if="viewFdcTrends">
                <template v-slot:activator="{ on }">
                  <span
                    v-on="viewFdcTrends ? on : null"
                    class="trends-container"
                  >
                    <span
                      v-if="
                        viewFdcTrends &&
                        filteredFdcColumn3Values[index].trend_count > 0
                      "
                      :class="[
                        {
                          'positive-percentage':
                            !filteredFdcColumn3Values[index].inverse_trend,
                          'negative-percentage':
                            filteredFdcColumn3Values[index].inverse_trend
                        }
                      ]"
                    >
                      +{{
                        (filteredFdcColumn3Values[index].trend_count / 100)
                          | percent
                      }}
                      <v-icon
                        :class="[
                          {
                            'positive-trendline':
                              !filteredFdcColumn3Values[index].inverse_trend,
                            'negative-trendline':
                              filteredFdcColumn3Values[index].inverse_trend
                          }
                        ]"
                      >
                        trending_up
                      </v-icon>
                    </span>
                    <span
                      v-if="
                        viewFdcTrends &&
                        filteredFdcColumn3Values[index].trend_count < 0
                      "
                      :class="[
                        {
                          'positive-percentage':
                            filteredFdcColumn3Values[index].inverse_trend,
                          'negative-percentage':
                            !filteredFdcColumn3Values[index].inverse_trend
                        }
                      ]"
                    >
                      {{
                        (filteredFdcColumn3Values[index].trend_count / 100)
                          | percent
                      }}
                      <v-icon
                        :class="[
                          {
                            'positive-trendline':
                              filteredFdcColumn3Values[index].inverse_trend,
                            'negative-trendline':
                              !filteredFdcColumn3Values[index].inverse_trend
                          }
                        ]"
                      >
                        trending_down
                      </v-icon>
                    </span>
                    <span
                      v-if="
                        viewFdcTrends &&
                        (filteredFdcColumn3Values[index].trend_count === null ||
                          filteredFdcColumn3Values[index].trend_count === 0)
                      "
                      class="neutral-percentage"
                    >
                      {{
                        (filteredFdcColumn3Values[index].trend_count / 100)
                          | percent
                      }}
                      <v-icon class="neutral-trendline"> trending_flat </v-icon>
                    </span>
                  </span>
                </template>
                <span
                  v-if="
                    viewFdcTrends &&
                    filteredFdcColumn3Values[index].trend_count > 0
                  "
                >
                  {{
                    (Math.abs(filteredFdcColumn3Values[index].trend_count) /
                      100)
                      | percent
                  }}
                  more than
                  {{ getDropdownById(fdcThirdDateRange).trendText }}</span
                >
                <span
                  v-if="
                    viewFdcTrends &&
                    filteredFdcColumn3Values[index].trend_count < 0
                  "
                >
                  {{
                    (Math.abs(filteredFdcColumn3Values[index].trend_count) /
                      100)
                      | percent
                  }}
                  less than
                  {{ getDropdownById(fdcThirdDateRange).trendText }}</span
                >
                <span
                  v-if="
                    viewFdcTrends &&
                    (filteredFdcColumn3Values[index].trend_count === null ||
                      filteredFdcColumn3Values[index].trend_count === 0)
                  "
                >
                  Same as
                  {{ getDropdownById(fdcThirdDateRange).trendText }}</span
                >
              </v-tooltip>
              <span
                v-if="
                  filteredFdcColumn3Values[index]
                    .checked_in_custom_date_range_count != null &&
                  filteredFdcColumn3Values[index].show_checked_in_column
                "
                class="checked_in_container body-small"
                @click="
                  funnelDrilldown(
                    filteredFdcColumn3Values[index],
                    getDropdownById(fdcThirdDateRange),
                    'standard',
                    true,
                    fdcThirdCustom
                  )
                "
              >
                <v-icon size="20" class="checked_in_icon">
                  mdi-check-circle-outline
                </v-icon>
                {{
                  filteredFdcColumn3Values[index]
                    .checked_in_custom_date_range_count
                }}
              </span>
            </span>
          </template>
        </v-data-table>
      </div>
    </div>
    <div class="funnel-relative">
      <!--  APPOINTMENTS TO FDC PIPELINE END-->

      <!--       FUNNEL DRILLDOWN START -->
      <FunnelDrilldownDialog
          :value="funnelDrilldownDialog"
          :funnelDrilldownTitle="funnelDrilldownTitle"
          :funnelDrilldownData="funnelDrilldownData"
          :funnelDrilldownLoading="funnelDrilldownLoading"
          :funnelDrilldownHeaders="funnelDrilldownHeaders"
          :selectedFunnel="selectedFunnel"
          :totalSystemSize="totalSystemSize"
          @close="closeFunnelDrilldownDialog"
          @export="exportDrilldownCsv"
      ></FunnelDrilldownDialog>
    </div>
    <FunnelDrilldownDialogWithLotsOfColumns
        :value="fdcFunnelDrilldownDialog"
        :funnelDrilldownTitle="funnelDrilldownTitle"
        :funnelDrilldownData="funnelDrilldownData"
        :funnelDrilldownLoading="funnelDrilldownLoading"
        :funnelDrilldownHeaders="funnelDrilldownHeaders"
        :selectedFunnel="selectedFunnel"
        :totalSystemSize="totalSystemSize"
        @close="closeFunnelDrilldownDialog"
        @export="exportDrilldownCsv"
    />
    <!-- FUNNEL DRILLDOWN END -->
    <!------------------------------------- FUNNEL TAB END ------------------------------------>

    <ConfirmationDialog
      v-if="selectingCustomDates"
      :disableConfirm="
        customDate.startDate === null ||
        customDate.endDate === null ||
        customDate.startDate?.length === 0 ||
        customDate.endDate?.length === 0
      "
      :open-dialog="selectingCustomDates"
      @confirm="applyCustomDates()"
      @cancel="cancelCustomDialogue()"
      @close-dialog="selectingCustomDates = false"
    >
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

<script setup>
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import moment from 'moment'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import constants from '@/helpers/constants'
import {
  handleHidingGlobalLoader,
  getRequest,
  postRequest,
  getRequestWithParams
} from '@/helpers/helpers'

import { saveAs } from 'file-saver'
import {
  getCloserAreas,
  getCloserRegions,
  getCloserDistricts,
  getCloserOffices,
  getCloserReps
} from '@/services/dashboardService'

import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useRoute, useRouter } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'
import FunnelDrilldownDialog from "@/views/blueraven/closerDashboard/AppointmentCreatedFunnelDrilldownDialog.vue";
import FunnelDrilldownDialogWithLotsOfColumns
  from "@/views/blueraven/closerDashboard/FunnelDrilldownDialogWithLotsOfColumns.vue";

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const filters = vueInstance.$filters

const viewFdcTrends = ref(false)
const viewTrends = ref(false)
const viewOnlyMajorMilestones = ref(false)
const disableTrends = ref(false)
const firstDateRange = ref(2)
const secondDateRange = ref(null)
const thirdDateRange = ref(null)
const fdcFirstDateRange = ref(2)
const fdcSecondDateRange = ref(null)
const fdcThirdDateRange = ref(null)
const firstCustom = ref({
  startDate: '',
  endDate: '',
  trendStart: '',
  trendEnd: '',
  isActive: false
})
const secondCustom = ref({
  startDate: '',
  endDate: '',
  trendStart: '',
  trendEnd: '',
  isActive: false
})
const thirdCustom = ref({
  startDate: '',
  endDate: '',
  trendStart: '',
  trendEnd: ''
})
const fdcFirstCustom = ref({
  startDate: '',
  endDate: '',
  trendStart: '',
  trendEnd: '',
  isActive: false
})
const fdcSecondCustom = ref({
  startDate: '',
  endDate: '',
  trendStart: '',
  trendEnd: '',
  isActive: false
})
const fdcThirdCustom = ref({
  startDate: '',
  endDate: '',
  trendStart: '',
  trendEnd: ''
})
const firstPeriod = ref(null)
const secondPeriod = ref(null)
const thirdPeriod = ref(null)
const isLoading = ref(true)
const isBrCorporateUser = ref(userStore.details.companyId === 2)
const openFirstMenu = ref(false)
const openSecondMenu = ref(false)
const openThirdMenu = ref(false)
const fdcOpenFirstMenu = ref(false)
const fdcOpenSecondMenu = ref(false)
const fdcOpenThirdMenu = ref(false)
const funnelDrilldownDialog = ref(false)
const fdcFunnelDrilldownDialog = ref(false)
const currentUserOrgId = ref(null)
const dropdownValuesLoading = ref(true)
const dropdownValues = ref([])
const isCloser = ref(false)
const isCloserMgr = ref(false)
const isCloserDistrictMgr = ref(false)
const selectedFunnel = ref({})
const isCloserRegional = ref(false)
const userCanViewAll = ref(
  userStore.userHasFeatureAccessLevel('CLOSER_DASHBOARD', 'VIEW_ALL')
)
const userCanViewAllProjects = ref(
  userStore.userHasFeatureAccessLevel('PROJECTS', 'VIEW_ALL')
)
const headers = ref([])
const fdcHeaders = ref([])
const apptsCreatedPipelineLoaded = ref(false)
const apptsToFdcPipelineLoaded = ref(false)
const appointmentTypes = ref([])
const appointmentTypesModel = ref([])
const funnelsWereLoaded = ref(false)
const customColumn = ref(1)
const customTable = ref('apptsCreated')
const milestonesExpanded = ref(true)
const apptsCreatedExpanded = ref(true)
const fdcPipelineExpanded = ref(true)
const apptsCreatedPipelineDataLoading = ref(true)
const apptsToFdcPipelineDataLoading = ref(false)
const apptsCreatedPipelineData = ref([])
const apptsToFdcPipelineData = ref([])
const fdcExpandableMilestones = ref([0, 3, 11, 14])
const hideInactiveReps = ref(false)
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
const regionModel = ref([])
const regionData = ref([])
const districtModel = ref([])
const districtData = ref([])
const officeModel = ref([])
const officeData = ref([])
const repModel = ref([])
const repData = ref([])
const selectedRepData = ref([])
const repDataMaster = ref([])
const appointmentTypesSelectAll = ref(false)
const viewAllFilteredReps = ref(false)
const apptsCreatedPipelineDateRange = ref({
  label: 'Month to Date',
  value: 'MTD'
})
const showApptsCreatedPipelineCustomDates = ref(false)
const initialPageLoad = ref(true)
const areaValuesChanged = ref(false)
const regionValuesChanged = ref(false)
const districtValuesChanged = ref(false)
const officeValuesChanged = ref(false)
const repValuesChanged = ref(false)
const apptsToFdcPipelineDateRange = ref({
  label: 'Month to Date',
  value: 'MTD'
})
const showApptsToFdcPipelineCustomDates = ref(false)
const viewSelect = ref('standard')
const funnelDrilldownTitle = ref('')
const funnelDrilldownData = ref([])
const funnelDrilldownLoading = ref(false)
const funnelDrilldownSearch = ref('')
const filteredFunnelDrilldownData = ref([])
const funnelDrilldownRowCount = ref(0)
const totalSystemSize = ref(0)
const repLengthOverride = ref(false)
const footerProps = ref({
  showFirstLastPage: !constants.IS_MOBILE,
  firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
  lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
  'items-per-page-options': [100, 500, 1000, 2500, 5000, 10000]
})
const column2Values = ref([])
const column3Values = ref([])
const fdcColumn2Values = ref([])
const fdcColumn3Values = ref([])
const selectingCustomDates = ref(false)
const customDate = ref({
  startDate: '',
  endDate: '',
  trendStart: '',
  trendEnd: ''
})
const closerDashContainer = ref(null)

const timezone = computed(() => {
  return userStore.timezone.value || 'US/Mountain'
})
const currentUserId = computed(() => {
  return userStore.details.id
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

const filtersSelected = computed(() => {
  return (
    areaModel.value.length > 0 ||
    regionModel.value.length > 0 ||
    districtModel.value.length > 0 ||
    officeModel.value.length > 0
  )
})

const filteredApptsCreatedPipelineData = computed(() => {
  if (!milestonesExpanded.value) {
    return apptsCreatedPipelineData.value.filter((dv) => dv.display_order < 3)
  }
  return apptsCreatedPipelineData.value
})
const filteredFdcPipelineData = computed(() => {
  if (viewOnlyMajorMilestones.value) {
    return apptsToFdcPipelineData.value?.filter((dv) => dv.major_milestone)
  } else return apptsToFdcPipelineData.value
})
const filteredFdcColumn2Values = computed(() => {
  if (viewOnlyMajorMilestones.value) {
    return fdcColumn2Values.value?.filter((dv) => dv.major_milestone)
  } else return fdcColumn2Values.value
})
const filteredFdcColumn3Values = computed(() => {
  if (viewOnlyMajorMilestones.value) {
    return fdcColumn3Values.value?.filter((dv) => dv.major_milestone)
  } else return fdcColumn3Values.value
})
const funnelDrilldownHeaders = computed(() => {
  return [
    {
      text: '',
      value: 'count',
      show: true,
      sortable: false,
      width: "0.5%",
      optional: false
    }, // 0
    {
      text: 'Owner',
      value: 'owner_name',
      show: true,
      width: 90,
      optional: false
    }, // 1
    { text: 'Office', value: 'office', show: true, width: 75, optional: false }, // 2
    { text: 'State', value: 'state', show: true, width: 75, optional: false }, // 3
    {
      text: 'Metro',
      value: 'metro_area',
      show: true,
      width: 75,
      optional: false
    }, // 4
    {
      text: 'Status',
      value: 'status_type',
      show: true,
      width: 75,
      optional: false
    }, // 5
    {
      text: 'Name',
      value: 'customer_name',
      show: true,
      width: 90,
      optional: false
    }, // 6
    {
      text: 'Project ID',
      value: 'project_id',
      show: true,
      width: 85,
      optional: false
    }, // 7
    {
      text: 'Event ID',
      value: 'project_process_step_event_id',
      show: selectedFunnel.value.funnel_type_id === 1,
      width: 85,
      optional: false
    }, // 8
    {
      text: 'Source',
      value: 'source_name',
      show: true,
      width: 85,
      optional: false
    }, // 9
    {
      text: 'System Size',
      value: 'system_size',
      show: true,
      width: 110,
      optional: false
    }, // 10
    {
      text: 'Financier',
      value: 'financier',
      show: true,
      width: 95,
      optional: false
    }, // 11
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
    {
      text: 'Appointment Outcome',
      value: 'appointment_outcome',
      show: false,
      width: 170,
      optional: true
    }, // 15
    {
      text: 'Credit Decision Date',
      value: 'credit_decision_date',
      show: false,
      width: 160,
      optional: true,
      dateType: 'date',
      dateFormat: 'MM/DD/YYYY'
    }, // 16
    {
      text: 'Credit Check',
      value: 'credit_check',
      show: false,
      width: 115,
      optional: true
    }, // 17
    {
      text: 'Installation Agreement Signed Date',
      value: 'installation_agreement_signed_date',
      show: false,
      width: 235,
      optional: true,
      dateType: 'date',
      dateFormat: 'MM/DD/YYYY'
    }, // 18
    {
      text: 'Site Survey Verified Date',
      value: 'site_survey_verified_date',
      show: false,
      width: 160,
      optional: true,
      dateType: 'date',
      dateFormat: 'MM/DD/YYYY'
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
      optional: true,
      dateType: 'timestamp',
      dateFormat: 'MM/DD/YYYY'
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
      optional: true,
      dateType: 'date',
      dateFormat: 'MM/DD/YYYY'
    }, // 23
    {
      text: 'Utility Bill Verified Date',
      value: 'utility_bill_verified_date',
      show: false,
      width: 175,
      optional: true,
      dateType: 'date',
      dateFormat: 'MM/DD/YYYY'
    }, // 24
    {
      text: 'Financial Agreement Signed',
      value: 'financial_agreement_signed_date',
      show: false,
      width: 195,
      optional: true,
      dateType: 'date',
      dateFormat: 'MM/DD/YYYY'
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
      optional: true,
      dateType: 'date',
      dateFormat: 'MM/DD/YYYY'
    }, // 28
    {
      text: 'Checked In Time',
      value: 'checked_in_time',
      show: false,
      width: 160,
      optional: true,
      dateType: 'timestamp',
      dateFormat: 'MM/DD/YYYY h:mm a'
    } // 29
  ]
})
const windowInnerWidth = computed(() => {
  return window.innerWidth
})
const selectAllBrsProvidedSources = computed(() => {
  return (
    brsProvidedSourceModel.value.length === brsProvidedSourceData.value.length
  )
})
const selectSomeBrsProvidedSources = computed(() => {
  return (
    brsProvidedSourceModel.value.length > 0 &&
    !selectAllBrsProvidedSources.value
  )
})
const brsProvidedSourcesSelectIcon = computed(() => {
  if (
    brsProvidedSourceModel.value.length === brsProvidedSourceData.value.length
  ) {
    return 'check_box'
  }
  if (selectSomeBrsProvidedSources.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectSomeLeadsCreatedSources = computed(() => {
  return (
    leadsCreatedSourceModel.value.length > 0 &&
    !selectAllLeadsCreatedSources.value
  )
})
const leadsCreatedSourcesSelectIcon = computed(() => {
  if (
    leadsCreatedSourceModel.value.length === leadsCreatedSourceData.value.length
  ) {
    return 'check_box'
  }
  if (selectSomeLeadsCreatedSources.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const selectAllSelfGenSources = computed(() => {
  return selfGenSourceModel.value.length === selfGenSourceData.value.length
})
const selectAllLeadsCreatedSources = computed(() => {
  return (
    leadsCreatedSourceModel.value.length === leadsCreatedSourceData.value.length
  )
})
const selectAllFdcLeadsCreatedSources = computed(() => {
  return fdcSourceModel.value.length === fdcSourceData.value.length
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

const fdcSourcesSelectIcon = computed(() => {
  if (fdcSourceModel.value.length === fdcSourceData.value.length) {
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
  return (
    repModel.value.length === repData.value.length || repLengthOverride.value
  )
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

const appointmentTypesIcon = computed(() => {
  if (appointmentTypesModel.value.length === appointmentTypes.value.length) {
    return 'check_box'
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
  await getDropdownValues()
  await getAppointmentTypes()
  if (userStore.details.userPositions?.length > 0) {
    let primaryPosition = userStore.details.userPositions.find(
      (p) => !p.endDate && !p.archived && p.primaryFlag
    )
    let positionId = primaryPosition.positionId
    currentUserOrgId.value = primaryPosition.orgId

    isCloser.value = positionId === 1
    isCloserDistrictMgr.value = positionId === 517
    isCloserMgr.value =
      positionId === 2 || positionId === 326 || isCloserDistrictMgr.value
    isCloserRegional.value = positionId === 3
  }

  appStore.loading = true
  await loadFunnels()
  appStore.loading = false
  funnelsWereLoaded.value = true
  headers.value = [
    {
      text: 'Milestones',
      value: 'milestone',
      sortable: false,
      class: 'milestone-col-th',
      show: true
    },
    {
      text: 'Source',
      value: 'source',
      align: 'left',
      sortable: false,
      class: 'total-col-th data-col-th',
      show: true
    },
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
    {
      text: 'Milestones',
      value: 'milestone',
      sortable: false,
      class: 'milestone-col-th',
      show: true
    },
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
const exportCsv = async (tableName) => {
  appStore.loading = true
  try {
    if (tableName === 'created') {
      let filename = 'Closer Dashboard - Appointments Created Pipeline.csv'
      let csvData = ' , '
      if (
        dropdownValues.value.find((x) => x.id === firstDateRange.value).name ===
        'PERIOD'
      ) {
        csvData += dropdownValues.value.find(
          (x) => x.id === firstDateRange.value
        ).periodList[firstPeriod.value].shortLabel
      } else {
        csvData +=
          dropdownValues.value.find((x) => x.id === firstDateRange.value)
            .name === 'CUSTOM'
            ? firstCustom.value.name
            : dropdownValues.value.find((x) => x.id === firstDateRange.value)
                .friendlyName
      }
      if (viewTrends.value) {
        csvData += ', ' + 'Trend 1'
      }
      if (secondDateRange.value) {
        if (
          dropdownValues.value.find((x) => x.id === secondDateRange.value)
            .name === 'PERIOD'
        ) {
          csvData +=
            ' , ' +
            dropdownValues.value.find((x) => x.id === secondDateRange.value)
              .periodList[secondPeriod.value].shortLabel
        } else {
          csvData +=
            ', ' +
            (dropdownValues.value.find((x) => x.id === secondDateRange.value)
              .name === 'CUSTOM'
              ? secondCustom.value.name
              : dropdownValues.value.find((x) => x.id === secondDateRange.value)
                  .friendlyName)
        }
        if (viewTrends.value) {
          csvData += ', ' + 'Trend 2'
        }
      }
      if (thirdDateRange.value) {
        if (
          dropdownValues.value.find((x) => x.id === thirdDateRange.value)
            .name === 'PERIOD'
        ) {
          csvData +=
            ' , ' +
            dropdownValues.value.find((x) => x.id === thirdDateRange.value)
              .periodList[thirdPeriod.value].shortLabel
        } else {
          csvData +=
            ', ' +
            (dropdownValues.value.find((x) => x.id === thirdDateRange.value)
              .name === 'CUSTOM'
              ? thirdCustom.value.name
              : dropdownValues.value.find((x) => x.id === thirdDateRange.value)
                  .friendlyName)
        }
        if (viewTrends.value) {
          csvData += ', ' + 'Trend 3'
        }
      }
      csvData += '\n'

      apptsCreatedPipelineData.value.forEach((p, i) => {
        csvData +=
          p.name + ',' + (p.leads_created_count ? p.leads_created_count : 0)
        if (viewTrends.value) {
          csvData += ', ' + (p.trend ? p.trend : 0) + '%'
        }
        if (secondDateRange.value) {
          csvData +=
            ', ' +
            (column2Values.value[i].leads_created_count
              ? column2Values.value[i].leads_created_count
              : 0)
          if (viewTrends.value) {
            csvData +=
              ', ' +
              (column2Values.value[i].trend
                ? column2Values.value[i].trend
                : 0) +
              '%'
          }
        }
        if (thirdDateRange.value) {
          csvData +=
            ', ' +
            (column3Values.value[i].leads_created_count
              ? column3Values.value[i].leads_created_count
              : 0)
          if (viewTrends.value) {
            csvData +=
              ', ' +
              (column3Values.value[i].trend
                ? column3Values.value[i].trend
                : 0) +
              '%'
          }
        }
        csvData += '\n'
      })
      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      })

      saveAs(blob, filename)
    } else if (tableName === 'fdc') {
      let filename = 'Closer Dashboard - Appointments to FDC Pipeline.csv'
      let csvData = ' , '
      if (
        dropdownValues.value.find((x) => x.id === fdcFirstDateRange.value)
          .name === 'PERIOD'
      ) {
        csvData += dropdownValues.value.find(
          (x) => x.id === fdcFirstDateRange.value
        ).periodList[firstPeriod.value].shortLabel
      } else {
        csvData +=
          dropdownValues.value.find((x) => x.id === fdcFirstDateRange.value)
            .name === 'CUSTOM'
            ? firstCustom.value.name
            : dropdownValues.value.find((x) => x.id === fdcFirstDateRange.value)
                .friendlyName
      }
      if (viewFdcTrends.value) {
        csvData += ', ' + 'Trend 1'
      }
      if (fdcSecondDateRange.value) {
        if (
          dropdownValues.value.find((x) => x.id === fdcSecondDateRange.value)
            .name === 'PERIOD'
        ) {
          csvData +=
            ' , ' +
            dropdownValues.value.find((x) => x.id === fdcSecondDateRange.value)
              .periodList[secondPeriod.value].shortLabel
        } else {
          csvData +=
            ', ' +
            (dropdownValues.value.find((x) => x.id === fdcSecondDateRange.value)
              .name === 'CUSTOM'
              ? secondCustom.value.name
              : dropdownValues.value.find(
                  (x) => x.id === fdcSecondDateRange.value
                ).friendlyName)
        }
        if (viewFdcTrends.value) {
          csvData += ', ' + 'Trend 2'
        }
      }
      if (fdcThirdDateRange.value) {
        if (
          dropdownValues.value.find((x) => x.id === fdcThirdDateRange.value)
            .name === 'PERIOD'
        ) {
          csvData +=
            ' , ' +
            dropdownValues.value.find((x) => x.id === fdcThirdDateRange.value)
              .periodList[thirdPeriod.value].shortLabel
        } else {
          csvData +=
            ', ' +
            (dropdownValues.value.find((x) => x.id === fdcThirdDateRange.value)
              .name === 'CUSTOM'
              ? thirdCustom.value.name
              : dropdownValues.value.find(
                  (x) => x.id === fdcThirdDateRange.value
                ).friendlyName)
        }
        if (viewFdcTrends.value) {
          csvData += ', ' + 'Trend 3'
        }
      }
      csvData += '\n'

      filteredFdcPipelineData.value.forEach((p, i) => {
        csvData +=
          p.name +
          ',' +
          (p.custom_date_range_count ? p.custom_date_range_count : 0)
        if (viewFdcTrends.value) {
          csvData += ', ' + (p.trend_count ? p.trend_count : 0) + '%'
        }
        if (fdcSecondDateRange.value) {
          csvData +=
            ', ' +
            (fdcColumn2Values.value[i].custom_date_range_count
              ? fdcColumn2Values.value[i].custom_date_range_count
              : 0)
          if (viewFdcTrends.value) {
            csvData +=
              ', ' +
              (fdcColumn2Values.value[i].trend_count
                ? fdcColumn2Values.value[i].trend_count
                : 0) +
              '%'
          }
        }
        if (fdcThirdDateRange.value) {
          csvData +=
            ', ' +
            (fdcColumn3Values.value[i].custom_date_range_count
              ? fdcColumn3Values.value[i].custom_date_range_count
              : 0)
          if (viewFdcTrends.value) {
            csvData +=
              ', ' +
              (fdcColumn3Values.value[i].trend_count
                ? fdcColumn3Values.value[i].trend_count
                : 0) +
              '%'
          }
        }
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
const changeSources = () => {
  if (firstDateRange.value != null) {
    apptsCreatedPipelineLoad(1)
  }
  if (secondDateRange.value != null) {
    apptsCreatedPipelineLoad(2)
  }
  if (thirdDateRange.value != null) {
    apptsCreatedPipelineLoad(3)
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
    const params = {
      today: moment().format('YYYY-MM-DD')
    }

    const { data, status } = await getRequestWithParams(
      '/closerDashboard/dropdownValues',
      { params },
      'blueraven',
      []
    )
    dropdownValues.value = data
    isLoading.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving data')
  }
}
const getAppointmentTypes = async () => {
  try {
    const params = {
      today: moment().format('YYYY-MM-DD')
    }

    const { data, status } = await getRequest(
      '/closerDashboard/appointmentTypes',
      'blueraven',
      []
    )
    appointmentTypes.value = data
    appointmentTypesModel.value = cloneDeep(appointmentTypes.value)
    isLoading.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving data')
    isLoading.value = false
  }
}
const openDrilldown = async (item, column) => {
  if (column === 1) {
    if (
      dropdownValues.value.find((x) => x.id === firstDateRange.value).name ===
      'PERIOD'
    ) {
      startDate.value = moment(
        dropdownValues.value.find((x) => x.id === firstDateRange.value)
          .periodList[firstPeriod.value].startDate
      ).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = moment(
        dropdownValues.value.find((x) => x.id === firstDateRange.value)
          .periodList[firstPeriod.value].endDate
      ).format('YYYY-MM-DDTHH:mm:ss')
    } else {
      startDate.value = dropdownValues.value.find(
        (x) => x.id === firstDateRange.value
      ).startDate
        ? dropdownValues.value.find((x) => x.id === firstDateRange.value)
            .startDate
        : moment(firstCustom.value.startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = dropdownValues.value.find(
        (x) => x.id === firstDateRange.value
      ).endDate
        ? dropdownValues.value.find((x) => x.id === firstDateRange.value)
            .endDate
        : moment(firstCustom.value.endDate).format('YYYY-MM-DDTHH:mm:ss')
    }
  } else if (column === 2) {
    if (
      dropdownValues.value.find((x) => x.id === secondDateRange.value).name ===
      'PERIOD'
    ) {
      startDate.value = moment(
        dropdownValues.value.find((x) => x.id === secondDateRange.value)
          .periodList[secondPeriod.value].startDate
      ).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = moment(
        dropdownValues.value.find((x) => x.id === secondDateRange.value)
          .periodList[secondPeriod.value].endDate
      ).format('YYYY-MM-DDTHH:mm:ss')
    } else {
      startDate.value = dropdownValues.value.find(
        (x) => x.id === secondDateRange.value
      ).startDate
        ? dropdownValues.value.find((x) => x.id === secondDateRange.value)
            .startDate
        : moment(secondCustom.value.startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = dropdownValues.value.find(
        (x) => x.id === secondDateRange.value
      ).endDate
        ? dropdownValues.value.find((x) => x.id === secondDateRange.value)
            .endDate
        : moment(secondCustom.value.endDate).format('YYYY-MM-DDTHH:mm:ss')
    }
  } else if (column === 3) {
    if (
      dropdownValues.value.find((x) => x.id === thirdDateRange.value).name ===
      'PERIOD'
    ) {
      startDate.value = moment(
        dropdownValues.value.find((x) => x.id === thirdDateRange.value)
          .periodList[thirdPeriod.value].startDate
      ).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = moment(
        dropdownValues.value.find((x) => x.id === thirdDateRange.value)
          .periodList[thirdPeriod.value].endDate
      ).format('YYYY-MM-DDTHH:mm:ss')
    } else {
      startDate.value = dropdownValues.value.find(
        (x) => x.id === thirdDateRange.value
      ).startDate
        ? dropdownValues.value.find((x) => x.id === thirdDateRange.value)
            .startDate
        : moment(thirdCustom.value.startDate).format('YYYY-MM-DDTHH:mm:ss')
      endDate.value = dropdownValues.value.find(
        (x) => x.id === thirdDateRange.value
      ).endDate
        ? dropdownValues.value.find((x) => x.id === thirdDateRange.value)
            .endDate
        : moment(thirdCustom.value.endDate).format('YYYY-MM-DDTHH:mm:ss')
    }
  }
  if (moment(endDate.value).diff(moment(startDate.value), 'days') + 1 > 100) {
    return
  }
  selectedMilestone.value = item
  await getDrilldownHeaders()
  await getDrilldownData(column)
  showDrilldown.value = true
}

const changeFdcDropdownSelection = async (dropdown) => {
  customTable.value = 'FDC'
  if (dropdown === 1) {
    let result = cloneDeep(
      dropdownValues.value.find((x) => x.id === fdcFirstDateRange.value)
    )
    if (result === null) {
      return null
    }
    if (result.startDate === null) {
      if (!fdcFirstCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          customColumn.value = 1
          if (fdcFirstCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = fdcFirstCustom.value.startDate
              .format('YYYY-MM-DD')
              .toString()
          }
          if (fdcFirstCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = fdcFirstCustom.value.endDate
              .format('YYYY-MM-DD')
              .toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[firstPeriod.value].startDate
          result.endDate = result.periodList[firstPeriod.value].endDate
          if (firstPeriod.value != result.periodList.length - 1) {
            result.trendStart =
              result.periodList[firstPeriod.value + 1].startDate
            result.trendEnd = result.periodList[firstPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(fdcFirstCustom.value)
        // resetCustomDate();
        fdcFirstCustom.value.isActive = false
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await apptsToFdcPipelineLoad(1)
  } else if (dropdown === 2) {
    let result = cloneDeep(
      dropdownValues.value.find((x) => x.id === fdcSecondDateRange.value)
    )
    if (result === null) {
      return null
    }
    if (result.startDate === null) {
      if (!fdcSecondCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          customColumn.value = 2
          if (fdcSecondCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = fdcSecondCustom.value.startDate
              .format('YYYY-MM-DD')
              .toString()
          }
          if (fdcSecondCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = fdcSecondCustom.value.endDate
              .format('YYYY-MM-DD')
              .toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[secondPeriod.value].startDate
          result.endDate = result.periodList[secondPeriod.value].endDate
          if (secondPeriod.value != result.periodList.length - 1) {
            result.trendStart =
              result.periodList[secondPeriod.value + 1].startDate
            result.trendEnd = result.periodList[secondPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(fdcSecondCustom.value)
        // resetCustomDate();
        fdcSecondCustom.value.isActive = false
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await apptsToFdcPipelineLoad(2)
  } else if (dropdown === 3) {
    let result = cloneDeep(
      dropdownValues.value.find((x) => x.id === fdcThirdDateRange.value)
    )
    if (result == null) {
      return null
    }
    if (result.startDate === null) {
      if (!fdcThirdCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          customColumn.value = 3
          if (fdcThirdCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = fdcThirdCustom.value.startDate
              .format('YYYY-MM-DD')
              .toString()
          }
          if (fdcThirdCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = fdcThirdCustom.value.endDate
              .format('YYYY-MM-DD')
              .toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[thirdPeriod.value].startDate
          result.endDate = result.periodList[thirdPeriod.value].endDate
          if (thirdPeriod.value != result.periodList.length - 1) {
            result.trendStart =
              result.periodList[thirdPeriod.value + 1].startDate
            result.trendEnd = result.periodList[thirdPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(fdcThirdCustom.value)
        // resetCustomDate();
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await apptsToFdcPipelineLoad(3)
  }
}

const changeDropdownSelection = async (dropdown) => {
  customTable.value = 'apptsCreated'
  if (dropdown === 1) {
    let result = cloneDeep(
      dropdownValues.value.find((x) => x.id === firstDateRange.value)
    )
    if (result === null) {
      return null
    }
    if (result.startDate === null) {
      if (!firstCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          customColumn.value = 1
          if (firstCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = firstCustom.value.startDate
              .format('YYYY-MM-DD')
              .toString()
          }
          if (firstCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = firstCustom.value.endDate
              .format('YYYY-MM-DD')
              .toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[firstPeriod.value].startDate
          result.endDate = result.periodList[firstPeriod.value].endDate
          if (firstPeriod.value != result.periodList.length - 1) {
            result.trendStart =
              result.periodList[firstPeriod.value + 1].startDate
            result.trendEnd = result.periodList[firstPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(firstCustom.value)
        // resetCustomDate();
        firstCustom.value.isActive = false
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await apptsCreatedPipelineLoad(1)
  } else if (dropdown === 2) {
    let result = cloneDeep(
      dropdownValues.value.find((x) => x.id === secondDateRange.value)
    )
    if (result === null) {
      return null
    }
    if (result.startDate === null) {
      if (!secondCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          customColumn.value = 2
          if (secondCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = secondCustom.value.startDate
              .format('YYYY-MM-DD')
              .toString()
          }
          if (secondCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = secondCustom.value.endDate
              .format('YYYY-MM-DD')
              .toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[secondPeriod.value].startDate
          result.endDate = result.periodList[secondPeriod.value].endDate
          if (secondPeriod.value != result.periodList.length - 1) {
            result.trendStart =
              result.periodList[secondPeriod.value + 1].startDate
            result.trendEnd = result.periodList[secondPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(secondCustom.value)
        // resetCustomDate();
        secondCustom.value.isActive = false
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await apptsCreatedPipelineLoad(2)
  } else if (dropdown === 3) {
    let result = cloneDeep(
      dropdownValues.value.find((x) => x.id === thirdDateRange.value)
    )
    if (result == null) {
      return null
    }
    if (result.startDate === null) {
      if (!thirdCustom.value.isActive) {
        if (result.name === 'CUSTOM') {
          customColumn.value = 3
          if (thirdCustom.value.startDate.toString().length > 0) {
            customDate.value.startDate = thirdCustom.value.startDate
              .format('YYYY-MM-DD')
              .toString()
          }
          if (thirdCustom.value.endDate.toString().length > 0) {
            customDate.value.endDate = thirdCustom.value.endDate
              .format('YYYY-MM-DD')
              .toString()
          }
          selectingCustomDates.value = true
          return
        } else if (result.name === 'PERIOD') {
          result.startDate = result.periodList[thirdPeriod.value].startDate
          result.endDate = result.periodList[thirdPeriod.value].endDate
          if (thirdPeriod.value != result.periodList.length - 1) {
            result.trendStart =
              result.periodList[thirdPeriod.value + 1].startDate
            result.trendEnd = result.periodList[thirdPeriod.value + 1].endDate
          } else {
            delete result.trendStart
            delete result.trendEnd
          }
        }
      } else {
        result = cloneDeep(thirdCustom.value)
        // resetCustomDate();
      }
    } else if (result.name === 'ALL_TIME') {
      delete result.trendStart
      delete result.trendEnd
    }
    await apptsCreatedPipelineLoad(3)
  }
}
const getDropdownById = (id) => {
  return dropdownValues.value.find((x) => x.id === id)
}
const exportDrilldownCsv = () => {
  let csv = ''

  visibleFunnelDrilldownHeaders().forEach((h) => {
    if (h.text !== '') {
      return (csv += `${h.text},`)
    }
  })
  csv += `\n`

  funnelDrilldownData.value.forEach((o) => {
    visibleFunnelDrilldownHeaders().forEach((h) => {
      if (h.text !== '') {
        if (h.dateType !== null && h.dateType !== undefined) {
          //if it is a date it needs to be formatted here
          csv +=
            '"' +
            `${o[h.value] === null || o[h.value] === undefined ? '' : filters.formatDate(o[h.value], h.dateType, h.dateFormat)}` +
            '",'
        } else {
          csv +=
            '"' +
            `${o[h.value] === null || o[h.value] === undefined ? '' : o[h.value]}` +
            '",'
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
  return fdcExpandableMilestones.value.includes(item.display_order - 4)
    ? 'shaded-row'
    : ''
}

const visibleFunnelDrilldownHeaders = () => {
  return funnelDrilldownHeaders.value.filter((header) => header.show === true)
}

const resetScrollBarPosition = () => {
  // reset scroll bar position to top
  closerDashContainer.value.scrollTop = 0
}

/* FUNNEL-RELATED CODE START */
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
      apptsCreatedPipelineLoad(1)
      if (secondDateRange.value) {
        apptsCreatedPipelineLoad(2)
      }
      if (thirdDateRange.value) {
        apptsCreatedPipelineLoad(3)
      }
    } else {
      brsProvidedSourceModel.value = cloneDeep(brsProvidedSourceData.value)
      apptsCreatedPipelineLoad(1)
      if (secondDateRange.value) {
        apptsCreatedPipelineLoad(2)
      }
      if (thirdDateRange.value) {
        apptsCreatedPipelineLoad(3)
      }
    }
  })
}
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
    apptsToFdcPipelineLoad(1)
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

const loadFunnels = async () => {
  if (leadsCreatedSourceData.value?.length === 0) {
    await loadSources()
  }

  if (isCloser.value || isCloserMgr.value || isCloserRegional.value) {
    await areaLoad(true)
    await regionLoad(true, true)
    await districtLoad(true, true)
    await officeLoad(true, true)
    await repLoad(true)
  } else {
    await areaLoad(false)
    await regionLoad(false, true)
    await districtLoad(false, true)
    await officeLoad(false, true)
    await repLoad(false)
  }

  if (apptsToFdcPipelineData.value?.length > 0) {
    apptsToFdcPipelineLoad(1)
    if (fdcSecondDateRange.value) {
      apptsToFdcPipelineLoad(2)
    }
    if (fdcThirdDateRange.value) {
      apptsToFdcPipelineLoad(3)
    }
  }
}

const funnelAllReps = async () => {
  // if(!filtersSelected.value) {
  //   areaModel.value = []
  //   districtModel.value = []
  //   regionModel.value = []
  //   officeModel.value = []
  //
  //   // repModel.value = [
  //   //   {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
  //   // ]
  //   //
  //   // repData.value = [
  //   //   {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
  //   // ]
  // }
  // else{
  viewAllFilteredReps.value = true
  // }

  // apptsToFdcPipelineLoad(appts_to_fdc_pipeline_dt1.value, appts_to_fdc_pipeline_dt2.value, false)
  apptsToFdcPipelineLoad(1)
  if (fdcSecondDateRange.value) {
    apptsToFdcPipelineLoad(2)
  }
  if (fdcThirdDateRange.value) {
    apptsToFdcPipelineLoad(3)
  }
}

const loadSources = async () => {
  try {
    //todo: should be changed to await
    getRequest('/closerDashboard/getBrsProvidedSources', 'blueraven', []).then(
      (res) => {
        let filteredData = res.data.filter((data) => data.sourceName != 'EPC')
        if (isCloser.value || isCloserMgr.value) {
          res.data = filteredData
        }
        brsProvidedSourceData.value = res.data
        brsProvidedSourceModel.value = cloneDeep(filteredData)
        getRequest('/closerDashboard/getSelfGenSources', 'blueraven', []).then(
          (res) => {
            selfGenSourceData.value = res.data
            selfGenSourceModel.value = cloneDeep(selfGenSourceData.value)
          }
        )

        getRequest(
          '/closerDashboard/getLeadsCreatedSources',
          'blueraven',
          []
        ).then((res) => {
          leadsCreatedSourceData.value = res.data
          fdcSourceData.value = res.data
          let filteredData = res.data.filter((data) => data.sourceName != 'EPC')
          leadsCreatedSourceModel.value = cloneDeep(filteredData)
          fdcSourceModel.value = cloneDeep(filteredData)
          apptsCreatedPipelineLoad(1)
        })
      }
    )
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving lists of sources')
  }
}

const apptsCreatedPipelineLoad = async (column) => {
  apptsCreatedPipelineLoaded.value = false
  let brsProvidedSources = []
  let selfGenSources = []
  let leadsCreatedSources = []
  let dateSelected = null

  brsProvidedSourceModel.value?.forEach((brsProvidedSource) => {
    if (brsProvidedSource.sourceId) {
      brsProvidedSources.push(brsProvidedSource.sourceId)
    }
  })

  selfGenSourceModel.value.forEach((selfGenSource) => {
    if (selfGenSource.sourceId) {
      selfGenSources.push(selfGenSource.sourceId)
    }
  })

  leadsCreatedSourceModel.value.forEach((leadsCreatedSource) => {
    if (leadsCreatedSource.sourceId) {
      leadsCreatedSources.push(leadsCreatedSource.sourceId)
    }
  })

  if (column === 1) {
    dateSelected = getDropdownById(firstDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate =
        dateSelected.periodList[firstPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[firstPeriod.value].endDate
      dateSelected.trendStart =
        dateSelected.periodList[firstPeriod.value].trendStart
      dateSelected.trendEnd =
        dateSelected.periodList[firstPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = firstCustom.value
    }
  } else if (column === 2) {
    dateSelected = getDropdownById(secondDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate =
        dateSelected.periodList[secondPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[secondPeriod.value].endDate
      dateSelected.trendStart =
        dateSelected.periodList[secondPeriod.value].trendStart
      dateSelected.trendEnd =
        dateSelected.periodList[secondPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = secondCustom.value
    }
  } else if (column === 3) {
    dateSelected = getDropdownById(thirdDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate =
        dateSelected.periodList[thirdPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[thirdPeriod.value].endDate
      dateSelected.trendStart =
        dateSelected.periodList[thirdPeriod.value].trendStart
      dateSelected.trendEnd =
        dateSelected.periodList[thirdPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = thirdCustom.value
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

  apptsCreatedPipelineDataLoading.value = true
  try {
    await postRequest(
      '/closerDashboard/funnel/apptsCreatedPipeline',
      requestBody,
      'blueraven',
      []
    ).then((res) => {
      if (column == 1) {
        apptsCreatedPipelineData.value = orderBy(
          res.data,
          (row) => row.display_order
        )
      } else if (column == 2) {
        column2Values.value = orderBy(res.data, (row) => row.display_order)
      } else if (column == 3) {
        column3Values.value = orderBy(res.data, (row) => row.display_order)
      }
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
const applyCustomDates = async () => {
  if (customTable.value === 'apptsCreated') {
    if (customColumn.value === 1) {
      firstCustom.value.startDate = moment(customDate.value.startDate)
      firstCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = firstCustom.value.endDate.diff(
        firstCustom.value.startDate,
        'days'
      )
      firstCustom.value.trendEnd = firstCustom.value.startDate
        .clone()
        .subtract(1, 'days')
      firstCustom.value.trendStart = firstCustom.value.trendEnd
        .clone()
        .subtract(dateDiff, 'days')
      getDropdownById(firstDateRange.value).trendText =
        moment(firstCustom.value.trendStart).format('MM/DD/YYYY') +
        ' - ' +
        moment(firstCustom.value.trendEnd).format('MM/DD/YYYY')
      firstCustom.value.name =
        moment(firstCustom.value.startDate).format('MM/DD/YY') +
        '-' +
        moment(firstCustom.value.endDate).format('MM/DD/YY')
    } else if (customColumn.value === 2) {
      secondCustom.value.startDate = moment(customDate.value.startDate)
      secondCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = secondCustom.value.endDate.diff(
        secondCustom.value.startDate,
        'days'
      )
      secondCustom.value.trendEnd = secondCustom.value.startDate
        .clone()
        .subtract(1, 'days')
      secondCustom.value.trendStart = secondCustom.value.trendEnd
        .clone()
        .subtract(dateDiff, 'days')
      getDropdownById(secondDateRange.value).trendText =
        moment(secondCustom.value.trendStart).format('MM/DD/YYYY') +
        ' - ' +
        moment(secondCustom.value.trendEnd).format('MM/DD/YYYY')
      secondCustom.value.name =
        moment(secondCustom.value.startDate).format('MM/DD/YY') +
        '-' +
        moment(secondCustom.value.endDate).format('MM/DD/YY')
    } else if (customColumn.value === 3) {
      thirdCustom.value.startDate = moment(customDate.value.startDate)
      thirdCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = thirdCustom.value.endDate.diff(
        thirdCustom.value.startDate,
        'days'
      )
      thirdCustom.value.trendEnd = thirdCustom.value.startDate
        .clone()
        .subtract(1, 'days')
      thirdCustom.value.trendStart = thirdCustom.value.trendEnd
        .clone()
        .subtract(dateDiff, 'days')
      getDropdownById(thirdDateRange.value).trendText =
        moment(thirdCustom.value.trendStart).format('MM/DD/YYYY') +
        ' - ' +
        moment(thirdCustom.value.trendEnd).format('MM/DD/YYYY')
      thirdCustom.value.name =
        moment(thirdCustom.value.startDate).format('MM/DD/YY') +
        '-' +
        moment(thirdCustom.value.endDate).format('MM/DD/YY')
    }

    await apptsCreatedPipelineLoad(customColumn.value)
  } else {
    if (customColumn.value === 1) {
      fdcFirstCustom.value.startDate = moment(customDate.value.startDate)
      fdcFirstCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = fdcFirstCustom.value.endDate.diff(
        fdcFirstCustom.value.startDate,
        'days'
      )
      fdcFirstCustom.value.trendEnd = fdcFirstCustom.value.startDate
        .clone()
        .subtract(1, 'days')
      fdcFirstCustom.value.trendStart = fdcFirstCustom.value.trendEnd
        .clone()
        .subtract(dateDiff, 'days')
      getDropdownById(fdcFirstDateRange.value).trendText =
        moment(fdcFirstCustom.value.trendStart).format('MM/DD/YYYY') +
        ' - ' +
        moment(fdcFirstCustom.value.trendEnd).format('MM/DD/YYYY')
      fdcFirstCustom.value.name =
        moment(fdcFirstCustom.value.startDate).format('MM/DD/YY') +
        '-' +
        moment(fdcFirstCustom.value.endDate).format('MM/DD/YY')
    } else if (customColumn.value === 2) {
      fdcSecondCustom.value.startDate = moment(customDate.value.startDate)
      fdcSecondCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = fdcSecondCustom.value.endDate.diff(
        fdcSecondCustom.value.startDate,
        'days'
      )
      fdcSecondCustom.value.trendEnd = fdcSecondCustom.value.startDate
        .clone()
        .subtract(1, 'days')
      fdcSecondCustom.value.trendStart = fdcSecondCustom.value.trendEnd
        .clone()
        .subtract(dateDiff, 'days')
      getDropdownById(fdcSecondDateRange.value).trendText =
        moment(fdcSecondCustom.value.trendStart).format('MM/DD/YYYY') +
        ' - ' +
        moment(fdcSecondCustom.value.trendEnd).format('MM/DD/YYYY')
      fdcSecondCustom.value.name =
        moment(fdcSecondCustom.value.startDate).format('MM/DD/YY') +
        '-' +
        moment(fdcSecondCustom.value.endDate).format('MM/DD/YY')
    } else if (customColumn.value === 3) {
      fdcThirdCustom.value.startDate = moment(customDate.value.startDate)
      fdcThirdCustom.value.endDate = moment(customDate.value.endDate)
      let dateDiff = fdcThirdCustom.value.endDate.diff(
        fdcThirdCustom.value.startDate,
        'days'
      )
      fdcThirdCustom.value.trendEnd = fdcThirdCustom.value.startDate
        .clone()
        .subtract(1, 'days')
      fdcThirdCustom.value.trendStart = fdcThirdCustom.value.trendEnd
        .clone()
        .subtract(dateDiff, 'days')
      getDropdownById(fdcThirdDateRange.value).trendText =
        moment(fdcThirdCustom.value.trendStart).format('MM/DD/YYYY') +
        ' - ' +
        moment(fdcThirdCustom.value.trendEnd).format('MM/DD/YYYY')
      fdcThirdCustom.value.name =
        moment(fdcThirdCustom.value.startDate).format('MM/DD/YY') +
        '-' +
        moment(fdcThirdCustom.value.endDate).format('MM/DD/YY')
    }

    await apptsToFdcPipelineLoad(customColumn.value)
  }
}
const apptsToFdcPipelineLoad = async (column) => {
  apptsToFdcPipelineLoaded.value = false
  apptsToFdcPipelineDataLoading.value = true
  let orgs = []
  let leadsCreatedSources = []
  let dateSelected = null
  let appointmentTypes = []

  if (repModel.value.length === 0 && !viewAllFilteredReps.value) {
    apptsToFdcPipelineData.value = []
    return
  }

  officeModel.value.forEach((org) => orgs.push(org.org_id))

  selectedRepData.value = []
  if (viewAllFilteredReps.value && repModel.value.length === 0) {
    filteredRepData.value.forEach((rep) =>
      selectedRepData.value.push(rep.user_position_id)
    )
  } else {
    repModel.value.forEach((rep) =>
      selectedRepData.value.push(rep.user_position_id)
    )
  }

  fdcSourceModel.value.forEach((leadsCreatedSource) => {
    if (leadsCreatedSource.sourceId) {
      leadsCreatedSources.push(leadsCreatedSource.sourceId)
    }
  })

  if (column === 1) {
    dateSelected = getDropdownById(fdcFirstDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate =
        dateSelected.periodList[firstPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[firstPeriod.value].endDate
      dateSelected.trendStart =
        dateSelected.periodList[firstPeriod.value].trendStart
      dateSelected.trendEnd =
        dateSelected.periodList[firstPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = fdcFirstCustom.value
    }
  }

  if (column === 2) {
    dateSelected = getDropdownById(fdcSecondDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate =
        dateSelected.periodList[secondPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[secondPeriod.value].endDate
      dateSelected.trendStart =
        dateSelected.periodList[secondPeriod.value].trendStart
      dateSelected.trendEnd =
        dateSelected.periodList[secondPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = fdcSecondCustom.value
    }
  }

  if (column === 3) {
    dateSelected = getDropdownById(fdcThirdDateRange.value)
    if (dateSelected.periodList != null) {
      dateSelected.startDate =
        dateSelected.periodList[thirdPeriod.value].startDate
      dateSelected.endDate = dateSelected.periodList[thirdPeriod.value].endDate
      dateSelected.trendStart =
        dateSelected.periodList[thirdPeriod.value].trendStart
      dateSelected.trendEnd =
        dateSelected.periodList[thirdPeriod.value].trendEnd
    } else if (dateSelected.name === 'CUSTOM') {
      dateSelected = fdcThirdCustom.value
    }
  }

  if (appointmentTypesModel.value.length > 0) {
    for (let appointmentType of appointmentTypesModel.value) {
      appointmentTypes.push(appointmentType.id)
    }
  } else {
    appointmentTypes = null
  }

  const requestBody = {
    users: selectedRepData.value,
    start: dateSelected.startDate,
    end: dateSelected.endDate,
    trendStart: dateSelected.trendStart,
    trendEnd: dateSelected.trendEnd,
    appointmentTypeIds: appointmentTypes,
    leadSourceIds: leadsCreatedSources,
    hideInactive: hideInactiveReps.value
  }

  try {
    if (!initialPageLoad.value) {
      appStore.loading = true
    }
    await postRequest(
      '/closerDashboard/funnel/' + viewSelect.value,
      requestBody,
      'blueraven',
      []
    ).then((res) => {
      let dataTarget = orderBy(res.data, (row) => row.display_order)
      // apptsToFdcPipelineData.value = orderBy(res.data, row => row.display_order)
      dataTarget = orderBy(res.data, (row) => row.display_order)

      if (column === 1) {
        apptsToFdcPipelineData.value = dataTarget
      } else if (column === 2) {
        fdcColumn2Values.value = dataTarget
      } else if (column === 3) {
        fdcColumn3Values.value = dataTarget
      }
      apptsToFdcPipelineLoaded.value = true
      apptsToFdcPipelineDataLoading.value = false
      if (!initialPageLoad.value) {
        appStore.loading = false
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving Appointments to FDC Pipeline data')
    if (!initialPageLoad.value) {
      appStore.loading = false
    }
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

const areaLoad = async (preSelectLists) => {
  if (repValuesChanged.value || initialPageLoad.value) {
    if (!currentUserId.value) return

    await getCloserAreas(currentUserId.value, false).then((res) => {
      if (res?.length > 0) {
        areaData.value = res
      }

      if (preSelectLists && (isCloserMgr.value || isCloserRegional.value)) {
        areaModel.value = areaData.value.filter((od) => od.active)
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
}

const regionLoad = async (preSelectLists) => {
  if (repValuesChanged.value || initialPageLoad.value) {
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

    await getCloserRegions(
      currentUserId.value,
      JSON.stringify(areas),
      false
    ).then((res) => {
      regionData.value = res

      if (preSelectLists && (isCloserMgr.value || isCloserRegional.value)) {
        regionModel.value = regionData.value.filter((od) => od.active)
      } else if (preSelectLists) {
        regionModel.value = cloneDeep(regionData.value)
      }

      if (!initialPageLoad.value) {
        districtLoad(preSelectLists, true)
        // repLoad(preSelectLists, true)
      }
    })

    apptsToFdcPipelineData.value = []
  }
}

const districtLoad = async (preSelectLists) => {
  if (repValuesChanged.value || initialPageLoad.value) {
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

    await getCloserDistricts(
      currentUserId.value,
      JSON.stringify(areas),
      JSON.stringify(regions),
      false
    ).then((res) => {
      if (res?.length > 0) {
        districtData.value = res
      }

      if (preSelectLists && (isCloserMgr.value || isCloserRegional.value)) {
        districtModel.value = districtData.value.filter((od) => od.active)
      } else if (preSelectLists) {
        districtModel.value = cloneDeep(districtData.value)
      }

      // reset these values when the districts change
      // regionModel.value = []
      apptsToFdcPipelineData.value = []
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
}

const officeLoad = async (preSelectLists) => {
  if (repValuesChanged.value || initialPageLoad.value) {
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
    //
    //   // if (regions?.length === 0) return
    // }

    // reset these values when the offices change
    repModel.value = []
    apptsToFdcPipelineData.value = []
    await getCloserOffices(
      currentUserId.value,
      JSON.stringify(areas),
      JSON.stringify(regions),
      JSON.stringify(districts),
      false
    ).then((res) => {
      officeData.value = res

      if (preSelectLists && (isCloserMgr.value || isCloserRegional.value)) {
        officeModel.value = officeData.value.filter((od) => od.active)
      } else if (preSelectLists) {
        officeModel.value = cloneDeep(officeData.value)
      }

      if (!initialPageLoad.value) {
        repLoad(preSelectLists, true)
      }
    })

    // apptsToFdcPipelineData.value = []
    // repData.value = []
    repModel.value = []
  }
  repValuesChanged.value = false
}

const repLoad = async (preSelectLists) => {
  //reset these any time we are reloading reps or things get weird
  if (repValuesChanged.value || initialPageLoad.value) {
    if (!initialPageLoad.value) {
      appStore.loading = true
    }
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

    apptsToFdcPipelineData.value = []
    await getCloserReps(
      currentUserId.value,
      JSON.stringify(areas),
      JSON.stringify(regions),
      JSON.stringify(districts),
      JSON.stringify(offices)
    ).then((res) => {
      repData.value = res

      repDataMaster.value = cloneDeep(res)

      if (preSelectLists) {
        // if(repDataMaster.value.length > 1000){
        //   repModel.value = [
        //     {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
        //   ]
        //
        //   repData.value = [
        //     {user_id: -1, user_position_id: -1, name: 'All Reps', active: true}
        //   ]
        // }
        // else {
        //   repModel.value = cloneDeep(repData.value)
        // }
        viewAllFilteredReps.value = true
      }

      if (initialPageLoad.value) {
        apptsToFdcPipelineData.value = []

        apptsToFdcPipelineLoad(1)
        if (fdcSecondDateRange.value) {
          apptsToFdcPipelineLoad(2)
        }
        if (fdcThirdDateRange.value) {
          apptsToFdcPipelineLoad(3)
        }
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

const funnelDrilldown = async (
  funnel,
  dateRange,
  pipelineName,
  isCheckedInColumn,
  customColumn
) => {
  appStore.loading = true
  selectedFunnel.value = funnel
  let sourceIds = []
  let userIds = []
  let orgIds = []
  let appointmentTypeIds = null
  let start, end
  let datesMatch = false
  let selectedStartDate = dateRange.startDate
  let selectedEndDate = dateRange.endDate

  if (pipelineName === 'apptsCreatedPipeline') {
    let brsSourceIds = brsProvidedSourceModel.value.map(
      (brsProvidedSource) => brsProvidedSource.sourceId
    )
    let selfGenSourceIds = selfGenSourceModel.value.map(
      (selfGenSource) => selfGenSource.sourceId
    )
    let leadSourceIds = leadsCreatedSourceModel.value.map(
      (leadSource) => leadSource.sourceId
    )
    if (funnel.id === 12) {
      // BRS-provided sources
      sourceIds = brsSourceIds
    } else if (funnel.id === 13) {
      // Self-gen sources
      sourceIds = selfGenSourceIds
    } else if (funnel.id === 34) {
      sourceIds = leadSourceIds
    } else {
      sourceIds = brsSourceIds.concat(selfGenSourceIds)
    }
  } else {
    userIds = repModel.value.map((rep) => rep.user_position_id)
    orgIds = officeModel.value.map((org) => org.org_id)
    if (appointmentTypesModel.value.length > 0) {
      appointmentTypeIds = appointmentTypesModel.value.map(
        (appointmentType) => appointmentType.id
      )
    }
  }

  if (dateRange.name === 'CUSTOM') {
    datesMatch =
      moment(customColumn.startDate).format('YYYY-MM-DD') ===
      moment(customColumn.endDate).format('YYYY-MM-DD')
    selectedStartDate = moment(customColumn.startDate).format('YYYY-MM-DD')
    selectedEndDate = moment(customColumn.endDate).format('YYYY-MM-DD')
  } else {
    datesMatch =
      moment(dateRange.startDate).format('YYYY-MM-DD') ===
      moment(dateRange.endDate).format('YYYY-MM-DD')
  }
  if (datesMatch) {
    funnelDrilldownTitle.value =
      funnel.name + ' on ' + moment(selectedStartDate).format('M/D/YYYY')
  } else {
    funnelDrilldownTitle.value =
      funnel.name +
      ' ' +
      moment(selectedStartDate).format('M/D/YYYY') +
      ' - ' +
      moment(selectedEndDate).format('M/D/YYYY')
  }

  funnelDrilldownHeaders.value[1].show = true
  funnelDrilldownHeaders.value[2].show = true
  funnelDrilldownHeaders.value[4].show = true
  funnelDrilldownHeaders.value[5].show = true
  funnelDrilldownHeaders.value[7].show = true
  funnelDrilldownHeaders.value[9].show = false
  funnelDrilldownHeaders.value[10].show = true
  funnelDrilldownHeaders.value[11].show = true
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
      funnelDrilldownHeaders.value[9].show = true //source
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
      funnelDrilldownHeaders.value[9].show = true //source
      funnelDrilldownHeaders.value[18].show = true // installation_agreement_signed_date
      funnelDrilldownHeaders.value[20].show = true // site_survey_completed_date
      break
    case 5: // Site Surveys Verified
      funnelDrilldownHeaders.value[9].show = true //source
      funnelDrilldownHeaders.value[19].show = true // site_survey_verified_date
      break
    case 6: // Final Designs sent to Homeowner
      funnelDrilldownHeaders.value[9].show = true //source
      funnelDrilldownHeaders.value[21].show = true // final_design_sent_to_homeowner_date
      funnelDrilldownHeaders.value[22].show = true // final_design_signed_date
      break
    case 7: // Final Designs Approved
      funnelDrilldownHeaders.value[9].show = true //source
      funnelDrilldownHeaders.value[22].show = true // final_design_signed_date
      funnelDrilldownHeaders.value[25].show = true // financial_agreement_signed_date
      funnelDrilldownHeaders.value[23].show = true // proof_of_homeowners_insurance_obtained_date
      funnelDrilldownHeaders.value[26].show = true // cash_down_payment
      funnelDrilldownHeaders.value[24].show = true // utility_bill_verified_date
      break
    case 21: // Final Designs Completed
      funnelDrilldownHeaders.value[9].show = true
      funnelDrilldownHeaders.value[27].show = true // final_design_complete_date
      break
    case 8: // Installations Completed
      funnelDrilldownHeaders.value[9].show = true //source
      funnelDrilldownHeaders.value[28].show = true // substantial_completion_date
      break
    case 34:
      funnelDrilldownHeaders.value[1].show = true
      funnelDrilldownHeaders.value[2].show = false
      funnelDrilldownHeaders.value[4].show = false
      funnelDrilldownHeaders.value[5].show = false
      funnelDrilldownHeaders.value[7].show = false
      funnelDrilldownHeaders.value[9].show = true
      funnelDrilldownHeaders.value[10].show = false
      funnelDrilldownHeaders.value[11].show = false

      break
  }

  const requestBody = {
    start: selectedStartDate,
    end: selectedEndDate,
    funnelId: funnel.id,
    hideInactive: hideInactiveReps.value,
    leadSourceIds: fdcSourceModel.value.map((leadSource) => leadSource.sourceId)
  }

  if (pipelineName === 'apptsCreatedPipeline') {
    requestBody.sources = sourceIds
  } else {
    requestBody.users = selectedRepData.value
    requestBody.isCheckedInColumn = isCheckedInColumn
    requestBody.appointmentTypeIds = appointmentTypeIds
  }

  try {
    await postRequest(
      `/closerDashboard/funnelDrilldown/${pipelineName}`,
      requestBody,
      'blueraven',
      []
    ).then(({ data, status }) => {
      funnelDrilldownData.value = data?.length > 0 ? data : []
      if (funnelDrilldownData.value?.length > 0) {
        // for (let i = 0; i < funnelDrilldownData.value.length; i++) {
        //   funnelDrilldownData.value[i].rowNum = i + 1
        // }

        markMissingDrilldownData()
      }

      if (pipelineName === 'apptsCreatedPipeline') {
        funnelDrilldownDialog.value = true
      } else {
        fdcFunnelDrilldownDialog.value = true
        console.log(fdcFunnelDrilldownDialog.value)
      }
      handleHidingGlobalLoader(status)
      appStore.loading = false
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

      if (
        key === 'credit_check' &&
        line[key] &&
        line[key] !== 'Pass' &&
        line[key] !== 'Pending Review'
      ) {
        newLine.strike = true
      }
    })
    return newLine
  })
}

const calcTotalSystemSize = () => {
  if (
    funnelDrilldownData.value.length > 0 &&
    filteredFunnelDrilldownData.value.length > 0
  ) {
    let total = 0

    filteredFunnelDrilldownData.value.forEach((row) => {
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

const filteredRepData = computed(() => {
  // if(!milestonesExpanded.value){
  //   return apptsCreatedPipelineData.value.filter(dv => dv.display_order < 3)
  // }
  if (!hideInactiveReps.value) {
    return repData.value
  } else {
    return repData.value.filter((dv) => dv.active)
  }
})

const switchInactiveReps = () => {
  apptsToFdcPipelineData.value = []
}

const filteredRepDataMaster = computed(() => {
  // if(!milestonesExpanded.value){
  //   return apptsCreatedPipelineData.value.filter(dv => dv.display_order < 3)
  // }
  if (!hideInactiveReps.value) {
    return repDataMaster.value
  } else {
    return repDataMaster.value.filter((dv) => dv.active)
  }
})

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
      apptsCreatedPipelineLoad(1)
      if (secondDateRange.value) {
        apptsCreatedPipelineLoad(2)
      }
      if (thirdDateRange.value) {
        apptsCreatedPipelineLoad(3)
      }
    } else {
      selfGenSourceModel.value = cloneDeep(selfGenSourceData.value)
      apptsCreatedPipelineLoad(1)
      if (secondDateRange.value) {
        apptsCreatedPipelineLoad(2)
      }
      if (thirdDateRange.value) {
        apptsCreatedPipelineLoad(3)
      }
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
      apptsCreatedPipelineLoad(1)
      if (secondDateRange.value) {
        apptsCreatedPipelineLoad(2)
      }
      if (thirdDateRange.value) {
        apptsCreatedPipelineLoad(3)
      }
    } else {
      leadsCreatedSourceModel.value = cloneDeep(leadsCreatedSourceData.value)
      apptsCreatedPipelineLoad(1)
      if (secondDateRange.value) {
        apptsCreatedPipelineLoad(2)
      }
      if (thirdDateRange.value) {
        apptsCreatedPipelineLoad(3)
      }
    }
  })
}

const toggleSelectAllFdcLeadsCreatedSources = () => {
  vueInstance.$nextTick(() => {
    if (selectAllFdcLeadsCreatedSources.value) {
      fdcSourceModel.value = []
      apptsToFdcPipelineLoad(1)
      if (fdcSecondDateRange.value) {
        apptsToFdcPipelineLoad(2)
      }
      if (fdcThirdDateRange.value) {
        apptsToFdcPipelineLoad(3)
      }
    } else {
      fdcSourceModel.value = cloneDeep(fdcSourceData.value)
      apptsToFdcPipelineLoad(1)
      if (fdcSecondDateRange.value) {
        apptsToFdcPipelineLoad(2)
      }
      if (fdcThirdDateRange.value) {
        apptsToFdcPipelineLoad(3)
      }
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
    //
  }
  repValuesChanged.value = true
  await regionLoad(false)
  repValuesChanged.value = false
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
    // officeLoad(false)
  }
  repValuesChanged.value = true
  await districtLoad(false)
  repValuesChanged.value = false
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

const toggleSomeReps = () => {
  if (repValuesChanged.value) {
    viewAllFilteredReps.value = false
    if (repData.value[0]?.name == 'All Reps') {
      repData.value = repDataMaster.value
      repModel.value = []
    }
    vueInstance.$nextTick(() => {
      apptsToFdcPipelineLoad(1)
      if (fdcSecondDateRange.value) {
        apptsToFdcPipelineLoad(2)
      }
      if (fdcThirdDateRange.value) {
        apptsToFdcPipelineLoad(3)
      }
    })
  }
  repValuesChanged.value = false
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
  fdcFunnelDrilldownDialog.value = false
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

.checked_in_icon {
  padding-right: 4px;
}
.trends-container {
  width: 88px;
}
.fdc-data {
  min-width: 72px;
  cursor: pointer;
}
.appts-data {
  cursor: pointer;
}
.other-filters-text {
  margin-right: 12px;
  color: var(--v-grey-darken1);
}
.rep-filters-text {
  margin-right: 18px;
  color: var(--v-grey-darken1);
}
.hide-inactive-label {
  margin-right: 8px;
  margin-bottom: 10px;
  letter-spacing: normal;
}
.hide-inactive-switch-container {
  width: 200px;
}
.reps-container {
  padding-right: 6px;
}
.hide-inactive-switch {
  margin-right: 8px;
  margin-bottom: 6px;
  margin-top: -4px;
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

.reset-button-inactive {
  color: var(--v-grey-darken2);
  border-radius: 4px;
  border: 1px solid #9e9e9e;
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
.material-symbols-outlined {
  font-variation-settings:
    'FILL' 0,
    'wght' 400,
    'GRAD' 0,
    'opsz' 24;
}
.checked_in_container {
  display: flex;
  background-color: var(--v-grey-lighten2);
  align-items: center;
  text-align: center;
  overflow: hidden;
  padding: 8px;
  border-radius: 4px;
  cursor: pointer;
  height: 28px;
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
}
.export-icon {
  color: #1f3c73;
}
.export-button {
  margin-top: 25px;
  color: #1f3c73;
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
  opacity: 0.6;
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
  font-family: 'Roboto Condensed', sans-serif;
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

  th,
  td {
    font-family: 'Roboto Condensed', sans-serif;
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
        margin: 2px;
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


@media (min-width: 500px) {
  #closer-dash-toolbar-container
    #closer-dash-toolbar
    .v-toolbar
    .v-toolbar__content
    .v-toolbar__title {
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
    th,
    td {
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
    max-width: calc(100% - 50px);
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
#closer-funnel-table
  > div
  > table
  > thead
  > tr
  > th.text-start.milestone-col-th,
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
</style>
}

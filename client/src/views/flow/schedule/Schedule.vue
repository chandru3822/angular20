<template>
  <v-container id="schedule-container" class="py-0">
    <v-row class="map-row">
      <v-col cols="12" md="5">
        <Map :latitude="state.mapLatitude" :markers="selectedRows" :longitude="state.mapLongitude"
             :zoom="state.mapZoom" :map-resources="mapResources"></Map>
      </v-col>
      <v-col cols="12" md="7" style="overflow: auto;">
        <!-- map-resources allows the calendar to send events back to the map -->
        <Calendar :map-resources="mapResources"
                  ref="calendar"
                  :states="states"
                  :callback="this.resourceMapCallback"
                  :date-callback="this.dateCallback"></Calendar>
      </v-col>
    </v-row>
    <v-row class="schedule-row">
      <v-col cols="12" md="5" class="py-0 schedule-row-filter-container">
        <v-card color="white" class="text-left py-0 square-card height-one-hunned">
          <v-card-actions v-if="!selectedProject || !selectedProject.projectId">
            <v-btn text @click="showFilters = true" :class="{underline: showFilters}">Filters</v-btn>
            <v-btn text @click="showFilters = false" :class="{underline: !showFilters}">Find Project</v-btn>
          </v-card-actions>
          <v-card-text v-if="showFilters && (!selectedProject || !selectedProject.projectId)"
                       class="filter-text-card">
            <v-autocomplete attach v-model="state"
                      :items="states"
                      label="State"
                      return-object
                            hide-details
                      item-text="state"
                      item-value="id"
            ></v-autocomplete>

            <v-autocomplete attach v-model="selectedEventTypes"
                      :items="eventTypes"
                      label="Event"
                      item-text="eventName"
                      item-value="id"
                      return-object
                            hide-details
                      clearable
                      :disabled="!state || !state.id"
                      multiple
            >
              <template
                  slot="selection"
                  slot-scope="{ item, index }"
              >
                <div v-if="index === 0 && selectedEventTypes.length < 3">
                  <v-chip small v-for="sp in selectedEventTypes">
                    <span>{{ sp.eventName }}</span>
                  </v-chip>
                </div>
                <span
                    v-if="index === 1 && selectedEventTypes.length >= 3"
                    class="primary--text text-caption"
                >{{ selectedEventTypes.length }} selected</span>
              </template>
            </v-autocomplete>

            <v-autocomplete v-model="selectedEventStatusType"
                      :items="eventStatusTypes"
                      label="Event Step Status"
                      clearable
                            hide-details
                      item-text="eventStatusType"
                      item-value="id"
                      :disabled="selectedEventTypes.length === 0"
                      return-object
            />

            <v-autocomplete v-model="selectedProcessStepStatusType"
                      :items="processStepStatusTypes"
                      label="Process Step Status"
                      clearable
                      hide-details
                      item-text="processStepStatusType"
                      item-value="id"
                      :disabled="selectedEventTypes.length === 0"
                      return-object
            />
            <v-btn color="primaryCustom" class="white--text schedule-row-go-button"
                   :disabled="!selectedEventTypes || selectedEventTypes.length === 0 || !state
                   || !selectedEventStatusType || !selectedEventStatusType.id
                   || !selectedProcessStepStatusType || !selectedProcessStepStatusType.id"
                   @click="getProjects(true)">Go</v-btn>
          </v-card-text>
          <v-card-text class="filter-text-card" v-else-if="!showFilters && (!selectedProject || !selectedProject.projectId)">
            <v-autocomplete v-model="searchProject"
                            :items="searchProjects"
                            :search-input.sync="search"
                            item-text="projectName"
                            :key="0"
                            prepend-icon="search"
                            text
                            hide-details
                            label="Search for project..."
                            autocomplete="off"
                            :loading="searchProjectsLoading"
                            item-value="projectId"
                            return-object
                            attach
                            >
              <template slot="item" slot-scope="data">
                <!-- HTML that describe how select should render items when the select is open -->
                {{ data.item.projectName }} - {{ data.item.projectId }}
              </template>
            </v-autocomplete>
            <v-select attach v-model="searchEventType"
                      :items="eventTypes"
                      label="Event"
                      hide-details
                      item-text="eventName"
                      item-value="id"
                      return-object
            >
            </v-select>
            <v-autocomplete v-model="searchEventStatusType"
                            :items="eventStatusTypes"
                            label="Event Step Status"
                            clearable
                            hide-details
                            item-text="eventStatusType"
                            item-value="id"
                            return-object
            />
            <v-select attach v-model="searchProcessStepStatusType"
                      :items="processStepStatusTypes"
                      label="Process Step Status"
                      hide-details
                      item-text="processStepStatusType"
                      item-value="id"
                      return-object
            >
            </v-select>
            <v-btn color="primaryCustom" class="white--text schedule-row-go-button"
                   :disabled="!searchProject || !searchProject.projectId
                        || !searchEventType.id" @click="getSingleProject(searchProject.projectId, searchEventType.id, searchEventStatusType.id, searchProcessStepStatusType.id)">Go</v-btn>
          </v-card-text>
          <v-card-text class="height-one-hunned" v-else>
            <v-toolbar color="white" flat id="schedule-project-toolbar">
              <v-toolbar-title class="app-title">
                {{selectedProject.projectName}}
                <div class="toolbar-subtitle">{{selectedProject.processStepName}}</div>
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-tooltip top v-if="$store.getters.userHasFeature('PROJECTS')">
                  <template v-slot:activator="{ on }">
                    <v-btn x-small text v-on="on"
                           target="_blank"
                           :to="`/project/${selectedProject.projectId}/details`"><v-icon>mdi-chevron-right</v-icon></v-btn>
                  </template>
                  <span>Go to Project</span>
                </v-tooltip>
                <v-tooltip top v-if="$store.getters.userHasFeature('PROCESS_STEPS')">
                  <template v-slot:activator="{ on }">
                    <v-btn x-small text v-on="on"
                           target="_blank"
                           :to="`/project/${selectedProject.projectId}/processStep/${selectedProject.projectProcessStepId}`">
                      <v-icon>mdi-chevron-double-right</v-icon>
                    </v-btn>
                  </template>
                  <span>Go to Process Step</span>
                </v-tooltip>
                <v-tooltip top v-if="$store.getters.userHasFeature('EVENTS')">
                  <template v-slot:activator="{ on }">
                    <v-btn x-small text v-on="on"
                           target="_blank"
                           :to="`/project/${selectedProject.projectId}/processStep/${selectedProject.projectProcessStepId}/event/${selectedProject.projectProcessStepEventId}`">
                      <v-icon>mdi-chevron-triple-right</v-icon>
                    </v-btn>
                  </template>
                  <span>Go to Event</span>
                </v-tooltip>
                <v-tooltip top>
                  <template v-slot:activator="{ on }">
                    <v-btn x-small text v-on="on" @click="selectedProject = {}"><v-icon>mdi-close</v-icon></v-btn>
                  </template>
                  <span>Close</span>
                </v-tooltip>
              </v-toolbar-items>
            </v-toolbar>
            <div class="px-3">
              <h4>{{selectedProject.eventName}}</h4>
              <DatetimePickerInput
                v-model="selectedProject.start"
                :timezone="this.timezone"
                hide-details
                :readonly="selectedProject.startFieldReadOnly || !userCanEdit || selectedProject.processStepStatusTypeId !== 1 || selectedProject.eventStatusTypeId !== 1"
                :type="'timestamp'"
                :format="'MMMM DD, YYYY, h:mm A'"
                label="Start Time"
                @input="validateSaveEvent()"
              />
              <DatetimePickerInput
                v-model="selectedProject.end"
                :timezone="this.timezone"
                :readonly="selectedProject.endFieldReadOnly || !userCanEdit || selectedProject.processStepStatusTypeId !== 1 || selectedProject.eventStatusTypeId !== 1"
                :type="'timestamp'"
                :format="'MMMM DD, YYYY, h:mm A'"
                label="End Time"
                hide-details
                @input="validateSaveEvent()"
              />
              <v-autocomplete v-model="selectedProject.resource"
                        :items="selectedProject.resources"
                        :label="selectedProject.resourceFieldName  || 'Resource'"
                        placeholder=" "
                        return-object
                        clearable
                              hide-details
                        item-text="name"
                        :readonly="selectedProject.resourceFieldReadOnly || !userCanEdit || selectedProject.processStepStatusTypeId !== 1 || selectedProject.eventStatusTypeId !== 1"
                        :disabled="selectedProject.resourceFieldReadOnly || !userCanEdit || selectedProject.processStepStatusTypeId !== 1 || selectedProject.eventStatusTypeId !== 1"
                        item-value="id"
                        @input="validateSaveEvent()"
              />
              <v-btn color="primaryCustom"
                     class="white--text schedule-row-go-button"
                     :disabled="fieldsSaving || saveInvalid || !userCanEdit || selectedProject.processStepStatusTypeId !== 1 || selectedProject.eventStatusTypeId !== 1"
                     @click="[fieldsSaving = true, scheduleProject()]">Save</v-btn>
              <v-dialog
                  v-if="selectedProject.eventStatusTypeId === 2"
                  v-model="selectedProject.unscheduleConfirm"
                  width="500">
                <template #activator="{ on }">
                  <v-btn color="secondaryCustom"
                         class="unschedule-button"
                         @click="getCancelledCompanyEventStatuses"
                         v-on="on">Unschedule Event</v-btn>
                </template>
                <v-card>
                  <v-card-title
                      class="text-h5 grey lighten-2"
                      primary-title>
                    Confirm
                  </v-card-title>

                  <v-card-text class="pt-4">
                    Are you sure you want to remove this event from the schedule? This will cancel the event.

                    <v-select attach :items="cancelledCompanyEventStatuses"
                              v-model="selectedProject.cancelledCompanyStatusType"
                              item-value="id"
                              return-object
                              label="Status to set this event to:"
                              item-text="eventStatusType"></v-select>

                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        @click="selectedProject.unscheduleConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                        :disabled="!selectedProject.cancelledCompanyStatusType || !selectedProject.cancelledCompanyStatusType.id"
                        color="primaryCustom"
                        text
                        @click="cancelProjectProcessStepEvent">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12" md="7" class="py-0 height-one-hunned">
        <div class="list-container">
          <div id="list-loader" v-if="listLoading">
            <v-progress-circular
              indeterminate
              :size="80"
              :color="'primaryCustom'"
            ></v-progress-circular>
          </div>
          <v-text-field
            v-model="projectFilter"
            @input="filterProjects()"
            @click:clear="filterProjects()"
            class="square-card"
            clearable
            prepend-inner-icon="search"
            label="Filter"
            solo
            hide-details
          ></v-text-field>
          <v-divider></v-divider>
          <v-data-table
              :headers="headers"
              :items="projects"
              fixed-header
              :mobile-breakpoint="0"
              :footer-props="footerProps"
              :options.sync="options"
              disable-sort
              v-model="selectedRows"
              :server-items-length="totalProjects"
              item-key="projectProcessStepEventId"
              :show-select="true"
              :item-selected="(item, value) => this.zoomToMap(item, value)"
              :toggle-select-all="(value) => this.zoomToMap(value)"
              class="elevation-1 square-card"
          >
            <template #no-data>
              No Results Found
            </template>

            <template #no-results>
              No results
            </template>

            <template #item.start="{ item }">
              {{item.start | formatDate('timestamp', 'MM/DD/YYYY')}}
            </template>

            <template #item.projectName="{ item }">
              <a @click="[getResources(item), selectedProject = item, selectedProject.resource = { id: item.resourceId, name: item.resourceName }]" style="text-decoration: underline">{{item.projectName}}</a>
            </template>

          </v-data-table>
        </div>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import { handleHidingGlobalLoader, postRequest, getSnackbar } from '@/helpers/helpers'
  import {getActiveStatesByHierarchy} from '@/services/stateService'
  import Map from './components/Map'
  import Calendar from './components/Calendar'
  import {getEventTypes} from '@/services/scheduleService'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import { getStatusTypes } from '@/services/processStepStatusTypeService'
  import axios from 'axios'
  import constants from "@/helpers/constants";
  import {
    getCancelledCompanyStatusTypesAssignedToPpsEvent,
    getEventStatusTypes
  } from "@/services/eventStatusTypeService";
  import debounce from 'lodash.debounce'

  export default {
    name: 'Schedule',
    components: {
      Map,
      Calendar,
      DatetimePickerInput
    },
    data() {
      return {
        initialLoad: true,
        snackbar: {},
        showFilters: true,
        listLoading: false,
        saveInvalid: true,
        timezone: this.$store.state.user.details.timezone.value,
        defaultZoom: 2.0,
        // they do these coordinates backwards to comply with geoJSON whatever that is.
        //center of the USA
        defaultCenter: [-98.5795, 39.8283],
        center: null,
        startTime: null,
        endTime: null,
        mapResources: [],
        selectedRows: [],
        selectedResources: [],
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('EVENTS', 'EDIT'),
        state: {},
        states: [],
        eventStatusTypes: [],
        selectedEventStatusType: {},
        processStepStatusTypes: [],
        selectedProcessStepStatusType: {},
        eventTypes: [],
        totalProjects: 0,
        //used for multi select
        selectedEventTypes: [],
        //used for single select
        selectedProject: {},
        cancelledCompanyEventStatuses: [],
        //used for search
        searchEventType: {},
        searchProcessStepStatusType: {},
        searchEventStatusType: {},
        searchProject: {},
        searchProjects: [],
        eventTypesChanged: false,
        searchProjectsLoading: false,
        search: null,
        fieldsSaving: false,
        asyncActions: {},
        headers: [
          {text: 'Project', value: 'projectName', show: true},
          {text: 'Process Step', value: 'processStepName', show: true},
          {text: 'Event', value: 'eventName', show: true},
          {text: 'Status', value: 'companyEventStatusType', show: true},
          {text: 'Work Date', value: 'start', show: true},
          {text: 'Resource', value: 'resourceName', show: true},
        ],
        projects: [],
        projectFilter: '',
        options: {
          itemsPerPage: 100
        },
        footerProps: {
          'items-per-page-options': [25, 50, 100],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        // masterProjects: []
      }
    },
    watch: {
      options: {
        handler() {
          if(!this.initialLoad) {
            this.getProjects()
          }
        }
      },
      search(val) {
        if(!val) {
          this.searchProject = {}
          return
        }
        if(val && (!this.searchProject || this.searchProject.projectName !== val)) {
          this.getProjectsSearchedFor(val);
        }
      },
      selectedProject() {
        this.validateSaveEvent()
      },
      startTime () {
        // this.getProjects()
      },
      endTime () {
        // this.getProjects()
      }
    },
    created() {
      this.state = JSON.parse(localStorage.getItem('scheduleState')) || {}
      this.selectedEventTypes = JSON.parse(localStorage.getItem('scheduleEventTypes')) || []
      this.selectedProcessStepStatusType = JSON.parse(localStorage.getItem('scheduleProcessStepStatusType')) || {}
      this.selectedEventStatusType = JSON.parse(localStorage.getItem('scheduleEventStatusType')) || {}
      this.getActiveStatesByHierarchy()
      this.getStatusTypes()
      this.getEventStatusTypes()
      this.getEventTypes()
      if(this.$route.query && this.$route.query.projectProcessStepEventId) {
        //projectId, eventId, processStepStatusTypeId
        this.getSingleProject(null, null, null,null, parseInt(this.$route.query.projectProcessStepEventId))
      }
    },
    methods: {
      getCancelledCompanyEventStatuses: async function () {
        try {
          const {data} = await getCancelledCompanyStatusTypesAssignedToPpsEvent(this.selectedProject.projectProcessStepId, this.selectedProject.projectProcessStepEventId)
          this.cancelledCompanyEventStatuses = data
          if(data?.length === 1) {
            this.selectedProject.cancelledCompanyStatusType = data[0]
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching process step statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.fetchingSteps = false
        }
      },
      validateSaveEvent () {
        if(!this.selectedProject || !this.selectedProject.start || !this.selectedProject.end
          || !this.selectedProject.resource || !this.selectedProject.resource.id || (this.selectedProject.start >= this.selectedProject.end) ||
          //if all 3 fields are read only, dont let them save
          (this.selectedProject.startFieldReadOnly && this.selectedProject.endFieldReadOnly && this.selectedProject.resourceFieldReadOnly)) {
          this.saveInvalid = true
        } else {
          this.saveInvalid = false
        }
      },
      async scheduleProject() {
        this.selectedProject.resourceId = this.selectedProject.resource.id
        this.selectedProject.resourceName = this.selectedProject.resource.name
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await postRequest(`/schedule/saveEvent`, this.selectedProject)
          // this tells the calendar to reload the events after a save (probably could just push the result into the existing records somehow but that was way harder)
          this.$refs.calendar.getEvents(false, true)
          handleHidingGlobalLoader(this, status)
          this.fieldsSaving = false
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Scheduled Project')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Scheduling Project')
          this.fieldsSaving = false
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async cancelProjectProcessStepEvent() {
        try {
          const {status} = await postRequest(`/projectProcessStep/${this.selectedProject.projectProcessStepId}/event/${this.selectedProject.projectProcessStepEventId}/status`, this.selectedProject.cancelledCompanyStatusType)
          // this.selectedProject.unscheduleConfirm = false
          this.projects = this.projects.filter(p => p.projectProcessStepEventId !== this.selectedProject.projectProcessStepEventId)
          this.selectedProject.eventStatusTypeId = this.selectedProject?.cancelledCompanyStatusType?.id
          handleHidingGlobalLoader(this, status)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Unscheduled Event')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Unscheduling Event')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goTo (ps, isProject, isProcessStep) {
        if (isProject) {
          this.$router.push({name: 'projectDetails', params: {projectId: ps.projectId}})
        } else if (isProcessStep) {
          this.$router.push({name: 'projectProcessStep', params: {projectId: ps.projectId, processStepId: ps.projectProcessStepId}, query: { processStepId: ps.processStepId, contactId: ps.contactId }})
        }
      },
      resourceMapCallback (newValue) {
        this.mapResources = newValue
      },
      dateCallback (startTime, endTime) {
        this.startTime = startTime
        this.endTime = endTime
      },
      async getActiveStatesByHierarchy() {
        try {
          const {data} = await getActiveStatesByHierarchy()
          this.states = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getEventTypes() {
        try {
          // 'event types' is just schedulable process steps
          const {data} = await getEventTypes()
          this.eventTypes = data
          if(this.eventTypes?.length > 0) {
            this.selectedEventTypes = this.selectedEventTypes.filter(set => {
              return this.eventTypes.some(et => et.id === set.id)
            })
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getEventStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getEventStatusTypes()
          this.eventStatusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getStatusTypes() {
        try {
          //the old way
          // const {data} = await getCompanyStatusTypes()
          // //only show active and complete
          // this.processStepStatusTypes = data.filter(d => d.processStepStatusTypeId !== 3)

          //the new way - use root statuses
          const {data} = await getStatusTypes()
          //only show active and complete
          this.processStepStatusTypes = data?.filter(d => d.id !== 3)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Status Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getResources(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          item.resources = []

          let params = {
            companyId: item.companyId,
            systemListId: item.systemListId,
            systemListOptionIds: item.systemListOptionIds,
            resourceId: item.resourceId
          }
          const {data, status} = await postRequest(`/schedule/projectResources`, params, null, [])
          item.resources = data || []
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Resources')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterProjects: debounce(function () {
        //dont run if the other filters aren't filled in
        if(this.selectedEventTypes && this.selectedEventTypes.length > 0 &&
          this.state && this.selectedEventStatusType && this.selectedEventStatusType.id &&
          this.selectedProcessStepStatusType && this.selectedProcessStepStatusType) {

          //don't allow projectFilter to be null - causes issues
          this.projectFilter = this.projectFilter || ''
          this.getProjects()

        }
      }, 500),
      async getProjects(resetQuery) {
        if(resetQuery) {
          // todo: should we remove this.$route.query params if the button is clicked?
          // this.$route.query = {}
        }

        const {page, itemsPerPage} = this.options

        localStorage.setItem('scheduleState', JSON.stringify(this.state))
        localStorage.setItem('scheduleEventTypes', JSON.stringify(this.selectedEventTypes))
        localStorage.setItem('scheduleProcessStepStatusType', JSON.stringify(this.selectedProcessStepStatusType))
        localStorage.setItem('scheduleEventStatusType', JSON.stringify(this.selectedEventStatusType))

        if(this.selectedEventTypes?.length > 0) {
          this.listLoading = true
          try {
            if(this.source){
              this.source.cancel();
            }
            const CancelToken = axios.CancelToken;
            this.source = CancelToken.source();

            const {data} = await postRequest(`/schedule/projects`, {
              search: this.projectFilter,
              source: this.source,
              cancelToken: this.source.token,
              eventIds: this.selectedEventTypes?.length > 0 ? this.selectedEventTypes.map(o => o.id) : [],
              //old way
              // processStepStatusTypeId: this.selectedProcessStepStatusType.processStepStatusTypeId,
              // new way:
              processStepStatusTypeId: this.selectedProcessStepStatusType.id,
              eventStatusTypeId: this.selectedEventStatusType.id,
              companyStateId: this.state.id,
              startTime: this.startTime,
              endTime: this.endTime,
              page: page - 1,
              size: itemsPerPage
            })
            this.projects = data.content || []
            this.projects.forEach(d => {
              d.coordinates = [ d.longitude, d.latitude ]
            })
            this.totalProjects = data.totalElements
            this.listLoading = false
            this.initialLoad = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Projects')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.listLoading = false
          }
        } else {
          this.projects = []
        }
      },
      async searchForProjects(search) {
        try {
          let params = {
            search
          }
          const {data} = await postRequest(`/schedule/projects/search`, params)
          this.searchProjects = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Searching Projects')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getProjectsSearchedFor(search) {
        // cancel pending call
        clearTimeout(this._timerId);

        this.searchProjectsLoading = true

        // delay new call 500ms
        this._timerId = setTimeout(async () => {
          //todo:_this
          await this.searchForProjects(search)
          this.searchProjectsLoading = false
        }, 500)
      },
      async getSingleProject(projectId, eventId, eventStatusTypeId, processStepStatusTypeId, projectProcessStepEventId) {
        this.listLoading = true
        try {
          let params = {
            projectId,
            eventId,
            processStepStatusTypeId,
            projectProcessStepEventId,
            eventStatusTypeId
          }

          //"getProject" is a bad term for this endpoint. it really returns a specific event with some project details
          const {data} = await postRequest(`/schedule/getProject`, params, null, [])
          this.projects = data
          this.projects.forEach(d => {
            d.coordinates = [ d.longitude, d.latitude ]
          })

          this.totalProjects = this.projects.length

          if(this.projects.length === 1) {
            this.selectedProject = this.projects[0]
            this.selectedProject.resource = { id: this.selectedProject.resourceId, name: this.selectedProject.resourceName }
          }
          this.listLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Project Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.listLoading = false
        }
      },

    },
    zoomToMap(item) {
      console.log('ZOOM ITEM', item)
    }
  }
</script>

<style lang="scss">
  #schedule-container .v-data-table__wrapper {
    height: calc(40vh - 118px);
    //this is smaller because it is the inner wrapper of the table
    min-height: 211px;
  }

  #schedule-container .v-data-footer__pagination {
    display: none !important;
  }

  #schedule-container .v-data-table td {
    height: 30px;
  }

  #schedule-project-toolbar .v-toolbar__content {
    padding: 4px 0 !important;
  }

  .map-field-input {
    border-bottom: solid 1px rgba(0, 0, 0, 0.42);
  }
</style>

<style lang="scss" scoped>
  .map-row {
    height: 60%;
    min-height: 300px;
  }

  .schedule-row {
    height: calc(40% - 10px);
    min-height: 300px;
  }

  .schedule-row-filter-container {
    height: 100%;
    position: relative;
  }

  .filter-text-card {
    padding-top: 0 !important;
    display: flex;
    flex-direction: column;
    height: calc(100% - 90px);
  }

  .schedule-row-go-button {
    position: absolute;
    bottom: 10px;
  }

  .unschedule-button {
    position: absolute;
    bottom: 10px;
    right: 25px;
  }

  .map-field-label {
    font-size: 12px;
    color: var(--v-primaryCustom-base);
  }

  .list-container {
    position: relative;
    background-color: white;
  }

  #list-loader {
    height: 100%;
    width: 100%;
    position: absolute;
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    margin: auto;
    background-color: var(--v-secondary-base);
    opacity: .5;
  }
</style>


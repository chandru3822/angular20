<template>
  <v-container id="schedule-container">
    <v-row>
      <v-col cols="12" md="5" class="map-row">
        <Map :latitude="state.mapLatitude" :markers="selectedRows" :longitude="state.mapLongitude"
             :zoom="state.mapZoom" :map-resources="mapResources"></Map>
      </v-col>
      <v-col cols="12" md="7" class="map-row" style="overflow: auto;">
        <!-- map-resources allows the calendar to send events back to the map -->
        <Calendar :map-resources="mapResources"
                  ref="calendar"
                  :states="states"
                  :callback="this.resourceMapCallback"
                  :date-callback="this.dateCallback"></Calendar>
      </v-col>
    </v-row>
    <v-row class="schedule-row">
      <v-col cols="12" md="5" class="py-0">
        <v-card color="white" class="text-left py-0">
          <v-card-actions v-if="!selectedProject || !selectedProject.projectId">
            <v-btn text @click="showFilters = true" :class="{underline: showFilters}">Filters</v-btn>
            <v-btn text @click="showFilters = false" :class="{underline: !showFilters}">Find Project</v-btn>
          </v-card-actions>
          <v-card-text v-if="showFilters && (!selectedProject || !selectedProject.projectId)" class="pt-0">
            <v-select v-model="state"
                      :items="states"
                      label="State"
                      return-object
                      item-text="state"
                      item-value="id"
            ></v-select>

            <v-select v-model="selectedEventTypes"
                      :items="eventTypes"
                      label="Event Type"
                      item-text="eventType"
                      item-value="id"
                      return-object
                      :disabled="!state || !state.id"
                      multiple
            >
              <v-list-item
                  slot="prepend-item"
                  ripple
                  @click="toggleSelectAllSteps()"
              >
                <v-list-item-action>
                  <v-icon>{{ icon }}</v-icon>
                </v-list-item-action>
                <v-list-item-title>Select All</v-list-item-title>
              </v-list-item>
              <v-divider
                  slot="prepend-item"
                  class="mt-2"
              ></v-divider>
              <template
                  slot="selection"
                  slot-scope="{ item, index }"
              >
                <div v-if="index === 0 && selectedEventTypes.length < 3">
                  <v-chip small v-for="sp in selectedEventTypes">
                    <span>{{ sp.eventType }}</span>
                  </v-chip>
                </div>
                <span
                    v-if="index === 1 && selectedEventTypes.length >= 3"
                    class="primary--text caption"
                >{{ selectedEventTypes.length }} selected</span>
              </template>
            </v-select>

            <v-select v-model="selectedProcessStepStatusTypes"
                      :items="processStepStatusTypes"
                      label="Status"
                      item-text="processStepStatusType"
                      item-value="id"
                      :disabled="selectedEventTypes.length === 0"
                      return-object
                      multiple
                      @input="filterProjects"
            >
              <template
                  slot="selection"
                  slot-scope="{ item, index }"
              >
                <div v-if="index === 0 && selectedProcessStepStatusTypes.length < 3">
                  <v-chip small v-for="sp in selectedProcessStepStatusTypes">
                    <span>{{ sp.processStepStatusType }}</span>
                  </v-chip>
                </div>
                <span
                    v-if="index === 1 && selectedProcessStepStatusTypes.length >= 3"
                    class="primary--text caption"
                >{{ selectedProcessStepStatusTypes.length }} selected</span>
              </template>
            </v-select>
            <v-btn dark color="primary" @click="getProjects(true)">Go</v-btn>
          </v-card-text>
          <v-card-text v-else-if="!showFilters && (!selectedProject || !selectedProject.projectId)">
            <v-autocomplete v-model="searchProject"
                            :items="searchProjects"
                            :search-input.sync="search"
                            item-text="projectName"
                            prepend-icon="search"
                            text
                            label="Search for project..."
                            autocomplete="off"
                            :loading="searchProjectsLoading"
                            item-value="id"
                            return-object
                            >

            </v-autocomplete>
            <v-select v-model="searchEventType"
                      :items="eventTypes"
                      label="Event Type"
                      item-text="eventType"
                      item-value="id"
                      return-object
            >
            </v-select>
            <v-select v-model="searchProcessStepStatusType"
                      :items="processStepStatusTypes"
                      label="Status"
                      item-text="processStepStatusType"
                      item-value="id"
                      return-object
            >
            </v-select>
            <v-btn color="primary" class="white--text" :disabled="!searchProject.projectId || !searchEventType.id" @click="getSingleProject(searchProject.projectId, searchEventType.id, searchProcessStepStatusType.id)">Go</v-btn>
          </v-card-text>
          <v-card-text v-else>
            <v-toolbar color="white" flat>
              <v-toolbar-title class="app-title">
                {{selectedProject.contactFirstName}} {{selectedProject.contactLastName}}
                <div class="toolbar-subtitle">{{selectedProject.processStepName}}</div>
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-tooltip top>
                  <template v-slot:activator="{ on }">
                    <v-btn x-small text v-on="on" @click="goTo(selectedProject, true, false)"><v-icon>mdi-chevron-right</v-icon></v-btn>
                  </template>
                  <span>Go to Project</span>
                </v-tooltip>
                <v-tooltip top>
                  <template v-slot:activator="{ on }">
                    <v-btn x-small text v-on="on" @click="goTo(selectedProject, false, true)"><v-icon>mdi-chevron-double-right</v-icon></v-btn>
                  </template>
                  <span>Go to Process Step</span>
                </v-tooltip>
                <v-tooltip top>
                  <template v-slot:activator="{ on }">
                    <v-btn x-small text v-on="on" @click="selectedProject = {}"><v-icon>mdi-close</v-icon></v-btn>
                  </template>
                  <span>Close</span>
                </v-tooltip>
              </v-toolbar-items>
            </v-toolbar>
            <div class="pa-3">
              <div class="map-field-label">{{selectedProject.startFieldName || 'Start Time'}}</div>
              <DatetimePickerInput
                v-model="selectedProject.start"
                :timezone="this.timezone"
                :readonly="selectedProject.startFieldReadOnly"
                :type="'timestamp'"
                :format="'MMMM DD, YYYY, h:mm A'"
                label="Start Time"
                @input="validateSaveEvent()"
              />
              <div class="map-field-label mt-3">{{selectedProject.endFieldName || 'End Time'}}</div>
              <DatetimePickerInput
                v-model="selectedProject.end"
                :timezone="this.timezone"
                :readonly="selectedProject.endFieldReadOnly"
                :type="'timestamp'"
                :format="'MMMM DD, YYYY, h:mm A'"
                label="End Time"
                @input="validateSaveEvent()"
              />
              <v-select v-model="selectedProject.resource"
                        :items="selectedProject.resources"
                        :label="selectedProject.resourceFieldName  || 'Resource'"
                        placeholder=" "
                        return-object
                        item-text="name"
                        :readonly="selectedProject.resourceFieldReadOnly"
                        :disabled="selectedProject.resourceFieldReadOnly"
                        item-value="id"
                        class="mt-3"
                        @input="validateSaveEvent()"
              />
              <v-btn color="primary"
                     class="white--text"
                     :disabled="saveInvalid"
                     @click="scheduleProject">Save</v-btn>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12" md="7" class="py-0">
        <div class="list-container">
          <div id="list-loader" v-if="listLoading">
            <v-progress-circular
              indeterminate
              :size="80"
              :color="'primary'"
            ></v-progress-circular>
          </div>
          <v-data-table
              :headers="headers"
              :items="projects"
              :fixed-header="true"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              v-model="selectedRows"
              item-key="projectProcessStepId"
              hide-default-footer
              :show-select="true"
              :item-selected="(item, value) => addToMap(item, value)"
              :toggle-select-all="(value) => addToMap(value)"
              class="elevation-1"
          >
            <template #no-data>
              No Results Found
            </template>

            <template #no-results>
              No results
            </template>

            <template #item.start="{ item }">
              {{item.start | formatDate('date')}}
            </template>

            <template #item.projectName="{ item }">
              <a @click="[selectedProject = item, selectedProject.resource = { id: item.resourceId, name: item.resourceName }]" style="text-decoration: underline">{{item.projectName}}</a>
            </template>

          </v-data-table>
        </div>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import {getActiveStatesByHierarchy} from '@/services/stateService'
  import Map from './components/Map'
  import {getEventTypes} from '@/services/scheduleService'
  import cloneDeep from 'lodash.clonedeep'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getStatusTypes} from '@/services/processStepStatusTypeService'

  import Calendar from './components/Calendar'

  export default {
    name: 'Schedule',
    components: {
      Snackbar,
      Map,
      Calendar,
      DatetimePickerInput
    },
    data() {
      return {
        snackbar: {},
        showFilters: true,
        listLoading: false,
        saveInvalid: true,
        timezone: this.$store.state.user.details.timezone.value,
        // showFilters: false,
        defaultZoom: 2.0,
        map: {
          accessToken: '***REMOVED***',
          style: 'mapbox://styles/mapbox/streets-v10'
        },
        // they do these coordinates backwards to comply with geoJSON whatever that is.
        //center of the USA
        defaultCenter: [-98.5795, 39.8283],
        center: null,
        startTime: null,
        endTime: null,
        mapResources: [],
        selectedRows: [],
        selectedResources: [],
        state: {},
        states: [],
        processStepStatusTypes: [],
        selectedProcessStepStatusTypes: [],
        eventTypes: [],
        //used for multi select
        selectedEventTypes: [],
        //used for single select
        selectedProject: {},
        //used for search
        searchEventType: {},
        searchProcessStepStatusType: {},
        searchProject: {},
        searchProjects: [],
        eventTypesChanged: false,
        searchProjectsLoading: false,
        search: null,
        asyncActions: {},
        headers: [
          {text: 'Project', value: 'projectName', show: true},
          {text: 'Process Step', value: 'processStepName', show: true},
          {text: 'Status', value: 'processStepStatusType', show: true},
          {text: 'Work Date', value: 'start', show: true},
          {text: 'Resource', value: 'resourceName', show: true},
        ],
        projects: [],
        masterProjects: []
      }
    },
    computed: {
      selectAll () {
        return this.selectedEventTypes.length === this.eventTypes.length
      },
      selectSome () {
        return this.selectedEventTypes.length > 0 && !this.selectAll
      },
      icon () {
        if (this.selectedEventTypes && this.eventTypes && this.selectedEventTypes.length === this.eventTypes.length) {
          return 'check_box'
        }
        if (this.selectSome) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      }
    },
    watch: {
      search(val) {
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
      this.getActiveStatesByHierarchy()
      this.getStatusTypes()
      this.getEventTypes()
      if(this.$route.query && this.$route.query.processStepId && this.$route.query.projectId) {
        this.getSingleProject(parseInt(this.$route.query.projectId), parseInt(this.$route.query.processStepId))
      }
    },
    methods: {
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
          const {data} = await postRequest(`/schedule/saveEvent`, this.selectedProject)
          // this tells the calendar to reload the events after a save (probably could just push the result into the existing records somehow but that was way harder)
          this.$refs.calendar.getEvents()
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Scheduled Project')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Scheduling Project')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goTo (ps, isProject, isProcessStep) {
        if (isProject) {
          this.$router.push({name: 'projectOverview', params: {projectId: ps.projectId}})
        } else if (isProcessStep) {
          this.$router.push({name: 'projectProcessStep', params: {projectId: ps.projectId, processStepId: ps.projectProcessStepId}})
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
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getActiveStatesByHierarchy()
          this.states = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getEventTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          // 'event types' is just schedulable process steps
          const {data} = await getEventTypes()
          this.eventTypes = data
          this.selectedEventTypes = this.selectedEventTypes.filter(set => {
            return this.eventTypes.some(et => et.id === set.id)
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getStatusTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getStatusTypes()
          this.processStepStatusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Status Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },

      async getProjects(resetQuery) {
        if(resetQuery) {
          // todo: should we remove this.$route.query params if the button is clicked?
          // this.$route.query = {}
        }
        localStorage.setItem('scheduleState', JSON.stringify(this.state))
        localStorage.setItem('scheduleEventTypes', JSON.stringify(this.selectedEventTypes))

        if(this.selectedEventTypes?.length > 0) {
          this.listLoading = true
          try {
            let params = {
              eventTypeIds: this.selectedEventTypes?.length > 0 ? this.selectedEventTypes.map(o => o.id) : [],
              stateId: this.state.id,
              startTime: this.startTime,
              endTime: this.endTime
            }

            const {data} = await postRequest(`/schedule/projects`, params)
            data.forEach(d => {
              d.coordinates = [ d.longitude, d.latitude ]
            })
            this.projects = data
            this.masterProjects = cloneDeep(data)
            if(this.selectedProcessStepStatusTypes?.length > 0) {
              this.filterProjects()
            }
            this.listLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Projects')
            this.listLoading = false
          }
        } else {
          this.projects = []
          this.masterProjects = []
        }
      },
      filterProjects () {
        let statusIds = this.selectedProcessStepStatusTypes.map(st => st.processStepStatusTypeId)
        if(statusIds?.length === 0) {
          this.projects = cloneDeep(this.masterProjects)
        } else {
          this.projects = this.masterProjects.filter(p => {
            return statusIds.includes(p.processStepStatusTypeId)
          })
        }
      },
      toggleSelectAllSteps () {
        this.$nextTick(() => {
          if (this.selectAll) {
            this.selectedEventTypes = []
          } else {
            this.selectedEventTypes = cloneDeep(this.eventTypes)
          }
        })
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
      async getSingleProject(projectId, eventTypeId, processStepStatusTypeId) {
        this.listLoading = true
        try {
          let params = {
            projectId,
            eventTypeId,
            processStepStatusTypeId
            // i dont think we need this for finding specific projects
            // startTime: this.startTime,
            // endTime: this.endTime
          }

          const {data} = await postRequest(`/schedule/getProject`, params)
          data.forEach(d => {
            d.coordinates = [ d.longitude, d.latitude ]
          })
          this.projects = data
          if(this.projects.length === 1) {
            this.selectedProject = this.projects[0]
          }
          this.listLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Project Details')
          this.listLoading = false
        }
      },

    }
  }
</script>

<style lang="scss">
  #schedule-container .v-data-table__wrapper {
    height: calc(35vh);
    min-height: 300px;
  }

  #schedule-container .v-data-table td {
    height: 30px;
  }

  .map-field-input {
    border-bottom: solid 1px rgba(0, 0, 0, 0.42);
  }
</style>

<style lang="scss" scoped>
  .map-row {
    min-height: 300px;
  }



  .schedule-row {
    /*height: 40vh;*/
    min-height: 300px;
  }

  .map-field-label {
    font-size: 12px;
    color: var(--v-primary-base);
  }

  .list-container {
    position: relative;
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

  @media (min-width: 769px) {
    .map-row {
      height: calc(65vh - 95px);
      min-height: 200px;
    }
  }
</style>


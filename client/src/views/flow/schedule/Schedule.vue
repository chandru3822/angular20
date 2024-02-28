<template>
  <component :is="activeComp"
             id="schedule-container"
             :header-hidden="true"
             :right-hidden="!showMap"
             :left-hidden="true"
             :auto-overflow-left="true"
             :useRightPanelMobile="true"
             :right-open="showMap"
  >
    <template v-slot:main-column>
      <v-btn id="map-btn" v-if="!showMap" fab tile absolute right color="primary" class="mt-4 mb-n1" @click="showMap = !showMap"><v-icon>mdi-map</v-icon></v-btn>
    <Calendar :map-resources="mapResources"
              ref="calendar"
              :preselected-event="selectedProject"
              :states="states"
              :callback="resourceMapCallback"
              :date-callback="dateCallback"/>
      <ProjectModal :project="selectedProject" :timezone="timezone"  @toggleProjectMapPin="toggleSelectedProjectMapPin()"/>
    </template>
    <template v-slot:right-column>
      <v-row class="map-row">
        <v-col cols="12" class="pa-0 ml-3">
          <Map v-if="showMap"
               :latitude="latitude"
               :current-project-marker="selectedProject"
               :markers="projectMapMarkers"
               :longitude="longitude"
               :zoom="mapZoom"
               :map-resources="mapResources"
               :start-time="startTime"
               :end-time="endTime"
               @close-map="showMap = false"
          >
            <template v-slot:searchMenu>
              <v-btn id="search-menu-btn" fab tile outlined @click="[searchMenuOpen = !searchMenuOpen, menuOpen = false]" small color="primary" class="rounded-tile-btn white-background"><v-icon>mdi-magnify</v-icon></v-btn>
              <ProjectSearchDialog v-show="searchMenuOpen" :pin-to-map-callback="projectMapMarkersCallback"  :pinned-projects="projectMapMarkers"
                                   :states="states" :start-time="startTime" :end-time="endTime"
                                   @close-dialog="searchMenuOpen = false" @zoom-map="zoomToMap"/>
            </template>
          </Map>
        </v-col>
      </v-row>
    </template>
  </component>
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
  import constants from "@/helpers/constants";
  import {
    getCancelledCompanyStatusTypesAssignedToPpsEvent,
    getEventStatusTypes
  } from "@/services/eventStatusTypeService";
  import ThreeColumnLayout from "@/views/ThreeColumnLayout.vue";
  import ThreeColumnLayoutMobile from "@/views/ThreeColumnLayoutMobile.vue";
  import ProjectSearchDialog from "@/views/flow/schedule/components/ProjectSearchDialog.vue";
  import ProjectModal from "@/views/flow/schedule/components/ProjectModal.vue";

  export default {
    name: 'Schedule',
    components: {
      ProjectModal,
      ProjectSearchDialog,
      ThreeColumnLayout,
      ThreeColumnLayoutMobile,
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
        scheduleConflict: false,
        confirmSchedule: false,
        center: null,
        conflictingEvents: null,
        startTime: null,
        endTime: null,
        mapResources: [],
        projectMapMarkers: [],
        selectedResources: [],
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('EVENTS', 'EDIT'),
        state: {},
        mapZoom: null,
        latitude: null,
        longitude: null,
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
        searchMenuOpen: false,
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
        showMap: true
        // masterProjects: []
      }
    },
    computed: {
      activeComp() {
        return this.$vuetify.breakpoint.smAndDown ? 'ThreeColumnLayoutMobile' : 'ThreeColumnLayout'
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
      async checkForSchedulingConflicts(){
          this.scheduleProject(false);
      },
      async cancelDialog(){
        this.conflictingEvents = null
        this.fieldsSaving = false
        this.$refs.calendar.getEvents(false, true)
      },
      async scheduleProject(forceSave) {

        this.selectedProject.resourceId = this.selectedProject.resource.id
        this.selectedProject.resourceName = this.selectedProject.resource.name
        this.selectedProject.forceSave = forceSave
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await postRequest(`/schedule/saveEvent`, this.selectedProject)
          //if saved successfully then increase the "saveVersion" so they can make a 2nd change too
          this.selectedProject.saveVersion++
          // this tells the calendar to reload the events after a save (probably could just push the result into the existing records somehow but that was way harder)
          this.$refs.calendar.getEvents(false, true)
          handleHidingGlobalLoader(this, status)
          this.fieldsSaving = false
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Scheduled Project')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } catch (e) {
          if(e.status == 409){
            this.conflictingEvents = e.data;
            this.fieldsSaving = false
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
          else {
            console.error('*** ERROR ***', e)
            let saveMismatch = e.data?.message === 'Save Version Mismatch'
            let msg = saveMismatch ? 'Error Scheduling Project. This event has been update by another user. Please refresh to see the latest data.' : 'Error Scheduling Project'
            this.snackbar = getSnackbar('ERROR', msg)
            this.fieldsSaving = false
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
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
      resourceMapCallback (newValue, showMap) {
        this.mapResources = newValue
        if(newValue.length > 0){
          this.showMap = true
          let zoomObj = newValue[0]
          this.zoomToMap({latitude: zoomObj.coordinates[1], longitude: zoomObj.coordinates[0]})
        }
        else {
          this.resetMapZoom()
        }
      },
      projectMapMarkersCallback(newValue){
        this.projectMapMarkers = newValue
        this.showMap = true
        if(newValue.length > 0){
          this.zoomToMap(newValue[0], 8)
        }
      },
      toggleSelectedProjectMapPin(){
        this.selectedProject.pinned = !this.selectedProject.pinned
        if(this.selectedProject.pinned){
          this.zoomToMap({latitude: this.selectedProject.latitude, longitude: this.selectedProject.longitude})
        } else if(this.latitude === Math.trunc(this.selectedProject.latitude) && this.longitude === Math.trunc(this.selectedProject.longitude)) {
          this.resetMapZoom()
        }
      },
      dateCallback (startTime, endTime) {
        this.startTime = startTime
        this.endTime = endTime
      },

      async getSingleProject(projectId, eventId, eventStatusTypeId, processStepStatusTypeId, projectProcessStepEventId) {
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
          let project = data[0]
          project.coordinates = [ project.longitude, project.latitude ]
          project.pinned = false
            this.selectedProject = project
            this.selectedProject.resource = { id: this.selectedProject.resourceId, name: this.selectedProject.resourceName }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Project Details')
          store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
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

      resetMapZoom(){
        this.zoomToMap(
            {
              longitude: null,
              latitude: null,
            },
            2
        )
      },

      zoomToMap(item, zoomOverride) {
        if(item){
          this.mapZoom = zoomOverride ? zoomOverride : 6
          this.longitude = item.mapLongitude | item.longitude
          this.latitude = item.mapLatitude | item.latitude
        }
      }

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

  #map-btn {
    border-radius: 4px;
  }

  #schedule-project-toolbar .v-toolbar__content {
    padding: 4px 0 !important;
  }

  .map-field-input {
    border-bottom: solid 1px rgba(0, 0, 0, 0.42);
  }

  #find-drive-time > button.rounded-tile-btn.v-btn.v-btn--fab.v-btn--round.v-btn--tile  {
    border-radius: 4px;

    &.white-background {
      background-color: white;
    }
  }

  .project-search-card{
    position: relative;
    top:40px;
    right:38px;
  }
</style>

<style lang="scss" scoped>
  .map-row {
    height: 100%;
    min-height: 300px;
    max-width: 100%;
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
    color: var(--v-primary-base);
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


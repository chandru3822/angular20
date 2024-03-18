<template>
  <component :is="activeComp"
             id="schedule-container"
             :header-hidden="true"
             :right-hidden="!showMap"
             :left-hidden="true"
             :auto-overflow-left="true"
             :useRightPanelMobile="true"
             :right-open="showMap"
             :showRightCollapseBtn="false"
  >
    <template v-slot:main-column>
      <AlbatrossButton id="map-btn" v-if="!showMap" class="absolute-right" color="primary" size="small" :elevation="5" custom-classes="mt-4 mb-n1 px-4" @click="showHideMap(!showMap)"><v-icon>mdi-map</v-icon></AlbatrossButton>
    <Calendar :map-resources="mapResources"
              ref="calendar"
              :map-open="showMap"
              :preselected-event="selectedProject"
              :states="states"
              :callback="resourceMapCallback"
              :date-callback="dateCallback"
              @scheduleResource="scheduleResourceToCurrentProject"
              @unscheduleResource="calendarResourceToSchedule = {}"
    />
      <ProjectModal
          v-if="selectedProject.projectId"
          :project="selectedProject"
          :timezone="timezone"
          :resource-from-calendar="calendarResourceToSchedule"
          @toggleProjectMapPin="toggleSelectedProjectMapPin()"/>
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
               @close-map="showHideMap(false)"
          >
            <template v-slot:searchMenu>
              <AlbatrossButton id="search-menu-btn" class="rounded-tile-btn" variant="outlined" icon @click="[searchMenuOpen = !searchMenuOpen, menuOpen = false]" color="primary"><v-icon>mdi-magnify</v-icon></AlbatrossButton>
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

<script setup>
  import {AppMutations} from '@/stores/AppStore'
  import { postRequest, getSnackbar } from '@/helpers/helpers'
  import {getActiveStatesByHierarchy} from '@/services/stateService'
  import Map from './components/Map'
  import Calendar from './components/Calendar'
  import {getEventTypes} from '@/services/scheduleService'
  import { getStatusTypes } from '@/services/processStepStatusTypeService'
  import constants from "@/helpers/constants";
  import { getEventStatusTypes } from "@/services/eventStatusTypeService";
  import ThreeColumnLayout from "@/views/ThreeColumnLayout.vue";
  import ThreeColumnLayoutMobile from "@/views/ThreeColumnLayoutMobile.vue";
  import ProjectSearchDialog from "@/views/flow/schedule/components/ProjectSearchDialog.vue";
  import ProjectModal from "@/views/flow/schedule/components/ProjectModal.vue";
  import {ScheduleActions, ScheduleMutations} from "@/stores/ScheduleStore.js";
  import {computed, getCurrentInstance, onMounted, ref, watch} from "vue";
  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const router = vueInstance.$router
  const route = vueInstance.$route
  const vuetify = vueInstance.$vuetify

  const snackbar = ref({})
  const saveInvalid = ref(true)
  const timezone = ref(null)
  const startTime = ref(null)
  const endTime = ref(null)
  const mapResources = ref([])
  const projectMapMarkers = ref([])
  const userCanEdit = ref(store.getters.userHasFeatureAccessLevel('EVENTS', 'EDIT'))
  const state = ref({})
  const mapZoom = ref(null)
  const latitude = ref(null)
  const longitude = ref(null)
  const states = ref([])
  const eventStatusTypes = ref([])
  const processStepStatusTypes = ref([])
  const eventTypes = ref([])
  //used for multi select
  const selectedEventTypes = ref([])
  //used for single select
  const selectedProject = ref({})
  //used for search
  const searchMenuOpen = ref(false)
  const search = ref(null)
  // const fieldsSaving = ref(false)
  const projects = ref([])
  const options = ref({
    itemsPerPage: 100
  })
  const footerProps = ref({
    'items-per-page-options': [25, 50, 100],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
  })
  const calendarResourceToSchedule =ref({})

  const activeComp = computed(() => {
    return vuetify.breakpoint.smAndDown ? ThreeColumnLayoutMobile : ThreeColumnLayout
  })
  const showMap = computed(() => {
    return store.state.schedule.showMap
  })

  watch(selectedProject, () => {
        validateSaveEvent()
  })

    onMounted(() => {
      loadTimezone()
      fetchActiveStatesByHierarchy()
      fetchStatusTypes()
      fetchEventStatusTypes()
      fetchEventTypes()
      if(route.query && route.query.projectProcessStepEventId) {
        //projectId, eventId, processStepStatusTypeId
        getSingleProject(null, null, null,null, parseInt(route.query.projectProcessStepEventId), true)

      }
    })

  const loadTimezone = () => {
        if(store.state.schedule.timezone?.value === null) {
          timezone.value = store.state.user.details.timezone
          updateTimezone()
        }
        else {
          timezone.value = store.state.user.details.timezone
        }
      }
  const updateTimezone = () => {
        store.dispatch(ScheduleActions.CHANGE_TIMEZONE, timezone.value)
      }
      const showHideMap = (show)=> {
        if(show !== showMap.value) {
          store.commit(ScheduleMutations.SHOW_HIDE_MAP)
        }
      }
      const validateSaveEvent =  () => {
        if(!selectedProject.value || !selectedProject.value.start || !selectedProject.value.end
          || !selectedProject.value.resource || !selectedProject.value.resource.id || (selectedProject.value.start >= selectedProject.value.end) ||
          //if all 3 fields are read only, dont let them save
          (selectedProject.value.startFieldReadOnly && selectedProject.value.endFieldReadOnly && selectedProject.value.resourceFieldReadOnly)) {
          saveInvalid.value = true
        } else {
          saveInvalid.value = false
        }
      }
      const resourceMapCallback =  (newValue) => {
        mapResources.value = newValue
        if(newValue.length > 0){
          showHideMap(true)
          let zoomObj = newValue[0]
          zoomToMap({latitude: zoomObj.coordinates[1], longitude: zoomObj.coordinates[0]})
        }
        else {
          resetMapZoom()
        }
      }
      const projectMapMarkersCallback = (newValue)=> {
        projectMapMarkers.value = newValue
        showHideMap(true)
        if(newValue.length > 0){
          zoomToMap(newValue[0], 8)
        }
      }
      const toggleSelectedProjectMapPin = (onload)=> {
        selectedProject.value.pinned = !selectedProject.value.pinned
        if(selectedProject.value.pinned && !onload){
          showHideMap(true)
          zoomToMap({latitude: selectedProject.value.latitude, longitude: selectedProject.value.longitude})
        } else if(latitude.value === Math.trunc(selectedProject.value.latitude) && longitude.value === Math.trunc(selectedProject.value.longitude)) {
          resetMapZoom()
        }
      }
      const dateCallback =  (start, end) => {
        startTime.value = start
        endTime.value = end
      }

      const scheduleResourceToCurrentProject = (resource)=> {
        calendarResourceToSchedule.value = resource
      }

      const getSingleProject = async(projectId, eventId, eventStatusTypeId, processStepStatusTypeId, projectProcessStepEventId, onLoad) => {
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
            selectedProject.value = project
          if(onLoad === true){
            toggleSelectedProjectMapPin(onLoad)
          }
          store.commit(ScheduleMutations.SET_SELECTED_RESOURCE_ID, project.resourceId)
          selectedProject.value.resource = { id: selectedProject.value.resourceId, name: selectedProject.value.resourceName }
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Loading Project Details')
          store.commit(AppMutations.SHOW_SNACK, snackbar.value)
        }
      }

      const fetchActiveStatesByHierarchy = async() =>  {
        try {
          const {data} = await getActiveStatesByHierarchy()
          states.value = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Retrieving States')
          store.commit(AppMutations.SHOW_SNACK, snackbar.value)
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const fetchEventTypes = async() =>  {
        try {
          // 'event types' is just schedulable process steps
          const {data} = await getEventTypes()
          eventTypes.value = data
          if(eventTypes.value?.length > 0) {
            selectedEventTypes.value = selectedEventTypes.value.filter(set => {
              return eventTypes.value.some(et => et.id === set.id)
            })
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Retrieving Event Types')
          store.commit(AppMutations.SHOW_SNACK, snackbar.value)
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const fetchEventStatusTypes = async() => {
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getEventStatusTypes()
          eventStatusTypes.value = data
          store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Retrieving Data')
          store.commit(AppMutations.SHOW_SNACK, snackbar.value)
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const fetchStatusTypes = async() =>  {
        try {
          //the old way
          // const {data} = await getCompanyStatusTypes()
          // //only show active and complete
          // processStepStatusTypes.value = data.filter(d => d.processStepStatusTypeId !== 3)

          //the new way - use root statuses
          const {data} = await getStatusTypes()
          //only show active and complete
          processStepStatusTypes.value = data?.filter(d => d.id !== 3)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Retrieving Status Types')
          store.commit(AppMutations.SHOW_SNACK, snackbar.value)
          store.commit(AppMutations.SET_LOADING, false)
        }
      }

      const resetMapZoom = ()=> {
        zoomToMap(
            {
              longitude: null,
              latitude: null,
            },
            2
        )
      }

      const zoomToMap = (item, zoomOverride) => {
        if(item){
          mapZoom.value = zoomOverride ? zoomOverride : 6
          longitude.value = item.mapLongitude | item.longitude
          latitude.value = item.mapLatitude | item.latitude
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

  #map-btn.absolute-right {
    position: absolute;
    z-index: 5;
    right: 16px;
    border-radius: 4px;
    height: 56px;
  }

  #schedule-project-toolbar .v-toolbar__content {
    padding: 4px 0 !important;
  }

  .map-field-input {
    border-bottom: solid 1px rgba(0, 0, 0, 0.42);
  }

  #search-menu-btn.rounded-tile-btn {
    background-color: white;
    border-radius: 4px;
  }

  .project-search-card{
    position: relative;
    top:36px;
    right:34px;
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


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
             :class="{'height-one-hunned': isSidebarView}"
  >
    <template v-slot:main-column>
      <a-btn id="map-btn" v-if="!showMap && vuetify.breakpoint.mdAndUp && !isSidebarView" class="absolute-right" color="primary" size="x-small" :elevation="5" custom-classes="mt-4 mb-n1 px-4" @click="showHideMap(!showMap)"><v-icon>mdi-map</v-icon></a-btn>
      <a-btn id="close-filters-mobile" v-if="showHideFilters && vuetify.breakpoint.smAndDown" class="absolute-right" color="primary" size="x-small" :elevation="5" custom-classes="mt-4 mb-n1 px-4" @click="[showHideFilters = false, showMobileBtns = false]"><v-icon>mdi-filter-remove</v-icon></a-btn>
      <v-speed-dial
          v-if="vuetify.breakpoint.smAndDown && !showHideFilters"
          v-model="showMobileBtns"
          class="mobile-btns"
          bottom
      >
        <template v-slot:activator>
          <a-btn
              id="speed-dial-activator"
              v-model="showMobileBtns"
              color="primary"
              size="x-small"
              custom-classes="mt-4 mb-n1 px-4"
          >
            <v-icon v-if="showMobileBtns">
              mdi-close
            </v-icon>
            <v-icon v-else>
              mdi-rhombus-split
            </v-icon>
          </a-btn>
        </template>
        <a-btn id="filters-mobile-btn"  size="x-small"
               custom-classes="mt-4 mb-n1 px-4" v-if="showMobileBtns" color="primary" @click="showHideFilters=!showHideFilters"><v-icon>mdi-filter</v-icon></a-btn>
        <a-btn id="map-mobile-btn" size="x-small"
               custom-classes="mt-4 mb-n1 px-4" v-if="!showMap" color="primary" @click="showHideMap(!showMap)"><v-icon>mdi-map</v-icon></a-btn>
      </v-speed-dial>

      <Calendar :map-resources="mapResources"
                ref="calendarRef"
                :map-open="showMap"
                :show-filters="showHideFilters"
                :preselected-event="selectedProject"
                :states="states"
                :callback="resourceMapCallback"
                :date-callback="dateCallback"
                @scheduleResource="scheduleResourceToCurrentProject"
                @unscheduleResource="unscheduleResourceFromCurrentProject"
      />
      <ProjectModal
          v-if="selectedProject.projectId"
          :project="selectedProject"
          :timezone="timezone"
          :resource-from-calendar="calendarResourceToSchedule"
          @toggleProjectMapPin="toggleSelectedProjectMapPin()"
          @updateEvents="updateEvents()"/>
    </template>
    <template v-slot:right-column>
      <v-row class="map-row">
        <v-col cols="12" class="pa-0 ml-3">
          <Map v-if="showMap"
               ref="mapChild"
               :latitude="latitude"
               :current-project-marker="selectedProject"
               :markers="projectMapMarkers"
               :longitude="longitude"
               :zoom="mapZoom"
               :map-resources="mapResources"
               :start-time="startTime"
               :end-time="endTime"
               @close-map="showHideMap(false)"
               @close-search-menu="searchMenuOpen = false"
          >
            <template v-slot:searchMenu>
              <a-btn id="search-menu-btn" v-if="vuetify.breakpoint.mdAndUp" class="rounded-tile-btn pa-5" variant="outlined" icon @click="openSearchModal()" color="primary"><v-icon>mdi-magnify</v-icon></a-btn>
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
import { postRequest } from '@/helpers/helpers'
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
import {computed, getCurrentInstance, onMounted, ref, watch} from "vue";

import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter, onBeforeRouteLeave} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useScheduleStore } from '@/stores/ScheduleStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const scheduleStore = useScheduleStore()

const vueInstance = getCurrentInstance().proxy
const vuetify = vueInstance.$vuetify
const calendarRef = ref(null);

const saveInvalid = ref(true)
const startTime = ref(null)
const endTime = ref(null)
const mapResources = ref([])
const projectMapMarkers = ref([])
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
const mapChild =ref()
const showHideFilters = ref(false)
const showMobileBtns = ref(false)

const activeComp = computed(() => {
  return vuetify.breakpoint.smAndDown ? ThreeColumnLayoutMobile : ThreeColumnLayout
})
const showMap = computed(() => scheduleStore.showMap)

const isSidebarView = computed(() => route.path.includes('inboxConversation'))

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('EVENTS', 'EDIT')
})
const timezone = computed(() => userStore.timezone)

watch(selectedProject, () => {
  validateSaveEvent()
})

onMounted(() => {
  fetchActiveStatesByHierarchy()
  fetchStatusTypes()
  fetchEventStatusTypes()
  fetchEventTypes()
  if(route.query && route.query.projectProcessStepEventId) {
    //projectId, eventId, processStepStatusTypeId
    getSingleProject(null, null, null,null, parseInt(route.query.projectProcessStepEventId), true)

  }
})

const openSearchModal = () => {
  searchMenuOpen.value = !searchMenuOpen.value
  mapChild.value.closeMenu()

}
const updateEvents = () => {
  calendarRef.value.updateEvents()
}

const showHideMap = (show)=> {
  if(show !== showMap.value) {
    scheduleStore.showMap = !scheduleStore.showMap
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
const resourceMapCallback =  (newValue, addPin) => {
  mapResources.value = newValue
  if(newValue.length > 0 && addPin){
    //only show the map if we're adding a pin, not when removing a pin
    showHideMap(true)
    let zoomObj = newValue[newValue.length-1] //choose the most recently added one?
    zoomToMap({latitude: zoomObj.coordinates[1], longitude: zoomObj.coordinates[0]})
  }
}
const projectMapMarkersCallback = (newValue)=> {
  projectMapMarkers.value = newValue
  showHideMap(true)
  // for now only doing this if 1 project is pinned until further definition from ashi
  if(newValue.length === 1){
    zoomToMap(newValue[0], 8)
  }
}
const toggleSelectedProjectMapPin = (onload)=> {
  selectedProject.value.pinned = !selectedProject.value.pinned
  if(selectedProject.value.pinned && !onload){
    //if pinning b/c we're loading the page with a selected project, we don't want to show the map if it's hidden
    showHideMap(true)
    zoomToMap({latitude: selectedProject.value.latitude, longitude: selectedProject.value.longitude})
  } else if(selectedProject.value.pinned && showMap.value === true){
    //if we're loading the page with a selected project and the map is already open, zoom into the project pin
    zoomToMap({latitude: selectedProject.value.latitude, longitude: selectedProject.value.longitude})
  }
}
const dateCallback =  (start, end) => {
  startTime.value = start
  endTime.value = end
}

const scheduleResourceToCurrentProject = (resource)=> {
  calendarResourceToSchedule.value = resource
  appStore.snack = {...createSnackbar('Resource assigned'), show: true}
}
const unscheduleResourceFromCurrentProject = ()=> {
  calendarResourceToSchedule.value = {}
  appStore.snack = {...createSnackbar('Resource unassigned'), show: true}
}

//this snackbar is different from others so we built it here
const createSnackbar = (text) => {
  return {
    y: 'bottom',
    x: null,
    mode: '',
    timeout: 5000,
    text: text,
    color: 'grey darken-3',
    fontClass: 'secondary--text',
    enabled: true
  }
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
    scheduleStore.resourceId = project.selectedResourceId
    selectedProject.value.resource = { id: selectedProject.value.resourceId, name: selectedProject.value.resourceName }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading Project Details')
  }
}

const fetchActiveStatesByHierarchy = async() =>  {
  try {
    const {data} = await getActiveStatesByHierarchy()
    states.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
	appStore.showSnack('ERROR', 'Error Retrieving States')
	appStore.loading = false
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
    appStore.showSnack('ERROR', 'Error Retrieving Event Types')
    appStore.loading = false
  }
}
const fetchEventStatusTypes = async() => {
  appStore.loading = true
  try {
    const {data} = await getEventStatusTypes()
    eventStatusTypes.value = data
	appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
	appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
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
	appStore.showSnack('ERROR', 'Error Retrieving Status Types')
    appStore.loading = false
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

#schedule-container {
  @media(max-width: 960px) {
    overflow-x: clip;
  }
}
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
.mobile-btns{
  position: absolute;
  z-index: 5;
  right: 24px;
  border-radius: 4px;
  bottom: 24px;
}
#filters-mobile-btn, #map-mobile-btn, #close-filters-mobile,
#speed-dial-activator{
  height: 46px;
  width: 46px;
}
#close-filters-mobile{
  bottom: 24px;
  position: absolute;

}
#close-filters-mobile.absolute-right,
#map-btn.absolute-right {
  position: absolute;
  z-index: 5;
  right: 24px;
  border-radius: 4px;
  height: 46px;
  width: 46px;
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


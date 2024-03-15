<script setup>
/*
*@name ProjectSearchDialog
*@author jess
*@date 2/13/24
*
*@description
*
*/

import constants from "@/helpers/constants.js";
import {computed, getCurrentInstance, onMounted, ref, watch} from "vue";
import {getSnackbar, postRequest} from "@/helpers/helpers.js";
import {AppMutations} from "@/stores/AppStore.js";
import axios from "axios";

import {getEventTypes} from "@/services/scheduleService.js";
import {getEventStatusTypes} from "@/services/eventStatusTypeService.js";
import {getStatusTypes} from "@/services/processStepStatusTypeService.js";
import ProjectSearchResultCard from "@/views/flow/schedule/components/ProjectSearchResultCard.vue";
import SpinnerInline from "@/components/SpinnerInline.vue";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter, onBeforeRouteLeave} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const props = defineProps({
  states: {
    type: Array
  },
  startTime:String,
  endTime: String,
  pinToMapCallback: Function,
  pinnedProjects:Array,
})

const emit = defineEmits(['close-dialog', 'zoom-map'])

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const state =ref({}),
    eventStatusTypes= ref([]),
    processStepStatusTypes= ref([]),
    selectedProcessStepStatusType= ref({}),
    eventTypes= ref([]),
    projects= ref([]),
    totalProjects= ref(0),
    selectedProject=ref(),
    selectedEventTypes= ref([]),
    searchEventType= ref({}),
    searchEventStatusType= ref({}),
    searchProject= ref({}),
    searchProjects= ref([]),
    eventTypesChanged= ref(false),
    searchProjectsLoading= ref(false),
    search= ref(null),
    options= ref({
      itemsPerPage: 100
    }),
    footerProps= ref({
      'items-per-page-options': [25, 50, 100],
      'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
    }),
    listLoading = ref(false),
    // initialLoad = ref(true)
    _timerId = ref(),
    showSearchResults = ref(false)
;

const CancelToken = axios.CancelToken;
const source = ref(CancelToken.source());

watch(search, async(val) => {
    if(!val) {
      searchProject.value = {}
      return
    }
    if(val && (!searchProject.value || searchProject.value.projectName !== val)) {
      await getProjectsSearchedFor(val);
    }
})

const fetchEventTypes = async() => {
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
    snackbar('ERROR', 'Error Retrieving Event Types')
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
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const fetchStatusTypes = async() => {
  try {
    //the old way
    // const {data} = await getCompanyStatusTypes()
    // //only show active and complete
    // processStepStatusTypes = data.filter(d => d.processStepStatusTypeId !== 3)

    //the new way - use root statuses
    const {data} = await getStatusTypes()
    //only show active and complete
    processStepStatusTypes.value = data?.filter(d => d.id !== 3)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Status Types')
    appStore.loading = false
  }
}
const searchForProjects = async(search) => {
  try {
    let params = {
      search
    }
    const {data} = await postRequest(`/schedule/projects/search`, params)
    searchProjects.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Searching Projects')
  }
}
const goGoGadgetMapSearch = () =>{
  projects.value = []
  showSearchResults.value = true
  if(state?.value?.id){
    getProjects(true)
    emit('zoom-map', state.value)
  }
  else if(searchProject.value?.projectId){
    getSingleProject(searchProject.value.projectId, searchEventType.value.id, searchEventStatusType.value.id, selectedProcessStepStatusType.value.id)
  }
}
const getProjects = async(resetQuery) => {
  if(resetQuery) {
    // todo: should we remove this.$route.query params if the button is clicked?
    // this.$route.query = {}
  }

  const {page, itemsPerPage} = options.value
  localStorage.setItem('scheduleState', JSON.stringify(state.value))
  localStorage.setItem('scheduleEventTypes', JSON.stringify(selectedEventTypes.value))
  localStorage.setItem('scheduleProcessStepStatusType', JSON.stringify(selectedProcessStepStatusType.value))
  localStorage.setItem('scheduleEventStatusType', JSON.stringify(searchEventStatusType.value))
  if(selectedEventTypes.value?.length > 0) {
    listLoading.value = true
    try {
      if(source.value){
        source.value.cancel();
      }
      source.value = CancelToken.source();
      const {data} = await postRequest(`/schedule/projects`, {
        source: source.value,
        cancelToken: source.value.token,
        eventIds: selectedEventTypes.value?.length > 0 ? selectedEventTypes.value.map(o => o.id) : [],
        //old way
        // processStepStatusTypeId: selectedProcessStepStatusType.processStepStatusTypeId,
        // new way:
        processStepStatusTypeId: selectedProcessStepStatusType.value.id,
        eventStatusTypeId: searchEventStatusType.value.id,
        companyStateId: state.value.id,
        startTime: store.state.schedule.startTime,
        endTime: store.state.schedule.endTime,
        page: 0,
        search:"",
        size: itemsPerPage
      })
      projects.value = data.content || []
      projects.value.forEach(d => {
        d.coordinates = [ d.longitude, d.latitude ]
      })
      totalProjects.value = data.totalElements
      listLoading.value = false
      // initialLoad.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Projects')
      listLoading.value = false
    }
  } else {
    projects.value = []
  }
}
const getProjectsSearchedFor = async(search) => {
  // cancel pending call
  clearTimeout(_timerId.value);

  searchProjectsLoading.value = true

  // delay new call 500ms
  _timerId.value = setTimeout(async () => {
    //todo:_this
    await searchForProjects(search)
    searchProjectsLoading.value = false
  }, 500)
},
 getSingleProject = async(projectId, eventId, eventStatusTypeId, processStepStatusTypeId, projectProcessStepEventId) => {
  listLoading.value = true
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
    projects.value = data
    projects.value.forEach(d => {
      d.coordinates = [ d.longitude, d.latitude ]
    })

    totalProjects.value = projects.length

    if(projects.value.length === 1) {
      selectedProject.value = projects.value[0]
      selectedProject.value.resource = { id: selectedProject.value.resourceId, name: selectedProject.value.resourceName }
      toggleOneMapPin({addPin: true, project: projects.value[0]})
    }
    listLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Project Details')
    listLoading.value = false
  }
}

const clear = () => {
  state.value = {}
  searchProject.value = {}
  selectedEventTypes.value = []
  searchEventType.value = {}
  searchEventStatusType.value = {}
  selectedProcessStepStatusType.value = {}
  projects.value = []
  showSearchResults.value = false
}

const toggleAllPinsOnMap = () => {
  if(allPinsPinned.value){
    props.pinToMapCallback([])
  } else {
    props.pinToMapCallback(projects.value)
  }
}

const toggleOneMapPin = ({addPin, id, project}) => {
  let pinnedList = props.pinnedProjects
  if(addPin){
    if(!project){
      project = projects.value.find(p => p.projectProcessStepEventId === id)
    }
    pinnedList = props.pinnedProjects.concat([project])
  } else {
    pinnedList = props.pinnedProjects.filter(p => {
      return p.projectProcessStepEventId !== id
    })
  }
  props.pinToMapCallback(pinnedList)
}

const allPinsPinned = computed(() => {
  let allPinned = true
  if(projects.value.length > 0 && props.pinnedProjects.length > 0) {
    projects?.value?.forEach((p) => {
      allPinned = isOnePinned(p)
      if (allPinned === false){
        return false
      }
    })
    return allPinned
  }
})

const isOnePinned = (project) => {
  if(props.pinnedProjects.length > 0){
    let index = props.pinnedProjects.findIndex(pinned => {
      return project.projectProcessStepEventId === pinned.projectProcessStepEventId
    })
    return index >= 0
  }
}

const openProjectEvent = (project) => {
        //open event clicks in new window every time so they dont have to keep reloading the calendar
        let routerData = router.resolve({path: `/project/${project.projectId}/processStep/${project.projectProcessStepId}/event/${project.projectProcessStepEventId}`})
        window.open(routerData.href, '_blank')
    }

onMounted(() => {
  fetchEventTypes()
  fetchEventStatusTypes()
  fetchStatusTypes()


})
</script>

<template>
  <v-card id="project-search-card" color="white" style="max-width: 280px; min-width: 280px" class="square-card pa-4 project-search-card" elevation="8"> <!--did this manually instead of using v-menu b/c the dropdowns were getting cut off-->
    <div class="d-flex justify-space-between">
      <v-card-title class="label-large pa-0">Search Projects</v-card-title>
      <AlbatrossButton icon size="small" @click="emit('close-dialog')"><v-icon>close</v-icon></AlbatrossButton>
    </div>
    <div v-if="!showSearchResults" class="project-search-field-container pt-1">
      <div class="one-hunned pb-3">
        <v-autocomplete attach v-model="state" class="pb-2"
                        :items="states"
                        label="State"
                        clearable
                        return-object
                        hide-details
                        dense
                        item-text="state"
                        item-value="id"
                        @click:clear="clear"
                        :disabled="!!searchProject?.projectId"
        ></v-autocomplete>
        <v-autocomplete v-model="searchProject"
                        :items="searchProjects"
                        :search-input.sync="search"
                        item-text="projectName"
                        clearable
                        :key="0"
                        :disabled="!!state?.id"
                        text
                        hide-details
                        class="pb-2"
                        label="Project"
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
        <!--only show the other fields once state or project has been selected-->
        <div v-if="searchProject?.projectId || state?.id">

          <v-select attach v-model="searchEventType"
                    :items="eventTypes"
                    label="Event"
                    hide-details
                    item-text="eventName"
                    item-value="id"
                    return-object
                    clearable
                    class="pb-2"
                    v-if="searchProject?.projectId"
          />
          <v-autocomplete attach v-model="selectedEventTypes"
                          :items="eventTypes"
                          label="Event"
                          item-text="eventName"
                          item-value="id"
                          return-object
                          hide-details
                          class="pb-2"
                          clearable
                          :disabled="!state || !state.id"
                          multiple
                          v-else
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

          <v-autocomplete v-model="searchEventStatusType"
                          :items="eventStatusTypes"
                          label="Event Status"
                          :disabled="!searchEventType?.id && selectedEventTypes.length === 0"
                          clearable
                          hide-details
                          class="pb-2"
                          item-text="eventStatusType"
                          item-value="id"
                          return-object
          />
          <v-autocomplete v-model="selectedProcessStepStatusType"
                          :items="processStepStatusTypes"
                          label="Process Step Status"
                          clearable
                          hide-details
                          item-text="processStepStatusType"
                          item-value="id"
                          return-object
          />
        </div>
      </div>
    </div>
    <div v-else class="body-small">
      <v-chip x-small color="primary lighten-9" v-if="state.state" class="mr-1 px-2 grey--text text--darken-3">{{state.state}} </v-chip>
      <v-chip x-small color="primary lighten-9" v-if="searchProject?.projectName" class="mr-1 px-2 grey--text text--darken-3">{{searchProject.projectName}} </v-chip>
      <v-chip x-small color="primary lighten-9" v-if="searchEventType?.eventName" class="mr-1 px-2 grey--text text--darken-3">{{searchEventType.eventName}} </v-chip>
      <v-chip x-small v-for="e in selectedEventTypes" color="primary lighten-9" class="mr-1 px-2 grey--text text--darken-3">{{e.eventName}} </v-chip>
      <v-chip x-small color="primary lighten-9" class="mr-1 px-2 grey--text text--darken-3">Event: {{searchEventStatusType.eventStatusType}}</v-chip>
      <v-chip x-small color="primary lighten-9" class="mr-1 px-2 grey--text text--darken-3">Process Step: {{selectedProcessStepStatusType.processStepStatusType}}</v-chip>
    </div>
    <v-card-actions class="px-0 pb-0">
      <AlbatrossButton @click="clear" variant="text" small class="text-capitalize flex-grow-0 body-medium">Reset</AlbatrossButton>
      <AlbatrossButton v-if="!showSearchResults"
          variant="outlined"
          small
          @click="goGoGadgetMapSearch"
          color="primary"
          class="text-capitalize flex-grow-1 body-medium"
          :disabled="!((state?.id || searchProject?.projectId) && (selectedEventTypes?.length > 0 ||searchEventType?.id) && searchEventStatusType?.id && selectedProcessStepStatusType?.id)"
      >Go</AlbatrossButton>
      <AlbatrossButton v-else
          variant="outlined"
          size="small"
          @click="showSearchResults = false"
          color="primary"
          class="text-capitalize flex-grow-1 body-medium"
      >Edit search</AlbatrossButton>
    </v-card-actions>
    <div v-if="showSearchResults">
    <div class="d-flex justify-space-between align-baseline py-3">
      <span class="label-medium">Search Results</span>
      <AlbatrossButton variant="text" size="small" color="primary" class="text-capitalize" :disabled="!projects || projects.length === 0" @click="toggleAllPinsOnMap">
        {{allPinsPinned ? 'Hide all pins' : 'Show all pins' }}</AlbatrossButton>
    </div>
    <SpinnerInline :size="20" spinner-color="primary" :centered="true" v-if="listLoading"/>
    <div class="search-results">
      <span v-if="(!projects || projects.length === 0) && !listLoading" class="body-medium">No projects found</span>
    <div v-for="p in projects">
      <ProjectSearchResultCard
          :project-name="p.projectName"
          :project-id="p.projectId"
          :id="p.projectProcessStepEventId"
          :event="p.eventName"
          :process-step="p.processStepName"
          :status="p.eventStatusType"
          :start-date="p.start"
          :end-date="p.end"
          :event-resource="p.resourceName"
          :pinned="isOnePinned(p)"
          @pinToMap="toggleOneMapPin"
          @click="openProjectEvent(p)"
          class="clickable"
      />
    </div>
    </div>
    </div>
  </v-card>

</template>

<style scoped lang="scss">
.search-results {
  max-height: calc(100vh - 350px);
  overflow-y: scroll;
}
</style>

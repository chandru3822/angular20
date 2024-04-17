<template>
  <div id="calendar-container">

    <div id="calendar-filter-container" class="pa-6 pt-1">
<v-col cols="11" class="pa-0">
      <!-- if this row is not wrapped in a div then the calendar doesn't size well on refresh. i have no clue why -->
      <v-row class="py-0 d-flex align-baseline">
        <v-col id="states-filter-col" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <a-autocomplete attach v-model="selectedStates"
                    :items="sortedStates"
                    label="States"
                    multiple
                    hide-details
                    return-object
                    item-title="state"
                    item-value="id"
                    @blur="filterOrgsAndUsers"
          >
            <template v-slot:selection="{ item, index }">
              <div v-if="index === 0 && selectedStates.length < 3">
                <v-chip small close @click:close="selectedStates.splice(idx, 1)"
                        v-for="(ss, idx) in selectedStates">
                  <span>{{ ss.state }}</span>
                </v-chip>
              </div>
              <span
                v-if="index === 1 && selectedStates.length >= 3"
                class="primary--text text-caption"
              >{{ selectedStates.length }} selected</span>
            </template>
            <template  v-slot:prepend-item>
              <v-list-item
                ripple
                @click="toggleSelectAllStates()">
                  <v-icon class="mr-4">{{ iconStates }}</v-icon>
                <v-list-item-title class="wrap-dropdown-item py-2">Select All</v-list-item-title>
              </v-list-item>
              <v-divider
                class="mt-2"
              ></v-divider>
            </template>

            <template v-slot:item="{item}">
              <v-icon class="mr-4">{{selectedStates.findIndex(s => s.stateId === item.stateId) >= 0 ? 'check_box' : 'check_box_outline_blank'}}</v-icon>
              <span class="wrap-dropdown-item py-2">{{ item.state }}</span>
            </template>
          </a-autocomplete>
        </v-col>
        <v-col id="org-resource-types-filter-col" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <a-autocomplete v-model="selectedOrgTypes"
                          allow-overflow
                    :items="sortedOrgTypes"
                    label="Organization Resource Types"
                    multiple
                    type="search"
                    :loading="orgTypesLoading"
                    hide-details
                    return-object
                    item-title="orgType"
                    item-value="id"
                    @input="orgTypeValuesChanged = true"
                    @blur="filterOrgsAndUsers"
                          attach
          >
            <template v-slot:selection="{item, index}">
              <div v-if="index === 0 && selectedOrgTypes.length < 3">
                <v-chip small close @click:close="selectedOrgTypes.splice(idx, 1)"
                        v-for="(sr, idx) in selectedOrgTypes">
                  <span>{{ sr.orgType }}</span>
                </v-chip>
              </div>
              <span
                  v-if="index === 1 && selectedOrgTypes.length >= 3"
                  class="primary--text text-caption"
              >{{ selectedOrgTypes.length }} selected</span>
            </template>
            <template  v-slot:prepend-item>
              <v-list-item
                  ripple
                  @click="toggleSelectAllOrgTypes()">
                <v-list-item-action class="mr-4">
                  <v-icon>{{ iconOrgTypes }}</v-icon>
                </v-list-item-action>
                <v-list-item-title class="wrap-dropdown-item py-2">Select All</v-list-item-title>
              </v-list-item>
              <v-divider
                  class="mt-2"
              ></v-divider>
            </template>
            <template v-slot:item="{item}">
              <!--The only purpose of this template is to allow the items to wrap-->
              <v-icon class="mr-4">{{selectedOrgTypes.findIndex(ot => ot.id === item.id) >= 0 ? 'check_box' : 'check_box_outline_blank'}}</v-icon>
              <span class="wrap-dropdown-item py-2">{{ item.orgType }}</span>
            </template>
          </a-autocomplete>
        </v-col>
<!--        <v-col id="placeholder-col-1" v-if="$vuetify.breakpoint.smOnly" cols="4" md="0" class="py-0"/>-->
        <v-col id="org-resources-col" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <a-autocomplete v-model="selectedOrgs"
                          ref="orgSelector"
                          :items="sortedOrgs"
                          label="Organization Resources"
                          multiple
                          clearable
                          :loading="orgsLoading"
                          :hide-details="countSelected < maxSelectionAllowed"
                          :error="countSelected >= maxSelectionAllowed"
                          :error-messages="countSelected >= maxSelectionAllowed ? countErrorMessage : null"
                          return-object
                          item-title="orgName"
                          item-value="id"
                          @input="[orgValuesChanged = true, limiter()]"
                          @blur="reloadCalendar"
                          attach
          >
            <template
                v-slot:selection="{item, index}"
            >
              <span v-if="index === 0" class="primary--text text-caption">
                {{ selectedOrgs.length }} selected
              </span>
            </template>
            <template v-slot:item="{item}">
              <!--The only purpose of this template is to allow the items to wrap-->
              <v-icon class="mr-4">{{selectedOrgs.findIndex(o => o.id === item.id) >= 0 ? 'check_box' : 'check_box_outline_blank'}}</v-icon>
              <span class="wrap-dropdown-item py-2">{{ item.orgName }}</span>
            </template>
          </a-autocomplete>
        </v-col>
        <v-col id="placeholder-desktop-col" v-if="$vuetify.breakpoint.md && !mapOpen" cols="0" md="3" class="py-0"/>
        <v-col id="position-resource-types-col" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <a-autocomplete v-model="selectedPositions"
                          :items="sortedPositions"
                          label="Position Resource Types"
                          multiple
                          hide-details
                          :loading="positionsLoading"
                          return-object
                          item-title="position"
                          item-value="id"
                          @input="positionValuesChanged = true"
                          @blur="filterOrgsAndUsers"
                          attach
          >
            <template  v-slot:selection="{item, index}">
              <div v-if="index === 0 && selectedPositions.length < 3">
                <v-chip small close @click:close="selectedPositions.splice(idx, 1)"
                        v-for="(sr, idx) in selectedPositions">
                  <span>{{ sr.position }}</span>
                </v-chip>
              </div>
              <span
                  v-if="index === 1 && selectedPositions.length >= 3"
                  class="primary--text text-caption"
              >{{ selectedPositions.length }} selected</span>
            </template>
            <template  v-slot:prepend-item>
              <v-list-item ripple
                  @click="toggleSelectAllPositions()">
                <v-list-item-action class="mr-4">
                  <v-icon>{{ iconPositions }}</v-icon>
                </v-list-item-action>
                <v-list-item-title class="wrap-dropdown-item py-2">Select All</v-list-item-title>
              </v-list-item>
              <v-divider class="mt-2"
              ></v-divider>
            </template>
            <template v-slot:item="{ props, item }">
              <!--The only purpose of this template is to allow the items to wrap-->
              <v-icon class="mr-4">{{selectedPositions.findIndex(p => p.id === item.id) >= 0 ? 'check_box' : 'check_box_outline_blank'}}</v-icon>
              <span class="wrap-dropdown-item py-2">{{ item.position }}</span>
            </template>
          </a-autocomplete>

        </v-col>
<!--        <v-col id="placeholder-col-2" v-if="$vuetify.breakpoint.smOnly" cols="4" md="0" class="py-0"/>-->
        <v-col id="user-resources-col"  cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <a-autocomplete v-model="selectedUsers"
                          :items="sortedUsers"
                          label="User Resources"
                          multiple
                          clearable
                          :hide-details="countSelected < maxSelectionAllowed"
                          :error="countSelected >= maxSelectionAllowed"
                          :error-messages="countSelected >= maxSelectionAllowed ? countErrorMessage : null"
                          :loading="usersLoading"
                          return-object
                          item-title="fullName"
                          item-value="id"
                          @input="[userValuesChanged = true, limiter()]"
                          @blur="reloadCalendar"
                          attach
          >
            <template  v-slot:selection="{item, index}">
              <span v-if="index === 0" class="primary--text text-caption">
                {{ selectedUsers.length }} selected
              </span>
            </template>
            <template v-slot:item="{item}">
              <!--The only purpose of this template is to allow the items to wrap-->
              <v-icon class="mr-4">{{selectedUsers.findIndex(u => u.id === item.id) >= 0 ? 'check_box' : 'check_box_outline_blank'}}</v-icon>
              <span class="wrap-dropdown-item py-2">{{ item.fullName }}</span>
            </template>
          </a-autocomplete>
        </v-col>
        <v-col id="time-zone-col" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <a-select
              v-model="scheduleTimezone"
              :items="timezones"
              label="Current Time Zone"
              item-title="friendlyValue"
              :hide-details="true"
              return-object
              prepend-icon="mdi-web"
			  @change="updateTimezone"
          />
        </v-col>
        <v-col id="cancelled-events-toggle-col" class="py-0 d-flex align-start" cols="9" sm="4" md="3">
            <v-switch
              v-model="includeCancelled"
              dense
              hide-details
              class="fix-switch-color cancelled-event-switch mt-0"
              label="Cancelled Events"
              @change="reloadCalendar"
            />
        </v-col>
      </v-row>
</v-col>
    </div>
    <div class="calendar-resize-container background-white pa-6">
      <div id="calendar-loader" v-if="calendarLoading">
        <v-progress-circular
          indeterminate
          :size="80"
          :color="'primary'"
        ></v-progress-circular>
      </div>
      <FullCalendar ref="eventCalendar" id="event-calendar" :options="calendarOptions">
        <template v-slot:resourceAreaHeaderContent>
          <div class="d-flex justify-space-between align-baseline">
          <span>Resources</span>
            <div>
            <v-tooltip bottom :open-on-hover="!$vuetify.breakpoint.smAndDown" :open-on-click="false">
              <template v-slot:activator="{on}">
                <a-btn icon size="small" @click="toggleMapPinsForAllResources(!allResourcesOnMap)" :activation-handler="on" class="mx-1">
                  <v-icon color="primary lighten-5"  v-if="allResourcesOnMap">mdi-map-marker</v-icon>
                  <v-icon color="grey darken-1" v-else>mdi-map-marker-off</v-icon>
                </a-btn>
              </template>
              <span v-if="allResourcesOnMap">Remove all from map</span>
              <span v-else>Pin all on map</span>
            </v-tooltip>
            </div>
          </div>
        </template>
        <template v-slot:resourceLabelContent="{resource, index}">
          <div class="d-flex justify-space-between align-baseline">
            <a v-if="resource.id.charAt(0)==='1'" :href="`${getHostUrl()}/org/${resource.id.substring(1)}`" target="_blank" class="body-large overflow-hidden resource-title">{{resource.title}}</a>
            <span v-else class="body-large overflow-hidden resource-title">{{ resource.title }}</span>
            <div>
              <v-tooltip bottom :open-on-hover="!$vuetify.breakpoint.smAndDown" :open-on-click="false">
                <template v-slot:activator="{on}">
                  <a-btn icon size="small" @click="toggleMapPinForResource(resource)" :activation-handler="on" class="mx-1">
                    <v-icon color="primary lighten-5"  v-if="isResourceOnMap(resource) || allResourcesOnMap">mdi-map-marker</v-icon>
                    <v-icon color="grey darken-1" v-else>mdi-map-marker-off</v-icon>
                  </a-btn>
                </template>
                <span v-if="isResourceOnMap(resource)">Remove pin from map</span>
                <span v-else>Pin on map</span>
              </v-tooltip>
              <v-tooltip bottom :open-on-hover="!$vuetify.breakpoint.smAndDown" :open-on-click="false">
                <template v-slot:activator="{on}">
              <a-btn v-if="showScheduleBtnForResource(resource)" icon size="small" :color="isAssignedResource(resource) ? 'primary lighten-5' : 'grey darken-1'" class="mx-1" @click="toggleScheduleResource(resource)" :activation-handler="on">
                <v-icon>mdi-calendar-plus</v-icon>
              </a-btn>
                </template>
                {{isAssignedResource(resource) ? 'Remove Resource' : 'Assign to Event' }}
              </v-tooltip>
              <a-btn icon size="small" color="grey darken-1" class="mx-1" @click="closeResource(resource)"><v-icon>close</v-icon></a-btn>
            </div>
          </div>
        </template>
        <template v-slot:eventContent="{event}">
          <v-tooltip bottom :open-on-hover="!$vuetify.breakpoint.smAndDown" :open-on-click="false">
            <template v-slot:activator="{ on, attrs }">
              <span v-if="event.title !== 'null'" v-bind="attrs" v-on="on" :class="{'text-no-wrap':event.display !== 'background'}" class="event-title body-medium">{{event.title}}</span>
            </template>
            <span>{{event.title}}</span>
          </v-tooltip>
<!--yes, 'null' is intentionally a string because that's how it comes back from the calendar-->
        </template>
      </FullCalendar>
    </div>
  </div>
</template>

<script setup>
import moment from 'moment'
import cloneDeep from 'lodash.clonedeep'
import {getSchedulingOrgTypes} from '@/services/orgService'

import {handleHidingGlobalLoader, getRequest, getHostUrl, getRequestWithParams, postRequest, getEventColorClass} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import FullCalendar from "@fullcalendar/vue";
import momentTimezonePlugin from "@fullcalendar/moment-timezone";
import resourceTimelinePlugin from "@fullcalendar/resource-timeline";
import interaction from "@fullcalendar/interaction";
import {computed, getCurrentInstance, nextTick, onMounted, ref, watch} from "vue";
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useScheduleStore } from '@/stores/ScheduleStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const scheduleStore = useScheduleStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const vuetify = vueInstance.$vuetify
const filters = vueInstance.$filters

const eventCalendar = ref(null)
const userCanEdit = computed(() => userStore.userHasFeatureAccessLevel('SCHEDULE', 'EDIT'))

const emit = defineEmits(['scheduleResource', 'unscheduleResource'])

const props = defineProps({
  mapOpen:Boolean,
  mapResources: {type: Array},
  callback: Function,
  dateCallback: Function,
  states: {type: Array},
  preselectedEvent: {type:Object, required: false}
})

const scheduleTimezone = computed(() => scheduleStore.getTimezone)
const userTimezone = computed(() => userStore.timezone)

const calendarOptions = ref({
  plugins: [
    resourceTimelinePlugin, interaction, momentTimezonePlugin
  ],
  firstDay: 1,
  initialView: 'resourceTimelineDay',
  resources: [],
  resourceAreaWidth: vuetify.breakpoint.smAndDown? 200: 300,
  resourceGroupLaneClassNames:['resourceLaneClass'],
  schedulerLicenseKey: constants.FULL_CALENDAR_LICENSE_KEY,
  eventSources:[
    (info, successCallback, failureCallback) => goGetEventsNow(info, successCallback, failureCallback)
  ],
  eventClick: (eventClickInfo) => handleEventClick(eventClickInfo),
  datesSet: (dateInfo) => updateCalDates(dateInfo),
  navLinks: true,
  slotLabelDidMount:function ({el, date, view, level}) {
    //this is a workaround because the day headers on the week view take you to the wrong view,
    // and they don't trigger navLinkDayClick
    if(view.type === "resourceTimelineWeek" && level === 0) {
      let elA = el.querySelector('a')
      if(elA.dataset.navlink === ''){
        elA.onclick = () => {
          view.calendar.changeView("resourceTimelineDay", date);
        }
      }
    }
  },
  headerToolbar:{
    left: vuetify.breakpoint.mdAndUp ? 'prev,customToday,next': 'prev,next',
    center: 'title',
    right: vuetify.breakpoint.mdAndUp ? 'resourceTimelineDay,resourceTimelineWeek': ''
  },
  slotMinWidth:40,
  slotMinTime:"04:00:00",
  slotMaxTime:"23:00:00",
  nowIndicator:true,
  views:{
    resourceTimelineDay:{
      titleFormat:{ month: 'long',
        year: 'numeric',
        day: 'numeric',
        weekday: 'long'
      }
    },
    resourceTimelineWeek:{
      titleFormat:{ month: 'short',
        year: 'numeric',
        day: 'numeric'
      },
      slotMinWidth:76,
    }
  },
  height: '100%',
  timeZone: scheduleTimezone.value.value || {},

  customButtons: {
    customToday: {
      text: 'Today',
      click: async () => {
        let calendarApi = eventCalendar.value.getApi()
        calendarApi.gotoDate(new Date)
        handlePinsOnDayChange()
      }
    }
  }
})
const calendarLoading = ref(false)
const includeCancelled = ref(false)
const calendarApi = ref(null)
const calendarStartTime = ref(null)
const calendarEndTime = ref(null)
const maxSelectionAllowed = ref(10)
const countErrorMessage = ref('Maximum Selection Reached')
//filters
const selectedStates = ref([])
const masterOrgs = ref([])
const orgValuesChanged = ref(false)
const orgs = ref([])
const selectedOrgs = ref([])
const orgsLoading = ref(true)
const usersLoading = ref(true)
const userValuesChanged = ref(false)
const masterUsers = ref([])
const users = ref([])
const selectedUsers = ref([])
const orgTypes = ref([])
const orgTypeValuesChanged = ref(false)
const selectedOrgTypes = ref([])
const orgTypesLoading = ref(true)
const positions = ref([])
const positionValuesChanged = ref(false)
const selectedPositions =  ref([])
const previousStateCount =  ref(0)
const previousTypeCount =  ref(0)
const previousPositionCount =  ref(0)
const positionsLoading =  ref(true)
const mapPinnedResources = ref([])
const mapResourceEvents =  ref([])
const checkedResources =  ref([])
const timezones = ref([
  { friendlyValue: 'US/Pacific', value: 'America/Los_Angeles'},
  { friendlyValue: 'US/Alaska', value: 'America/Anchorage'},
  { friendlyValue: 'US/Arizona', value: 'America/Phoenix'},
  { friendlyValue: 'US/Central', value: 'America/Chicago'},
  { friendlyValue: 'US/Hawaii', value: 'Pacific/Honolulu'},
  { friendlyValue: 'US/Eastern', value: 'America/New_York'},
  { friendlyValue: 'US/Mountain', value: 'America/Denver'}
])

const updateTimezone = (newTimezone) => scheduleStore.timezone = newTimezone

//states
const sortedStates = computed(() => {
  const sStates = props.states.filter(state => selectedStates.value.includes(state))
  const uStates = props.states.filter(state => !selectedStates.value.includes(state))
  return sStates.concat(uStates)
})
const selectAllStates = computed( () => {
  return props.states.length === selectedStates.value.length
})
const selectSomeStates = computed(() => {
  return selectedStates.value.length > 0 && !selectAllStates.value
})
const iconStates = computed(() => {
  if (props.states.length === selectedStates.value.length) {
    return 'check_box'
  }
  if (selectSomeStates.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
//org Types
const sortedOrgTypes = computed(() =>  {
  const sots = orgTypes.value.filter(orgType => selectedOrgTypes.value.includes(orgType))
  const usots = orgTypes.value.filter(orgType => !selectedOrgTypes.value.includes(orgType))
  return sots.concat(usots)
})
const selectAllOrgTypes =  computed(() => {
  return orgTypes.value.length === selectedOrgTypes.value.length
})
const selectSomeOrgTypes =  computed(() => {
  return selectedOrgTypes.value.length > 0 && !selectAllOrgTypes.value
})
const iconOrgTypes =  computed(() => {
  if (orgTypes.value.length === selectedOrgTypes.value.length) {
    return 'check_box'
  }
  if (selectSomeOrgTypes.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
//positions
const sortedPositions = computed(() => {
  const sp = positions.value.filter(position => selectedPositions.value.includes(position));
  const up = positions.value.filter(position => !selectedPositions.value.includes(position));
  return sp.concat(up)

})
const selectAllPositions =  computed(() => {
  return positions.value.length === selectedPositions.value.length
})
const selectSomePositions =  computed(() => {
  return selectedPositions.value.length > 0 && !selectAllPositions.value
})
const iconPositions =  computed(() => {
  if (positions.value.length === selectedPositions.value.length) {
    return 'check_box'
  }
  if (selectSomePositions.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
//orgs
const sortedOrgs = computed(() => {
  const sOrgs = orgs.value.filter(org => selectedOrgs.value.includes(org));
  const usOrgs = orgs.value.filter(org => !selectedOrgs.value.includes(org));
  return sOrgs.concat(usOrgs)
})
//users
const sortedUsers = computed(() => {
  const sUsers = users.value.filter(user => selectedUsers.value.includes(user));
  const usUsers = users.value.filter(user => !selectedUsers.value.includes(user));
  return sUsers.concat(usUsers)
})

const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const countSelected = computed(() => {
  return selectedOrgs.value?.length + selectedUsers.value?.length
})

    onMounted (async () => {
      calendarApi.value = eventCalendar.value.getApi()
      await getSchedulingOrgs()
      await getSchedulingUsers()
      await fetchSchedulingOrgTypes()
      await getPositions()
      if(props.preselectedEvent){
        filterOrgsAndUsers()
      }
    })
    watch(() => scheduleTimezone, (value) => {
        //when the schedule timezone value changes, update the calendar plugin's timezone
        let calendarApi = eventCalendar.value.getApi()
        calendarApi.setOption('timeZone', scheduleTimezone)
        //and show a snackbar if the timezones don't match
        if(userTimezone !== scheduleTimezone) {
          const snackbar = createSnackbar('Note: Timezone changes only affect the scheduling tool.  The timezone everywhere else on Albatross remains unchanged.')
          appStore.snack = {...snackbar, show: true}
        }
      })
      watch(userTimezone, (newVal) => {
        //when the value of the timezone changes (either via the time zone dropdown selector or a change in the user store timezone value),
        // update the timezone for the schedule page
        changeTimezone(newVal)
      })

// whenever selectedUsers or selectedOrgs changes, concat them both into resources
watch(selectedUsers, (newValue, oldValue) => {
  calendarOptions.value.resources = selectedOrgs.value.concat(selectedUsers.value)
  if(oldValue.length > newValue.length) {
    //if we're removing users
    const removedUsers = oldValue.filter(oldUser => newValue.indexOf(oldUser) < 0)
    handlePinsOnSelectedResourceChange(removedUsers)
  }
  handleResourceColors()
})
watch(selectedOrgs, (newValue, oldValue) => {
  calendarOptions.value.resources = selectedOrgs.value.concat(selectedUsers.value)
  if(oldValue.length > newValue.length) {
    //if we're removing users
    const removedOrgs = oldValue.filter(oldOrg => newValue.indexOf(oldOrg) < 0)
    handlePinsOnSelectedResourceChange(removedOrgs)
  }
  handleResourceColors()
  // refs.orgSelector.setSearch('')//prevents weird scroll bug
})

const reloadCalendar = () =>{
  let calendarApi = eventCalendar.value.getApi()
  calendarApi.refetchEvents()
}
const isResourceOnMap = (resource) => {
  return mapPinnedResources.value?.findIndex(rId => resource.id === rId) >=0
}
const allResourcesOnMap = computed(() => {
  const allResources = calendarOptions.value.resources
  if (allResources.length === 0) {
    return false
  }
  let allOnMap = true
  allResources.forEach(r => {
    if (!isResourceOnMap(r)) {
      allOnMap = false
    }
  })
  return allOnMap
})
const isAssignedResource = (resource) => {
  let result = false
  const selectedResourceId = scheduleStore.selectedResourceId
  if(!selectedResourceId || selectedResourceId < 0){
    return false
  }
  if(resource.extendedProps.orgId === selectedResourceId) {
    result = true
  } else {
    const positions = resource.extendedProps.userPositions?.filter(p => p.id === selectedResourceId)
    result = positions?.length > 0
  }
  return result
}

const handleResourceColors = () => {
  calendarOptions.value.resources.forEach((r, index) => {
    r.eventBackgroundColor = '#FFFFFF'
    r.eventBorderColor = '#919191'
    r.eventColorClass = getEventColorClass(index)

    //the event will come get this later
    if(index <= 19) {
      // use one of the first 20 pre-defined colors
      r.color = constants.COLOR_LIST[index]
    } else {
      //generate a random color
      let hexColorCode = '';
      while (hexColorCode.length < 6) {
        hexColorCode += (Math.random()).toString(16).substr(-6).substr(-1)
      }
      r.color = '#'+hexColorCode
    }
  })
}


      //filter functions
      const toggleSelectAllStates =  async() => {
        await nextTick(() => {
          if (selectAllStates.value) {
            selectedStates.value = []
          } else {
            selectedStates.value = cloneDeep(props.states)
          }
        })
      }
      const toggleSelectAllOrgTypes =  () => {
        nextTick(() => {
          if (selectAllOrgTypes.value) {
            selectedOrgTypes.value = []
          } else {
            selectedOrgTypes.value = cloneDeep(orgTypes.value)
          }
        })
      }
      const toggleSelectAllPositions =  () => {
        nextTick(() => {
          if (selectAllPositions.value) {
            selectedPositions.value = []
          } else {
            selectedPositions.value = cloneDeep(positions.value)
          }
        })
      }
      const showScheduleBtnForResource = (resource) => {
        // v-if="userCanEdit && project.editableInSchedule"
        if(props.preselectedEvent && userCanEdit && props.preselectedEvent.editableInSchedule) {
          if (props.preselectedEvent.systemListId === 2) {
            const allowedPositions = resource.extendedProps?.userPositions?.filter(p => props.preselectedEvent.systemListOptionIds.includes(p.positionId))
            return allowedPositions?.length > 0
          } else if (props.preselectedEvent.systemListId === 3) {
            return props.preselectedEvent.systemListOptionIds.includes(resource.extendedProps.orgTypeId)
          }
        }
        return false
      }
      const getSchedulingOrgs = async() => {
        orgsLoading.value = true
        try {
          const {data, status} = await getRequestWithParams(`/org/getSchedulingOrgs`, {
            params: {
              stateId: null, //?
              isSchedulingTool: true
            }
          }, null, [])
          //in order for resources to work as both users and orgs, the resourceId needs to be prefixed with a type_id 1=org, 2=user
          data?.forEach(d => {
            d.masterId = d.id
            d.id = `${1}${d.id}`
          })
          orgs.value = data
          masterOrgs.value = cloneDeep(orgs.value)
          orgsLoading.value = false
          selectedOrgs.value = selectedOrgs.value.filter(so => {
            return orgs.value.some(o => o.id === so.id)
          })
           handleHidingGlobalLoader( status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.showSnack('ERROR', 'Error Retrieving Orgs')
          appStore.loading = false
        }
      }
      const fetchSchedulingOrgTypes = async() => {
        orgTypesLoading.value = true
        try {
          const {data, status} = await getSchedulingOrgTypes()
          orgTypes.value = data

          //if we came from an event, preselect the correct Resource TYPES
          if(props.preselectedEvent){
            if(props.preselectedEvent.systemListId === 3){
              selectedOrgTypes.value = orgTypes?.value.filter(ot => props.preselectedEvent.systemListOptionIds.includes(ot.id))
            }
          }

          orgTypesLoading.value = false
           handleHidingGlobalLoader( status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.showSnack('ERROR', 'Error Retrieving Org Types')
          appStore.loading = false
        }
      }
      const getPositions = async() => {
        positionsLoading.value = true
        try {
          const {data, status} = await getRequest(`/position/schedulable`, null, [])
          positions.value = data
          //if we came from an event, preselect the correct Resource TYPES
          if(props.preselectedEvent){
            if(props.preselectedEvent.systemListId === 2){
              selectedPositions.value = positions.value.filter(p => props.preselectedEvent.systemListOptionIds.includes(p.id))
            }
          }
          positionsLoading.value = false
           handleHidingGlobalLoader( status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.showSnack('ERROR', 'Error Retrieving Positions')
          appStore.loading = false
        }
      }
      const getSchedulingUsers = async() => {
        appStore.loading = true
        try {
          const {data, status} = await getRequestWithParams(`/user/getSchedulingUsers`, {
            params: {
              stateId: null, //?
              isSchedulingTool: true
            }
          }, null, [])
          //in order for resources to work as both users and orgs, the resourceId needs to be prefixed with a type_id 1=org, 2=user
          data.forEach(d => {
            d.masterId = d.id
            d.id = `${2}${d.id}`
          })
          users.value = data
          masterUsers.value = cloneDeep(users.value)
          usersLoading.value = false
          selectedUsers.value = selectedUsers.value.filter(su => {
            return users.value.some(u => u.id === su.id)
          })
           handleHidingGlobalLoader( status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.showSnack('ERROR', 'Error Retrieving Users')
          appStore.loading = false
        }
      }
      const limiter = () => {
        orgs.value.forEach(o => {
          let match = selectedOrgs.value.find(so => so.id === o.id)
          o.disabled = !match && countSelected.value >= maxSelectionAllowed.value
        })
        users.value.forEach(u => {
          let match = selectedUsers.value.find(su => su.id === u.id)
          u.disabled = !match && countSelected.value >= maxSelectionAllowed.value
        })
      }
      const filterOrgsAndUsers = () => {
        //only filter if something is selected or deselected back down to 0 length - cant watch these values because we don't want to call the function on the change but only on blur
        let stateFilterRequired = selectedStates.value?.length > 0
        let stateReset = previousStateCount.value > 0 && selectedStates.value?.length === 0
        previousStateCount.value = selectedStates.value?.length
        let orgTypeFilterRequired = selectedOrgTypes.value?.length > 0
        let typeReset = previousTypeCount.value > 0 && selectedOrgTypes.value?.length === 0
        previousTypeCount.value = selectedOrgTypes.value?.length
        let positionFilterRequired = selectedPositions.value?.length > 0
        let positionReset = previousPositionCount.value > 0 && selectedOrgTypes.value?.length === 0
        previousPositionCount.value = selectedPositions.value?.length
        if(stateFilterRequired || orgTypeFilterRequired || positionFilterRequired || stateReset || typeReset || positionReset) {
          orgs.value = masterOrgs.value.filter(mo => {
            let stateMatch = true
            let orgTypeMatch = true
            if(stateFilterRequired) {
              let match = selectedStates.value.find(ss => ss.stateId === mo.stateId)
              stateMatch = match !== null && match !== undefined
            }
            if(orgTypeFilterRequired) {
              let match = selectedOrgTypes.value.find(sot => sot.id === mo.orgTypeId)
              orgTypeMatch = match !== null && match !== undefined
            }
            return stateMatch && orgTypeMatch
          })
          let selectedPositionIds = selectedPositions.value.map(p => p.id)
          let selectedStateIds = selectedStates.value.map(s => s.stateId)
          users.value = masterUsers.value.filter(mo => {
            let stateMatch = true
            let positionMatch = true
            if(stateFilterRequired) {
              stateMatch = mo.userPositions.some(up => {
                return selectedStateIds.includes(up.stateId)
              })
            }
            if(positionFilterRequired) {
              positionMatch = mo?.userPositions.some(up => {
                return selectedPositionIds.includes(up.positionId)
              })
            }
            return stateMatch && positionMatch
          })
        }
      }

const closeResource = (resource) => {
  //todo: are there any cases where a user resource and an org resource could end up with the same id??
  let index = selectedUsers.value.findIndex(r =>
      r.id === resource.id
  )
  if(index >= 0){
    selectedUsers.value.splice(index, 1)
  } else {
    index = selectedOrgs.value.findIndex(r => r.id === resource.id)
    selectedOrgs.value.splice(index,1)
  }
  if(isResourceOnMap(resource)){
    toggleMapPinForResource(resource)
  }
  calendarOptions.value.resources = selectedOrgs.value.concat(selectedUsers.value)
  limiter()
}
const toggleScheduleResource = (resource) =>{
  if(!isAssignedResource(resource)){
    emit('scheduleResource', resource)
  } else {
    emit('unscheduleResource')
  }
}

//map functions
const toggleMapPinForResource = (resource) => {
  handlePopulatingMapPins(!isResourceOnMap(resource), resource, true)
}
const toggleMapPinsForAllResources = (pinOrNot) => {
  const allResources = calendarOptions.value.resources
  allResources.forEach(r => {
    handlePopulatingMapPins(pinOrNot, r, true)
  })
}

const handlePinsOnSelectedResourceChange = (removedResource) => {
  for(let resource of removedResource) {
    if (isResourceOnMap(resource)) {
      toggleMapPinForResource(resource)
    }
  }
}

const handlePinsOnDayChange = () => {
  mapResourceEvents.value = []
  checkedResources.value.forEach((r, idx) => {
    handlePopulatingMapPins(true, r, false, idx === checkedResources.value.length - 1)
  })
}
const handlePopulatingMapPins = (addPin, resource, doCallback) => {
  if(addPin) {
    let calendarApi = eventCalendar.value.getApi()

    let resourceEvents = calendarApi.getEvents().filter(e => {
      return e.display !== 'inverse-background' && e.display !== 'background' && e._def.resourceIds.indexOf(resource.id) >= 0

    })
    resourceEvents.forEach(re => {
      let eventObj = {
        id: resource.id,
        projectName: re.extendedProps.projectName,
        processStepName: re.extendedProps.processStepName,
        city: re.extendedProps.city,
        projectId: re.extendedProps.projectId,
        projectProcessStepId: re.extendedProps.projectProcessStepId,
        projectProcessStepEventId: re.extendedProps.projectProcessStepEventId,
        stateAbbreviation: re.extendedProps.stateAbbreviation,
        postalCode: re.extendedProps.postalCode,
        street1: re.extendedProps.street1,
        color: resource.color || resource.extendedProps.color,
        coordinates: [ re.extendedProps.longitude, re.extendedProps.latitude],
        start: re.startStr,
        end: re.endStr
      }
      mapResourceEvents.value.push(eventObj)
    })

    mapPinnedResources.value.push(resource.id)
  } else {
    mapResourceEvents.value = mapResourceEvents.value.filter(r => {
      return r.id !== resource?.id
    })
    mapPinnedResources.value = mapPinnedResources.value.filter(rId => resource?.id !== rId)
  }
  if(doCallback) {
    props.callback(mapResourceEvents.value, addPin)
  }
}


      //calendar event functions
      const getAvailability = async(info) => {
        try {
          let params = {
            orgIds: selectedOrgs.value?.length > 0 ? selectedOrgs.value.map(o => o.masterId) : [],
            userIds: selectedUsers.value?.length > 0 ? selectedUsers.value.map(u => u.masterId) : [],
            startTime: info.start,
            endTime: info.end,
            timezone: scheduleTimezone.value.value
          }
          const {data} = await postRequest(`/schedule/availability`, params)

    data?.forEach(d => {
      if (d.allDay) {
        d.start = moment.utc(d.start).format('YYYY-MM-DD')
        d.end = moment.utc(d.end).format('YYYY-MM-DD')
      }
      //todo: should probably find where this is coming from on the back end and fix it there
      if(d.rendering){
        d.display = d.rendering
      }

      d.groupId = Number(`${d.systemListTypeId}${d.resourceId}`)
      d.resourceId = Number(`${d.systemListTypeId}${d.resourceId}`)
      d.backgroundColor = 'rgba(0,0,0,.12)'
      d.classNames = 'pl-2'



      if(!d.isSlotTime && d.display === 'inverse-background') {
        // d.backgroundColor= 'rgba(255,255,255,0)'
        //if the availability is not coming from a slot schedule AND not a personal appt then do some time adjustments re:DST
        //do start time
        if(d.daylightSavings && !moment(d.start).isDST()) {
          d.start = moment.utc(d.start).add(1, 'h').format('YYYY-MM-DDTHH:mm:ssZ')
        } else if (!d.daylightSavings && moment(d.start).isDST()) {
          //else if the day was NOT saved during DST, but now IS DST, then add an hour
          d.start = moment.utc(d.start).subtract(1, 'h').format('YYYY-MM-DDTHH:mm:ssZ')
        }
        //do end time
        if(d.daylightSavings && !moment(d.end).isDST()) {
          d.end = moment.utc(d.end).add(1, 'h').format('YYYY-MM-DDTHH:mm:ssZ')
        } else if (!d.daylightSavings && moment(d.end).isDST()) {
          //else if the day was NOT saved during DST, but now IS DST, then add an hour
          d.end = moment.utc(d.end).subtract(1, 'h').format('YYYY-MM-DDTHH:mm:ssZ')
        }
      }

      if(d.display === 'background' || d.display === 'auto'){
        d.display = 'auto'
        d.title = d.title + ': ' + getFormattedDate(d.start, 'hh:mm') + '-' + getFormattedDate(d.end)
        d.textColor='rgba(0,0,0,0.87)'
        d.backgroundColor='var(--v-grey-lighten1)'
      }
    })

    //we do this for every resource, regardless of if they already have an availability or not
    // if they already have one it still works as it should and doesn't block out the time, but if they
    // dont already have one then this will block/grey out the day so it doesn't look like they are available
    calendarOptions.value.resources.forEach(r => {
      data.push({
        start: moment.utc(info.start).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
        end: moment.utc(info.start).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
        title: '',
        display: 'inverse-background',
        allDay: false,
        //these values have already been pre-appended with the 1 or 2
        groupId: r.id,
        resourceId: r.id,
        backgroundColor: 'rgba(0,0,0,.12)'
      })
    })
    return data;

        } catch (e) {
          console.error('*** ERROR ***', e)
          appStore.showSnack('ERROR', 'Error Retrieving Availability')
          appStore.loading = false
        }
      }
const updateCalDates = async(info) => {
  let start = info.start
  let end = info.end
  let diff = moment(end).diff(start, 'days')
  if(diff > 7){
    //for some reason when you click the date header in the week view, it sometimes tries to navigate to the month view; this prevents that
    //it seems like it should be forcing it to navigate to the current date, but for some reason, it navigates to the date that was clicked...if it ain't broke...
    let calendarApi = eventCalendar.value.getApi()
    calendarApi.changeView('resourceTimelineDay', new Date)
  }
  calendarStartTime.value = info.start
  calendarEndTime.value = info.end
  await updatePins(info)
}
const updatePins = async(info) => {
  let filteredResources = mapResourceEvents.value?.filter( e => isValidEventDate(Date.parse(e.start), Date.parse(e.end), Date.parse(info.start), Date.parse(info.end)))
  props.callback(filteredResources, true)
}

const isValidEventDate = (eventStart, eventEnd, currentStart, currentEnd) => {
  return !(eventEnd <= currentStart || eventStart >= currentEnd)
}
const goGetEventsNow = async (info, successCallback, failureCallback) => {
  mapResourceEvents.value = []
  if (selectedOrgs.value.length > 0 || selectedUsers.value.length > 0) {
    //i do this here instead of on its own because all of the code above here has to happen for get availability as well
    calendarLoading.value = true
    const availabilityData = await getAvailability(info);
    try {
      let params = {
        orgIds: selectedOrgs.value?.length > 0 ? selectedOrgs.value.map(o => o.masterId) : [],
        // this was the old way. leaving here in case
        // userPositionIds: this.getUserPositionIds(),
        userIds: selectedUsers.value?.length > 0 ? selectedUsers.value.map(u => u.masterId) : [],
        startTime: info.start,
        endTime: info.end,
        includeCancelled: includeCancelled.value
      }
      const {data} = await postRequest(`/schedule`, params)
      data.forEach(d => {
        d.id = d.eventId
        // d.resourceId = `${d.systemListTypeId}${d.resourceId}`
        // if resource is a user show on calendar using userId so that if they have multiple positions we can load all of them into the same user row on the calendar
        d.resourceId = d.userId ? `${d.systemListTypeId}${d.userId}` : `${d.systemListTypeId}${d.resourceId}`
        d.title = `${d.contactFirstName ?? ''} ${d.contactLastName ?? ''} \n ${d.eventName} \n ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`
        d.hoverTitle = `${d.contactFirstName ?? ''} ${d.contactLastName ?? ''} \n ${d.eventName} \n ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`
        let matchingResource = calendarOptions.value.resources.find(r => r.id === d.resourceId)
        if(d.eventStatusTypeId === 3) {
          d.colorForBorder = 'var(--v-grey-darken2)'
          d.textColor = 'var(--v-grey-darken2)'
        } else {
          d.colorForBorder = matchingResource?.color
          d.textColor = 'var(--v-primary-base)'
          d.classNames=['event-tile', matchingResource?.eventColorClass]
        }

        if(isResourceOnMap(matchingResource) && d.projectProcessStepEventId && isValidEventDate(Date.parse(d.start), Date.parse(d.end), Date.parse(calendarStartTime.value), Date.parse(calendarEndTime.value))) {
          let eventObj = {
            key:matchingResource.id + d.projectId + d.projectProcessStepId + d.projectProcessStepEventId,
            id: matchingResource.id,
            projectName: d.projectName,
            processStepName: d.processStepName,
            city: d.city,
            projectId: d.projectId,
            projectProcessStepId: d.projectProcessStepId,
            projectProcessStepEventId: d.projectProcessStepEventId,
            stateAbbreviation: d.stateAbbreviation,
            postalCode: d.postalCode,
            street1: d.street1,
            color: matchingResource.color,
            coordinates: [d.longitude, d.latitude],
            start: d.startStr || d.start,
            end: d.endStr ||d.end
          }
          mapResourceEvents.value.push(eventObj)
        }

      })
      props.callback(mapResourceEvents.value, true)
      // console.log('the events: ',data)
      let events = cloneDeep(data)
      events = events.concat(availabilityData)
      successCallback(events)
      calendarLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Events')
      failureCallback(e)
      calendarLoading.value = false
    } finally {
      orgValuesChanged.value = false
      userValuesChanged.value = false
    }
  }
  successCallback([])
}
const updateEvents = () => {
  calendarApi.value.refetchEvents()
}

defineExpose({
  updateEvents
})

const handleEventClick = (info) => {
  if(info.event.title && info.event.display === 'auto' && info.event.extendedProps?.projectProcessStepId) {
    let props = info.event.extendedProps
    //open event clicks in new window every time so they dont have to keep reloading the calendar
    let routerData = router.resolve({path: `/project/${props.projectId}/processStep/${props.projectProcessStepId}/event/${props.projectProcessStepEventId}`})
    window.open(routerData.href, '_blank')
  }
}

      const changeTimezone = async (tz) => scheduleStore.timezone = tz

const getFormattedDate = (date) => {
  //used for formatting the start/end for the hoverTitle
  return filters.formatDate(date, 'timestamp', 'h:mm a')
}

//this snackbar is different from others so we built it here
const createSnackbar = (text) => {
  return {
    y: 'bottom',
    x: null,
    mode: '',
    timeout: -1,
    text: text,
    color: 'grey darken-3',
    fontClass: 'secondary--text',
    enabled: true
  }
}

</script>

<style lang="scss">

.event-tile{
  border-left-width: 20px;
  height: 28px;
}

.fc h2.fc-toolbar-title{
  //headline-large
  font-family: lato;
  font-weight: 600;
  font-size: 1.375rem;
  line-height: 1.4;
}


#calendar-container .fc-toolbar-title {
  @media(max-width: 960px) {
    font-size: 1.25rem;
  }
}
//add space for scrollbar so it doesn't block times
#event-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th:nth-child(1) > div > div > table > thead > tr > th,
#event-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th > div > div > div > table > tbody > tr.fc-timeline-header-row.fc-timeline-header-row-chrono > th {
  padding-bottom: 8px;
}

.background-event {
  font-size: 11px;
  padding-left: 5px;
  cursor: default;
  margin-left: 1px;
  margin-right: 1px;
  opacity: 1 !important;
  color: black;
  overflow: hidden;
  border: solid 1px black;
}


#calendar-container .fc-timeline-event {
  /*height: inherit;*/
  border-radius: 5px;
  padding-left: 7px;
}

#calendar-container .cancelled-event-switch label {
  font-size: 12px;
}

#calendar-container .cancelled-event-switch .v-input--selection-controls__input {
  transform: scale(0.775);
  transform-origin: center;
}


#calendar-container .fc-rows tr,
#calendar-container .fc-rows tr .fc-widget-content div{
  padding: 5px 0 !important;

}

#calendar-container .fc-rows tr,
#calendar-container .fc-rows tr .fc-widget-content{
  height: auto !important;
}

#calendar-container .fc-cell-content {
  padding-top: 0;
  padding-bottom: 0;
}

#calendar-container > div.calendar-resize-container > div > div.fc-view-container > div > table > tbody > tr > td.fc-time-area.fc-widget-content > div > div > div > div.fc-content > div > table > tbody > tr > td > div > div.fc-bgevent-container > div {
  color: white !important;
  font-size: 0.875rem !important;
}

.event-style{
  background-image: linear-gradient(to right, purple 20px, rgba(0,0,0,0) 20px) !important;
}

#event-calendar {
  position: relative;
  z-index: 0;
  //  this keeps the calendar from being in front of the filter dropdowns.
}

#event-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th > div > div > div > table > tbody > tr > th.fc-slot > div > a.fc-timeline-slot-cushion{
  cursor: default !important;
  color: var(--v-grey-darken1)
}
#event-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th > div > div{
  ::-webkit-scrollbar {
    height: 0 !important;  /* Remove scrollbar space */
    background: transparent !important;  /* Optional: just make scrollbar invisible */
  }
}
//thickening and darkening the day dividers on week view of calendar
#event-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th:nth-child(3) > div > div > div > table > tbody > tr:nth-child(1) > th.fc-timeline-slot.fc-timeline-slot-label.fc-day,
#event-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th:nth-child(3) > div > div > div > table > tbody > tr.fc-timeline-header-row.fc-timeline-header-row-chrono > th:nth-child(19n+1),
#event-calendar > div.fc-view-harness.fc-view-harness-active > div.fc-resourceTimelineWeek-view.fc-view.fc-resource-timeline.fc-resource-timeline-flat.fc-timeline.fc-timeline-overlap-enabled > table > tbody > tr > td:nth-child(3) > div > div > div > div.fc-timeline-slots > table > tbody > tr > td:nth-child(19n+1) {
  border-left-width: 3px;
}

.fc .fc-datagrid-header .fc-datagrid-cell-frame {
  display:block;
}

.fc .fc-scrollgrid {
  border-radius: 4px;
}

</style>

<style lang="scss" scoped>
.resource-title {
  max-width: 60%;
  white-space: break-spaces;
  @media(max-width: 960px) {
    max-width: 30%;
  }
}
.v-tooltip__content {
  background-color: white;
  color: var(--v-grey-darken4);
  outline-color: black;
}
.v-tooltip__content.menuable__content__active {
  opacity: 1;
  filter:  drop-shadow(0px 4px 4px rgba(0, 0, 0, 0.25));
}

.wrap-dropdown-item {
  white-space: normal;
}

#calendar-container {
  height: 100%;
  display: flex;
  flex-flow: column;
  overflow-y: hidden;
  background-color: white;
}

#calendar-filter-container {
  border-bottom: 1px black solid;
  box-shadow: 0 4px 4px rgba(0, 0, 0, 0.25);
  z-index: 1;
  background-color: var(--v-grey-lighten4);
  @media(max-width: 600px) {
    max-height:50%;
    overflow-y: scroll;
  }
}
.calendar-resize-container {
  /* without this when you resize the screen the calendar goes whackadoodle */
  //flex: 1 1 auto;
  position: relative;
  height: calc(100% - 150px);
}

.event-title {
  display: block;
  max-width: 100%;
  text-overflow: ellipsis;
  overflow: hidden;
}

.border-bottom {
  border-bottom: 1px solid #C7C7CC;

}

.background-white {
  background-color: white;
}

#calendar-loader {
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
.invisible-btn{
  visibility: hidden;
  height: 0 !important;
}

</style>

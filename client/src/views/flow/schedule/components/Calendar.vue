<template>
  <div id="calendar-container">

    <div id="calendar-filter-container" class="pa-6 pt-4">
<v-col cols="11" class="pa-0">
      <!-- if this row is not wrapped in a div then the calendar doesn't size well on refresh. i have no clue why -->
      <v-row class="py-0 d-flex align-baseline">
        <v-col id="states-filter-col" class="py-0" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <v-autocomplete attach v-model="selectedStates"
                    :items="sortedStates"
                    label="States"
                    multiple
                    hide-details
                    return-object
                    item-text="state"
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
            <v-list-item
              slot="prepend-item"
              ripple
              @click="toggleSelectAllStates()">
              <v-list-item-action>
                <v-icon>{{ iconStates }}</v-icon>
              </v-list-item-action>
              <v-list-item-title class="wrap-dropdown-item">Select All</v-list-item-title>
            </v-list-item>
            <v-divider
              slot="prepend-item"
              class="mt-2"
            ></v-divider>

            <template v-slot:item="{item}">
              <span class="wrap-dropdown-item">{{ item.state }}</span>
            </template>
          </v-autocomplete>
        </v-col>
        <v-col id="org-resource-types-filter-col" class="py-0" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <v-autocomplete v-model="selectedOrgTypes"
                          allow-overflow
                    :items="sortedOrgTypes"
                    label="Organization Resource Types"
                    multiple
                    type="search"
                    :loading="orgTypesLoading"
                    hide-details
                    return-object
                    item-text="orgType"
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
            <v-list-item
                slot="prepend-item"
                ripple
                @click="toggleSelectAllOrgTypes()">
              <v-list-item-action>
                <v-icon>{{ iconOrgTypes }}</v-icon>
              </v-list-item-action>
              <v-list-item-title class="wrap-dropdown-item">Select All</v-list-item-title>
            </v-list-item>
            <v-divider
                slot="prepend-item"
                class="mt-2"
            ></v-divider>
            <template v-slot:item="{item}">
              <!--The only purpose of this template is to allow the items to wrap-->
              <span class="wrap-dropdown-item">{{ item.orgType }}</span>
            </template>
          </v-autocomplete>
        </v-col>
<!--        <v-col id="placeholder-col-1" v-if="$vuetify.breakpoint.smOnly" cols="4" md="0" class="py-0"/>-->
        <v-col id="org-resources-col" class="py-0" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <v-autocomplete v-model="selectedOrgs"
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
                          item-text="orgName"
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
              <span class="wrap-dropdown-item">{{ item.orgName }}</span>
            </template>
          </v-autocomplete>
        </v-col>
        <v-col id="placeholder-desktop-col" v-if="$vuetify.breakpoint.md && !mapOpen" cols="0" md="3" class="py-0"/>
        <v-col id="position-resource-types-col" class="py-0" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <v-autocomplete v-model="selectedPositions"
                          :items="sortedPositions"
                          label="Position Resource Types"
                          multiple
                          hide-details
                          :loading="positionsLoading"
                          return-object
                          item-text="position"
                          item-value="id"
                          @input="poitionValuesChanged = true"
                          @blur="filterOrgsAndUsers"
                          attach
          >
            <template
                slot="selection"
                slot-scope="{ item, index }"
            >
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
            <v-list-item
                slot="prepend-item"
                ripple
                @click="toggleSelectAllPositions()">
              <v-list-item-action>
                <v-icon>{{ iconPositions }}</v-icon>
              </v-list-item-action>
              <v-list-item-title class="wrap-dropdown-item">Select All</v-list-item-title>
            </v-list-item>
            <v-divider
                slot="prepend-item"
                class="mt-2"
            ></v-divider>
            <template v-slot:item="{item}">
              <!--The only purpose of this template is to allow the items to wrap-->
              <span class="wrap-dropdown-item">{{ item.position }}</span>
            </template>
          </v-autocomplete>

        </v-col>
<!--        <v-col id="placeholder-col-2" v-if="$vuetify.breakpoint.smOnly" cols="4" md="0" class="py-0"/>-->
        <v-col id="user-resources-col" class="py-0" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <v-autocomplete v-model="selectedUsers"
                          :items="sortedUsers"
                          label="User Resources"
                          multiple
                          clearable
                          :hide-details="countSelected < maxSelectionAllowed"
                          :error="countSelected >= maxSelectionAllowed"
                          :error-messages="countSelected >= maxSelectionAllowed ? countErrorMessage : null"
                          :loading="usersLoading"
                          return-object
                          item-text="fullName"
                          item-value="id"
                          @input="[userValuesChanged = true, limiter()]"
                          @blur="reloadCalendar"
                          attach
          >
            <template
                slot="selection"
                slot-scope="{ item, index }"
            >
              <span v-if="index === 0" class="primary--text text-caption">
                {{ selectedUsers.length }} selected
              </span>
            </template>
            <template v-slot:item="{item}">
              <!--The only purpose of this template is to allow the items to wrap-->
              <span class="wrap-dropdown-item">{{ item.fullName }}</span>
            </template>
          </v-autocomplete>
        </v-col>
        <v-col id="time-zone-col" cols="9" sm="4" md="3" :lg="mapOpen ? '4' : '2'">
          <v-select
              v-model="timezone"
              :items="timezones"
              label="Current Time Zone"
              item-text="friendlyValue"
              :hide-details="true"
              return-object
              prepend-icon="mdi-web"
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
        <template v-slot:resourceLabelContent="{resource, index}">
          <div class="d-flex justify-space-between align-baseline">
            <a class="body-medium overflow-hidden resource-title">{{ resource.title }}</a>
            <div>
              <v-tooltip bottom>
                <template v-slot:activator="{on}">
              <AlbatrossButton icon size="x-small" @click="toggleMapPinForResource(resource)" :activation-handler="on" class="mx-1">
                <v-icon color="primary lighten-5"  v-if="isResourceOnMap(resource)">mdi-map-marker</v-icon>
                <v-icon color="grey darken-1" v-else>mdi-map-marker-off</v-icon>
              </AlbatrossButton>
                </template>
                <span v-if="isResourceOnMap(resource)">Remove pin from map</span>
                <span v-else>Pin on map</span>
              </v-tooltip>
              <v-tooltip bottom>
                <template v-slot:activator="{on}">
              <AlbatrossButton v-if="showScheduleBtnForResource(resource)" icon size="x-small" :color="isAssignedResource(resource) ? 'primary lighten-5' : 'grey darken-1'" class="mx-1" @click="toggleScheduleResource(resource)" :activation-handler="on">
                <v-icon>mdi-calendar-plus</v-icon>
              </AlbatrossButton>
                </template>
                Assign to Event
              </v-tooltip>
              <AlbatrossButton icon size="x-small" color="grey darken-1" class="mx-1" @click="closeResource(resource)"><v-icon>close</v-icon></AlbatrossButton>
            </div>
          </div>
        </template>
        <template v-slot:eventContent="{event}">
          <span v-if="event.title !== 'null'" class="event-title text-no-wrap">{{event.title}}</span>
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
import {AppMutations} from '@/stores/AppStore'

import {handleHidingGlobalLoader, getRequest, getHostUrl, getRequestWithParams, postRequest, getSnackbar, getEventColorClass} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "../../../../components/ConfirmationDialog.vue";
import {UserActions} from "@/stores/UserStore";
import FullCalendar from "@fullcalendar/vue";
import momentTimezonePlugin from "@fullcalendar/moment-timezone";
import resourceTimelinePlugin from "@fullcalendar/resource-timeline";
import interaction from "@fullcalendar/interaction";
import {ScheduleActions, ScheduleMutations} from "@/stores/ScheduleStore.js";
import {computed, getCurrentInstance, nextTick, onMounted, ref, watch} from "vue";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const vuetify = vueInstance.$vuetify
const refs = vueInstance.$refs
const filters = vueInstance.$filters
const router = vueInstance.$router

const emit = defineEmits(['scheduleResource', 'unscheduleResource'])

    const props = defineProps({
      mapOpen:Boolean,
      mapResources: {type: Array},
      callback: Function,
      dateCallback: Function,
      states: {type: Array},
      preselectedEvent: {type:Object, required: false}
    })


const userCanEdit = ref(store.getters.userHasFeatureAccessLevel('EVENTS', 'EDIT'))
const calendarOptions = ref({
  plugins: [
    resourceTimelinePlugin, interaction, momentTimezonePlugin
  ],
  initialView: 'resourceTimelineDay',
  resources: [],
  resourceAreaWidth: 300,
  schedulerLicenseKey: constants.FULL_CALENDAR_LICENSE_KEY,
  eventSources:[
    (info, successCallback, failureCallback) => goGetEventsNow(info, successCallback, failureCallback)
  ],
  eventClick: (eventClickInfo) => handleEventClick(eventClickInfo),
  navLinks: true,
  navLinkDayClick: "resourceTimeline",
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
  titleFormat:{ month: 'long',
    year: 'numeric',
    day: 'numeric',
    weekday: 'long'
  },
  height: '100%',
  timeZone: store.state.schedule.timezone.value || {},

  customButtons: {
    customToday: {
      text: 'Today',
      click: async () => {
        let calendarApi = refs.eventCalendar.getApi()
        calendarApi.gotoDate(new Date)
        handlePinsOnDayChange()
      }
    },
  }
})
const snackbar = ref({})
const calendarLoading = ref(false)
const includeCancelled = ref(false)
const calendarInitialRender = ref(true)
const calendarApi = ref(null)
const calendarStart = ref(null)
const calendarView = ref(null)
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

const mapResourceEvents =  ref([])
const checkedResources =  ref([])
const daySelector =  ref(false)
const dayOptions =  ref([])
const timezone =  ref(store.state.schedule.timezone.value || store.state.user.details.timezone.value)
const timezones = ref([
  { friendlyValue: 'US/Pacific', value: 'America/Los_Angeles'},
  { friendlyValue: 'US/Alaska', value: 'America/Anchorage'},
  { friendlyValue: 'US/Arizona', value: 'America/Phoenix'},
  { friendlyValue: 'US/Central', value: 'America/Chicago'},
  { friendlyValue: 'US/Hawaii', value: 'Pacific/Honolulu'},
  { friendlyValue: 'US/Eastern', value: 'America/New_York'},
  { friendlyValue: 'US/Mountain', value: 'America/Denver'}
])


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
// const firstDayOption = computed(() => {
//   return moment.utc(calendarStartTime.value).format('dddd MMM Do, YYYY')
// })
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const countSelected = computed(() => {
  return selectedOrgs.value?.length + selectedUsers.value?.length
})

    onMounted (async () => {
      calendarApi.value = refs.eventCalendar.getApi()
      calendarStart.value = calendarApi.value.getDate()
      setCalendarStartAndEndTimes()
      await getSchedulingOrgs()
      await getSchedulingUsers()
      await fetchSchedulingOrgTypes()
      await getPositions()
      if(props.preselectedEvent){
        filterOrgsAndUsers()
      }
    })
    watch(() => store.state.schedule.timezone.value, (value) => {
        //when the schedule timezone value changes, update the calendar plugin's timezone
        let calendarApi = refs.eventCalendar.getApi()
        calendarApi.setOption('timeZone', store.state.schedule.timezone.value)
      })
      watch(() => store.state.user.details.timezone, () => {
        //when the app timezone changes, update the schedule timezone to match
        timezone.value = store.state.user.details.timezone
        debugger
      })
      watch(timezone, () => {
        //when the value of the timezone changes (either via the time zone dropdown selector or a change in the user store timezone value),
        // update the timezone for the schedule page
        changeTimezone(timezone.value)
      })

      // whenever selectedUsers or selectedOrgs changes, concat them both into resources
    watch(selectedUsers, () => {
        calendarOptions.value.resources = selectedOrgs.value.concat(selectedUsers.value)
        handleResourceColors()
      })
      watch(selectedOrgs, () => {
        calendarOptions.value.resources = selectedOrgs.value.concat(selectedUsers.value)
        handleResourceColors()
        refs.orgSelector.setSearch('')//prevents weird scroll bug
      })
      watch(calendarStartTime, (newStartTime, oldStartTime) => {
        if(newStartTime !== oldStartTime) {
          getDayOptions()
        }
      })
      watch(calendarEndTime, (newEndTime, oldEndTime) => {
        if(newEndTime !== oldEndTime) {
          getDayOptions()
        }
      })

      const reloadCalendar = () =>{
        let calendarApi = refs.eventCalendar.getApi()
        calendarApi.refetchEvents()
      }
      const isResourceOnMap = (resource) => {
        return props.mapResources.findIndex(mr => resource.id === mr.id) >=0
      }
      const isAssignedResource = (resource) => {
        let result = false
        const selectedResourceId = store.state.schedule.selectedResourceId
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
      const getDayOptions = () => {
        let options = []
        const startDate = calendarApi.value?.view.activeStart
        const endDate = calendarApi.value?.view.activeEnd

        if(startDate && endDate) {
          let i = startDate
          while (moment(endDate).isAfter(i)) {
            let dayOption = {
              rawDate: i,
              formattedDate: moment.utc(i).format('dddd MMM Do, YYYY')
            }
            options.push(dayOption)
            i = moment(i).add(1, 'days')
          }
        }
        dayOptions.value = options
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
        store.commit(AppMutations.SET_LOADING, true)
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
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Retrieving Orgs')
          store.commit(AppMutations.SHOW_SNACK, snackbar.value)
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const fetchSchedulingOrgTypes = async() => {
        store.commit(AppMutations.SET_LOADING, true)
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
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Retrieving Org Types')
          store.commit(AppMutations.SHOW_SNACK, snackbar)
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const getPositions = async() => {
        store.commit(AppMutations.SET_LOADING, true)
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
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Retrieving Positions')
          store.commit(AppMutations.SHOW_SNACK, snackbar.value)
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const getSchedulingUsers = async() => {
        store.commit(AppMutations.SET_LOADING, true)
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
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Retrieving Users')
          store.commit(AppMutations.SHOW_SNACK, snackbar)
          store.commit(AppMutations.SET_LOADING, false)
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

      const handlePinsOnDayChange = () => {
        mapResourceEvents.value = []
        checkedResources.value.forEach((r, idx) => {
          handlePopulatingMapPins(true, r, false, idx === checkedResources.value.length - 1)
        })
      }
      const handlePopulatingMapPins = (addPin, resource, doCallback) => {
        if(addPin) {
          let calendarApi = refs.eventCalendar.getApi()

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
              color: resource.extendedProps.color,
              coordinates: [ re.extendedProps.longitude, re.extendedProps.latitude],
              start: re.startStr,
              end: re.endStr
            }
            mapResourceEvents.value.push(eventObj)
          })
        } else {
          mapResourceEvents.value = mapResourceEvents.value.filter(r => {
            return r.id !== resource?.id
          })
        }
        if(doCallback) {
          props.callback(mapResourceEvents.value, addPin)
        }
        let calendarApi = refs.eventCalendar.getApi()
      }


      //calendar event functions
      const getAvailability = async(info) => {
        try {
          let params = {
            orgIds: selectedOrgs.value?.length > 0 ? selectedOrgs.value.map(o => o.masterId) : [],
            userIds: selectedUsers.value?.length > 0 ? selectedUsers.value.map(u => u.masterId) : [],
            startTime: info.start,
            endTime: info.end,
            timezone: timezone.value.value
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
            d.backgroundColor = 'var(--v-grey-darken1)'



            if(!d.isSlotTime && d.display === 'inverse-background') {
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

            if(d.display === 'background'){
              d.title = d.title + ': ' + moment(d.start).format('h:mm') + '-' + moment(d.end).format('h:mm')
            }
          })

          //we do this for every resource, regardless of if they already have an availability or not
          // if they already have one it still works as it should and doesn't block out the time, but if they
          // dont already have one then this will block/grey out the day so it doesn't look like they are available
          calendarOptions.value.resources.forEach(r => {
            data.push({
              start: moment.utc(info.start).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
              end: moment.utc(info.end).endOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
              title: '',
              display: 'background',
              allDay: false,
              //these values have already been pre-appended with the 1 or 2
              groupId: r.id,
              resourceId: r.id,
              backgroundColor: 'var(--v-grey-darken1)'
            })
          })
          return data;

        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar.value = getSnackbar('ERROR', 'Error Retrieving Availability')
          store.commit(AppMutations.SHOW_SNACK, snackbar)
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const goGetEventsNow = async (info, successCallback, failureCallback) => {
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
              // if resource is a user show on calender using userId so that if they have multiple positions we can load all of them into the same user row on the calendar
              d.resourceId = d.userId ? `${d.systemListTypeId}${d.userId}` : `${d.systemListTypeId}${d.resourceId}`
              d.title = `${d.contactFirstName ?? ''} ${d.contactLastName ?? ''} \n ${d.eventName}`
              d.hoverTitle = `${d.contactFirstName ?? ''} ${d.contactLastName ?? ''} \n ${d.eventName} \n ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`
              let matchingResource = calendarOptions.value.resources.find(r => r.id === d.resourceId)
              if(d.eventStatusTypeId === 3) {
                d.colorForBorder = '#919191'
                d.textColor = '#919191'
              } else {
                d.colorForBorder = matchingResource?.color
                d.textColor = 'var(--v-primary-base)'
                d.classNames=['event-tile', matchingResource?.eventColorClass]
              }
            })
            // console.log('the events: ',data)
            let events = cloneDeep(data)
            events = events.concat(availabilityData)
            successCallback(events)
            calendarLoading.value = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            snackbar.value = getSnackbar('ERROR', 'Error Retrieving Events')
            store.commit(AppMutations.SHOW_SNACK, snackbar.value)
            failureCallback(e)
            calendarLoading.value = false
          } finally {
            orgValuesChanged.value = false
            userValuesChanged.value = false
          }
        }
        successCallback([])
      }
      const handleEventClick = (info) => {
        if(info.event.title && info.event.display === 'auto') {
          let props = info.event.extendedProps
          //open event clicks in new window every time so they dont have to keep reloading the calendar
          let routerData = router.resolve({path: `/project/${props.projectId}/processStep/${props.projectProcessStepId}/event/${props.projectProcessStepEventId}`})
          window.open(routerData.href, '_blank')
        }
      }

      const changeTimezone = async (tz) => {
        //update the timezone in the schedule store
        await store.dispatch(ScheduleActions.CHANGE_TIMEZONE, tz)
      }

      const getFormattedDate = (date) => {
        //used for formatting the start/end for the hoverTitle
        return filters.formatDate(date, 'timestamp', 'h:mm a')
      }
      const setCalendarStartAndEndTimes = () => {
        calendarStart.value = calendarApi.value.getDate()
        calendarView.value = calendarApi.value.view?.type
        if(calendarView.value === 'resourceTimelineDay') {
          calendarStartTime.value = moment(calendarStart.value).startOf('d').utc().format('YYYY-MM-DD HH:mm:ss')
          calendarEndTime.value = moment(calendarStart.value).add(1, 'd').startOf('d').subtract(1, 's').utc().format('YYYY-MM-DD HH:mm:ss')
        } else {
          //moment starts on sunday, isoWeek starts on monday
          calendarStartTime.value = moment(calendarStart.value).startOf('isoWeek').utc().format('YYYY-MM-DD HH:mm:ss')
          calendarEndTime.value = moment(calendarStart.value).endOf('isoWeek').utc().format('YYYY-MM-DD HH:mm:ss')
        }
        store.commit(ScheduleMutations.SET_START_TIME, calendarStartTime.value)
        store.commit(ScheduleMutations.SET_END_TIME, calendarEndTime.value)
        props.dateCallback(calendarStartTime.value, calendarEndTime.value)
      }

</script>

<style lang="scss">

.event-tile{
  border-left-width: 20px;
  height: 20px;
}

#calendar-container .fc-toolbar-title {
  @media(max-width: 960px) {
    font-size: 1.25rem;
  }
}
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
  opacity: 1;
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


  #calendar-container .fc-event.event-tile:hover {
    color: inherit !important;
    max-width: unset;
    width: fit-content;
    -webkit-box-shadow: 2px 3px 5px 0px rgba(145,147,147,1);
    -moz-box-shadow: 2px 3px 5px 0px rgba(145,147,147,1);
    box-shadow: 2px 3px 5px 0px rgba(145,147,147,1);
    z-index: 5;

    span {
      max-width: unset;
      width: fit-content;
      padding-right: 4px;
    }
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
</style>

<style lang="scss" scoped>
.resource-title {
  text-overflow: ellipsis;
  max-width: 60%;
  @media(max-width: 960px) {
    max-width: 30%;
  }
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
  @media(max-width: 960px) {
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


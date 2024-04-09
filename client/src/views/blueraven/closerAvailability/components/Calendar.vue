<script setup>
import {computed, getCurrentInstance, onMounted, ref, watch} from "vue";
import resourceTimelinePlugin from "@fullcalendar/resource-timeline";
import interaction from "@fullcalendar/interaction";
import momentTimezonePlugin from "@fullcalendar/moment-timezone";
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, getEventColorClass} from '@/helpers/helpers'
import moment from "moment/moment.js";
import {ScheduleMutations} from "@/stores/ScheduleStore.js";
import constants from "@/helpers/constants.js";
import FullCalendar from "@fullcalendar/vue";
import cloneDeep from "lodash.clonedeep";
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const refs = vueInstance.$refs
const filters = vueInstance.$filters
const router = vueInstance.$router

const emit = defineEmits(['scheduleResource', 'unscheduleResource'])

// Calendar Info
const calendarApi = ref(null)
const calendarStart = ref(null)
const calendarView = ref(null)
const calendarStartTime = ref(null)
const calendarEndTime = ref(null)
const calendarLoading = ref(false)

const maxSelectionAllowed = ref(10)
const countErrorMessage = ref('Maximum Selection Reached')

const timezoneFriendly = computed(() => {
  return store.state.schedule.timezone?.value
})

const calendarOptions = ref({
  plugins: [
    resourceTimelinePlugin, interaction, momentTimezonePlugin
  ],
  schedulerLicenseKey: constants.FULL_CALENDAR_LICENSE_KEY,
  initialView: 'resourceTimelineDay',
  firstDay: 1,
  resources: [],
  resourceAreaWidth: 300,
  eventSources:[
    (info, successCallback, failureCallback) => getEventSources(info, successCallback, failureCallback)
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
    left: 'prev,customToday,next',
    center: 'title',
    right: vuetify.breakpoint.mdAndUp ? 'resourceTimelineDay,resourceTimelineWeek': ''
  },
  slotMinWidth:40,
  slotMinTime:"04:00:00",
  slotMaxTime:"23:00:00",
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
  timeZone: timezoneFriendly.value || {},

  customButtons: {
    customToday: {
      text: 'Today',
      click: async () => {
        let calendarApi = refs.eventCalendar.getApi()
        calendarApi.gotoDate(new Date)
      }
    },
  }
})

const reloadCalendar = () =>{
  let calendarApi = refs.eventCalendar.getApi()
  calendarApi.refetchEvents()
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
}

const handleEventClick = (info) => {
  if(info.event.title && info.event.display === 'auto') {
    let props = info.event.extendedProps
    //open event clicks in new window every time so they dont have to keep reloading the calendar
    let routerData = router.resolve({path: `/project/${props.projectId}/processStep/${props.projectProcessStepId}/event/${props.projectProcessStepEventId}`})
    window.open(routerData.href, '_blank')
  }
}

watch(() => timezoneFriendly, (value) => {
  //when the schedule timezone value changes, update the calendar plugin's timezone
  calendarApi.value.setOption('timeZone', timezoneFriendly.value)
})


// ----------------------------------------------------------------------------------

// Round Robin Filter
const roundRobins = ref([]) //list values for autocomplete
const selectedRoundRobins = ref([]) //selected values - set by autocomplete
const roundRobinValueChanged = ref(false) //field dirty - set on autocomplete input
const roundRobinsLoading = ref(true) //controls loading state of autocomplete
//method to get roundRobins list values (called on mounted)
const getRoundRobins = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/roundRobin/forUser`)
    roundRobins.value = data
    roundRobinsLoading.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Round Robins')
    appStore.loading = false
  }
}
// ----------------------------------------------------------------------------------
// Round Robin Users
const roundRobinUsers = ref([]) //list values for autocomplete
const selectedUsers = ref([])
const usersLoading = ref(true)
const userValuesChanged = ref(false)
const masterUsers = ref([]) //?

watch(selectedUsers, () => {
  calendarOptions.value.resources = selectedUsers.value
  handleResourceColors()
  reloadCalendar()
})

const getRoundRobinUsers = async() => {
    roundRobinUsers.value = []
  appStore.loading = true
    try {
      let params = {
        roundRobinIds: selectedRoundRobins.value?.length > 0 ? selectedRoundRobins.value.map(z => z.id) : null
      }
      const {data, status} = await postRequest(`/roundRobin/usersByDownline`, params, null, [])
      roundRobinUsers.value = data
      usersLoading.value = false
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Users')
      appStore.loading = false
    }
  }

const selectAllRoundRobinUsers = computed(() => roundRobinUsers.value.length === selectedUsers.value.length)
const selectSomeRoundRobinUsers = computed(() => selectedUsers.value.length > 0 && !selectAllRoundRobinUsers.value)
const iconRoundRobinUsers = computed(() => {
  if (selectAllRoundRobinUsers.value) {
    return 'check_box'
  }
  if (selectSomeRoundRobinUsers.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})

const toggleSelectAllRoundRobinUsers = () => {
  if (selectAllRoundRobinUsers.value) {
    selectedUsers.value = []
  } else {
    selectedUsers.value = cloneDeep(roundRobinUsers.value)
  }
  reloadCalendar()
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
// ----------------------------------------------------------------------------------

const getEventSources = async(info, successCallback, failureCallback) => {
  //dont reload events if they deselected all of one type
  //and only load if the selected values changed
  if (selectedUsers.value?.length > 0) {
      //i do this here instead of on its own because all of the code above here has to happen for get availability as well
      calendarLoading.value = true
      const availabilityData = await getAvailability(info)

      try {
        let params = {
          // this was the old way. leaving here in case
          // userPositionIds: this.getUserPositionIds(),
          userIds: selectedUsers.value?.length > 0 ? selectedUsers.value.map(u => u.userId) : [],
          startTime: info.start,
          endTime: info.end
        }
        const {data} = await postRequest(`/schedule`, params, null, [])
        let additionalRecords = []
        data?.forEach(d => {
          d.id = d.eventId
          // d.resourceId = `${d.systemListTypeId}${d.resourceId}`
          // if resource is a user show on calendar using userId so that if they have multiple positions we can load all of them into the same user row on the calendar
          d.title = `${d.contactFirstName ?? ''} ${d.contactLastName ?? ''} ${d.eventName} ${d.eventName} ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`
          d.hoverTitle = `${d.contactFirstName ?? ''} ${d.contactLastName ?? ''} \n ${d.eventName} \n ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`
          //get all selected users who match the appt user_id
          let matchingUsers = selectedUsers.value.filter(r => r.userId === d.userId)
          // if there is more than one selected user with that user ID then add another record for the additional user
          if (matchingUsers?.length > 1) {
            matchingUsers.forEach((mu, idx) => {
              //if it is the first matching user then just update the existing data record
              if (idx === 0) {
                d.resourceId = mu.id
                d.title = `${d.projectName ?? ''} ${d.groupName ?? ''}\n ${d.eventName} \n ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`
                d.colorForBorder = mu.color
                d.textColor = 'var(--v-primary-base)'
                d.classNames=['event-tile', mu?.eventColorClass]
              } else {
                //otherwise need to add a record to data
                let newRecord = cloneDeep(d)
                newRecord.resourceId = mu.id
                newRecord.title = `${newRecord.projectName ?? ''} ${newRecord.groupName ?? ''}\n ${d.eventName} \n ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`
                newRecord.colorForBorder = mu.color
                additionalRecords.push(newRecord)
                d.textColor = 'var(--v-primary-base)'
                d.classNames=['event-tile', mu?.eventColorClass]
              }
            })
          } else if (matchingUsers.length === 1) {
            d.resourceId = matchingUsers[0].id
            d.title = `${d.projectName ?? ''} ${d.groupName ?? ''}\n ${d.eventName} \n ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`
            d.colorForBorder = matchingUsers[0].color
            d.textColor = 'var(--v-primary-base)'
            d.classNames=['event-tile', matchingUsers[0].eventColorClass]
          }
          //it shouldn't be possible to not have a matching user, but if it doesn't match we just wont do anything and see what happens
        })

        let events = availabilityData.concat(data).concat(additionalRecords)
        successCallback(events)
        calendarLoading.value = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Retrieving Events')
        failureCallback(e)
        calendarLoading.value = false
      } finally {
        userValuesChanged.value = false
        roundRobinValueChanged.value = false
      }
    }
    successCallback([])
}

const getAvailability = async(info) => {
  try {
    let params = {
      //can't change postalCodeZoneUserIds name because that is what mobile sends in
      postalCodeZoneUserIds: selectedUsers.value?.length > 0 ? selectedUsers.value.map(u => u.id) : [],
      startTime: info.start,
      endTime: info.end,
      timezone: info.timeZone
    }
    console.log(info.timeZone)
    const {data} = await postRequest(`/closerAvailability`, params, 'blueraven', [])
    data.forEach(d => {
      if (d.allDay) {
        d.start = moment.utc(d.start).format('YYYY-MM-DD')
        d.end = moment.utc(d.end).format('YYYY-MM-DD')
      }
      //todo: should probably find where this is coming from on the back end and fix it there
      if(d.rendering){
        d.display = d.rendering
      }
      d.groupId = `${d.resourceId}`
      d.resourceId = `${d.resourceId}`
      d.backgroundColor = 'rgba(0,0,0,.25)'
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

      if(d.display === 'background' || d.display === 'auto'){
        d.display = 'auto'
        d.title = d.title + ': ' + moment(d.start).format('h:mm') + '-' + moment(d.end).format('h:mm')
        d.textColor='rgba(0,0,0,0.87)'

      }
  })

    //we do this for every resource, regardless of if they already have an availability or not
    // if they already have one it still works as it should and doesn't block out the time, but if they
    // dont already have one then this will block/grey out the day so it doesn't look like they are available
    selectedUsers.value.forEach(r => {
      data.push({
        start: moment.utc(info.start).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
        end: moment.utc(info.start).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
        title: '',
        display: 'inverse-background',
        allDay: false,
        //these values have already been pre-appended with the 1 or 2
        groupId: r.id,
        resourceId: r.id,
        backgroundColor: 'rgba(0,0,0,.25)'
      })
    })
    return data;

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Availability')
    appStore.loading = false
  }
}

const countSelected = computed(() => {
  return selectedUsers.value?.length
})

const limiter = () => {
  roundRobinUsers.value.forEach(u => {
    let match = selectedUsers.value.find(su => su.id === u.id)
    u.disabled = !match && countSelected.value >= maxSelectionAllowed.value
  })
}

const getFormattedDate = (date) => {
  //used for formatting the start/end for the hoverTitle
  return filters.formatDate(date, 'timestamp', 'h:mm a')
}

onMounted (async () => {
  calendarApi.value = refs.eventCalendar.getApi()
  calendarStart.value = calendarApi.value.getDate()
  setCalendarStartAndEndTimes()
  await getRoundRobins()
  await getRoundRobinUsers()
})

</script>

<template>
  <div id="closer-availability-calendar-container">
    <div id="calendar-filter-container" class="pa-6 pt-4">
  <v-row class="py-0 d-flex align-baseline">
    <v-col class="py-0" >
      <v-autocomplete v-model="selectedRoundRobins"
                      :items="roundRobins"
                      label="Round Robin"
                      multiple
                      type="search"
                      class="mr-2"
                      :loading="roundRobinsLoading"
                      hide-details
                      return-object
                      @input="roundRobinValueChanged = true"
                      item-text="roundRobinName"
                      @blur="getRoundRobinUsers(selectedRoundRobins)"
                      item-value="id"
                      attach
      >
        <template v-slot:selection = "{ item, index }">
          <div v-if="index === 0 && selectedRoundRobins.length < 3">
            <v-chip small close @click:close="selectedRoundRobins.splice(index, 1)"
                    v-for="sr in selectedRoundRobins">
              <span>{{ sr.roundRobinName }}</span>
            </v-chip>
          </div>
          <span
              v-if="index === 1 && selectedRoundRobins.length >= 3"
              class="primary--text text-caption"
          >{{ selectedRoundRobins.length }} selected</span>
        </template>
      </v-autocomplete>

    </v-col>
    <!--        <v-col id="placeholder-col-2" v-if="$vuetify.breakpoint.smOnly" cols="4" md="0" class="py-0"/>-->
    <v-col id="user-resources-col" class="py-0">
      <v-autocomplete ref="pczuSelect"
                      v-model="selectedUsers"
                      :items="roundRobinUsers"
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
                      attach
      >
        <template v-slot:selection = "{ item, index }">
              <span v-if="index === 0" class="primary--text text-caption">
                {{ selectedUsers.length }} selected
              </span>
        </template>
        <template v-slot:prepend-item>
          <v-list-item
              v-if="roundRobinUsers.length <= 20"
              ripple
              @click="toggleSelectAllRoundRobinUsers()">
            <v-list-item-action>
              <v-icon>{{ iconRoundRobinUsers }}</v-icon>
            </v-list-item-action>
            <v-list-item-title>Select All</v-list-item-title>
          </v-list-item>
          <v-divider
              v-if="roundRobinUsers.length <= 20"
              class="mt-2"
          ></v-divider>
        </template>

      </v-autocomplete>
    </v-col>
  </v-row>
    </div>
    <div class="calendar-resize-container background-white pa-6">
      <div id="calendar-loader" v-if="calendarLoading">
        <v-progress-circular
            indeterminate
            :size="80"
            :color="'primary'"
        ></v-progress-circular>
      </div>
    <FullCalendar ref="eventCalendar" id="closer-availability-calendar" :options="calendarOptions">
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

#closer-availability-calendar-container .fc-toolbar-title {
  @media(max-width: 960px) {
    font-size: 1.25rem;
  }
}
//add space for scrollbar so it doesn't block times
#closer-availability-calendar-container > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th:nth-child(1) > div > div > table > thead > tr > th,
#closer-availability-calendar-container > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th > div > div > div > table > tbody > tr.fc-timeline-header-row.fc-timeline-header-row-chrono > th {
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


#closer-availability-calendar-container .fc-timeline-event {
  /*height: inherit;*/
  border-radius: 5px;
  padding-left: 7px;
}

#closer-availability-calendar-container .cancelled-event-switch label {
  font-size: 12px;
}

#closer-availability-calendar-container .cancelled-event-switch .v-input--selection-controls__input {
  transform: scale(0.775);
  transform-origin: center;
}

#closer-availability-calendar-container .fc-rows tr,
#closer-availability-calendar-container .fc-rows tr .fc-widget-content div{
  padding: 5px 0 !important;

}

#closer-availability-calendar-container .fc-rows tr,
#closer-availability-calendar-container .fc-rows tr .fc-widget-content{
  height: auto !important;
}

#closer-availability-calendar-container .fc-cell-content {
  padding-top: 0;
  padding-bottom: 0;
}

#closer-availability-calendar-container > div.calendar-resize-container > div > div.fc-view-container > div > table > tbody > tr > td.fc-time-area.fc-widget-content > div > div > div > div.fc-content > div > table > tbody > tr > td > div > div.fc-bgevent-container > div {
  color: white !important;
  font-size: 0.875rem !important;
}

.event-style{
  background-image: linear-gradient(to right, purple 20px, rgba(0,0,0,0) 20px) !important;
}

#closer-availability-calendar {
  position: relative;
  z-index: 0;
  //  this keeps the calendar from being in front of the filter dropdowns.
}

#closer-availability-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th > div > div > div > table > tbody > tr > th.fc-slot > div > a.fc-timeline-slot-cushion{
  cursor: default !important;
  color: var(--v-grey-darken1)
}
#closer-availability-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th > div > div{
  ::-webkit-scrollbar {
    height: 0 !important;  /* Remove scrollbar space */
    background: transparent !important;  /* Optional: just make scrollbar invisible */
  }
}
//thickening and darkening the day dividers on week view of calendar
#closer-availability-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th:nth-child(3) > div > div > div > table > tbody > tr:nth-child(1) > th.fc-timeline-slot.fc-timeline-slot-label.fc-day,
#closer-availability-calendar > div.fc-view-harness.fc-view-harness-active > div > table > thead > tr > th:nth-child(3) > div > div > div > table > tbody > tr.fc-timeline-header-row.fc-timeline-header-row-chrono > th:nth-child(19n+1),
#closer-availability-calendar > div.fc-view-harness.fc-view-harness-active > div.fc-resourceTimelineWeek-view.fc-view.fc-resource-timeline.fc-resource-timeline-flat.fc-timeline.fc-timeline-overlap-enabled > table > tbody > tr > td:nth-child(3) > div > div > div > div.fc-timeline-slots > table > tbody > tr > td:nth-child(19n+1) {
  border-left-width: 3px;
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

#closer-availability-calendar-container {
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
  background-color: var(--v-grey-lighten4)
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

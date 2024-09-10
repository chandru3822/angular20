<script setup>
/*
*@name ScheduleSingleUserView
*@author jess
*@date 6/11/24
*
*@description
*
*/

import FullCalendar from "@fullcalendar/vue";
import momentTimezonePlugin from "@fullcalendar/moment-timezone";
import timeGridPlugin from '@fullcalendar/timegrid'
import {computed, getCurrentInstance, ref, toRefs} from "vue";
import {postRequest} from "@/helpers/helpers.js";
import cloneDeep from "lodash.clonedeep";
import moment from "moment/moment.js";
import {useUserStore} from "@/stores/UserStore.js";
import {useAppStore} from "@/stores/AppStore.js";
import {useRouter} from "vue-router/composables";

const props = defineProps({
  userId: Number
})
const {userId} = toRefs(props)
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const filters = vueInstance.$filters
const userStore = useUserStore()
const appStore = useAppStore()
const router = useRouter()
const vuetify = vueInstance.$vuetify
const userScheduleCalendar = ref(null)

const calendarLoading = ref(false)
const calendarApi = ref(null)

const userTimezone = computed(() => userStore.timezone)


const calendarOptions = ref({
  plugins: [timeGridPlugin],
  initialView: 'timeGridWeek',
  headerToolbar:{
    left: vuetify.breakpoint.mdAndUp ? 'prev,customToday,next': 'prev,next',
    center: 'title',
    right: vuetify.breakpoint.mdAndUp ? 'timeGridDay,timeGridWeek': ''
  },
  allDaySlot: false,
  slotMinTime:"04:00:00",
  slotMaxTime:"23:00:00",
  titleFormat:{ month: vuetify.breakpoint.smAndDown ? 'short' : 'long',
    year: 'numeric',
    day: 'numeric',
    weekday: vuetify.breakpoint.smAndDown ? 'short' : 'long'
  },
  nowIndicator:true,
  views:{
    timeGridDay:{
      titleFormat:{ month: 'short',
        year: 'numeric',
        day: 'numeric',
        weekday: 'short'
      }
    },
    timeGridWeek:{
      titleFormat:{ month: 'short',
        year: 'numeric',
        day: 'numeric'
      },
      slotMinWidth:76,
    }
  },
  customButtons: {
    customToday: {
      text: 'Today',
      click: async () => {
        let calendarApi = userScheduleCalendar.value.getApi()
        calendarApi.gotoDate(new Date)
      }
    }
  },
  eventSources:[
    (info, successCallback, failureCallback) => goGetEventsNow(info, successCallback, failureCallback)
  ],
  eventClick: (eventClickInfo) => handleEventClick(eventClickInfo),
})

const goGetEventsNow = async (info, successCallback, failureCallback) => {
  if (userId.value) {
    //i do this here instead of on its own because all of the code above here has to happen for get availability as well
    // calendarLoading.value = true
    const availabilityData = await getAvailability(info);
    try {
      let params = {
        userIds: [userId.value],
        startTime: info.start,
        endTime: info.end,
        includeCancelled: false,
        orgIds: []
      }
      const {data} = await postRequest(`/schedule`, params)
      data.forEach(d => {
        d.id = d.eventId
        // d.resourceId = `${d.systemListTypeId}${d.resourceId}`
        // if resource is a user show on calendar using userId so that if they have multiple positions we can load all of them into the same user row on the calendar
        d.title = `${d.contactFirstName ?? ''} ${d.contactLastName ?? ''} \n ${d.eventName} \n ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`
        d.hoverTitle = `${d.contactFirstName ?? ''} ${d.contactLastName ?? ''} \n ${d.eventName} \n ${getFormattedDate(d.start)} - ${getFormattedDate(d.end)}`

      })
      let events = cloneDeep(data)
      events = events.concat(availabilityData)
      successCallback(events)
      calendarLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Events')
      failureCallback(e)
      calendarLoading.value = false
    }
  }
  calendarLoading.value = false
  successCallback([])
}
const getAvailability = async(info) => {
  try {
    let params = {
      userIds: [userId.value],
      startTime: info.start,
      endTime: info.end,
      timezone: userTimezone.value.value
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
      data.push({
        start: moment.utc(info.start).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
        end: moment.utc(info.start).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
        title: '',
        display: 'inverse-background',
        allDay: false,
        backgroundColor: 'rgba(0,0,0,.12)'
      })
    return data;

  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Availability')
    appStore.loading = false
  }
}

const updateEvents = () => {
  calendarApi.value.refetchEvents()
}
const handleEventClick = (info) => {
  if(info.event.title && info.event.display === 'auto' && info.event.extendedProps?.projectProcessStepId) {
    let props = info.event.extendedProps
    //open event clicks in new window every time so they dont have to keep reloading the calendar
    let routerData = router.resolve({path: `/project/${props.projectId}/processStep/${props.projectProcessStepId}/event/${props.projectProcessStepEventId}`})
    window.open(routerData.href, '_blank')
  }
}

const getFormattedDate = (date) => {
  //used for formatting the start/end for the hoverTitle
  return filters.formatDate(date, 'timestamp', 'h:mm a')
}

</script>

<template>
  <div class="calendar-resize-container background-white pa-6 height-one-hunned">
    <div id="calendar-loader" v-if="calendarLoading">
      <v-progress-circular
          indeterminate
          :size="80"
          :color="'primary'"
      ></v-progress-circular>
    </div>
    <FullCalendar ref="userScheduleCalendar" id="user-schedule-calendar" :options="calendarOptions">
      <template v-slot:eventContent="{event}">
        <v-tooltip bottom :open-on-hover="!$vuetify.breakpoint.smAndDown" :open-on-click="false">
          <template v-slot:activator="{ on, attrs }">
            <span v-if="event.title !== 'null'" v-bind="attrs" v-on="on" class="event-title body-medium">{{event.title}}</span>
          </template>
          <span>{{event.title}}</span>
        </v-tooltip>
        <!--yes, 'null' is intentionally a string because that's how it comes back from the calendar-->
      </template>
    </FullCalendar>
  </div>

</template>

<style scoped lang="scss">
#user-schedule-calendar {
  height: 100%;
}
.v-tooltip__content {
  background-color: white;
  color: var(--v-grey-darken4);
  outline-color: black;
}
.background-white {
  background-color: white;
}
</style>
<style lang="scss">
#user-schedule-calendar > div.fc-view-harness.fc-view-harness-active > div > table > tbody > tr > td > div > div > div > div.fc-timegrid-cols > table > tbody > tr > td.fc-day.fc-timegrid-col > div > div > div.fc-timegrid-event-harness {
  overflow:clip;
}

#user-schedule-calendar > div.calendar-resize-container > div > div.fc-view-container > div > table > tbody > tr > td.fc-time-area.fc-widget-content > div > div > div > div.fc-content > div > table > tbody > tr > td > div > div.fc-bgevent-container > div {
  color: white !important;
  font-size: 0.875rem !important;
}
</style>

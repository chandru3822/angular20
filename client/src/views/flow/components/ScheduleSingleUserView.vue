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

const props = defineProps({
  userId: Number
})
const {userId} = toRefs(props)
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const filters = vueInstance.$filters
const userStore = useUserStore()
const appStore = useAppStore()
const vuetify = vueInstance.$vuetify
const userScheduleCalendar = ref(null)

const calendarLoading = ref(false)
const calendarApi = ref(null)

const userTimezone = computed(() => userStore.timezone)


const calendarOptions = ref({
  plugins: [timeGridPlugin],
  initialView: 'timeGridDay',
  headerToolbar:{
    left: 'title',
    right:vuetify.breakpoint.mdAndUp ? 'prev,customToday,next': 'prev,next'
  },
  allDaySlot: false,
  slotMinTime:"04:00:00",
  slotMaxTime:"23:00:00",
  titleFormat:{ month: vuetify.breakpoint.smAndDown ? 'short' : 'long',
    year: 'numeric',
    day: 'numeric',
    weekday: vuetify.breakpoint.smAndDown ? 'short' : 'long'
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
<!--      <template v-slot:resourceAreaHeaderContent>-->
<!--        <div class="d-flex justify-space-between align-baseline">-->
<!--          <span>Resources</span>-->
<!--          <div>-->
<!--            <v-tooltip bottom :open-on-hover="!$vuetify.breakpoint.smAndDown" :open-on-click="false">-->
<!--              <template v-slot:activator="{on}">-->
<!--                <a-btn icon size="small" @click="toggleMapPinsForAllResources(!allResourcesOnMap)" :activation-handler="on" class="mx-1">-->
<!--                  <v-icon color="grey darken-3"  v-if="allResourcesOnMap">mdi-map-marker</v-icon>-->
<!--                  <v-icon color="grey darken-1" v-else>mdi-map-marker-off</v-icon>-->
<!--                </a-btn>-->
<!--              </template>-->
<!--              <span v-if="allResourcesOnMap">Remove all from map</span>-->
<!--              <span v-else>Pin all on map</span>-->
<!--            </v-tooltip>-->
<!--          </div>-->
<!--        </div>-->
<!--      </template>-->
<!--      <template v-slot:resourceLabelContent="{resource, index}">-->
<!--        <div class="d-flex justify-space-between align-baseline">-->
<!--          <a v-if="resource.id.charAt(0)==='1'" :href="`${getHostUrl()}/org/${resource.id.substring(1)}`" target="_blank" class="body-large overflow-hidden resource-title text-decoration-none">{{resource.title}}</a>-->
<!--          <a v-else :href="`${getHostUrl()}/user/${resource.id.substring(1)}/details`" target="_blank" class="body-large overflow-hidden resource-title text-decoration-none">{{ resource.title }}</a>-->
<!--          <div>-->
<!--            <v-tooltip bottom :open-on-hover="!$vuetify.breakpoint.smAndDown" :open-on-click="false">-->
<!--              <template v-slot:activator="{on}">-->
<!--                <a-btn icon size="small" @click="toggleMapPinForResource(resource)" :activation-handler="on" class="mx-1">-->
<!--                  <v-icon :color="resource.extendedProps.color"  v-if="isResourceOnMap(resource) || allResourcesOnMap">mdi-map-marker</v-icon>-->
<!--                  <v-icon color="grey darken-1" v-else>mdi-map-marker-off</v-icon>-->
<!--                </a-btn>-->
<!--              </template>-->
<!--              <span v-if="isResourceOnMap(resource)">Remove pin from map</span>-->
<!--              <span v-else>Pin on map</span>-->
<!--            </v-tooltip>-->
<!--            <v-tooltip bottom :open-on-hover="!$vuetify.breakpoint.smAndDown" :open-on-click="false">-->
<!--              <template v-slot:activator="{on}">-->
<!--                <a-btn v-if="resource.id.charAt(0)==='2' && !isSidebarView && userCanSms" icon size="small" @click="[showMessagingDialog = true, userToMessage = {userId: Number(resource.id.substring(1)), title:resource.title}]" :activation-handler="on" class="mx-1">-->
<!--                  <v-icon color="grey darken-1">mdi-forum</v-icon>-->
<!--                </a-btn>-->
<!--              </template>-->
<!--              <span>Message Resource</span>-->
<!--            </v-tooltip>-->
<!--            <v-tooltip bottom :open-on-hover="!$vuetify.breakpoint.smAndDown" :open-on-click="false">-->
<!--              <template v-slot:activator="{on}">-->
<!--                <a-btn v-if="showScheduleBtnForResource(resource)" icon size="small" :color="isAssignedResource(resource) ? 'primary lighten-5' : 'grey darken-1'" class="mx-1" @click="toggleScheduleResource(resource)" :activation-handler="on">-->
<!--                  <v-icon>mdi-calendar-plus</v-icon>-->
<!--                </a-btn>-->
<!--              </template>-->
<!--              {{isAssignedResource(resource) ? 'Remove Resource' : 'Assign to Event' }}-->
<!--            </v-tooltip>-->
<!--            <a-btn icon size="small" color="grey darken-1" class="mx-1" @click="closeResource(resource)"><v-icon>close</v-icon></a-btn>-->
<!--          </div>-->
<!--        </div>-->
<!--      </template>-->
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

</template>

<style scoped lang="scss">
#user-schedule-calendar {
  height: 100%;

}
</style>

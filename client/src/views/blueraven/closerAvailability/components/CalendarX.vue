<template>
  <div id="calendar-container">
    <div class="mb-2">
      <!-- if this row is not wrapped in a div then the calendar doesn't size well on refresh. i have no clue why -->
      <v-row class="py-0">
        <v-col cols="12" md="6">
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
            <template
                slot="selection"
                slot-scope="{ item, index }"
            >
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
        <v-col>
          <v-col id="user-resources-col" class="py-0">
            <v-autocomplete v-model="selectedUsers"
                            :items="roundRobinUsers"
                            label="User Resources"
                            multiple
                            clearable
                            :hide-details="countSelected < maxSelectionAllowed"
                            :error="countSelected >= maxSelectionAllowed"
                            :error-messages="countSelected >= maxSelectionAllowed ? countErrorMessage : null"
                            :loading="roundRobinUsersLoading"
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
            </v-autocomplete>
          </v-col>

          <v-autocomplete ref="pczuSelect"
                          v-model="selectedRoundRobinUsers"
                          :items="roundRobinUsers"
                          label="Users"
                          multiple
                          class="mr-3"
                          :hide-details="countSelected < maxSelectionAllowed"
                          :error="countSelected >= maxSelectionAllowed"
                          :error-messages="countSelected >= maxSelectionAllowed ? countErrorMessage : null"
                          :loading="roundRobinUsersLoading"
                          return-object
                          :item-text="(item) => `${ item.fullName } - ${ item.roundRobinName }`"
                          item-value="id"
                          @input="[roundRobinUserValuesChanged = true, limiter()]"
                          @blur="reloadCalendar"
                          attach
          >
            <template
                slot="selection"
                slot-scope="{ item, index }"
            >
              <div v-if="index === 0 && selectedRoundRobinUsers.length < 3">
                <v-chip small close @click:close="[selectedRoundRobinUsers.splice(idx, 1), limiter()]"
                        v-for="(sr, idx) in selectedRoundRobinUsers">
                  <span>{{ sr.fullName }} - {{sr.roundRobinName}}</span>
                </v-chip>
              </div>
              <span
                  v-if="index === 1 && selectedRoundRobinUsers.length >= 3"
                  class="primary--text text-caption"
              >{{ selectedRoundRobinUsers.length }} selected</span>
            </template>

          </v-autocomplete>
        </v-col>
      </v-row>
    </div>
    <div class="calendar-resize-container">
      <div id="calendar-loader" v-if="calendarLoading">
        <v-progress-circular
            indeterminate
            :size="80"
            :color="'primary'"
        ></v-progress-circular>
      </div>
      <FullCalendar ref="eventCalendar" id="closer-availability-calendar" :options="calendarOptions">
        <template v-slot:resourceLabelContent="{resource, index}">
          Resource {{index}}
        </template>

      </FullCalendar>
    </div>

  </div>
</template>

<script setup>
import '@fullcalendar/core'
import '@fullcalendar/timeline'
import '@fullcalendar/resource-timeline'

import FullCalendar from '@fullcalendar/vue'
import resourceTimelinePlugin from "@fullcalendar/resource-timeline";
import interaction from "@fullcalendar/interaction";

import moment from 'moment'
import cloneDeep from 'lodash.clonedeep'
import momentTimezonePlugin from "@fullcalendar/moment-timezone";
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {computed, getCurrentInstance, onMounted, ref, watch} from "vue";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const vuetify = vueInstance.$vuetify
const refs = vueInstance.$refs
const filters = vueInstance.$filters

const emit = defineEmits(['scheduleResource', 'unscheduleResource'])
const props= defineProps({
  mapResources: {type: Array},
  callback: Function,
  dateCallback: Function,
  states: {type: Array}
})

const calendarOptions = ref({
  plugins: [
    resourceTimelinePlugin, interaction, momentTimezonePlugin
  ],
  initialView: 'resourceTimelineDay',
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
    right: 'resourceTimelineDay,resourceTimelineWeek'
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
      }
    },
  }
})

const snackbar = ref({})
const calendarLoading = ref(false)
// const includeCancelled = ref(false)
const calendarInitialRender = ref(true)
const calendarApi = ref(null)
const calendarStart = ref(null)
const calendarView = ref(null)
const calendarStartTime = ref(null)
const calendarEndTime = ref(null)

const initialLoad = ref(true)



const timezone =  ref(store.state.schedule.timezone.value)

// Round Robin Filter
const roundRobins = ref([]) //list values for autocomplete
const selectedRoundRobins = ref([]) //selected values - set by autocomplete
const roundRobinValueChanged = ref(false) //field dirty - set on autocomplete input
const roundRobinsLoading = ref(true) //controls loading state of autocomplete
//method to get roundRobins list values (called on mounted)
const getRoundRobins = async() => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/roundRobin/forUser`)
    roundRobins.value = data
    roundRobinsLoading.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar.value = getSnackbar('ERROR', 'Error Retrieving Round Robins')
    store.commit(AppMutations.SHOW_SNACK, snackbar.value)
    store.commit(AppMutations.SET_LOADING, false)
  }
}
// ----------------------------------------------------------------------------------
// Round Robin Users Filter
const roundRobinUsers = ref([]) //list values for autocomplete
const selectedRoundRobinUsers = ref([]) //selected values - set by autocomplete
const roundRobinUserValuesChanged = ref(false)//field dirty - set on autocomplete input
const roundRobinUsersLoading = ref(true)
//method to get roundRobinsUsers list values (called on mounted)

const selectedUsers = ref([])
watch(selectedUsers, () => {
  calendarOptions.value.resources = [].concat(selectedUsers.value)
  handleResourceColors()
})



const getRoundRobinUsers = async(roundRobins) => {
  if(roundRobinValueChanged.value || initialLoad.value) {
    roundRobinValueChanged.value = false
    initialLoad.value = false
    roundRobinUsers.value = []
    store.commit(AppMutations.SET_LOADING, true)
    try {
      let params = {
        roundRobinIds: roundRobins?.length > 0 ? roundRobins.map(z => z.id) : null
      }
      const {data, status} = await postRequest(`/roundRobin/usersByDownline`, params, null, [])
      roundRobinUsers.value = data
      roundRobinUsersLoading.value = false
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar.value = getSnackbar('ERROR', 'Error Retrieving Users')
      store.commit(AppMutations.SHOW_SNACK, snackbar.value)
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
// ------------------------------
// Round Robin Users Filter count
const countSelected = computed(() => selectedRoundRobinUsers.length) //count of selected round robin users
const maxSelectionAllowed = ref(10)
const countErrorMessage = ref('Maximum Selection Reached')
// ------------------------------
// Round Robin Users Filter 'Select All' display
const selectAllRoundRobinUsers = computed(() => {
  return roundRobinUsers.value.length === selectedRoundRobinUsers.value.length
})
const selectSomeRoundRobinUsers = computed(() => {
  return selectedRoundRobinUsers.value.length > 0 && !selectAllRoundRobinUsers.value
})
const iconRoundRobinUsers = computed(() => {
  if (roundRobinUsers.value.length === selectedRoundRobinUsers.value.length) {
    return 'check_box'
  }
  if (selectSomeRoundRobinUsers) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
// ----------------------------------------------------------------------------------


onMounted (async () => {
  calendarApi.value = refs.eventCalendar.getApi()
  calendarStart.value = calendarApi.value.getDate()
  setCalendarStartAndEndTimes()
  await getRoundRobins()
  await getRoundRobinUsers()

})

const reloadCalendar = () =>{
  console.log('reload Calendar')
  let calendarApi = refs.eventCalendar.getApi()
  calendarApi.refetchEvents()
}

//vuetify selects/autocompletes have a bug with the select all feature being used at the same time as the @blur event
//the @blur event should only be called when the menu is closed, but in a select all it is called when the select all button is clicked. wreaks havoc.
//this sucks but fixes that issue re: https://github.com/vuetifyjs/vuetify/issues/11488
// watch(() => refs.pczuSelect.isMenuActive, (val) => {
//       // if val is false = blur aka the menu is being closed. true = menu is being opened
//       if(!val && selectedRoundRobinUsers.value.length > 0) {
//         reloadCalendar()
//       }
//     })

watch(() => store.state.user.details.timezone.value, () => {
  calendarApi.setOption('timeZone', store.state.user.details.timezone.value)
})
watch(selectedRoundRobinUsers, () => {
  calendarOptions.value.resources = selectedRoundRobinUsers.value
  props.callback(selectedRoundRobinUsers.value)
  handleResourceColors()
})

const limiter = () => {
  roundRobinUsers.value.forEach(u => {
    let match = selectedRoundRobinUsers.value.find(su => su.id === u.id)
    u.disabled = !match && countSelected.value >= maxSelectionAllowed.value
  })
}
const handleResourceColors = () => {
  selectedRoundRobinUsers.value.forEach((r, index) => {
    r.eventBackgroundColor = '#FFFFFF'
    r.eventBorderColor = '#919191'

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
const toggleSelectAllRoundRobinUsers = () => {
  if (selectAllRoundRobinUsers) {
    selectedRoundRobinUsers.value = []
  } else {
    selectedRoundRobinUsers.value = cloneDeep(roundRobinUsers.value)
  }
}

const getAvailability = async(info) => {
  try {
    let params = {
      //can't change postalCodeZoneUserIds name because that is what mobile sends in
      postalCodeZoneUserIds: selectedRoundRobinUsers.value?.length > 0 ? selectedRoundRobinUsers.value.map(u => u.id) : [],
      startTime: info.start,
      endTime: info.end,
      timezone: timezone.value.value
    }
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
      d.color = 'var(--v-grey-darken1)'
    })

    //we do this for every resource, regardless of if they already have an availability or not
    // if they already have one it still works as it should and doesn't block out the time, but if they
    // dont already have one then this will block/grey out the day so it doesn't look like they are available
    selectedRoundRobinUsers.value.forEach(r => {
      data.push({
        start: moment.utc(info.start).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
        end: moment.utc(info.end).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
        title: '',
        rendering: 'inverse-background',
        allDay: false,
        //these values have already been pre-appended with the 1 or 2
        groupId: r.id,
        resourceId: r.id,
        color: 'var(--v-error-base)'
      })
    })
    return data;

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar.value = getSnackbar('ERROR', 'Error Retrieving Availability')
    store.commit(AppMutations.SHOW_SNACK, snackbar.value)
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getEventSources = async(info, successCallback, failureCallback) => {
  //dont reload events if they deselected all of one type
  //and only load if the selected values changed
  if ((selectedRoundRobinUsers.value?.length > 0 && (roundRobinUserValuesChanged.value || calendarInitialRender.value))) {
    if (!calendarInitialRender.value) {
      setCalendarStartAndEndTimes()
    }
    calendarInitialRender.value = false
    // note: this gets called every render of the calendar which makes clicking the 'day' and 'week' buttons work
    if (selectedRoundRobinUsers.value.length > 0) {
      //i do this here instead of on its own because all of the code above here has to happen for get availability as well
      calendarLoading.value = true
      const availabilityData = await getAvailability()

      try {
        let params = {
          // this was the old way. leaving here in case
          // userPositionIds: this.getUserPositionIds(),
          userIds: selectedRoundRobinUsers.value?.length > 0 ? selectedRoundRobinUsers.value.map(u => u.userId) : [],
          startTime: info.start,
          endTime: info.end
        }
        const {data} = await postRequest(`/schedule`, params, null, [])
        let additionalRecords = []
        data?.forEach(d => {
          //get all selected users who match the appt user_id
          let matchingUsers = selectedRoundRobinUsers.value.filter(r => r.userId === d.userId)

          // if there is more than one selected user with that user ID then add another record for the additional user
          if (matchingUsers?.length > 1) {
            matchingUsers.forEach((mu, idx) => {
              //if it is the first matching user then just update the existing data record
              if (idx === 0) {
                d.resourceId = mu.id
                d.title = `<b>${d.projectName ?? ''}</b> <br/> ${d.groupName}`
                d.colorForBorder = mu.color
              } else {
                //otherwise need to add a record to data
                let newRecord = cloneDeep(d)
                newRecord.resourceId = mu.id
                newRecord.title = `<b>${newRecord.projectName ?? ''}</b> <br/> ${newRecord.groupName}`
                newRecord.colorForBorder = mu.color
                additionalRecords.push(newRecord)
              }
            })
          } else if (matchingUsers.length === 1) {
            d.resourceId = matchingUsers[0].id
            d.title = `<b>${d.projectName ?? ''}</b> <br/> ${d.groupName}`
            d.colorForBorder = matchingUsers[0].color
          }
          //it shouldn't be possible to not have a matching user, but if it doesn't match we just wont do anything and see what happens

        })
        let events = availabilityData.concat(additionalRecords)
        successCallback()
        calendarLoading.value = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar.value = getSnackbar('ERROR', 'Error Retrieving Events')
        store.commit(AppMutations.SHOW_SNACK, snackbar.value)
        failureCallback(e)
        calendarLoading.value = false
      } finally {
        roundRobinUserValuesChanged.value = false
        roundRobinValuesChanged.value = false
      }
    }
    successCallback([])
  }
}
const setCalendarStartAndEndTimes = () => {
  calendarStart.value = calendarApi.value.getDate()
  calendarView.value = calendarApi.value.view?.type
  if(calendarView.value === 'resourceTimelineDay') {
    calendarStartTime.value = moment(calendarStart.value).startOf('d').utc().format('YYYY-MM-DD HH:mm:ss')
    calendarEndTime.value = moment(calendarStart.value).add(1, 'd').startOf('d').utc().format('YYYY-MM-DD HH:mm:ss')
    // this.calendarStartTime = moment(this.calendarStart).tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
    // this.calendarEndTime = moment(this.calendarStart).add(1, 'd').tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
  } else {
    //moment starts on sunday, isoWeek starts on monday
    calendarStartTime.value = moment(calendarStart.value).startOf('isoWeek').utc().format('YYYY-MM-DD HH:mm:ss')
    calendarEndTime.value = moment(calendarStart.value).endOf('isoWeek').utc().format('YYYY-MM-DD HH:mm:ss')
  }
  props.dateCallback(calendarStartTime.value, calendarEndTime.value)
}

const handleEventClick = (info) => {
  if(info.event.title && !info.event.rendering) {
    let props = info.event.extendedProps
    //open event clicks in new window every time so they dont have to keep reloading the calendar
    let routerData = router.resolve({path: `/project/${props.projectId}/processStep/${props.projectProcessStepId}/event/${props.projectProcessStepEventId}`})
    window.open(routerData.href, '_blank')
    // this.$router.push({path: `/project/${props.projectId}/processStep/${props.projectProcessStepId}`})
  }
}
const handleEventRender = (info) => {
  //3 types of rendering. null = regular scheduled events,
  // background = blocked out from start to end, (resource_appointments)
  // inverse-background = blocked before start and after end (resource_schedule_availability)
  if(info.event.rendering === 'background') {
    info.el.textContent = info.event.title
    info.el.style.cssText += `font-size: 11px; padding-left: 5px; cursor: default; margin-left: 1px; margin-right: 1px; opacity: 1; color: black; overflow: hidden; border: solid 1px black;`
    info.el.title = info.event.title + ': ' + moment(info.event.start).format('h:mm') + '-' + moment(info.event.end).format('h:mm')
  } else if(info.event.rendering !== 'inverse-background') {
    info.el.querySelector('.fc-title').innerHTML = info.event.title
    info.el.style.cssText += `border-left-color: ${info.event.extendedProps.colorForBorder}; border-left-width: 20px; height: 20px; overflow: hidden;`
  }
}

const handleResourceRender = (renderInfo) => {
  let checkbox = document.createElement('INPUT');
  checkbox.setAttribute('type', 'checkbox')
  checkbox.setAttribute('class', 'mr-2')

  checkbox.onchange = (event) => {
    if(event.target.checked) {
      let resource = renderInfo.resource
      let resourceEvents = eventSources[0].events.filter(e => {
        return e.resourceId === resource.id || e.resourceId?.toString() === resource.id
      })
      resourceEvents.forEach(re => {
        let eventObj = {
          id: resource.id,
          projectName: re.projectName,
          processStepName: re.processStepName,
          color: resource.extendedProps.color,
          coordinates: [ re.longitude, re.latitude]
        }
        mapResourceEvents.push(eventObj)
      })
    } else {
      mapResourceEvents = mapResourceEvents.filter(r => {
        return r.id !== renderInfo.resource?.id
      })
    }
    this.callback(mapResourceEvents)
  }

  renderInfo.el.querySelector('.fc-cell-text')
      .prepend(checkbox)

}

const clearSelectedMapResourceEvents = () => {
  let selectedResourceIds = selectedRoundRobinUsers.value.map(u => u.id)
  this.mapResourceEvents = mapResourceEvents.value.filter(r => {
    return selectedResourceIds.includes(r.id)
  })
}

</script>

<style lang="scss">
#calendar-container .fc-timeline-event {
  /*height: inherit;*/
  border-radius: 5px;
  padding-left: 7px;
}

#calendar-container .fc-event:hover {
  color: inherit !important;
  -webkit-box-shadow: 2px 3px 5px 0px rgba(145,147,147,1);
  -moz-box-shadow: 2px 3px 5px 0px rgba(145,147,147,1);
  box-shadow: 2px 3px 5px 0px rgba(145,147,147,1);
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

</style>

<style lang="scss" scoped>
#calendar-container {
  height: 100%;
  display: flex;
  flex-flow: column;
}
.calendar-resize-container {
  /* without this when you resize the screen the calendar goes whackadoodle */
  flex: 1 1 auto;
  position: relative;
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
</style>


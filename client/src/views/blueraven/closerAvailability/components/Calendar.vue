<template>
  <div id="calendar-container">
    <div class="mb-2">
      <!-- if this row is not wrapped in a div then the calendar doesn't size well on refresh. i have no clue why -->
      <v-row class="py-0">
          <v-select v-model="selectedStates"
                    :items="states"
                    label="States"
                    multiple
                    class="mr-2"
                    hide-details
                    return-object
                    item-text="state"
                    item-value="id"
          >
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
              <div v-if="index === 0 && selectedStates.length < 3">
                <v-chip small close @click:close="selectedStates.splice(index, 1)"
                        v-for="ss in selectedStates">
                  <span>{{ ss.state }}</span>
                </v-chip>
              </div>
              <span
                v-if="index === 1 && selectedStates.length >= 3"
                class="primary--text caption"
              >{{ selectedStates.length }} selected</span>
            </template>
            <v-list-item
              slot="prepend-item"
              ripple
              @click="toggleSelectAllStates()">
              <v-list-item-action>
                <v-icon>{{ iconStates }}</v-icon>
              </v-list-item-action>
              <v-list-item-title>Select All</v-list-item-title>
            </v-list-item>
            <v-divider
              slot="prepend-item"
              class="mt-2"
            ></v-divider>
          </v-select>

          <v-autocomplete v-model="selectedPostalCodeZones"
                    :items="postalCodeZones"
                    label="Round Robin"
                    multiple
                    class="mr-2"
                    :loading="postalCodeZonesLoading"
                    hide-details
                    return-object
                    item-text="zoneName"
                    item-value="id"
          >
            <template
                slot="selection"
                slot-scope="{ item, index }"
            >
              <div v-if="index === 0 && selectedPostalCodeZones.length < 3">
                <v-chip small close @click:close="selectedPostalCodeZones.splice(index, 1)"
                        v-for="sr in selectedPostalCodeZones">
                  <span>{{ sr.zoneName }}</span>
                </v-chip>
              </div>
              <span
                  v-if="index === 1 && selectedPostalCodeZones.length >= 3"
                  class="primary--text caption"
              >{{ selectedPostalCodeZones.length }} selected</span>
            </template>
            <v-list-item
                slot="prepend-item"
                ripple
                @click="toggleSelectAllPostalCodeZones()">
              <v-list-item-action>
                <v-icon>{{ iconPostalCodeZones }}</v-icon>
              </v-list-item-action>
              <v-list-item-title>Select All</v-list-item-title>
            </v-list-item>
            <v-divider
                slot="prepend-item"
                class="mt-2"
            ></v-divider>
          </v-autocomplete>

        <v-autocomplete v-model="selectedPostalCodeZoneUsers"
                        :items="postalCodeZoneUsers"
                        label="Closers"
                        multiple
                        class="mr-3"
                        :loading="postalCodeZoneUsersLoading"
                        hide-details
                        return-object
                        @input="postalCodeZoneUserValuesChanged = true"
                        item-text="fullName"
                        item-value="id"
                        @blur="getEvents(false)"
        >
          <template
            slot="selection"
            slot-scope="{ item, index }"
          >
            <div v-if="index === 0 && selectedPostalCodeZoneUsers.length < 3">
              <v-chip small close @click:close="selectedPostalCodeZoneUsers.splice(idx, 1)"
                      v-for="(sr, idx) in selectedPostalCodeZoneUsers">
                <span>{{ sr.fullName }}</span>
              </v-chip>
            </div>
            <span
              v-if="index === 1 && selectedPostalCodeZoneUsers.length >= 3"
              class="primary--text caption"
            >{{ selectedPostalCodeZoneUsers.length }} selected</span>
          </template>
          <v-list-item
            slot="prepend-item"
            ripple
            @click="toggleSelectAllPostalCodeZoneUsers()">
            <v-list-item-action>
              <v-icon>{{ iconPostalCodeZoneUsers }}</v-icon>
            </v-list-item-action>
            <v-list-item-title>Select All</v-list-item-title>
          </v-list-item>
          <v-divider
            slot="prepend-item"
            class="mt-2"
          ></v-divider>
        </v-autocomplete>
      </v-row>
    </div>
    <div class="calendar-resize-container">
      <div id="calendar-loader" v-if="calendarLoading">
        <v-progress-circular
          indeterminate
          :size="80"
          :color="'primaryCustom'"
        ></v-progress-circular>
      </div>
      <FullCalendar ref="eventCalendar"
                    :schedulerLicenseKey="licenseKey" :plugins="calendarPlugins"
                    :defaultView="calendar.options.defaultView"
                    :resources="selectedPostalCodeZoneUsers"
                    theme-system="standard"
                    :resources-initially-expanded="true"
                    :time-zone="calendar.options.timezone"
                    :header="calendar.options.header"
                    :editable="calendar.options.editable"
                    :event-sources="eventSources"
                    :now-indicator="true"
                    :slot-duration="calendar.options.slotDuration"
                    :slot-label-interval="calendar.options.slotLabelInterval"
                    :slot-width="calendar.options.slotWidth"
                    :min-time="calendar.options.minTime"
                    :max-time="calendar.options.maxTime"
                    :height="calendar.options.height"
                    :scroll-time="calendar.options.scrollTime"
                    :first-day="calendar.options.firstDay"
                    :hidden-days="calendar.options.hiddenDays"
                    :custom-buttons="calendar.options.customButtons"
                    @eventClick="(info) => handleEventClick(info)"
                    @eventRender="(info) => handleEventRender(info)"
                    @resourceRender="(renderInfo) => handleResourceRender(renderInfo)"
      />
    </div>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </div>
</template>

<script>
  import FullCalendar from '@fullcalendar/vue'
  import resourceTimelinePlugin from '@fullcalendar/resource-timeline'
  import interaction from '@fullcalendar/interaction'
  import momentPlugin from '@fullcalendar/moment'
  import moment from 'moment'
  import cloneDeep from 'lodash.clonedeep'
  import {getSchedulingOrgTypes} from '@/services/orgService'
  import momentTimezonePlugin from '@fullcalendar/moment-timezone'
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, getRequestWithParams, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'ScheduleCalendar',
    components: {
      FullCalendar,
      Snackbar
    },
    props: {
      mapResources: {type: Array},
      callback: Function,
      dateCallback: Function,
      states: {type: Array}
    },
    computed: {
      //states
      selectAllStates () {
        return this.states.length === this.selectedStates.length
      },
      selectSomeStates () {
        return this.selectedStates.length > 0 && !this.selectAllStates
      },
      iconStates () {
        if (this.states.length === this.selectedStates.length) {
          return 'check_box'
        }
        if (this.selectSomeStates) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      //postal code zones
      selectAllPostalCodeZones () {
        return this.postalCodeZones.length === this.selectedPostalCodeZones.length
      },
      selectSomePostalCodeZones () {
        return this.selectedPostalCodeZones.length > 0 && !this.selectAllPostalCodeZones
      },
      iconPostalCodeZones () {
        if (this.postalCodeZones.length === this.selectedPostalCodeZones.length) {
          return 'check_box'
        }
        if (this.selectSomePostalCodeZones) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      //postal code zone users
      selectAllPostalCodeZoneUsers () {
        return this.postalCodeZoneUsers.length === this.selectedPostalCodeZoneUsers.length
      },
      selectSomePostalCodeZoneUsers () {
        return this.selectedPostalCodeZones.length > 0 && !this.selectAllPostalCodeZoneUsers
      },
      iconPostalCodeZoneUsers () {
        if (this.postalCodeZoneUsers.length === this.selectedPostalCodeZoneUsers.length) {
          return 'check_box'
        }
        if (this.selectSomePostalCodeZoneUsers) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
    },
    mounted () {
      this.calendarApi = this.$refs.eventCalendar.getApi()
      this.calendarStart = this.calendarApi.getDate()
      this.setCalendarStartAndEndTimes()
      //when getEvents was placed in the calendar it loaded before the calendar dates were set: :view-skeleton-render="getEvents"
      //placing here seems to have solved that
      this.getEvents()
    },
    watch: {
      '$store.state.user.details.timezone.value': function () {
        this.calendar.options.timezone = this.$store.state.user.details.timezone.value
      },
      'selectedPostalCodeZoneUsers': function () {
        //clear out selected map resources so we don't orphan map pins when the uncheck a closer
        this.clearSelectedMapResourceEvents()
        this.callback(this.mapResourceEvents)
        this.handleResourceColors()
      },
    },
    created() {
      this.getPostalCodeZones()
      this.getPostalCodeZoneUsers()
    },
    data() {
      return {
        snackbar: {},
        calendarLoading: false,
        calendarInitialRender: true,
        calendarApi: null,
        calendarStart: null,
        calendarView: null,
        calendarStartTime: null,
        calendarEndTime: null,
        eventSources: [
          { name: 'Regular Events',
            events: [] },
          { name: 'Appt Events',
            events: [] }
        ],
        events: [],
        selectedStates: [],
        postalCodeZones: [],
        postalCodeZoneValuesChanged: false,
        selectedPostalCodeZones: [],
        postalCodeZonesLoading: true,
        postalCodeZoneUsers: [],
        postalCodeZoneUserValuesChanged: false,
        selectedPostalCodeZoneUsers: [],
        postalCodeZoneUsersLoading: true,
        resources: [],
        mapResourceEvents: [],
        calendarPlugins: [ interaction, resourceTimelinePlugin, momentPlugin, momentTimezonePlugin ],
        licenseKey: 'GPL-My-Project-Is-Open-Source',
        calendar: {
          options: {
            slotDuration: '00:30:00',
            slotLabelInterval: '01:00:00',
            slotWidth: 45,
            scrollTime: moment().tz(this.$store.state.user.details.timezone.value).startOf('hour').format('HH:mm:ss'),
            hiddenDays: [0],
            minTime: '02:00:00',
            maxTime: '23:00:00',
            height: 'parent',
            firstDay: 1,
            editable: true,
            defaultView: 'resourceTimelineDay',
            timezone: this.$store.state.user.details.timezone.value,
            header: {
              left: 'customPrev,customToday,customNext',
              center: 'title',
              right: 'customTimelineDay,customTimelineWeek'
            },
            customButtons: {
              customToday: {
                text: 'Today',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.gotoDate(new Date)
                  // this.setCalendarStartAndEndTimes()
                  this.mapResourceEvents = []
                  this.callback(this.mapResourceEvents)
                  this.getEvents(false, true)
                }
              },
              customPrev: {
                text: '',
                icon: 'chevron-left',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.prev()
                  // this.setCalendarStartAndEndTimes()
                  this.mapResourceEvents = []
                  this.callback(this.mapResourceEvents)
                  this.getEvents(false, true)
                }
              },
              customNext: {
                text: '',
                icon: 'chevron-right',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.next()
                  // this.setCalendarStartAndEndTimes()
                  this.mapResourceEvents = []
                  this.callback(this.mapResourceEvents)
                  this.getEvents(false, true)
                }
              },
              customTimelineDay: {
                text: 'day',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  this.calendar.options.slotDuration = '00:30:00'
                  this.calendar.options.minTime = '02:00:00'
                  this.calendar.options.maxTime = '23:00:00'
                  this.calendar.options.slotLabelInterval = '01:00:00'
                  this.calendar.options.slotWidth = 45
                  calendarApi.changeView('resourceTimelineDay')
                  this.mapResourceEvents = []
                  this.callback(this.mapResourceEvents)
                  this.getEvents(false, true)
                }
              },
              customTimelineWeek: {
                text: 'week',
                click: () => {
                  this.calendar.options.minTime = '06:00:00'
                  this.calendar.options.maxTime = '22:00:00'
                  this.calendar.options.slotDuration = '01:00:00'
                  this.calendar.options.slotLabelInterval = '02:00:00'
                  this.calendar.options.slotWidth = 25

                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.changeView('resourceTimelineWeek')
                  this.mapResourceEvents = []
                  this.callback(this.mapResourceEvents)
                  this.getEvents(false, true)
                }
              },
            }
          }
        }
      }
    },
    methods: {
      handleResourceColors() {
        this.selectedPostalCodeZoneUsers.forEach((r, index) => {
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
      },
      toggleSelectAllStates () {
        this.$nextTick(() => {
          if (this.selectAllStates) {
            this.selectedStates = []
          } else {
            this.selectedStates = cloneDeep(this.states)
          }
        })
      },
      toggleSelectAllPostalCodeZones () {
        this.$nextTick(() => {
          if (this.selectAllPostalCodeZones) {
            this.selectedPostalCodeZones = []
          } else {
            this.selectedPostalCodeZones = cloneDeep(this.postalCodeZones)
          }
        })
      },
      toggleSelectAllPostalCodeZoneUsers () {
        this.$nextTick(() => {
          if (this.selectAllPostalCodeZoneUsers) {
            this.selectedPostalCodeZoneUsers = []
          } else {
            this.selectedPostalCodeZoneUsers = cloneDeep(this.postalCodeZoneUsers)
          }
        })
      },
      async getPostalCodeZones () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/postalCode/zones`)
          this.postalCodeZones = data
          this.postalCodeZonesLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Round Robins')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPostalCodeZoneUsers () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/postalCode/zone/users`)
          this.postalCodeZoneUsers = data
          this.postalCodeZoneUsersLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Closers')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAvailability() {
        try {
          let params = {
            userIds: this.selectedPostalCodeZoneUsers?.length > 0 ? this.selectedPostalCodeZoneUsers.map(u => u.id) : [],
            startTime: this.calendarStartTime,
            endTime: this.calendarEndTime
          }
          const {data} = await postRequest(`/schedule/availability`, params)
          data.forEach(d => {
            d.groupId = `${d.resourceId}`
            d.resourceId = `${d.resourceId}`
            d.color = 'gray'
          })
          this.eventSources[1].events = cloneDeep(data)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Availability')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getUserPositionIds () {
        let userPositionIds = []
        this.selectedPostalCodeZoneUsers?.forEach(su => {
          su.userPositions?.forEach(up => {
            //up.id = userPositionId
            userPositionIds.push(up.id)
          })
        })
        return userPositionIds
      },
      async getEvents(reload) {
        localStorage.setItem('caUsers', JSON.stringify(this.selectedPostalCodeZoneUsers))
        //dont reload events if they deselected all of one type
        //and only load if the selected values changed
        if(reload || (this.selectedPostalCodeZoneUsers?.length > 0 && (this.postalCodeZoneUserValuesChanged || this.calendarInitialRender))) {
          if (!this.calendarInitialRender) {
            this.setCalendarStartAndEndTimes()
          }
          this.calendarInitialRender = false
          // note: this gets called every render of the calendar which makes clicking the 'day' and 'week' buttons work
          this.eventSources = [
            { name: 'Regular Events',
              events: [] },
            { name: 'Appt Events',
              events: [] }
          ]
          if (this.selectedPostalCodeZoneUsers.length > 0) {
            //i do this here instead of on its own because all of the code above here has to happen for get availability as well
            this.calendarLoading = true
            await this.getAvailability()

            try {
              let params = {
                userPositionIds: this.getUserPositionIds(),
                startTime: this.calendarStartTime,
                endTime: this.calendarEndTime
              }
              const {data} = await postRequest(`/schedule`, params)
              data.forEach(d => {
                // d.resourceId = `${d.systemListTypeId}${d.resourceId}`
                // if resource is a user show on calender using userId so that if they have multiple positions we can load all of them into the same user row on the calendar
                d.resourceId = d.userId
                d.title = `<b>${d.contactFirstName ?? ''} ${d.contactLastName ?? ''}</b> <br/> ${d.groupName}`
                let matchingResource = this.selectedPostalCodeZoneUsers.find(r => r.id === d.resourceId)
                d.colorForBorder = matchingResource?.color
              })
              this.eventSources[0].events = cloneDeep(data)

              this.calendarLoading = false
            } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error Retrieving Events')
              this.calendarLoading = false
            } finally {
              this.orgValuesChanged = false
              this.userValuesChanged = false
            }
          }
        }
      },
      setCalendarStartAndEndTimes () {
        this.calendarStart = this.calendarApi.getDate()
        this.calendarView = this.calendarApi.view?.type
        if(this.calendarView === 'resourceTimelineDay') {
          this.calendarStartTime = moment(this.calendarStart).startOf('d').utc().format('YYYY-MM-DD HH:mm:ss')
          this.calendarEndTime = moment(this.calendarStart).add(1, 'd').startOf('d').utc().format('YYYY-MM-DD HH:mm:ss')
          // this.calendarStartTime = moment(this.calendarStart).tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
          // this.calendarEndTime = moment(this.calendarStart).add(1, 'd').tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
        } else {
          //moment starts on sunday, add 1 to start
          this.calendarStartTime = moment(this.calendarStart).startOf('week').add(1, 'd').utc().format('YYYY-MM-DD HH:mm:ss')
          this.calendarEndTime = moment(this.calendarStart).endOf('week').utc().format('YYYY-MM-DD HH:mm:ss')
        }
        this.dateCallback(this.calendarStartTime, this.calendarEndTime)
      },
      handleEventClick (info) {
        if(info.event.title && !info.event.rendering) {
          let props = info.event.extendedProps
          this.$router.push({path: `/project/${props.projectId}/processStep/${props.projectProcessStepId}?processStepId=${props.processStepId}&contactId=${props.contactId}`})
          // this.$router.push({name: 'projectProcessStep', params: {projectId: props.projectId, processStepId: props.projectProcessStepId}})
        }
      },
      handleEventRender (info) {
        //3 types of rendering. null = regular scheduled events,
        // background = blocked out from start to end, (resource_appointments)
        // inverse-background = blocked before start and after end (resource_schedule_availability)
        if(info.event.rendering === 'background') {
          info.el.textContent = info.event.title
          info.el.style.cssText += `font-size: 11px; padding-left: 5px; cursor: default; margin-left: 1px; margin-right: 1px; opacity: 100%; color: black; overflow: hidden; border: solid 1px black;`
          info.el.title = info.event.title + ': ' + moment(info.event.start).format('h:mm') + '-' + moment(info.event.end).format('h:mm')
        } else if(info.event.rendering !== 'inverse-background') {
          info.el.querySelector('.fc-title').innerHTML = info.event.title
          info.el.style.cssText += `border-left-color: ${info.event.extendedProps.colorForBorder}; border-left-width: 20px; height: 20px; overflow: hidden;`
        }
      },
      handleResourceRender (renderInfo) {
        let checkbox = document.createElement('INPUT');
        checkbox.setAttribute('type', 'checkbox')
        checkbox.setAttribute('class', 'mr-2')

        checkbox.onchange = (event) => {
          console.log('it happened', event)
          if(event.target.checked) {
            let resource = renderInfo.resource
            let self = this
            let resourceEvents = this.eventSources[0].events.filter(e => {
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
              this.mapResourceEvents.push(eventObj)
            })
          } else {
            this.mapResourceEvents = this.mapResourceEvents.filter(r => {
              return r.id !== renderInfo.resource?.id
            })
          }
          this.callback(this.mapResourceEvents)
        }

        renderInfo.el.querySelector('.fc-cell-text')
          .prepend(checkbox)

      },
      clearSelectedMapResourceEvents () {
        let selectedResourceIds = this.selectedPostalCodeZoneUsers.map(u => u.id)
        this.mapResourceEvents = this.mapResourceEvents.filter(r => {
          return selectedResourceIds.includes(r.id)
        })
        console.log('randaLogger', this.mapResourceEvents)
      },

    }
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
    height: 25px !important;
  }

  #calendar-container .fc-cell-content {
    padding-top: 0;
    padding-bottom: 0;
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


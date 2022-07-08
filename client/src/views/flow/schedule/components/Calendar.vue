<template>
  <div id="calendar-container">
    <div class="mb-2">
      <!-- if this row is not wrapped in a div then the calendar doesn't size well on refresh. i have no clue why -->
      <v-row class="py-0">
        <v-col class="py-0" cols="12" md="4">
          <v-select attach v-model="selectedStates"
                    :items="states"
                    label="States"
                    multiple
                    hide-details
                    return-object
                    item-text="state"
                    item-value="id"
                    @blur="filterOrgsAndUsers"
          >
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
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
              <v-list-item-title>Select All</v-list-item-title>
            </v-list-item>
            <v-divider
              slot="prepend-item"
              class="mt-2"
            ></v-divider>
          </v-select>
        </v-col>
        <v-col class="py-0" cols="12" md="4">
          <v-autocomplete v-model="selectedOrgTypes"
                    :items="orgTypes"
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
            <template
                slot="selection"
                slot-scope="{ item, index }"
            >
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
              <v-list-item-title>Select All</v-list-item-title>
            </v-list-item>
            <v-divider
                slot="prepend-item"
                class="mt-2"
            ></v-divider>
          </v-autocomplete>
        </v-col>
        <v-col class="py-0" cols="12" md="4">

          <v-autocomplete v-model="selectedPositions"
                    :items="positions"
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
              <v-list-item-title>Select All</v-list-item-title>
            </v-list-item>
            <v-divider
                slot="prepend-item"
                class="mt-2"
            ></v-divider>
          </v-autocomplete>
        </v-col>
      </v-row>
      <v-row class="py-0">
        <v-col class="py-0" cols="12" md="4">
          <div>
            <v-switch
              v-model="includeCancelled"
              dense
              hide-details
              class="fix-switch-color cancelled-event-switch"
              label="Include Cancelled Events"
              @change="getEvents(null)"
            />
          </div>
        </v-col>
        <v-col class="py-0" cols="12" md="4">
          <v-autocomplete v-model="selectedOrgs"
                    :items="orgs"
                    label="Organization Resources"
                    multiple
                    clearable
                    :loading="orgsLoading"
                    :hide-details="countSelected < maxSelectionAllowed"
                    :error="countSelected >= maxSelectionAllowed"
                    :error-messages="countSelected >= maxSelectionAllowed ? countErrorMessage : null"
                    return-object
                    type="search"
                    item-text="orgName"
                    item-value="id"
                    @input="[orgValuesChanged = true, limiter()]"
                    @blur="getEvents(true)"
                          attach
          >
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
              <span v-if="index === 0" class="primary--text text-caption">
                {{ selectedOrgs.length }} selected
              </span>
            </template>
          </v-autocomplete>
        </v-col>
        <v-col class="py-0" cols="12" md="4">

          <v-autocomplete v-model="selectedUsers"
                          :items="users"
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
                          @blur="getEvents(false)"
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
                    :resources="resources"
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

  </div>
</template>

<script>
  import '@fullcalendar/core/main.css'
  import '@fullcalendar/timeline/main.css'
  import '@fullcalendar/resource-timeline/main.css'

  import FullCalendar from '@fullcalendar/vue'
  import resourceTimelinePlugin from '@fullcalendar/resource-timeline'
  import interaction from '@fullcalendar/interaction'
  import momentPlugin from '@fullcalendar/moment'
  import moment from 'moment'
  import cloneDeep from 'lodash.clonedeep'
  import {getSchedulingOrgTypes} from '@/services/orgService'
  import momentTimezonePlugin from '@fullcalendar/moment-timezone'
  import {AppMutations} from '@/stores/AppStore'

  import {handleHidingGlobalLoader, getRequest, getHostUrl, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'ScheduleCalendar',
    components: {
      FullCalendar,
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
      //org Types
      selectAllOrgTypes () {
        return this.orgTypes.length === this.selectedOrgTypes.length
      },
      selectSomeOrgTypes () {
        return this.selectedOrgTypes.length > 0 && !this.selectAllOrgTypes
      },
      iconOrgTypes () {
        if (this.orgTypes.length === this.selectedOrgTypes.length) {
          return 'check_box'
        }
        if (this.selectSomeOrgTypes) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      //positions
      selectAllPositions () {
        return this.positions.length === this.selectedPositions.length
      },
      selectSomePositions () {
        return this.selectedPositions.length > 0 && !this.selectAllPositions
      },
      iconPositions () {
        if (this.positions.length === this.selectedPositions.length) {
          return 'check_box'
        }
        if (this.selectSomePositions) {
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
      // whenever selectedUsers or selectedOrgs changes, concat them both into resources
      'selectedUsers': function () {
        this.resources = this.selectedOrgs.concat(this.selectedUsers)
        this.handleResourceColors()
      },
      'selectedOrgs': function () {
        this.resources = this.selectedOrgs.concat(this.selectedUsers)
        this.handleResourceColors()
      },
    },
    created() {
      // this.selectedOrgs = JSON.parse(localStorage.getItem('scheduleOrgs')) || []
      // this.selectedUsers = JSON.parse(localStorage.getItem('scheduleUsers')) || []
      this.countSelected = this.selectedOrgs?.length + this.selectedUsers?.length
      this.getSchedulingOrgs()
      this.getSchedulingUsers()
      this.getSchedulingOrgTypes()
      this.getPositions()
    },
    data() {
      return {
        snackbar: {},
        calendarLoading: false,
        includeCancelled: false,
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
        countSelected: 0,
        maxSelectionAllowed: 10,
        countErrorMessage: 'Maximum Selection Reached',
        selectedStates: [],
        masterOrgs: [],
        orgValuesChanged: false,
        orgs: [],
        selectedOrgs: [],
        orgsLoading: true,
        usersLoading: true,
        userValuesChanged: false,
        masterUsers: [],
        users: [],
        selectedUsers: [],
        orgTypes: [],
        orgTypeValuesChanged: false,
        selectedOrgTypes: [],
        orgTypesLoading: true,
        positions: [],
        positionValuesChanged: false,
        selectedPositions: [],
        previousStateCount: 0,
        previousTypeCount: 0,
        previousPositionCount: 0,
        positionsLoading: true,
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
            hiddenDays: [],
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
                  this.getEvents(false, true)
                  this.dateCallback(this.calendarStartTime, this.calendarEndTime)
                }
              },
              customNext: {
                text: '',
                icon: 'chevron-right',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.next()
                  // this.setCalendarStartAndEndTimes()
                  this.getEvents(false, true)
                  this.dateCallback(this.calendarStartTime, this.calendarEndTime)
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
                  this.getEvents(false, true)
                  this.dateCallback(this.calendarStartTime, this.calendarEndTime)
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
                  this.getEvents(false, true)
                  this.dateCallback(this.calendarStartTime, this.calendarEndTime)
                }
              },
            }
          }
        }
      }
    },
    methods: {
      handleResourceColors() {
        this.resources.forEach((r, index) => {
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
      toggleSelectAllOrgTypes () {
        this.$nextTick(() => {
          if (this.selectAllOrgTypes) {
            this.selectedOrgTypes = []
          } else {
            this.selectedOrgTypes = cloneDeep(this.orgTypes)
          }
        })
      },
      toggleSelectAllPositions () {
        this.$nextTick(() => {
          if (this.selectAllPositions) {
            this.selectedPositions = []
          } else {
            this.selectedPositions = cloneDeep(this.positions)
          }
        })
      },
      async getSchedulingOrgs() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequestWithParams(`/org/getSchedulingOrgs`, {
            params: {
              stateId: this.state?.id ?? null,
              isSchedulingTool: true
            }
          }, null, [])
          //in order for resources to work as both users and orgs, the resourceId needs to be prefixed with a type_id 1=org, 2=user
          data?.forEach(d => {
            d.masterId = d.id
            d.id = `${1}${d.id}`
          })
          this.orgs = data
          this.masterOrgs = cloneDeep(this.orgs)
          this.orgsLoading = false
          this.selectedOrgs = this.selectedOrgs.filter(so => {
            return this.orgs.some(o => o.id === so.id)
          })
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Orgs')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getSchedulingOrgTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getSchedulingOrgTypes()
          this.orgTypes = data
          this.orgTypesLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPositions() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/position/schedulable`, null, [])
          this.positions = data
          this.positionsLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getSchedulingUsers() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequestWithParams(`/user/getSchedulingUsers`, {
            params: {
              stateId: this.state?.id ?? null,
              isSchedulingTool: true
            }
          }, null, [])
          //in order for resources to work as both users and orgs, the resourceId needs to be prefixed with a type_id 1=org, 2=user
          data.forEach(d => {
            d.masterId = d.id
            d.id = `${2}${d.id}`
          })
          this.users = data
          this.masterUsers = cloneDeep(this.users)
          this.usersLoading = false
          this.selectedUsers = this.selectedUsers.filter(su => {
            return this.users.some(u => u.id === su.id)
          })
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAvailability() {
        try {
          let params = {
            orgIds: this.selectedOrgs?.length > 0 ? this.selectedOrgs.map(o => o.masterId) : [],
            userIds: this.selectedUsers?.length > 0 ? this.selectedUsers.map(u => u.masterId) : [],
            startTime: this.calendarStartTime,
            endTime: this.calendarEndTime
          }
          const {data} = await postRequest(`/schedule/availability`, params)
          data?.forEach(d => {
            //this is really stupid.  in full calendar an all day appt strips off the time. and just uses the date.
            //so an end time of '2020-12-31 23:59:59' will strip off the time and not include it in the all day range
            //so your event will appear to end on the 30th
            d.allDay = false
            d.groupId = `${d.systemListTypeId}${d.resourceId}`
            d.resourceId = `${d.systemListTypeId}${d.resourceId}`
            d.color = 'gray'

            if(!d.isSlotTime && d.rendering === 'inverse-background') {
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
          })

          //we do this for every resource, regardless of if they already have an availability or not
          // if they already have one it still works as it should and doesn't block out the time, but if they
          // dont already have one then this will block/grey out the day so it doesn't look like they are available
          this.resources.forEach(r => {
            data.push({
                start: moment.utc(this.calendarStartTime).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
                end: moment.utc(this.calendarStartTime).startOf('d').format('YYYY-MM-DDTHH:mm:ssZ'),
                title: null,
                rendering: 'inverse-background',
                allDay: false,
                //these values have already been pre-appended with the 1 or 2
                groupId: r.id,
                resourceId: r.id,
                color: 'gray'
              })
          })

          this.eventSources[1].events = cloneDeep(data)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Availability')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      limiter() {
        this.countSelected = this.selectedOrgs?.length + this.selectedUsers?.length
        this.orgs.forEach(o => {
          let match = this.selectedOrgs.find(so => so.id === o.id)
          o.disabled = !match && this.countSelected >= this.maxSelectionAllowed
        })
        this.users.forEach(u => {
          let match = this.selectedUsers.find(su => su.id === u.id)
          u.disabled = !match && this.countSelected >= this.maxSelectionAllowed
        })
      },
      async getEvents(isOrgs, reload) {
        //if `isOrgs` is not passed in, it is because we don't know it (came from v-switch change)
        if(null == isOrgs) {
          isOrgs = this.selectedOrgs?.length > 0
          this.orgValuesChanged = true
          this.userValuesChanged = true
        }

        //dont reload events if they deselected all of one type and only load if the selected values changed
        if(reload || (isOrgs && this.selectedOrgs?.length > 0 && (this.orgValuesChanged || this.calendarInitialRender))
          || (!isOrgs && this.selectedUsers?.length > 0 && (this.userValuesChanged || this.calendarInitialRender))) {
          if (reload || !this.calendarInitialRender) {
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
          if (this.selectedOrgs.length > 0 || this.selectedUsers.length > 0) {
            //i do this here instead of on its own because all of the code above here has to happen for get availability as well
            this.calendarLoading = true
            await this.getAvailability()

            try {
              let params = {
                orgIds: this.selectedOrgs?.length > 0 ? this.selectedOrgs.map(o => o.masterId) : [],
                // this was the old way. leaving here in case
                // userPositionIds: this.getUserPositionIds(),
                userIds: this.selectedUsers?.length > 0 ? this.selectedUsers.map(u => u.masterId) : [],
                startTime: this.calendarStartTime,
                endTime: this.calendarEndTime,
                includeCancelled: this.includeCancelled
              }
              const {data} = await postRequest(`/schedule`, params)
              data.forEach(d => {
                // d.resourceId = `${d.systemListTypeId}${d.resourceId}`
                // if resource is a user show on calender using userId so that if they have multiple positions we can load all of them into the same user row on the calendar
                d.resourceId = d.userId ? `${d.systemListTypeId}${d.userId}` : `${d.systemListTypeId}${d.resourceId}`
                d.title = `<b>${d.contactFirstName ?? ''} ${d.contactLastName ?? ''}</b> <br/> ${d.eventName}`
                d.hoverTitle = `${d.contactFirstName ?? ''} ${d.contactLastName ?? ''} \n ${d.eventName} \n ${this.getFormattedDate(d.start)} - ${this.getFormattedDate(d.end)}`
                let matchingResource = this.resources.find(r => r.id === d.resourceId)
                if(d.eventStatusTypeId === 3) {
                  d.colorForBorder = '#919191'
                  d.textColor = '#919191'
                } else {
                  d.colorForBorder = matchingResource?.color
                }
              })
              this.eventSources[0].events = cloneDeep(data)

              this.calendarLoading = false
            } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error Retrieving Events')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.calendarLoading = false
            } finally {
              this.orgValuesChanged = false
              this.userValuesChanged = false
            }
          }
        }
      },
      // getUserPositionIds () {
      //   let userPositionIds = []
      //   this.selectedUsers?.forEach(su => {
      //     su.userPositions.forEach(up => {
      //       //up.id = userPositionId
      //       userPositionIds.push(up.id)
      //     })
      //   })
      //   return userPositionIds
      // },
      getFormattedDate(date) {
        //used for formatting the start/end for the hoverTitle
        return this.$filters.formatDate(date, 'timestamp', 'h:mm a')
      },
      setCalendarStartAndEndTimes () {
        this.calendarStart = this.calendarApi.getDate()
        this.calendarView = this.calendarApi.view?.type
        if(this.calendarView === 'resourceTimelineDay') {
          this.calendarStartTime = moment(this.calendarStart).startOf('d').utc().format('YYYY-MM-DD HH:mm:ss')
          this.calendarEndTime = moment(this.calendarStart).add(1, 'd').startOf('d').subtract(1, 's').utc().format('YYYY-MM-DD HH:mm:ss')
          // this.calendarStartTime = moment(this.calendarStart).tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
          // this.calendarEndTime = moment(this.calendarStart).add(1, 'd').tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
        } else {
          //moment starts on sunday, isoWeek starts on monday
          this.calendarStartTime = moment(this.calendarStart).startOf('isoWeek').utc().format('YYYY-MM-DD HH:mm:ss')
          this.calendarEndTime = moment(this.calendarStart).endOf('isoWeek').utc().format('YYYY-MM-DD HH:mm:ss')
        }
        this.dateCallback(this.calendarStartTime, this.calendarEndTime)
      },
      handleEventClick (info) {
        if(info.event.title && !info.event.rendering) {
          let props = info.event.extendedProps
          //open event clicks in new window every time so they dont have to keep reloading the calendar
          let routerData = this.$router.resolve({path: `/project/${props.projectId}/processStep/${props.projectProcessStepId}/event/${props.projectProcessStepEventId}`})
          window.open(routerData.href, '_blank')
          // this.$router.push({path: `/project/${props.projectId}/processStep/${props.projectProcessStepId}`})
        }
      },
      handleEventRender (info) {
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
          //this gives normal events a hover
          info.el.title = info.event.extendedProps.hoverTitle
        }
      },
      handleResourceRender (renderInfo) {
        let checkbox = document.createElement('INPUT');
        checkbox.setAttribute('type', 'checkbox')
        checkbox.setAttribute('class', 'mr-2')

        checkbox.onchange = (event) => {
          if(event.target.checked) {
            let resource = renderInfo.resource
            let resourceEvents = this.eventSources[0].events.filter(e => {
              return e.resourceId === resource.id
            })
            resourceEvents.forEach(re => {
              let eventObj = {
                id: resource.id,
                projectName: re.projectName,
                processStepName: re.processStepName,
                city: re.city,
                stateAbbreviation: re.stateAbbreviation,
                postalCode: re.postalCode,
                street1: re.street1,
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

        //if this is an org (first char === 1) then make it a hyperlink to the org screen
        let isOrg = false
        let anchorHref = ''
        if(renderInfo?.resource?.id?.charAt(0) === '1') {
          isOrg = true
          let orgId = renderInfo?.resource?.id?.substring(1)
          anchorHref = getHostUrl() + '/org/' + orgId
        }
        renderInfo.el.querySelector('.fc-cell-text').innerHTML = isOrg ?
          "<a target='_blank' href=" + anchorHref + ">" + renderInfo.resource.title + "</a>" :
          "<span>" + renderInfo.resource.title + "</span>"
        renderInfo.el.querySelector('.fc-cell-text').prepend(checkbox)

      },
      filterOrgsAndUsers() {
        //only filter if something is selected or deselected back down to 0 length - cant watch these values because we don't want to call the function on the change but only on blur
        let stateFilterRequired = this.selectedStates?.length > 0
        let stateReset = this.previousStateCount > 0 && this.selectedStates?.length === 0
        this.previousStateCount = this.selectedStates?.length
        let orgTypeFilterRequired = this.selectedOrgTypes?.length > 0
        let typeReset = this.previousTypeCount > 0 && this.selectedOrgTypes?.length === 0
        this.previousTypeCount = this.selectedOrgTypes?.length
        let positionFilterRequired = this.selectedPositions?.length > 0
        let positionReset = this.previousPositionCount > 0 && this.selectedOrgTypes?.length === 0
        this.previousPositionCount = this.selectedPositions?.length
        if(stateFilterRequired || orgTypeFilterRequired || positionFilterRequired || stateReset || typeReset || positionReset) {
          this.orgs = this.masterOrgs.filter(mo => {
            let stateMatch = true
            let orgTypeMatch = true
            if(stateFilterRequired) {
              let match = this.selectedStates.find(ss => ss.stateId === mo.stateId)
              stateMatch = match !== null && match !== undefined
            }
            if(orgTypeFilterRequired) {
              let match = this.selectedOrgTypes.find(sot => sot.id === mo.orgTypeId)
              orgTypeMatch = match !== null && match !== undefined
            }
            return stateMatch && orgTypeMatch
          })
          let selectedPositionIds = this.selectedPositions.map(p => p.id)
          let selectedStateIds = this.selectedStates.map(s => s.stateId)
          this.users = this.masterUsers.filter(mo => {
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

    }
  }
</script>

<style lang="scss">
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


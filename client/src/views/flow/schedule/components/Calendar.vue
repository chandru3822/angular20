<template>
  <div id="calendar-container">
    <div class="mb-2">
      <!-- if this row is not wrapped in a div then the calendar doesn't size well on refresh. i have no clue why -->
      <v-row class="py-0">
        <v-col class="py-0" cols="12" md="4">
          <v-select v-model="selectedStates"
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
                  class="primary--text caption"
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
                  class="primary--text caption"
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
          >
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
              <span v-if="index === 0" class="primary--text caption">
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
          >
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
              <span v-if="index === 0" class="primary--text caption">
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
  import FullCalendar from '@fullcalendar/vue'
  import resourceTimelinePlugin from '@fullcalendar/resource-timeline'
  import interaction from '@fullcalendar/interaction'
  import momentPlugin from '@fullcalendar/moment'
  import moment from 'moment'
  import cloneDeep from 'lodash.clonedeep'
  import {getSchedulingOrgTypes} from '@/services/orgService'
  import momentTimezonePlugin from '@fullcalendar/moment-timezone'
  import {AppMutations} from '@/stores/AppStore'

  import {getRequest, deleteRequest, getRequestWithParams, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
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
      this.selectedOrgs = JSON.parse(localStorage.getItem('scheduleOrgs')) || []
      this.selectedUsers = JSON.parse(localStorage.getItem('scheduleUsers')) || []
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
          const {data} = await getRequestWithParams(`/org/getSchedulingOrgs`, {
            params: {
              stateId: this.state?.id ?? null,
              isSchedulingTool: true
            }
          })
          //in order for resources to work as both users and orgs, the resourceId needs to be prefixed with a type_id 1=org, 2=user
          data.forEach(d => {
            d.masterId = d.id
            d.id = `${1}${d.id}`
          })
          this.orgs = data
          this.masterOrgs = cloneDeep(this.orgs)
          this.orgsLoading = false
          this.selectedOrgs = this.selectedOrgs.filter(so => {
            return this.orgs.some(o => o.id === so.id)
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getSchedulingOrgTypes()
          this.orgTypes = data
          this.orgTypesLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getRequest(`/position/schedulable`)
          this.positions = data
          this.positionsLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getRequestWithParams(`/user/getSchedulingUsers`, {
            params: {
              stateId: this.state?.id ?? null,
              isSchedulingTool: true
            }
          })
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
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          data.forEach(d => {
            d.groupId = `${d.systemListTypeId}${d.resourceId}`
            d.resourceId = `${d.systemListTypeId}${d.resourceId}`
            d.color = 'gray'
          })
          this.eventSources[1].events = cloneDeep(data)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Availability')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      limiter(e) {
        this.countSelected = this.selectedOrgs?.length + this.selectedUsers?.length
        console.log('count', this.countSelected)
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
        localStorage.setItem('scheduleOrgs', JSON.stringify(this.selectedOrgs))
        localStorage.setItem('scheduleUsers', JSON.stringify(this.selectedUsers))
        //dont reload events if they deselected all of one type
        //and only load if the selected values changed
        if(reload || (isOrgs && this.selectedOrgs?.length > 0 && (this.orgValuesChanged || this.calendarInitialRender)) || (!isOrgs && this.selectedUsers?.length > 0 && (this.userValuesChanged || this.calendarInitialRender))) {
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
          if (this.selectedOrgs.length > 0 || this.selectedUsers.length > 0) {
            //i do this here instead of on its own because all of the code above here has to happen for get availability as well
            this.calendarLoading = true
            await this.getAvailability()

            try {
              let params = {
                orgIds: this.selectedOrgs?.length > 0 ? this.selectedOrgs.map(o => o.masterId) : [],
                userPositionIds: this.getUserPositionIds(),
                startTime: this.calendarStartTime,
                endTime: this.calendarEndTime
              }
              const {data} = await postRequest(`/schedule`, params)
              data.forEach(d => {
                // d.resourceId = `${d.systemListTypeId}${d.resourceId}`
                // if resource is a user show on calender using userId so that if they have multiple positions we can load all of them into the same user row on the calendar
                d.resourceId = d.userId ? `${d.systemListTypeId}${d.userId}` : `${d.systemListTypeId}${d.resourceId}`
                d.title = `<b>${d.contactFirstName ?? ''} ${d.contactLastName ?? ''}</b> <br/> ${d.groupName}`
                let matchingResource = this.resources.find(r => r.id === d.resourceId)
                d.colorForBorder = matchingResource?.color
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
      getUserPositionIds () {
        let userPositionIds = []
        this.selectedUsers?.forEach(su => {
          su.userPositions.forEach(up => {
            //up.id = userPositionId
            userPositionIds.push(up.id)
          })
        })
        return userPositionIds
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


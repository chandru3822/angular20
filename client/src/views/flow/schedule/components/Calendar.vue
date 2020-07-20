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
                <v-chip small v-for="ss in selectedStates">
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
          <v-select v-model="selectedOrgTypes"
                    :items="orgTypes"
                    label="Organization Types"
                    multiple
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
                <v-chip small v-for="sr in selectedOrgTypes">
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
          </v-select>
        </v-col>
        <v-col class="py-0" cols="12" md="4">

          <v-autocomplete v-model="selectedPositions"
                    :items="positions"
                    label="Positions"
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
                <v-chip small v-for="sr in selectedPositions">
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
          <v-select v-model="selectedOrgs"
                    :items="orgs"
                    label="Organizations"
                    multiple
                    :loading="orgsLoading"
                    hide-details
                    return-object
                    item-text="orgName"
                    item-value="id"
                    @input="orgValuesChanged = true"
                    @blur="getEvents(true)"
          >
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
              <div v-if="index === 0 && selectedOrgs.length < 3">
                <v-chip small v-for="sr in selectedOrgs">
                  <span>{{ sr.orgName }}</span>
                </v-chip>
              </div>
              <span
                v-if="index === 1 && selectedOrgs.length >= 3"
                class="primary--text caption"
              >{{ selectedOrgs.length }} selected</span>
            </template>
            <v-list-item
              slot="prepend-item"
              ripple
              @click="toggleSelectAllOrgs()">
              <v-list-item-action>
                <v-icon>{{ icon }}</v-icon>
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

          <v-autocomplete v-model="selectedUsers"
                          :items="users"
                          label="Users"
                          multiple
                          hide-details
                          :loading="usersLoading"
                          return-object
                          item-text="fullName"
                          item-value="id"
                          @input="userValuesChanged = true"
                          @blur="getEvents(false)"
          >
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
              <div v-if="index === 0 && selectedUsers.length < 3">
                <v-chip small v-for="sr in selectedUsers">
                  <span>{{ sr.fullName }}</span>
                </v-chip>
              </div>
              <span
                v-if="index === 1 && selectedUsers.length >= 3"
                class="primary--text caption"
              >{{ selectedUsers.length }} selected</span>
            </template>
            <v-list-item
              slot="prepend-item"
              ripple
              @click="toggleSelectAllUsers()">
              <v-list-item-action>
                <v-icon>{{ iconUsers }}</v-icon>
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
    </div>
    <div class="calendar-resize-container">
      <FullCalendar ref="eventCalendar"
                    :schedulerLicenseKey="licenseKey" :plugins="calendarPlugins"
                    :defaultView="calendar.options.defaultView"
                    :resources="resources"
                    theme-system="standard"
                    :time-zone="calendar.options.timezone"
                    :header="calendar.options.header"
                    :editable="calendar.options.editable"
                    :events="events"
                    :now-indicator="true"
                    :min-time="calendar.options.minTime"
                    :max-time="calendar.options.maxTime"
                    :height="calendar.options.height"
                    :scroll-time="calendar.options.scrollTime"
                    :first-day="calendar.options.firstDay"
                    :hidden-days="calendar.options.hiddenDays"
                    :custom-buttons="calendar.options.customButtons"
                    :slot-width="55"
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
  import {getOrgTypes} from '@/services/orgService'
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
      //orgs
      selectAll () {
        return this.orgs.length === this.selectedOrgs.length
      },
      selectSome () {
        return this.selectedOrgs.length > 0 && !this.selectAll
      },
      icon () {
        if (this.orgs.length === this.selectedOrgs.length) {
          return 'check_box'
        }
        if (this.selectSome) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
      //users
      selectAllUsers () {
        return this.users.length === this.selectedUsers.length
      },
      selectSomeUsers () {
        return this.selectedUsers.length > 0 && !this.selectAllUsers
      },
      iconUsers () {
        if (this.users.length === this.selectedUsers.length) {
          return 'check_box'
        }
        if (this.selectSomeUsers) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      },
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
        if (this.positions.length === this.selectedOrgTypes.length) {
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
      this.getSchedulingOrgs()
      this.getSchedulingUsers()
      this.getOrgTypes()
      this.getPositions()
    },
    data() {
      return {
        snackbar: {},
        calendarInitialRender: true,
        calendarApi: null,
        calendarStart: null,
        calendarView: null,
        calendarStartTime: null,
        calendarEndTime: null,
        events: [],
        selectedStates: [],
        previousStateCount: 0,
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
        previousTypeCount: 0,
        orgTypesLoading: true,
        positions: [],
        positionValuesChanged: false,
        selectedPositions: [],
        previousPositionCount: 0,
        positionsLoading: true,
        resources: [],
        mapResourceEvents: [],
        calendarPlugins: [ interaction, resourceTimelinePlugin, momentPlugin, momentTimezonePlugin ],
        licenseKey: 'GPL-My-Project-Is-Open-Source',
        calendar: {
          options: {
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
              right: 'resourceTimelineDay,resourceTimelineWeek'
            },
            customButtons: {
              customToday: {
                text: 'Today',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.gotoDate(new Date)
                  // this.setCalendarStartAndEndTimes()
                  this.getEvents()
                }
              },
              customPrev: {
                text: '',
                icon: 'chevron-left',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.prev()
                  // this.setCalendarStartAndEndTimes()
                  this.getEvents()
                }
              },
              customNext: {
                text: '',
                icon: 'chevron-right',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.next()
                  // this.setCalendarStartAndEndTimes()
                  this.getEvents()
                }
              }
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
      toggleSelectAllOrgs () {
        this.$nextTick(() => {
          if (this.selectAll) {
            this.selectedOrgs = []
          } else {
            this.selectedOrgs = cloneDeep(this.orgs)
          }
        })
      },
      toggleSelectAllUsers () {
        this.$nextTick(() => {
          if (this.selectAllUsers) {
            this.selectedUsers = []
          } else {
            this.selectedUsers = cloneDeep(this.users)
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrgTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getOrgTypes()
          this.orgTypes = data
          this.orgTypesLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPositions() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/position/scheduling`)
          this.positions = data
          this.positionsLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getEvents(isOrgs) {
        localStorage.setItem('scheduleOrgs', JSON.stringify(this.selectedOrgs))
        localStorage.setItem('scheduleUsers', JSON.stringify(this.selectedUsers))
        //dont reload events if they deselected all of one type
        //and only load if the selected values changed
        if((isOrgs && this.selectedOrgs?.length > 0 && (this.orgValuesChanged || this.calendarInitialRender)) || (!isOrgs && this.selectedUsers?.length > 0 && (this.userValuesChanged || this.calendarInitialRender))) {
          if (!this.calendarInitialRender) {
            this.setCalendarStartAndEndTimes()
          }
          this.calendarInitialRender = false
          // note: this gets called every render of the calendar which makes clicking the 'day' and 'week' buttons work
          this.events = []
          if (this.selectedOrgs.length > 0 || this.selectedUsers.length > 0) {
            this.$store.commit(AppMutations.SET_LOADING, true)

            try {
              let params = {
                orgIds: this.selectedOrgs?.length > 0 ? this.selectedOrgs.map(o => o.masterId) : [],
                userIds: this.selectedUsers?.length > 0 ? this.selectedUsers.map(u => u.masterId) : [],
                startTime: this.calendarStartTime,
                endTime: this.calendarEndTime
              }
              const {data} = await postRequest(`/schedule`, params)
              data.forEach(d => {
                d.resourceId = `${d.systemListTypeId}${d.resourceId}`
                d.title = `<b>${d.contactFirstName} ${d.contactLastName}</b> <br/> ${d.groupName}`
                let matchingResource = this.resources.find(r => r.id === d.resourceId)
                d.colorForBorder = matchingResource?.color
              })
              this.events = cloneDeep(data)
              this.$store.commit(AppMutations.SET_LOADING, false)
            } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error Retrieving Events')
              this.$store.commit(AppMutations.SET_LOADING, false)
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
          this.calendarStartTime = moment(this.calendarStart).tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
          this.calendarEndTime = moment(this.calendarStart).add(1, 'd').tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
        } else {
          //moment starts on sunday, add 1 to start
          this.calendarStartTime = moment(this.calendarStart).startOf('week').add(1, 'd').tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
          this.calendarEndTime = moment(this.calendarStart).endOf('week').tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
        }
        this.dateCallback(this.calendarStartTime, this.calendarEndTime)
      },
      handleEventClick (info) {
        let props = info.event.extendedProps
        this.$router.push({name: 'projectProcessStep', params: {projectId: props.projectId, processStepId: props.projectProcessStepId}})
      },
      handleEventRender (info) {
        info.el.querySelector('.fc-title').innerHTML = info.event.title
        info.el.style.cssText += `border-left-color: ${info.event.extendedProps.colorForBorder}; border-left-width: 20px; height: 20px; overflow: hidden;`
      },
      handleResourceRender (renderInfo) {
        let checkbox = document.createElement('INPUT');
        checkbox.setAttribute('type', 'checkbox')
        checkbox.setAttribute('class', 'mr-2')

        checkbox.onchange = (event) => {
          if(event.target.checked) {
            // debugger
            let resource = renderInfo.resource
            let resourceEvents = this.events.filter(e => {
              return e.resourceId === resource.id
            })
            resourceEvents.forEach(re => {
              let eventObj = {
                id: resource.id,
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
        //only filter if something is selected
        let stateFilterRequired = this.selectedStates?.length > 0
        let orgTypeFilterRequired = this.selectedOrgTypes?.length > 0
        let positionFilterRequired = this.selectedPositions?.length > 0
        if(stateFilterRequired || orgTypeFilterRequired || positionFilterRequired) {
          this.orgs = this.masterOrgs.filter(mo => {
            let stateMatch = true
            let orgTypeMatch = true
            if(stateFilterRequired) {
              let match = this.selectedStates.find(ss => ss.id === mo.stateId)
              stateMatch = match !== null && match !== undefined
            }
            if(orgTypeFilterRequired) {
              let match = this.selectedOrgTypes.find(sot => sot.id === mo.orgTypeId)
              orgTypeMatch = match !== null && match !== undefined
            }
            return stateMatch && orgTypeMatch
          })
          let selectedPositionIds = this.selectedPositions.map(p => p.id)
          let selectedStateIds = this.selectedStates.map(s => s.id)
          this.users = this.masterUsers.filter(mo => {
            let stateMatch = true
            let positionMatch = true
            if(stateFilterRequired) {
              stateMatch = mo.userPositions.some(up => {
                return selectedStateIds.includes(up.stateId)
              })
            }
            if(positionFilterRequired) {
              positionMatch = mo.userPositions.some(up => {
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
}
</style>


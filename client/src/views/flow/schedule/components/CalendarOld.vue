<template>
  <div class="calendar-container">
    <v-select v-model="selectedOrgs"
              :items="orgs"
              label="Organizations"
              multiple
              return-object
              item-text="orgName"
              item-value="id"
              @input="getEvents"
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
    <v-select v-model="selectedUsers"
              :items="users"
              label="Users"
              multiple
              return-object
              item-text="fullName"
              item-value="id"
              @input="getEvents"
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
    </v-select>
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
                  :button-icons="calendar.options.buttonIcons"
                  :custom-buttons="calendar.options.customButtons"
                  :view-skeleton-render="getEvents"
                  @eventClick="(info) => handleEventClick(info)"
    />
    <Snackbar :snackbar="snackbar"></Snackbar>
  </div>
</template>

<script>
  import FullCalendar from '@fullcalendar/vue'
  import resourceTimelinePlugin from '@fullcalendar/resource-timeline'
  import interaction from '@fullcalendar/interaction'
  import { toMoment } from '@fullcalendar/moment'
  import moment from 'moment'
  import cloneDeep from 'lodash.clonedeep'
  import momentTimezonePlugin from '@fullcalendar/moment-timezone'
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, getRequestWithParams, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'

  export default {
    name: 'ScheduleCalendar',
    components: {
      FullCalendar,
      Snackbar
    },
    props: {

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
      }
    },
    data() {
      return {
        snackbar: {},
        events: [],
        orgs: [],
        selectedOrgs: [],
        users: [],
        selectedUsers: [],
        resources: [],
        calendarPlugins: [ interaction, resourceTimelinePlugin, momentTimezonePlugin ],
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
            buttonIcons: {
              prev: 'left-single-arrow',
              next: 'right-single-arrow',
              prevYear: 'left-double-arrow',
              nextYear: 'right-double-arrow'
            },
            customButtons: {
              customToday: {
                text: 'Today',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  console.log('randaLogger MOMENT', moment())
                  calendarApi.gotoDate(new Date)
                  this.getEvents()
                }
              },
              customPrev: {
                text: '',
                icon: 'chevron-left',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.prev()
                  this.getEvents()
                }
              },
              customNext: {
                text: '',
                icon: 'chevron-right',
                click: () => {
                  let calendarApi = this.$refs.eventCalendar.getApi()
                  calendarApi.next()
                  this.getEvents()
                }
              }
            }
          }
        }
      }
    },
    watch: {
      '$store.state.user.details.timezone.value': function () {
        this.calendar.options.timezone = this.$store.state.user.details.timezone.value
        // let calendarApi = this.$refs.eventCalendar.getApi()
        // calendarApi.rerenderEvents()
        // calendarApi.destroy()
        // calendarApi.render()
      },
      // whenever selectedUsers or selectedOrgs changes, concat them both into resources
      'selectedUsers': function () {
        this.resources = this.selectedOrgs.concat(this.selectedUsers)
      },
      'selectedOrgs': function () {
        this.resources = this.selectedOrgs.concat(this.selectedUsers)
      }
    },
    created() {
      // console.log('randaLogger',moment().tz(this.$store.state.user.details.timezone.value).startOf('hour').format('HH:mm:ss'))
      this.getSchedulingOrgs()
      this.getSchedulingUsers()
    },
    methods: {
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
      async getSchedulingOrgs() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/org/getSchedulingOrgs`, {
            params: {
              stateId: this.state?.id ?? null
            }
          })
          //in order for resources to work as both users and orgs, the resourceId needs to be prefixed with a type_id 1=org, 2=user
          data.forEach(d => {
            d.masterId = d.id
            d.id = `${1}${d.id}`
          })
          this.orgs = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Orgs')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getSchedulingUsers() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/user/getSchedulingUsers`, {
            params: {
              stateId: this.state?.id ?? null
            }
          })
          //in order for resources to work as both users and orgs, the resourceId needs to be prefixed with a type_id 1=org, 2=user
          data.forEach(d => {
            d.masterId = d.id
            d.id = `${2}${d.id}`
          })
          this.users = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getEvents() {
        // note: this gets called every render of the calendar which makes clicking the 'day' and 'week' buttons work
        console.log('randaLogger CALLED')
        this.events = []
        if(this.selectedOrgs.length > 0 || this.selectedUsers.length > 0) {
          let calendarApi = this.$refs.eventCalendar.getApi()
          const calendarStart = calendarApi.getDate()
          let calendarView = calendarApi.view?.type
          let startTime, endTime
          console.log('randaLogger', calendarView)
          if(calendarView === 'resourceTimelineDay') {
            startTime = moment(calendarStart).tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
            endTime = moment(calendarStart).add(1, 'd').tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
          } else {
            //moment starts on sunday, add 1 to start
            startTime = moment(calendarStart).startOf('week').add(1, 'd').tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
            endTime = moment(calendarStart).endOf('week').tz(this.$store.state.user.details.timezone.value).format('YYYY-MM-DD')
          }
          console.log('randaLogger',startTime)
          console.log('randaLogger',endTime)
          this.$store.commit(AppMutations.SET_LOADING, true)

          try {
            let params = {
              orgIds: this.selectedOrgs?.length > 0 ? this.selectedOrgs.map(o => o.masterId) : [],
              userIds: this.selectedUsers?.length > 0 ? this.selectedUsers.map(u => u.masterId) : [],
              startTime,
              endTime
            }
            const {data} = await postRequest(`/schedule`, params)
            data.forEach(d => {
              d.resourceId = `${d.systemListTypeId}${d.resourceId}`
              d.color = d.scheduleColor ?? '#FFFFFF'
              d.title = d.groupName

              this.events = data
            })
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Events')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }

      },
      handleEventClick (info) {
        console.log('event clicked yo', info)
        let props = info.event.extendedProps
        this.$router.push({name: 'projectProcessStep', params: {projectId: props.projectId, processStepId: props.projectProcessStepId}})
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
.calendar-container {
  height: 100%;
}
</style>


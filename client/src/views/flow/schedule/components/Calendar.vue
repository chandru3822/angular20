<template>
  <FullCalendar :schedulerLicenseKey="licenseKey" :plugins="calendarPlugins"
                :defaultView="calendar.options.defaultView"
                :resources="resources"
                :timezone="calendar.options.timezone"
                :header="calendar.options.header"
                :editable="calendar.options.editable"
                :events="events"
                :min-time="calendar.options.minTime"
                :max-time="calendar.options.maxTime"
  />
</template>

<script>
  import FullCalendar from '@fullcalendar/vue'
  import resourceTimelinePlugin from '@fullcalendar/resource-timeline'
  import interaction from '@fullcalendar/interaction'
  import moment from 'moment'

  export default {
    name: 'ScheduleCalendar',
    components: {
      FullCalendar
    },
    props: {
      events: { type: Array },
      resources: { type: Array }
    },
    data() {
      return {
        calendarPlugins: [ interaction, resourceTimelinePlugin ],
        licenseKey: 'GPL-My-Project-Is-Open-Source',
        calendar: {
          options: {
            minTime: '02:00:00',
            maxTime: '23:00:00',
            editable: true,
            defaultView: 'resourceTimelineDay',
            //todo: set the timezone using their setting
            timezone: moment().tz(this.$store.state.user.details.timezone).format('z'),
            header: {
              left: 'prev,next',
              center: 'title',
              right: 'resourceTimelineDay,resourceTimelineWeek'
            },
          }
        }
      }
    },
    created() {
      console.log('randaLogger', moment().tz(this.$store.state.user.details.timezone).format('z'))
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>


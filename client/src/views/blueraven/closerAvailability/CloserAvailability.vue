<template>
  <v-container>
    <v-row id="closer-availability-container">
      <v-col cols="12" md="12" class="map-row" style="overflow: auto;">
        <!-- map-resources allows the calendar to send events back to the map -->
        <Calendar :map-resources="mapResources"
                  ref="calendar"
                  :callback="this.resourceMapCallback"
                  :date-callback="this.dateCallback"></Calendar>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import Calendar from './components/Calendar'

export default {
  name: 'CloserAvailability',
  components: {
    Calendar
  },
  data() {
    return {
      snackbar: {},
      timezone: this.$store.state.user.details.timezone.value,
      startTime: null,
      endTime: null,
      mapResources: [],
      selectedRows: [],
      selectedResources: [],
      state: {},
      caState: null,
      eventTypes: [],
      selectedEventTypes: [],
      eventTypesChanged: false,
      searchProjectsLoading: false,
      asyncActions: {}
    }
  },
  methods: {
    resourceMapCallback(newValue) {
      this.mapResources = newValue
    },
    dateCallback(startTime, endTime) {
      this.startTime = startTime
      this.endTime = endTime
    },
  }
}
</script>

<style lang="scss" scoped>
#closer-availability-container {
  height: calc(100vh - 100px);
}
</style>


<template>
  <v-container>
    <v-row id="closer-availability-container">
      <v-col cols="12" md="4" class="map-row">
        <Map :latitude="state.mapLatitude" :markers="selectedRows" :longitude="state.mapLongitude"
             :zoom="state.mapZoom" :map-resources="mapResources"></Map>
      </v-col>
      <v-col cols="12" md="8" class="map-row" style="overflow: auto;">
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
  import {AppMutations} from '@/stores/AppStore'

  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import Map from './components/Map'
  import Calendar from './components/Calendar'

  export default {
    name: 'CloserAvailability',
    components: {

      Map,
      Calendar
    },
    data() {
      return {
        snackbar: {},
        timezone: this.$store.state.user.details.timezone.value,
        defaultZoom: 2.0,
        map: {
          accessToken: '***REMOVED***',
          style: 'mapbox://styles/mapbox/streets-v10'
        },
        //center of the USA
        defaultCenter: [-98.5795, 39.8283],
        center: null,
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
    watch: {},
    created() {},
    methods: {
      resourceMapCallback (newValue) {
        this.mapResources = newValue
      },
      dateCallback (startTime, endTime) {
        this.startTime = startTime
        this.endTime = endTime
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
#closer-availability-container {
  height: calc(100vh - 100px);
}
</style>


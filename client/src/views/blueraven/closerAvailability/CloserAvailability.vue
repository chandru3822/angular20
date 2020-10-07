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
                  :states="states"
                  :callback="this.resourceMapCallback"
                  :date-callback="this.dateCallback"></Calendar>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import {getActiveStatesByHierarchy} from '@/services/stateService'
  import Map from './components/Map'
  import Calendar from './components/Calendar'

  export default {
    name: 'CloserAvailability',
    components: {
      Snackbar,
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
        states: [],
        caState: null,
        eventTypes: [],
        selectedEventTypes: [],
        eventTypesChanged: false,
        searchProjectsLoading: false,
        asyncActions: {}
      }
    },
    watch: {},
    created() {
      this.caState = JSON.parse(localStorage.getItem('closerAvailabilityState')) || {}
      this.getActiveStatesByHierarchy()
    },
    methods: {
      resourceMapCallback (newValue) {
        this.mapResources = newValue
      },
      dateCallback (startTime, endTime) {
        this.startTime = startTime
        this.endTime = endTime
      },
      async getActiveStatesByHierarchy() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getActiveStatesByHierarchy()
          this.states = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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


<template>
  <v-container>
    <v-row class="map-row">
      <v-col cols="5">
        <Map :latitude="state.mapLatitude" :longitude="state.mapLongitude" :zoom="state.mapZoom"></Map>
      </v-col>
      <v-col cols="7">
        <Calendar></Calendar>
      </v-col>
    </v-row>
    <v-row class="schedule-row mt-4">
      <v-col cols="5">
        <v-card color="white" class="text-left">
          <v-card-actions>
            <v-btn text @click="showFilters = true" :class="{underline: showFilters}">Filters</v-btn>
            <v-btn text @click="showFilters = false" :class="{underline: !showFilters}">Find Project</v-btn>
          </v-card-actions>
          <v-card-text v-if="showFilters">
            <v-select v-model="state"
                      :items="states"
                      label="State"
                      return-object
                      item-text="state"
                      item-value="id"
            ></v-select>
            <v-select
                label="Event Type"></v-select>
            <v-select
                label="Status"></v-select>
          </v-card-text>
          <v-card-text v-else>
            Not sure
          </v-card-text>
        </v-card>
      </v-col>
      <v-col cols="7">
        <v-data-table
            :headers="headers"
            :items="projects"
            :items-per-page="-1"
            item-key="dbFunctionParamId"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No parameters exist for this function
          </template>

          <template #item.projectName="{ item }">
            <a @click="goToProject(item.id)">{{item.projectName}}</a>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import {getActiveStates} from '@/services/stateService'
  import Map from './components/Map'
  import cloneDeep from 'lodash.clonedeep'
  import Calendar from './components/Calendar'

  export default {
    name: 'Schedule',
    components: {
      Snackbar,
      Map,
      Calendar
    },
    data() {
      return {
        snackbar: {},
        showFilters: true,
        defaultZoom: 2.0,
        map: {
          accessToken: '***REMOVED***',
          style: 'mapbox://styles/mapbox/streets-v10'
        },
        // they do these coordinates backwards to comply with geoJSON whatever that is.
        //center of the USA
        defaultCenter: [ -98.5795, 39.8283 ],
        center: null,
        state: {},
        states: [],
        asyncActions: {},
        headers: [
          { text: 'Projects', value: 'projectName', show: true },
          { text: 'Work Type', value: 'workType', show: true },
          { text: 'Status', value: 'statusType', show: true},
          { text: 'Estimated Time', value: 'estimatedTime', show: true},
          { text: 'Time Window', value: 'timeWindow', show: true},
          { text: 'Work Date', value: 'workDate', show: true},
          { text: 'Resource', value: 'Resource', show: true},
        ],
        projects: [
          {
            id: 1,
            projectName: 'Randa Test',
            workType: 'Closer Appointment',
            statusType: 'Un-routed',
            estimatedTime: '60 minutes',
            timeWindow: '8:00 AM - 12:00 PM',
            workDate: null,
            resource: null
          }
        ]
      }
    },
    created () {
      this.getActiveStates()
    },
    methods: {
      goToProject(id) {
        this.$router.push({name: 'project', params: {projectId: id}})
      },
      async getActiveStates () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getActiveStates()
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
.map-row {
  height: 50vh;
  min-height: 300px;
}
.schedule-row {
  height: 40vh;
  min-height: 300px;
}
</style>


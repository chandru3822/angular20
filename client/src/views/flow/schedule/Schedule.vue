<template>
  <v-container>
    <v-row :class="{'map-row': !IS_MOBILE}">
      <v-col cols="12" md="5" :class="{'map-row': IS_MOBILE}">
        <Map :latitude="state.mapLatitude" :markers="projects" :longitude="state.mapLongitude" :zoom="state.mapZoom"></Map>
      </v-col>
      <v-col cols="12" md="7">
        <Calendar :events="projects" :resources="selectedResources"></Calendar>
      </v-col>
    </v-row>
    <v-row class="schedule-row mt-4">
      <v-col cols="12" md="5">
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
                      @input="getSchedulingOrgs"
            ></v-select>
            <v-select v-model="selectedResources"
                      :items="resources"
                      label="Resources"
                      multiple
                      return-object
                      item-text="orgName"
                      item-value="id"
                      @input="getEventsForResources"
            >
              <template
                  slot="selection"
                  slot-scope="{ item, index }"
              >
                <div v-if="index === 0 && selectedResources.length < 3" >
                  <v-chip small v-for="sr in selectedResources">
                    <span>{{ sr.orgName }}</span>
                  </v-chip>
                </div>
                <span
                    v-if="index === 1 && selectedResources.length >= 3"
                    class="primary--text caption"
                >{{ selectedResources.length }} selected</span>
              </template>
            </v-select>
            <v-select v-model="selectedEventTypes"
                      :items="eventTypes"
                      label="Event Type"
                      item-text="processStepName"
                      item-value="id"
                      return-object
                      multiple
            >
              <template
                  slot="selection"
                  slot-scope="{ item, index }"
              >
                <div v-if="index === 0 && selectedEventTypes.length < 3" >
                  <v-chip small v-for="sp in selectedEventTypes">
                    <span>{{ sp.processStepName }}</span>
                  </v-chip>
                </div>
                <span
                    v-if="index === 1 && selectedEventTypes.length >= 3"
                    class="primary--text caption"
                >{{ selectedEventTypes.length }} selected</span>
              </template>
            </v-select>

            <v-select v-model="selectedProcessStepStatusTypes"
                      :items="processStepStatusTypes"
                      label="Status"
                      item-text="processStepStatusType"
                      item-value="id"
                      return-object
                      multiple
            >
              <template
                  slot="selection"
                  slot-scope="{ item, index }"
              >
                <div v-if="index === 0 && selectedProcessStepStatusTypes.length < 3" >
                  <v-chip small v-for="sp in selectedProcessStepStatusTypes">
                    <span>{{ sp.processStepStatusType }}</span>
                  </v-chip>
                </div>
                <span
                    v-if="index === 1 && selectedProcessStepStatusTypes.length >= 3"
                    class="primary--text caption"
                >{{ selectedProcessStepStatusTypes.length }} selected</span>
              </template>
            </v-select>
          </v-card-text>
          <v-card-text v-else>
            Not sure
          </v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12" md="7">
        <v-data-table
            :headers="headers"
            :items="projects"
            :items-per-page="-1"
            :mobile-breakpoint="0"
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
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'
  import {getActiveStates} from '@/services/stateService'
  import Map from './components/Map'
  import {getStatusTypes} from '@/services/processStepStatusTypeService'
  import cloneDeep from 'lodash.clonedeep'
  import Calendar from './components/Calendar'
  import {getRequestWithParams} from "../../../helpers/helpers";

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
        IS_MOBILE,
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
        resources: [],
        selectedResources: [],
        processStepStatusTypes: [],
        selectedProcessStepStatusTypes: [],
        eventTypes: [],
        selectedEventTypes: [],
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
        projects: []
      }
    },
    created () {
      this.getActiveStates()
      this.getStatusTypes()
      this.getEventTypes()
      this.getSchedulingOrgs()
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
      async getSchedulingOrgs () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/org/getSchedulingOrgs`, { params: {
              stateId: this.state?.id ?? null
            }})
          this.resources = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getEventTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          // 'event types' is just schedulable process steps
          const {data} = await getRequest(`/processStep/getSchedulableProcessSteps`)
          this.eventTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getStatusTypes()
          this.processStepStatusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getEventsForResources () {
        //todo: actually do a get when i know how to do so
        this.projects = [
          {
            id: 1,
            projectName: 'Randa Test',
            workType: 'Closer Appointment',
            statusType: 'Un-routed',
            estimatedTime: '60 minutes',
            timeWindow: '8:00 AM - 12:00 PM',
            workDate: null,
            //stuff for fullcalendar event
            resourceId: 219,
            title: 'Meeting',
            start: '2019-10-25T10:30:00',
            end: '2019-10-25T12:30:00',
            allDay: false,
            //stuff for map marker
            color: '#ff0000',
            coordinates: [ -112.03396600000, 43.49165000000 ]
          },
          {
            id: 2,
            projectName: 'Humes Test',
            workType: 'Closer Appointment',
            statusType: 'Un-routed',
            estimatedTime: '60 minutes',
            timeWindow: '8:00 AM - 12:00 PM',
            workDate: null,
            //stuff for fullcalendar event
            resourceId: 248,
            title: 'Meeting',
            start: '2019-10-25T08:30:00',
            end: '2019-10-25T10:30:00',
            allDay: false,
            //stuff for map marker
            color: '#35dffa',
            coordinates: [ -112.1644, 43.3155 ]
          },
          {
            id: 3,
            projectName: 'Keller Test',
            workType: 'Closer Appointment',
            statusType: 'Un-routed',
            estimatedTime: '60 minutes',
            timeWindow: '8:00 AM - 12:00 PM',
            workDate: null,
            //stuff for fullcalendar event
            resourceId: 247,
            title: 'Meeting',
            start: '2019-10-25T09:30:00',
            end: '2019-10-25T10:30:00',
            allDay: false,
            //stuff for map marker
            color: '#68fa30',
            coordinates: [ -112.3450, 43.1905 ]
          }, {
            id: 4,
            projectName: 'Mandy Test',
            workType: 'Closer Appointment',
            statusType: 'Un-routed',
            estimatedTime: '60 minutes',
            timeWindow: '8:00 AM - 12:00 PM',
            workDate: null,
            //stuff for fullcalendar event
            resourceId: 229,
            title: 'Meeting',
            start: '2019-10-25T06:30:00',
            end: '2019-10-25T08:30:00',
            allDay: false,
            //stuff for map marker
            color: '#fa27f8',
            coordinates: [ -111.9150, 43.6724 ]
          }
        ]
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


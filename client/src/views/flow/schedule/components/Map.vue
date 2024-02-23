<template>
  <MglMap id="map" :accessToken="map.accessToken"
          :mapStyle="map.style"
          @load="onMapLoad">

    <div id="find-drive-time" class="d-flex justify-start">
      <v-btn color="primary" class="rounded-tile-btn ml-4 mr-3" fab tile @click="$emit('close-map')"><v-icon>mdi-chevron-right</v-icon></v-btn>
      <v-menu data-app bottom
              offset-y
              content-class="drive-time-menu"
              v-model="menuOpen"
              :min-width="260"
              :max-width="260"
              :close-on-click="false"
              :close-on-content-click="false">
        <template v-slot:activator="{ on }">
          <v-btn fab tile outlined v-on="on" @click="searchMenuOpen = false" small color="primary" class="rounded-tile-btn white-background mr-3"><v-icon>mdi-car</v-icon></v-btn>
        </template>
        <v-card id="drive-time-card" color="white" class="square-card pa-4">
          <div class="d-flex justify-space-between">
          <v-card-title class="label-large pa-0">Find Drive Time</v-card-title>
            <v-btn icon small @click="menuOpen = false"><v-icon>close</v-icon></v-btn>
          </div>
          <div class="address-container">
            <div class="one-hunned py-3">
              <v-text-field text outlined label="Starting Point" placeholder="Select pin or enter address" autocomplete="new-password"
                            @click="[address1 = '', drivingDistance = 0, drivingDuration = 0, selectAddress1 = true, selectAddress2 = false]"
                            hide-details
                            v-model="address1"
                            @input="[showAddress2List = false, debounceSearchAddress(address1, true)]"></v-text-field>
              <v-list ref="dropdownMenu1" v-if="showAddress1List">
                <v-list-item v-for="(suggestion, idx) in suggestions">
                  <v-card class="pa-2" outlined :class="{'mt-2': idx !== 0}" @click="selectAddress(suggestion, true)">
                    <span class="dropdown-item text-decoration-none" >
                      {{ formatLabel(suggestion.label, 'start') }}<span>{{
                        formatLabel(suggestion.label, 'middle')
                      }}</span>{{ formatLabel(suggestion.label, 'end') }}
                    </span>
                  </v-card>
                </v-list-item>
              </v-list>
            </div>
<!--            <v-btn class="mt-2" small color="primary"-->
<!--                   @click="[address1 = '', drivingDistance = 0, drivingDuration = 0, selectAddress1 = !selectAddress1, selectAddress2 = false]"-->
<!--                   :disabled="mapResources.length === 0 && markers.length === 0"-->
<!--                   :loading="selectAddress1">Select Pin-->
<!--            </v-btn>-->
          </div>

          <div class="address-container">
            <div class="one-hunned">
              <v-text-field text outlined label="Destination" placeholder="Select pin or enter address" autocomplete="new-password"
                            @click="[address2 = '', drivingDistance = 0, drivingDuration = 0, selectAddress2 = true, selectAddress1 = false]"
                            hide-details
                            v-model="address2"
                            @input="[showAddress1List = false, debounceSearchAddress(address2, false)]"></v-text-field>
              <v-list ref="dropdownMenu2" v-if="showAddress2List">
                <v-list-item v-for="(suggestion, idx) in suggestions">
                  <v-card class="pa-2" outlined :class="{'mt-2': idx !== 0}" @click="selectAddress(suggestion, false)">
                    <span class="dropdown-item text-decoration-none">
                      {{ formatLabel(suggestion.label, 'start') }}<span>{{
                        formatLabel(suggestion.label, 'middle')
                      }}</span>{{ formatLabel(suggestion.label, 'end') }}
                    </span>
                  </v-card>
                </v-list-item>
              </v-list>
            </div>
<!--            <v-btn class="mt-2" small color="primary"-->
<!--                   @click="[address2 = '', drivingDistance = 0, drivingDuration = 0, selectAddress2 = !selectAddress2, selectAddress1 = false]"-->
<!--                   :disabled="mapResources.length === 0 && markers.length === 0"-->
<!--                   :loading="selectAddress2">Select Pin-->
<!--            </v-btn>-->
          </div>

<!--          <v-divider class="mt-2"></v-divider>-->

<!--          <div class="mt-2 drive-time-buttons">-->
<!--            <v-btn text small class="mr-3" @click="[address1 = '', address2 = '', clearColors()]">Clear</v-btn>-->
<!--            <v-btn color="primary" small :disabled="!address1 || !address2"-->
<!--                   :loading="loadingDriveTime"-->
<!--                   @click="loadDriveTime">Calculate-->
<!--            </v-btn>-->
<!--          </div>-->

          <div class="mt-2 body-large">
            <div>Drive Time:</div> <span v-if="drivingDuration">{{ drivingDuration }}</span>
            <div>Drive Distance:</div><span v-if="drivingDistance">{{ drivingDistance }} miles</span>
          </div>
        </v-card>
      </v-menu>
      <slot name="searchMenu"/>
    </div>
    <!-- these markers come from the project search  -->
    <MglMarker v-for="m in markers" v-if="m.coordinates"
               :key="m.projectProcessStepEventId + `${markerCount}`"
               :coordinates="m.coordinates"
               @click="selectAddressForDriveTime(m)"
               :color="m.color || defaultEmptyColor">
      <MglPopup :close-button="false">
        <VCard flat>
          {{ m.projectName }}<br/>
          {{ m.processStepName }}
          <span v-if="null != m.street1 || null != m.city || null != m.postalCode">
            <br/>
            {{ m.street1 }}<br/>
            {{ m.city }}, {{ m.stateAbbreviation }} {{ m.postalCode }}<br/>
            {{ m.color }} - {{ m.projectProcessStepEventId + markerCount.toString() }}
          </span>
        </VCard>
      </MglPopup>
    </MglMarker>
    <!-- these markers come from the calendar  -->
    <MglMarker v-for="m in mapResources" v-if="m.coordinates"
               :key="m.projectProcessStepEventId + `${markerCount}`"
               :coordinates="m.coordinates"
               @click="selectAddressForDriveTime(m)"
               :color="m.color || defaultEmptyColor">
      <MglPopup :close-button="false">
        <VCard flat>
          {{ m.projectName }}<br/>
          {{ m.processStepName }}
          <span v-if="null != m.street1 || null != m.city || null != m.postalCode">
            <br/>
            {{ m.street1 }}<br/>
            {{ m.city }}, {{ m.stateAbbreviation }} {{ m.postalCode }}
          </span>
        </VCard>
      </MglPopup>
    </MglMarker>
    <MglNavigationControl :showCompass="false" position="top-right"/>
  </MglMap>
</template>

<script>
import 'mapbox-gl/dist/mapbox-gl.css'
import '@7oaksgroup/v-mapbox/dist/v-mapbox.css'
import {MglMap, MglMarker, MglNavigationControl, MglPopup} from '@7oaksgroup/v-mapbox'
import constants from '@/helpers/constants'
import {getRequestWithParams, getSnackbar, postRequest} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import moment from 'moment'
import debounce from "lodash.debounce";
import axios from "axios";
import ProjectSearchDialog from "@/views/flow/schedule/components/ProjectSearchDialog.vue";

export default {
  name: 'ScheduleMap',
  components: {
    ProjectSearchDialog,
    MglMap,
    MglPopup,
    MglMarker,
    MglNavigationControl
  },
  props: {
    latitude: {type: Number},
    longitude: {type: Number},
    zoom: {type: Number},
    markers: {type: Array},
    mapResources: {type: Array},
    states:Array,
    startTime:String,
    endTime: String,
  },
  watch: {
    'latitude': function () {
      // reset the selected group when the object type changes
      this.changeMapLocation()
    },
    search(val) {
      if(!val) {
        this.searchProject = {}
        return
      }
      if(val && (!this.searchProject || this.searchProject.projectName !== val)) {
        this.getProjectsSearchedFor(val);
      }
    },
  },
  data() {
    return {
      snackbar: {},
      menuOpen: false,
      loadingDriveTime: false,
      constants,
      markerCount: 0, //this is used to reset the key when the color of a marker changes so it gets redrawn
      drivingMarkerColor: '#ab4711',
      defaultEmptyColor: '#ffffff',
      location: '',
      address1: '',
      showAddress1List: false,
      selectAddress1: false,
      address2: '',
      selectAddress2: false,
      showAddress2List: false,
      distanceDivisionMetric: 1609.34,
      durationDivisionMetric: 60,
      defaultZoom: 2.0,
      suggestions: [],
      // they do these coordinates backwards to comply with geoJSON whatever that is.
      //center of the USA
      defaultCenter: [-98.5795, 39.8283],
      center: null,
      map: {
        accessToken: constants.MAPBOX_ACCESS_TOKEN,
        style: constants.MAPBOX_STYLE
      },
      // mapboxOptions: {},
      drivingDuration: 0,
      drivingDistance: 0,

      //used for search,

    }
  },
  created() {},
  methods: {
    selectAddress(suggestion, isFirst) {
      if (isFirst) {
        this.address1 = suggestion.label
        this.showAddress1List = false
        if(!!this.address2){
          this.loadDriveTime()
        }
      } else {
        this.address2 = suggestion.label
        this.showAddress2List = false
        if(!!this.address1){
          this.loadDriveTime()
        }
      }
    },
    formatLabel(label, part) {
      let index = label.toLowerCase().indexOf(this.address1.toLowerCase())
      if (index >= 0) {
        let text = ''
        switch (part) {
          case 'start':
            text = label.substring(0, index)
            break
          case 'middle':
            text = label.substring(index, index + this.address1.length)
            break
          case 'end':
            text = label.substring(index + this.address1.length)
            break
        }
        return text
      } else if (part === 'start') {
        return label
      } else {
        return ''
      }
    },
    debounceSearchAddress: debounce(function (address, isFirst) {
      this.clearMarkerSelectionForOne(isFirst)
      this.searchAddress(address, isFirst)
    }, 500),
    async searchAddress(address, isFirst) {
      this.suggestions = []
      if (isFirst) {
        if (this.address1.length >= 2) {
          await this.geoCode(this.address1)
          this.showAddress1List = true
        } else {
          this.showAddress1List = false
        }
      } else {
        if (this.address2.length >= 2) {
          await this.geoCode(this.address2)
          this.showAddress2List = true
        } else {
          this.showAddress2List = false
        }
      }
    },
    async geoCode(address) {
      if (this.address1.length >= 2 || this.address2.length >= 2) {
        try {
          let params = {
            address
          }
            const {data} = await getRequestWithParams(`/mapbox/getSuggestions`, {params})
          if (data.features) {
            let addresses = data.features.map(address => {
              let label = address.place_name
              let location = label.split(', ')[1]
              return {
                label: label,
                street: label.split(', ')[0],
                postcode: location.slice(0, location.indexOf(' ')),
                city: location.slice(1 + location.indexOf(' ')),
                state: address.context.at(-2).text,
                country: address.context.at(-1).text
              }
            })
            this.suggestions = addresses
            // return addresses
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Getting Address Suggestions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }

        // let searchtext = encodeURIComponent(address)
        // let {api, endpoint, ...query} = this.mapboxOptions
        // let queryString = new URLSearchParams(query).toString()
        // let request = new Request(`${api + endpoint}/${searchtext}.json?${queryString}`)
        // let response = await fetch(request)
        // let data = await response.json()

      }
      else {

      }
    },
    clearMarkerSelectionForOne(isFirst){
      if(isFirst) {
        this.markers.forEach(m => {
          if (m.oldColor !== undefined && m.selectedFirst) {
            m.color = m.oldColor
            m.selectedFirst = false
          }
        })
        this.mapResources.forEach(m => {
          if (m.oldColor !== undefined && m.selectedFirst) {
            m.color = m.oldColor
            m.selectedFirst = false
          }
        })
      } else {
        this.markers.forEach(m => {
          if(m.oldColor !== undefined && m.selectedSecond) {
            m.color = m.oldColor
            m.selectedSecond = false
          }
        })
        this.mapResources.forEach(m => {
          if (m.oldColor !== undefined && m.selectedSecond) {
            m.color = m.oldColor
            m.selectedSecond = false
          }
        })
      }
      this.resetDriveTime()
    },
    resetDriveTime() {
      this.drivingDistance = 0
      this.drivingDuration = 0
      this.markerCount++
      this.suggestions = []
    },
    clearColors() {
      this.markers.forEach(m => {
        if (m.oldColor !== undefined) {
          m.color = m.oldColor
          m.selectedFirst = false
          m.selectedSecond = false
        }
      })
      this.mapResources.forEach(m => {
        if (m.oldColor !== undefined) {
          m.color = m.oldColor
          m.selectedFirst = false
          m.selectedSecond = false
        }
      })
      this.resetDriveTime();
      this.showAddress1List = false
      this.showAddress2List = false
      this.selectAddress1 = false
      this.selectAddress2 = false
    },
    selectAddressForDriveTime(marker) {
      if (this.selectAddress1) {
        this.address1 = marker.street1 + ', ' + marker.city + ', ' + marker.stateAbbreviation + ' ' + marker.postalCode
        this.selectAddress1 = false
        //dont move out of if statement, because we dont want the colors to change unless they are selecting an address for drive time
        marker.oldColor = marker.color || this.defaultEmptyColor
        marker.color = this.drivingMarkerColor
        //get a list of all addresses selectedFirst and unset them, then set this one to selectedFirst
        let firstMarkers = this.markers.filter(m => m.selectedFirst)
        let firstResourceMarkers = this.mapResources.filter(m => m.selectedFirst)
        firstMarkers?.forEach(m => {
          m.selectedFirst = false
          m.color = m.oldColor
        })
        firstResourceMarkers?.forEach(m => {
          m.selectedFirst = false
          m.color = m.oldColor
        })
        marker.selectedFirst = true
        this.markerCount++
        if(!!this.address2){
          this.loadDriveTime()
        }
      } else if (this.selectAddress2) {
        this.address2 = marker.street1 + ', ' + marker.city + ', ' + marker.stateAbbreviation + ' ' + marker.postalCode
        this.selectAddress2 = false
        marker.oldColor = marker.color || this.defaultEmptyColor
        marker.color = this.drivingMarkerColor
        //get a list of all addresses selectedSecond and unset them, then set this one to selectedSecond
        let secondMarkers = this.markers.filter(m => m.selectedSecond)
        let secondResourceMarkers = this.mapResources.filter(m => m.selectedSecond)
        secondMarkers?.forEach(m => {
          m.selectedSecond = false
          m.color = m.oldColor
        })
        secondResourceMarkers?.forEach(m => {
          m.selectedSecond = false
          m.color = m.oldColor
        })
        marker.selectedSecond = true
        this.markerCount++
        if(!!this.address1){
          this.loadDriveTime()
        }
      }
    },
    async getLatLong(address) {
      try {
        let params = {
          address
        }
        return await getRequestWithParams(`/mapbox/getLatLong`, {params})
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Getting Address Lat & Long')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async loadDriveTime() {
      this.$gtag.event('brs_drive_time', {event_category: "engagement", event_label: "Drive Time"})
      this.loadingDriveTime = true
      const {data: first} = await this.getLatLong(this.address1)
      const {data: second} = await this.getLatLong(this.address2)

      //then need to load the drive time/route stuff
      await this.getDirections(first, second)
    },
    async getDirections(firstPair, secondPair) {
      this.drivingDistance = 0
      this.drivingDuration = 0

      try {
        let params = {
          latLongPairs: firstPair + ';' + secondPair
        }

        const {data} = await getRequestWithParams(`/mapbox/getDriveTime`, {params})
        if (data.routes && data.routes[0]) {
          if (data.routes[0].distance) {
            this.drivingDistance = (data.routes[0].distance / this.distanceDivisionMetric).toFixed(2)
          }

          if (data.routes[0].duration) {
            this.drivingDuration = moment().startOf('day').seconds(data.routes[0].duration).format('H[h] mm [m] ss [s]')
          }
        }
        this.loadingDriveTime = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Getting Drive Time')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async changeMapLocation() {
      try {
        this.center = this.latitude && this.longitude ? [this.longitude, this.latitude] : this.defaultCenter
        let zoom = this.zoom ?? this.defaultZoom
        await this.asyncActions.flyTo({
          center: this.center,
          zoom: zoom,
          speed: 2
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error jumping to address')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async onMapLoad(event) {
      // Here we're catching 'load' map event
      this.asyncActions = event.component.actions
      await this.changeMapLocation()
    },


    /**Project Search Methods**/
    async getProjects(resetQuery) {
      if(resetQuery) {
        // todo: should we remove this.$route.query params if the button is clicked?
        // this.$route.query = {}
      }

      const {page, itemsPerPage} = this.options
      localStorage.setItem('scheduleState', JSON.stringify(this.state))
      localStorage.setItem('scheduleEventTypes', JSON.stringify(this.selectedEventTypes))
      localStorage.setItem('scheduleProcessStepStatusType', JSON.stringify(this.selectedProcessStepStatusType))
      localStorage.setItem('scheduleEventStatusType', JSON.stringify(this.searchEventStatusType))

      if(this.selectedEventTypes?.length > 0) {
        this.listLoading = true
        try {
          if(this.source){
            this.source.cancel();
          }
          const CancelToken = axios.CancelToken;
          this.source = CancelToken.source();

          const {data} = await postRequest(`/schedule/projects`, {
            search: this.projectFilter,
            source: this.source,
            cancelToken: this.source.token,
            eventIds: this.selectedEventTypes?.length > 0 ? this.selectedEventTypes.map(o => o.id) : [],
            //old way
            // processStepStatusTypeId: this.selectedProcessStepStatusType.processStepStatusTypeId,
            // new way:
            processStepStatusTypeId: this.selectedProcessStepStatusType.id,
            eventStatusTypeId: this.searchEventStatusType.id,
            companyStateId: this.state.id,
            startTime: this.startTime,
            endTime: this.endTime,
            page: page - 1,
            size: itemsPerPage
          })
          this.projects = data.content || []
          this.projects.forEach(d => {
            d.coordinates = [ d.longitude, d.latitude ]
          })
          this.totalProjects = data.totalElements
          this.listLoading = false
          this.initialLoad = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Projects')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.listLoading = false
        }
      } else {
        this.projects = []
      }
    },
    async searchForProjects(search) {
      try {
        let params = {
          search
        }
        const {data} = await postRequest(`/schedule/projects/search`, params)
        this.searchProjects = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Searching Projects')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getProjectsSearchedFor(search) {
      // cancel pending call
      clearTimeout(this._timerId);

      this.searchProjectsLoading = true

      // delay new call 500ms
      this._timerId = setTimeout(async () => {
        //todo:_this
        await this.searchForProjects(search)
        this.searchProjectsLoading = false
      }, 500)
    },
    async getSingleProject(projectId, eventId, eventStatusTypeId, processStepStatusTypeId, projectProcessStepEventId) {
      this.listLoading = true
      try {
        let params = {
          projectId,
          eventId,
          processStepStatusTypeId,
          projectProcessStepEventId,
          eventStatusTypeId
        }

        //"getProject" is a bad term for this endpoint. it really returns a specific event with some project details
        const {data} = await postRequest(`/schedule/getProject`, params, null, [])
        this.projects = data
        this.projects.forEach(d => {
          d.coordinates = [ d.longitude, d.latitude ]
        })

        this.totalProjects = this.projects.length

        if(this.projects.length === 1) {
          this.selectedProject = this.projects[0]
          this.selectedProject.resource = { id: this.selectedProject.resourceId, name: this.selectedProject.resourceName }
          this.selectedRows.push(this.projects[0])
          this.zoomToMap({
            item:{
              longitude: this.selectedProject.longitude,
              latitude: this.selectedProject.latitude
            },
            value: true
          })
        }
        this.listLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Project Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.listLoading = false
      }
    },
    async getEventStatusTypes () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getEventStatusTypes()
        this.eventStatusTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getStatusTypes() {
      try {
        //the old way
        // const {data} = await getCompanyStatusTypes()
        // //only show active and complete
        // this.processStepStatusTypes = data.filter(d => d.processStepStatusTypeId !== 3)

        //the new way - use root statuses
        const {data} = await getStatusTypes()
        //only show active and complete
        this.processStepStatusTypes = data?.filter(d => d.id !== 3)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }

}
</script>

<style lang="scss">
.drive-time-menu {
  border-radius: 0 !important;
}

#drive-time-card > div > div > div.v-list.v-sheet {
  max-height: calc(100vh - 400px);
  overflow-y: auto;

  .v-list-item {
    //padding: 0;
    //looked at removing the padding on the child as shown in figma, but it looks odd with the scrollbar
  }
}

</style>

<style scoped lang="scss">

#find-drive-time > button.rounded-tile-btn.v-btn.v-btn--fab.v-btn--round.v-btn--tile  {
  border-radius: 4px;

  &.white-background {
    background-color: white;
  }
}

#find-drive-time {
  position: absolute;
  top: 10px;
  left: 10px;
}

.drive-time-buttons {
  display: flex;
  justify-content: space-between;
}

.project-search-card{
  position: relative;
  top:40px;
  right:38px;
}
</style>

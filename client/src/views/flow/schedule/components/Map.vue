<template>
  <MglMap id="map" :accessToken="map.accessToken"
          :mapStyle="map.style"
          @load="onMapLoad">
    <div id="find-drive-time">
      <v-menu data-app bottom
              offset-y
              content-class="drive-time-menu"
              v-model="menuOpen"
              :min-width="260"
              :max-width="260"
              :close-on-click="false"
              :close-on-content-click="false">
        <template v-slot:activator="{ on }">
          <v-btn small :color="menuOpen ? 'grey lighten-4' : 'primary'" v-on="on">Find Drive Time</v-btn>
        </template>
        <v-card color="white" class="square-card px-4 pb-4 pt-2">
          <div class="address-container">
            <div class="one-hunned">
              <v-text-field text label="Address 1" autocomplete="new-password"
                            @click="selectAddress1 = false"
                            hide-details
                            v-model="address1" @input="[showAddress2List = false, debounceSearchAddress(address1, true)]"></v-text-field>
              <v-list ref="dropdownMenu1" v-if="showAddress1List">
                <v-list-item v-for="(suggestion, idx) in suggestions">
                  <v-card class="pa-2" outlined :class="{'mt-2': idx !== 0}">
                    <a class="dropdown-item text-decoration-none" href="#" @click="selectAddress(suggestion, true)">
                      {{ formatLabel(suggestion.label, 'start') }}<span
                      class="text-primary">{{
                        formatLabel(suggestion.label, 'middle')
                      }}</span>{{ formatLabel(suggestion.label, 'end') }}
                    </a>
                  </v-card>
                </v-list-item>
              </v-list>
            </div>
            <v-btn class="mt-2" small color="primary" @click="[address1 = '', drivingDistance = 0, drivingDuration = 0, selectAddress1 = !selectAddress1, selectAddress2 = false]"
                   :disabled="mapResources.length === 0 && markers.length === 0"
                   :loading="selectAddress1">Select Pin
            </v-btn>
          </div>

          <div class="address-container">
            <div class="one-hunned">
              <v-text-field text label="Address 2" autocomplete="new-password"
                            @click="selectAddress2 = false"
                            hide-details
                            v-model="address2" @input="[showAddress1List = false, debounceSearchAddress(address2, false)]"></v-text-field>
              <v-list ref="dropdownMenu2" v-if="showAddress2List">
                <v-list-item v-for="(suggestion, idx) in suggestions">
                  <v-card class="pa-2" outlined :class="{'mt-2': idx !== 0}">
                    <a class="dropdown-item text-decoration-none" href="#"
                       @click="selectAddress(suggestion, false)">
                      {{ formatLabel(suggestion.label, 'start') }}<span
                      class="text-primary">{{
                        formatLabel(suggestion.label, 'middle')
                      }}</span>{{ formatLabel(suggestion.label, 'end') }}
                    </a>
                  </v-card>
                </v-list-item>
              </v-list>
            </div>
            <v-btn class="mt-2" small color="primary" @click="[address2 = '', drivingDistance = 0, drivingDuration = 0, selectAddress2 = !selectAddress2, selectAddress1 = false]"
                   :disabled="mapResources.length === 0 && markers.length === 0"
                   :loading="selectAddress2">Select Pin
            </v-btn>
          </div>

          <v-divider class="mt-2"></v-divider>

          <div class="mt-2 drive-time-buttons">
            <v-btn text small class="mr-3" @click="[address1 = '', address2 = '', clearColors()]">Clear</v-btn>
            <v-btn color="primary" small :disabled="!address1 || !address2"
                   :loading="loadingDriveTime"
                   @click="loadDriveTime">Calculate</v-btn>
          </div>

          <div class="mt-2" v-if="drivingDistance || drivingDuration">
            <v-divider class="mb-2"></v-divider>
            <strong>Drive Time:</strong> {{ drivingDuration }} <br>
            <strong>Drive Distance:</strong> {{ drivingDistance }} miles
          </div>
        </v-card>
      </v-menu>
    </div>
    <!-- these markers come from the lower data table  -->
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
            {{ m.color }} - {{m.projectProcessStepEventId + markerCount.toString() }}
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
import Mapbox from 'mapbox-gl'
import {MglMap, MglPopup, MglMarker, MglNavigationControl} from 'vue-mapbox'
import constants from '@/helpers/constants'
import {getRequestWithParams, getSnackbar, postRequest} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import moment from 'moment'
import debounce from "lodash.debounce";

export default {
  name: 'ScheduleMap',
  components: {
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
  },
  watch: {
    'latitude': function () {
      // reset the selected group when the object type changes
      this.changeMapLocation()
    }
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
      drivingDistance: 0
    }
  },
  created() {
    this.createMap()
  },
  methods: {
    createMap() {

      // this.mapboxOptions = {
      //   api: 'https://api.mapbox.com/geocoding/v5/',
      //   endpoint: 'mapbox.places',
      //   access_token: constants.MAPBOX_ACCESS_TOKEN,
      //   limit: 5,
      //   types: 'address',
      //   proximity: 'ip',
      //   autocomplete: true,
      //   fuzzyMatch: true,
      //   language: 'en'
      // }

      this.mapbox = Mapbox
    },
    selectAddress(suggestion, isFirst) {
      if (isFirst) {
        this.address1 = suggestion.label
        this.showAddress1List = false
      } else {
        this.address2 = suggestion.label
        this.showAddress2List = false
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
        // console.log(`Found ${searchtext.value} in ${label} at pos ${index} and ${part} part is ${text}`);
        return text
      } else if (part === 'start') {
        return label
      } else {
        return ''
      }
    },
    debounceSearchAddress: debounce(function (address, isFirst) {
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
          } else {
            console.log(data.message)
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
    },
    clearColors() {
      this.markers.forEach(m => {
        if(m.oldColor !== undefined) {
          m.color = m.oldColor
          m.selectedFirst = false
          m.selectedSecond = false
        }
      })
      this.mapResources.forEach(m => {
        if(m.oldColor !== undefined) {
          m.color = m.oldColor
          m.selectedFirst = false
          m.selectedSecond = false
        }
      })
      this.drivingDistance = 0
      this.drivingDuration = 0
      this.markerCount++
      this.suggestions = []
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
      // Here we catching 'load' map event
      await this.asyncActions.flyTo({
        center: [this.longitude, this.latitude],
        zoom: this.zoom,
        speed: 2
      })

    },
    async onMapLoad(event) {
      // Here we catching 'load' map event
      this.asyncActions = event.component.actions
      this.center = this.latitude && this.longitude ? [this.longitude, this.latitude] : this.defaultCenter
      let zoom = this.zoom ?? this.defaultZoom
      await this.asyncActions.flyTo({
        center: this.center,
        zoom: zoom,
        speed: 2
      })
    },
  }

}
</script>

<style lang="scss">
.drive-time-menu {
  border-radius: 0 !important;
}
</style>

<style scoped lang="scss">
#find-drive-time {
  position: absolute;
  top: 10px;
  left: 10px;
}

.drive-time-buttons {
  display: flex;
  justify-content: space-between;
}
</style>

<template>
  <MglMap id="map" :accessToken="map.accessToken"
          :mapStyle="map.style"
          @load="onMapLoad">
    <div id="find-drive-time">
      <v-menu data-app bottom
              offset-y
              content-class="drive-time-menu"
              v-model="menuOpen"
              :close-on-click="false"
              :close-on-content-click="false">
        <template v-slot:activator="{ on }">
          <v-btn :color="menuOpen ? 'grey lighten-4' : 'primary'" v-on="on">Find Drive Time</v-btn>
        </template>
        <v-card color="white" class="square-card pa-4">
          Location: {{ location }}

          <v-text-field text label="Address 1" autocomplete="new-password"
                        v-model="address1" @input="searchAddress(address1, true)"></v-text-field>
<!--          <input type="text" class="form-control" v-model="address1" @input="searchAddress"/>-->
          <v-list ref="dropdownMenu1" v-if="showAddress1List">
            <v-list-item v-for="suggestion in suggestions">
              <a class="dropdown-item" href="#" @click="selectAddress(suggestion, true)">
                {{ formatLabel(suggestion.label, 'start') }}<span
                class="text-primary">{{ formatLabel(suggestion.label, 'middle') }}</span>{{ formatLabel(suggestion.label, 'end') }}
              </a>
            </v-list-item>
          </v-list>

          <v-text-field text  label="Address 2" autocomplete="new-password"
                        v-model="address2" @input="searchAddress(address2, false)"></v-text-field>
          <v-list ref="dropdownMenu2" v-if="showAddress2List">
            <v-list-item v-for="suggestion in suggestions">
              <a class="dropdown-item" href="#" @click="selectAddress(suggestion, false)">
                {{ formatLabel(suggestion.label, 'start') }}<span
                class="text-primary">{{ formatLabel(suggestion.label, 'middle') }}</span>{{ formatLabel(suggestion.label, 'end') }}
              </a>
            </v-list-item>
          </v-list>

<!--          <div class="address-container">-->
<!--            <v-text-field text label="Address 1"-->
<!--                          hide-details-->
<!--                          v-model="address1"></v-text-field>-->
<!--            <v-btn color="primary" @click="[address1 = '', selectAddress1 = !selectAddress1, selectAddress2 = false]"-->
<!--                   :loading="selectAddress1">Select-->
<!--            </v-btn>-->
<!--          </div>-->
<!--          <div class="address-container">-->
<!--            <v-text-field text label="Address 2"-->
<!--                          hide-details-->
<!--                          v-model="address2"></v-text-field>-->
<!--            <v-btn color="primary" @click="[address2 = '', selectAddress2 = !selectAddress2, selectAddress1 = false]"-->
<!--                   :loading="selectAddress2">Select-->
<!--            </v-btn>-->
<!--          </div>-->
          <div class="mt-2">
            <v-btn text class="mr-3" @click="[address1 = '', address2 = '']">Clear</v-btn>
            <v-btn color="primary"  @click="loadDriveTime">Go</v-btn>
          </div>
        </v-card>
      </v-menu>
    </div>
    <!-- these markers come from the lower data table  -->
    <MglMarker v-for="m in markers" v-if="m.coordinates"
               :key="m.id"
               :coordinates="m.coordinates"
               @click="selectAddressForDriveTime(m)"
               :color="m.color || '#ffffff'">
      <MglPopup :close-button="false">
        <VCard flat>
          {{ m.contactFirstName }} {{ m.contactLastName }}<br/>
          {{ m.processStepName }}
          <span v-if="null != m.street1 || null != m.city || null != m.postalCode">
            <br/>
            {{ m.street1 }}<br/>
            {{ m.city }}, {{ m.stateAbbreviation }} {{ m.postalCode }}
          </span>
        </VCard>
      </MglPopup>
    </MglMarker>
    <!-- these markers come from the calendar  -->
    <MglMarker v-for="m in mapResources" v-if="m.coordinates"
               :key="m.id"
               :coordinates="m.coordinates"
               :color="m.color || '#ffffff'">
      <MglPopup :close-button="false" :onclick="selectAddressForDriveTime"
                :ondrag="selectAddressForDriveTime" :ondragend="selectAddressForDriveTime"
                :ondragstart="selectAddressForDriveTime">
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
import axios from 'axios'
import 'mapbox-gl/dist/mapbox-gl.css'
import {AddressAutofill} from '@mapbox/search-js-core'
import Mapbox from 'mapbox-gl'
import {MglMap, MglPopup, MglMarker, MglNavigationControl} from 'vue-mapbox'
import constants from '@/helpers/constants'
import {getRequestWithParams, getSnackbar, postRequest} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";

export default {
  name: 'ScheduleMap',
  components: {
    MglMap,
    MglPopup,
    MglMarker,
    MglNavigationControl,
    AddressAutofill
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
      constants,
      location: '',
      address1: '',
      showAddress1List: false,
      selectAddress1: false,
      address2: '',
      selectAddress2: false,
      showAddress2List: false,
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
      mapboxOptions: {}
    }
  },
  created() {
    this.createMap()
  },
  methods: {
    getDynamicId() {
      //this is super dumb but it is the only legit way i've found to disable autocompleting fields
      return 'dynamicID-' + Math.floor(Math.random() * Date.now())
    },
    createMap() {

      this.mapboxOptions = {
        api: 'https://api.mapbox.com/geocoding/v5/',
        endpoint: 'mapbox.places',
        access_token: constants.MAPBOX_ACCESS_TOKEN,
        limit: 5,
        types: 'address',
        proximity: 'ip',
        autocomplete: true,
        fuzzyMatch: true,
        language: 'en'
      }

      this.mapbox = Mapbox
    },
    selectAddress(suggestion, isFirst) {
      if(isFirst) {
        console.log('1) SELECTED THIS ADDRESS: ', suggestion)
        this.address1 = suggestion.label
        this.showAddress1List = false
      } else {
        console.log('2) SELECTED THIS ADDRESS: ', suggestion)
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
    async searchAddress(address, isFirst) {
      console.log('trying stuff', address)
      this.suggestions = []
      if (isFirst) {
        if(this.address1.length >= 2) {
          await this.geoCode(this.address1)
          this.showAddress1List = true
        } else {
          this.showAddress1List = false
        }
      } else {
        if(this.address2.length >= 2) {
          console.log('we true')
          await this.geoCode(this.address2)
          this.showAddress2List = true
        } else {
          console.log('we false')
          this.showAddress2List = false
        }
      }
    },
    async geoCode(address) {
      if (this.address1.length >= 2 || this.address2.length >= 2) {
        let searchtext = encodeURIComponent(address)
        let {api, endpoint, ...query} = this.mapboxOptions
        let queryString = new URLSearchParams(query).toString()
        let request = new Request(`${api + endpoint}/${searchtext}.json?${queryString}`)
        let response = await fetch(request)
        let data = await response.json()
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
          console.log('suggestions', this.suggestions)
          // return addresses
        } else {
          console.log(data.message)
        }
      }
    },
    selectAddressForDriveTime(marker) {
      if (this.selectAddress1) {
        this.address1 = marker.street1 + ', ' + marker.city + ', ' + marker.stateAbbreviation + ' ' + marker.postalCode
        this.selectAddress1 = false
      } else if (this.selectAddress2) {
        this.address2 = marker.street1 + ', ' + marker.city + ', ' + marker.stateAbbreviation + ' ' + marker.postalCode
        this.selectAddress2 = false
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
      const {data:first } = await this.getLatLong(this.address1)
      console.log('first lat long here', first)
      const {data:second } = await this.getLatLong(this.address1)
      console.log('second lat long here', second)

      //then need to load the drive time/route stuff
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

.address-container {
  display: flex;
}
</style>

<template>
  <MglMap id="map" :accessToken="map.accessToken"
          :mapStyle="map.style"
          @load="onMapLoad">

    <div id="map-btns" class="d-flex justify-start">
      <a-btn id="hide-map-btn" color="primary" size="small" class="rounded-tile-btn ml-4 mr-3" :elevation="5" custom-classes="px-4" @click="$emit('close-map')"><v-icon>mdi-chevron-right</v-icon></a-btn>
      <v-menu data-app bottom
              offset-y
              content-class="drive-time-menu"
              v-model="menuOpen"
              :min-width="260"
              :max-width="260"
              :close-on-click="false"
              :close-on-content-click="false">
        <template v-slot:activator="{ on }">
          <a-btn id="drive-time-btn" variant="outlined" :activation-handler="on" icon color="primary" class="rounded-tile-btn white-background mr-3"><v-icon>mdi-car</v-icon></a-btn>
        </template>
        <v-card id="drive-time-card" color="white" class="square-card pa-4">
          <div class="d-flex justify-space-between">
            <v-card-title class="label-large pa-0">Find Drive Time</v-card-title>
            <a-btn icon size="small" @click="menuOpen = false"><v-icon>close</v-icon></a-btn>
          </div>
          <div class="address-container">
            <div class="one-hunned py-3">
              <a-text-field  variant="outlined" label="Starting Point" placeholder="Select pin or enter address" autocomplete="new-password"
                            @click="[address1 = '', drivingDistance = 0, drivingDuration = 0, selectAddress1 = true, selectAddress2 = false]"
                            hide-details
                            v-model="address1"
                            @input="[showAddress2List = false, debounceSearchAddress(address1, true)]"></a-text-field>
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
          </div>

          <div class="address-container">
            <div class="one-hunned">
              <a-text-field  variant="outlined" label="Destination" placeholder="Select pin or enter address" autocomplete="new-password"
                            @click="[address2 = '', drivingDistance = 0, drivingDuration = 0, selectAddress2 = true, selectAddress1 = false]"
                            hide-details
                            v-model="address2"
                            @input="[showAddress1List = false, debounceSearchAddress(address2, false)]"></a-text-field>
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
            <div class="mt-2 body-large">
              <div>Drive Time:</div> <span v-if="drivingDuration">{{ drivingDuration }}</span>
              <div>Drive Distance:</div><span v-if="drivingDistance">{{ drivingDistance }} miles</span>
            </div>
          </div>
        </v-card>
      </v-menu>
      <slot name="searchMenu"/>
    </div>
    <!--    this marker is for the event we came from using 'open scheduler'-->
    <MglMarker v-if="currentProjectMarker.pinned"
               :key="currentProjectMarker.projectProcessStepEventId+ `${markerCount}`"
               :coordinates="currentProjectMarker.coordinates"

               @click="selectAddressForDriveTime(currentProjectMarker)"
               color="var(--v-primary-base)">
      <MglPopup :close-button="false" :offset="36">
        <MapPopUp :marker="currentProjectMarker"/>
      </MglPopup>
    </MglMarker>
    <!-- these markers come from the project search  -->
    <MglMarker v-for="m in markers" v-if="m.coordinates"
               :key="m.projectProcessStepEventId + `${markerCount}`"
               :coordinates="m.coordinates"
               @click="selectAddressForDriveTime(m)"
               :color="m.color || defaultEmptyColor">
      <MglPopup :close-button="false" :offset="36">
        <MapPopUp :marker="m"/>
      </MglPopup>
    </MglMarker>
    <!-- these markers come from the calendar  -->
    <MglMarker v-for="m in mapResources" v-if="m.coordinates"
               :key="m.projectProcessStepEventId + `${markerCount}`"
               :coordinates="m.coordinates"
               @click="selectAddressForDriveTime(m)"
               :color="m.color || defaultEmptyColor">
      <MglPopup :close-button="false" :offset="36">
        <MapPopUp :marker="m"/>
      </MglPopup>
    </MglMarker>
    <MglNavigationControl :showCompass="false" position="top-right"/>
  </MglMap>
</template>

<script setup>
import 'mapbox-gl/dist/mapbox-gl.css'
import '@7oaksgroup/v-mapbox/dist/v-mapbox.css'
import {MglMap, MglMarker, MglNavigationControl, MglPopup} from '@7oaksgroup/v-mapbox'
import constants from '@/helpers/constants'
import {getRequestWithParams, postRequest} from "@/helpers/helpers";
import moment from 'moment'
import debounce from "lodash.debounce";
import {getCurrentInstance, ref, watch} from "vue";
import MapPopUp from "@/views/flow/schedule/components/MapPopUp.vue"

import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter, onBeforeRouteLeave} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  latitude: {type: Number},
  longitude: {type: Number},
  zoom: {type: Number},
  currentProjectMarker: Object,
  markers: {type: Array},
  mapResources: {type: Array},
  startTime:String,
  endTime: String,
})

watch( () => props.latitude, () => {
  // reset the selected group when the object type changes
  changeMapLocation()
})

const menuOpen = ref(false)
const loadingDriveTime = ref(false)
const markerCount = ref(0) //this is used to reset the key when the color of a marker changes so it gets redraw
const drivingMarkerColor = ref('#ab4711')
const defaultEmptyColor = ref('#EEEEEE')
const location = ref('')
const address1 = ref('')
const showAddress1List = ref(false)
const selectAddress1 = ref(false)
const address2 = ref('')
const selectAddress2 = ref(false)
const showAddress2List = ref(false)
const distanceDivisionMetric = ref(1609.34)
const durationDivisionMetric = ref(60)
const defaultZoom = ref(2.0)
const suggestions = ref([])
// they do these coordinates backwards to comply with geoJSON whatever that is.
//center of the USA
const defaultCenter = ref([-98.5795, 39.8283])
const center = ref(null)
const map = ref({
  accessToken: constants.MAPBOX_ACCESS_TOKEN,
  style: constants.MAPBOX_STYLE
})
const drivingDuration = ref(0)
const drivingDistance = ref(0)
const options = ref({
  itemsPerPage: 100
})
const asyncActions = ref()

const selectAddress = ((suggestion, isFirst) => {
  debugger
  if (isFirst) {
    address1.value = suggestion.label
    showAddress1List.value = false
    if(!!address2.value){
      loadDriveTime()
    }
  } else {
    address2.value = suggestion.label
    showAddress2List.value = false
    if(!!address1.value){
      loadDriveTime()
    }
  }
})
const formatLabel = ((label, part) => {
  let index = label.toLowerCase().indexOf(address1.value.toLowerCase())
  if (index >= 0) {
    let text = ''
    switch (part) {
      case 'start':
        text = label.substring(0, index)
        break
      case 'middle':
        text = label.substring(index, index + address1.value.length)
        break
      case 'end':
        text = label.substring(index + address1.value.length)
        break
    }
    return text
  } else if (part === 'start') {
    return label
  } else {
    return ''
  }
})
const debounceSearchAddress = debounce(function (address, isFirst) {
  clearMarkerSelectionForOne(isFirst)
  searchAddress(address, isFirst)
}, 500)

const searchAddress = async(address, isFirst) => {
  if (isFirst) {
    if (address1.value.length >= 2) {
      await geoCode(address1.value)
      showAddress1List.value = true
    } else {
      showAddress1List.value = false
    }
  } else {
    if (address2.value.length >= 2) {
      await geoCode(address2.value)
      showAddress2List.value = true
    } else {
      showAddress2List.value = false
    }
  }
}
const geoCode = async(address) => {
  if (address1.value.length >= 2 || address2.value.length >= 2) {
    try {
      let params = {
        address
      }
      const {data} = await getRequestWithParams(`/mapbox/getSuggestions`, {params})
      if (data.features) {
        suggestions.value = data.features.map(address => {
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
      }
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Getting Address Suggestions')
      
    }
  }
}
const clearMarkerSelectionForOne = (isFirst)=> {
  if(isFirst) {
    props.markers.forEach(m => {
      if (m.oldColor !== undefined && m.selectedFirst) {
        m.color = m.oldColor
        m.selectedFirst = false
      }
    })
    props.mapResources.forEach(m => {
      if (m.oldColor !== undefined && m.selectedFirst) {
        m.color = m.oldColor
        m.selectedFirst = false
      }
    })
  } else {
    props.markers.forEach(m => {
      if(m.oldColor !== undefined && m.selectedSecond) {
        m.color = m.oldColor
        m.selectedSecond = false
      }
    })
    props.mapResources.forEach(m => {
      if (m.oldColor !== undefined && m.selectedSecond) {
        m.color = m.oldColor
        m.selectedSecond = false
      }
    })
  }
  resetDriveTime()
}
const resetDriveTime = () => {
  drivingDistance.value = 0
  drivingDuration.value = 0
  markerCount.value++
  suggestions.value = []
}

const selectAddressForDriveTime = (marker) => {
  if (selectAddress1.value) {
    address1.value = marker.street1 + ', ' + marker.city + ', ' + marker.stateAbbreviation + ' ' + marker.postalCode
    selectAddress1.value = false
    //dont move out of if statement, because we dont want the colors to change unless they are selecting an address for drive time
    marker.oldColor = marker.color || defaultEmptyColor.value
    marker.color = drivingMarkerColor.value
    //get a list of all addresses selectedFirst and unset them, then set this one to selectedFirst
    let firstMarkers = props.markers.filter(m => m.selectedFirst)
    let firstResourceMarkers = props.mapResources.filter(m => m.selectedFirst)
    firstMarkers?.forEach(m => {
      m.selectedFirst = false
      m.color = m.oldColor
    })
    firstResourceMarkers?.forEach(m => {
      m.selectedFirst = false
      m.color = m.oldColor
    })
    marker.selectedFirst = true
    markerCount.value++
    if(!!address2.value){
      loadDriveTime()
    }
  } else if (selectAddress2.value) {
    address2.value = marker.street1 + ', ' + marker.city + ', ' + marker.stateAbbreviation + ' ' + marker.postalCode
    selectAddress2.value = false
    marker.oldColor = marker.color || defaultEmptyColor.value
    marker.color = drivingMarkerColor.value
    //get a list of all addresses selectedSecond and unset them, then set this one to selectedSecond
    let secondMarkers = props.markers.filter(m => m.selectedSecond)
    let secondResourceMarkers = props.mapResources.filter(m => m.selectedSecond)
    secondMarkers?.forEach(m => {
      m.selectedSecond = false
      m.color = m.oldColor
    })
    secondResourceMarkers?.forEach(m => {
      m.selectedSecond = false
      m.color = m.oldColor
    })
    marker.selectedSecond = true
    markerCount.value++
    if(!!address1.value){
      loadDriveTime()
    }
  }
}
const getLatLong = async(address) => {
  try {
    let params = {
      address
    }
    return await getRequestWithParams(`/mapbox/getLatLong`, {params})
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Getting Address Lat & Long')
    
  }
}
const loadDriveTime = async() => {
  vueInstance.$gtag.event('brs_drive_time', {event_category: "engagement", event_label: "Drive Time"})
  loadingDriveTime.value = true
  const {data: first} = await getLatLong(address1.value)
  const {data: second} = await getLatLong(address2.value)

  //then need to load the drive time/route stuff
  await getDirections(first, second)
}
const getDirections = async(firstPair, secondPair) => {
  drivingDistance.value = 0
  drivingDuration.value = 0
  try {
    let params = {
      latLongPairs: firstPair + ';' + secondPair
    }

    const {data} = await getRequestWithParams(`/mapbox/getDriveTime`, {params})
    if (data.routes && data.routes[0]) {
      if (data.routes[0].distance) {
        drivingDistance.value = (data.routes[0].distance / distanceDivisionMetric.value).toFixed(2)
      }

      if (data.routes[0].duration) {
        drivingDuration.value = moment().startOf('day').seconds(data.routes[0].duration).format('H[h] mm [m] ss [s]')
      }
    }
    loadingDriveTime.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Getting Drive Time')
    
  }
}
const changeMapLocation = async() => {
  try {
    center.value = props.latitude && props.longitude ? [props.longitude, props.latitude] : defaultCenter.value
    let currentZoom = props.zoom ?? defaultZoom.value
    await asyncActions.value?.flyTo({
      center: center.value,
      zoom: currentZoom,
      speed: 2
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error jumping to address')
    
  }
}
const onMapLoad = async(event) => {
  // Here we're catching 'load' map event
  asyncActions.value = event.component.actions
  await changeMapLocation()
}
</script>

<style lang="scss">
.drive-time-menu {
  border-radius: 0 !important;
}

.white-background{
  background-color: white;
}

#drive-time-btn.rounded-tile-btn {
  border-radius: 4px;
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

#hide-map-btn {
  height: 56px;
  padding:0;
}

#map-btns {
  position: absolute;
  top: 16px;
  left: 0px;
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

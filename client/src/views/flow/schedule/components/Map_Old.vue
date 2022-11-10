<template>
  <MglMap :accessToken="map.accessToken"
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
          <div class="address-container">
            <v-text-field text label="Address 1"
                          hide-details
                          v-model="address1"></v-text-field>
            <v-btn color="primary" @click="[address1 = '', selectAddress1 = !selectAddress1, selectAddress2 = false]"
              :loading="selectAddress1">Select</v-btn>
          </div>
          <div class="address-container">
            <v-text-field text label="Address 2"
                          hide-details
                          v-model="address2"></v-text-field>
            <v-btn color="primary" @click="[address2 = '', selectAddress2 = !selectAddress2, selectAddress1 = false]"
                   :loading="selectAddress2">Select</v-btn>
          </div>
          <div class="mt-2">
            <v-btn text class="mr-3" @click="[address1 = '', address2 = '']">Clear</v-btn>
            <v-btn color="primary" :disabled="!address1 || !address2" @click="loadDriveTime">Go</v-btn>
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
          {{m.contactFirstName}} {{m.contactLastName}}<br/>
          {{m.processStepName}}
          <span v-if="null != m.street1 || null != m.city || null != m.postalCode">
            <br/>
            {{m.street1}}<br/>
            {{m.city}}, {{m.stateAbbreviation}} {{m.postalCode}}
          </span>
        </VCard>
      </MglPopup>
    </MglMarker>
    <!-- these markers come from the calendar  -->
    <MglMarker v-for="m in mapResources" v-if="m.coordinates"
               :key="m.id"
               :coordinates="m.coordinates"
               :color="m.color || '#ffffff'">
      <MglPopup  :close-button="false" :onclick="selectAddressForDriveTime"
                 :ondrag="selectAddressForDriveTime" :ondragend="selectAddressForDriveTime" :ondragstart="selectAddressForDriveTime">
        <VCard flat>
          {{m.projectName}}<br/>
          {{m.processStepName}}
          <span v-if="null != m.street1 || null != m.city || null != m.postalCode">
            <br/>
            {{m.street1}}<br/>
            {{m.city}}, {{m.stateAbbreviation}} {{m.postalCode}}
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

  export default {
    name: 'ScheduleMap',
    components: {
      MglMap,
      MglPopup,
      MglMarker,
      MglNavigationControl,
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
        address1: '',
        selectAddress1: false,
        address2: '',
        selectAddress2: false,
        defaultZoom: 2.0,
        // they do these coordinates backwards to comply with geoJSON whatever that is.
        //center of the USA
        defaultCenter: [-98.5795, 39.8283],
        map: {
          accessToken: constants.MAPBOX_ACCESS_TOKEN,
          style: constants.MAPBOX_STYLE
        }
      }
    },
    created() {
      this.mapbox = Mapbox
    },
    methods: {
      selectAddressForDriveTime(marker) {
        if(this.selectAddress1) {
          this.address1 = marker.street1 + ', ' + marker.city + ', ' + marker.stateAbbreviation + ' ' + marker.postalCode
          this.selectAddress1 = false
        } else if (this.selectAddress2) {
          this.address2 = marker.street1 + ', ' + marker.city + ', ' + marker.stateAbbreviation + ' ' + marker.postalCode
          this.selectAddress2 = false
        }
      },
      async loadDriveTime() {
        console.log('load drive time here')
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
        let center = this.latitude && this.longitude ? [this.longitude, this.latitude] : this.defaultCenter
        let zoom = this.zoom ?? this.defaultZoom
        await this.asyncActions.flyTo({
          center,
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

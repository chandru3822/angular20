<template>
  <MglMap :accessToken="map.accessToken"
          :mapStyle="map.style"
          @load="onMapLoad">
    <!-- these markers come from the lower data table  -->
    <MglMarker v-for="m in markers" v-if="m.coordinates" :coordinates="m.coordinates"
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
    <MglMarker v-for="m in mapResources" v-if="m.coordinates" :coordinates="m.coordinates"
               :color="m.color || '#ffffff'">
      <MglPopup  :close-button="false">
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
      async changeMapLocation(event) {
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

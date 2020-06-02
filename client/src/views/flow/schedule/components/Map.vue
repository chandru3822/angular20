<template>
  <MglMap :accessToken="map.accessToken"
          :mapStyle="map.style"
          @load="onMapLoad">
    <MglMarker v-for="m in markers" v-if="m.coordinates" :coordinates="m.coordinates"
               :color="m.color || '#ffffff'"></MglMarker>
    <MglMarker v-for="m in mapResources" v-if="m.coordinates" :coordinates="m.coordinates"
               :color="m.color || '#ffffff'"></MglMarker>
    <MglNavigationControl :showCompass="false" position="top-right"/>
  </MglMap>
</template>

<script>
  import Mapbox from 'mapbox-gl'
  import {MglMap, MglMarker, MglNavigationControl} from 'vue-mapbox'
  import constants from '@/helpers/constants'


  export default {
    name: 'ScheduleMap',
    components: {
      MglMap,
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
          const newParams = await this.asyncActions.flyTo({
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
        const newParams = await this.asyncActions.flyTo({
          center,
          zoom: zoom,
          speed: 2
        })
      },
    }

  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>


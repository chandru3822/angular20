<template>
  <MglMap :accessToken="map.accessToken"
          :mapStyle="map.style"
          @load="onMapLoad">
    <!-- these markers come from the lower data table  -->
    <MglMarker v-for="m in markers" v-if="m.coordinates" :coordinates="m.coordinates"
               :color="m.color || '#ffffff'">
      <MglPopup :close-button="false">
        <VCard flat>
          {{ m.contactFirstName }} {{ m.contactLastName }}<br/>
          {{ m.processStepName }}
        </VCard>
      </MglPopup>
    </MglMarker>
    <!-- these markers come from the calendar  -->
    <MglMarker v-for="m in mapResources" v-if="m.coordinates" :coordinates="m.coordinates"
               :color="m.color || '#ffffff'">
      <MglPopup :close-button="false">
        <VCard flat>
          {{ m.projectName }}<br/>
          {{ m.processStepName }}
        </VCard>
      </MglPopup>
    </MglMarker>
    <MglNavigationControl :showCompass="false" position="top-right"/>
  </MglMap>
</template>

<script setup>
import 'mapbox-gl/dist/mapbox-gl.css'
import '@7oaksgroup/v-mapbox/dist/v-mapbox.css'
import Mapbox from 'mapbox-gl'
import {MglMap, MglMarker, MglNavigationControl, MglPopup} from '@7oaksgroup/v-mapbox'
import constants from '@/helpers/constants'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

const props = defineProps({
  latitude: {type: Number},
  longitude: {type: Number},
  zoom: {type: Number},
  markers: {type: Array},
  mapResources: {type: Array},
})
const { latitude, longitude, zoom, markers, mapResources } = toRefs(props)
const asyncActions = ref({})

watch(latitude, async() => {
  await changeMapLocation()
})

const mapbox = ref(null)
const defaultZoom = ref(2.0)
const defaultCenter = ref([-98.5795, 39.8283])
const map = ref({accessToken: constants.MAPBOX_ACCESS_TOKEN,style: constants.MAPBOX_STYLE})

onMounted(() => {
    mapbox.value = Mapbox
})


    const changeMapLocation = async() => {
      // Here we catching 'load' map event
      await asyncActions.value.flyTo({
        center: [longitude.value, latitude.value],
        zoom: zoom.value,
        speed: 2
      });

    }
    const onMapLoad = async(event) => {
      // Here we catching 'load' map event
      asyncActions.value = event.component.actions
      let center = latitude.value && longitude.value ? [longitude.value, latitude.value] : defaultCenter.value
      let zoom = zoom.value ?? defaultZoom.value
      await asyncActions.value.flyTo({
        center,
        zoom: zoom,
        speed: 2
      });
    }
</script>

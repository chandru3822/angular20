<template>
  <v-container>
    <v-row id="closer-availability-container">
      <v-col cols="12" md="12" class="map-row pa-0" style="overflow: auto;">
        <!-- map-resources allows the calendar to send events back to the map -->
        <Calendar :map-resources="mapResources"
                  ref="calendar"
                  :callback="resourceMapCallback"
                  :date-callback="dateCallback"></Calendar>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import Calendar from './components/Calendar'
import { ref } from 'vue'

const startTime = ref(null)
const endTime = ref(null)
const mapResources = ref([])
const selectedRows = ref([])
const selectedResources = ref([])
const state = ref({})
const caState = ref(null)
const eventTypes = ref([])
const selectedEventTypes = ref([])
const eventTypesChanged = ref(false)
const searchProjectsLoading = ref(false)
const asyncActions = ref({})

    const resourceMapCallback = (newValue) => {
      mapResources.value = newValue
    }
    const dateCallback = (startTime, endTime) => {
      startTime.value = startTime
      endTime.value = endTime
    }
</script>

<style lang="scss" scoped>
#closer-availability-container {
  height: calc(100vh - 60px);
}
</style>


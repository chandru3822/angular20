<script setup>
/*
*@name MapPopUp
*@author jess
*@date 3/4/24
*
*@description
*
*/
import {getCurrentInstance} from "vue";

import { useRouter} from "vue-router/composables";

const router = useRouter()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  marker:Object,
})

const eventIsSameDay = (startDate, endDate) => {
  const start = new Date(startDate)
  const end = new Date(endDate)
  return start.getDate() === end.getDate() && start.getMonth() === end.getMonth() && start.getFullYear() === end.getFullYear()
}

const openProjectEvent = (project) => {
  //open event clicks in new window every time so they dont have to keep reloading the calendar
  let routerData = router.resolve({path: `/project/${project.projectId}/processStep/${project.projectProcessStepId}/event/${project.projectProcessStepEventId}`})
  window.open(routerData.href, '_blank')
}
</script>

<template>
    <v-card flat class="pa-1 pb-0" style="font-family: 'Lato, sans-serif'">
      <div class="label-large pb-2">{{ marker.projectName }}</div>
      <div class="label-large pb-2">{{ marker.processStepName }}</div>
      <span class="body-large pb-2" v-if="null != marker.street1 || null != marker.city || null != marker.postalCode">
            {{ marker.street1 }}<br/>
            {{ marker.city }}, {{ marker.stateAbbreviation }} {{ marker.postalCode }}
          </span>
      <div v-if="marker.start && eventIsSameDay(marker.start, marker.end)" class="body-large pb-2">{{marker.start | formatDate('timestamp','MMM DD YYYY, h:mm a')}} - {{marker.end | formatDate('timestamp','h:mm a')}}</div>
      <div v-else-if="marker.start" class="body-large pb-2">{{marker.start | formatDate('timestamp','MMM DD YYYY, h:mm a')}} - {{marker.end | formatDate('timestamp','MMM DD YYYY, h:mm a')}}</div>
      <div v-else class="grey--text body-large pb-2">Unscheduled</div>
      <div>
        <a-btn variant="outlined" color="primary" html-style="width:100%" class="body-medium" @click="openProjectEvent(marker)">Open Project</a-btn>
      </div>
    </v-card>
</template>

<style scoped lang="scss">

</style>

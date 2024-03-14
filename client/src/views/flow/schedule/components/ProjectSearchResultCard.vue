<script setup>
/*
*@name ProjectSearchResultCard
*@author jess
*@date 2/14/24
*
*@description
*
*/
import moment from 'moment'

const props = defineProps({
  projectId: Number,
  projectName:String,
  processStep: String,
  event: String,
  id: Number, //needs to be unique; for the schedule page we're using projectProcessStepEventId
  status: String,
  startDate: String,
  endDate:String,
  eventResource: String,
  pinned: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['pinToMap'])

const eventIsSameDay = () => {
  if(!props.startDate){
    return false
  }
  const start = new Date(props.startDate)
  const end = new Date(props.endDate)
  return start.getDate() === end.getDate() && start.getMonth() === end.getMonth() && start.getFullYear() === end.getFullYear()
}

const togglePinToMap = () => {
  emit('pinToMap', {
  addPin: !props.pinned, id: props.id
})
}

</script>

<template>
<v-card outlined max-height="100%" @click="emit('click')">
  <v-card-title class="d-flex pa-2 align-start">
    <span class="label-medium pr-1 break-word max-width-half">{{projectName}}</span>
    <v-chip v-if="status" small color="success lighten-4" class="grey--text text--darken-4 body-small">{{status}}</v-chip>
    <v-spacer/>
    <v-btn icon small color="primary" @click.stop="togglePinToMap">
    <v-icon v-if="pinned">mdi-map-marker</v-icon>
    <v-icon v-else>mdi-map-marker-off</v-icon>
    </v-btn>
  </v-card-title>
  <v-card-text class="grey--text text--darken-4">
    <div class="body-medium">{{event}} ({{processStep}})</div>
    <div v-if="eventIsSameDay()" class="body-medium">{{startDate | formatDate('timestamp','MMM DD YYYY, h:mm a')}} - {{endDate | formatDate('timestamp','h:mm a')}}</div>
    <div v-else-if="startDate" class="body-medium">{{startDate | formatDate('timestamp','MMM DD YYYY, h:mm a')}} - {{endDate | formatDate('timestamp','MMM DD YYYY, h:mm a')}}</div>
    <div v-if="eventResource && eventResource !== '  - '" class="body-medium">{{eventResource}}</div>
  </v-card-text>
</v-card>
</template>

<style scoped lang="scss">
.break-word {
  word-break: break-word;
}
.max-width-half{
  max-width: 50%;
}
</style>

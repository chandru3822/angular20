<template>
<v-row>
  <v-col cols="12" class="pt-0">
    <v-card flat v-for="e in events" class="active-event-button" @click="goToPath(`/project/${projectId}/processStep/${e.projectProcessStepId}/event/${e.id}`)">
      {{ e.eventName }}
      <span :class="getStatusClass(e.eventStatusTypeId)">{{e.eventStatusType}}</span>
    </v-card>
  </v-col>
</v-row>
</template>

<script>
import {getStatusClass} from '@/services/processStepStatusTypeService'

export default {
  name: 'UpcomingEventSnippet',
  props: {
    projectId: Number,
    events: Array
  },
  data () {
    return {
      getStatusClass
    }
  },
  methods: {
    goToPath(path) {
      this.$router.push(path)
    },
  }
}
</script>


<style scoped lang="scss">
.active-event-button {
  border: solid 1px #C4C4C4;
  padding: 10px;
  margin-bottom: 10px;
  font-size: 14px;
}
</style>

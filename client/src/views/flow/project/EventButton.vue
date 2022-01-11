<template>
  <v-card flat class="event-button" @click="goToPath(`/project/${projectId}/processStep/${event.projectProcessStepId}/event/${event.id}`)">
    {{ event.eventName }}
    <span :class="getStatusClass(event.eventStatusTypeId)">{{event.eventStatusType}}</span>
  </v-card>
</template>

<script>

import {handleHidingGlobalLoader, postRequest} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import {getStatusClass} from '@/services/eventStatusTypeService'

export default {
  name: 'EventButton',
  props: {
    projectId: Number,
    event: Object,
  },
  data() {
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

<style lang="scss">
.event-button {
  border: solid 1px #C4C4C4 !important;
  padding: 10px;
  margin-left: 10px;
  margin-right: 10px;
  margin-bottom: 10px;
}
</style>

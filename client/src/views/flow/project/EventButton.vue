<template>
  <v-card flat class="event-button" @click="goToPath(`/project/${projectId}/processStep/${event.projectProcessStepId}/event/${event.id}`)">
    <span class="font-size-14">{{ event.eventName }}</span>
    <span class="font-size-12 ml-2" :class="getStatusClass(event.eventStatusTypeId)">{{event.eventStatusType}}</span> <br>
    <span class="event-resource" v-if="event.resource">{{ event.resource }}</span>
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
  margin-bottom: 10px;
}
.event-resource {
  font-size: 12px;
  color: #9E9C9C;
}
</style>

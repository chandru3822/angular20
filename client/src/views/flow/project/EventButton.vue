<template>
  <v-card flat :class="{'active-event': ppsEventId ? ppsEventId === event.id : false}"
          class="event-button albatross-body-1"
          @click="goToPath(`/project/${projectId}/processStep/${event.projectProcessStepId}/event/${event.id}`)"
  >
   {{ event.eventName }}
    <span class="ml-2" :class="getStatusClass(event.eventStatusTypeId)">{{event.eventStatusType}}</span> <br>
    <div class="event-resource" v-if="event.resource || event.startTime">
      <span v-if="event.resource">{{ event.resource }}</span>
      <div v-if="event.startTime">
        {{ event.startTime | formatDate('timestamp', 'M/D/YY h:mm a')}}
        <span v-if="event.endTime">
            - {{ event.endTime | formatDate('timestamp', 'M/D/YY h:mm a')}}
          </span>
      </div>
    </div>
    <div class="albatross-body-3"
         v-if="$store.getters.userHasFeatureAccessLevel('EVENTS', 'ADMIN')">
      {{ event.id }}
    </div>
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
  computed: {
    ppsEventId () {
      return parseInt(this.$route.params.ppsEventId)
    }
  },
  data() {
    return {
      getStatusClass,
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
//removes the blue-ish effect after you click one of these
.active-event:focus::before {
  opacity: 0;
}

.active-event {
  background-color: var(--v-active-base) !important;
}

.event-button {
  border: solid 1px #C4C4C4 !important;
  padding: 10px;
  margin-bottom: 10px;
}

.event-resource {
  font-size: 0.875rem;
  color: #9E9C9C;
}
</style>

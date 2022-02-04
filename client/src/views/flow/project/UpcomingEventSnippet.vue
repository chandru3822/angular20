<template>
<v-row>
  <v-col cols="12" class="pt-0">
    <v-card flat v-for="e in events"
            :class="{'active-event': ppsEventId === e.id}"
            class="active-event-button albatross-body-1" @click="goToPath(`/project/${projectId}/processStep/${e.projectProcessStepId}/event/${e.id}`)">
      {{ e.eventName }}
      <span :class="getStatusClass(e.eventStatusTypeId)">{{e.eventStatusType}}</span> <br/>
      <div class="event-resource" v-if="e.resource || e.startTime">
        <span v-if="e.resource">{{ e.resource }}</span>
        <div v-if="e.startTime">
          {{ e.startTime | formatDate('timestamp', 'M/D/YY h:mm a')}}
          <span v-if="e.endTime">
            - {{ e.endTime | formatDate('timestamp', 'M/D/YY h:mm a')}}
          </span>
        </div>
      </div>
      <div class="albatross-body-3"
           v-if="$store.getters.userHasFeatureAccessLevel('EVENTS', 'ADMIN')">
        {{ e.id }}
      </div>
    </v-card>
  </v-col>
</v-row>
</template>

<script>
import {getStatusClass} from '@/services/processStepStatusTypeService'
import moment from 'moment'

export default {
  name: 'UpcomingEventSnippet',
  props: {
    projectId: Number,
    events: Array
  },
  computed: {
    ppsEventId () {
      return parseInt(this.$route.params.ppsEventId)
    },
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
.active-event {
  background-color: #C4C4C4;
}

.active-event-button {
  border: solid 1px #C4C4C4;
  padding: 10px;
  margin-bottom: 10px;
}

.event-resource {
  font-size: 0.875rem;
  color: #9E9C9C;
}
</style>

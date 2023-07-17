<template>
  <v-card flat :class="{'active-event': ppsEventId ? ppsEventId === event.id : false}"
          class="event-button albatross-body-1"
          @click="goToPath(`/project/${projectId}/processStep/${event.projectProcessStepId}/event/${event.id}`)"
  >
   {{ event.eventName }}
    <span class="ml-2" :class="getStatusClass(event.eventStatusTypeId)">{{event.eventStatusType}}</span> <br>
    <div class="event-resource" v-if="event.resource || event.startTime || event.customFieldDisplayValue">
      <span v-if="event.resource">{{ event.resource }}</span>
      <div v-if="event.startTime">
        {{ event.startTime | formatDate('timestamp', 'M/D/YY h:mm a')}}
        <span v-if="event.endTime">
            - {{ event.endTime | formatDate('timestamp', 'M/D/YY h:mm a')}}
          </span>
      </div>
      <div v-if="event.customFieldDisplayValue">
      <div>
        <span v-if="event.customFieldDisplayValue.dateValue">{{event.customFieldDisplayValue.fieldName}}: {{ event.customFieldDisplayValue.dateValue | formatDate('date', 'M/D/YY') }}</span>
        <span v-if="event.customFieldDisplayValue.timestampValue">{{event.customFieldDisplayValue.fieldName}}: {{ event.customFieldDisplayValue.timestampValue | formatDate('timestamp', 'M/D/YY h:mm a') }}</span>
        <span v-if="event.customFieldDisplayValue.textValue" >{{event.customFieldDisplayValue.fieldName}}: {{ event.customFieldDisplayValue.textValue }}</span>
        <span v-if="event.customFieldDisplayValue.richTextValue" >{{event.customFieldDisplayValue.fieldName}}: {{ event.customFieldDisplayValue.richTextValue }}</span>
        <span v-if="event.customFieldDisplayValue.intValueAsText" >{{event.customFieldDisplayValue.fieldName}}: {{ event.customFieldDisplayValue.intValueAsText }}</span>
        <span v-else-if="event.customFieldDisplayValue.intValue" >{{event.customFieldDisplayValue.fieldName}}: {{ event.customFieldDisplayValue.intValue }}</span>  <!--else required here b/c if it has intValueAsText, it will also have intValue, but we the reverse is not true -->
        <span v-if="event.customFieldDisplayValue.intArrayValueAsText" >{{event.customFieldDisplayValue.fieldName}}: {{ event.customFieldDisplayValue.intArrayValueAsText }}</span>
        <span v-else-if="event.customFieldDisplayValue.intArrayValue" >{{event.customFieldDisplayValue.fieldName}}: {{ event.customFieldDisplayValue.intArrayValue }}</span><!--else required here b/c if it has intArrayValueAsText, it will also have intArrayValue, but we the reverse is not true -->
        <span v-else-if="event.customFieldDisplayValue.booleanValue" >{{event.customFieldDisplayValue.fieldName}}:
        <v-icon class="ml-1 mb-1" size="20">check</v-icon>
        </span>
        <span v-else-if="event.customFieldDisplayValue.booleanValue === false" >{{event.customFieldDisplayValue.fieldName}}: <!--else required here to ensure we don't show the x if the vooleanValue is undefined/null instead of false -->
        <v-icon class="ml-1 mb-1" size="20">close</v-icon>
        </span>
      </div>
      </div>
    </div>
    <div class="albatross-body-3 grey--text text--darken-2"
         v-if="$store.getters.userHasFeatureAccessLevel('EVENTS', 'ADMIN')">
      {{ event.id }}
    </div>
  </v-card>
</template>

<script>
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
  color: var(--v-grey-darken2);
}
</style>

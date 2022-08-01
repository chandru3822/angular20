<template>
<v-row>
  <v-col cols="12" class="pt-0">
    <div v-for="e in events"
    >
      <EventButton
          :event="e"
          :project-id="projectId"
      />
    </div>
  </v-col>
</v-row>
</template>

<script>
import {getStatusClass} from '@/services/processStepStatusTypeService'
import EventButton from "@/views/flow/project/EventButton";

export default {
  name: 'ActiveEventSnippet',
  props: {
    projectId: Number,
    events: Array
  },

  computed: {},
  data () {
    return {
      getStatusClass
    }
  },
  methods: {
    goToPath(path) {
      this.$router.push(path)
    },
  },
  components: {
    EventButton
  }
}
</script>


<style scoped lang="scss">

.active-event-button {
  border: solid 1px var(--v-grey-lighten1);
  padding: 10px;
  margin-bottom: 10px;
}

</style>

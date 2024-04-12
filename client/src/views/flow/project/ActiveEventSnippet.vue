<template>
  <v-row>
    <v-col cols="12" class="pa-0">
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

<script setup>
import {getStatusClass} from '@/services/processStepStatusTypeService'
import EventButton from "@/views/flow/project/EventButton";
import { toRefs } from 'vue'
import {useRoute, useRouter} from "vue-router/composables";

const router = useRouter()

const props = defineProps({
  projectId: Number,
  events: Array
})

const { projectId, events } = toRefs(props)

const goToPath = (path) => {
  router.push(path)
}

</script>


<style scoped lang="scss">

.active-event-button {
  border: solid 1px var(--v-grey-lighten1);
  padding: 10px;
  margin-bottom: 10px;
}

</style>

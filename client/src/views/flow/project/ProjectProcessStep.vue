<template>
<v-row>
  <v-col class="text-left">
    <router-link :to="`/project/${projectId}`">Back</router-link>
    <h3></h3>
  </v-col>

  <v-col cols="12" class="text-left">
    <h1>{{ processStep.name }}</h1>
  </v-col>

  <v-col cols="12" lg="6" xl="6" class="text-left">
    <h3>Actions</h3>

    <v-row>
      <v-col v-for="action in processStep.actions" :key="action.id">
        <ActionButton
          v-if="action.actionTypeId === 2"
          :actionId="action.id"
          :projectProcessStep="stepId"
          :label="action.actionName"
        />
      </v-col>
    </v-row>
  </v-col>
</v-row>
</template>

<script>

import {getRequest, logError} from '@/helpers/helpers'
import ActionButton from './ActionButton'

export default {
  name: 'ProjectProcessStep',
  components: {
    ActionButton
  },
  data () {
    return {
      projectId: this.$route.params.projectId,
      stepId: this.$route.params.processStepId,
      processStep: {},
      isProcessStepLoading: true
    }
  },
  created () {
    this.getProcessStep()
  },
  methods: {
    getProcessStep: async function() {
      try {
        const {data} = await getRequest(`/projectProcessStep/${this.stepId}`)
        this.processStep = data
      } catch (e) {
        logError(e)
      } finally {
        this.isProcessStepLoading = false
      }
    }
  }
}
</script>

<style lang="scss" scoped>

</style>

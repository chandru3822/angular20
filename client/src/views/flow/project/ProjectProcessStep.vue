<template>
<v-row>
  <v-col>
    <router-link :to="`/project/${projectId}`">Back</router-link>
    <h3></h3>
  </v-col>
</v-row>
</template>

<script>

import {getRequest, logError, VUE_APP_FLOW_API} from '@/helpers/helpers'

export default {
  name: 'ProjectProcessStep',
  data () {
    return {
      projectId: this.$route.params.projectId,
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
        const {data} = await getRequest(`${VUE_APP_FLOW_API}/projectProcessStep/${this.projectId}`)
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

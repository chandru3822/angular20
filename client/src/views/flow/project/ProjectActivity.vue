<template>
<v-row id="project-activity-container" class="mt-2">
  <v-col cols="12" lg="12" class="pt-0">
      <v-row>
        <div v-if="selectedOption === 1">
          <Messaging :primaryId="projectId"/>
        </div>
        <div v-else-if="selectedOption === 2">
          <ProjectNotes></ProjectNotes>
        </div>
        <div v-else>
          <Attachments :projectId="projectId"/>
        </div>
    </v-row>
    <v-row>
      <v-btn @click="selectedOption = 1">sms</v-btn>
      <v-btn @click="selectedOption = 2">notes</v-btn>
      <v-btn @click="selectedOption = 3">docs</v-btn>
    </v-row>
  </v-col>
</v-row>
</template>

<script>

import {handleHidingGlobalLoader, getRequest, postRequest, logError, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import SpinnerInline from '@/components/SpinnerInline'
import Attachments from '@/views/flow/components/Attachments'
import ProjectNotes from '@/views/flow/project/ProjectNotes'
import Messaging from '@/views/flow/components/Messaging'

export default {
  name: 'ProjectActivity',
  components: {
    SpinnerInline,
    Attachments,
    ProjectNotes,
    Messaging
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      selectedOption: 1
    }
  },
  created () {
  },
  props: {
  },
  computed: {
  },

  methods: {
  }
}
</script>

<style lang="scss" scoped>

</style>

<style lang="scss">

</style>

<template>
  <v-row id="project-activity-container" class="mt-2" grow>
    <v-col cols="12" lg="12" class="pt-0 project-activity-content">
      <div>Project Notes</div>
        <div v-if="selectedOption === 0">
          <Messaging :primaryId="projectId"/>
        </div>
        <div v-else-if="selectedOption === 1">
          <ProjectNotes></ProjectNotes>
        </div>
        <div v-else>
          <Attachments :projectId="projectId"/>
        </div>

      <v-bottom-navigation v-model="selectedOption"
                           grow :value="selectedOption"
                           color="primaryButton"
                           class="override-primary-font-color">
        <v-btn class="override-primary-font-color">
          <v-icon class="override-primary-font-color">question_answer</v-icon>
        </v-btn>
        <v-btn class="override-primary-font-color">
          <v-icon class="override-primary-font-color">article</v-icon>
        </v-btn>
        <v-btn class="override-primary-font-color">
          <v-icon class="override-primary-font-color">folder</v-icon>
        </v-btn>
      </v-bottom-navigation>
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
.project-activity-content {
  //display: flex;
  //flex-direction: column;
  //justify-content: space-between;
}

</style>

<style lang="scss">

</style>

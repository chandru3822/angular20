<template>
  <v-row id="project-activity-container" class="mt-2">
    <v-col cols="12" lg="12" class="py-0">
      <div v-if="selectedOption === 0" class="project-activity-content">
        <Messaging :primaryId="projectId"/>
      </div>
      <div v-else-if="selectedOption === 1" class="project-activity-content">
        <div>Project Notes</div>
        <ProjectNotes></ProjectNotes>
      </div>
      <div v-else class="project-activity-content">
        <Attachments :projectId="projectId"/>
      </div>
      <v-row
          grow :value="selectedOption"
          color="primaryButton"
          class="section-footer"
          cols="12"
          fixed>
        <v-col no-gutters cols="4">
          <v-btn  @click="selectedOption = 0" class="section-footer-button">
            <v-icon>question_answer</v-icon>
          </v-btn>
        </v-col>
        <v-col no-gutters cols="4">
          <v-btn  @click="selectedOption = 1" class="section-footer-button" cols="4">
            <v-icon>article</v-icon>
          </v-btn>
        </v-col>
        <v-col no-gutters cols="4">
          <v-btn  @click="selectedOption = 2" class="section-footer-button" cols="4">
            <v-icon>folder</v-icon>
          </v-btn>
        </v-col>
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

#project-activity-container{
  height: 100%;
}
.project-activity-content {
  overflow-y: scroll;
  width:100%;
}

.section-footer{
  height: fit-content;
  background-color: white;
  position: sticky;
  bottom: -12px;
}

.section-footer-button {
  width: 100%;
}

</style>

<style lang="scss">

</style>

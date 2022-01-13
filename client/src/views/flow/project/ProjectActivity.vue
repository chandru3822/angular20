<template>
  <v-row id="project-activity-container" class="mt-2">
    <v-col cols="12" lg="12" class="py-0">
      <div v-show="!isCollapsed">
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
      </div>
      <v-row v-show="isCollapsed" class="project-activity-collapsed"></v-row>
      <v-row
          :value="selectedOption"
          color="primaryButton"
          class="section-footer px-4"
          cols="12"
      >
        <v-col no-gutters :cols="isCollapsed ? 12 : 4" class="px-0">
          <v-btn text block elevation="0"  @click="selectView(0)" :dark = "selectedOption == 0" :class="{'section-selected': selectedOption==0}">
            <v-icon>mdi-forum-outline</v-icon>
          </v-btn>
        </v-col>
        <v-col no-gutters :cols="isCollapsed ? 12 : 4" class="px-0">
          <v-btn text block elevation="0" @click="selectView(1)" :dark="selectedOption==1" :class="{'section-selected': selectedOption==1}">
            <v-icon>mdi-text-long</v-icon>
          </v-btn>
        </v-col>
        <v-col no-gutters :cols="isCollapsed ? 12 : 4" class="px-0">
          <v-btn text block elevation="0"  @click="selectView(2)" :dark="selectedOption==2" :class="{'section-selected': selectedOption==2}">
            <v-icon>mdi-folder-outline</v-icon>
          </v-btn>
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</template>

<script>

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
  props: {
    isCollapsed: Boolean
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      selectedOption: 1
    }
  },
  created () {
  },
  computed: {
  },

  methods: {
    selectView: function(viewOption){
      this.selectedOption = viewOption;
      if(this.isCollapsed){
        this.$emit('openRight');
      }
    }
  }
}
</script>

<style lang="scss" scoped>

#project-activity-container{
  height: 100%;
}
.project-activity-content {
  height: 800px;
  overflow-y: scroll;
  width:100%;
}

.project-activity-collapsed {
  height: 600px;
  width:100%;
}

.section-footer{
  height: fit-content;
  background-color: white;
  position: sticky;
  bottom: 0;
}

.section-selected{
  background-color: var(--v-primaryCustom-base) !important;
}

.section-not-selected {
  background-color: white;
}

</style>

<style lang="scss">

</style>

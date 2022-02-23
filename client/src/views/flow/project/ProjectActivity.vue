<template>
  <v-row id="project-activity-container" no-gutters>
    <v-col cols="12" lg="12" class="py-0 pr-0">
<!--      <v-toolbar color="transparent" class="elevation-0" id="right-sidebar-title">-->
<!--        <v-toolbar-title v-show="!isCollapsed">{{ sidebarTitle }}</v-toolbar-title>-->
<!--        <v-spacer v-if="!$store.state.project.rightSideSplit"></v-spacer>-->
<!--        <v-toolbar-items>-->
<!--          <div>-->
<!--            <v-btn small text class="mt-1" @click="collapseSide()">-->
<!--              <v-icon>mdi-menu</v-icon>-->
<!--            </v-btn>-->
<!--          </div>-->
<!--        </v-toolbar-items>-->
<!--      </v-toolbar>-->
      <div class="albatross-header-3 mb-3 d-inline-block"
           :class="{'title-collapse': $store.state.project.rightSideSplit,
                    'title-no-collapse': !$store.state.project.rightSideSplit}">
        <div v-if="!$store.state.project.rightSideSplit" class="d-inline-block">{{sidebarTitle}}</div>
        <v-btn  class="d-inline-block" small text @click="collapseSide()">
          <v-icon>mdi-menu</v-icon>
        </v-btn>
      </div>
<!--      <div class="right-expander-button d-inline-block">-->
<!--      </div>-->
      <div class="project-activity-inner-container">
        <div v-show="!$store.state.project.rightSideSplit" :style="{'height': $store.state.project.rightSideSplit ? 'calc(100% - 250px)' : 'calc(100vh - 17rem)'}">
          <Messaging v-if="selectedOption === 0" :primaryId="projectId"/>
          <ProjectNotes v-else-if="selectedOption === 1"></ProjectNotes>
          <AttachmentsDropdown v-else :projectId="projectId" :project-process-step-id="projectProcessStepId"/>
        </div>
      </div>
      <div class="footer-container"
           :style="{'width': $store.state.project.rightSideSplit ? '72px' : 'calc(100% - 30px)',
                    'left': $store.state.project.rightSideSplit ? '0px' : '15px',}">
        <v-row
          :value="selectedOption"
          color="primaryButton"
          :style="{'flex-direction': $store.state.project.rightSideSplit ? 'column' : 'row',
                      'width': $store.state.project.rightSideSplit ? 'calc(100% - 45px)' : '100%'}"
          class="section-footer ma-0"
        >
          <v-col cols="4" class="px-0">
            <v-btn text block elevation="0" @click="selectView(0)" :dark="selectedOption === 0"
                   :class="{'section-selected': selectedOption===0}">
              <v-icon>mdi-forum-outline</v-icon>
            </v-btn>
          </v-col>
          <v-col cols="4" class="px-0">
            <v-btn text block elevation="0" @click="selectView(1)" :dark="selectedOption === 1"
                   :class="{'section-selected': selectedOption===1}">
              <v-icon>mdi-text-long</v-icon>
            </v-btn>
          </v-col>
          <v-col cols="4" class="px-0">
            <v-btn text block elevation="0" @click="selectView(2)" :dark="selectedOption === 2"
                   :class="{'section-selected': selectedOption===2}">
              <v-icon>mdi-folder-outline</v-icon>
            </v-btn>
          </v-col>
        </v-row>
      </div>
    </v-col>
  </v-row>
</template>

<script>

import SpinnerInline from '@/components/SpinnerInline'
import ProjectNotes from '@/views/flow/project/ProjectNotes'
import Messaging from '@/views/flow/components/Messaging'
import AttachmentsDropdown from "@/views/flow/components/AttachmentsDropdown";
import {ProjectMutations} from '@/stores/ProjectStore'

export default {
  name: 'ProjectActivity',
  components: {
    SpinnerInline,
    AttachmentsDropdown,
    ProjectNotes,
    Messaging
  },
  props: {},
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      projectProcessStepId: parseInt(this.$route.params.processStepId),
      projectProcessStepEventId: parseInt(this.$route.params.ppsEventId),
      selectedOption: null == this.$store.state.project.selectedTab ? 1 : this.$store.state.project.selectedTab,

    }
  },
  created() {
  },
  computed: {
    sidebarTitle() {
      switch (this.selectedOption) {
        case 0:
          return "Project Communication"
        case 1:
          return "Project Notes"
        case 2:
          return "Documents"
      }
    }
  },

  methods: {
    collapseSide() {
      this.$store.commit(ProjectMutations.RIGHT_SIDE_COLLAPSE)
    },
    selectView: function (viewOption) {
      this.$store.commit(ProjectMutations.SET_SELECTED_TAB, viewOption)
      this.selectedOption = viewOption;
      if (this.isCollapsed) {
        this.$emit('openRight');
      }
    }
  }
}
</script>

<style lang="scss" scoped>

#project-activity-container {
  height: 100%;
  position: relative;
}

.project-activity-inner-container {
  overflow: auto;
}

.project-activity-content {
  min-height: 800px;
  overflow-y: scroll;
  width: 100%;
}

.footer-container {
  width: calc(100% - 30px);
  height: fit-content;
  min-height: 65px;
  bottom: 5px;
  position: absolute;
}

.section-footer {
  display: flex;
  align-items: center;
  width: 100%;
  background-color: white;
}

.section-selected {
  background-color: var(--v-primaryCustom-base) !important;
}

.section-not-selected {
  background-color: white;
}

.right-expander-button {
  margin-right: 10px;
}

.title-collapse {
  padding-left: 0;
  margin-top: 15px;
}

.title-no-collapse {
  padding-left: 24px;
  padding-top: 4px;
  display: flex !important;
  justify-content: space-between;
  margin-right: 11px;
}
</style>

<style lang="scss">
#right-sidebar-title .v-toolbar__content {
  display: flex;
  align-items: flex-start;
}
</style>

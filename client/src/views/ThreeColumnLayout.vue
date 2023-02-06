<template>
  <v-container class="pa-0" id="three-column-container">
    <v-row>
      <slot name="header">
        <v-toolbar v-if="!headerHidden" flat class="three-column-header px-4">
          <v-toolbar-title class="albatross-header-1 d-flex align-center mr-6">
            <slot name="back-btn"></slot>
            {{ headerText }}
          </v-toolbar-title>
          <slot name="search"></slot>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <slot name="header-btn">
            </slot>
          </v-toolbar-items>
        </v-toolbar>
      </slot>
    </v-row>
    <v-row class="split-container" :class="{'full-height':headerHidden}">
      <v-col id="left-column" class=" project-section text-left px-0 left-column" :class="{ 'hidden': this.leftHidden,
                                                                                            'collapsed': this.$store.state.project.leftSideSplit,
                                                                                            'narrow': this.leftSmall,
                                                                                            'auto-overflow': this.autoOverflowLeft,
                                                                                            'white-bg': this.leftSideWhiteBg,
                                                                                            'hide-column-xs': $store.state.project.leftSideSplit}">
        <div :class="{'title-collapsed': $store.state.project.leftSideSplit,
                      'ml-4': !$store.state.project.leftSideSplit}">
          <v-btn small text color="primary" class="hamburger-menu" @click="collapseSide('left')">
            <v-icon>mdi-menu</v-icon>
          </v-btn>
        </div>
        <slot name="left-column"></slot>
      </v-col>
      <v-col class="project-section center-panel pt-0 px-0 auto-overflow" :class="{'white-bg': this.centerWhiteBg, 'hide-column-xs': !$store.state.project.leftSideSplit}">
        <slot name="main-column"></slot>
      </v-col>
      <v-col id="right-column" class="project-section right-column px-0 pb-0" :class="{'hidden': this.rightHidden,
                                                                                                  'halvsies': this.leftHidden,
                                                                                                  'collapsed': this.$store.state.project.rightSideSplit && showRightCollapseBtn,
                                                                                                  'white-bg': this.rightSideWhiteBg,
                                                                                                  'hide-column-xs': true  }">
        <slot name="right-column">
          <ProjectActivity v-if="!projectLoading && projectId !== 0" :show-sms-tab="true" :allow-sidebar-collapse="showRightCollapseBtn"
                           @closeRight="closeRight()"
                           @click="collapseSide('right')"
                           @openRight="$store.state.project.rightSideSplit = false">
            <template v-slot:collapse-button><slot name="collapse-button"></slot></template>
          </ProjectActivity>
        </slot>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import constants from '@/helpers/constants'
import {AppMutations} from "@/stores/AppStore";
import {getRequest, handleHidingGlobalLoader, logError} from "@/helpers/helpers";
import {ProjectMutations} from "@/stores/ProjectStore";
import ProjectActivity from '@/views/flow/project/ProjectActivity'

export default {
  name: "ThreeColumnLayout",
  components: {
    ProjectActivity,
  },
  props: {
    headerText: String,
    headerBtnText: String,
    headerHidden: Boolean,
    leftCollapsed: Boolean,
    leftSmall: Boolean,
    leftHidden: Boolean,
    rightCollapsed: Boolean,
    rightHidden: Boolean,
    rightSideWhiteBg: {
      type: Boolean,
      default: true
    },
    leftSideWhiteBg: {
      type: Boolean,
      default: true
    },
    autoOverflowLeft: Boolean,
    centerWhiteBg: Boolean,
    showRightCollapseBtn: {
      type: Boolean,
      default: true
    },
  },
  computed: {
    leftWidth() {
      if (!this.leftHidden) {
        return {
          'hidden': this.leftHidden,
          'collapsed': this.$store.state.project.leftSideSplit,
          'narrow': this.leftSmall
        }
      }
    },
    rightWidth() {
      if (!this.rightHidden) {
        return {
          'hidden': this.rightHidden,
          'collapsed': this.$store.state.project.rightSideSplit && this.showRightCollapseBtn,
        }
      }
    },
  },
  watch: {
    // whenever userImage changes, this function will run
    '$route.params.projectId': function () {
      this.projectId = parseInt(this.$route.params.projectId) | null
      this.getProject()
    }
  },
  data() {
    return {
      constants,
      projectLoading: false,
      projectId: parseInt(this.$route.params.projectId) | null,
      rightHiddenMobile: this.rightCollapsed
  }
  },
  created() {
    //have to reset this on creation in case there is already a state then they go to the project url directly
    this.$store.commit(ProjectMutations.RESET_PROJECT_STATE)
    this.getProject()
  },
  methods: {
    getProject: async function () {
      try {
        if (this.projectId == 0) {
          return;
        }
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await getRequest(`/project/${this.projectId}`)
        this.project = data
        window.document.title = `${this.project.projectName} - Project Details`
        this.projectLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.projectLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
      }
    },
    closeRight() {
      this.$emit('closeRight')
    },
    collapseSide(side) {
      if (side === 'left') {
        this.$store.commit(ProjectMutations.LEFT_SIDE_COLLAPSE)
      } else {
        this.$store.commit(ProjectMutations.RIGHT_SIDE_COLLAPSE)
      }
    },
  }
}
</script>

<style lang="scss" scoped>
#three-column-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow: hidden;
}

.three-column-header {
  height: 64px;
  background-color: var(--v-grey-lighten2) !important;
}

.split-container {
  height: calc(100% - 65px);
  max-width: 100%;
  width: 100%;
  margin-right: 0 !important;
  margin-left: 0 !important;

  &.full-height {
    height: 100%
  }
}

.project-section {
  max-height: 100%;
  padding-top: 24px;
}

.project-section.left-column,
.project-section.center-panel {
  border-right: solid #C4C4C4 1px;
}

.auto-overflow {
  overflow: auto;
}

.white-bg {
  background-color: #fff;
}

.title-collapsed {
  text-align: center;
}

@media (min-width: 960px) {
  .left-column {
    width: calc((2 / 12) * 100%); //col-2
    max-width: calc((2 / 12) * 100%); //col-2
  }

  #right-column{
    width: calc((5 / 12) * 100%); //col-5
    max-width: calc((5 / 12) * 100%); //col-5
  }
}

.left-column {

  &.hidden {
    display: none;
  }

  &.hidden {
    display: none;
  }

  &.collapsed {
    width: 72px;
    max-width: 72px;
    //width: calc((1 / 24) * 100%); // half a col
    //max-width: calc((1 / 24) * 100%); // half a col
  }

  &.narrow {
    width: calc((1 / 12) * 100%); //col-1
    max-width: calc((1 / 12) * 100%); //col-1
  }
}

#right-column {
  &.hidden {
    display: none;
  }

  &.halvsies {
    width: calc((6/12) * 100%); //col-6
    max-width: calc((6/12) * 100%); //col-6
  }

  &.collapsed {
    width: 72px;
    max-width: 72px;
    width: calc((1 / 24) * 100%); //half a col
    max-width: calc((1 / 24) * 100%); //half a col
  }
}
</style>

<template>
  <v-container class="pt-0" id="three-column-container">
    <v-row>
      <slot name="header">
      <v-toolbar v-if="!headerHidden" flat color="#E3E3E3" class="three-column-header px-4">
        <v-toolbar-title class="albatross-header-1 d-flex align-center mr-6">{{headerText}}</v-toolbar-title>
        <slot name="search"></slot>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <div>
            <v-btn v-if="constants.IS_MOBILE" class="mt-3 no-text-transform" @click="">
              <v-icon >mdi-cloud-download</v-icon>
            </v-btn>
            <v-btn v-else class="mt-3 no-text-transform" @click="">
              {{headerBtnText}}
            </v-btn>
          </div>
        </v-toolbar-items>
      </v-toolbar>
      </slot>
    </v-row>
    <v-row class="split-container" :class="{'full-height':headerHidden}">
      <v-col cols="6" md="1" :width="leftWidth" class=" project-section text-left py-0 px-0 left-column" :class="leftWidth">
        <slot name="left-column"></slot>
      </v-col>
      <v-col class="project-section center-panel pt-0 px-0">
        <slot name="main-column"></slot>
      </v-col>
      <v-col id="right-column" class="project-section right-column px-0 pb-0 white-bg" :class="rightWidth"
      >
        <slot  name="right-column">
          <ProjectActivity v-if="!projectLoading && projectId !== 0"
                           @closeRight="closeRight()"
                           @openRight="$store.state.project.rightSideSplit = false"></ProjectActivity>
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
    headerBtnText:String,
    headerHidden: Boolean,
    leftCollapsed: Boolean,
    leftSmall: Boolean,
    leftHidden: Boolean,
    rightCollapsed: Boolean,
    rightHidden: Boolean
  },
  computed:{
    leftWidth() {
      if(this.leftHidden){
        return {
          'hidden': this.leftHidden,
          'collapsed': this.leftCollapsed,
          'narrow': this.leftSmall
        }
      }
    },
    rightWidth() {
        return {
          'hidden': this.rightHidden,
          'collapsed': this.rightCollapsed
        }
    }
  },
  watch: {
    // whenever userImage changes, this function will run
    '$route.params.projectId': function () {
      this.projectId = parseInt(this.$route.params.projectId) | null
      this.getProject()
    }
    },
  data () {
    return {
      constants,
      projectLoading: false,
      projectId: parseInt(this.$route.params.projectId) | null,
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
    }
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
}

.split-container{
  height: calc(100% - 50px);
  max-width: 100%;
  width: 100%;
  margin-right: 0 !important;
  margin-left: 0 !important;

  &.full-height {
    height: 100%
  }
}

.expand-left {

}

.collapse-left {
  width: 72px;
  padding: 12px;
}

.collapse-right {
  width: 72px;
  padding: 12px;
}

.center-width-left-side-collapse {
  width: calc(50% - 36px);
  padding: 10px !important;
}

.right-width-left-side-collapse {
  width: calc(50% - 36px);
  padding: 24px 10px 10px 10px !important;
}

.center-width-right-side-collapse {
  width: calc(83.33% - 72px);
  padding: 10px !important;
}

.center-width-both-collapse {
  width: calc(100% - 144px);
  padding: 10px !important;
}

.project-section {
  max-height: 100%;
  padding-top: 24px;
}

.project-section.left-column,
.project-section.center-panel {
border-right: solid #C4C4C4 1px;
  overflow:auto;
}

.white-bg {
  background-color: #fff;
}
.left-column {
  width: calc((2/12)*1%);//col-2
  &.hidden {
    display: none;
  }
  &.collapsed {
    width: calc((1/24)*1%);// half a col
  }
  &.narrow {
    width:calc((1/12)*1%) //col-1
  }
}

#right-column {
  width: calc((5/12)*1%);//col-5
  &.hidden {
    display: none;
  }
  &.collapsed {
    width: calc((1/24)*1%);//half a col
  }
}
</style>

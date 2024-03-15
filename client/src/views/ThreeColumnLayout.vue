<template>
  <v-container class="pa-0" id="three-column-container">
    <v-row>
      <v-toolbar v-if="!props.headerHidden" flat :height="props.headerLarge ? '94px' : '64px'" class="three-column-header px-5">
        <slot name="header">
          <v-toolbar-title class="headline-medium d-flex align-center mr-6">
            <slot name="back-btn"></slot>
            {{ props.headerText }}
          </v-toolbar-title>
          <slot name="search"></slot>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <slot name="header-btn">
            </slot>
          </v-toolbar-items>
        </slot>
      </v-toolbar>
    </v-row>
    <v-row class="split-container" :class="{'full-height': props.headerHidden, 'tall-header': props.headerLarge}">
      <v-col id="left-column" @click="emit('end-notes-timer')" class=" project-section text-left px-0 left-column"
             :class="{'hidden': props.leftHidden,
                      'collapsed': projectStore.leftSideSplit,
                      'narrow': props.leftSmall,
                      'mobile-overflow': true,
                      'auto-overflow': props.autoOverflowLeft,
                      'white-bg': props.leftSideWhiteBg,
                      'hide-column-xs': projectStore.leftSideSplit}">
        <div class="mobile-padding-menu-button" :class="{'title-collapsed': projectStore.leftSideSplit,
                      'ml-2': !projectStore.leftSideSplit}">
          <a-btn size="small" variant="text" prepend-icon="mdi-menu" @click="collapseSide('left')" />
        </div>
        <div v-if="!projectStore.leftSideSplit" class="left-panel-scrollable-area auto-overflow">
          <slot name="left-column"></slot>
        </div>
      </v-col>
      <v-col class="project-section center-panel py-0 px-0" @click="emit('end-notes-timer')"
             :class="{'white-bg': props.centerWhiteBg, 'hide-column-xs': !projectStore.leftSideSplit, 'halvsies': props.leftHidden}">
        <slot name="main-column"></slot>
      </v-col>
      <v-col id="right-column" class="project-section right-column pa-0" :class="{'hidden': props.rightHidden,
                                                                                                  'halvsies': props.leftHidden,
                                                                                                  'collapsed': projectStore.rightSideSplit && props.showRightCollapseBtn,
                                                                                                  'white-bg': props.rightSideWhiteBg,
                                                                                                  'hide-column-xs': true  }">
        <slot name="right-column">
          <ProjectActivity v-if="!projectLoading && (projectId !== 0 || userId !== 0)" :show-sms-tab="true"
                           :allow-sidebar-collapse="props.showRightCollapseBtn"
                           @closeRight="closeRight()"
                           @click="collapseSide('right')"
                           @openRight="projectStore.rightSideSplit = false">
            <template v-slot:collapse-button>
              <slot name="collapse-button"></slot>
            </template>
          </ProjectActivity>
        </slot>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import {getRequest, handleHidingGlobalLoader, logError} from '@/helpers/helpers'
import ProjectActivity from '@/views/flow/project/ProjectActivity'

import {computed, defineProps, getCurrentInstance, onMounted, ref} from 'vue'
import { useProjectStore } from '@/stores/ProjectStorePinia.js'
import {useRouter, useRoute} from 'vue-router/composables'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const projectStore = useProjectStore()
const appStore = useProjectStore()
const route = useRoute()
const router = useRouter()
const snackbar = vueInstance.$snackbar

const props = defineProps({
  headerText: String,
  headerBtnText: String,
  headerHidden: Boolean,
  headerLarge: Boolean,
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
  }
})

const projectLoading = ref(false)
const project = ref({})
const emit = defineEmits(['closeRight', 'end-notes-timer'])

const projectId = computed(() => {
  return parseInt(route.params.projectId) || 0
})
const userId = computed(() => {
  return parseInt(route.params.userId) || 0
})

// todo: note, i checked the code and these two values aren't being used...unless i am blind!
// const leftWidth = computed(() => {
//   if (!props.leftHidden) {
//     return {
//       'hidden': props.leftHidden,
//       'collapsed': projectStore.leftSideSplit,
//       'narrow': props.leftSmall
//     }
//   }
// })
//
// const rightWidth = computed(() => {
//   if (!props.rightHidden) {
//     return {
//       'hidden': props.rightHidden,
//       'collapsed': projectStore.rightSideSplit && props.showRightCollapseBtn,
//     }
//   }
// })

// todo: i am almost certain that this code is never getting hit, taking out for now
// watch(() => vueInstance.$route.params.projectId, () => {
//   // whenever userImage changes, this function will run
//   projectId.value = parseInt(vueInstance.$route.params.projectId) | null
//   console.log('this happened', projectId.value)
//   getProject()
// })
// watch(() => vueInstance.$route.params.userId, () => {
//   userId.value = parseInt(vueInstance.$route.params.userId) | null
// })

onMounted(() => {
  //have to reset this on creation in case there is already a state then they go to the project url directly
  projectStore.resetProjectState()
  getProject()
})
const getProject = async () => {
  try {
    if (projectId.value === 0) {
      return;
    }
    appStore.loading = true
    const {data, status} = await getRequest(`/project/${projectId.value}`)
    project.value = data
    window.document.title = `${project.value.projectName} - Project Details`
    projectLoading.value = false
    appStore.loading = false

    handleHidingGlobalLoader(status)
  } catch (e) {
    projectLoading.value = false
    appStore.loading = false
    logError(e)
  }
}
const closeRight = () => {
  emit('closeRight')
}
const collapseSide = (side) => {
  if (side === 'left') {
    projectStore.leftSideSplit = !projectStore.leftSideSplit
  } else {
    projectStore.rightSideSplit = !projectStore.rightSideSplit
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
  min-height: 64px;
  background-color: var(--v-grey-lighten2) !important;
}

.split-container {
  height: calc(100% - 65px);
  max-width: 100%;
  width: 100%;
  margin-right: 0 !important;
  margin-left: 0 !important;
  flex-wrap: nowrap;

  &.full-height {
    height: 100%
  }

  &.tall-header {
    height: calc(100% - 94px);
  }
}

.project-section {
  max-height: 100%;
}


.left-panel-scrollable-area {
  height: calc(100% - 30px);
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
    width: calc((3 / 12) * 100%); //col-3
    max-width: calc((3 / 12) * 100%); //col-3
  }

  #right-column {
    width: calc((4 / 12) * 100%); //col-4
    max-width: calc((4 / 12) * 100%); //col-4
  }
}

@media (min-width: 1200px) {
  .left-column {
    width: calc((2 / 12) * 100%); //col-2
    max-width: calc((2 / 12) * 100%); //col-2
  }

  #right-column {
    width: calc((5 / 12) * 100%); //col-5
    max-width: calc((5 / 12) * 100%); //col-5
  }
}

@media (max-width: 960px) {
  .mobile-overflow {
    overflow: auto;
  }

  .mobile-padding-menu-button {
    padding-top: 16px;

    padding-bottom: 16px;
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
    width: calc((6 / 12) * 100%); //col-6
    max-width: calc((6 / 12) * 100%); //col-6
  }

  &.collapsed {
    width: 72px;
    max-width: 72px;
    min-width: 72px;
  }
}

.center-panel.halvsies {
  width: calc((6 / 12) * 100%);
}
</style>

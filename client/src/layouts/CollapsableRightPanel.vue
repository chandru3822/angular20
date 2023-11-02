<script setup>
/*
*@name CollapsableRightPanel
*@author jess
*@date 10/10/23
*
*@description
* slots
*   title
*   header-actions
*   header-second-line
*   collapse-button-icon
* props
*   viewOptions-Array of objects with the following data:
*       icon
*   selectedOption-Number representing the index of the selected option in viewOptions,
*
*
*/

import {getCurrentInstance, computed, defineProps, defineEmits} from 'vue'
import {ProjectMutations} from "@/stores/ProjectStore";

//instantiate the store
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

//props and emits
const props = defineProps({
  viewOptions:[],
  selectedOption:Number,
  allowSidebarCollapse: {
    type: Boolean,
    default: true
  },
})
const emit = defineEmits(['selectView', 'collapseClicked'])

//the selected view
const selectView = (viewOption) => {
  emit('selectView', viewOption)
  if (isSidebarCollapsed.value) {
    collapseExpandSide()
  }
}

//collapsed or expanded
const isSidebarCollapsed = computed(() => {
  return store.state.project.rightSideSplit
})
const collapseButtonClicked = () => {
  if(props.allowSidebarCollapse) {
    collapseExpandSide() }
  else {
    emit('collapseClicked')
  }
}
const collapseExpandSide = () => {
  store.commit(ProjectMutations.RIGHT_SIDE_COLLAPSE)
}

const isMobile = computed(() => {
  return vueInstance.$vuetify.breakpoint.smAndDown
})



</script>

<template>

  <v-row id="conversation-activity-container" ref="conversationActivityContainer" class="pa-0 pt-4 d-flex flex-column" no-gutters>
    <div v-if="isSidebarCollapsed" class="pl-3 pt-2">
      <v-btn class="d-inline-block align-self-center" :class="{'title-collapsed':isSidebarCollapsed}" small text color="primary" @click="collapseExpandSide()">
        <slot name="collapse-btn-icon">
          <v-icon>mdi-menu</v-icon>
        </slot>
      </v-btn>
    </div>
    <div v-else class="conversation-activity-header-container d-flex flex-column one-hunned">
      <div class="pt-0 pl-6 d-flex align-center conversation-activity-header title-no-collapse headline-small">
          <slot name="title" v-if="!isSidebarCollapsed">Sidebar Title</slot>
        <v-spacer v-if="!isSidebarCollapsed"></v-spacer>
        <slot name="header-actions" v-if="!isSidebarCollapsed"/>
        <v-btn  v-if="!isMobile" class="d-inline-block align-self-center" :class="{'title-collapsed':isSidebarCollapsed}" small text color="primary" @click="collapseButtonClicked">
          <slot name="collapse-btn-icon">
            <v-icon>mdi-menu</v-icon>
          </slot>
        </v-btn>
      </div>
      <slot v-if="!isSidebarCollapsed" name="header-second-line"/>
      <!-- i show this line regardless of selected tab so that the mb-3 sticks around. otherwise need to add it to the element above for only options 0 & 1-->
      <div class="mb-3" v-if="!isSidebarCollapsed"></div>
      <v-divider v-if="selectedOption === 0 && !isSidebarCollapsed"></v-divider>
    </div>
    <div v-show="!isSidebarCollapsed" class="conversation-activity-inner-container one-hunned">
      <slot/>
    </div>
    <div fixed class="footer-container px-0" :class="{'footerAbsolute' : !isMobile}"
         :style="{'width': isSidebarCollapsed ? '72px' : '100%',
                      }">
      <v-row
          :value="selectedOption"
          :style="{'flex-direction': isSidebarCollapsed ? 'column' : 'row',
                        'width': isSidebarCollapsed ? 'calc(100% - 45px)' : '100%'}"
          class="section-footer ma-0" :class="{'px-4': !isSidebarCollapsed}"
      >
        <v-col v-for="(option, index) in viewOptions" :cols="12/viewOptions.length" class="px-0">
          <v-btn v-if="option.visible" text :color="selectedOption === index ? 'white' : 'primary'" block elevation="0" @click="selectView(index)" :dark="selectedOption === index"
                 :class="{'section-selected': selectedOption===index}" >
            <v-icon>{{option.icon}}</v-icon>
          </v-btn>
        </v-col>
      </v-row>
    </div>
  </v-row>
</template>



<style lang="scss" scoped>

@media (max-width: 960px) {
  .mobile-hamburger-menu {
    padding-left: 32px;
    padding-right: 24px;
  }

  .mobile-contact-header{
    padding-top: 14px;
    padding-right: 36px;
  }

  .mobile-content-padding{
    padding-top: 16px;
    padding-left: 16px;
  }
}

#conversation-activity-container {
  height: 100%;
  width: 100%;
  position: relative;
}

.conversation-activity-inner-container {
  max-height: calc(100% - 175px);
  margin-top:0;
  overflow: auto;

@media (min-width: 960px) {
  max-height: calc(100% - 112px);
  }
}

.conversation-activity-header {
  height: 41px;
}

.conversation-activity-content {
  min-height: 800px;
  overflow-y: scroll;
  width: 100%;
}

.footer-container {
  width: 100%;
  align-self: center;
  height: fit-content;
  min-height: 65px;
  background-color: transparent;
  bottom: 0px;
}

.footerAbsolute {
  position: absolute;
}

.footerFixed {
  position: fixed;
}

.section-footer {
  display: flex;
  align-items: center;
  position: absolute;
  bottom: 0px;
}

.section-selected {
  background-color: var(--v-primary-base) !important;
}

.section-not-selected {
  background-color: white;
}

.title-collapse {
  padding-left: 12px;
  margin-top:8px;
}

.title-no-collapse {
  padding-left: 24px;
  padding-top: 4px;
  display: flex !important;
  justify-content: space-between;
  margin-right: 11px;
}

.conversation-name-link {
  text-decoration: none;
}

.v-btn-toggle .v-btn {
  border: 1px solid var(--v-primary-base) !important;
  height: 30px !important;
  width: 168px !important;

  &:not(:last-child) {
    border-right: none !important;
  }
}

.toggle-btn {
  width: 50% !important;
}

//not sure why/when this broke but we were always showing a scrollbar this makes it show only when needed
.scrollable-area {
  height: calc(100% - 5px);
}
</style>

<style lang="scss">
#right-sidebar-title .v-toolbar__content {
  display: flex;
  align-items: flex-start;
}

#conversation-activity-container .fix-toggle-opacity:before {
  background-color: unset !important;
}

.internal-chip {
  background-color: #C8E6C9 !important;
  height: 22px;
}

.customer-chip {
  background-color: #FECDD2 !important;
  height: 22px;
}
</style>

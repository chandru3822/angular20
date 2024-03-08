<template>
  <SidePanelExpansionPanel v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
                           header="Active Events"
                           :section-expanded="sectionExpanded"
                           :is-loading="activeEventsLoading"
                           @click="toggleCollapseExpand">
    <template v-slot:tool-btn>
      <v-btn v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
             text small color="primary" @click.stop :to="`/project/${projectId}/events`" class="pa-2 mx-2" max-width="48px">
        <v-icon :size="20">mdi-format-list-bulleted</v-icon>
      </v-btn>
    </template>
    <template v-slot:expanded-content>
      <ActiveEventSnippet class="px-3"
                          @refresh-upcoming-events="getEvents()"
                          :events="events"
                          :projectId="projectId"/>
      <v-col
          v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
          cols="12"
          class="text-left pt-0 albatross-body-3"
      >
      </v-col>
    </template>
  </SidePanelExpansionPanel>
</template>

<script>

import {getRequest, logError} from '@/helpers/helpers'
import EventSnippet from '@/views/flow/project/EventSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import ActiveEventSnippet from '@/views/flow/project/ActiveEventSnippet'
import SidePanelExpansionPanel from '@/components/SidePanelExpansionPanel.vue'
import { mapStores } from 'pinia'
import { useUserStore } from '@/stores/UserStorePinia.js'
import { useProjectStore } from '@/stores/ProjectStorePinia.js'

export default {
  name: 'ActiveEvents',
  components: {
    SidePanelExpansionPanel,
    SpinnerInline,
    EventSnippet,
    ActiveEventSnippet
  },
  props: {
    project: Object,
    updateKey: Number
  },
  watch: {
    updateKey: function () {
      this.getEvents()
    },
  },
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      events: [],
      customFieldGroups: [],
      menuOpen: false,
      activeEventsLoading: false,
      snackbar: {},
      eventSearch: '',
      eventsExpanded: false,
    }
  },
  created() {
    this.getEvents()
  },
  computed: {
    ...mapStores(useUserStore, useProjectStore),
    sectionExpanded() {
      return this.projectStore.activeEventDropdown
    },
    userCanEdit() {
      return this.userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
    },
    companyId() {
      return this.userStore.details.companyId
    },
    eventsByName() {
      const names = [...new Set(this.events.map(e => e.eventName))]

      return names.map(eventName => {
        return {
          eventName,
          events: this.events.filter(step => step.eventName === eventName)
        }
      })
    }
  },
  methods: {
    filteredEvents() {
      return this.eventSearch === '' ? this.eventsByName : this.eventsByName.filter(psn => psn.eventName.toLowerCase().includes(this.eventSearch.toLowerCase()))
    },
    getEvents: async function () {
      try {
        this.activeEventsLoading = true
        const {data} = await getRequest(`/project/${this.projectId}/activeEvents`, null, [])
        this.events = data
      } catch (e) {
        logError(e)
      } finally {
        this.activeEventsLoading = false
      }
    },
    toggleCollapseExpand(){
      this.projectStore.activeEventDropdown = !this.projectStore.activeEventDropdown
    }

  }
}
</script>

<style lang="scss" scoped>
#project-details-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.project-header {
  border-bottom: solid 1px #EAEAF4
}

.project-title {
  font-size: 20px;
}

.project-subtitle {
  font-size: 15px;
}

.work-type-header {
  &:not(:first-child) {
    padding-top: 20px;
  }
}
</style>

<style lang="scss">
.process-step-toolbar .v-toolbar__content {
  padding-left: 10px !important;
}

.manage-btn {

  margin-left: 12px;

  & > .v-btn__content {
    color: white !important;
  }
}
</style>

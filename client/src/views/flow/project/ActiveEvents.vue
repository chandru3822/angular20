<template>
  <SidePanelExpansionPanel v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
                           header="Active Events"
                           :section-expanded="sectionExpanded"
                           :is-loading="activeEventsLoading"
                           @click="toggleCollapseExpand">
    <template v-slot:tool-btn>
      <v-btn v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
             text color="primary" x-small class="d-inline-block" :to="`/project/${projectId}/events`">
        <v-icon small>mdi-view-list</v-icon>
      </v-btn>
    </template>
    <template v-slot:expanded-content>
      <ActiveEventSnippet class="px-4"
                          @refresh-upcoming-events="getEvents()"
                          :events="events"
                          :projectId="projectId"/>
      <v-col
          v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
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
import SidePanelExpansionPanel from "@/components/SidePanelExpansionPanel.vue";
import {ProjectMutations} from "@/stores/ProjectStore";

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
      sectionExpanded: this.$store.state.project.activeEventDropdown,
      customFieldGroups: [],
      menuOpen: false,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      activeEventsLoading: false,
      snackbar: {},
      eventSearch: '',
      eventsExpanded: false,
      companyId: this.$store.state.user.details.companyId,
    }
  },
  created() {
    this.getEvents()
  },
  computed: {
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
      this.$store.commit(ProjectMutations.ACTIVE_EVENT_COLLAPSE)
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

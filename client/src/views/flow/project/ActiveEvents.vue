<template>
  <v-row id="project-details-container" class="mx-6">
    <v-col cols="12" lg="12" class="text-left py-0 px-0">
      <v-expansion-panels flat class="py-0" v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-expansion-panel>
          <v-expansion-panel-header color="transparent" flat class="px-0 project-section-header" height="auto">
            <div class="label-large">Active Events</div>
          </v-expansion-panel-header>

          <v-expansion-panel-content cols="12" class="py-0">
            <SpinnerInline v-if="activeEventsLoading" :size="20" color="primary"/>
            <ActiveEventSnippet v-else class="px-4"
              @refresh-upcoming-events="getEvents()"
              :events="events"
              :projectId="projectId"/>
            <v-col
                v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
                cols="12"
                class="text-left pt-0 albatross-body-3"
            >
              <router-link :to="`/project/${projectId}/events`">View All</router-link>
            </v-col>
          </v-expansion-panel-content>
        </v-expansion-panel>
      </v-expansion-panels>

      <v-fade-transition v-if="sectionExpanded && $store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">

      </v-fade-transition>
    </v-col>

  </v-row>
</template>

<script>

import {getRequest, logError} from '@/helpers/helpers'
import EventSnippet from '@/views/flow/project/EventSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import ActiveEventSnippet from '@/views/flow/project/ActiveEventSnippet'

export default {
  name: 'ActiveEvents',
  components: {
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
      sectionExpanded: this.$route.path.includes('processStep'),
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

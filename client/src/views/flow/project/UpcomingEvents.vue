<template>
  <v-row id="project-details-container" class="">
    <v-col cols="12" lg="12" class="text-left pt-0">
      <v-col class="py-0" v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-row>
          <v-toolbar color="transparent" flat class="project-section-header">
            <v-toolbar-title class="font-size-14">Upcoming Events</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
            </v-toolbar-items>
          </v-toolbar>

          <v-col cols="12" v-if="upcomingEventsLoading">
            <SpinnerInline :size="20" color="primaryCustom"/>
          </v-col>

          <v-col cols="12" v-else class="pa-0">
            <UpcomingEventSnippet
              @refresh-upcoming-events="getEvents()"
              :events="events"
              :projectId="projectId"/>
          </v-col>
        </v-row>
      </v-col>

      <v-fade-transition v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-col
          cols="12"
          class="text-left pt-0 font-size-10"
        >
          <router-link :to="`/project/${projectId}/events`">View All</router-link>
        </v-col>
      </v-fade-transition>
    </v-col>

  </v-row>
</template>

<script>

import {getRequest, putRequest, postRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import EventSnippet from '@/views/flow/project/EventSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import UpcomingEventSnippet from '@/views/flow/project/UpcomingEventSnippet'
import moment from 'moment'

export default {
  name: 'UpcomingEvents',
  components: {
    SpinnerInline,
    EventSnippet,
    UpcomingEventSnippet
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
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      upcomingEventsLoading: false,
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
        this.upcomingEventsLoading = true
        const {data} = await getRequest(`/project/${this.projectId}/upcomingEvents`)
        this.events = data
        console.log('randaLogger',this.events)
      } catch (e) {
        logError(e)
      } finally {
        this.upcomingEventsLoading = false
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

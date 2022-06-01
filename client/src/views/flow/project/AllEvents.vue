<template>
  <v-row no-gutters id="project-details-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="text-left pt-0">
      <v-col class="py-0" v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-row>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title class="albatross-header-3">Active Events</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
            </v-toolbar-items>
          </v-toolbar>

          <v-col cols="12" v-if="activeEventsLoading">
            <SpinnerInline :size="20" color="primary"/>
          </v-col>

          <v-col cols="12" v-else class="pt-0">
            <TableActiveEventSnippet
              :events="getActiveEvents(events)"
              :projectId="projectId"/>
          </v-col>
        </v-row>
      </v-col>

      <v-fade-transition v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-col
          v-show="!eventsExpanded"
          cols="12"
          class="text-right pt-0"
        >
        <span @click="eventsExpanded = true" class="clickable primary--text">
          Expand All Events <v-icon color="primary">mdi-menu-down</v-icon>
        </span>
        </v-col>
      </v-fade-transition>

      <v-expand-transition>
        <v-col v-show="eventsExpanded">
          <v-row>
            <v-col cols="12">
              <v-row class="justify-space-around align-center">
                <v-col class="text-left pb-0">
                  <h3>All Events</h3>
                </v-col>
                <v-col class="text-right pb-0">
              <span @click="eventsExpanded = false" class="clickable primary--text">
                Collapse All Events <v-icon color="primary">mdi-menu-up</v-icon>
              </span>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="12" class="pt-0">
                  <v-divider/>
                </v-col>
              </v-row>
            </v-col>

            <v-col cols="12" v-if="activeEventsLoading">
              <SpinnerInline :size="20" color="primary"/>
            </v-col>

            <v-col cols="12" class="pt-0" v-else>
              <v-text-field placeholder="Filter..."
                            hide-details
                            outlined
                            type="search"
                            class=""
                            v-model="eventSearch"></v-text-field>

              <template v-for="event in filteredEvents()">
                <h4 class="text-left work-type-header">{{event.eventName}}</h4>
                <EventSnippet
                  :key="event.eventName"
                  :events="event.events"
                  :projectId="projectId"/>
              </template>
            </v-col>

          </v-row>
        </v-col>
      </v-expand-transition>
    </v-col>

  </v-row>
</template>

<script>

import {getRequest, putRequest, postRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import EventSnippet from '@/views/flow/project/EventSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import TableActiveEventSnippet from '@/views/flow/project/TableActiveEventSnippet'
import moment from 'moment'

export default {
  name: 'AllEvents',
  components: {
    SpinnerInline,
    EventSnippet,
    TableActiveEventSnippet
  },
  props: {
    project: Object
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      events: [],
      customFieldGroups: [],
      menuOpen: false,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      activeEventsLoading: false,
      snackbar: {},
      eventSearch: '',
      eventsExpanded: true,
      companyId: this.$store.state.user.details.companyId,
    }
  },
  created () {
    this.getEvents()
  },
  computed: {
    eventsByName () {
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
    getActiveEvents(events) {
      return events.filter(event => {
        return event.eventStatusTypeId === 1
      })
    },
    filteredEvents () {
      return this.eventSearch === '' ? this.eventsByName : this.eventsByName.filter(psn => psn.eventName.toLowerCase().includes(this.eventSearch.toLowerCase()) )
    },
    getEvents: async function () {
      try {
        this.activeEventsLoading = true
        const {data} = await getRequest(`/project/${this.projectId}/events`)
        this.events = data
        window.document.title = `${this.project.projectName} - Events`
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

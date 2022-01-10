<template>
<v-row id="project-details-container" class="mt-2">
  <v-col cols="12" lg="12" class="text-left pt-0">

        <v-row>
          <v-col cols="12">
            <v-row class="justify-space-around align-center">
              <v-col class="text-left pb-0">
                <h3>All Events</h3>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="12" class="pt-0">
                <v-divider/>
              </v-col>
            </v-row>
          </v-col>

          <v-col cols="12" v-if="upcomingEventsLoading">
            <SpinnerInline :size="20" color="primaryCustom"/>
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
    project: Object
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      events: [],
      customFieldGroups: [],
      upcomingEventsLoading: false,
      eventSearch: '',
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
    getUpcomingEvents(events) {
      return events.filter(event => {
        return event.eventStatusTypeId === 1
      })
    },
    filteredEvents () {
      return this.eventSearch === '' ? this.eventsByName : this.eventsByName.filter(psn => psn.eventName.toLowerCase().includes(this.eventSearch.toLowerCase()) )
    },
    getEvents: async function () {
      try {
      this.upcomingEventsLoading = true
       const {data} = await getRequest(`/project/${this.projectId}/events`)
       this.events = data
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

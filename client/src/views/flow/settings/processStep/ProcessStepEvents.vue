<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="req-header-bar">
          <v-toolbar-title class="app-title">Events</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn @click="[addNewEvent = !addNewEvent, getAvailableEvents()]" text v-if="userCanAdd">
              <v-icon v-if="!addNewEvent">add</v-icon>
              {{ addNewEvent ? 'Cancel' : 'Add Event'}}
            </v-btn>
            <v-btn text @click="expandEvents = !expandEvents">
              <v-icon v-if="!expandEvents">mdi-chevron-down</v-icon>
              <v-icon v-else>mdi-chevron-up</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-row v-if="addNewEvent">
          <v-col cols="12">
            <v-select v-model="newEventId"
                      :items="availableEvents"
                      label="Select Event"
                      item-value="id"
                      item-text="eventName"
                      @input="addEventToProcessStep"
            ></v-select>
          </v-col>
        </v-row>
        <v-row v-if="expandEvents">
          <v-col cols="12" class="pt-0">
            <v-data-table
              :headers="headers"
              :items="filterEvents()"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              single-expand
              :expanded.sync="expanded"
              hide-default-footer
              class="elevation-1 fix-column-width-bug square-card"
            >
              <template #no-data>
                No events for this process step
              </template>

              <template #no-results>
                No events for this process step
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedEventIndex % 2}">
                  <v-autocomplete
                    v-model="selectedEvent.initialCompanyEventStatusTypeId"
                    :items="companyEventStatuses"
                    label="Initial Event Status"
                    item-text="eventStatusType"
                    item-value="id"
                  >
                    <template slot="item" slot-scope="data">
                      <!-- HTML that describes how select should render items when the select is open -->
                      {{ data.item.eventStatusType }} ({{ data.item.rootEventStatusType }})
                    </template>
                  </v-autocomplete>
                  <v-btn class="white--text"
                         color="primaryButton"
                         @click="saveEventDetails(item)"
                  >Save</v-btn>
                </td>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">{{item.eventName}}</td>
                  <td class="text-left">{{item.initialEventStatusType}}</td>
                  <td>
                    <div style="display: flex; justify-content: flex-end">
                      <v-btn small text @click="[expanded = [item], selectedEvent = item, getAssignedEventStatusTypes(), selectedEventIndex = index]"
                             v-if="!expanded.includes(item)">
                        <v-icon v-if="item.immutable">expand_more</v-icon>
                        <v-icon v-else>edit</v-icon>
                      </v-btn>
                      <v-btn small text @click="[expanded = [], selectedEventIndex = null, selectedEvent = {}]"
                             v-if="expanded.includes(item)">cancel
                      </v-btn>
                      <v-dialog
                        v-if="userCanEdit"
                        v-model="item.deleteConfirm"
                        width="500">
                        <template #activator="{ on }">
                          <v-btn small text v-on="on">
                            <v-icon>delete</v-icon>
                          </v-btn>
                        </template>
                        <v-card>
                          <v-card-title
                            class="headline grey lighten-2"
                            primary-title>
                            Confirm
                          </v-card-title>

                          <v-card-text class="pt-4">
                            Are you sure you want to delete this event?
                          </v-card-text>

                          <v-divider></v-divider>

                          <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn
                              @click="item.deleteConfirm = false">
                              No
                            </v-btn>
                            <v-btn
                              color="primaryCustom"
                              text
                              @click="deleteEventFromStep(item)">
                              Yes
                            </v-btn>
                          </v-card-actions>
                        </v-card>
                      </v-dialog>
                    </div>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  import Vue2Filters from 'vue2-filters'
  import {AppMutations} from '@/stores/AppStore'
  import {
    getRequest,
    deleteRequest,
    putRequest,
    postRequest,
    getRequestWithParams,
    getSnackbar
  } from '@/helpers/helpers'
  import {getAvailableForEvent} from "@/services/eventStatusTypeService";

  export default {
    name: 'ProcessStepEvents',
    mixins: [Vue2Filters.mixin],
    data() {
      return {
        snackbar: {},
        expandEvents: true,
        companyEventStatuses: [],
        selectedEvent: {},
        selectedEventIndex: null,
        expanded: [],
        processStepId: this.$route.params.id,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        headers: [
          {text: 'Event', value: 'eventName', show: true},
          {text: 'Initial Status', value: 'initialEventStatusType', show: true},
          {text: null, value: 'icons', show: true}
        ],
        addNewEvent: false,
        newEventId: null,
        events: [],
        availableEvents: []
      }
    },
    computed: {},
    async created() {
      await this.getEvents()
    },
    methods: {
      async getAssignedEventStatusTypes() {
          try {
            const {data} = await getRequest(`/event/${this.selectedEvent.eventId}/status`)
            this.companyEventStatuses = data
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Status Types')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.companyStatusesLoading = false
          }
      },
      async getEvents() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/event`)
          this.events = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAvailableEvents() {
        if(this.addNewEvent) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequest(`/processStep/${this.processStepId}/event/available`)
            this.availableEvents = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      filterEvents() {
        return this.events.filter(e => {
          return !e.archived
        })
      },
      async addEventToProcessStep() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/processStep/${this.processStepId}/event/${this.newEventId}`)
          this.events.push(data)
          this.newEventId = null
          this.addNewEvent = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Event')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteEventFromStep(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/event/${item.id}`)
          item.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Event Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Event')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveEventDetails(psEvent) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/processStep/${this.processStepId}/event/${psEvent.eventId}`, psEvent)
          this.snackbar = getSnackbar('SUCCESS', 'Event Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Event')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }

  }
</script>

<style scoped lang="scss">

</style>

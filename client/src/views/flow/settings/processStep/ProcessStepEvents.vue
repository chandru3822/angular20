<template>
  <v-container class="pt-0">
    <v-row v-if="!selectedEvent || !selectedEvent.id">
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
            <v-select v-model="newEvent"
                      :items="availableEvents"
                      label="Select Event"
                      item-value="id"
                      item-text="eventName"
                      return-object
            ></v-select>
            <v-select v-if="newEvent.id"
                      v-model="newEvent.initialCompanyEventStatusTypeId"
                      :items="newEvent.companyEventStatusTypes"
                      label="Select Initial Status"
                      item-value="id"
                      item-text="eventStatusType"
            ></v-select>
            <v-btn class="white--text"
                   color="primaryButton"
                   :disabled="!newEvent.id || !newEvent.initialCompanyEventStatusTypeId"
                   @click="addEventToProcessStep">
              Save
            </v-btn>
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
              hide-default-footer
              class="elevation-1 fix-column-width-bug square-card"
            >
              <template #no-data>
                No events for this process step
              </template>

              <template #no-results>
                No events for this process step
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">{{item.eventName}}</td>
                  <td class="text-left">{{item.initialEventStatusType}}</td>
                  <td>
                    <div style="display: flex; justify-content: flex-end">
                      <v-btn small text @click="[selectedEvent = item, getAssignedEventStatusTypes(), getCompanyProcessStepStatuses(), selectedEventIndex = index]">
                        <v-icon>edit</v-icon>
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
    <v-row v-else>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">{{ selectedEvent.eventName }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>

          </v-toolbar-items>
        </v-toolbar>
        <v-card class="pa-4">
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
                 @click="saveEventDetails(selectedEvent)"
          >Save</v-btn>
        </v-card>
      </v-col>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Event Actions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNewEventAction = !addNewEventAction]" v-if="userCanAdd">
              <v-icon v-if="!addNewEventAction">add</v-icon>
              {{ addNewEventAction ? 'Cancel' : 'Add Action' }}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNewEventAction">
          <v-text-field text
                        label="Action Name"
                        v-model="newEventAction.actionName">
          </v-text-field>
          <v-autocomplete
            v-model="newEventAction.companyEventStatusTypeId"
            :items="companyEventStatuses"
            label="Change Event Status To"
            item-text="eventStatusType"
            item-value="id"
          ></v-autocomplete>
          <v-autocomplete
            v-model="newEventAction.companyProcessStepStatusTypeId"
            :items="processStepStatuses"
            label="Change Process Step Status To"
            item-text="processStepStatusType"
            item-value="id"
          >
            <template slot="item" slot-scope="data">
              <!-- HTML that describes how select should render items when the select is open -->
              {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
            </template>
          </v-autocomplete>
          <v-btn class="white--text"
                 color="primaryButton"
                 @click="saveEventAction(newEventAction)"
          >Add Action</v-btn>
        </v-card>
        <v-data-table
          v-if="!addNewEventAction"
          :headers="actionHeaders"
          :items="filterEventActions()"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          single-expand
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            No actions for this event
          </template>

          <template #no-results>
            No actions for this event
          </template>

          <template #expanded-item="{ headers, item: action }">
            <td :colspan="headers.length" class="pa-4">
              <v-text-field text
                            label="Action Name"
                            v-model="action.actionName">
              </v-text-field>
              <v-autocomplete
                v-model="action.companyEventStatusTypeId"
                :items="companyEventStatuses"
                label="Change Event Status To"
                item-text="eventStatusType"
                item-value="id"
              ></v-autocomplete>
              <v-autocomplete
                v-model="action.companyProcessStepStatusTypeId"
                :items="processStepStatuses"
                label="Change Process Step Status To"
                item-text="processStepStatusType"
                item-value="id"
              >
                <template slot="item" slot-scope="data">
                  <!-- HTML that describes how select should render items when the select is open -->
                  {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
                </template>
              </v-autocomplete>
              <v-btn class="white--text"
                     color="primaryButton"
                     @click="saveEventAction(action)"
              >Save Action</v-btn>

              this UI is confusing<br/>
              Required Fields
              <v-toolbar flat>
                <v-toolbar-title class="app-title">Required Fields</v-toolbar-title>
                <v-spacer></v-spacer>
                <v-toolbar-items>
                  <v-btn text @click="[addRequiredField = !addRequiredField]">
                    <v-icon v-if="!addRequiredField">add</v-icon>
                    {{ addRequiredField ? 'Cancel' : 'Add Required Event Field' }}
                  </v-btn>
                </v-toolbar-items>
                <v-card v-if="addRequiredField">
                  <v-autocomplete
                    v-model="newRequiredField.customFieldGroupAssignmentId"
                    :items="customFieldGroupAssignments"
                    label="Event Fields"
                    return-object
                    item-text="fieldName"
                  ></v-autocomplete>
                  <v-btn class="white--text"
                         color="primaryButton"
                         @click="addRequiredField(newRequiredField)"
                  >Add Required Field</v-btn>
                </v-card>
              </v-toolbar>
            </td>
          </template>

          <template #item="{ item: action, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{action.actionName}}</td>
              <td class="text-left">{{action.eventStatusType || 'N/A'}}</td>
              <td class="text-left">{{action.processStepStatusType || 'N/A'}}</td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn text @click="[expanded = [action]]" v-if="!expanded.includes(action)">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn text @click="expanded = []" v-else>cancel
                  </v-btn>
                  <v-dialog
                    v-if="userCanEdit"
                    v-model="action.deleteConfirm"
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
                        Are you sure you want to delete this event action?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                          @click="action.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                          color="primaryCustom"
                          text
                          @click="deleteActionFromEvent(action)">
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
    getSnackbar, logError
  } from '@/helpers/helpers'
  import {getAssignedToProcessStep} from '@/services/processStepStatusTypeService'
  import {getAvailableForEvent} from "@/services/eventStatusTypeService";

  export default {
    name: 'ProcessStepEvents',
    mixins: [Vue2Filters.mixin],
    data() {
      return {
        snackbar: {},
        expandEvents: true,
        companyEventStatuses: [],
        processStepStatuses: [],
        newEventStatuses: [],
        selectedEvent: {},
        selectedEventIndex: null,
        expanded: [],
        addNewEventAction: false,
        newEventAction: {},
        addRequiredField: false,
        customFieldGroupAssignments: [],
        newRequiredField: {},
        actionHeaders: [
          {text: 'Action Name', value: 'actionName', show: true},
          {text: 'Change Event Status To', value: 'companyEventStatusType', show: true},
          {text: 'Change Process Step Status To', value: 'companyProcessStepStatusType', show: true},
          {text: null, value: 'icons', show: true}
        ],
        processStepId: this.$route.params.id,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        headers: [
          {text: 'Event', value: 'eventName', show: true},
          {text: 'Initial Status', value: 'initialEventStatusType', show: true},
          {text: null, value: 'icons', show: true}
        ],
        addNewEvent: false,
        newEvent: {},
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
      async getCompanyProcessStepStatuses() {
        try {
          const {data} = await getAssignedToProcessStep(this.processStepId)
          this.processStepStatuses = data
        } catch (e) {
          this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          logError(e)
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
      filterEventActions() {
        return this.selectedEvent?.processStepEventActions.filter(e => {
          return !e.archived
        })
      },
      async addEventToProcessStep() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            eventId: this.newEvent.id,
            initialCompanyEventStatusTypeId: this.newEvent.initialCompanyEventStatusTypeId
          }
          const {data} = await postRequest(`/processStep/${this.processStepId}/event`, params)
          this.events.push(data)
          this.newEvent = {}
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
          this.expanded = []
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Event')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteActionFromEvent(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${action.id}`)
          action.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Action Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveEventAction(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action`, action)
          if(!action.id) {
            this.addNewEventAction = false
            this.newEventAction = {}
            this.selectedEvent.processStepEventActions.push(data)
          } else {
            action.eventStatusType = data.eventStatusType
            action.processStepStatusType = data.processStepStatusType
          }
          this.snackbar = getSnackbar('SUCCESS', 'Action Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }

  }
</script>

<style scoped lang="scss">

</style>

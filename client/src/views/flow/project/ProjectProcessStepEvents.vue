<template>
  <v-main class="events-container">
    <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
      <v-toolbar-title>
        Event Details
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
      </v-toolbar-items>
    </v-toolbar>
    <v-card class="pa-4 square-card">
      <div v-if="!selectedEvent.id">
        <div v-for="pse in processStepEvents" class="mb-2" v-if="!eventsLoading">
          <v-btn color="primaryCustom" class="white--text pl-2" @click="addEvent(pse)">
            <v-icon color="white" class="mr-2">add</v-icon>
            {{ pse.eventName }}
          </v-btn>
        </div>
        <v-data-table
          :headers="headers"
          :items="projectProcessStepEvents"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          hide-default-footer
          disable-sort
          :loading="eventsLoading"
          class="elevation-0"
        >
          <template #no-data>
            No events
          </template>

          <template #no-results>
            No events
          </template>

          <template #item="{ item, index }">
            <tr class="clickable text-left" :class="{'shaded-row': projectProcessStepEvents.indexOf(item) % 2}"
                @click="[selectedEvent = item, getEventCfgs(item), getEventDetails(item)]">
              <td class="text-left">{{ item.eventName }}</td>
              <td class="text-left">{{ item.eventStatusType }}</td>
              <td class="text-left">{{ item.startTime | formatDate('timestamp') }}</td>
              <td class="text-left">{{ item.endTime | formatDate('timestamp') }}</td>
              <td class="text-left">{{ item.resource }}</td>
            </tr>
          </template>

        </v-data-table>
      </div>
      <div v-else>
        <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
          <v-toolbar-title>
            {{ selectedEvent.eventName }}

          </v-toolbar-title>
          <v-spacer></v-spacer>
          <div>
            <v-autocomplete
              v-model="eventDetails.companyEventStatusTypeId"
              :items="companyEventStatuses"
              label="Event Status"
              item-text="eventStatusType"
              item-value="id"
            ></v-autocomplete>
          </div>
          <v-spacer></v-spacer>
          <v-toolbar-items>

            <v-btn text class="pl-1 pr-2 mb-2" @click="closeEventWindow()">
              <v-icon>close</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <div class="error-text" v-if="eventActionMissingRequirements">
          The following fields are required to perform the selected action.
        </div>

        <v-card class="pa-4 square-card mb-2"
                v-if="eventDetails.uniqueBehaviorTypeId === 1 && (!project.postalCode || !project.companyStateId)">
          A state and postal code are required on the project to continue with scheduling. Please return to the
          project screen and update.
        </v-card>

        <v-form ref="eventFieldForm" v-else>
          <DatetimePickerInput
            v-model="eventDetails.startTime"
            :timezone="this.timezone"
            :readonly="uniqueAlreadyHasValue"
            :required="actionRequiresStart && !eventDetails.startTime && !eventSaveOverrideRequired"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="Start Time"
          />
          <DatetimePickerInput
            v-model="eventDetails.endTime"
            :timezone="this.timezone"
            :readonly="uniqueAlreadyHasValue"
            :required="actionRequiresEnd && !eventDetails.endTime && !eventSaveOverrideRequired"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="End Time"
          />
          <v-autocomplete
            v-model="eventDetails.resourceId"
            :items="eventDetails.availableResources"
            :disabled="uniqueAlreadyHasValue"
            :rules="getResourceRequirement()"
            label="Resource"
            item-text="name"
            item-value="id"
          ></v-autocomplete>

          <v-btn color="primaryCustom" v-if="eventDetails.uniqueBehaviorTypeId === 1"
                 class="white--text mb-4"
                 :disabled="uniqueAlreadyHasValue"
                 id="qa-round-robin-button"
                 @click="showRoundRobin = !showRoundRobin">Round Robin
          </v-btn>
          <div v-if="eventDetails.uniqueBehaviorTypeId === 1 && showRoundRobin" class="qa-show-round-robin">
            <v-toolbar flat color="transparent">
              <v-toolbar-title>Lead Allocation</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="py-0">
              <v-card-text class="pt-0" v-if="userIsScheduler && !schedulerCanEdit">
                You do not have access to schedule projects in this Postal Code
              </v-card-text>
              <div class="pb-3">
                <CustomValueInput
                  :readonly="!userCanEdit"
                  :min-date="minDate"
                  :callback="checkAvailabilityDate"
                  :field="availabilityDateField"
                />
                <div class="text-right" v-if="availabilityDateField.dateValue">
                  <v-btn color="primaryCustom" dark class="white--text"
                         :loading="searchLoading"
                         id="qa-round-robin-search"
                         @click="getAvailableTimeSlots">
                    Search
                  </v-btn>
                </div>
                <v-select v-if="timeSlots.length > 0 && availabilityDateField.dateValue"
                          v-model="selectedTimeSlot"
                          class="qa-round-robin-time-select"
                          :items="timeSlots"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          label="Select an Available Time Slot"
                          return-object
                >
                  <template slot="selection" slot-scope="data">
                    {{ data.item.scheduledStartTime | formatDate('timestamp') }}
                  </template>
                  <template slot="item" slot-scope="data">
                    {{ data.item.scheduledStartTime | formatDate('timestamp') }}
                  </template>
                </v-select>
                <div v-else-if="searchedTimeSlots && availabilityDateField.dateValue">No Times Available for the
                  Selected Date
                </div>
                <div class="text-right" v-if="selectedTimeSlot.scheduledStartTime && availabilityDateField.dateValue">
                  <v-btn color="primaryCustom" class="white--text"
                         @click="saveCloserAppointment" id="qa-round-robin-save">
                    Save Appointment
                  </v-btn>
                </div>
              </div>
            </v-card-text>

          </div>

          <v-col
            v-if="selectedEvent && selectedEvent.id"
            class="pt-0"
            v-for="(cfg, index) in selectedEvent.customFieldGroups"
            :key="cfg.id"
          >
            <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
              <v-toolbar-title>
                <!--              <v-btn small text v-if="cfg.eventId && $store.getters.userHasFeature('SCHEDULE')"-->
                <!--                     :to="`/schedule?projectProcessStepId=${projectProcessStepId}`">-->
                <!--                <v-icon>mdi-calendar</v-icon>-->
                <!--              </v-btn>-->
                {{ cfg.groupName }}
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
              </v-toolbar-items>
            </v-toolbar>
            <v-card flat class="pa-3">
              <CustomValueInput
                v-for="(field, idx) in cfg.customFieldValues"
                :key="idx"
                :required="field.required && !eventSaveOverrideRequired"
                :callback="populateDirtyCfvs"
                :readonly="getReadOnly(field)"
                :field="field"
              />
            </v-card>
          </v-col>
        </v-form>

        <v-btn class="white--text mr-2 mb-2 save-btn"
               @click="checkFieldsForUnique()"
               color="primaryButton"
        >Save Event
        </v-btn>
        <v-btn class="white--text save-btn mb-2 mr-2"
               color="primaryButton"
               :disabled="!action.canPerform"
               @click="[attemptedAction = action, validateActionRequirements(action)]"
               v-for="(action, i) in eventDetails.eventActions"
               :key="i">
          {{ action.actionName }}
        </v-btn>
        <v-row>
          <Attachments :project-process-step-event-id="selectedEvent.id" :event-id="selectedEvent.eventId"
                       :project-process-step-id="projectProcessStepId"/>
        </v-row>
      </div>
    </v-card>
  </v-main>
</template>

<script>

import {
  getRequest,
  logError,
  getSnackbar,
  getRequestWithParams,
  putRequest,
  postRequest,
  postRequestWithRequestParams
} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import {getCompanyEventStatusTypes} from '@/services/eventStatusTypeService'
import {getCustomFieldReadOnly} from "@/services/customFieldService";
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import Attachments from '@/views/flow/components/Attachments'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import constants from '@/helpers/constants'
import moment from 'moment-timezone'
import {DateTime} from 'luxon'

export default {
  name: 'ProjectProcessStepEvents',
  components: {
    CustomValueInput,
    Attachments,
    DatetimePickerInput
  },
  props: {
    projectProcessStepEvents: Array,
    eventsLoading: Boolean,
    project: Object
  },
  data() {
    return {
      snackbar: {},
      selectedEvent: {},
      attemptedAction: {},
      companyEventStatuses: [],
      eventActionMissingRequirements: false,
      eventDetails: {},
      dirtyCfvs: [],
      contactId: this.$route.query.contactId,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      timezone: this.$store.state.user.details.timezone.value,
      projectId: this.$route.params.projectId,
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADMIN'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT'),
      userIsScheduler: this.$store.state.user.details.userPositions?.some(p => p.scheduler),
      projectProcessStepId: parseInt(this.$route.params.processStepId),
      processStepId: this.$route.query.processStepId,
      processStepEvents: [],
      headers: [
        {text: 'Event', value: 'eventName', show: true},
        {text: 'Status', value: 'eventStatusType', show: true},
        {text: 'Start Time', value: 'startTime', show: true},
        {text: 'End Time', value: 'endTime', show: true},
        {text: 'Resource', value: 'resource', show: true},
      ],
      eventSaveOverrideRequired: false,
      actionRequiresStart: false,
      actionRequiresEnd: false,
      actionRequiresResource: false,
      roundRobinNumberOfDays: 7,
      timeSlots: [],
      selectedTimeSlot: {},
      closerApptOverride: false,
      minDate: moment().format('YYYY-MM-DDTHH:mm:ssZ'),
      closerApptSaved: false,
      searchedTimeSlots: false,
      showRoundRobin: false,
      searchLoading: false,
      uniqueAlreadyHasValue: false,
      availabilityDateField: {fieldName: 'Select a Date', dataTypeId: 1, dateValue: null},
    }
  },
  async created() {
    this.getCompanyEventStatusTypes()
    await this.getProcessStepEvents()
  },
  watch: {
    eventActionMissingRequirements: function () {
      this.$nextTick(() => {
        this.$refs.eventFieldForm.validate()
      })
    }
  },
  computed: {},
  methods: {
    closeEventWindow() {
      this.selectedEvent = {}
      this.eventDetails = {}
    },
    getResourceRequirement() {
      if (this.actionRequiresResource && !this.eventDetails.resourceId && !this.eventSaveOverrideRequired) {
        return this.requiredRules
      }
    },
    validateActionRequirements: async function (action) {
      this.eventActionMissingRequirements = false
      this.eventSaveOverrideRequired = false
      this.actionRequiresStart = action?.requireStartTime
      this.actionRequiresEnd = action?.requireEndTime
      this.actionRequiresResource = action?.requireResource

      let requiredFields = action?.customFields?.filter(cf => cf.required) || []
      if (requiredFields.length > 0) {
        let fieldValueMissing = false
        this.selectedEvent?.customFieldGroups?.forEach(cfg => {
          cfg?.customFieldValues?.forEach(cf => {
            let match = requiredFields.find(rf => rf.customFieldGroupAssignmentId === cf.customFieldGroupAssignmentId)
            if (match) {
              if ( // check each data type to see if it has a value
                (cf.dataTypeId === 1 && null == cf.dateValue) ||
                (cf.dataTypeId === 2 && null == cf.timestampValue) ||
                (cf.dataTypeId === 3 && null == cf.booleanValue) ||
                (cf.dataTypeId === 4 && null == cf.numericValue) ||
                (cf.dataTypeId === 5 && null == cf.textValue) ||
                (cf.dataTypeId === 6 && null == cf.intValue) ||
                (cf.dataTypeId === 7 && null == cf.intArrayValue) ||
                (cf.dataTypeId === 8 && null == cf.intValue) ||
                (cf.dataTypeId === 9 && null == cf.intValue)
              ) {
                cf.required = true
                fieldValueMissing = true
                this.eventActionMissingRequirements = true
              }
            } else {
              cf.required = false
            }
          })
        })
        //if there wasn't a match, or there was a match but no missing data, then run the event
        if (!fieldValueMissing) {
          this.eventActionMissingRequirements = false
          //update the cfv's
          await this.updateFieldGroups()
          //then do the event action which will save the event details as well
          await this.doEventAction(action)
        }
      } else {
        this.eventActionMissingRequirements = false
        await this.doEventAction(action)
      }
    },
    async getCompanyEventStatusTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getCompanyEventStatusTypes()
        this.companyEventStatuses = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    doEventAction: async function (action) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          startTime: this.eventDetails.startTime,
          endTime: this.eventDetails.endTime,
          resourceId: this.eventDetails.resourceId,
          companyEventStatusTypeId: this.eventDetails.companyEventStatusTypeId
        }

        const {data} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.selectedEvent.id}/action/${action.id}/perform`, params)
        //we dont need to update the data now that the page is reloading
        // this.eventDetails = data
        // this.selectedEvent = data
        //reload the page so we get the updated pps status stuff
        this.$router.go(this.$router.currentRoute)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Performing Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getRoundRobinNumDays: async function () {
      //need to load the round robin Number of days into future for this project
      const {data} = await getRequestWithParams(`/postalCode/zone/byPostalCode`, {
        params: {
          projectId: this.projectId,
          postalCode: this.project.postalCode
        }
      })
      this.roundRobinNumberOfDays = data.schedulableFutureDays || 7
    },
    addEvent: async function (pse) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event`, pse)
        //i have no idea why i am using 2 data objects for the same value but dont have time to figure it out atm
        this.selectedEvent = data
        this.eventDetails = data
        if (data.uniqueBehaviorTypeId === 1) {
          this.uniqueAlreadyHasValue = null != this.eventDetails.startTime || null != this.eventDetails.endTime || null != this.eventDetails.resourceId
          this.getRoundRobinNumDays()
        }
        this.projectProcessStepEvents.push(data)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getProcessStepEvents: async function () {
      //this gets the events assigned to the process step so we know which ADD buttons to show
      try {
        const {data} = await getRequest(`/processStep/${this.processStepId}/event`)
        this.processStepEvents = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getReadOnly: function (field) {
      // if process_step admin then they can edit any process step fields, otherwise idk???
      return (!this.userIsAdmin)
        || getCustomFieldReadOnly(this.$store, field)
        || !this.userCanEdit
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if (!match) {
        this.dirtyCfvs.push(field)
      }
    },
    getEventCfgs: async function (ppsEvent) {
      try {
        const {data} = await getRequest(`/customFieldValues/event/${ppsEvent.id}`)
        this.selectedEvent.customFieldGroups = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getEventDetails: async function (ppsEvent) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${ppsEvent.id}`)
        this.eventDetails = data
        if (data.uniqueBehaviorTypeId === 1) {
          this.uniqueAlreadyHasValue = null != this.eventDetails.startTime || null != this.eventDetails.endTime || null != this.eventDetails.resourceId
          this.getRoundRobinNumDays()
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveEventDetails() {
      this.eventSaveOverrideRequired = true
      this.eventActionMissingRequirements = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.eventDetails.id}`, this.eventDetails)
        this.eventDetails = data

        if(this.selectedEvent?.id != null) {
          //populate the event into the previous list so that it will be right if they click the X
          //get selected event index
          let index = this.projectProcessStepEvents.findIndex(ppse => ppse.id === this.eventDetails.id)
          console.log('randaLogger INDEX FACE: ', index)
          this.projectProcessStepEvents[index] = this.eventDetails
        }

        if (data.uniqueBehaviorTypeId === 1) {
          this.uniqueAlreadyHasValue = null != this.eventDetails.startTime || null != this.eventDetails.endTime || null != this.eventDetails.resourceId
          this.getRoundRobinNumDays()
        }
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Default Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateFieldGroups() {
      if (this.dirtyCfvs?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        // this.processStep.customFieldGroups = this.customFieldGroups
        try {
          // const {data} = await putRequest(`/projectProcessStep`, this.processStep)
          // save dirty custom field values
          this.$refs.eventFieldForm.resetValidation()
          const {data} = await postRequest(`/customFieldValues/event/${this.selectedEvent.id}`, this.dirtyCfvs)
          this.dirtyCfvs = []
          this.customFieldGroups = data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async getAvailableTimeSlots() {
      try {
        this.searchLoading = true
        this.selectedTimeSlot = {}
        this.searchedTimeSlots = false

        let params = {
          projectId: this.projectId,
          startTime: moment(this.availabilityDateField.dateValue).startOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
          endTime: moment(this.availabilityDateField.dateValue).endOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
          availableDate: this.availabilityDateField.dateValue
        }
        const {data} = await getRequestWithParams(`/availability/timeSlots`, {params})
        this.searchedTimeSlots = true
        this.timeSlots = data
        this.searchLoading = false
      } catch (e) {
        logError(e)
        this.searchLoading = false
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Time Slots')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async saveCloserAppointment() {
      try {
        let body = {
          projectId: this.projectId,
          projectProcessStepId: this.projectProcessStepId,
          // startTime: moment(this.availabilityDateField.dateValue).startOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
          // endTime: moment(this.availabilityDateField.dateValue).endOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
          appointmentTime: this.selectedTimeSlot.scheduledStartTime,
          users: this.selectedTimeSlot.users
        }
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/availability/setCloserAppointment`, body)
        if (data) {
          // this.customFieldGroups = data
          // this.setCfgValues()
          this.closerApptSaved = true
          this.showRoundRobin = false
          this.availabilityDateField.dateValue = null
          this.timeSlots = []
          this.selectedTimeSlot = {}
        }
        await this.getProcessStep()
      } catch (e) {
        logError(e)
        let msg = e?.data?.message ?? 'Unable to Set Closer Appointment'
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    checkAvailabilityDate() {
      if (this.availabilityDateField.dateValue !== null) {
        // Limit user to selecting availability dates < 8 days out
        const selectedDate = DateTime.fromISO(this.availabilityDateField.dateValue)
        const cappedDate = DateTime.local().set({
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0
        }).plus({days: this.roundRobinNumberOfDays})
        if (selectedDate > cappedDate) {
          this.availabilityDateField.dateValue = null
          this.snackbar = getSnackbar('ERROR', `You can only schedule appointments ${this.roundRobinNumberOfDays} days in advance`)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } else {
          this.populateDirtyCfvs(this.availabilityDateField)
        }
      }
    },
    async userCanScheduleLeadAllocation() {
      //we only have to check this if the user is a scheduler otherwise we just use the userCanEdit value
      if (this.userIsScheduler) {
        this.schedulerLoading = true
        try {
          const {data} = await getRequestWithParams(`/postalCode/zone/userCanSchedule`, {
            params: {
              postalCode: this.project.postalCode
            }
          })
          this.schedulerCanEdit = data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Checking Scheduler Round Robin')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.schedulerLoading = false
        }
      }
    },
    async checkFieldsForUnique() {
      let validSave = true
      let resource = null
      if (this.eventDetails.uniqueBehaviorTypeId === 1) {
        let startTime = this.eventDetails.startTime
        let endTime = this.eventDetails.endTime
        resource = this.eventDetails.resourceId
        if ((startTime && !endTime) || (!startTime && endTime) || (resource && (!startTime && !endTime))) {
          this.snackbar = getSnackbar('ERROR', 'Start time and end time are required')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
          validSave = false
        } else if (startTime && endTime && !moment(endTime).isAfter(startTime)) {
          this.snackbar = getSnackbar('ERROR', 'End time must be after start time')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
          validSave = false
        } else if (startTime && endTime && !resource) {
          //resource required if times are saving
          this.snackbar = getSnackbar('ERROR', 'Resource is required')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
          validSave = false
        }
      }
      if (validSave) {
        this.saveEventDetails()
        this.updateFieldGroups()
      }
    }
  }
}
</script>

<style lang="scss">

</style>
<style lang="scss" scoped>
.events-container {

}
</style>

<template>
  <v-main class="py-0 relative height-one-hunned overflow-y-auto" v-if="!eventDetailsLoading">
    <div>
      <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar" id="event-header">
        <v-toolbar-title>
          {{ selectedEvent.eventName }}

        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-dialog
            v-if="(selectedEvent.startTime === null && selectedEvent.allowAllUserDeletion) || $store.getters.userHasFeatureAccessLevel('EVENTS', 'ADMIN')"
            v-model="selectedEvent.deleteConfirm"
            width="500">
            <template v-slot:activator="{ on }">
              <v-btn text small class="clickable" v-on="on">
                <v-icon>delete</v-icon>
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                class="headline grey lighten-2"
                primary-title
              >
                Confirm
              </v-card-title>

              <v-card-text>
                Are you sure you want to delete this event: <strong>{{ selectedEvent.eventName }}</strong>?
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  @click="selectedEvent.deleteConfirm = false">
                  No
                </v-btn>
                <v-btn
                  color="primaryCustom"
                  text
                  @click="[selectedEvent.archived = true, deleteEvent(selectedEvent.id)]">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </v-toolbar-items>
      </v-toolbar>
      <div v-if="selectedEvent && selectedEvent.eventActions && selectedEvent.eventActions.length > 0">
        <div class="action-subheader">
          Actions
          <v-btn
            class="back-btn show-unperformable-actions-btn"
            text
            :ripple="false"
            @click="showUnperformableActions = !showUnperformableActions"
          >
            {{ showUnperformableActions ? 'Hide Disabled' : 'Show All' }}
          </v-btn>
        </div>
      </div>
      <div v-for="action in filteredActions" :key="action.id" class="d-inline-block ma-1">
        <v-btn class="action-button white--text"
               color="primaryCustom"
               :disabled="!action.canPerform"
               @click="[attemptedAction = action, validateActionRequirements(action)]">
          {{ action.actionName }}
        </v-btn>
      </div>
      <div class="error-text" v-if="eventActionMissingRequirements">
        {{ this.saveErrorMsg }}
      </div>
      <div v-if="ppsEventId && attachmentTypes && attachmentTypes.length > 0" class="my-2">
        <v-btn class="one-hunned" color="#E3E3E3" @click="showUploadModal = true">
          Upload Documents
        </v-btn>
        <v-dialog :width="uploadModalWidth" v-model="showUploadModal">
          <UploadDocumentModal @cancel="showUploadModal = false"
                               :width="uploadModalWidth"
                               :pps-event-id="ppsEventId"
                               :attachment-types="attachmentTypes"></UploadDocumentModal>
        </v-dialog>
      </div>
      <v-toolbar color="secondary" class="elevation-0 cfg-detail-header fixed-toolbar">
        <v-toolbar-title>
          Details/Custom Fields
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text v-if="windowWidth >= splitColumnMinWidth && !splitValueColumns"
                 @click="setSplitColumnValue()">
            <v-icon v-if="!$store.state.project.manualColumnSplit">mdi-format-columns</v-icon>
            <v-icon v-else>mdi-menu</v-icon>
          </v-btn>
          <div>
            <v-btn class="white--text mt-3"
                   @click="checkFieldsForUnique()"
                   :disabled="!userCanEdit"
                   color="primaryButton">
              Save Fields
            </v-btn>
          </div>
        </v-toolbar-items>
      </v-toolbar>
      <v-card class="pa-4 square-card mb-2"
              v-if="selectedEvent.uniqueBehaviorTypeId === 1 && (!project.postalCode || !project.companyStateId)">
        A state and postal code are required on the project to continue with scheduling. Please return to the
        project screen and update.
      </v-card>

      <v-form ref="eventFieldForm" v-else>
        <v-autocomplete
          v-model="selectedEvent.companyEventStatusTypeId"
          :items="companyEventStatuses"
          label="Event Status"
          :disabled="!userCanManage"
          item-text="eventStatusType"
          item-value="id"
        ></v-autocomplete>
        <DatetimePickerInput
          v-model="selectedEvent.startTime"
          :timezone="this.timezone"
          :disabled="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.startTimeWhiteListedPositions, selectedEvent.startTimeReadOnly)"
          :readonly="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.startTimeWhiteListedPositions, selectedEvent.startTimeReadOnly)"
          :required="!selectedEvent.startTime && !eventSaveOverrideRequired"
          :type="'timestamp'"
          :format="'MMMM DD, YYYY, h:mm A'"
          label="Start Time"
        />
        <DatetimePickerInput
          v-model="selectedEvent.endTime"
          :timezone="this.timezone"
          :disabled="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.endTimeWhiteListedPositions, selectedEvent.endTimeReadOnly)"
          :readonly="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.endTimeWhiteListedPositions, selectedEvent.endTimeReadOnly)"
          :required="actionRequiresEnd && !selectedEvent.endTime && !eventSaveOverrideRequired"
          :type="'timestamp'"
          :format="'MMMM DD, YYYY, h:mm A'"
          label="End Time"
        />
        <v-autocomplete
          v-if="selectedEvent && selectedEvent.availableResources"
          v-model="selectedEvent.resourceId"
          :items="selectedEvent.availableResources"
          :disabled="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.resourceWhiteListedPositions, selectedEvent.resourceReadOnly)"
          :readonly="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.resourceWhiteListedPositions, selectedEvent.resourceReadOnly)"
          :rules="getResourceRequirement()"
          label="Resource"
          item-text="name"
          item-value="id"
        ></v-autocomplete>

        <v-btn color="primaryCustom" v-if="selectedEvent.uniqueBehaviorTypeId === 1"
               class="white--text mb-4"
               :disabled="uniqueAlreadyHasValue"
               id="qa-round-robin-button"
               @click="showRoundRobin = !showRoundRobin">Round Robin
        </v-btn>
        <div v-if="selectedEvent.uniqueBehaviorTypeId === 1 && showRoundRobin" class="qa-show-round-robin">
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
                <v-btn color="primaryCustom" class="white--text"
                       :loading="remoteSearchLoading"
                       :disabled="inPersonSearchLoading"
                       v-if="showRemoteSearch || userIsAdmin"
                       id="qa-round-robin-search-remote"
                       @click="getAvailableTimeSlots(true)">
                  Search Remote Appt. Slots
                </v-btn>
                <v-btn color="primaryCustom" class="white--text ml-3"
                       :loading="inPersonSearchLoading"
                       v-if="schedulerCanEdit || userIsAdmin"
                       :disabled="remoteSearchLoading"
                       id="qa-round-robin-search"
                       @click="getAvailableTimeSlots(false)">
                  Search In-person Appt. Slots
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
          class="pt-0 px-0"
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
          <v-card class="px-4 square-card"  v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
            <v-row>
              <v-col :cols="columnSplit ? 6 : 12" class="pb-0 pt-2">
                <CustomValueInput
                  v-for="(field, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 1)"
                  :key="idx"
                  :required="field.required && !eventSaveOverrideRequired"
                  :callback="populateDirtyCfvs"
                  :readonly="getReadOnly(field)"
                  :field="field"
                  :use-field-ancillary-name="true"
                  :show-field-name="false"
                />
              </v-col>
              <v-col cols="6" v-if="columnSplit">
                <CustomValueInput
                  v-for="(field, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                  :key="idx"
                  :required="field.required && !eventSaveOverrideRequired"
                  :callback="populateDirtyCfvs"
                  :readonly="getReadOnly(field)"
                  :field="field"
                  :use-field-ancillary-name="true"
                  :show-field-name="false"
                />
              </v-col>
            </v-row>
          </v-card>
        </v-col>
      </v-form>


    </div>
  </v-main>
  <v-main v-else>
    <SpinnerInline centered :size="50" color="primaryCustom"/>
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
  postRequestWithRequestParams, deleteRequest
} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import {getAssignedToEvent} from '@/services/eventStatusTypeService'
import {getEventCustomFieldReadOnly, getEventDefaultFieldReadOnly} from "@/services/customFieldService";
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import Attachments from '@/views/flow/components/Attachments'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import constants from '@/helpers/constants'
import moment from 'moment-timezone'
import {DateTime} from 'luxon'
import SpinnerInline from '@/components/SpinnerInline'
import {ProjectMutations} from "@/stores/ProjectStore";
import UploadDocumentModal from '@/views/flow/components/UploadDocumentModal'

export default {
  name: 'ProjectProcessStepEvent',
  components: {
    CustomValueInput,
    Attachments,
    DatetimePickerInput,
    SpinnerInline,
    UploadDocumentModal
  },
  props: {
    project: Object,
    splitValueColumns: Boolean
  },
  data() {
    return {
      snackbar: {},
      selectedEvent: {},
      showUploadModal: false,
      uploadModalWidth: 400,
      attachmentTypes: [],
      attemptedAction: {},
      companyEventStatuses: [],
      saveErrorMsg: '',
      eventActionMissingRequirements: false,
      ppsEventId: parseInt(this.$route.params.ppsEventId),
      menuOpen: false,
      dirtyCfvs: [],
      requiredRules: constants.BASIC_REQUIRED_RULE,
      timezone: this.$store.state.user.details.timezone.value,
      projectId: this.$route.params.projectId,
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('EVENTS', 'ADMIN'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('EVENTS', 'EDIT'),
      userCanManage: this.$store.getters.userHasFeatureAccessLevel('EVENTS', 'MANAGE'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('EVENTS', 'ADD'),
      userIsScheduler: this.$store.state.user.details.userPositions?.some(p => p.scheduler),
      projectProcessStepId: parseInt(this.$route.params.processStepId),
      processStepId: this.$route.query.processStepId,
      eventSaveOverrideRequired: false,
      actionRequiresStart: false,
      actionRequiresEnd: false,
      actionRequiresResource: false,
      roundRobinNumberOfDays: 7,
      timeSlots: [],
      selectedTimeSlot: {},
      schedulerCanEdit: false,
      showRemoteSearch: false,
      inPersonSearchLoading: false,
      remoteSearchLoading: false,
      mostRecentSearchWasRemote: false,
      schedulerLoading: true,
      closerApptOverride: false,
      minDate: moment().format('YYYY-MM-DDTHH:mm:ssZ'),
      closerApptSaved: false,
      searchedTimeSlots: false,
      showRoundRobin: false,
      uniqueAlreadyHasValue: false,
      availabilityDateField: {id: -1, fieldName: 'Select a Date', dataTypeId: 1, dateValue: null},
      showUnperformableActions: false,
      eventDetailsLoading: false,
      windowWidth: window.innerWidth,
      splitColumnMinWidth: 1700
    }
  },
  async created() {
    await this.loadAllPageDetails()
  },
  mounted() {
    window.addEventListener('resize', () => {
      this.windowWidth = window.innerWidth
    })
  },
  watch: {
    eventActionMissingRequirements: function () {
      this.$nextTick(() => {
        this.$refs.eventFieldForm.validate()
      })
    },
    // whenever pps event id changes, this function will run
    '$route.params.ppsEventId': function () {
      // reset the selected item
      this.projectProcessStepId = parseInt(this.$route.params.processStepId)
      this.ppsEventId = parseInt(this.$route.params.ppsEventId)
      this.getEventDetails()
    },
  },
  computed: {
    columnSplit() {
      return this.splitValueColumns || (this.windowWidth >= this.splitColumnMinWidth && this.$store.state.project.manualColumnSplit)
    },
    filteredActions() {
      if (!this?.selectedEvent?.eventActions) {
        return []
      }

      if (this.showUnperformableActions) {
        return this.selectedEvent.eventActions
      } else {
        return this.selectedEvent.eventActions.filter(a => a.canPerform === true)
      }
    }
  },
  methods: {
    setSplitColumnValue() {
      //flip the flag
      this.$store.commit(ProjectMutations.FLIP_MANUAL_COLUMN_SPLIT)
    },
    getCustomFieldValuesToDisplay(values, columnNum) {
      if (this.columnSplit) {
        return values.filter(function (element, index, values) {
          return (index % 2 === (columnNum === 1 ? 0 : 1));
        });
      } else {
        return values
      }
    },
    async loadAllPageDetails() {
      this.eventDetailsLoading = true
      const requests = [this.getEventDetails(), this.getEventAttachmentTypes()]
      await Promise.all(requests)
      this.eventDetailsLoading = false
    },
    closeEventWindow() {
      this.selectedEvent = {}
    },
    getResourceRequirement() {
      if (this.actionRequiresResource && !this.selectedEvent.resourceId && !this.eventSaveOverrideRequired) {
        return this.requiredRules
      }
    },
    validateActionRequirements: async function (action) {
      this.eventActionMissingRequirements = false
      this.eventSaveOverrideRequired = false
      this.actionRequiresStart = true //action?.requireStartTime
      this.actionRequiresEnd = action?.requireEndTime
      this.actionRequiresResource = action?.requireResource
      //will only be used if there is an error shown here
      this.saveErrorMsg = 'Additional fields are required to perform the selected action.'

      let requiredFields = action?.requiredFields
      if ((this.actionRequiresStart && !this.selectedEvent.startTime) || (this.actionRequiresEnd && !this.selectedEvent.endTime) || (this.actionRequiresResource && !this.selectedEvent.resourceId)) {
        this.eventActionMissingRequirements = true
        document.getElementById('event-header').scrollIntoView()
      } else if (requiredFields.length > 0) {
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
                document.getElementById('event-header').scrollIntoView()
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
    async getStatusesAssignedToEvent() {
      try {
        const {data} = await getAssignedToEvent(this.selectedEvent.eventId)
        this.companyEventStatuses = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
    async userCanScheduleRemoteLeadAllocation() {
      //we only have to check this if the user is a scheduler otherwise we just use the userCanEdit value
      if (this.userIsScheduler) {
        this.schedulerLoading = true
        try {
          const {data} = await getRequest(`/postalCode/zone/userCanScheduleRemote`)
          this.showRemoteSearch = data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Checking Scheduler Round Robin')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.schedulerLoading = false
        }
      }
    },
    doEventAction: async function (action) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          startTime: this.selectedEvent.startTime,
          endTime: this.selectedEvent.endTime,
          resourceId: this.selectedEvent.resourceId,
          companyEventStatusTypeId: this.selectedEvent.companyEventStatusTypeId
        }

        const {data} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.selectedEvent.id}/action/${action.id}/perform`, params)
        this.selectedEvent = data
        this.snackbar = getSnackbar('SUCCESS', 'Action Performed')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
        //calls fn that tells the upcoming events to update
        this.$emit('refresh-upcoming-pps')
        this.$emit('refresh-upcoming-events')
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
    getReadOnly: function (field) {
      // if events admin then they can edit any event fields, otherwise idk???
      return getEventCustomFieldReadOnly(this.$store, field)
        || !this.userCanEdit
    },
    getDefaultFieldReadOnly: function (wlp, readOnlyFieldValue) {
      // if events admin then they can edit any event fields, otherwise idk???
      return getEventDefaultFieldReadOnly(this.$store, wlp, readOnlyFieldValue)
        || !this.userCanEdit
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if (!match && field?.id !== -1) {
        this.dirtyCfvs.push(field)
      }
    },
    // getEventCfgs: async function (ppsEvent) {
    //   try {
    //     const {data} = await getRequest(`/customFieldValues/event/${ppsEvent.id}`)
    //     this.selectedEvent.customFieldGroups = data
    //   } catch (e) {
    //     console.error('*** ERROR ***', e)
    //     this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
    //     this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    //     this.$store.commit(AppMutations.SET_LOADING, false)
    //   }
    // },
    getEventDetails: async function () {
      try {
        const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.ppsEventId}`)
        this.selectedEvent = data
        //this verifies whether the event had a start time when the page loaded, if not then we allow all users to delete
        this.selectedEvent.allowAllUserDeletion = data.startTime === null
        //have to reset the pps stuff too in case they just go directly to the url
        this.$store.commit(ProjectMutations.SET_PPS, {
          projectProcessStepId: this.selectedEvent.projectProcessStepId,
          processStepId: this.selectedEvent.processStepId,
          processStepName: this.selectedEvent.processStepName
        })
        this.$store.commit(ProjectMutations.SET_PPS_EVENT, this.selectedEvent)
        if (data.uniqueBehaviorTypeId === 1) {
          this.uniqueAlreadyHasValue = null != this.selectedEvent.startTime || null != this.selectedEvent.endTime || null != this.selectedEvent.resourceId
          this.getRoundRobinNumDays()
          this.userCanScheduleLeadAllocation()
          this.userCanScheduleRemoteLeadAllocation()
        }
        await this.getStatusesAssignedToEvent()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.eventDetailsLoading = false
      }
    },
    deleteEvent: async function (ppseId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${ppseId}`)
        //go to the process step
        this.$router.push(`/project/${this.projectId}/processStep/${this.projectProcessStepId}?processStepId=${this.selectedEvent.processStepId}&contactId=${this.project.contactId}`)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveEventDetails() {
      let isNewEvent = this.selectedEvent.isNew
      this.eventSaveOverrideRequired = true
      this.eventActionMissingRequirements = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.selectedEvent.id}`, this.selectedEvent)
        this.selectedEvent = data
        this.$emit('refresh-upcoming-events')
        if (data.uniqueBehaviorTypeId === 1) {
          this.uniqueAlreadyHasValue = null != this.selectedEvent.startTime || null != this.selectedEvent.endTime || null != this.selectedEvent.resourceId
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
    async getAvailableTimeSlots(remote) {
      this.mostRecentSearchWasRemote = remote
      try {
        this.remoteSearchLoading = remote
        this.inPersonSearchLoading = !remote
        this.selectedTimeSlot = {}
        this.searchedTimeSlots = false

        let params = {
          projectId: this.projectId,
          startTime: moment(this.availabilityDateField.dateValue).startOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
          endTime: moment(this.availabilityDateField.dateValue).endOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
          availableDate: this.availabilityDateField.dateValue,
          remote: remote
        }
        const {data} = await getRequestWithParams(`/availability/timeSlots`, {params})
        this.searchedTimeSlots = true
        this.timeSlots = data
        this.remoteSearchLoading = false
        this.inPersonSearchLoading = false
      } catch (e) {
        logError(e)
        this.remoteSearchLoading = false
        this.inPersonSearchLoading = false
        let errorMsg = e.data ? e.data.message : 'Error Retrieving Time Slots'
        this.snackbar = getSnackbar('ERROR', errorMsg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async saveCloserAppointment() {
      try {
        let body = {
          projectId: this.projectId,
          projectProcessStepId: this.projectProcessStepId,
          projectProcessStepEventId: this.selectedEvent.id, // i think?
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
          //set the start time, end time and resource on the event
          this.selectedEvent.startTime = data.appointmentStartTime
          this.selectedEvent.endTime = data.appointmentEndTime
          this.selectedEvent.resourceId = data.userPositionId
          this.selectedEvent.resource = data.userFullName
          this.uniqueAlreadyHasValue = true

        }
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
    async checkFieldsForUnique() {
      if (null != this.selectedEvent.startTime) {
        let validSave = true
        let resource = null
        if (this.selectedEvent.uniqueBehaviorTypeId === 1) {
          let startTime = this.selectedEvent.startTime
          let endTime = this.selectedEvent.endTime
          resource = this.selectedEvent.resourceId
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
      } else {
        //only startTime is required to save fields
        this.actionRequiresEnd = false
        this.actionRequiresResource = false
        this.eventActionMissingRequirements = true
        this.saveErrorMsg = 'Start Time is required to save the event fields'
        //dont do this for now. makes the page look weird after save
        // document.getElementById('event-header').scrollIntoView()
      }
    },
    filterProjectProcessStepEvents() {
      return this.projectProcessStepEvents ? this.projectProcessStepEvents.filter(ppse => {
        return !ppse.archived
      }) : []
    },
    getEventAttachmentTypes: async function () {
      //this gets the attachment types assigned to the process step so we know whether to show the upload button
      try {
        const {data} = await getRequest(`/attachmentType/eventTypesByPpsEventId/${this.ppsEventId}`, null, [])
        this.attachmentTypes = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style lang="scss">
.event-button .v-btn__content {
  //max-width: 100%;
  width: 100%;
  white-space: normal;
}

.cfg-name-toolbar .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-name-toolbar .v-toolbar__title {
  font-size: 14px;
}

.cfg-detail-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-detail-header .v-toolbar__title {
  font-size: 16px;
}
</style>
<style lang="scss" scoped>
.action-subheader {
  width: 186px;
  margin-top: 20px;
  font-weight: 600;
}

::v-deep {
  .v-btn.back-btn {

    text-transform: capitalize;
    text-decoration: underline;

    &:not(.v-btn--round) {
      padding: 0;
    }

    &:hover:before {
      opacity: 0 !important;
    }

    .v-btn__content {
      justify-content: start;
    }
  }

  .show-unperformable-actions-btn {
    margin-bottom: 2px;
    margin-left: 10px;
    font-size: 12px;
  }
}

</style>

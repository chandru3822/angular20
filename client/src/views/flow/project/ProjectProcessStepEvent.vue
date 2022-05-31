<template>
  <v-main v-if="!eventDetailsLoading && projectMismatch">
    <div class="error--text">
      No Matching Event Found
    </div>
  </v-main>
  <v-main ref="ppseFieldsContainer" class="pa-0 relative height-one-hunned overflow-y-auto" v-else-if="!eventDetailsLoading">
    <v-dialog width="500" v-model="unsavedFieldsModal">
      <v-card>
        <v-card-title
          class="text-h5 grey lighten-2"
          primary-title
        >
          Confirm
        </v-card-title>

        <v-card-text class="pt-4">
          You have unsaved fields. Are you sure you want to continue without saving?
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            @click="unsavedFieldsModal = false">
            No
          </v-btn>
          <v-btn
            color="primary"
            text
            @click="[navigationOverride = true, goToPath(toPath, query)]">
            Yes
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <div v-if="selectedEvent.id" class="pt-6">
      <v-toolbar color="transparent" height="auto"
                 class="elevation-0 cfg-name-toolbar px-6" id="event-header">
        <v-toolbar-title class="albatross-header-2">
          <div>{{ selectedEvent.eventName }}</div>
          <div :class="getStatusClass(selectedEvent.eventStatusTypeId)">({{ selectedEvent.eventStatusType }})</div>
          <div class="scheduled-time" v-if="selectedEvent.scheduledDate">
            Scheduled {{ selectedEvent.scheduledDate | formatDate('timestamp', 'M/D/YYYY [at] h:mm a') }}
            <br>
            Created by {{ selectedEvent.createdBy }}
          </div>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-dialog
            v-if="(selectedEvent.startTime === null && selectedEvent.allowAllUserDeletion) || $store.getters.userHasFeatureAccessLevel('EVENTS', 'ADMIN')"
            v-model="selectedEvent.deleteConfirm"
            width="500">
            <template v-slot:activator="{ on }">
              <v-btn text small class="clickable mt-1" v-on="on">
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
                  color="primary"
                  text
                  @click="[selectedEvent.archived = true, deleteEvent(selectedEvent.id)]">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </v-toolbar-items>
      </v-toolbar>
      <div class="pb-4 px-6">
        <div class="mt-2" v-if="selectedEvent && selectedEvent.eventBanners && selectedEvent.eventBanners.length > 0">
          <v-card class="square-card" :class="{'mt-2': idx !== 0}"
                  v-for="(b, idx) in filterBy(selectedEvent.eventBanners, true, 'canPerform')">
            <v-card-text class="flex-display pa-0"  :style="{'color': b.color}">
              <div class="banner-card-swatch" :style="{'background-color': b.bgColor}"></div>
              <div :style="{'background-color': b.bgColor + 20}" class="one-hunned">
                <pre class="app-pre-wrapper px-3 py-2">{{b.content}}</pre>
              </div>
            </v-card-text>
          </v-card>
        </div>
        <div v-if="selectedEvent && selectedEvent.eventActions && selectedEvent.eventActions.length > 0">
          <div class="action-subheader albatross-header-3">
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
          <v-btn class="action-button white--text text-capitalize"
                 color="primary"
                 v-if="!action.hideFromWeb"
                 :disabled="!action.canPerform"
                 @click="[attemptedAction = action, validateActionRequirements(action)]">
            <div>
              <div class="action-button-name">
                {{ action.actionName }}
              </div>
              <div class="action-button-subtitle">
                <span class="action-button-subtitle-date">{{
                    action.actionRunDate | formatDate('timestamp', 'M/D/YY h:mm a')
                  }}</span>
                {{ action.actionRunBy }}
              </div>
            </div>
            <v-icon :color="action.canPerform ? 'white' : null" v-if="action.alreadyTriggered" class="ml-1" size="20">
              check
            </v-icon>
          </v-btn>
        </div>
      </div>
      <div class="fixed-toolbar padding-left-1">
        <v-toolbar flat color="secondary" class="cfg-name-toolbar px-6">
          <v-toolbar-title class="albatross-header-3">
            Event Details
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text small @click="setSplitColumnValue()" class="px-0">
              <v-icon v-if="!$store.state.project.manualColumnSplit" class="px-0">mdi-format-columns</v-icon>
              <v-icon v-else class="px-0">mdi-format-align-justify</v-icon>
            </v-btn>
            <v-btn v-if="ppsEventId && attachmentTypes && attachmentTypes.length > 0" text small
                   @click="showUploadModal = true" class="px-0">
              <v-icon class="px-0">mdi-upload</v-icon>
            </v-btn>
            <v-dialog :width="uploadModalWidth" v-model="showUploadModal">
              <UploadDocumentModal @cancel="showUploadModal = false"
                                   :width="uploadModalWidth"
                                   :show-success-snackbar="true"
                                   :pps-event-id="ppsEventId"
                                   :attachment-types="attachmentTypes"></UploadDocumentModal>
            </v-dialog>
            <div>
              <v-btn class="white--text mt-3 ml-2"
                     @click="checkFieldsForUnique()"
                     :disabled="!userCanEdit || getReadOnly()"
                     color="primaryButton">
                Save Fields
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
      </div>
      <div class="error-text pb-4 px-6" v-if="eventActionMissingRequirements">
        {{ this.saveErrorMsg }}
      </div>
      <v-card class="pa-4 square-card mb-2"
              v-if="selectedEvent.uniqueBehaviorTypeId === 1 && (!project.postalCode || !project.companyStateId)">
        A state and postal code are required on the project to continue with scheduling. Please return to the
        project screen and update.
      </v-card>

      <v-form ref="eventFieldForm" class="px-6" v-else>
        <div class="albatross-header-4 d-flex align-baseline">Overview
          <v-btn small text v-if="$store.getters.userHasFeature('SCHEDULE')"
                 class="px-0 d-flex align-baseline" target="_blank"
                 :to="`/schedule?projectProcessStepEventId=${ppsEventId}`">
            <span class="albatross-header-5 pl-2 scheduler-button-text">Open Scheduler</span>
            <v-icon class="scheduler-button-icon">mdi-open-in-new</v-icon>
          </v-btn>
        </div>
        <v-card class="square-card px-4 pt-4 mt-4">
          <v-autocomplete
            v-model="selectedEvent.companyEventStatusTypeId"
            :items="companyEventStatuses"
            label="Event Status"
            :disabled="!userCanManage"
            item-text="eventStatusType"
            item-value="id"
            @input="[statusChanged = true, defaultValuesChanged = true]"
          ></v-autocomplete>
          <DatetimePickerInput
            v-model="selectedEvent.startTime"
            :timezone="this.timezone"
            :disabled="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.startTimeWhiteListedPositions, selectedEvent.startTimeReadOnly)"
            :readonly="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.startTimeWhiteListedPositions, selectedEvent.startTimeReadOnly)"
            :required="actionRequiresStart && !selectedEvent.startTime && !eventSaveOverrideRequired"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="Start Time"
            :change-callback="startTimeChanged"
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
            :change-callback="() => { this.defaultValuesChanged = true}"
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
            @input="defaultValuesChanged = true"
          ></v-autocomplete>

          <v-btn color="primary" v-if="selectedEvent.uniqueBehaviorTypeId === 1"
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
              <v-card-text class="pt-0" v-if="userIsScheduler && !schedulerCanEdit && !userIsAdmin">
                You do not have access to schedule projects in this Postal Code
              </v-card-text>
              <div class="pb-3" v-else>
                <CustomValueInput
                  :readonly="!userCanEdit"
                  :min-date="minDate"
                  :callback="checkAvailabilityDate"
                  :field="availabilityDateField"
                />
                <div class="text-right" v-if="availabilityDateField.dateValue">
                  <v-btn color="primary" class="white--text"
                         :loading="remoteSearchLoading"
                         :disabled="inPersonSearchLoading"
                         v-if="showRemoteSearch || userIsAdmin"
                         id="qa-round-robin-search-remote"
                         @click="getAvailableTimeSlots(true)">
                    Search Remote Appt. Slots
                  </v-btn>
                  <v-btn color="primary" class="white--text ml-3"
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
                  <v-btn color="primary" class="white--text"
                         @click="saveCloserAppointment" id="qa-round-robin-save">
                    Save Appointment
                  </v-btn>
                </div>
              </div>
            </v-card-text>

          </div>
        </v-card>
        <v-col
          v-if="selectedEvent && selectedEvent.id"
          class="pt-0 px-0"
          v-for="(cfg, index) in selectedEvent.customFieldGroups"
          :key="cfg.id"
        >
          <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
            <v-toolbar-title class="albatross-header-4">
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
          <v-card class="px-4 square-card" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
            <v-row>
              <v-col :cols="$store.state.project.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
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
              <v-col cols="6" v-if="$store.state.project.manualColumnSplit" class="pb-0 pt-2">
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
    <SpinnerInline centered :size="50" color="primary"/>
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
import {getStatusClass} from '@/services/eventStatusTypeService'
import Vue2Filters from 'vue2-filters'

export default {
  name: 'ProjectProcessStepEvent',
  components: {
    CustomValueInput,
    Attachments,
    DatetimePickerInput,
    SpinnerInline,
    UploadDocumentModal
  },
  mixins: [Vue2Filters.mixin],
  props: {
    project: Object,
    splitValueColumns: Boolean
  },
  data() {
    return {
      snackbar: {},
      selectedEvent: {},
      showUploadModal: false,
      projectMismatch: false,
      uploadModalWidth: 600,
      defaultValuesChanged: false,
      //this is used to determine if we should save the status or not. should only save if it changes
      statusChanged: false,
      unsavedFieldsModal: false,
      navigationOverride: false,
      toPath: null,
      query: {},
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
      projectId: parseInt(this.$route.params.projectId),
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
      eventDetailsLoading: true,
      // windowWidth: window.innerWidth,
      // splitColumnMinWidth: 1700,
      getStatusClass
    }
  },
  async created() {
    await this.loadAllPageDetails()
  },
  beforeRouteUpdate(to, from, next) {
    // called when the route that renders this component is about to be updated via router-view update
    if (this.navigationOverride || (this.dirtyCfvs.length === 0 && !this.defaultValuesChanged)) {
      //set overide to false before navigation or else the confirmation dialog doesn't work if the next screen is also a pps
      this.navigationOverride = false
      next()
    } else {
      this.toPath = to.path
      this.query = to.query
      this.unsavedFieldsModal = true
    }
  },
  beforeRouteLeave(to, from, next) {
    // called when the route that renders this component is about to be navigated away from.
    if (this.navigationOverride || (this.dirtyCfvs.length === 0 && !this.defaultValuesChanged)) {
      //set overide to false before navigation or else the confirmation dialog doesn't work if the next screen is also a pps
      this.navigationOverride = false
      next()
    } else {
      this.toPath = to.path
      this.query = to.query
      this.unsavedFieldsModal = true
    }
  },
  mounted() {
    // window.addEventListener('resize', () => {
    //   this.windowWidth = window.innerWidth
    // })
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
      this.loadAllPageDetails()
    },
  },
  computed: {
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
    doSomething() {
      console.log('this happened')
    },
    goToPath(path, query) {
      this.unsavedFieldsModal = false
      this.$router.push({path, query})
    },
    setSplitColumnValue() {
      //flip the flag
      this.$store.commit(ProjectMutations.FLIP_MANUAL_COLUMN_SPLIT)
    },
    getCustomFieldValuesToDisplay(values, columnNum) {
      if (this.$store.state.project.manualColumnSplit) {
        return values.filter(function (element, index, values) {
          return (index % 2 === (columnNum === 1 ? 0 : 1));
        });
      } else {
        return values
      }
    },
    async loadAllPageDetails() {
      this.eventDetailsLoading = true
      //if you add a new item to requests make sure it returns the request status
      const requests = [this.getEventDetails(), this.getEventAttachmentTypes()]
      try {
        await Promise.all(requests).then((statusVals) => {
          let success = true
          statusVals.forEach(status => {
            if (status !== 200) {
              success = false
            }
          })
          if (success) {
            //this was causing issues if you moved too quickly between events
            this.eventDetailsLoading = false
          }
        })
      } catch (e) {
        console.error('*** ERROR ***', e)

      }
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
      this.actionRequiresStart = action?.requireStartTime //this is no longer required to be true
      this.actionRequiresEnd = action?.requireEndTime
      this.actionRequiresResource = action?.requireResource
      //will only be used if there is an error shown here
      this.saveErrorMsg = 'Additional fields are required to perform the selected action.'

      let cfHasMissing = this.needsRequiredField(action.requiredFields)
      if ((this.actionRequiresStart && !this.selectedEvent.startTime) ||
        (this.actionRequiresEnd && !this.selectedEvent.endTime) ||
        (this.actionRequiresResource && !this.selectedEvent.resourceId) || cfHasMissing) {

        this.eventActionMissingRequirements = true

      } else {
        //if there wasn't a required field then run the event
        this.eventActionMissingRequirements = false
        await this.doEventAction(action)
      }
    },
    needsRequiredField(requiredFields) {
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
              ((cf.dataTypeId === 5 || cf.dataTypeId === 13) && null == cf.textValue) ||
              (cf.dataTypeId === 6 && null == cf.intValue) ||
              (cf.dataTypeId === 7 && (null == cf.intArrayValue || cf.intArrayValue.length === 0)) ||
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
      return fieldValueMissing
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
          id: this.selectedEvent.id,
          startTime: this.selectedEvent.startTime,
          endTime: this.selectedEvent.endTime,
          resourceId: this.selectedEvent.resourceId,
          saveVersion: this.selectedEvent.saveVersion,
          companyEventStatusTypeId: this.selectedEvent.companyEventStatusTypeId,
          customFieldValues: this.dirtyCfvs
        }

        const {data} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.selectedEvent.id}/action/${action.id}/perform`, params)

        this.snackbar = getSnackbar('SUCCESS', 'Action Completed')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

        //calls fn that tells the upcoming events to update
        //we dont know if an event action will trigger other changes so we have to refresh everything all the time
        this.$emit('refresh-project-status')
        this.$emit('refresh-upcoming-pps')
        this.$emit('refresh-upcoming-events')

        //set this because running an action also saves fields so it needs to be reset
        this.defaultValuesChanged = false
        if (data?.processStepStatusTypeId !== 1) {
          //set navigation override so we dont get the unsaved fields popup
          this.navigationOverride = true
          //if ps root status is not active then go back to project screen
          this.$router.push({name: 'projectDetails', params: {projectId: this.projectId}})
        } else if (data?.eventStatusTypeId !== 1) {
          //set navigation override so we dont get the unsaved fields popup
          this.navigationOverride = true
          //if ps root status is active but event root status is not then go back to ps
          let path = `/project/${this.projectId}/processStep/${this.projectProcessStepId}`
          this.$router.push(path)
        } else {
          //stay on the screen and refresh values
          this.selectedEvent = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)

      } catch (e) {
        console.error('*** ERROR ***', e)
        let saveMismatch = e.data?.message === 'Save Version Mismatch'
        let msg = saveMismatch ? `Cannot save changes, this event has been updated by another user. Click <a class="white--text underline" href="">here</a> to refresh.` : 'Error Performing Event'
        this.snackbar = getSnackbar('ERROR', msg, saveMismatch)
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
    startTimeChanged() {
      this.defaultValuesChanged = true
      //if it is the closer event then auto populate the end time with (start time + 1 hour)
      if (this.selectedEvent?.uniqueBehaviorTypeId === 1 && this.selectedEvent?.startTime != null) {
        console.log('STARTER TOWN', this.selectedEvent.startTime)
        this.selectedEvent.endTime = moment.utc(this.selectedEvent.startTime).add(90, 'm').format('YYYY-MM-DDTHH:mm:ssZ')
        console.log('END TOWN', this.selectedEvent.endTime)
      }
    },
    getReadOnly: function (field) {
      // if events admin then they can edit any event fields, otherwise idk???
      // if not readonly and the user can manage then ignore event status check
      let fieldReadOnly = false
      if (null != field) {
        fieldReadOnly = getEventCustomFieldReadOnly(this.$store, field)
      }
      return ((!this.userIsAdmin && !this.userCanManage && !fieldReadOnly) && (this?.selectedEvent?.eventStatusTypeId !== 1 || this?.selectedEvent?.processStepStatusTypeId !== 1))
        || fieldReadOnly || !this.userCanEdit
    },
    getDefaultFieldReadOnly: function (wlp, readOnlyFieldValue) {
      let readOnly = getEventDefaultFieldReadOnly(this.$store, wlp, readOnlyFieldValue)
      // if events admin then they can edit any event fields, otherwise idk???
      // if not readonly and the user can manage then ignore event status check
      return ((!this.userIsAdmin && !this.userCanManage && !readOnly) && (this?.selectedEvent?.eventStatusTypeId !== 1 || this?.selectedEvent?.processStepStatusTypeId !== 1))
        || readOnly
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
        this.projectMismatch = false
        const {
          data,
          status
        } = await getRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.ppsEventId}`)
        if (data && data.projectId && data.projectId !== this.projectId) {
          this.projectMismatch = true
          this.eventDetailsLoading = false
          this.snackbar = getSnackbar('ERROR', `Invalid Request: Project Mismatch`)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } else {
          this.selectedEvent = data
          //this verifies whether the event had a start time when the page loaded, if not then we allow all users to delete
          this.selectedEvent.allowAllUserDeletion = data.startTime === null
          //have to reset the pps stuff too in case they just go directly to the url
          this.$store.commit(ProjectMutations.SET_PPS, {
            projectProcessStepId: this.selectedEvent.projectProcessStepId,
            processStepId: this.selectedEvent.processStepId,
            processStepName: this.selectedEvent.processStepName
          })
          window.document.title = this.project?.id ? `${this.project.projectName} - ${this.selectedEvent.eventName}`
            : `${this.selectedEvent.eventName}`
          this.$store.commit(ProjectMutations.SET_PPS_EVENT, this.selectedEvent)
          if (data.uniqueBehaviorTypeId === 1) {
            this.uniqueAlreadyHasValue = null != this.selectedEvent.startTime || null != this.selectedEvent.endTime || null != this.selectedEvent.resourceId
            this.getRoundRobinNumDays()
            this.userCanScheduleLeadAllocation()
            this.userCanScheduleRemoteLeadAllocation()
          }
          //this was causing an error if you clicked too fast between events
          if (data.id) {
            await this.getStatusesAssignedToEvent()
          }
          return status
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        let msg = e?.data?.message || 'Error Retrieving Details'
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    deleteEvent: async function (ppseId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${ppseId}`)
        //set navigation override so that if there were unsaved fields it won't ask you to try and save
        this.navigationOverride = true
        this.$emit('refresh-upcoming-events')
        //go to the process step
        this.$router.push(`/project/${this.projectId}/processStep/${this.projectProcessStepId}`)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveEventDetails() {
      this.eventSaveOverrideRequired = true
      this.eventActionMissingRequirements = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          id: this.selectedEvent.id,
          startTime: this.selectedEvent.startTime,
          endTime: this.selectedEvent.endTime,
          resourceId: this.selectedEvent.resourceId,
          saveVersion: this.selectedEvent.saveVersion,
          //we only send up the status if it changed. sql handles whether to save the value or not
          companyEventStatusTypeId: this.statusChanged ? this.selectedEvent.companyEventStatusTypeId : null,
          customFieldValues: this.dirtyCfvs
        }
        const {data} = await putRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.selectedEvent.id}`, params)
        this.statusChanged = false
        this.dirtyCfvs = []
        this.$refs.ppseFieldsContainer.$el.scrollTop = 0
        this.selectedEvent = data
        this.snackbar = getSnackbar('SUCCESS', 'Fields Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$emit('refresh-upcoming-events')
        if (data.uniqueBehaviorTypeId === 1) {
          this.uniqueAlreadyHasValue = null != this.selectedEvent.startTime || null != this.selectedEvent.endTime || null != this.selectedEvent.resourceId
          this.getRoundRobinNumDays()
        }
      } catch (e) {
        logError(e)
        let saveMismatch = e.data?.message === 'Save Version Mismatch'
        let msg = saveMismatch ? `<div class="text-center">Cannot Save Changes. <br/>This event has been updated by another user. <br/>Click <a class="white--text underline" href="">here</a> to refresh.</div>` : 'Error Performing Event'
        this.snackbar = getSnackbar('ERROR', msg, saveMismatch)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
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
          users: this.selectedTimeSlot.users,
          remote: this.mostRecentSearchWasRemote,
          customFieldValues: this.dirtyCfvs
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
          //set the some values that may have updated when setting the closer appt event
          this.selectedEvent.startTime = data.appointmentStartTime
          this.selectedEvent.endTime = data.appointmentEndTime
          this.selectedEvent.resourceId = data.userPositionId
          this.selectedEvent.resource = data.userFullName
          this.selectedEvent.companyEventStatusTypeId = data.companyEventStatusTypeId
          this.selectedEvent.eventActions = data.eventActions
          this.uniqueAlreadyHasValue = true
          //reset the error messages:
          this.eventActionMissingRequirements = false
          this.saveErrorMsg = ''
          this.showUnperformableActions = true

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
      let validSave = true
      let startTime = this.selectedEvent.startTime
      let endTime = this.selectedEvent.endTime

      //if is for closer appt
      if (this.selectedEvent.uniqueBehaviorTypeId === 1) {
        if (!startTime || !endTime || !this.selectedEvent.resourceId) {
          validSave = false
          this.eventActionMissingRequirements = true
          this.actionRequiresEnd = !endTime
          this.actionRequiresResource = !this.selectedEvent.resourceId
          this.saveErrorMsg = 'Additional fields are required to save this event.'
        } else if (startTime && endTime && !moment(endTime).isAfter(startTime)) {
          validSave = false
          this.eventActionMissingRequirements = true
          this.saveErrorMsg = 'End time must be after start time'
        }
      } else if (null != this.selectedEvent.startTime) {
        //for all other types just compare start to end if end not null
        if (startTime && endTime && !moment(endTime).isAfter(startTime)) {
          validSave = false
          this.eventActionMissingRequirements = true
          this.saveErrorMsg = 'End time must be after start time'
        }
      }
      //per judson, dont require start time anymore
      // else {
      //   //only startTime is required to save fields
      //   validSave = false
      //   this.actionRequiresEnd = false
      //   this.actionRequiresResource = false
      //   this.eventActionMissingRequirements = true
      //   this.saveErrorMsg = 'Start Time is required to save the event fields'
      //   //dont do this for now. makes the page look weird after save
      //   // document.getElementById('event-header').scrollIntoView()
      // }

      //after everything, only save if valid
      if (validSave) {
        this.eventActionMissingRequirements = false
        this.defaultValuesChanged = false
        this.saveEventDetails()
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
        const {data, status} = await getRequest(`/attachmentType/eventTypesByPpsEventId/${this.ppsEventId}`, null, [])
        this.attachmentTypes = data
        return status
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

#event-header .v-toolbar__content {
  display: flex;
  align-items: flex-start;
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


</style>
<style lang="scss" scoped>

.cfg-detail-header {
  background-color: var(--v-secondary-base) !important;
  margin-left: -10px;
  margin-right: -10px;
  padding-left: 10px;
  padding-right: 10px;
}

.scheduler-button-text {
  text-transform: capitalize;
  text-decoration: underline;
}

.scheduler-button-icon {
  text-decoration: none;
  font-size: 12px;
}

.scheduled-time {
  color: #9E9C9C;
  font-size: 12px;
  font-weight: normal;
}

.action-subheader {
  width: 186px;
  margin-top: 20px;
}

.padding-left-1 {
  padding-left: 1px; //keeps the Event Details toolbar from covering the border on the left panel
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

.action-button-name {
  display: block;
}

.action-button-subtitle {
  display: block;
  font-size: 10px;
}

.banner-card-swatch {
  min-height: 100%;
  width: 30px;
}

.action-button-subtitle-date {
  text-transform: lowercase;
}

</style>

<template>
<v-main>

<!--  screen header -->
    <v-row class="process-step-header">
      <v-col cols="8" class="text-left pl-5">
        <div class="project-title">
          <router-link :to="`/project/${project.id}/details`">{{ project.projectName}}</router-link>
        </div>
        <div class="project-subtitle">
          {{ project.street1 }} - {{ project.city }}, {{ project.state }} {{ project.postalCode }}
        </div>
      </v-col>

      <v-col cols="4" class="lead-owner pb-2 text-right">
        <div v-if="!displayChangeOwner">
          <div v-if="processStep.owner && processStep.owner.userId">
            <v-avatar
              :tile="false"
              :size="25"
              color="grey lighten-4"
              class="account-img mr-2"
            >
              <img name="accountImg" src="../../../assets/flow/user_img_placeholder.png">
            </v-avatar>
            {{processStep.owner.fullName}}<br/>
            {{processStep.owner.position}}
          </div>
        </div>
        <div v-if="displayChangeOwner">
          <v-autocomplete v-model="processStep.owner"
                          :items="availableOwners"
                          label="Select Owner"
                          item-text="fullName"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          return-object
                          autocomplete="off"
                          @change="updateOwner"
          >
          </v-autocomplete>
        </div>
        <v-btn text x-small v-if="userCanEdit" class="change-owner-button" @click="displayChangeOwner = !displayChangeOwner">
          <span v-if="displayChangeOwner">cancel</span>
          <span v-else-if="processStep.owner && processStep.owner.userId">change</span>
          <span v-else>add owner</span>
        </v-btn>
        <v-btn text x-small v-if="userCanEdit && processStep.owner && processStep.owner.userId" class="change-owner-button" @click="removeOwner">
          remove
        </v-btn>
      </v-col>
    </v-row>
<v-row>
  <v-col class="text-left px-5 py-0">
<!--    <v-btn-->
<!--      class="back-btn"-->
<!--      text-->
<!--      :ripple="false"-->
<!--      @click="$router.go(-1)">Back</v-btn>-->
    <v-btn
      class="back-btn"
      text
      :ripple="false"
      :to="`/project/${projectId}/details`">Back to Project</v-btn>
<!--    {{usingUniqueView}}-->
  </v-col>

  <v-col cols="12" class="py-0 process-step-header" >
    <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
      <v-toolbar-title class="px-5 process-step-name">
        {{ processStep.processStepName }}
        <v-icon v-if="processStep.processStepStatusTypeId === 1"
                size="20" color="green">mdi-circle-slice-8</v-icon>

      <v-dialog
        v-model="processStep.changeActiveConfirm"
        width="500">
        <template #activator="{ on }">
          <v-checkbox
            class=""
            v-on="on"
            dense
            v-model="processStep.main"
            :disabled="processStep.main || !userCanEdit"
            label="Primary"
          />
        </template>
        <v-card>
          <v-card-title
            class="headline grey lighten-2"
            primary-title>
            Confirm
          </v-card-title>

          <v-card-text class="pt-4">
            Modifying the primary flag will cancel the current active process step. It will also run any automatic actions that have not yet been run where the criteria is met using values from the new active process step.
            Are you sure you want to set this process step to Primary?
          </v-card-text>

          <v-divider></v-divider>

          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn
              @click="[processStep.changeActiveConfirm = false, processStep.main = false]">
              No
            </v-btn>
            <v-btn
              color="primaryCustom"
              text
              @click="[processStep.changeActiveConfirm = false, updateMain(processStep.projectProcessStepId)]">
              Yes
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <div>
        <v-btn
          v-if="anyGroupNonUnique()"
          color="primaryCustom"
          class="white--text"
          :disabled="fieldsSaving"
          @click="[fieldsSaving = true, checkFields()]"
        >Save Process Step Fields</v-btn>
      </div>
    </v-toolbar>
  </v-col>
  <v-col cols="12" lg="6" class="text-left pt-0">

<!--    process field groups-->
    <v-col
      class="pt-0"
      v-for="(cfg, index) in customFieldGroups"
      :key="index"
    >
      <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
        <v-toolbar-title>
<!--  @TODO: @humes, once schedule tool is ready, have this link go to a more specific location in the schedule tool-->
          <v-btn small text v-if="cfg.eventTypeId && $store.getters.userHasFeature('SCHEDULE')"
                 :to="`/schedule?projectProcessStepId=${projectProcessStepId}`">
            <v-icon>mdi-calendar</v-icon>
          </v-btn>
<!--          <router-link v-if="cfg.eventTypeId && $store.getters.userHasFeature('SCHEDULE')"-->
<!--                       :to="`/schedule?projectProcessStepId=${projectProcessStepId}`">{{cfg.groupName}}</router-link>-->
          {{cfg.groupName}}
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-toolbar-items v-if="displayUniqueView(cfg)">
            <v-btn
              v-if="cfg.uniqueBehaviorTypeId === 1 && closerApptOverride && !anyGroupNonUnique()"
              text
              @click="checkFields"
            >Save Process Fields</v-btn>
            <v-spacer></v-spacer>
            <v-btn text @click="closerApptOverride = !closerApptOverride"
                   v-if="!closerAppointmentDetails.userId">
              {{ closerApptOverride ? 'Back' : 'Override' }}
            </v-btn>
<!--            todo: change to this button after they finish testing. this will make the override button only available to closers -->
<!--            <v-btn text @click="closerApptOverride = !closerApptOverride"-->
<!--                   v-if="!closerAppointmentDetails.userId && $store.getters.userHasPosition(1)">-->
<!--              {{ closerApptOverride ? 'Back' : 'Override' }}-->
<!--            </v-btn>-->
          </v-toolbar-items>
        </v-toolbar-items>
      </v-toolbar>
      <v-card v-if="displayUniqueView(cfg) && !closerApptOverride && project.postalCode && project.companyStateId">
        <v-toolbar flat color="transparent">
          <v-toolbar-title>Lead Allocation</v-toolbar-title>
        </v-toolbar>
        <v-card-text class="py-0" v-if="!userIsScheduler || (userIsScheduler && schedulerCanEdit)">
          <div v-if="!closerAppointmentDetails.userId" class="pb-3">
            <CustomValueInput
                :readonly="!userCanEdit"
                :callback="populateDirtyCfvs"
                :field="availabilityDateField"
            />
            <div class="text-right" v-if="availabilityDateField.dateValue">
              <v-btn color="primaryCustom" dark class="white--text"
                     :loading="searchLoading"
                @click="getAvailableTimeSlots">
                Search
              </v-btn>
            </div>
            <v-select v-if="timeSlots.length > 0 && availabilityDateField.dateValue"
              v-model="selectedTimeSlot"
              :items="timeSlots"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              label="Select an Available Time Slot"
              return-object
            >
              <template slot="selection" slot-scope="data">
                {{ data.item.scheduledStartTime | formatDate('timestamp')}}
              </template>
              <template slot="item" slot-scope="data">
                {{ data.item.scheduledStartTime | formatDate('timestamp')}}
              </template>
            </v-select>
            <div v-else-if="searchedTimeSlots && availabilityDateField.dateValue">No Times Available for the Selected Date</div>
            <div class="text-right" v-if="selectedTimeSlot.scheduledStartTime && availabilityDateField.dateValue">
              <v-btn color="primaryCustom" class="white--text"
                     @click="saveCloserAppointment">
                Save Appointment
              </v-btn>
            </div>
          </div>
          <div v-else>
            Appointment has been saved.
            <DatetimePickerInput
              v-model="closerAppointmentDetails.appointmentStartTime"
              :timezone="timezone"
              :type="'timestamp'"
              :readonly="true"
              :format="'MMMM DD, YYYY, h:mm A'"
              label="Closer Appointment Start Time"
            />
            <DatetimePickerInput
              v-model="closerAppointmentDetails.appointmentEndTime"
              :timezone="timezone"
              :type="'timestamp'"
              :readonly="true"
              :format="'MMMM DD, YYYY, h:mm A'"
              label="Closer Appointment End Time"
            />
            <v-text-field color="primaryCustom"
                          v-model="closerAppointmentDetails.userFullName"
                          readonly
                          disabled
                          label="Closer"></v-text-field>
          </div>
        </v-card-text>
        <v-card-text class="pt-0" v-else-if="!schedulerLoading && userIsScheduler && !schedulerCanEdit">
          You do not have access to schedule projects in this Postal Code
        </v-card-text>
      </v-card>
      <v-card class="pa-4" v-if="displayUniqueView(cfg) && !closerApptOverride && (!project.postalCode || !project.companyStateId)">
        A state and postal code are required on the project to continue with scheduling.  Please return to the project screen and update.
      </v-card>
      <v-card class="pa-4" v-if="!displayUniqueView(cfg) || closerApptOverride">
        <CustomValueInput
          v-for="(field, idx) in cfg.customFieldValues"
          :key="idx"
          :callback="populateDirtyCfvs"
          :readonly="getReadOnly(field)"
          :field="field"
        />
      </v-card>
    </v-col>



    <!-- todo: @humes just putting this here so i can test scheduling.  feel free to do what you want with it. i dont even know if this is the right spot -->
    <!-- @TODO: @randa, Uncommenting for now until I can add it in programatically. How do we not hardcode the processStepid and projectId vals? (they harcoded for testing?)   -->
<!--    <v-row>-->
<!--      <v-col cols="12">-->

<!--        <h3>Links</h3>-->

<!--        <v-btn :to="{name: 'schedule', query: { processStepId: 1, projectId: 171704 } }">-->
<!--          Test link to schedule screen-->
<!--        </v-btn>-->
<!--      </v-col>-->
<!--    </v-row>-->


  </v-col>

  <v-col cols="12" lg="6" class="text-left pt-0">
    <v-toolbar color="transparent" class="elevation-0">
      <v-toolbar-title>Actions</v-toolbar-title>
    </v-toolbar>
    <v-col v-for="action in processStep.actions" :key="action.id" class="pt-0">
      <ActionButton
        v-if="action.actionTypeId === 2"
        :actionId="action.id"
        :projectProcessStepId="parseInt(projectProcessStepId)"
        :label="action.actionName"
        :handleOnComplete="handleActionCompleted"
        :handleOnCompleteError="handleOnCompleteError"
      />
    </v-col>
<!--    <NotesAndActivity-->
<!--      :showNotes="true"-->
<!--      :showActivity="false"-->
<!--      :notes="notes"-->
<!--      :primaryId="parseInt(projectProcessStepId)"-->
<!--      type="ProjectProcessStep"-->
<!--    />-->
    <v-row>
      <Attachments :projectProcessStepId="parseInt(projectProcessStepId)" :processStepId="parseInt(processStepId)"/>
    </v-row>

    <v-row>
      <Links :projectProcessStepId="parseInt(projectProcessStepId)" :processStepId="parseInt(processStepId)"/>
    </v-row>
  </v-col>

</v-row>
</v-main>
</template>

<script>

import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest, postRequest} from '@/helpers/helpers'
import ActionButton from './ActionButton'
import {AppMutations} from '@/stores/AppStore'

import Attachments from '@/views/flow/components/Attachments'
import Links from '@/views/flow/components/Links'
// import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import moment from 'moment-timezone'

export default {
  name: 'ProjectProcessStep',
  components: {
    ActionButton,
    Links,
    Attachments,
    // NotesAndActivity,
    CustomValueInput,
    DatetimePickerInput
  },
  data () {
    return {
      snackbar: {},
      availabilityDateField: { fieldName: 'Select a Date', dataTypeId: 1, dateValue: null },
      timeSlots: [],
      selectedTimeSlot: {},
      closerApptOverride: false,
      fieldsSaving: false,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT'),
      userIsScheduler: this.$store.state.user.details.userPositions?.some(p => p.scheduler),
      schedulerCanEdit: false,
      schedulerLoading: true,
      closerApptSaved: false,
      searchedTimeSlots: false,
      timezone: this.$store.state.user.details.timezone.value,
      closerAppointmentDetails: {},
      projectId: this.$route.params.projectId,
      projectProcessStepId: this.$route.params.processStepId,
      processStepId: this.$route.query.processStepId,
      processStep: {},
      customFieldGroups: [],
      isProcessStepLoading: true,
      dirtyCfvs: [],
      notes: [],
      project: {},
      displayChangeOwner: false,
      availableOwners: [],
      availableProcessStepStatuses: [],
      searchLoading: false,
      usingUniqueView: false,
      uniqueCfgId: null,
    }
  },
  async created () {
    this.getAvailableStatuses()
    this.getCustomFieldGroups()
    //per 9/24 request judson had us remove notes from process steps
    // this.getNotes()
    this.getProject()
    await this.getProcessStep()
    this.getAvailableOwners()
  },
  methods: {
    anyGroupNonUnique () {
      let nonUniqueGroups = this.customFieldGroups.find(cfg => cfg.uniqueBehaviorTypeId === null)
      return null != nonUniqueGroups
    },
    async getAvailableStatuses () {
      try {
        let params = {
          projectId: parseInt(this.projectId)
        }
        const {data} = await getRequestWithParams(`/processStep/status`, { params })
        // const {data} = await getRequest(`/processStep/status`)
        this.availableProcessStepStatuses = data
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        logError(e)
      }
    },
    getProcessStep: async function() {
      try {
        const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}`)
        this.processStep = data
        window.document.title = this.project?.id ? `${this.project.projectName} - ${this.processStep.processStepName}`
          : `${this.processStep.processStepName}`
      } catch (e) {
        logError(e)
      } finally {
        this.isProcessStepLoading = false
      }
    },
    async getCustomFieldGroups() {
      //@TODO: @humes, make this use local loading so entire screen isn't blocked waiting
      //this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customFieldValues/project/${this.projectId}/processStep/${this.projectProcessStepId}`)
        this.customFieldGroups = data
        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        // this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getNotes() {
      try {
        const {data} = await getRequestWithParams(`/note/getProjectProcessStepNotes`, {
          params: {
            primaryId: this.projectProcessStepId
          }
        })
        this.notes = data
      } catch {
        console.log('suck')

      }
    },
    getProject: async function () {
      try {
        const {data} = await getRequest(`/project/${this.projectId}`)
        this.project = data
        window.document.title = this.processStep?.processStepId ? `${this.project.projectName} - ${this.processStep.processStepName}`
                                    : `${this.project.projectName}`
        await this.userCanScheduleLeadAllocation()
      } catch (e) {
        logError(e)
      }
    },
    async getAvailableOwners () {
      // this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/projectProcessStep/owners/${this.processStep.processStepProcessId}`)
        this.availableOwners = data

        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving List of Owners')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        // this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async userCanScheduleLeadAllocation () {
      //we only have to check this if the user is a scheduler otherwise we just use the userCanEdit value
      if(this.userIsScheduler) {
        this.schedulerLoading = true
        try {
          const {data} = await getRequestWithParams(`/postalCode/zone/userCanSchedule`, { params: {
            postalCode: this.project.postalCode
          }})
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
    async updateProjectFieldGroups() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/customFieldValues/project/${this.projectId}`, this.customFieldGroups)
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Update Project Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async checkFields() {
      if(this.usingUniqueView && this.uniqueCfgId) {
        //if this is the schedule closer appt process step - i die inside a little more every time
        //if they ask us to do this for all scheduling groups we could just change to if cfg.eventTypeId != null
        //get the cfg that is the unique one
        let uniqueCfg = this.customFieldGroups.find(cfg => cfg.id === this.uniqueCfgId)
        let startField = uniqueCfg?.customFieldValues?.find(cfv => cfv.scheduleFieldTypeId === 1)
        let endField = uniqueCfg?.customFieldValues?.find(cfv => cfv.scheduleFieldTypeId === 2)
        let resourceField = uniqueCfg?.customFieldValues?.find(cfv => cfv.scheduleFieldTypeId === 3)
    
        let startTime = startField?.timestampValue
        let endTime = endField?.timestampValue
        let resource = resourceField?.intValue
        if((startTime && !endTime) || (!startTime && endTime) || (resource && (!startTime && !endTime))) {
          this.snackbar = getSnackbar('ERROR', 'Start time and end time are required')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
        } else if(startTime && endTime && moment(endTime).isBefore(startTime)) {
          this.snackbar = getSnackbar('ERROR', 'End time cannot be before start time')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
        } else if (startTime && endTime && !resource) {
          //resource required if times are saving
          this.snackbar = getSnackbar('ERROR', 'Resource is required')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
        } else {
          await this.updateFieldGroups(true, resource)
        }
      }else {
        await this.updateFieldGroups()
      }
    },
    async updateFieldGroups(cameFromUnique, resourceId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      // this.processStep.customFieldGroups = this.customFieldGroups
      try {
        // const {data} = await putRequest(`/projectProcessStep`, this.processStep)
        // save dirty custom field values
        const {data} = await postRequest(`/customFieldValues/project/${this.projectId}/processStep/${this.projectProcessStepId}`, this.dirtyCfvs)
        this.dirtyCfvs = []
        this.customFieldGroups = data
        //if override - schedule closer appt - log to the audit table
        if(cameFromUnique && resourceId) {
          console.log('AUDIT saving', resourceId)
          let params = {
            projectId: this.projectId,
            projectProcessStepId: this.projectProcessStepId,
            userPositionId: resourceId
          }
          await postRequest(`/availability/auditOverride`, params)
        }
        //only the uniqueBehaviorTypeId = 1 uses this field but i'm just setting it every time since i don't have the data here that i need to check and it shouldn't matter if it always gets updated. hows this for the longest comment ever?
        this.closerApptSaved = true
        this.$root.$emit('projectProcessStep:checkAction')
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.fieldsSaving = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    populateDirtyCfvs(field) {
      //some fields are for unique behavior and they dont need to be saved. this check should filter them out
      if(field.customFieldId) {
        let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
        if (!match) {
          this.dirtyCfvs.push(field)
        }
      } else {
        //this should only get hit when the "Select a Date" field value gets changed
        this.selectedTimeSlot = {}
        this.timeSlots = []
        this.searchedTimeSlots = false
      }
    },
    async removeOwner() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.processStep.owner = {}
        await postRequest(`/projectProcessStep/${this.projectProcessStepId}/owner`, this.processStep.owner)
        this.snackbar = getSnackbar('SUCCESS', 'Owner Removed')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Removing Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateOwner() {
      this.displayChangeOwner = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/projectProcessStep/${this.projectProcessStepId}/owner`, this.processStep.owner)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
      async updateMain(projectProcessStepId) {
          try {
              this.$store.commit(AppMutations.SET_LOADING, true)
              await postRequest(`/projectProcessStep/${projectProcessStepId}/status`, this.availableProcessStepStatuses.find(status => status.processStepStatusTypeId === 1))
          } catch (e) {
              logError(e)
              this.snackbar = getSnackbar('ERROR', 'Unable to update to primary process step')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.processStep.main = false
          } finally {
              this.$store.commit(AppMutations.SET_LOADING, false)
          }
      },
    getReadOnly: function (field) {
      return this?.processStep?.processStepStatusTypeId !== 1 || (!this.closerApptOverride ? getCustomFieldReadOnly(this.$store, field) : this.closerApptSaved) || !this.userCanEdit
    },
    handleActionCompleted () {
      this.$router.push({name: 'projectDetails', params: {projectId: this.projectId}})
    },
    handleOnCompleteError (actionId) {
      logError(`Failed to complete action with actionId: ${actionId}`)
      this.snackbar = getSnackbar('ERROR', 'Unable to Complete Action')
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    },
    async getAvailableTimeSlots () {
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
        if(data) {
          this.closerAppointmentDetails = data
          this.closerApptSaved = true
        }
        this.$root.$emit('projectProcessStep:checkAction')
      } catch (e) {
        logError(e)
        let msg = e?.data?.message ?? 'Unable to Set Closer Appointment'
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    displayUniqueView(cfg) {
      // return true
      if(cfg.uniqueBehaviorTypeId !== 1 || !this.userCanEdit) {
        return false
      } else {
        this.usingUniqueView = true
        this.uniqueCfgId = cfg.id
        let alreadyHasTime, alreadyHasResource = false
        //we should only hit this for a schedule closer appt group.
        // and it should always have 3 fields (start, end, resource)
        // if any of the 3 fields are already populated, don't allow them to edit/save
        cfg.customFieldValues.forEach(cfv => {
          if(cfv.intValue && cfv.id) {
            alreadyHasResource = true
          }
          if(cfv.timestampValue && cfv.id) {
            alreadyHasTime = true
          }
        })

        return !alreadyHasTime && !alreadyHasResource
      }
    }
  }
}
</script>

<style lang="scss">
.cfg-name-toolbar .v-toolbar__content {
  padding-left: 0 !important;
}
</style>
<style lang="scss" scoped>
.process-step-header {
  border-bottom: solid 1px #EAEAF4;
}

.process-step-name {
  font-weight: bold;
  font-size: 22px;
  padding-top: 10px;
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
}
</style>

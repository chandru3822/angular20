<template>
<v-row>

<!--  screen header -->
  <v-col cols="12">
    <v-row class="process-step-header">
      <v-col cols="8" class="text-left pl-5">
        <div class="project-title">
          <router-link :to="`/project/${project.id}`">{{ project.projectName}}</router-link>
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
              <img name="accountImg" src="../../../assets/user_img_placeholder.png">
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
                          return-object
                          autocomplete="off"
                          @change="updateOwner"
          >
          </v-autocomplete>
        </div>
        <v-btn text x-small class="change-owner-button" @click="displayChangeOwner = !displayChangeOwner">
          <span v-if="displayChangeOwner">cancel</span>
          <span v-else-if="processStep.owner && processStep.owner.userId">change</span>
          <span v-else>add owner</span>
        </v-btn>
      </v-col>
    </v-row>
  </v-col>

  <v-col class="text-left">
    <v-btn
      class="back-btn"
      text
      :ripple="false"
      @click="$router.go(-1)">Back</v-btn>
  </v-col>

  <v-col cols="12" class="text-left">
    <h2>{{ processStep.processStepName }}</h2>
            <v-checkbox
                v-model="processStep.main"
                :disabled="processStep.main"
                label="Primary"
                @change="updateMain(processStep.projectProcessStepId)"
            />
  </v-col>

  <v-col cols="12" lg="6" class="text-left">

<!--    process field groups-->
    <v-col
      class="mt-4"
      v-for="(cfg, index) in customFieldGroups"
      :key="index"
    >
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>
<!--  @TODO: @humes, once schedule tool is ready, have this link go to a more specific location in the schedule tool-->
          <router-link v-if="cfg.eventTypeId" :to="`/schedule`">{{cfg.groupName}}</router-link>
          <template v-else>{{cfg.groupName}}</template>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn
            v-if="index === 0 && (cfg.uniqueBehaviorTypeId !== 1 || (cfg.uniqueBehaviorTypeId === 1 && closerApptOverride))"
            text
            @click="updateFieldGroups"
          >Save Process Fields</v-btn>
          <v-spacer></v-spacer>
          <v-toolbar-items v-if="displayUniqueView(cfg)">
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
      <v-card v-if="displayUniqueView(cfg) && !closerApptOverride && project.postalCode">
        <v-toolbar flat color="transparent">
          <v-toolbar-title>Lead Allocation</v-toolbar-title>
          <v-spacer></v-spacer>
        </v-toolbar>
        <v-card-text>
          <div v-if="!closerAppointmentDetails.userId">
            <CustomValueInput
                :readonly="false"
                :callback="populateDirtyCfvs"
                :field="availabilityDateField"
            />
            <div class="text-right" v-if="availabilityDateField.dateValue">
              <v-btn color="primaryCustom" dark class="white--text"
                @click="getAvailableTimeSlots">
                Search
              </v-btn>
            </div>
            <v-select v-if="timeSlots.length > 0"
              v-model="selectedTimeSlot"
              :items="timeSlots"
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
            <div v-else-if="searchedTimeSlots">No Times Available for the Selected Date</div>
            <div class="text-right" v-if="selectedTimeSlot.scheduledStartTime">
              <v-btn color="primaryCustom" dark class="white--text"
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
              label="Start Time"
            />
            <DatetimePickerInput
              v-model="closerAppointmentDetails.appointmentEndTime"
              :timezone="timezone"
              :type="'timestamp'"
              :readonly="true"
              :format="'MMMM DD, YYYY, h:mm A'"
              label="End Time"
            />
            <v-text-field color="primary"
                          v-model="closerAppointmentDetails.userFullName"
                          readonly
                          label="Resource"></v-text-field>
          </div>
        </v-card-text>
      </v-card>
      <v-card class="pa-4" v-if="displayUniqueView(cfg) && !closerApptOverride && !project.postalCode">
        A postal code is required on the project to continue with scheduling.  Please return to the project screen and add a postal code.
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

    <v-toolbar color="transparent" class="elevation-0">
      <v-toolbar-title>Actions</v-toolbar-title>
    </v-toolbar>
    <v-col v-for="action in processStep.actions" :key="action.id">
      <ActionButton
        v-if="action.actionTypeId === 2"
        :actionId="action.id"
        :projectProcessStepId="parseInt(projectProcessStepId)"
        :label="action.actionName"
        :handleOnComplete="handleActionCompleted"
        :handleOnCompleteError="handleOnCompleteError"
      />
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

    <v-row>
      <Attachments :projectProcessStepId="parseInt(projectProcessStepId)" :processStepId="parseInt(processStepId)"/>
    </v-row>
  </v-col>

  <v-col cols="12" lg="6" class="text-left">
    <NotesAndActivity
      :showNotes="true"
      :showActivity="false"
      :notes="notes"
      :primaryId="parseInt(projectProcessStepId)"
      type="ProjectProcessStep"
    />
  </v-col>

  <Snackbar :snackbar="snackbar"></Snackbar>
</v-row>
</template>

<script>

import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest, postRequest} from '@/helpers/helpers'
import ActionButton from './ActionButton'
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import Attachments from '@/views/flow/components/Attachments'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import moment from 'moment-timezone'

export default {
  name: 'ProjectProcessStep',
  components: {
    ActionButton,
    Snackbar,
    Attachments,
    NotesAndActivity,
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
      availableProcessStepStatuses: []
    }
  },
  async created () {
    this.getAvailableStatuses()
    this.getCustomFieldGroups()
    this.getNotes()
    this.getProject()
    await this.getProcessStep()
    this.getAvailableOwners()
  },
  methods: {
    async getAvailableStatuses () {
      try {
        const {data} = await getRequest(`/processStep/status`)
        this.availableProcessStepStatuses = data
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
        logError(e)
      }
    },
    getProcessStep: async function() {
      try {
        const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}`)
        this.processStep = data
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
        // this.$store.commit(AppMutations.SET_LOADING, false)
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
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      // this.processStep.customFieldGroups = this.customFieldGroups
      try {
        // const {data} = await putRequest(`/projectProcessStep`, this.processStep)
        // save dirty custom field values
        const {data} = await postRequest(`/customFieldValues/project/${this.projectId}/processStep/${this.projectProcessStepId}`, this.dirtyCfvs)
        this.dirtyCfvs = []
        this.customFieldGroups = data
        //only the uniqueBehaviorTypeId = 1 uses this field but i'm just setting it every time since i don't have the data here that i need to check and it shouldn't matter if it always gets updated. hows this for the longest comment ever?
        this.closerApptSaved = true
        this.$root.$emit('projectProcessStep:checkAction')
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Fields')
      } finally {
          this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if(!match) {
        this.dirtyCfvs.push(field)
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
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
      async updateMain(projectProcessStepId) {
          try {
              this.$store.commit(AppMutations.SET_LOADING, true)
              await postRequest(`/projectProcessStep/${projectProcessStepId}/status`, this.availableProcessStepStatuses.find(status => status.id === 1))
          } catch (e) {
              logError(e)
              this.snackbar = getSnackbar('ERROR', 'Unable to update to primary process step')
              this.processStep.main = false
          } finally {
              this.$store.commit(AppMutations.SET_LOADING, false)
          }
      },
    getReadOnly: function (field) {
      return this?.processStep?.processStepStatusTypeId !== 1 || (!this.closerApptOverride ? getCustomFieldReadOnly(this.$store, field) : this.closerApptSaved)
    },
    handleActionCompleted () {
      this.$router.push({name: 'projectDetails', params: {projectId: this.projectId}})
    },
    handleOnCompleteError (actionId) {
      logError(`Failed to complete action with actionId: ${actionId}`)
      this.snackbar = getSnackbar('ERROR', 'Unable to Complete Action')
    },
    async getAvailableTimeSlots () {
      try {
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

      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Time Slots')
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
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    displayUniqueView(cfg) {
      // return true
      if(cfg.uniqueBehaviorTypeId !== 1) {
        return false
      } else {
        let hasTime, hasResource = false
        //we should only hit this for a schedule closer appt group. and it should always have 3 fields (start, end, resource)
        cfg.customFieldValues.forEach(cfv => {
          if(cfv.intValue) {
            hasResource = true
          }
          if(cfv.timestampValue) {
            hasTime = true
          }
        })
        return !hasTime && !hasResource
      }
    }
  }
}
</script>

<style lang="scss" scoped>

.process-step-header {
  border-bottom: solid 1px #EAEAF4;
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

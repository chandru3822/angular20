<template>
  <v-main v-if="!processStepLoading" class="py-0 px-6 relative height-one-hunned overflow-y-auto">
    <!--  error save dialog -->
    <v-row>
      <v-col class="text-left px-5 py-0">
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
                color="primaryCustom"
                text
                @click="[navigationOverride = true, goToPath(toPath, query)]">
                Yes
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </v-col>

      <v-col cols="12" class="pb-4 pt-6">
        <v-toolbar color="transparent" height="auto"
                   id="pps-toolbar"
                   class="elevation-0 cfg-name-toolbar toolbar-z-index-override">
          <v-toolbar-title class="process-step-name albatross-header-2">
            <div>{{ processStep.processStepName }}</div>
            <div v-if="processStep.processStepStatusTypeId"
                  :class="getStatusClass(processStep.processStepStatusTypeId)">({{
                processStep.processStepStatusType
              }})</div>
            <!--            <v-icon v-if="processStep.processStepStatusTypeId === 1"-->
            <!--                    size="20" color="green">mdi-circle-slice-8-->
            <!--            </v-icon>-->
            <v-dialog
              v-model="processStep.changeActiveConfirm"
              width="500">
              <template #activator="{ on }">
                <v-checkbox
                  v-on="on"
                  dense
                  v-model="processStep.main"
                  :disabled="processStep.main || !userCanManage || availableProcessStepStatuses.length === 0"
                  label="Primary"
                />
              </template>
              <v-card>
                <v-card-title
                  class="text-h5 grey lighten-2"
                  primary-title>
                  Confirm
                </v-card-title>

                <v-card-text class="pt-4">
                  Modifying the primary flag will run any automatic actions that have not yet been run where
                  the criteria is met using values from the new active process step.
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
                    @click="[processStep.changeActiveConfirm = false, processStep.main = true, showMainDialog = true]">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items class="owner-toolbar-items">
            <div v-if="!displayChangeOwner">
              <div v-if="processStep.owner && processStep.owner.userId" class="d-flex flex-row align-center">
                <div class="d-flex flex-column">
                <div class="owner-info">
                  {{ processStep.owner.fullName }}<br/>
                  <span class="owner-position albatross-body-3">{{ processStep.owner.position }}</span>
                </div>
                </div>
                <v-btn v-if="userCanEdit" small icon class="ml-2" @click="removeOwner"><v-icon>mdi-close</v-icon></v-btn>
              </div>
            </div>
            <div v-if="displayChangeOwner">
              <v-autocomplete v-model="processStep.owner"
                              :items="availableOwners"
                              class="mt-1"
                              label="Select Owner"
                              item-text="fullName"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                              return-object
                              hide-details
                              autocomplete="off"
                              @change="updateOwner"
                              attach
              >
              </v-autocomplete>
            </div>
            <div>
              <v-btn text small v-if="userCanEdit && !processStep.owner || !processStep.owner.userId" class="change-owner-button"
                     :class="{'mt-2': displayChangeOwner}"
                     @click="displayChangeOwner = !displayChangeOwner">
                <span v-if="displayChangeOwner">cancel</span>
                <span v-else>add owner</span>
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
      <v-col cols="12" class="text-left pt-2 pb-4" v-if="userHasEventsFeature && (
        (processStepEvents && processStepEvents.length > 0) ||
        (processStep && processStep.projectProcessStepEvents && processStep.projectProcessStepEvents.length > 0)
      )">
        <div class="pps-subheader albatross-header-3">
          All Events
<!--          only allow events added to active process steps -->
          <v-autocomplete
            v-model="eventToAdd"
            v-if="processStep.processStepStatusTypeId === 1 && userCanAddEvents && processStepEvents && processStepEvents.length > 0"
            :items="processStepEvents"
            placeholder="Select Event to add"
            item-text="eventName"
            item-value="id"
            return-object
            dense
            class="toolbar-z-index-override mt-2"
            @input="addEvent()"
          ></v-autocomplete>
        </div>
        <div v-for="e in processStep.projectProcessStepEvents" :key="e.id" class="d-inline-block mr-4 mt-2">
          <EventButton
            :event="e"
            :project-id="projectId"
          />
        </div>
      </v-col>
      <v-col cols="12" class="text-left pt-4">
        <div class="pps-subheader albatross-header-3" v-if="processStep && processStep.actions && processStep.actions.length > 0">
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
        <div v-for="action in filteredActions" :key="action.id" class="d-inline-block ma-1">
          <ActionButton
            v-if="action.actionTypeId === 2 && !action.hideFromWeb"
            :action-result="action"
            :projectProcessStepId="parseInt(projectProcessStepId)"
            :handleOnComplete="handleActionCompleted"
            :handleOnCompleteError="handleOnCompleteError"
          />
          <v-btn
            v-else-if="action.actionTypeId === 1 && !action.hideFromWeb"
            @click="followMultipleLinks(action)"
          >
            {{ action.actionName }}
          </v-btn>
        </div>

        <v-row>
          <Links :projectProcessStepId="parseInt(projectProcessStepId)"
                 :project-id="parseInt(projectId)"
                 :processStepId="parseInt(processStepId)"/>
        </v-row>
      </v-col>
      <v-col cols="12" style="height: 0; padding: 0 !important;">
      <!-- this is here because i couldn't figure out how to make the toolbar sticky when in a col, and how to make the toolbar on a new row at all screen widths if not in a col-->
      </v-col>
      <v-toolbar flat color="secondary" class="cfg-detail-header fixed-toolbar px-3">
        <v-toolbar-title class="albatross-header-3">
          Process Step Details
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="setSplitColumnValue()" class="px-0">
            <v-icon v-if="!$store.state.project.manualColumnSplit" class="px-0">mdi-format-columns</v-icon>
            <v-icon v-else class="px-0">mdi-format-align-justify</v-icon>
          </v-btn>
          <v-btn v-if="projectProcessStepId && attachmentTypes && attachmentTypes.length > 0" text small @click="showUploadModal = true" class="px-0">
            <v-icon class="px-0">mdi-upload</v-icon>
          </v-btn>
          <v-dialog :width="uploadModalWidth" v-model="showUploadModal">
            <UploadDocumentModal @cancel="showUploadModal = false"
                                 :width="uploadModalWidth"
                                 :show-success-snackbar="true"
                                 :pps-id="parseInt(projectProcessStepId)"
                                 :attachment-types="attachmentTypes"></UploadDocumentModal>
          </v-dialog>
          <div>
            <v-btn
              color="primaryCustom"
              class="white--text mt-3 ml-2"
              :disabled="fieldsSaving || getReadOnly()"
              @click="[fieldsSaving = true, checkFields()]"
            >Save Fields
            </v-btn>
          </div>
        </v-toolbar-items>
      </v-toolbar>
      <v-col cols="12" class="text-left py-0 px-0">
        <!--    process field groups-->
        <v-col
          class="pt-0"
          v-for="(cfg, index) in customFieldGroups"
          :key="index"
        >
          <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar" dense>
            <v-toolbar-title>
              <!--  @TODO: @humes, once schedule tool is ready, have this link go to a more specific location in the schedule tool-->
              <v-btn small text v-if="cfg.eventId && $store.getters.userHasFeature('SCHEDULE')"
                     :to="`/schedule?projectProcessStepId=${projectProcessStepId}`">
                <v-icon>mdi-calendar</v-icon>
              </v-btn>
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
                  :use-field-ancillary-name="true"
                  :callback="populateDirtyCfvs"
                  :readonly="getReadOnly(field)"
                  :field="field"
                  :show-field-name="false"
                />
              </v-col>
              <v-col cols="6" v-if="$store.state.project.manualColumnSplit" class="pb-0 pt-2">
                <CustomValueInput
                  v-for="(field, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                  :key="idx"
                  :use-field-ancillary-name="true"
                  :callback="populateDirtyCfvs"
                  :readonly="getReadOnly(field)"
                  :field="field"
                  :show-field-name="false"
                />
              </v-col>
            </v-row>

          </v-card>
        </v-col>

      </v-col>

    </v-row>

    <ProjectProcessStepStatus
      :show-dialog="showMainDialog"
      :project-id="projectId"
      :project-process-step="processStep"
      :available-process-step-statuses="availableProcessStepStatuses"
      :limit-to-active="false"
      :limit-to-non-cancelled="true"
      :new-status-optional="processStep.processStepStatusTypeId !== 3"
      @updateStatus="updateMain"
      @dialogClosed="[showMainDialog = false, processStep.main = false, processStep.newStatusToUse = {NEW_STATUS_TO_USE}]"
    />
  </v-main>
  <v-main v-else>
    <SpinnerInline centered :size="50" color="primaryCustom"/>
  </v-main>
</template>

<script>

import {
  handleHidingGlobalLoader,
  followLink,
  getRequest,
  logError,
  getSnackbar,
  getRequestWithParams,
  postRequest
} from '@/helpers/helpers'
import ActionButton from './ActionButton'
import EventButton from './EventButton'
import {AppMutations} from '@/stores/AppStore'
import {ProjectMutations} from '@/stores/ProjectStore'
import {getCompanyAssignedToProcessStep, getStatusClass} from '@/services/processStepStatusTypeService'
import Attachments from '@/views/flow/components/Attachments'
import Links from '@/views/flow/components/Links'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import {getCustomFieldReadOnly, getEventCustomFieldReadOnly} from '@/services/customFieldService'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import ProjectProcessStepStatus from '@/views/flow/project/ProjectProcessStepStatus'
import SpinnerInline from '@/components/SpinnerInline'
import UploadDocumentModal from '@/views/flow/components/UploadDocumentModal'

const NEW_STATUS_TO_USE = {id: null}

export default {
  name: 'ProjectProcessStep',
  props: {
    project: Object
  },
  components: {
    ActionButton,
    EventButton,
    Links,
    Attachments,
    CustomValueInput,
    DatetimePickerInput,
    ProjectProcessStepStatus,
    SpinnerInline,
    UploadDocumentModal
  },
  data() {
    return {
      snackbar: {},
      unsavedFieldsModal: false,
      fieldsSaving: false,
      getStatusClass,
      showUploadModal: false,
      uploadModalWidth: 600,
      attachmentTypes: [],
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT'),
      userCanAddEvents: this.$store.getters.userHasFeatureAccessLevel('EVENTS', 'ADD'),
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADMIN'),
      userCanManage: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'MANAGE'),
      userIsScheduler: this.$store.state.user.details.userPositions?.some(p => p.scheduler),
      userHasEventsFeature: this.$store.getters.userHasFeature('EVENTS'),
      schedulerCanEdit: false,
      showRemoteSearch: false,
      mostRecentSearchWasRemote: false,
      schedulerLoading: true,
      timezone: this.$store.state.user.details.timezone.value,
      projectId: parseInt(this.$route.params.projectId),
      projectProcessStepId: this.$route.params.processStepId,
      processStepId: null,
      processStep: {},
      customFieldGroups: [],
      isProcessStepLoading: true,
      dirtyCfvs: [],
      toPath: null,
      query: {},
      navigationOverride: false,
      notes: [],
      displayChangeOwner: false,
      availableOwners: [],
      availableProcessStepStatuses: [],
      searchLoading: false,
      showMainDialog: false,
      NEW_STATUS_TO_USE,
      showUnperformableActions: false,
      processStepLoading: true,
      eventToAdd: {},
      processStepEvents: [],
      // windowWidth: window.innerWidth,
      // splitColumnMinWidth: 1700

    }
  },
  watch: {
    // whenever pps id changes, this function will run
    '$route.params.processStepId': async function () {
      // reset the selected item
      this.projectProcessStepId = this.$route.params.processStepId
      await this.loadAllPageDetails()
    },
  },
  mounted() {
    // window.addEventListener('resize', () => {
    //   this.windowWidth = window.innerWidth
    // })
  },
  async created() {
    await this.loadAllPageDetails()
  },
  computed: {
    filteredActions() {
      if (!this?.processStep?.actions) {
        return []
      }

      if (this.showUnperformableActions) {
        return this.processStep.actions
      } else {
        return this.processStep.actions.filter(a => a.canPerform === true)
      }
    }
  },
  beforeRouteUpdate(to, from, next) {
    // called when the route that renders this component is about to be updated via router-view update
    if (this.navigationOverride || this.dirtyCfvs.length === 0) {
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
    if (this.navigationOverride || this.dirtyCfvs.length === 0) {
      //set overide to false before navigation or else the confirmation dialog doesn't work if the next screen is also a pps
      this.navigationOverride = false
      next()
    } else {
      this.toPath = to.path
      this.query = to.query
      this.unsavedFieldsModal = true
    }
  },
  methods: {
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
      this.processStepLoading = true
      //if you add a new item to requests make sure it returns the request status
      const requests = [this.getCustomFieldGroups(), this.getProcessStep(true)]
      await Promise.all(requests).then(async (statusVals) => {
        let success = true
        statusVals.forEach(status => {
          if (status !== 200) {
            success = false
          }
        })
        if (success) {
          //this was causing issues if you moved too quickly between pps, now we load the pps first then other items when we have the process step id
          const req2 = [this.getProcessStepEvents(), this.getProcessStepAttachmentTypes()]
          await Promise.all(req2).then((statuses) => {
            let success2 = true
            statuses.forEach(status => {
              if (status !== 200) {
                success2 = false
              }
            })
            if (success2) {
              //this was causing issues if you moved too quickly between pps
              this.processStepLoading = false
            }
          })
        }
      })
    },
    goToPath(path, query) {
      //reset these values so the next screen works if also a pps
      this.unsavedFieldsModal = false
      this.$router.push({ path, query })
    },
    async getAvailableStatuses() {
      if (this.processStep?.processStepId) {
        try {
          const {data} = await getCompanyAssignedToProcessStep(this.processStep.processStepId)
          // const {data} = await getRequest(`/processStep/status`)
          this.availableProcessStepStatuses = data
        } catch (e) {
          this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          logError(e)
        }
      }
    },
    getProcessStep: async function (reloadAll) {
      try {
        this.processStepLoading = true
        const {data, status} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}`)
        this.processStep = {...data, newStatusToUse: {NEW_STATUS_TO_USE}}
        this.processStepId = this.processStep.processStepId
        // this.contactId = this.processStep.contactId
        this.$store.commit(ProjectMutations.SET_PPS, this.processStep)
        if(reloadAll) {
          //dont reload if only doing simple refresh
          this.getAvailableStatuses()
          this.getAvailableOwners()
        } else {
          //only set this to false when doing a simple refresh or else it will turn off loaders too soon
          this.processStepLoading = false
        }
        window.document.title = this.project?.id ? `${this.project.projectName} - ${this.processStep.processStepName}`
          : `${this.processStep.processStepName}`
        // return {data, status}
        return status
      } catch (e) {
        logError(e)
      }
    },
    async getCustomFieldGroups() {
      try {
        const {data, status} = await getRequestWithParams(`/customFieldValues/project/${this.projectId}/processStep/${this.projectProcessStepId}`, null, null, [])
        this.customFieldGroups = data
        return status
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
    async getAvailableOwners() {
      // this.$store.commit(AppMutations.SET_LOADING, true)
      if (this.processStep?.processStepProcessId) {
        try {
          const {data} = await getRequest(`/projectProcessStep/owners/${this.processStep.processStepProcessId}`, null, [])
          this.availableOwners = data

          // this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving List of Owners')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          // this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async checkFields() {
      //why is this still here?
      await this.updateFieldGroups()
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
        this.$emit('refresh-upcoming-pps')
        await this.getProcessStep(false)
        this.snackbar = getSnackbar('SUCCESS', 'Fields Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } finally {
        this.fieldsSaving = false
      }
    },
    populateDirtyCfvs(field) {
      //i think we could mostly remove this code now that round robin moved to events
      //some fields are for unique behavior and they dont need to be saved. this check should filter them out
      if (field.customFieldId) {
        let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
        if (!match) {
          this.dirtyCfvs.push(field)
        }
      }
    },
    async removeOwner() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.processStep.owner = {}
        const {status} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/owner`, this.processStep.owner)
        this.snackbar = getSnackbar('SUCCESS', 'Owner Removed')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
        const {status} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/owner`, this.processStep.owner)
        this.$emit('refresh-upcoming-pps')
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateMain(pps) {
      this.showMainDialog = false
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await postRequest(`/projectProcessStep/${pps.projectProcessStepId}/main`, pps.newStatusToUse)
        const status = await this.getProcessStep(false)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Unable to update to primary process step')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.processStep.main = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getReadOnly: function (field) {
      // if process_step admin then they can edit any process step fields, otherwise they can only edit active ones (1 = active)
      let fieldReadOnly = false
      if(null != field) {
        fieldReadOnly = getCustomFieldReadOnly(this.$store, field)
      }
      return (!this.userIsAdmin && this?.processStep?.processStepStatusTypeId !== 1)
        || fieldReadOnly
        || !this.userCanEdit
    },
    followMultipleLinks(action) {
      action?.processStepActionLinks?.forEach(link => {
        followLink(link.url, this.projectId)
      })
    },
    handleActionCompleted(data) {
      this.$emit('refresh-upcoming-pps')
      this.$emit('refresh-project-status')

      this.snackbar = getSnackbar('SUCCESS', 'Action Completed')
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      //if root status is not active then go back to project screen
      if(data?.processStepStatusTypeId !== 1) {
        //just in case something wasn't saved before running this action then still allow the nav
        this.navigationOverride = true
        this.$router.push({name: 'projectDetails', params: {projectId: this.projectId}})
      } else {
        this.getProcessStep(false)
        //have to reload the custom field groups as well in case the action populated something
        this.getCustomFieldGroups()
      }
    },
    handleOnCompleteError(actionId, errorMessage) {
      logError(`Failed to complete action with actionId: ${actionId}`)

      let message = 'Unable to Complete Action'

      // See if this is a java function failure and display a more specific error message
      if (errorMessage && typeof errorMessage === 'string') {
        let lastClause = errorMessage.substring(errorMessage.lastIndexOf('*** '))

        // This is specific to BR to display if a loan wasn't found. Genericize when we get "free time"
        if (lastClause.includes('Unable to locate application')) {
          message = 'Unable to locate loan application'
        }
      }

      this.snackbar = getSnackbar('ERROR', message)
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    },
    addEvent: async function () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.eventToAdd.id}`)
        this.$emit('refresh-upcoming-events')
        this.$router.push(`/project/${this.projectId}/processStep/${data.projectProcessStepId}/event/${data.id}`)
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
        const {data, status} = await getRequest(`/processStep/${this.processStepId}/event`, null, [])
        this.processStepEvents = data
        return status
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getProcessStepAttachmentTypes: async function () {
      //this gets the attachment types assigned to the process step so we know whether to show the upload button
      try {
        const {data, status} = await getRequest(`/attachmentType/processStepTypes/${this.processStepId}`, null, [])
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
#pps-toolbar .v-toolbar__content {
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

.cfg-detail-header .v-toolbar__title {
  font-size: 16px;
}

.owner-toolbar-items {
  flex-direction: column;
  text-align: right;
}
</style>
<style lang="scss" scoped>
.process-step-name {
  font-weight: normal;
  font-size: 1.25rem;
}

.owner-image {
  display: inline-block;
  vertical-align: top;
  margin-top: 5px;
}

owner-toolbar-tools {
  display: flex;
}

.owner-info {
  display: inline-block;
  font-size: 14px;
}

.owner-position {
  color: #9E9C9C;
}

.pps-subheader {
  width: 186px;
  margin-top: 5px;
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

<template>
  <v-main>

    <!--  screen header -->
    <v-row class="process-step-header">
      <v-col cols="8" class="text-left pl-5">
        <div class="project-title">
          {{ project.projectName}}
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
                          attach
          >
          </v-autocomplete>
        </div>
        <v-btn text x-small v-if="userCanEdit" class="change-owner-button"
               @click="displayChangeOwner = !displayChangeOwner">
          <span v-if="displayChangeOwner">cancel</span>
          <span v-else-if="processStep.owner && processStep.owner.userId">change</span>
          <span v-else>add owner</span>
        </v-btn>
        <v-btn text x-small v-if="userCanEdit && processStep.owner && processStep.owner.userId"
               class="change-owner-button" @click="removeOwner">
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
          :to="`/project/${projectId}/details`"
          id="qa-back-to-project">
          Back to Project
        </v-btn>
        <v-dialog width="500" v-model="unsavedFieldsModal">
          <v-card>
            <v-card-title
              class="text-h5 grey lighten-2"
              primary-title
            >
              Confirm
            </v-card-title>

            <v-card-text class="pt-4">
              You have unsaved fields.  Are you sure you want to continue without saving?
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
                @click="[navigationOverride = true, goToPath(toPath)]">
                Yes
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </v-col>

      <v-col cols="12" class="py-0 process-step-header">
        <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
          <v-toolbar-title class="px-5 process-step-name">
            {{ processStep.processStepName }}
            <span v-if="processStep.processStepStatusTypeId" :class="getStatusClass(processStep.processStepStatusTypeId)">({{ processStep.processStepStatusType }})</span>
<!--            <v-icon v-if="processStep.processStepStatusTypeId === 1"-->
<!--                    size="20" color="green">mdi-circle-slice-8-->
<!--            </v-icon>-->
            <v-dialog
              v-model="processStep.changeActiveConfirm"
              width="500">
              <template #activator="{ on }">
                <v-checkbox
                  class=""
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
                    @click="[processStep.changeActiveConfirm = false, showMainDialog = true]">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <div>
            <v-btn
              color="primaryCustom"
              class="white--text"
              :disabled="fieldsSaving"
              @click="[fieldsSaving = true, checkFields()]"
            >Save Process Step Fields
            </v-btn>
          </div>
        </v-toolbar>
      </v-col>
      <v-col cols="12" lg="6" class="text-left pt-0">
        <v-col class="pt-0">
        </v-col>
        <!--    process field groups-->
        <v-col
          class="pt-0"
          v-for="(cfg, index) in customFieldGroups"
          :key="index"
        >
          <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
            <v-toolbar-title>
              <!--  @TODO: @humes, once schedule tool is ready, have this link go to a more specific location in the schedule tool-->
              <v-btn small text v-if="cfg.eventId && $store.getters.userHasFeature('SCHEDULE')"
                     :to="`/schedule?projectProcessStepId=${projectProcessStepId}`">
                <v-icon>mdi-calendar</v-icon>
              </v-btn>
              {{cfg.groupName}}
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
            </v-toolbar-items>
          </v-toolbar>

          <v-card class="pa-3 square-card">
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
          <v-toolbar-title>
            Actions
            <v-btn
              class="back-btn show-unperformable-actions-btn"
              text
              :ripple="false"
              @click="showUnperformableActions = !showUnperformableActions"
            >
              {{ showUnperformableActions ? 'Hide Disabled' : 'Show All' }}
            </v-btn>
          </v-toolbar-title>
        </v-toolbar>
        <v-col v-for="action in filteredActions" :key="action.id" class="pt-0">
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
            {{action.actionName}}
          </v-btn>
        </v-col>
        <!--    <NotesAndActivity-->
        <!--      :showNotes="true"-->
        <!--      :showActivity="false"-->
        <!--      :notes="notes"-->
        <!--      :primaryId="parseInt(projectProcessStepId)"-->
        <!--      type="ProjectProcessStep"-->
        <!--    />-->

        <v-row>
          <Links :projectProcessStepId="parseInt(projectProcessStepId)"
                 :project-id="parseInt(projectId)"
                 :processStepId="parseInt(processStepId)"/>
        </v-row>
      </v-col>

    </v-row>

    <ProjectProcessStepStatus
        v-if="!isProcessStepLoading"
        :show-dialog="showMainDialog"
        :project-id="parseInt(projectId)"
        :project-process-step="processStep"
        :available-process-step-statuses="availableProcessStepStatuses"
        :limit-to-active="false"
        :limit-to-non-cancelled="true"
        :new-status-optional="processStep.processStepStatusTypeId !== 3"
        @updateStatus="updateMain"
        @dialogClosed="[showMainDialog = false, processStep.main = false, processStep.newStatusToUse = {NEW_STATUS_TO_USE}]"
    />
  </v-main>
</template>

<script>

  import {handleHidingGlobalLoader, followLink, getRequest, logError, getSnackbar, getRequestWithParams, postRequest} from '@/helpers/helpers'
  import ActionButton from './ActionButton'
  import {AppMutations} from '@/stores/AppStore'
  import {getAssignedToProcessStep} from '@/services/processStepStatusTypeService'
  import Attachments from '@/views/flow/components/Attachments'
  import Links from '@/views/flow/components/Links'
  import CustomValueInput from '@/views/flow/components/CustomValueInput'
  import {getCustomFieldReadOnly} from '@/services/customFieldService'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import moment from 'moment-timezone'
  import ProjectProcessStepStatus from '@/views/flow/project/ProjectProcessStepStatus'

  const NEW_STATUS_TO_USE = {id: null}

  export default {
    name: 'ProjectProcessStep',
    components: {
      ActionButton,
      Links,
      Attachments,
      CustomValueInput,
      DatetimePickerInput,
      ProjectProcessStepStatus,
    },
    data() {
      return {
        snackbar: {},
        unsavedFieldsModal: false,
        fieldsSaving: false,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT'),
        userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADMIN'),
        userCanManage: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'MANAGE'),
        userIsScheduler: this.$store.state.user.details.userPositions?.some(p => p.scheduler),
        userHasEventsFeature: this.$store.getters.userHasFeature('EVENTS'),
        schedulerCanEdit: false,
        showRemoteSearch: false,
        mostRecentSearchWasRemote: false,
        schedulerLoading: true,
        timezone: this.$store.state.user.details.timezone.value,
        projectId: this.$route.params.projectId,
        projectProcessStepId: this.$route.params.processStepId,
        processStepId: this.$route.query.processStepId,
        processStep: {},
        customFieldGroups: [],
        isProcessStepLoading: true,
        dirtyCfvs: [],
        toPath: null,
        navigationOverride: false,
        notes: [],
        project: {},
        projectLoading: true,
        displayChangeOwner: false,
        availableOwners: [],
        availableProcessStepStatuses: [],
        searchLoading: false,
        showMainDialog: false,
        NEW_STATUS_TO_USE,
        showUnperformableActions: false,
        processStepLoading: true
      }
    },
    async created() {
      this.getCustomFieldGroups()
      //per 9/24 request judson had us remove notes from process steps
      // this.getNotes()
      this.getProject()
      await this.getProcessStep()
      this.getAvailableOwners()
    },
    computed: {
      filteredActions () {
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
    beforeRouteLeave (to, from, next) {
      // called when the route that renders this component is about to
      // be navigated away from.
      // has access to `this` component instance.
      if (this.navigationOverride || this.dirtyCfvs.length === 0) {
        //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
        next()
      } else {
        this.toPath = to.path
        this.unsavedFieldsModal = true
      }
    },
    methods: {
      goToPath(path) {
        this.$router.push(path)
      },
      getStatusClass(rootTypeId) {
        return rootTypeId === 1 ? 'status-active' : rootTypeId === 2 ? 'status-complete' : 'status-cancelled'
      },
      async getAvailableStatuses() {
        if(this.processStep?.processStepId) {
          try {
            const {data} = await getAssignedToProcessStep(this.processStep.processStepId)
            // const {data} = await getRequest(`/processStep/status`)
            this.availableProcessStepStatuses = data
          } catch (e) {
            this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            logError(e)
          }
        }
      },
      getProcessStep: async function () {
        this.processStepLoading = true
        try {
          const {data, status} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}`)
          this.processStep = {...data, newStatusToUse: {NEW_STATUS_TO_USE}}
          this.processStepLoading = false
          this.getAvailableStatuses()
          window.document.title = this.project?.id ? `${this.project.projectName} - ${this.processStep.processStepName}`
            : `${this.processStep.processStepName}`
          return {data, status}
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
          const {data} = await getRequestWithParams(`/customFieldValues/project/${this.projectId}/processStep/${this.projectProcessStepId}`, null, null, [])
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
          this.projectLoading = true
          const {data} = await getRequest(`/project/${this.projectId}`)
          this.projectLoading = false
          this.project = data
          window.document.title = this.processStep?.processStepId ? `${this.project.projectName} - ${this.processStep.processStepName}`
            : `${this.project.projectName}`
        } catch (e) {
          this.projectLoading = false
          logError(e)
        }
      },
      async getAvailableOwners() {
        // this.$store.commit(AppMutations.SET_LOADING, true)
        if(this.processStep?.processStepProcessId) {
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
        }
      },
      // async updateProjectFieldGroups() {
      //   try {
      //     this.$store.commit(AppMutations.SET_LOADING, true)
      //     const {data} = await postRequest(`/customFieldValues/project/${this.projectId}`, this.customFieldGroups)
      //     this.customFieldGroups = data
      //   } catch (e) {
      //     logError(e)
      //     this.snackbar = getSnackbar('ERROR', 'Error Update Project Fields')
      //     this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      //   } finally {
      //     this.$store.commit(AppMutations.SET_LOADING, false)
      //   }
      // },
      async checkFields() {
        // let validSave = true
        // if (this.psHasEventCfg) {
        //   //get check all schedule event cfgs on the page
        //   this.customFieldGroups.forEach(cfg => {
        //     if (null != cfg.eventId) {
        //       let startField = cfg?.customFieldValues?.find(cfv => cfv.scheduleFieldTypeId === 1)
        //       let endField = cfg?.customFieldValues?.find(cfv => cfv.scheduleFieldTypeId === 2)
        //       let resourceField = cfg?.customFieldValues?.find(cfv => cfv.scheduleFieldTypeId === 3)
        //
        //       let startTime = startField?.timestampValue
        //       let endTime = endField?.timestampValue
        //       resource = resourceField?.intValue
        //       if ((startTime && !endTime) || (!startTime && endTime) || (resource && (!startTime && !endTime))) {
        //         this.snackbar = getSnackbar('ERROR', 'Start time and end time are required')
        //         this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        //         this.fieldsSaving = false
        //         validSave = false
        //       } else if (startTime && endTime && !moment(endTime).isAfter(startTime)) {
        //         this.snackbar = getSnackbar('ERROR', 'End time must be after start time')
        //         this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        //         this.fieldsSaving = false
        //         validSave = false
        //       } else if (this.psRequiresResource && startTime && endTime && !resource) {
        //         //resource required if times are saving
        //         this.snackbar = getSnackbar('ERROR', 'Resource is required')
        //         this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        //         this.fieldsSaving = false
        //         validSave = false
        //       }
        //     }
        //   })
        // }

        // if (validSave) {
        //now that round robin is not in the pps, we can just directly update the fields
        await this.updateFieldGroups()
        // }
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
          await this.getProcessStep()
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
          const {status} = await this.getProcessStep()
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
        return (!this.userIsAdmin && this?.processStep?.processStepStatusTypeId !== 1)
          || getCustomFieldReadOnly(this.$store, field)
          || !this.userCanEdit
      },
      followMultipleLinks(action) {
        action?.processStepActionLinks?.forEach(link => {
          followLink(link.url, this.projectId)
        })
      },
      handleActionCompleted() {
        this.$router.push({name: 'projectDetails', params: {projectId: this.projectId}})
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

  .status-active {
    color: green;
    font-weight: normal;
    font-size: 12px;
  }

  .status-complete {
    color: cornflowerblue;
    font-weight: normal;
    font-size: 12px;
  }

  .status-cancelled {
    color: darkred;
    font-weight: normal;
    font-size: 12px;
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

    .show-unperformable-actions-btn {
      margin-bottom: 2px;
      font-size: 12px;
    }
  }
</style>

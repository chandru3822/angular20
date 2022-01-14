<template>
<v-menu
    v-model="displayDropdown"
    bottom
    offset-y
    min-width="350"
    :close-on-content-click="false"
>

  <template #activator="{on}">
    <v-btn text class="" x-small v-on="on" @click="[ getSteps() ]">
      <v-icon>add</v-icon>
    </v-btn>
  </template>

  <v-card class="pa-5">
<!--    cant change this part cuz the steps used are different depending on if the user is an admin or not -->
    <v-autocomplete v-model="selectedStep"
                    :items="steps"
                    label="Process Steps"
                    item-text="processStepName"
                    item-value="id"
                    placeholder="Select one..."
                    @input="[getCancelledStatuses(), getActiveStatusesAssignedToStep() ]"
                    return-object
                     />
    <v-autocomplete v-model="newPps.initialCompanyProcessStepStatusTypeId"
                    v-if="null != selectedStep"
                    :items="activeStatusesAssignedToStep"
                    label="Set initial status to:"
                    item-text="processStepStatusType"
                    item-value="id"
                    placeholder="Select one..."
                    attach/>
    <v-autocomplete v-model="newPps.existingCompanyProcessStepStatusTypeId"
                    v-if="null != selectedStep"
                    :items="cancelledCompanyStatuses"
                    label="Set status of existing active steps of the same type to:"
                    item-text="processStepStatusType"
                    item-value="id"
                    placeholder="Select one..."
                    attach/>
    <v-btn
        class="add-process-step-btn primary"
        :disabled="selectedStep == null || !newPps.existingCompanyProcessStepStatusTypeId || !newPps.initialCompanyProcessStepStatusTypeId"
        @click="addStep"
    >
      Create
    </v-btn>
  </v-card>
</v-menu>
</template>

<script>
import { handleHidingGlobalLoader, getRequestWithParams, getSnackbar, logError, postRequest} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import {getActiveAssignedToProcessStep, getCancelledCompanyStatusTypesAssignedToProcessStep} from '@/services/processStepStatusTypeService'

export default {
  name: 'AddProcessStep',
  props: {
    admin: {
      type: Boolean,
      default: false
    },
    projectId: {
      type: Number
    },
    processId: {
      type: Number
    },
    contactId: Number
  },

  data () {
    return {
      snackbar: {},
      displayDropdown: false,
      fetchingSteps: false,
      steps: [],
      newPps: {},
      selectedStep: null,
      fetchingStatuses: false,
      cancelledCompanyStatuses: [],
      activeStatusesAssignedToStep: [],
    }
  },
  created () {
    // this.getSteps()
    // this.getCancelledStatuses()
  },
  methods: {
    getSteps: async function () {
      if(!this.displayDropdown) {
        try {
          const url = (this.admin) ? `/processes/${this.processId}` : `/processes/${this.processId}/nonAdminProcessStepsForProcess`
          this.fetchingSteps = true
          const {data} = await getRequestWithParams(url, {
            params: {
              projectId: this.projectId,
            }
          })
          this.steps = (this.admin) ? data.processStepProcesses : data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching process steps')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.fetchingSteps = false
        }
      } else {
        this.selectedStep = null
        this.newPps = {}
      }
    },
    async getActiveStatusesAssignedToStep() {
      this.activeStatusesAssignedToStep = []
      try {
        let stepId = (this.admin) ? this.selectedStep.processStepId : this.selectedStep.id
        const {data} = await getActiveAssignedToProcessStep(stepId)
        this.activeStatusesAssignedToStep = data
        if (data?.length === 1) {
          this.newPps.initialCompanyProcessStepStatusTypeId = data[0].id
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching process step statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    getCancelledStatuses: async function () {
      this.cancelledCompanyStatuses = []
      try {
        let stepId = (this.admin) ? this.selectedStep.processStepId : this.selectedStep.id
        if(stepId) {
          this.fetchingStatuses = true
          const {data} = await getCancelledCompanyStatusTypesAssignedToProcessStep(stepId)
          this.cancelledCompanyStatuses = data
          if(data?.length === 1) {
            this.newPps.existingCompanyProcessStepStatusTypeId = data[0].id
          }
        }
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching process step statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.fetchingSteps = false
      }
    },
    addStep: async function () {
      try {
        let psId = (this.admin) ? this.selectedStep.processStepId : this.selectedStep.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await postRequest(`/projectProcessStep/initialStatus/${this.newPps.initialCompanyProcessStepStatusTypeId}/existingStatus/${this.newPps.existingCompanyProcessStepStatusTypeId}`, {
          projectId: this.projectId,
          processStepId: psId,
          main: true
        })

        this.selectedStep = null
        this.newPps = {}
        this.displayDropdown = false
        handleHidingGlobalLoader(this, status)
        this.$emit('step-added')
        //the data returned is the ppsId
        this.$router.push(`/project/${this.projectId}/processStep/${data}?processStepId=${psId}&contactId=${this.contactId}`)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding new process step')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style lang="scss">
.add-process-step-btn > .v-btn__content {
  color: white !important;
}
</style>

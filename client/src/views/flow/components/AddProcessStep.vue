<template>
<v-menu
    v-model="displayDropdown"
    bottom
    offset-y
    :close-on-content-click="false"
>

  <template #activator="{on}">
    <v-btn text class="" small v-on="on" @click="[ getSteps(), getCancelledStatuses() ]">
      <v-icon>add</v-icon>
    </v-btn>
  </template>

  <v-card class="pa-5">
    <v-autocomplete v-model="selectedStep"
                    :items="steps"
                    label="Process Steps"
                    item-text="processStepName"
                    item-value="id"
                    placeholder="Select one..."
                    return-object/>
    <v-autocomplete v-model="selectedStatus"
                    :items="cancelledCompanyStatuses"
                    label="Cancelled Status To Use"
                    item-text="processStepStatusType"
                    item-value="id"
                    placeholder="Select one..."
                    return-object/>
    <v-btn
        class="add-process-step-btn primary"
        :disabled="selectedStep === null || selectedStatus === null"
        @click="addStep"
    >
      Create
    </v-btn>
  </v-card>
</v-menu>
</template>

<script>
import {getRequest, getRequestWithParams, getSnackbar, logError, postRequest} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import {getCancelledCompanyStatusTypes} from '@/services/processStepStatusTypeService'


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
    }
  },

  data () {
    return {
      snackbar: {},
      displayDropdown: false,
      fetchingSteps: false,
      steps: [],
      selectedStep: null,
      fetchingStatuses: false,
      cancelledCompanyStatuses: [],
      selectedStatus: null
    }
  },
  created () {
    // this.getSteps()
    // this.getCancelledStatuses()
  },
  methods: {
    getSteps: async function () {
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
    },
    getCancelledStatuses: async function () {
      try {
        this.fetchingStatuses = true
        const {data} = await getCancelledCompanyStatusTypes(this.projectId)
        this.cancelledCompanyStatuses = data
        if(data?.length === 1) {
          this.selectedStatus = data[0]
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
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/projectProcessStep/${this.selectedStatus.id}`, {
          projectId: this.projectId,
          processStepId: (this.admin) ? this.selectedStep.processStepId : this.selectedStep.id,
          main: true
        })

        this.selectedStep = null
        this.selectedStatus = null
        this.displayDropdown = false
        this.$emit('step-added')
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding new process step')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
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

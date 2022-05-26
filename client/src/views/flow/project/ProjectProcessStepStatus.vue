<template>
<v-dialog
  v-model="internalShowDialog"
  @click:outside="$emit('dialogClosed')"
  width="500">
  <v-card>
    <v-card-title
      class="text-h5 grey lighten-2"
      primary-title
    >
      Change Process Step Status
    </v-card-title>

    <v-card-text class="mt-2">
      <v-autocomplete
        v-model="projectProcessStep.newStatusToUse"
        :items="statuses"
        item-text="processStepStatusType"
        item-value="companyProcessStepStatusTypeId"
        :label="`Status To Change To (${newStatusOptional === true ? 'Optional' : 'Required'})`"
        return-object
        class="mt-2"
        autocomplete="off"
        attach
      />
      <div class="error-text"
        v-if="projectProcessStep.main && projectProcessStep.newStatusToUse && projectProcessStep.newStatusToUse.processStepStatusTypeId === 3">
        WARNING: Setting the Primary step to a Cancelled status will automatically remove the Primary flag from this Project Process Step.
      </div>

      <div v-if="(projectProcessStep.newStatusToUse && projectProcessStep.newStatusToUse.processStepStatusTypeId !== 3) || newStatusOptional === true">
        Please select what to do with all existing Active steps of the same type.
        <v-autocomplete
          v-if="projectProcessStep.newStatusToUse"
          v-model="projectProcessStep.newStatusToUse.cancelledCompanyProcessStepStatusTypeId"
          :items="cancelledCompanyStatuses"
          label="Status To Use For Existing (Required)"
          item-text="processStepStatusType"
          item-value="id"
          attach
        />
      </div>
    </v-card-text>

    <v-divider></v-divider>

    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn
        @click="$emit('dialogClosed')">
        Cancel
      </v-btn>
      <v-btn
        :disabled="(!newStatusOptional && (!projectProcessStep.newStatusToUse || !projectProcessStep.newStatusToUse.id)) ||
                  (projectProcessStep.newStatusToUse.processStepStatusTypeId !== 3 &&
                      !projectProcessStep.newStatusToUse.cancelledCompanyProcessStepStatusTypeId)"
        color="primary"
        text
        @click="$emit('updateStatus', projectProcessStep)">
        Save
      </v-btn>
    </v-card-actions>
  </v-card>
</v-dialog>
</template>

<script>
import {getCancelledCompanyStatusTypesAssignedToProcessStep} from '@/services/processStepStatusTypeService'
import {getSnackbar, logError} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'

export default {
  name: 'ProjectProcessStepStatus',
  props: {
    projectId: Number,
    projectProcessStep: Object,
    availableProcessStepStatuses: Array,
    limitToNonCancelled: {
      type: Boolean,
      default: false
    },
    limitToActive: {
      type: Boolean,
      default: false
    },
    showDialog: {
      type: Boolean,
      default: false
    },
    newStatusOptional: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      cancelledCompanyStatuses: [],
      internalShowDialog: this.showDialog
    }
  },
  mounted() {
    this.getCancelledStatuses()
  },
  watch: {
    showDialog: function(val) {
      this.internalShowDialog = val
    },
    projectProcessStep: function () {
      //need to re-get cancelled statuses for the correct process step when it changes
      this.getCancelledStatuses()
    }
  },
  computed: {
    statuses() {
      if (this.limitToActive === true) {
        return this.availableProcessStepStatuses.filter(step => step.processStepStatusTypeId === 1)
      } else if (this.limitToNonCancelled) {
        return this.availableProcessStepStatuses.filter(step => step.processStepStatusTypeId !== 3)
      }
      return this.availableProcessStepStatuses
    }
  },
  methods: {
    async getCancelledStatuses() {
      if (this.cancelledCompanyStatuses?.length === 0) {
        try {
          if(this.projectProcessStep.processStepId) {
            const {data} = await getCancelledCompanyStatusTypesAssignedToProcessStep(this.projectProcessStep.processStepId)
            this.cancelledCompanyStatuses = data
          }
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching process step statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
  }
}
</script>

<style scoped>

</style>

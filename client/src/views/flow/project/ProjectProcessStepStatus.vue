<template>
<v-dialog
  v-model="internalShowDialog"
  width="500">
  <v-card>
    <v-card-title
      class="headline grey lighten-2"
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
        label="Status To Change To"
        return-object
        class="mt-2"
      />
      <div v-if="projectProcessStep.newStatusToUse.processStepStatusTypeId === 1">
        When setting a process step to an ACTIVE status. You must select what to do with all existing Active steps of the same type.
        <v-autocomplete
          v-model="projectProcessStep.newStatusToUse.cancelledCompanyProcessStepStatusTypeId"
          :items="cancelledCompanyStatuses"
          label="Status To Use For Existing"
          item-text="processStepStatusType"
          item-value="id"
        />
      </div>
    </v-card-text>

    <v-divider></v-divider>

    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn
        @click="$emit('dialogClosed')">
        No
      </v-btn>
      <v-btn
        :disabled="!projectProcessStep.newStatusToUse || (projectProcessStep.newStatusToUse.processStepStatusTypeId === 1 && !projectProcessStep.newStatusToUse.cancelledCompanyProcessStepStatusTypeId)"
        color="primaryCustom"
        text
        @click="$emit('updateStatus', projectProcessStep)">
        Yes
      </v-btn>
    </v-card-actions>
  </v-card>
</v-dialog>
</template>

<script>
import {getCancelledCompanyStatusTypes} from '@/services/processStepStatusTypeService'
import {getSnackbar, logError} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'

export default {
  name: 'ProjectProcessStepStatus',
  props: {
    projectId: Number,
    projectProcessStep: Object,
    availableProcessStepStatuses: Array,
    limitToActive: {
      type: Boolean,
      default: false
    },
    showDialog: {
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
    }
  },
  computed: {
    statuses() {
      if (this.limitToActive === true) {
        return this.availableProcessStepStatuses.filter(step => step.processStepStatusTypeId === 1)
      }
      return this.availableProcessStepStatuses
    }
  },
  methods: {
    async getCancelledStatuses() {
      if (this.cancelledCompanyStatuses?.length === 0) {
        try {
          const {data} = await getCancelledCompanyStatusTypes(this.projectId)
          this.cancelledCompanyStatuses = data
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
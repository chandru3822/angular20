<template>
  <ConfirmationDialog :open-dialog="internalShowDialog"
                      :disable-confirm="(!newStatusOptional && (!projectProcessStep.newStatusToUse || !projectProcessStep.newStatusToUse.id)) ||
                  (projectProcessStep.newStatusToUse.processStepStatusTypeId !== 3 &&
                      !projectProcessStep.newStatusToUse.cancelledCompanyProcessStepStatusTypeId)"
                      @confirm="$emit('updateStatus', projectProcessStep)"
                      @close-dialog="$emit('dialogClosed')"
  >
    <template v-slot:title>Change Process Step Status</template>
    <a-autocomplete
        v-model="projectProcessStep.newStatusToUse"
        :items="statuses"
        item-title="processStepStatusType"
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
      <a-autocomplete
          v-if="projectProcessStep.newStatusToUse"
          v-model="projectProcessStep.newStatusToUse.cancelledCompanyProcessStepStatusTypeId"
          :items="cancelledCompanyStatuses"
          label="Status To Use For Existing (Required)"
          item-title="processStepStatusType"
          item-value="id"
          attach
      />
    </div>
    <template v-slot:no>cancel</template>
    <template v-slot:yes>save</template>
  </ConfirmationDialog>
</template>

<script setup>
import {getCancelledCompanyStatusTypesAssignedToProcessStep} from '@/services/processStepStatusTypeService'
import { logError} from '@/helpers/helpers'

import ConfirmationDialog from "@/components/ConfirmationDialog";

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
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
})
const { projectId, projectProcessStep, availableProcessStepStatuses, limitToNonCancelled,
  limitToActive, showDialog, newStatusOptional } = toRefs(props)

const cancelledCompanyStatuses = ref([])
const newStatus = ref({})
const internalShowDialog = ref(showDialog.value)

onMounted(() => {
  getCancelledStatuses()

})

watch(showDialog, async(val) => {
  internalShowDialog.value = val
})

watch(projectProcessStep, async() => {
  //need to re-get cancelled statuses for the correct process step when it changes
  cancelledCompanyStatuses.value = [] //clear out any existing cancelled statuses to make sure we re-fetch for the new process
  getCancelledStatuses()
})

const statuses = computed(() => {
  if (limitToActive.value === true) {
    return availableProcessStepStatuses.value.filter(step => step.processStepStatusTypeId === 1)
  } else if (limitToNonCancelled.value) {
    return availableProcessStepStatuses.value.filter(step => step.processStepStatusTypeId !== 3)
  }
  return availableProcessStepStatuses.value
})

const getCancelledStatuses = async() => {
  if (cancelledCompanyStatuses.value?.length === 0) {
    try {
      if(projectProcessStep.value.processStepId) {
        const {data} = await getCancelledCompanyStatusTypesAssignedToProcessStep(projectProcessStep.value.processStepId)
        cancelledCompanyStatuses.value = data
      }
    } catch (e) {
      logError(e)
      snackbar('ERROR', 'Error fetching process step statuses')

    }
  }
}
</script>

<style scoped>

</style>

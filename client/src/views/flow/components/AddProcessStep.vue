<template>
  <v-menu
      v-model="displayDropdown"
      bottom
      offset-y
      min-width="350"
      :close-on-content-click="false"
      style="z-index: 10"
  >
    <template #activator="{on}">
      <a-btn
          :variant="outlined ? 'outlined' : 'text'"
          id="qa-add-process-step-button"
          color="primary"
          class="text-capitalize add-process-step-menu-btn one-hunned"
          :activation-handler="on"
          @click="getSteps()"
          @blur="clear()"
          :text="title != null ? title : ''"
          prepend-icon="add"
      ></a-btn>
    </template>

    <v-card class="pa-5">
      <!--    cant change this part cuz the steps used are different depending on if the user is an admin or not -->
      <a-autocomplete v-model="selectedStep"
                      :items="steps"
                      label="Process Steps"
                      item-title="processStepName"
                      item-value="id"
                      placeholder="Select one..."
                      @input="[getCancelledStatuses(), getActiveStatusesAssignedToStep() ]"
                      return-object
      />
      <a-autocomplete v-model="newPps.initialCompanyProcessStepStatusTypeId"
                      :disabled="null === selectedStep"
                      :items="activeStatusesAssignedToStep"
                      label="Set initial status to:"
                      item-title="processStepStatusType"
                      item-value="id"
                      placeholder="Select one..."
                      attach/>
      <a-autocomplete v-model="newPps.existingCompanyProcessStepStatusTypeId"
                      :disabled="null === selectedStep"
                      :items="cancelledCompanyStatuses"
                      label="Set status of existing active steps of the same type to:"
                      item-title="processStepStatusType"
                      item-value="id"
                      placeholder="Select one..."
                      attach/>
      <a-btn
          class="add-process-step-btn primary"
          :disabled="selectedStep == null || !newPps.existingCompanyProcessStepStatusTypeId || !newPps.initialCompanyProcessStepStatusTypeId"
          @click="addStep"
          color="unset"
          text="Create"
      ></a-btn>
    </v-card>
  </v-menu>
</template>

<script setup>
import { handleHidingGlobalLoader, getRequestWithParams,  logError, postRequest} from '@/helpers/helpers'

import {getActiveAssignedToProcessStep, getCancelledCompanyStatusTypesAssignedToProcessStep} from '@/services/processStepStatusTypeService'

import { getCurrentInstance, computed, ref, toRefs, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const vuetify = vueInstance.$vuetify

const props = defineProps({
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
  contactId: Number,
  title: String,
  showBtnText: {
    type: Boolean,
    default: false
  },
  largeBtn: {
    type: Boolean,
    default: false
  },
  outlined: {
    type: Boolean,
    default: false
  }
})
const { admin, projectId, processId, contactId, title, showBtnText, largeBtn, outlined } = toRefs(props)

const emit = defineEmits(['step-added'])

const displayDropdown = ref(false)
const fetchingSteps = ref(false)
const steps = ref([])
const newPps = ref({})
const selectedStep = ref(null)
const fetchingStatuses = ref(false)
const cancelledCompanyStatuses = ref([])
const activeStatusesAssignedToStep = ref([])

const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const getSteps = async () => {
  if(!displayDropdown.value) {
    try {
      const url = (admin.value) ? `/processes/${processId.value}` : `/processes/${processId.value}/nonAdminProcessStepsForProcess`
      fetchingSteps.value = true
      const {data} = await getRequestWithParams(url, {
        params: {
          projectId: projectId.value,
        }
      })
      steps.value = (admin.value) ? data.processStepProcesses : data.filter(ps => {
        //the query for nonAdminProcessSteps filters on 'non_admin_add is true' so we don't have to check that here
        let allowAdd = false
        if(ps.nonAdminAddWhiteListedPositions?.length > 0) {
          //do any of the user's active positions match the white listed positions
          allowAdd = ps.nonAdminAddAllow ? userStore.userHasAnyPosition(ps.nonAdminAddWhiteListedPositions?.map(wlp => wlp.positionId)) :
              !userStore.userHasAnyPosition(ps.nonAdminAddWhiteListedPositions?.map(wlp => wlp.positionId))
        } else {
          //allow them to add if nonAdminAdd is true and it is set to a deny list and there are no positions
          allowAdd = ps.nonAdminAdd && !ps.nonAdminAddAllow
        }
        return allowAdd
      })
    } catch (e) {
      logError(e)
      appStore.showSnack('ERROR', 'Error fetching process steps')

    } finally {
      fetchingSteps.value = false
    }
  } else {
    clear()
  }
}
const getActiveStatusesAssignedToStep = async() => {
  activeStatusesAssignedToStep.value = []
  try {
    let stepId = (admin.value) ? selectedStep.value.processStepId : selectedStep.value.id
    const {data} = await getActiveAssignedToProcessStep(stepId, !admin.value)
    activeStatusesAssignedToStep.value = data
    if (data?.length === 1) {
      newPps.value.initialCompanyProcessStepStatusTypeId = data[0].id
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching process step statuses')

  }
}
const getCancelledStatuses = async () => {
  cancelledCompanyStatuses.value = []
  try {
    let stepId = (admin.value) ? selectedStep.value.processStepId : selectedStep.value.id
    if(stepId) {
      fetchingStatuses.value = true
      const {data} = await getCancelledCompanyStatusTypesAssignedToProcessStep(stepId, !admin.value)
      cancelledCompanyStatuses.value = data
      if(data?.length === 1) {
        newPps.value.existingCompanyProcessStepStatusTypeId = data[0].id
      }
    }
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching process step statuses')

  } finally {
    fetchingSteps.value = false
  }
}
const addStep = async () => {
  try {
    let psId = (admin.value) ? selectedStep.value.processStepId : selectedStep.value.id
    appStore.loading = true
    const {data, status} = await postRequest(`/projectProcessStep/initialStatus/${newPps.value.initialCompanyProcessStepStatusTypeId}/existingStatus/${newPps.value.existingCompanyProcessStepStatusTypeId}`, {
      projectId: projectId.value,
      processStepId: psId,
      main: true
    })

    selectedStep.value = null
    newPps.value = {}
    displayDropdown.value = false
    handleHidingGlobalLoader( status)
    emit('step-added')
    //the data returned is the ppsId
    router.push(`/project/${projectId.value}/processStep/${data}`)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error adding new process step')

    appStore.loading = false
  }
}
const clear = () => {
  selectedStep.value = null
  newPps.value = {}
}

</script>

<style lang="scss">
#side-panel-expansion-panel-container {
  button.add-process-step-menu-btn {
    border: thin solid var(--v-primary-base);
  }
}
</style>

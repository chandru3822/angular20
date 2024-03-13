<template>
  <div>

    <v-row v-if="userIsAdmin" class="admin-body">

      <v-col cols="12" class="px-6 pt-6 headline-small">

        <v-toolbar flat class="project-header">
          <v-toolbar-title>Assigned Process Steps</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AddProcessStep
                v-if="processId"
                :admin="true"
                title="Add Process Step"
                :project-id="projectId"
                :process-id="processId"
                @step-added="getProjectProcessSteps"
            />
          </v-toolbar-items>
        </v-toolbar>
      </v-col>

      <v-col cols="12" class="px-6">
        <v-data-table
            class="elevation-1 table-striped"
            :headers="displayedHeaders"
            :items="projectProcessSteps"
            fixed-header
            multi-sort
            dense
            :sort-by="['processStepName', 'lastUpdated']"
            :sort-desc="[false, true]"
            hide-default-footer
            :loading="isProjectProcessStepsLoading"
            disable-pagination
        >

          <template #no-data>
            <span class="default-text-color">No available process steps</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available process steps</span>
          </template>

          <template #item.projectProcessStepId="{item: projectProcessStep}" class="text-left">
            <router-link
                :to="`/project/${projectId}/processStep/${projectProcessStep.projectProcessStepId}`">
              {{ projectProcessStep.projectProcessStepId }}
            </router-link>
          </template>
          <template #item.processStepName="{item: projectProcessStep}" class="text-left">{{ projectProcessStep.processStepName }}</template>
          <template #item.owner.fullName="{item: projectProcessStep}" class="text-left">{{ getOwnerName(projectProcessStep) }}</template>
          <template #item.lastUpdated="{item: projectProcessStep}" class="text-left">{{ projectProcessStep.lastUpdated }}</template>
          <template #item.processStepStatusType="{item: projectProcessStep}" class="text-left">
            <div>
              {{ projectProcessStep.processStepStatusType }}
              <AlbatrossButton
                  variant="text"
                  color="primary"
                  @click="[showStatusDialog = true, showMainDialog = false, alteringPrimaryFlag = false, selectedPps = projectProcessStep, getAvailableStatuses(projectProcessStep)]"
                  prepend-icon="edit"
              ></AlbatrossButton>
            </div>
          </template>
          <template #item.main="{item: projectProcessStep}" class="text-left">
            <v-dialog
                v-model="projectProcessStep.changeActiveConfirm"
                width="500">
              <template #activator="{ on }">
                <v-checkbox
                    v-on="on"
                    v-model="projectProcessStep.main"
                    :disabled="projectProcessStep.main"
                />
              </template>
              <v-card>
                <v-card-title
                    class="text-h5 grey lighten-2"
                    primary-title>
                  Confirm
                </v-card-title>

                <v-card-text class="pt-4">
                  Modifying the primary flag will run any automatic actions that have not yet been run where the
                  criteria is met using values from the new active process step.
                  Are you sure you want to set <strong>{{ projectProcessStep.processStepName }} -
                  {{ projectProcessStep.projectProcessStepId }}</strong> to Primary?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <AlbatrossButton
                      @click="[projectProcessStep.changeActiveConfirm = false, alteringPrimaryFlag = false, projectProcessStep.main = false]"
                      color="unset"
                      text="No"
                  ></AlbatrossButton>
                  <AlbatrossButton
                      color="primary"
                      variant="text"
                      @click="[showSelectedPps = false, showMainDialog = true, alteringPrimaryFlag = true, projectProcessStep.changeActiveConfirm = false, showStatusDialog = true, selectedPps = projectProcessStep, getAvailableStatuses(selectedPps)]"
                      text="Yes"
                  ></AlbatrossButton>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </template>
          <template #item.historyHere="{item: projectProcessStep}" class="text-left">
            <AlbatrossButton
                size="small"
                variant="text"
                color="primary"
                @click="getPpsHistory(projectProcessStep)"
                prepend-icon="mdi-chart-timeline"
            ></AlbatrossButton>
          </template>

        </v-data-table>
        <ConfirmationDialog :open-dialog="showPpsHistory" hide-confirm :width="1000" @close-dialog="[showPpsHistory = false, selectedPpsHistory = []]">
          <template v-slot:title><span class="pb-1">Project Process Step History</span></template>
          <PpsHistoryTable :selected-pps-history="selectedPpsHistory"></PpsHistoryTable>
          <template v-slot:no>Close</template>
        </ConfirmationDialog>
      </v-col>
    </v-row>

    <ProjectProcessStepStatus
        v-if="selectedPps && !alteringPrimaryFlag"
        :show-dialog="showStatusDialog"
        :project-id="projectId"
        :project-process-step="selectedPps"
        :available-process-step-statuses="availableProcessStepStatuses"
        @updateStatus="updateStatus"
        @dialogClosed="showStatusDialog = false"
    />

    <ProjectProcessStepStatus
        v-if="showSelectedPps && alteringPrimaryFlag"
        :show-dialog="showMainDialog"
        :project-id="projectId"
        :project-process-step="selectedPps"
        :available-process-step-statuses="availableProcessStepStatuses"
        :limit-to-active="false"
        :limit-to-non-cancelled="true"
        :new-status-optional="selectedPps.selectedProcessStepStatusType.processStepStatusTypeId !== 3"
        @updateStatus="updateMain"
        @dialogClosed="[showMainDialog = false, selectedPps.main = false, selectedPps.newStatusToUse = {NEW_STATUS_TO_USE}]"
    />
  </div>
</template>

<script setup>

import {
  handleHidingGlobalLoader,
  getRequest,
  getRequestWithParams,
  postRequest,
  deleteRequest,

  logError
} from '@/helpers/helpers'
import {getCompanyAssignedToProcessStep, getCancelledCompanyStatusTypes} from '@/services/processStepStatusTypeService'
import {v4 as uuid} from 'uuid'
import AddProcessStep from '@/views/flow/components/AddProcessStep.vue'
import PpsHistoryTable from '@/views/flow/components/PpsHistoryTable.vue'
import ProjectProcessStepStatus from '@/views/flow/project/ProjectProcessStepStatus.vue'
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, computed, toRefs, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify

const NEW_STATUS_TO_USE = {id: null}

const props = defineProps({
  processId: Number
})
const { processId } = toRefs(props)

const project = ref({})
const alteringPrimaryFlag = ref(false)
const projectProcessSteps = ref([])
const showPpsHistory = ref(false)
const selectedPpsHistory = ref([])
const displayDropdown = ref(false)
const displayChangeOwner = ref(false)
const availableOwners = ref([])
const cancelledCompanyStatuses = ref([])
const availableProcessStepStatuses = ref([])
const isProjectProcessStepsLoading = ref(false)
const selectedNewProjectProcessStep = ref(null)
const headers = ref([
  {text: 'ID', value: 'projectProcessStepId', show: true},
  {text: 'Type', value: 'processStepName', show: true},
  {text: 'Owner', value: 'owner.fullName', show: true},
  {text: 'Last Activity', value: 'lastUpdated', show: true},
  {text: 'Status', value: 'processStepStatusType', show: true},
  {text: 'Primary', value: 'main', show: true},
  {text: 'History', value: 'historyHere', show: true},
])
const showStatusDialog = ref(false)
const showMainDialog = ref(false)
const selectedPps = ref(null)
const showSelectedPps = ref(false)

const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'DELETE')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')
})
const displayedHeaders = computed(() => {
  return headers.value.filter(header => header.show)
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

onMounted(() => {
  getProjectProcessSteps()
})

const getProjectProcessSteps = async () => {
  try {
    isProjectProcessStepsLoading.value = true
    const {data, status} = await getRequest(`/project/${projectId.value}/processSteps`, null, [])
    projectProcessSteps.value = data.map(step => {
      // step.selectedProcessStepStatusType = availableProcessStepStatuses.value.find(status => status.id === step.companyProcessStepStatusTypeId)
      step.newStatusToUse = {NEW_STATUS_TO_USE}
      return step
    })
    return {status}
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching process steps')

  } finally {
    isProjectProcessStepsLoading.value = false
  }
}
const getAvailableStatuses = async(pps) => {
  showSelectedPps.value = false
  try {
    const {data} = await getCompanyAssignedToProcessStep(pps.processStepId)
    availableProcessStepStatuses.value = data
    if (availableProcessStepStatuses.value?.length > 0) {
      let match = availableProcessStepStatuses.value.find(status => status.id === pps.companyProcessStepStatusTypeId)
      if (match) {
        selectedPps.value.selectedProcessStepStatusType = match
        showSelectedPps.value = true
      }
    }
  } catch (e) {
    snackbar('ERROR', 'Error fetching available process step statuses')

    logError(e)
  }
}
const getCancelledStatuses = async() => {
  if (cancelledCompanyStatuses.value?.length === 0) {
    try {
      const {data} = await getCancelledCompanyStatusTypes(projectId.value)
      cancelledCompanyStatuses.value = data
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error fetching process step statuses')

    }
  }
}
const getOwnerName = (projectProcessStep) => {
  return projectProcessStep.owner?.fullName ?? ''
}
const updateOwner = async () => {
  displayChangeOwner.value = false
  appStore.loading = true
  try {
    const {status} = await postRequest(`/project/${projectId.value}/owner`, project.value.owner)
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error Saving Owner')

    appStore.loading = false
  }
}
const updateStatus = async (pps) => {
  showStatusDialog.value = false
  const selectedStep = projectProcessSteps.value.find(step => step.projectProcessStepId === pps.projectProcessStepId)
  try {
    appStore.loading = true
    await postRequest(`/projectProcessStep/${pps.projectProcessStepId}/status`, selectedStep.newStatusToUse)
    const {status} = await getProjectProcessSteps()
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error updating process step status')


    const previousStatus = availableProcessStepStatuses.value.find(status => status.id === selectedStep.companyProcessStepStatusTypeId)

    projectProcessSteps.value = projectProcessSteps.value.map(step => {
      if (step.companyProcessStepStatusTypeId === selectedStep.companyProcessStepStatusTypeId) {
        step.selectedProcessStepStatusType = previousStatus
      }
      return step
    })
    appStore.loading = false
  }
}
const deleteProjectProcessStep = async (projectProcessStepId) => {
  try {
    appStore.loading = true
    const {status} = await deleteRequest(`/projectProcessStep/${projectProcessStepId}`)
    projectProcessSteps.value = projectProcessSteps.value.filter(step => step.projectProcessStepId !== projectProcessStepId)
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error deleting process step')

    appStore.loading = false
  }
}
const updateMain = async (pps) => {
  showMainDialog.value = false
  const selectedStep = projectProcessSteps.value.find(step => step.projectProcessStepId === pps.projectProcessStepId)
  try {
    appStore.loading = true
    await postRequest(`/projectProcessStep/${pps.projectProcessStepId}/main`, selectedStep.newStatusToUse)
    const {status} = await getProjectProcessSteps()
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Unable to update the primary process step')

    if (selectedStep) {
      selectedStep.main = false
    }
    appStore.loading = false
  }
}
const getPpsHistory = async(pps) => {
  try {
    showPpsHistory.value = false
    appStore.loading = true
    const {data} = await getRequest(`/projectProcessStep/${pps.projectProcessStepId}/history`)
    showPpsHistory.value = true
    selectedPpsHistory.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error getting project process step history')

  } finally {
    appStore.loading = false
  }
}
</script>

<style scoped lang="scss">

@import "@/styles/main";

#project-admin-container {
  width: 100vw;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow-x: clip;
}

.project-header {
  border-bottom: solid 1px #EAEAF4;
  height: 64px;
}

.page-title {
  padding-top:16px;
  height: 20px;
}

.admin-body {
  height: calc(100% - 65px);
  max-width: 100%;
  width: 100%;
  margin-right: 0 !important;
  margin-left: 0 !important;
}

//.process-step-toolbar .v-toolbar__content {
//  padding-left: 0 !important;
//  padding-right: 0 !important;
//}

tr:nth-of-type(even) {
  @extend .shaded-row;

  ::v-deep .v-input__slot {
    background-color: var(--v-primary-lighten9) !important;
  }
}

::v-deep {
  .v-data-table__wrapper {
    height: 75vh;
    min-height: 300px;
  }

  tr .v-input__slot {
    transition: none !important;
    -webkit-transition: none !important;
  }

  tr:hover .v-input__slot {
    background-color: #eeeeee !important;
  }
}
</style>

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
                    <v-btn
                      text
                      color="primary"
                      @click="[showStatusDialog = true, showMainDialog = false, alteringPrimaryFlag = false, selectedPps = projectProcessStep, getAvailableStatuses(projectProcessStep)]"
                    >
                      <v-icon>edit</v-icon>
                    </v-btn>
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
                        <v-btn
                          @click="[projectProcessStep.changeActiveConfirm = false, alteringPrimaryFlag = false, projectProcessStep.main = false]">
                          No
                        </v-btn>
                        <v-btn
                          color="primary"
                          text
                          @click="[showSelectedPps = false, showMainDialog = true, alteringPrimaryFlag = true, projectProcessStep.changeActiveConfirm = false, showStatusDialog = true, selectedPps = projectProcessStep, getAvailableStatuses(selectedPps)]"
                        >
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </template>
                <template #item.historyHere="{item: projectProcessStep}" class="text-left">
                  <v-btn small text color="primary" @click="getPpsHistory(projectProcessStep)">
                    <v-icon>mdi-chart-timeline</v-icon>
                  </v-btn>
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

<script>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  getRequest,
  getRequestWithParams,
  postRequest,
  deleteRequest,
  getSnackbar,
  logError
} from '@/helpers/helpers'
import {getCompanyAssignedToProcessStep, getCancelledCompanyStatusTypes} from '@/services/processStepStatusTypeService'
import {v4 as uuid} from 'uuid'
import AddProcessStep from '@/views/flow/components/AddProcessStep.vue'
import PpsHistoryTable from '@/views/flow/components/PpsHistoryTable.vue'
import ProjectProcessStepStatus from '@/views/flow/project/ProjectProcessStepStatus.vue'
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import { mapStores } from 'pinia'
import { useUserStore } from '@/stores/UserStorePinia.js'

const NEW_STATUS_TO_USE = {id: null}

export default {
  name: 'ProcessSteps.vue',
  props: {
    processId: Number
  },
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      project: {},
      alteringPrimaryFlag: false,
      projectProcessSteps: [],
      showPpsHistory: false,
      selectedPpsHistory: [],
      snackbar: {},
      displayDropdown: false,
      displayChangeOwner: false,
      availableOwners: [],
      cancelledCompanyStatuses: [],
      availableProcessStepStatuses: [],
      isProjectProcessStepsLoading: false,
      selectedNewProjectProcessStep: null,
      headers: [
        {text: 'ID', value: 'projectProcessStepId', show: true},
        {text: 'Type', value: 'processStepName', show: true},
        {text: 'Owner', value: 'owner.fullName', show: true},
        {text: 'Last Activity', value: 'lastUpdated', show: true},
        {text: 'Status', value: 'processStepStatusType', show: true},
        {text: 'Primary', value: 'main', show: true},
        {text: 'History', value: 'historyHere', show: true},
        // {text: '', value: 'delete', sortable: false}
      ],
      uuid,
      showStatusDialog: false,
      showMainDialog: false,
      selectedPps: null,
      showSelectedPps: false,
      NEW_STATUS_TO_USE
    }
  },
  components: {
    ConfirmationDialog,
    ProjectProcessStepStatus,
    AddProcessStep,
    PpsHistoryTable
  },
  computed: {
    ...mapStores(useUserStore),
    userCanDelete() {
      return this.userStore.userHasFeatureAccessLevel('PROJECTS', 'DELETE')
    },
    userIsAdmin() {
      return this.userStore.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')
    },
    displayedHeaders() {
      return this.headers.filter(header => header.show)
    },
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    }
  },
  async created() {
    // await this.getAvailableStatuses()
    this.getProjectProcessSteps()
  },
  methods: {
    getProjectProcessSteps: async function () {
      try {
        this.isProjectProcessStepsLoading = true
        const {data, status} = await getRequest(`/project/${this.projectId}/processSteps`, null, [])
        this.projectProcessSteps = data.map(step => {
          // step.selectedProcessStepStatusType = this.availableProcessStepStatuses.find(status => status.id === step.companyProcessStepStatusTypeId)
          step.newStatusToUse = {NEW_STATUS_TO_USE}
          return step
        })
        return {status}
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching process steps')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.isProjectProcessStepsLoading = false
      }
    },
    async getAvailableStatuses(pps) {
      this.showSelectedPps = false
      try {
        const {data} = await getCompanyAssignedToProcessStep(pps.processStepId)
        this.availableProcessStepStatuses = data
        if (this.availableProcessStepStatuses?.length > 0) {
          let match = this.availableProcessStepStatuses.find(status => status.id === pps.companyProcessStepStatusTypeId)
          if (match) {
            this.selectedPps.selectedProcessStepStatusType = match
            this.showSelectedPps = true
          }
        }
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        logError(e)
      }
    },
    async getCancelledStatuses() {
      if (this.cancelledCompanyStatuses?.length === 0) {
        try {
          const {data} = await getCancelledCompanyStatusTypes(this.projectId)
          this.cancelledCompanyStatuses = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching process step statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    getOwnerName: projectProcessStep => projectProcessStep.owner?.fullName ?? '',
    updateOwner: async function () {
      this.displayChangeOwner = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await postRequest(`/project/${this.projectId}/owner`, this.project.owner)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    updateStatus: async function (pps) {
      this.showStatusDialog = false
      const selectedStep = this.projectProcessSteps.find(step => step.projectProcessStepId === pps.projectProcessStepId)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await postRequest(`/projectProcessStep/${pps.projectProcessStepId}/status`, selectedStep.newStatusToUse)
        const {status} = await this.getProjectProcessSteps()
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating process step status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

        const previousStatus = this.availableProcessStepStatuses.find(status => status.id === selectedStep.companyProcessStepStatusTypeId)

        this.projectProcessSteps = this.projectProcessSteps.map(step => {
          if (step.companyProcessStepStatusTypeId === selectedStep.companyProcessStepStatusTypeId) {
            step.selectedProcessStepStatusType = previousStatus
          }
          return step
        })
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    deleteProjectProcessStep: async function (projectProcessStepId) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await deleteRequest(`/projectProcessStep/${projectProcessStepId}`)
        this.projectProcessSteps = this.projectProcessSteps.filter(step => step.projectProcessStepId !== projectProcessStepId)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting process step')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    updateMain: async function (pps) {
      this.showMainDialog = false
      const selectedStep = this.projectProcessSteps.find(step => step.projectProcessStepId === pps.projectProcessStepId)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await postRequest(`/projectProcessStep/${pps.projectProcessStepId}/main`, selectedStep.newStatusToUse)
        const {status} = await this.getProjectProcessSteps()
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Unable to update the primary process step')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        if (selectedStep) {
          selectedStep.main = false
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getPpsHistory(pps) {
      try {
        this.showPpsHistory = false
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await getRequest(`/projectProcessStep/${pps.projectProcessStepId}/history`)
        this.showPpsHistory = true
        this.selectedPpsHistory = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error getting project process step history')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
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

  .project-admin-btn .v-btn__content {
    color: #ffffff !important;
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

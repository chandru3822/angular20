<template>
  <div id="project-admin-container">
    <v-toolbar flat color="#E3E3E3" class="project-header">
      <div class="app-title albatross-header-1">
        <router-link :to="`/project/${projectId}/details`">{{ project.projectName }}</router-link>
      </div>
      <v-spacer></v-spacer>
      <v-btn color="primary" dark class=" float-right white--text" @click="deleteProjectConfirm=true">
        Delete Project
      </v-btn>
      <ConfirmationDialog
          :open-dialog="deleteProjectConfirm"
          @confirm="deleteProject"
          @close-dialog="deleteProjectConfirm = false"
      >
        <span class="error--text">WARNING:</span>
        This cannot be undone. Are you sure you want to delete this project?
      </ConfirmationDialog>
    </v-toolbar>
    <v-row v-if="userIsAdmin">

      <v-col cols="12">

        <v-col cols="12" class="text-left">
          <router-link :to="`/project/${projectId}/details`">Back to Project</router-link>
        </v-col>

        <v-col cols="12" class="text-left">

          <AddProcessStep
            v-if="process.id"
            :admin="true"
            :project-id="projectId"
            :process-id="process.id"
            @step-added="getProjectProcessSteps"
          />
        </v-col>

        <v-col cols="12">

          <v-data-table
            class="elevation-1"
            :headers="displayedHeaders"
            :items="projectProcessSteps"
            fixed-header
            multi-sort
            :sort-by="['processStepName', 'lastUpdated']"
            :sort-desc="[false, true]"
            hide-default-footer
            dense
            :loading="isProjectProcessStepsLoading"
            disable-pagination
          >

            <template #no-data>
              <span class="default-text-color">No available process steps</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available process steps</span>
            </template>

            <template #item="{item: projectProcessStep}">
              <tr>
                <td class="text-left">
                  <router-link
                    :to="`/project/${projectId}/processStep/${projectProcessStep.projectProcessStepId}`">
                    {{ projectProcessStep.projectProcessStepId }}
                  </router-link>
                </td>
                <td class="text-left">{{ projectProcessStep.processStepName }}</td>
                <td class="text-left">{{ getOwnerName(projectProcessStep) }}</td>
                <td class="text-left">{{ projectProcessStep.lastUpdated }}</td>
                <td class="text-left">
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
                </td>
                <td class="text-left">
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
                </td>
                <td class="text-left">
                  <v-btn small text color="primary" @click="getPpsHistory(projectProcessStep)">
                    <v-icon>mdi-chart-timeline</v-icon>
                  </v-btn>
                </td>
                <!--            <td class="text-right">-->
                <!--              <v-icon @click="deleteProjectProcessStep(projectProcessStep.projectProcessStepId)">mdi-delete</v-icon>-->
                <!--            </td>-->
              </tr>
            </template>
          </v-data-table>
          <ConfirmationDialog :open-dialog="showPpsHistory" hide-confirm :width="1000" @close-dialog="[showPpsHistory = false, selectedPpsHistory = []]">
            <template v-slot:title>Project Process Step History</template>
            <PpsHistoryTable :selected-pps-history="selectedPpsHistory"></PpsHistoryTable>
            <template v-slot:no>Close</template>
          </ConfirmationDialog>
        </v-col>
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
import AddProcessStep from '@/views/flow/components/AddProcessStep'
import PpsHistoryTable from '@/views/flow/components/PpsHistoryTable'
import ProjectProcessStepStatus from '@/views/flow/project/ProjectProcessStepStatus'
import ConfirmationDialog from "@/components/ConfirmationDialog";

const NEW_STATUS_TO_USE = {id: null}

export default {
  name: 'ProjectAdmin.vue',
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      project: {},
      alteringPrimaryFlag: false,
      projectProcessSteps: [],
      showPpsHistory: false,
      selectedPpsHistory: [],
      process: {},
      snackbar: {},
      deleteProjectConfirm: false,
      displayDropdown: false,
      displayChangeOwner: false,
      userCanDelete: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'DELETE'),
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN'),
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
    displayedHeaders() {
      return this.headers.filter(header => header.show)
    },
  },
  async created() {
    await this.getProject()
    this.getProcess()
    // await this.getAvailableStatuses()
    this.getProjectProcessSteps()
  },
  methods: {
    getProject: async function () {
      try {
        const {data} = await getRequest(`/project/${this.projectId}`)
        this.project = data
        window.document.title = `${this.project.projectName} - Admin`
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching project')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
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
    getProcess: async function () {
      try {
        const {data} = await getRequestWithParams(`/processes/${this.project.processId}`, {
          params: {
            projectId: this.projectId
          }
        })
        this.process = data
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching available process steps')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        logError(e)
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
    async deleteProject() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/project/${this.projectId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Project Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$router.push('/projects')
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting project')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
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

@import "@/styles/main.scss";

#project-admin-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
}

.project-header {
  border-bottom: solid 1px #EAEAF4;
  height: 64px;
}

.process-step-toolbar .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

tr:nth-of-type(even) {
  @extend .shaded-row;

  ::v-deep .v-input__slot {
    background-color: var(--v-primary-lighten9) !important;
  }
}

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 320px);
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

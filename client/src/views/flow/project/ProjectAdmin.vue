<template>
<v-row id="project-admin-container">
  <v-col cols="12">
    <v-row class="project-header">
      <v-col cols="12" class="text-left pl-5">
        <div class="d-inline-block">
          <div class="project-title">
            <router-link :to="`/project/${projectId}/details`">{{ contact.fullName}}</router-link>
          </div>
          <div class="project-subtitle">
            {{ contact.street1 }} - {{ contact.city }}, {{ contact.state }}
          </div>
        </div>
        <v-dialog
          class="d-inline-block"
          v-model="deleteProjectConfirm"
          width="500">
          <template #activator="{ on }">
            <v-btn color="primaryCustom" dark class="mr-2  float-right white--text" v-on="on">
              Delete Project
            </v-btn>
          </template>
          <v-card>
            <v-card-title
              class="headline grey lighten-2"
              primary-title>
              Confirm
            </v-card-title>

            <v-card-text class="pt-4">
              <span class="bold error-text">WARNING: This cannot be undone. Are you sure you want to delete this project?</span>
            </v-card-text>

            <v-divider></v-divider>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn
                @click="deleteProjectConfirm = false">
                No
              </v-btn>
              <v-btn
                color="primaryCustom"
                text
                @click="deleteProject">
                Yes
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>

      </v-col>

    </v-row>
  </v-col>


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
       :headers="headers"
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
          No available process steps
        </template>

        <template #no-results>
          No available process steps
        </template>

        <template #item="{item: projectProcessStep}">
          <tr>
            <td class="text-left">
              <router-link :to="`/project/${projectId}/processStep/${projectProcessStep.projectProcessStepId}?processStepId=${projectProcessStep.processStepId}&contactId=${contact.id}`">{{ projectProcessStep.projectProcessStepId }}</router-link>
            </td>
            <td class="text-left">{{projectProcessStep.processStepName}}</td>
            <td class="text-left">{{getOwnerName(projectProcessStep)}}</td>
            <td class="text-left">{{projectProcessStep.lastUpdated}}</td>
            <td class="text-left">
              <div>
                {{ projectProcessStep.processStepStatusType }}
                <v-btn
                  text
                  color="primaryCustom"
                  @click="[showStatusDialog = true, selectedPps = projectProcessStep, getAvailableStatuses(projectProcessStep)]"
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
                    class="headline grey lighten-2"
                    primary-title>
                    Confirm
                  </v-card-title>

                  <v-card-text class="pt-4">
                    Modifying the primary flag will run any automatic actions that have not yet been run where the criteria is met using values from the new active process step.
                    Are you sure you want to set <strong>{{projectProcessStep.processStepName}} - {{projectProcessStep.projectProcessStepId}}</strong> to Primary?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                      @click="[projectProcessStep.changeActiveConfirm = false, projectProcessStep.main = false]">
                      No
                    </v-btn>
                    <v-btn
                      color="primaryCustom"
                      text
                      @click="[projectProcessStep.changeActiveConfirm = false, showMainDialog = true, selectedPps = projectProcessStep]"
                    >
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </td>
<!--            <td class="text-right">-->
<!--              <v-icon @click="deleteProjectProcessStep(projectProcessStep.projectProcessStepId)">mdi-delete</v-icon>-->
<!--            </td>-->
          </tr>
        </template>
      </v-data-table>
    </v-col>
  </v-col>

  <ProjectProcessStepStatus
    v-if="selectedPps"
    :show-dialog="showStatusDialog"
    :project-id="projectId"
    :project-process-step="selectedPps"
    :available-process-step-statuses="availableProcessStepStatuses"
    @updateStatus="updateStatus"
    @dialogClosed="showStatusDialog = false"
  />

  <ProjectProcessStepStatus
      v-if="showSelectedPps"
      :show-dialog="showMainDialog"
      :project-id="projectId"
      :project-process-step="selectedPps"
      :available-process-step-statuses="availableProcessStepStatuses"
      :limit-to-active="true"
      :new-status-optional="selectedPps.selectedProcessStepStatusType.processStepStatusTypeId !== 3"
      @updateStatus="updateMain"
      @dialogClosed="[showMainDialog = false, selectedPps.main = false, selectedPps.newStatusToUse = {NEW_STATUS_TO_USE}]"
  />
</v-row>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, getRequestWithParams, postRequest, putRequest, deleteRequest, getSnackbar, logError} from '@/helpers/helpers'
import {getAssignedToProcessStep, getCancelledCompanyStatusTypes} from '@/services/processStepStatusTypeService'
import { v4 as uuid } from 'uuid'
import AddProcessStep from '@/views/flow/components/AddProcessStep'
import ProjectProcessStepStatus from '@/views/flow/project/ProjectProcessStepStatus'

const NEW_STATUS_TO_USE = {id: null}

export default {
  name: 'ProjectAdmin.vue',
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      project: {},
      projectProcessSteps: [],
      process: {},
      contact: {},
      snackbar: {},
      deleteProjectConfirm: false,
      displayDropdown: false,
      displayChangeOwner: false,
      availableOwners: [],
      cancelledCompanyStatuses: [],
      availableProcessStepStatuses: [],
      isProjectProcessStepsLoading: false,
      selectedNewProjectProcessStep: null,
      headers: [
        {text: 'ID', value: 'projectProcessStepId'},
        {text: 'Type', value: 'processStepName'},
        {text: 'Owner', value: 'owner.fullName'},
        {text: 'Last Activity', value: 'lastUpdated'},
        {text: 'Status', value: 'processStepStatusType'},
        {text: 'Primary', value: 'main'},
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
    ProjectProcessStepStatus,
    AddProcessStep
  },
  async created () {
    this.getContact()
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
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching project')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    getProjectProcessSteps: async function () {
      try {
        this.isProjectProcessStepsLoading = true
        const {data} = await getRequest(`/project/${this.projectId}/processSteps`)
        this.projectProcessSteps = data.map(step => {
          // step.selectedProcessStepStatusType = this.availableProcessStepStatuses.find(status => status.id === step.companyProcessStepStatusTypeId)
          step.newStatusToUse = {NEW_STATUS_TO_USE}
          return step
        })
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
    getContact: async function () {
      try {
        const{data} = await getRequest(`/contact/project/${this.projectId}`)
        this.contact = data
      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    async getAvailableStatuses (pps) {
      this.showSelectedPps = false
      try {
        const {data} = await getAssignedToProcessStep(pps.processStepId)
        this.availableProcessStepStatuses = data
        if(this.availableProcessStepStatuses?.length > 0) {
          let match = this.availableProcessStepStatuses.find(status => status.id === pps.companyProcessStepStatusTypeId)
          if(match) {
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
        await postRequest(`/project/${this.projectId}/owner`, this.project.owner)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    updateStatus: async function (pps) {
      this.showStatusDialog = false
      const selectedStep = this.projectProcessSteps.find(step => step.projectProcessStepId === pps.projectProcessStepId)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await postRequest(`/projectProcessStep/${pps.projectProcessStepId}/status`, selectedStep.newStatusToUse)
        await this.getProjectProcessSteps()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating process step status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

        const previousStatus = this.availableProcessStepStatuses.find(status => status.id ===  selectedStep.companyProcessStepStatusTypeId)

        this.projectProcessSteps = this.projectProcessSteps.map(step => {
          if (step.companyProcessStepStatusTypeId === selectedStep.companyProcessStepStatusTypeId) {
            step.selectedProcessStepStatusType = previousStatus
          }
          return step
        })
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    deleteProjectProcessStep: async function (projectProcessStepId) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/projectProcessStep/${projectProcessStepId}`)
        this.projectProcessSteps = this.projectProcessSteps.filter(step => step.projectProcessStepId !== projectProcessStepId)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting process step')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    updateMain: async function (pps) {
        this.showMainDialog = false
        const selectedStep = this.projectProcessSteps.find(step => step.projectProcessStepId === pps.projectProcessStepId)
        try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            await postRequest(`/projectProcessStep/${pps.projectProcessStepId}/main`, selectedStep.newStatusToUse)
            await this.getProjectProcessSteps()
        } catch (e) {
            logError(e)
            this.snackbar = getSnackbar('ERROR', 'Unable to update the primary process step')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            if (selectedStep) {
                selectedStep.main = false
            }
        } finally {
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
    }
  }
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

#project-admin-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.project-header {
  border-bottom: solid 1px #EAEAF4
}

.project-title {
  font-size: 20px;
}

.project-subtitle {
  font-size: 15px;
}

tr:nth-of-type(even) {
  @extend .shaded-row;

  ::v-deep .v-input__slot {
    background-color: var(--v-rowShadeCustom-base) !important;
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

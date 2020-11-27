<template>
<v-row id="project-admin-container">
  <v-col cols="12">
    <v-row class="project-header">
      <v-col cols="8" class="text-left pl-5">
        <div class="project-title">
          <router-link :to="`/project/${projectId}/details`">{{ contact.fullName}}</router-link>
        </div>
        <div class="project-subtitle">
          {{ contact.street1 }} - {{ contact.city }}, {{ contact.state }}
        </div>
      </v-col>

    </v-row>
  </v-col>


  <v-col cols="12">

    <v-col cols="12" class="text-left">
      <router-link :to="`/project/${projectId}/details`">Back</router-link>
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
              <v-select
                v-model="projectProcessStep.selectedProcessStepStatusType"
                :items="availableProcessStepStatuses"
                item-text="processStepStatusType"
                item-value="companyProcessStepStatusTypeId"
                @change="updateStatus(projectProcessStep.projectProcessStepId)"
                return-object
                solo
                flat
                hide-details
              />
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
                    Modifying the primary flag will cancel the current active process step. It will also run any automatic actions that have not yet been run where the criteria is met using values from the new active process step.
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
                      @click="updateMain(projectProcessStep.projectProcessStepId)">
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

</v-row>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, getRequestWithParams, postRequest, putRequest, deleteRequest, getSnackbar, logError} from '@/helpers/helpers'

import { v4 as uuid } from 'uuid'
import AddProcessStep from '@/views/flow/components/AddProcessStep'

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
      displayDropdown: false,
      displayChangeOwner: false,
      availableOwners: [],
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
      uuid
    }
  },
  components: {

    AddProcessStep
  },
  async created () {
    this.getContact()
    await this.getProject()
    this.getProcess()
    await this.getAvailableStatuses()
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
          step.selectedProcessStepStatusType = this.availableProcessStepStatuses.find(status => status.id === step.companyProcessStepStatusTypeId)
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
    async getAvailableStatuses () {
      try {
        let params = {
          projectId: parseInt(this.projectId)
        }
        const {data} = await getRequestWithParams(`/processStep/status`, { params })
        this.availableProcessStepStatuses = data
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        logError(e)
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
    updateStatus: async function (projectProcessStepId) {
      const selectedStep = this.projectProcessSteps.find(step => step.projectProcessStepId === projectProcessStepId)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await postRequest(`/projectProcessStep/${projectProcessStepId}/status`, selectedStep.selectedProcessStepStatusType)
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
    createProjectProcessStep: async function () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        // Status is 1 (active) because current business logic says new project process steps must be active and primary
        const {data} = await postRequest(`/projectProcessStep/`, {
          projectId: this.projectId,
          processStepId: this.selectedNewProjectProcessStep.processStepId,
          companyProcessStepStatusTypeId: this.availableProcessStepStatuses.find(status => status.processStepStatusTypeId === 1)?.processStepStatusTypeId,
          main: true
        })
        this.selectedNewProjectProcessStep = null
        this.getProjectProcessSteps()
        this.displayDropdown = false
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error creating new process step')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
    updateMain: async function (projectProcessStepId) {
        try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            await postRequest(`/projectProcessStep/${projectProcessStepId}/status`, this.availableProcessStepStatuses.find(status => status.processStepStatusTypeId === 1))
            await this.getProjectProcessSteps()
        } catch (e) {
            logError(e)
            this.snackbar = getSnackbar('ERROR', 'Unable to update the primary process step')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            const selectedStep = this.projectProcessSteps.find(s => s.projectProcessStepId === projectProcessStepId)
            if (selectedStep) {
                selectedStep.main = false
            }
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

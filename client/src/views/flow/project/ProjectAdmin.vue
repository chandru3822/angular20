<template>
<v-row id="project-admin-container">
  <v-col cols="12">
    <v-row class="project-header">
      <v-col cols="8" class="text-left pl-5">
        <div class="project-title">
          <router-link :to="`/customer/${customer.id}`">{{ customer.fullName}}</router-link>
        </div>
        <div class="project-subtitle">
          {{ customer.street1 }} - {{ customer.city }}, {{ customer.state }}
        </div>
      </v-col>

      <v-col
        cols="4"
        class="lead-owner pb-2 text-right">
        <div v-if="!displayChangeOwner">
          <div v-if="project.owner && project.owner.userId">
            <v-avatar
              :tile="false"
              :size="25"
              color="grey lighten-4"
              class="account-img mr-2"
            >
              <img name="accountImg" src="../../../assets/user_img_placeholder.png">
            </v-avatar>
            {{project.owner.fullName}}<br/>
            {{project.owner.position}}
          </div>
        </div>
        <div v-if="displayChangeOwner">
          <v-autocomplete v-model="project.owner"
                          :items="availableOwners"
                          label="Select Owner"
                          item-text="fullName"
                          return-object
                          autocomplete="off"
                          @change="updateOwner"
          >
          </v-autocomplete>
        </div>
        <v-btn text x-small class="change-owner-button" @click="displayChangeOwner = !displayChangeOwner">
          <span v-if="displayChangeOwner">cancel</span>
          <span v-else-if="customer.owner && customer.owner.userId">change</span>
          <span v-else>add owner</span>
        </v-btn>
      </v-col>
    </v-row>
  </v-col>

  <v-col cols="6">

    <v-col cols="12" class="text-left">
      <v-btn
        class="new-btn primary"
      >
        Add Process Step
      </v-btn>
    </v-col>

    <v-col cols="12">

      <v-data-table
       class="elevation-1"
       :headers="headers"
       :items="projectProcessSteps"
       fixed-header
       disable-sort
       hide-default-footer
       :loading="isProjectProcessStepsLoading"
      >

        <template #item="{item: projectProcessStep}">
          <tr>
            <td>{{projectProcessStep.projectProcessStepId}}</td>
            <td>{{projectProcessStep.processStepName}}</td>
            <td>{{getOwnerName(projectProcessStep)}}</td>
            <td>{{projectProcessStep.lastUpdated}}</td>
            <td>
              <v-select
                v-model="projectProcessStep.selectedProcessStepStatusType"
                :items="availableProcessStepStatuses"
                item-text="processStepStatusType"
                item-value="processStepStatusTypeId"
                @change="updateStatus(projectProcessStep.projectProcessStepId)"
                return-object
                solo
                flat
              />
            </td>
          </tr>
        </template>
      </v-data-table>
    </v-col>
  </v-col>

  <v-col cols="6">
    <router-view></router-view>
  </v-col>

  <Snackbar :snackbar="snackbar"/>
</v-row>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, postRequest, getSnackbar, logError} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar.vue'
import { v4 as uuid } from 'uuid'

export default {
  name: 'ProjectAdmin.vue',
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      project: {},
      projectProcessSteps: [],
      process: {},
      customer: {},
      snackbar: {},
      displayChangeOwner: false,
      availableOwners: [],
      availableProcessStepStatuses: [],
      isProjectProcessStepsLoading: false,
      headers: [
        {text: 'ID', value: 'projectProcessStepId', show: true},
        {text: 'Type', value: 'processStepName', show: true},
        {text: 'Owner', value: 'owner.fullName', show: true},
        {text: 'Last Activity', value: 'lastUpdated', show: true},
        {text: 'Status', value: 'processStepStatusType', show: true}
      ],
      uuid
    }
  },
  components: {
    Snackbar
  },
  async created () {
    this.getCustomer()
    this.getAvailableOwners()
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
      }
    },
    getProjectProcessSteps: async function () {
      try {
        this.isProjectProcessStepsLoading = true
        const {data} = await getRequest(`/project/${this.projectId}/processSteps`)
        this.projectProcessSteps = data.map(step => {
          step.selectedProcessStepStatusType = this.availableProcessStepStatuses.find(status => status.processStepStatusTypeId === step.processStepStatusTypeId)
          return step
        })
        // this.projectProcessSteps.forEach(step => step.selectedProcessStepStatusType = Object.assign(, {}))
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching process steps')
      } finally {
        this.isProjectProcessStepsLoading = false
      }
    },
    getProcess: async function () {
      try {
        const {data} = await getRequest(`/processes/${this.project.processId}`)
        this.process = data
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching available process steps')
        logError(e)
      }
    },
    getCustomer: async function () {
      try {
        const{data} = await getRequest(`/customer/project/${this.projectId}`)
        this.customer = data
      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    async getAvailableOwners () {
      try {
        //@TODO: @randa, pretty sure the customer list will work for process steps and projects but double checking
        const {data} = await getRequest(`/project/owners`)
        this.availableOwners = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving List of Owners')
      }
    },
    async getAvailableStatuses () {
      try {
        const {data} = await getRequest(`/processStep/status`)
        this.availableProcessStepStatuses = data
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
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
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    updateStatus: async function (projectProcessStepId) {
      const selectedStep = this.projectProcessSteps.find(step => step.projectProcessStepId === projectProcessStepId)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await postRequest(`/projectProcessStep/${projectProcessStepId}/status`, selectedStep.selectedProcessStepStatusType)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating process step status')

        const previousStatus = this.availableProcessStepStatuses.find(status => status.processStepStatusTypeId ===  selectedStep.processStepStatusTypeId)

        this.projectProcessSteps = this.projectProcessSteps.map(step => {
          if (step.processStepStatusTypeId === selectedStep.processStepStatusTypeId) {
            step.selectedProcessStepStatusType = previousStatus
          }
          return step
        })
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style scoped lang="scss">
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
</style>

<style lang="scss">
.new-btn > .v-btn__content {
  color: white !important;
}
</style>

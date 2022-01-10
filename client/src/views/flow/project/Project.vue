<template>
  <div id="project-container">
    <v-row v-if="!projectLoading && project && project.id" class="project-header">
      <v-col cols="12">
        <div>
          {{ project.projectName }}
        </div>
        <div>
          <v-select
            v-model="project.companyProjectStatusTypeId"
            :items="statuses"
            :readonly="!userCanEdit || projectStatusIsReadOnly()"
            :disabled="!userCanEdit || projectStatusIsReadOnly()"
            item-text="projectStatusType"
            item-value="id"
            @change="updateStatus"
            label="Project Stage"
          />
          <div class="text-left project-stage"
               v-if="Object.keys(project).length > 0 && project.companyProjectStatusTypeId !== null && statuses.length > 0">
            Status: {{ projectStage }}
          </div>
        </div>
      </v-col>
    </v-row>
    <v-row class="project-split-container">
      <v-col cols="3" class="white-bg">
        Address: {{ project.street1 }} <br/>
        Owner:
        <div>
          <v-row v-if="project.owner && project.owner.userId && !displayChangeOwner">
            <v-avatar
              :tile="false"
              :size="40"
              color="grey lighten-4"
              class="account-img mr-4 mt-1"
            >
              <v-img name="accountImg" v-if="project.owner.presignedUrl"
                     :src="project.owner.presignedUrl"></v-img>
              <img v-else name="accountImg" src="../../../assets/flow/user_img_placeholder.png">
            </v-avatar>
            <div class="d-inline-block">
              {{ project.owner.fullName }} <br/>
              {{ project.owner.position }} <br/>
            </div>
          </v-row>
          <v-row>
            <v-col class="pa-0">
              <div v-if="project.owner && project.owner.userId && !displayChangeOwner">
                {{ formatPhoneNumber(project.owner.phoneNumber) }}<br/>
              </div>

              <div v-if="displayChangeOwner && !projectOwnerIsReadOnly()">
                <v-autocomplete v-model="project.owner"
                                :items="availableOwners"
                                label="Select Owner"
                                item-text="fullName"
                                return-object
                                autocomplete="off"
                                @change="updateOwner"
                                attach
                >
                </v-autocomplete>
              </div>
              <v-btn text x-small class="change-owner-button"
                     v-if="!projectOwnerIsReadOnly()"
                     @click="[displayChangeOwner = !displayChangeOwner, getOwners()]">
                <span v-if="displayChangeOwner">cancel</span>
                <span v-else-if="project.owner && project.owner.userId">change</span>
                <span v-else>add owner</span>
              </v-btn>
            </v-col>
          </v-row>
        </div>

        <ActiveProcessSteps :project="project"></ActiveProcessSteps>
        <UpcomingEvents v-if="userHasEventsFeature" :projectId="projectId"/>
      </v-col>
      <v-col cols="5" class="router-view-column">
        <router-view class="router-view"></router-view>
      </v-col>
      <v-col cols="4" class="white-bg">
        <ProjectActivity></ProjectActivity>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  isNumberOrHyphen,
  logError,
  getRequestWithParams,
  getSnackbar,
  formatPhoneNumber
} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import ProjectActivity from '@/views/flow/project/ProjectActivity'
import ActiveProcessSteps from '@/views/flow/project/ActiveProcessSteps'
import UpcomingEvents from '@/views/flow/project/UpcomingEvents'
import {getCompanyProjectStatusTypes} from "@/services/projectStatusTypeService"

export default {
  name: 'Project',
  components: {
    ProjectActivity,
    ActiveProcessSteps,
    UpcomingEvents
  },
  data() {
    return {
      snackbar: {},
      project: {},
      statuses: [],
      availableOwners: [],
      formatPhoneNumber,
      projectLoading: true,
      displayChangeOwner: false,
      projectId: parseInt(this.$route.params.projectId),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      userHasEventsFeature: this.$store.getters.userHasFeature('EVENTS'),
    }
  },
  created() {
    this.getProject()
    this.getStatuses()
  },
  computed: {
    projectStage() {
      return this.statuses?.find(s => s.id === this.project.companyProjectStatusTypeId)?.rootProjectStatusType
    }
  },
  mounted() {
  },
  methods: {
    getProject: async function () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/project/${this.projectId}`)
        this.project = data
        window.document.title = `${this.project.projectName} - Project Details`
        this.projectLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.projectLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
      }
    },
    getStatuses: async function () {
      try {
        const {data} = await getCompanyProjectStatusTypes(this.projectId)
        this.statuses = data
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching project statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    projectStatusIsReadOnly() {
      if (this.project.statusReadOnlyWhiteListedPositions?.length > 0) {
        return !this.$store.getters.userHasAnyPosition(this.project.statusReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
      } else {
        return this.project.ownerReadOnly
      }
    },
    projectOwnerIsReadOnly() {
      if (this.project.ownerReadOnlyWhiteListedPositions?.length > 0) {
        return !this.$store.getters.userHasAnyPosition(this.project.ownerReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
      } else {
        return this.project.ownerReadOnly
      }
    },
    updateStatus: async function () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await postRequest(`/project/${this.projectId}/status`, this.project)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating project status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    updateOwner: async function () {
      this.displayChangeOwner = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/project/${this.projectId}/owner`, this.project.owner)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getOwners: async function () {
      if (this.displayChangeOwner) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/project/owners`)
          this.availableOwners = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Available Owners')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
  }
}
</script>

<style lang="scss" scoped>
#project-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 12px !important;
  overflow: hidden;
}

.project-header {
  background-color: #E3E3E3;
}

.project-split-container {
  height: calc(100% - 50px);
}

.router-view-column {
  overflow: auto;
}

.white-bg {
  background-color: #fff;
}

</style>


<template>
  <div id="project-container">
    <v-toolbar flat color="#E3E3E3" class="project-header" v-if="!projectLoading && project && project.id">
      <v-toolbar-title class="app-title">
        <div class="d-inline-block">{{ project.projectName }}{{project.projectStatusTypeId}}</div>
        <div class="d-inline-block">
          <v-autocomplete
            class="ml-5"
            v-model="project.companyProjectStatusTypeId"
            :items="statuses"
            :readonly="!userCanEdit || projectStatusIsReadOnly()"
            :disabled="!userCanEdit || projectStatusIsReadOnly()"
            item-text="projectStatusType"
            item-value="id"
            solo
            dense
            hide-details
            :background-color="getStatusColor(project.projectStatusTypeId)"
            @change="updateStatus"
          />
        </div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div>
          <v-btn color="#C4C4C4"
                 v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')"
                 class="d-inline-block mt-3"
                 @click="$router.push({name: 'projectAdmin', params: {projectId}})"
          >
            Project Admin
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-row class="project-split-container">
      <v-col cols="2" class="white-bg project-section">
        <v-btn fab small text @click="collapseSidebar = !collapseSidebar">
          <v-icon>mdi-menu</v-icon>
        </v-btn>
        <div v-if="collapseSidebar">will collapse later</div>
        <v-toolbar flat>
          <v-toolbar-title>Overview</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="" v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT')">
              Edit
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <div class="px-4">
          Address: {{ project.street1 }} {{ project.city }} {{ project.stateAbbreviation }} <br/>
          Contact: {{ formatPhoneNumber(project.mobile || project.phone) }} <br/>
          Email: {{ project.email }} <br/>
          Owner:
          <div class="mb-3" v-if="project && project.owner">{{ project.owner.fullName }} - {{
              project.owner.position
            }}<br/>
            {{ formatPhoneNumber(project.owner.phoneNumber) }}<br/>
          </div>
          <router-link :to="`/contact/${project.contactId}`">Go to contact</router-link>
          <v-divider class="mt-5"></v-divider>
        </div>
        <ActiveProcessSteps :project="project"></ActiveProcessSteps>
        <v-divider class="mt-5"></v-divider>
        <UpcomingEvents v-if="userHasEventsFeature" :projectId="projectId"/>
      </v-col>
      <v-col cols="5" class="router-view-column project-section">
          <router-view v-if="project && project.id" class="router-view" :project="project"></router-view>
      </v-col>
      <v-col cols="5" class="white-bg project-section">
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
import {getCompanyProjectStatusTypes, getStatusColor} from "@/services/projectStatusTypeService"

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
      collapseSidebar: false,
      statuses: [],
      getStatusColor,
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
  padding: 0 !important;
  overflow: hidden;
}

.project-header {
  height: 64px;
}

.project-split-container {
  height: calc(100% - 50px);
}

.router-view-column {
  overflow: auto;
}

.project-section {
  overflow: auto;
  max-height: calc(100% - 15px);
}

.white-bg {
  background-color: #fff;
}
</style>


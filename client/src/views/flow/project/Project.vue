<template>
  <div id="project-container">
    <!--    modal for editing project fields -->
    <v-dialog width="500" v-model="showEditProjectModal" content-class="square-card">
      <v-card class="px-6 py-4 square-card">
        <v-form ref="projectEditForm">
          <v-card-title
            color="blackText"
            class="text-h6 text-capitalize pa-0 font-weight-bold"
            primary-title>
            Project Overview
          </v-card-title>
          <v-card-text class="pt-4 px-0">
            <div>
              <v-text-field
                v-model="tempProject.projectName"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                label="Project Name"
              ></v-text-field>
              <v-text-field
                v-model="tempProject.street1"
                label="Street"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                @change="tempProject.reloadCoordinates = true"
              ></v-text-field>
              <v-text-field
                v-model="tempProject.city"
                label="City"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                @change="tempProject.reloadCoordinates = true"
              ></v-text-field>
              <v-text-field
                type="text"
                v-model="tempProject.postalCode"
                counter
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                maxlength="10"
                @keypress="isNumberOrHyphen"
                :rules="postalCodeRules"
                @change="tempProject.reloadCoordinates = true"
                label="Postal Code"
              ></v-text-field>
              <v-autocomplete v-model="tempProject.companyStateId"
                              :items="states"
                              label="State"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                              :loading="statesLoading"
                              item-text="state"
                              item-value="id"
                              @input="tempProject.reloadCoordinates = true"
              ></v-autocomplete>
              <v-select v-model="tempProject.companyCountryId"
                        :items="countries"
                        label="Country"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        :loading="countriesLoading"
                        @input="tempProject.reloadCoordinates = true"
                        item-text="country"
                        item-value="id"
              ></v-select>
            </div>
            <v-autocomplete v-model="tempProject.owner"
                            :readonly="projectOwnerFieldIsReadOnly()"
                            :disabled="projectOwnerFieldIsReadOnly()"
                            :items="availableOwners"
                            :loading="ownersLoading"
                            label="Project Owner"
                            clearable
                            item-text="fullName"
                            return-object
                            autocomplete="off">
            </v-autocomplete>
            <v-autocomplete v-model="tempProject.companyProjectStatusTypeId"
                            :items="statuses"
                            :readonly="projectStatusIsReadOnly()"
                            :disabled="projectStatusIsReadOnly()"
                            :loading="statusesLoading"
                            label="Project Stage"
                            item-text="projectStatusType"
                            item-value="id"
            />
          </v-card-text>
        </v-form>

        <v-card-actions class="pa-0">
          <v-btn @click="showEditProjectModal = false">
            cancel
          </v-btn>
          <v-spacer></v-spacer>
          <v-btn
            color="primaryCustom"
            class="white--text text-capitalize font-weight-bold"
            :disabled="!project.projectName"
            @click="validateForm()">
            Save
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <!--    end dialog -->
    <v-toolbar flat color="#E3E3E3" class="project-header" v-if="!projectLoading && project && project.id">
      <v-toolbar-title class="app-title font-size-18">
        <router-link :to="`/project/${project.id}/details`">{{ project.projectName }}</router-link>
        <span v-if="$store.state.project && $store.state.project.pps && $store.state.project.pps.processStepName">
          <v-icon class="mx-5" size="12">mdi-arrow-right</v-icon>
          <router-link class="breadcrumb" :to="`/project/${project.id}/processStep/${$store.state.project.pps.projectProcessStepId}?processStepId=${$store.state.project.pps.processStepId}&contactId=${project.contactId}`">
            {{$store.state.project.pps.processStepName}}
          </router-link>
        </span>
        <span v-if="$store.state.project && $store.state.project.ppsEvent && $store.state.project.ppsEvent.eventName">
          <v-icon class="mx-5" size="12">mdi-arrow-right</v-icon>
          <router-link class="breadcrumb" :to="`/project/${project.id}/processStep/${$store.state.project.pps.projectProcessStepId}/event/${$store.state.project.ppsEvent.id}`">
            {{$store.state.project.ppsEvent.eventName}} Event
          </router-link>
        </span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div>
          <v-btn color="#fff"
                 v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')"
                 class="mt-3 no-text-transform"
                 :to="`/projectAdmin/${projectId}`"
          >
            Project Admin
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-row class="project-split-container">
      <div class="white-bg project-section px-0"
           :class="{'col-2': !collapseLeftSidebar, 'collapse-left': collapseLeftSidebar}">
        <div class="left-expander-button">
          <v-btn small text @click="collapseLeftSidebar = !collapseLeftSidebar">
            <v-icon>mdi-menu</v-icon>
          </v-btn>
        </div>
        <div v-if="!collapseLeftSidebar && project && project.id" class="px-2 height-one-hunned overflow-y-auto">
          <v-toolbar flat class="project-section-header">
            <v-toolbar-title class="font-size-14">Overview</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn
                text x-small
                @click="[getStatesAndCountries(), getOwners(), getStatuses(), tempProject = cloneDeep(project), showEditProjectModal = true]"
                v-if="project && project.id && ($store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
                    || !projectOwnerFieldIsReadOnly() || !projectStatusIsReadOnly())">
                <v-icon>edit</v-icon>
              </v-btn>
            </v-toolbar-items>
          </v-toolbar>
          <div class="px-1 address-details">
            <div v-if="!projectStatusLoading">
              <span class="vertical-top project-detail-label">Project Stage:</span>
              <div class="d-inline-block project-detail-item"
                   :style="{'color': getStatusColor(project.projectStatusTypeId)}">
                {{ project.projectStatusType }} <br/>
                ({{ project.rootProjectStatusType }})
              </div>
            </div>
            <div class="mt-1">
              <span class="vertical-top project-detail-label">Address:</span>
              <div class="d-inline-block project-detail-item">
                {{ project.street1 }} <br/>
                {{ project.city }} {{ project.stateAbbreviation }} {{ project.postalCode }}
              </div>
            </div>
            <span class="project-detail-label">Contact:</span>
            <span class="project-detail-item">{{ formatPhoneNumber(project.mobile || project.phone) }}</span> <br/>
            <span class="project-detail-label">Email:</span>
            <span class="project-detail-item">{{ project.email }}</span> <br/>
            <div class="mt-1">
              <span class="vertical-top project-detail-label">Owner:</span>
              <div class="d-inline-block project-detail-item" v-if="project && project.owner">
                {{ project.owner.fullName }} - {{ project.owner.position }} <br/>
                {{ formatPhoneNumber(project.owner.phoneNumber) }}<br/>
              </div>
            </div>
            <div class="mt-3">
              <router-link class="font-size-12" :to="`/contact/${project.contactId}`">Go to contact</router-link>
            </div>
            <v-divider class="mt-5"></v-divider>
          </div>
          <ActiveProcessSteps :project="project" :update-key="updatePpsKey"></ActiveProcessSteps>
          <v-divider class=""></v-divider>
          <UpcomingEvents v-if="userHasEventsFeature"
                          :update-key="updateEventKey"
                          :projectId="projectId"/>
        </div>
      </div>
      <div class="project-section pt-0 px-0" :class="{'col-5': !collapseLeftSidebar && !collapseRightSidebar,
                                                                 'center-width-left-side-collapse': collapseLeftSidebar && !collapseRightSidebar,
                                                                 'center-width-right-side-collapse': !collapseLeftSidebar && collapseRightSidebar,
                                                                 'center-width-both-collapse': collapseLeftSidebar && collapseRightSidebar}">
        <router-view @refresh-upcoming-events="updateEventKey++"
                     @refresh-upcoming-pps="updatePpsKey++"
                     @refresh-project-status="getUpdatedProjectStatus()"
                     ref="childComponent"
                     v-if="project && project.id" class="router-view"
                     :project="project"
                     :split-value-columns="collapseLeftSidebar && collapseRightSidebar"
        ></router-view>
      </div>
      <div class="white-bg project-section px-0"
           :class="{'col-5': !collapseRightSidebar && !collapseLeftSidebar,
                    'right-width-left-side-collapse': collapseLeftSidebar && !collapseRightSidebar,
                    'collapse-right text-center': collapseRightSidebar}">
        <div class="right-expander-button">
          <v-btn small text @click="collapseRightSidebar = !collapseRightSidebar">
            <v-icon>mdi-menu</v-icon>
          </v-btn>
        </div>
        <ProjectActivity :is-collapsed="collapseRightSidebar"
                         v-if="!projectLoading"
                         @openRight="collapseRightSidebar = false"></ProjectActivity>
      </div>
    </v-row>
  </div>
</template>

<script>
import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  logError,
  getRequestWithParams,
  getSnackbar,
  formatPhoneNumber,
  isNumberOrHyphen
} from '@/helpers/helpers'
import cloneDeep from 'lodash.clonedeep'
import {AppMutations} from '@/stores/AppStore'
import ProjectActivity from '@/views/flow/project/ProjectActivity'
import ActiveProcessSteps from '@/views/flow/project/ActiveProcessSteps'
import UpcomingEvents from '@/views/flow/project/UpcomingEvents'
import {getCompanyProjectStatusTypes, getStatusColor} from "@/services/projectStatusTypeService"
import constants from "@/helpers/constants";
import {getCompanyStates} from "@/services/stateService";
import {getCountries} from "@/services/countryService";
import {ProjectMutations} from "@/stores/ProjectStore";

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
      cloneDeep,
      //used for if the make edits then hit cancel
      tempProject: {},
      updateEventKey: 0,
      updatePpsKey: 0,
      project: {},
      statusesLoading: true,
      projectStatusLoading: false,
      ownersLoading: true,
      statesLoading: true,
      countriesLoading: true,
      collapseLeftSidebar: false,
      collapseRightSidebar: false,
      showEditProjectModal: false,
      statuses: [],
      getStatusColor,
      availableOwners: [],
      postalCodeRules: constants.POSTAL_CODE_RULES,
      formatPhoneNumber,
      isNumberOrHyphen,
      states: [],
      countries: [],
      projectLoading: true,
      projectId: parseInt(this.$route.params.projectId),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      userHasEventsFeature: this.$store.getters.userHasFeature('EVENTS'),
    }
  },
  created() {
    //have to reset this on creation in case there is already a state then they go to the project url directly
    this.$store.commit(ProjectMutations.RESET_PROJECT_STATE)
    this.getProject()
  },
  watch: {
    '$route.params.processStepId': async function () {
      //when changing pps, the pps AND ppsEvent state need to be reset so we'll call the project reset for now
      this.$store.commit(ProjectMutations.RESET_PROJECT_STATE)
    },
    '$route.params.ppsEventId': function () {
      this.$store.commit(ProjectMutations.RESET_PPS_EVENT_STATE)
    },
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
    getUpdatedProjectStatus: async function () {
      //this gets called if an event gets run, in case it updated the project status
      this.projectStatusLoading = true
      try {
        const {data, status} = await getRequest(`/project/${this.projectId}/status`)
        if (data) {
          this.project.companyProjectStatusTypeId = data.companyProjectStatusTypeId
          this.project.projectStatusType = data.projectStatusType
          this.project.projectStatusTypeId = data.projectStatusTypeId
          this.project.rootProjectStatusType = data.rootProjectStatusType
        }
        this.projectStatusLoading = false
      } catch (e) {
        this.projectStatusLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
      }
    },
    getStatuses: async function () {
      try {
        this.statusesLoading = true
        const {data} = await getCompanyProjectStatusTypes(this.projectId)
        this.statuses = data
        this.statusesLoading = false
      } catch (e) {
        this.statusesLoading = false
        this.snackbar = getSnackbar('ERROR', 'Error fetching project statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    projectStatusIsReadOnly() {
      if (this.project.statusReadOnlyWhiteListedPositions?.length > 0) {
        return !this.$store.getters.userHasAnyPosition(this.project.statusReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
      } else {
        return this.project.statusReadOnly
      }
    },
    projectOwnerFieldIsReadOnly() {
      if (this.project.ownerReadOnlyWhiteListedPositions?.length > 0) {
        return !this.$store.getters.userHasAnyPosition(this.project.ownerReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
      } else {
        return this.project.ownerReadOnly
      }
    },
    updateStatus: async function () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        let params = {
          companyProjectStatusTypeId: this.tempProject.companyProjectStatusTypeId
        }
        const {data, status} = await postRequest(`/project/${this.projectId}/status`, params)
        this.tempProject.companyProjectStatusTypeId = data.companyProjectStatusTypeId
        this.tempProject.projectStatusType = data.projectStatusType
        this.tempProject.projectStatusTypeId = data.projectStatusTypeId
        this.tempProject.rootProjectStatusType = data.rootProjectStatusType
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating project status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    updateOwner: async function () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //we use tempProject to save values in case they cancel then it repopulates at the end
        const {status} = await putRequest(`/project/${this.projectId}/owner`, this.tempProject.owner || {userPositionId: null})
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getStatesAndCountries: function () {
      // only load countries and states if they try to edit the project address and they haven't already been loaded
      if (this.states.length === 0 || this.countries.length === 0) {
        this.getCompanyStates()
        this.getCountries()
      }
    },
    getCompanyStates: async function () {
      try {
        this.statesLoading = true
        const {data, status} = await getCompanyStates()
        this.states = data
        this.statesLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.statesLoading = false
      }
    },
    getCountries: async function () {
      try {
        this.countriesLoading = true
        const {data, status} = await getCountries()
        this.countries = data
        this.countriesLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Countries')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.countriesLoading = false
      }
    },
    async validateForm() {
      if (this.$refs.projectEditForm.validate()) {
        //these could be combined - just dont have time atm
        this.saveProjectAddressFields()
        this.updateOwner()
        //have to wait for this one to complete or it doesn't have the right values to display fresh ones
        await this.updateStatus()
        //set project values if they hit save
        this.project = cloneDeep(this.tempProject)
        this.showEditProjectModal = false
      }
    },
    saveProjectAddressFields: async function () {
      this.editAddress = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //temp project holds all the changes in case they cancel. use those values
        const {status} = await putRequest(`/project`, this.tempProject)
        this.snackbar = getSnackbar('SUCCESS', 'Project Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Address')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getOwners: async function () {
      try {
        this.ownersLoading = true
        const {data, status} = await getRequest(`/project/owners`)
        this.availableOwners = data
        this.ownersLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.ownersLoading = false
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Available Owners')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
  }
}
</script>

<style lang="scss">
.project-section-header .v-toolbar__content {
  padding-left: 5px !important;
  padding-right: 5px !important;
}
</style>

<style lang="scss" scoped>
#project-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow: hidden;
}

.project-detail-label {
  font-size: 12px;
  color: #9E9C9C;
}

.project-detail-item {
  font-size: 12px;
  color: #424242;
  margin-left: 5px;
}

.project-header {
  height: 64px;
}

.project-split-container {
  height: calc(100% - 50px);
  max-width: 100%;
  width: 100%;
  margin-right: 0 !important;
  margin-left: 0 !important;
}

.overflow-y-auto {
  overflow: auto;
}

.project-section {
  max-height: 100%;
}

.white-bg {
  background-color: #fff;
}

.collapse-left {
  width: 72px;
  padding: 12px;
}

.left-expander-button {
  margin-left: 10px;
}

.right-expander-button {
  margin-right: 10px;
  text-align: right;
}

.collapse-right {
  width: 72px;
  padding: 12px;
}

.center-width-left-side-collapse {
  width: calc(50% - 36px);
  padding: 10px !important;
}

.right-width-left-side-collapse {
  width: calc(50% - 36px);
  padding: 10px !important;
}

.center-width-right-side-collapse {
  width: calc(83.33% - 72px);
  padding: 10px !important;
}

.center-width-both-collapse {
  width: calc(100% - 144px);
  padding: 10px !important;
}

.breadcrumb {
  font-size: 12px;
}
</style>


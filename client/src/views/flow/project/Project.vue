<template>
  <div id="project-container">
    <!--    modal for editing project fields -->
    <ConfirmationDialog :open-dialog="showEditProjectModal" @confirm="validateForm" @close-dialog="showEditProjectModal = false">
      <template v-slot:title>Project Overview</template>
      <v-form ref="projectEditForm">
        <div>
          <div class="error-text" v-if="checkAddress">
            Please enter a valid project address.
          </div>
          <div class="error-text" v-else-if="!stateIsActive()">
            Project address is in a non-active state. Please update project address to an active state.
          </div>
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
          <div v-if="tempProject.companyStateId && !stateIsActive() && !editState">
            <v-text-field
              type="text"
              v-model="tempProject.state"
              :readonly="true"
              :disabled="true"
              label="State"
              hide-details
            ></v-text-field>
            <a class="edit-state-link" @click="editState = true">Click here to edit state</a>
          </div>
          <v-autocomplete v-else
                          v-model="tempProject.companyStateId"
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
      </v-form>
      <template v-slot:yes>Save</template>
    </ConfirmationDialog>
    <!--    end dialog -->
    <v-toolbar flat color="grey lighten-2" :class="{'project-header': project && !project.tags || project.tags.length === 0,
                                                    'project-header-with-tags': project && project.tags && project.tags.length > 0,
                                                    'pt-2': project && project.tags && project.tags.length > 0}"
               v-if="!projectLoading && project && project.id">
      <v-toolbar-title class="app-title albatross-header-1 align-center mt-3"
      :class="{'mt-4': project.tags && project.tags.length > 0}">
        <div>
          <router-link :to="`/project/${project.id}/details`">{{ project.projectName }}</router-link>
          <span v-if="$store.state.project && $store.state.project.pps && $store.state.project.pps.processStepName">
            <v-icon class="mx-4" size="20">mdi-chevron-right</v-icon>
            <router-link class="breadcrumb albatross-body-2" :to="`/project/${project.id}/processStep/${$store.state.project.pps.projectProcessStepId}`">
              {{$store.state.project.pps.processStepName}}
            </router-link>
          </span>
          <span v-if="$store.state.project && $store.state.project.ppsEvent && $store.state.project.ppsEvent.eventName">
            <v-icon class="mx-4" size="20">mdi-chevron-right</v-icon>
            <router-link class="breadcrumb albatross-body-2" :to="`/project/${project.id}/processStep/${$store.state.project.pps.projectProcessStepId}/event/${$store.state.project.ppsEvent.id}`">
              {{$store.state.project.ppsEvent.eventName}} Event
            </router-link>
          </span>
        </div>
        <div class="mt-2">
          <v-chip v-for="(tag, idx) in project.tags"
                  small
                  class="tag-chip"
                  :color="tag.bgColor"
                  :text-color="tag.fontColor"
                  :close="tag.removable"
                  :class="{'ml-2': idx !== 0}">
            {{tag.tagName}}
          </v-chip>
        </div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div>
          <v-btn color="#fff"
                 v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADMIN') || $store.getters.userHasFeatureAccessLevel('PROJECTS', 'DELETE')"
                 class="mt-3 no-text-transform primary--text"
                 :to="`/projectAdmin/${projectId}`"
          >
            Project Admin
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar >
<!--    <v-toolbar flat color="grey lighten-2" id="tag-toolbar" v-if="project.tags && project.tags.length > 0">-->
<!--    </v-toolbar>-->
    <v-row class="project-split-container" :class="{'split-container-no-tags': project && !project.tags || project.tags.length === 0,
                                                    'split-container-with-tags': project && project.tags && project.tags.length > 0}">
      <div class="white-bg project-section px-0 left-panel"
           :class="{'col-2': !$store.state.project.leftSideSplit, 'collapse-left': $store.state.project.leftSideSplit}">
        <div class="left-expander-button ml-3" :class="{'title-collapsed': $store.state.project.leftSideSplit}">
          <v-btn small text color="primary" @click="collapseSide('left')" >
            <v-icon>mdi-menu</v-icon>
          </v-btn>
        </div>
        <div v-if="!$store.state.project.leftSideSplit && project && project.id" class="px-2 left-panel-scrollable-area overflow-y-auto">
          <PageOverview
            page-name="Project"
            :show-edit-btn="($store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT') && userCanEdit)"
            @clickEdit="showEditModal()"
            :details="overviewDetails"
          ></PageOverview>
          <div class="mx-4 address-details">
            <div class="mt-3">
              <router-link class="font-size-12" :to="`/contact/${project.contactId}`">Go to contact</router-link>
            </div>
          </div>
          <v-divider class="mt-6"></v-divider>
          <ActiveProcessSteps :project="project" :update-key="updatePpsKey" class="mx-2"></ActiveProcessSteps>
          <v-divider class="mb-3"></v-divider>
          <ActiveEvents v-if="userHasEventsFeature"
                          :update-key="updateEventKey"
                          :projectId="projectId"
                          class="mx-2"/>
        </div>
      </div>
      <div class="project-section center-panel pt-0 px-0" :class="{'col-5': !$store.state.project.leftSideSplit && !$store.state.project.rightSideSplit,
                                                                 'center-width-left-side-collapse': $store.state.project.leftSideSplit && !$store.state.project.rightSideSplit,
                                                                 'center-width-right-side-collapse': !$store.state.project.leftSideSplit && $store.state.project.rightSideSplit,
                                                                 'center-width-both-collapse': $store.state.project.leftSideSplit && $store.state.project.rightSideSplit}">
        <router-view @refresh-upcoming-events="updateEventKey++"
                     @refresh-upcoming-pps="updatePpsKey++"
                     @refresh-project-status="getUpdatedProjectStatus()"
                     ref="childComponent"
                     v-if="project && project.id" class="router-view"
                     :project="project"
        ></router-view>
      </div>
      <div class="project-section px-0 white-bg "
           :class="{'col-5': !$store.state.project.rightSideSplit && !$store.state.project.leftSideSplit,
                    'right-width-left-side-collapse': $store.state.project.leftSideSplit && !$store.state.project.rightSideSplit,
                    'collapse-right text-center': $store.state.project.rightSideSplit}">
        <ProjectActivity v-if="!projectLoading"  :show-sms-tab="true"
                         @openRight="$store.state.project.rightSideSplit = false"></ProjectActivity>
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
import ActiveEvents from '@/views/flow/project/ActiveEvents'
import {getCompanyProjectStatusTypes, getStatusColorClass} from "@/services/projectStatusTypeService"
import constants from "@/helpers/constants";
import {getActiveStates} from "@/services/stateService";
import {getCountries} from "@/services/countryService";
import {ProjectMutations} from "@/stores/ProjectStore";
import ConfirmationDialog from "@/components/ConfirmationDialog";
import PageOverview from "../PageOverview";
import debounce from 'lodash.debounce'
import {NotificationActions} from "@/plugins/notifications/NotificationStore";

export default {
  name: 'Project',
  components: {
    PageOverview,
    ConfirmationDialog,
    ProjectActivity,
    ActiveProcessSteps,
    ActiveEvents
  },
  data() {
    return {
      snackbar: {},
      cloneDeep,
      editState: false,
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
      showEditProjectModal: false,
      checkAddress: this.$route.query?.checkAddress === 'true',
      statuses: [],
      getStatusColorClass,
      availableOwners: [],
      postalCodeRules: constants.POSTAL_CODE_RULES,
      formatPhoneNumber,
      isNumberOrHyphen,
      states: [],
      countries: [],
      projectLoading: true,
      projectId: parseInt(this.$route.params.projectId),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      is7oaksAdmin: this.$store.getters.isFullAdmin,
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
    projectTagEvents: async function () {
      if(this.projectTagEvents?.length > 0) {
        this.$store.dispatch(NotificationActions.PROCESS_PROJECT_MSG, this.projectId)
        await this.getProjectTags()
      }
    }
  },
  computed: {
    projectTagEvents() {
      return this.$store.getters.getEventsByTopic('project_tag')?.filter(e => e.projectId === this.projectId)
    },
    projectStage() {
      return this.statuses?.find(s => s.id === this.project.companyProjectStatusTypeId)?.rootProjectStatusType
    },
    overviewDetails(){
      return [
        {
          label: 'Project Stage',
          type: constants.OVERVIEW_FIELD_TYPES.STATUS,
          value: this.project.projectStatusType,
          statusType: this.project.rootProjectStatusType,
          statusTypeId: this.project.projectStatusTypeId,
        },
        {
          label: 'Address',
          type: constants.OVERVIEW_FIELD_TYPES.ADDRESS,
          value: {
            street: this.project.street1,
            city: this.project.city,
            state: this.project.stateAbbreviation,
            zip: this.project.postalCode
          }
        },
        {
          label: 'Phone',
          type: constants.OVERVIEW_FIELD_TYPES.PHONE,
          value: this.project.phone,
        },
        {
          label: 'Mobile',
          type: constants.OVERVIEW_FIELD_TYPES.PHONE,
          value: this.project.mobile
        },
        {
          label: 'Email',
          type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
          value: this.project.email
        },
        {
          label: 'Owner',
          type: constants.OVERVIEW_FIELD_TYPES.OWNER,
          value: this.project.owner
        }
      ]
    }
  },
  mounted() {
  },
  methods: {
    stateIsActive() {
      //states is already a list of company states
      let companyStateIds = this.states.map(s => s.id)
      return companyStateIds.includes(this.tempProject.companyStateId)
    },
    collapseSide(side) {
      if(side === 'left') {
        this.$store.commit(ProjectMutations.LEFT_SIDE_COLLAPSE)
      } else {
        this.$store.commit(ProjectMutations.RIGHT_SIDE_COLLAPSE)
      }
    },
    async showEditModal() {
      //doing all this in a method so we can call it when the page loads if needed
      let requests = [
        this.getStatesAndCountries(),
        this.getOwners(),
        this.getStatuses()
      ]
      await Promise.all(requests)
      this.tempProject = cloneDeep(this.project)
      this.showEditProjectModal = true
    },
    getProject: async function () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/project/${this.projectId}`)
        this.project = data
        window.document.title = `${this.project.projectName} - Project Details`
        if(this.checkAddress) {
          this.showEditModal()
        }
        this.projectLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.projectLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
      }
    },
    getProjectTags: async function () {
      try {
        const {data, status} = await getRequestWithParams(`/tag/project/${this.projectId}`,
          {skipCancel: true }, null, [])
        this.project.tags = data
      } catch (e) {
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
      if(this.is7oaksAdmin) {
        return false
      } else if (this.project.statusReadOnlyWhiteListedPositions?.length > 0) {
        return !this.$store.getters.userHasAnyPosition(this.project.statusReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
      } else {
        return this.project.statusReadOnly
      }
    },
    projectOwnerFieldIsReadOnly() {
      if(this.is7oaksAdmin) {
        return false
      } else if (this.project.ownerReadOnlyWhiteListedPositions?.length > 0) {
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
        const {data, status} = await getActiveStates()
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
        //set project values if they hit save, have to update state stuff differently cuz there are multiple values needed
        let selectedState = this.states.find(s => s.id === this.tempProject.companyStateId)
        this.tempProject.state = selectedState?.state || null
        this.tempProject.stateAbbreviation = selectedState?.abbreviation || null
        //if they entered a valid address then stop asking for it
        if(this.tempProject.companyStateId && this.stateIsActive()) {
          this.$router.replace({'query': null})
          this.checkAddress = false
        }
        this.project = cloneDeep(this.tempProject)
        this.showEditProjectModal = false
      }
    },
    saveProjectAddressFields: async function () {
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
#tag-toolbar {
  height: 35px !important;

  .v-toolbar__content {
    align-items: start;
    height: 35px !important;
  }
}
.project-section-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.app-title, .breadcrumb {
  a {
    text-decoration-line: none;
  }
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
  font-size: 0.875rem;
  margin-left: 5px;
  overflow-wrap: break-word;
}

.project-header {
  height: 64px;
}

.project-header-with-tags {
  height: 94px !important;
}

.project-split-container {
  max-width: 100%;
  width: 100%;
  margin-right: 0 !important;
  margin-left: 0 !important;
}

.split-container-no-tags {
  height: calc(100% - 50px);
}

.split-container-with-tags {
  height: calc(100% - 80px);
}

.overflow-y-auto {
  overflow: auto;
}

.project-section {
  max-height: 100%;
  padding-top: 24px;
}

.left-panel-scrollable-area {
  height: calc(100% - 30px);
}

.project-section.left-panel,
.project-section.center-panel {
  //box-shadow: 1px 0px 1px #C4C4C4;
  //the way the center and right panels sit on each other the box shadow just wasn't working - going to try this border and see if they care
  border-right: solid #C4C4C4 1px;
}

.white-bg {
  background-color: #fff !important;
}

.collapse-left {
  width: 72px;
  padding: 12px;
}

//.left-expander-button {
//  margin-left: 10px;
//}

.title-collapsed {
  margin-top: 12px;
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
  padding: 24px 10px 10px 10px !important;
}

.tag-chip {
  font-weight: 600;
}


.center-width-right-side-collapse {
  width: calc(83.33% - 72px);
  padding: 10px !important;
}

.center-width-both-collapse {
  width: calc(100% - 144px);
  padding: 10px !important;
}

.edit-state-link {
  margin-bottom: 3px;
  font-size: 11px;
}


</style>


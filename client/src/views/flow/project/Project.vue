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
        {{ project.projectName }}
<!--        <div class="d-inline-block">-->
<!--          <v-autocomplete-->
<!--            v-if="!statusesLoading && statuses.length > 0"-->
<!--            class="ml-5"-->
<!--            v-model="project.companyProjectStatusTypeId"-->
<!--            :items="statuses"-->
<!--            :readonly="!userCanEdit || projectStatusIsReadOnly()"-->
<!--            :disabled="!userCanEdit || projectStatusIsReadOnly()"-->
<!--            item-text="projectStatusType"-->
<!--            item-value="id"-->
<!--            solo-->
<!--            dense-->
<!--            hide-details-->
<!--            :background-color="getStatusColor(project.projectStatusTypeId)"-->
<!--            @change="updateStatus"-->
<!--          />-->
<!--        </div>-->
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
      <div class="white-bg project-section overflow-y-auto"
           :class="{'col-3': !collapseLeftSidebar, 'collapse-left text-center': collapseLeftSidebar}">
        <v-btn small text @click="collapseLeftSidebar = !collapseLeftSidebar">
          <v-icon>mdi-menu</v-icon>
        </v-btn>
        <div v-if="!collapseLeftSidebar && project && project.id">
          <v-toolbar flat class="project-section-header">
            <v-toolbar-title class="font-size-14">Overview</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <div class="pt-3">
                <v-btn
                  @click="[getStatesAndCountries(), getOwners(), getStatuses(), tempProject = cloneDeep(project), showEditProjectModal = true]"
                  v-if="project && project.id && ($store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
                      || !projectOwnerFieldIsReadOnly() || !projectStatusIsReadOnly())">
                  Edit
                </v-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
          <div class="px-1 address-details">
            <div>
              <span class="vertical-top project-detail-label">Project Stage:</span>
              <div class="d-inline-block project-detail-item" :style="{'color': getStatusColor(project.projectStatusTypeId)}">
                {{ project.projectStatusType }} <br/>
                ({{project.rootProjectStatusType}})
              </div>
            </div>
            <div class="mt-1">
              <span class="vertical-top project-detail-label">Address:</span>
              <div class="d-inline-block project-detail-item">
                {{ project.street1 }} <br/>
                {{ project.city }} {{project.stateAbbreviation }} {{project.postalCode}}
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
          <ActiveProcessSteps :project="project"></ActiveProcessSteps>
          <v-divider class=""></v-divider>
          <UpcomingEvents v-if="userHasEventsFeature" :projectId="projectId"/>
        </div>
      </div>
      <div class="overflow-y-auto project-section" :class="{'col-5': !collapseLeftSidebar && !collapseRightSidebar,
                                                                 'center-width-left-side-collapse': collapseLeftSidebar && !collapseRightSidebar,
                                                                 'center-width-right-side-collapse': !collapseLeftSidebar && collapseRightSidebar,
                                                                 'center-width-both-collapse': collapseLeftSidebar && collapseRightSidebar}">
        <router-view v-if="project && project.id" class="router-view" :project="project"></router-view>
      </div>
      <div class="white-bg project-section"
           :class="{'col-4': !collapseRightSidebar, 'collapse-right text-center': collapseRightSidebar}">
        <div :class="{'text-right': !collapseRightSidebar}">
          <v-btn small text @click="collapseRightSidebar = !collapseRightSidebar">
            <v-icon>mdi-menu</v-icon>
          </v-btn>
        </div>
        <ProjectActivity v-if="!collapseRightSidebar"></ProjectActivity>
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
      project: {},
      statusesLoading: true,
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
    this.getProject()
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
    validateForm() {
      if (this.$refs.projectEditForm.validate()) {
        //set project values if they hit save
        this.project = cloneDeep(this.tempProject)
        //these could be combined - just dont have time atm
        this.saveProjectAddressFields()
        this.updateOwner()
        this.updateStatus()
        this.showEditProjectModal = false
      }
    },
    saveProjectAddressFields: async function () {
      this.editAddress = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/project`, this.project)
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
  max-height: calc(100% - 15px);
}

.white-bg {
  background-color: #fff;
}

.collapse-left {
  width: 104px;
  padding: 10px;
}

.collapse-right {
  width: 104px;
  padding: 10px;
}

.center-width-left-side-collapse {
  width: calc(66.66% - 104px);
  padding: 10px !important;
}

.center-width-right-side-collapse {
  width: calc(75% - 104px);
  padding: 10px !important;
}

.center-width-both-collapse {
  width: calc(100% - 208px);
  padding: 10px !important;
}
</style>


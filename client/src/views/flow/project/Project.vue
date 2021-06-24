<template>
  <v-row id="project-container" v-if="!projectLoading && project && project.id">
    <v-dialog width="500" v-model="unsavedFieldsModal">
      <v-card>
        <v-card-title
          class="headline grey lighten-2"
          primary-title
        >
          Confirm
        </v-card-title>

        <v-card-text class="pt-4">
          You have unsaved {{getDirtyText()}}. <br/>
          Are you sure you want to continue without saving?
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            @click="unsavedFieldsModal = false">
            No
          </v-btn>
          <v-btn
            color="primaryCustom"
            text
            @click="[navigationOverride = true, goToPath(toPath)]">
            Yes
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-col cols="12" class="py-0">
      <v-row>
        <v-col cols="12" class="pb-0">
          <v-row class="project-header">
            <v-col cols="5" class="text-left pl-5">
              <v-breadcrumbs :items="breadcrumbs" class="pl-0 pt-0 pb-2"></v-breadcrumbs>
              <div class="project-title">
                <router-link v-if="$store.getters.userHasFeature('CONTACTS')"
                             :to="`/contact/${project.contactId}`">
                  {{ project.projectName}} <span v-if="project.mobile">- {{ formatPhoneNumber(project.mobile) }}</span>
                </router-link>
                <span v-else>{{ project.projectName}}</span>
                <br/>
                <span class="project-created">Created By: {{project.createdBy}} - {{project.dateCreated | formatDate('timestamp')}}</span>
              </div>
              <div class="project-subtitle">
                <span v-if="!editAddress">{{ project.street1 }} - {{ project.city }}, {{ project.state }} {{ project.postalCode }}</span>
                <div v-else-if="userCanEdit" class="mt-4">
                  <v-form ref="projectEditForm">
                    <v-text-field
                      v-model="project.projectName"
                      label="ProjectName"
                    ></v-text-field>
                    <v-text-field
                      v-model="project.street1"
                      label="Street"
                    ></v-text-field>
                    <v-text-field
                      v-model="project.city"
                      label="City"
                    ></v-text-field>
                    <v-text-field
                      type="text"
                      v-model="project.postalCode"
                      counter
                      maxlength="10"
                      @keypress="isNumberOrHyphen"
                      :rules="postalCodeRules"
                      label="Postal Code"
                    ></v-text-field>
                    <v-select v-model="project.companyStateId"
                              :items="states"
                              label="State"
                              item-text="state"
                              item-value="id"
                    ></v-select>
                    <v-select v-model="project.companyCountryId"
                              :items="countries"
                              label="Country"
                              item-text="country"
                              item-value="id"
                    ></v-select>
                  </v-form>
                </div>
                <v-btn x-small text v-if="userCanEdit"
                       @click="[editAddress = !editAddress, project.reloadCoordinates = true, getStatesAndCountries()]">
                  <span v-if="editAddress">Cancel</span>
                  <v-icon v-else>edit</v-icon>
                </v-btn>
                <v-btn small color="primaryCustom"
                       :disabled="!project.projectName"
                       class="white--text" v-if="editAddress" @click="validateForm">
                  Save
                </v-btn>
              </div>
            </v-col>
            <v-col cols="4" class="lead-owner pb-2 text-right">
              <div class="d-inline-block mr-4" v-if="project.companyId !== this.companyId">
                <v-avatar
                  :tile="false"
                  :size="25"
                  color="#D6D6D6"
                  class="account-img mr-2"
                >
                  <v-icon color="white" size="20">mdi-office-building</v-icon>
                </v-avatar>
                <span>{{project.companyName}}</span><br/>
                <span class="project-company-subheader">Company</span>
              </div>
              <div v-if="!displayChangeOwner" class="d-inline-block">
                <div v-if="project.owner && project.owner.userId">
                  <v-avatar
                    :tile="false"
                    :size="25"
                    color="grey lighten-4"
                    class="account-img mr-2"
                  >
                    <img name="accountImg" src="../../../assets/flow/user_img_placeholder.png">
                  </v-avatar>
                  {{project.owner.fullName}}<br/>
                  {{project.owner.position}}
                </div>
              </div>
              <div v-if="displayChangeOwner && !projectOwnerIsReadOnly()">
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
              <v-btn text x-small class="change-owner-button"
                     v-if="!projectOwnerIsReadOnly()"
                     @click="[displayChangeOwner = !displayChangeOwner, getOwners()]">
                <span v-if="displayChangeOwner">cancel</span>
                <span v-else-if="project.owner && project.owner.userId">change</span>
                <span v-else>add owner</span>
              </v-btn>
            </v-col>
            <v-col cols="3" class="pb-2 text-right">
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
              <div class="text-left project-stage" v-if="Object.keys(project).length > 0 && project.companyProjectStatusTypeId !== null && statuses.length > 0">
                Status: {{ projectStage }}
              </div>
            </v-col>
          </v-row>
        </v-col>
      </v-row>
      <v-divider></v-divider>
      <v-row>
        <v-col cols="12" md="6">
          <!-- this v-model crap makes absolutely no sense to me but this is working so i am pushing it up -->
          <v-tabs v-if="tabs.length > 0"
                  background-color="transparent"
                  v-model="selectedTab.uniqueIdentifier"
                  show-arrows>
            <!--   todo: turn this into v-tabs in extension if constants.IS_MOBILE           -->
            <v-tab v-for="t in tabs" :key="t.id"
                   @click="selectedTab = t">
              {{t.tabName}}
            </v-tab>
          </v-tabs>
          <v-tabs v-else background-color="transparent">
            <v-tab>
              Project Details
            </v-tab>
          </v-tabs>
          <ProjectDetails ref="projectDetails" :project="project" :selected-tab="selectedTab"></ProjectDetails>

        </v-col>
        <v-col cols="12" md="6">
          <v-toolbar flat dense class="app-toolbar" color="transparent">
            <v-spacer></v-spacer>
            <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
              <v-tabs background-color="transparent">
                <!--   todo: turn this into v-tabs in extension if constants.IS_MOBILE           -->
                <v-tab @click="secondaryTab = 1">
                  Process Steps
                </v-tab>
                <v-tab @click="secondaryTab = 2">
                  Notes
                </v-tab>
                <v-tab @click="secondaryTab = 3">
                  Communication
                </v-tab>
              </v-tabs>
            </v-toolbar-items>
          </v-toolbar>
          <ActiveProcessSteps v-if="secondaryTab === 1" :project="project"></ActiveProcessSteps>
          <ProjectNotes ref="projectNotes" v-if="secondaryTab === 2"></ProjectNotes>
          <Messaging v-if="secondaryTab === 3" :primaryId="parseInt(projectId)"/>
        </v-col>
      </v-row>


    </v-col>

  </v-row>
  <v-row align="center" justify="center" v-else-if="!projectLoading">
    <v-col cols="12" sm="8">
      <v-card color="secondaryMaster" class="elevation-12 pb-5">
        <v-toolbar dark color="red">
          <v-toolbar-title>Error</v-toolbar-title>
        </v-toolbar>
        <v-card-text class="login-card-text">
          This project either doesn't exist or you don't have access to it in this context.
        </v-card-text>
        <v-card-actions class="justify-center">
          <v-btn to="/projects">Click here to go back to Projects</v-btn>
        </v-card-actions>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
  import {getRequest, putRequest, postRequest, isNumberOrHyphen, logError, getRequestWithParams, getSnackbar, formatPhoneNumber } from '@/helpers/helpers'
  import {AppMutations} from '@/stores/AppStore'
  import {getCompanyProjectStatusTypes} from '@/services/projectStatusTypeService'
  import ProjectDetails from '@/views/flow/project/ProjectDetails'
  import ActiveProcessSteps from '@/views/flow/project/ActiveProcessSteps'
  import ProjectNotes from '@/views/flow/project/ProjectNotes'
  import Messaging from '@/views/flow/components/Messaging'
  import constants from '@/helpers/constants'
  import {getCountries} from '@/services/countryService'
  import {getCompanyStates} from '@/services/stateService'

  export default {
    name: 'Project',
    components: {
      ProjectDetails,
      ActiveProcessSteps,
      ProjectNotes,
      Messaging
    },
    data() {
      return {
        snackbar: {},
        tabs: [],
        tabsLoading: true,
        selectedTab: {},
        secondaryTab: 1,
        isNumberOrHyphen,
        menuOpen: false,
        constants,
        postalCodeRules: constants.POSTAL_CODE_RULES,
        formatPhoneNumber,
        projectId: parseInt(this.$route.params.projectId),
        companyId: this.$store.state.user.details.companyId,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
        displayChangeOwner: false,
        availableOwners: [],
        editAddress: false,
        statuses: [],
        project: {},
        states: [],
        unsavedFieldsModal: false,
        toPath: null,
        navigationOverride: false,
        hasDirtyNotes: false,
        dirtyFieldsCount: null,
        countries: [],
        projectLoading: true,
        breadcrumbs: [
          {
            text: 'Back to Projects',
            disabled: false,
            exact: true,
            to: `/projects`
          },
        ]
      }
    },
    created() {
      this.getProject()
      this.getStatuses()
      this.getProjectTabs()
    },
    beforeRouteLeave (to, from, next) {
      // has to get the dirty fields count from the child component then do the route nav protection here in the parent
      this.dirtyFieldsCount = this.$refs.projectDetails.getDirtyFieldsCount()

      if(typeof this.$refs.projectNotes?.hasDirtyNotes === 'function') {
        this.hasDirtyNotes = this.$refs.projectNotes.hasDirtyNotes()
      }

      if (this.navigationOverride || (this.dirtyFieldsCount === 0 && !this.hasDirtyNotes)) {
        //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
        next()
      } else {
        this.toPath = to.path
        this.unsavedFieldsModal = true
      }
    },
    computed: {
      projectStage() {
        return this.statuses?.find(s => s.id === this.project.companyProjectStatusTypeId)?.rootProjectStatusType
      }
    },
    mounted () {
      // Navigate to the Communication tab if coming from SMS Queue screen
      if (this.$route.query.secondaryTab != null && parseInt(this.$route.query.secondaryTab) == 3) {
        this.secondaryTab = 3
      }
    },
    methods: {
      getDirtyText() {
        return this.hasDirtyNotes && this.dirtyFieldsCount > 0 ?
          'fields and notes' : this.hasDirtyNotes ? 'notes' : 'fields'
      },
      goToPath(path) {
        this.$router.push(path)
      },
      projectOwnerIsReadOnly() {
        if(this.project.ownerReadOnlyWhiteListedPositions?.length > 0) {
          return !this.$store.getters.userHasAnyPosition(this.project.ownerReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
        } else {
          return this.project.ownerReadOnly
        }
      },
      projectStatusIsReadOnly() {
        if(this.project.statusReadOnlyWhiteListedPositions?.length > 0) {
          return !this.$store.getters.userHasAnyPosition(this.project.statusReadOnlyWhiteListedPositions?.map(wlp => wlp.positionId))
        } else {
          return this.project.ownerReadOnly
        }
      },
      validateForm() {
        if (this.$refs.projectEditForm.validate()) {
          this.saveProjectAddress()
        }
      },
      getProjectTabs: async function () {
        this.tabsLoading = true
        try {
          let params = {
            projectId: parseInt(this.projectId)
          }
          const {data} = await getRequestWithParams(`/objectTypeTab/project`, {params})
          this.tabs = data
          this.selectedTab = this.tabs?.length > 0 ? data[0] : {}
        } catch (e) {
          logError(e)
        } finally {
          this.tabsLoading = false
        }
      },
      getProject: async function () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/project/${this.projectId}`)
          this.project = data
          window.document.title = `${this.project.projectName} - Project Details`
          this.projectLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          this.projectLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
          logError(e)
        }
      },
      updateOwner: async function () {
        this.displayChangeOwner = false
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/project/${this.projectId}/owner`, this.project.owner)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Owner')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.$store.commit(AppMutations.SET_LOADING, false)
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
      updateStatus: async function () {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await postRequest(`/project/${this.projectId}/status`, this.project)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error updating project status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      saveProjectAddress: async function () {
        this.editAddress = false
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/project`, this.project)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Address')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
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
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyStates()
          this.states = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getCountries: async function () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCountries()
          this.countries = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Countries')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getOwners: async function () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/project/owners`)
          this.availableOwners = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Available Owners')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss" scoped>
  #project-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .project-created {
    font-size: 12px;
    color: grey;
    font-style: italic;
  }

  .project-company-subheader {
    font-size: 12px;
  }

  .project-stage {
    font-size: 12px;
    margin-top: -10px;
  }
</style>


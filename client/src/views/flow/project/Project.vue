<template>
  <v-row id="project-container" v-if="!projectLoading && project && project.id">
    <v-col cols="12" class="py-0">
      <v-row>
        <v-col cols="12" class="pb-0">
          <v-row class="project-header">
            <v-col cols="6" class="text-left pl-5">
              <v-breadcrumbs :items="breadcrumbs" class="pl-0 pt-0 pb-2"></v-breadcrumbs>
              <div class="project-title">
                <router-link v-if="$store.getters.userHasFeature('CONTACTS')"
                             :to="`/contact/${project.contactId}`">
                  {{ project.projectName}}
                </router-link>
                <span v-else>{{ project.projectName}}</span>
                <br/>
                <span class="project-created">{{project.createdBy}} - {{project.dateCreated | formatDate('timestamp')}}</span>
              </div>
              <div class="project-subtitle">
                <span v-if="!editAddress">{{ project.street1 }} - {{ project.city }}, {{ project.state }} {{ project.postalCode }}</span>
                <div v-else-if="userCanEdit" class="mt-4">
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
                    v-model="project.postalCode"
                    counter
                    maxlength="10"
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
                </div>
                <v-btn x-small text v-if="userCanEdit" @click="[editAddress = !editAddress, project.reloadCoordinates = true, getStatesAndCountries()]">
                  <span v-if="editAddress">Cancel</span>
                  <v-icon v-else>edit</v-icon>
                </v-btn>
                <v-btn small color="primaryCustom"
                       :disabled="!project.projectName"
                       class="white--text" v-if="editAddress" @click="saveProjectAddress">
                  Save
                </v-btn>
              </div>
            </v-col>
            <v-col cols="3" class="lead-owner pb-2 text-right">
              <div v-if="!displayChangeOwner">
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
              <div v-if="displayChangeOwner && !project.projectOwnerReadonly">
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
                     v-if="!project.projectOwnerReadonly"
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
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                item-text="projectStatusType"
                item-value="id"
                @change="updateStatus"
                label="Project Status"
              />
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
          <ProjectDetails :project="project" :selected-tab="selectedTab"></ProjectDetails>

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
          <ProjectNotes v-if="secondaryTab === 2"></ProjectNotes>
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
import {getRequest, putRequest, postRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
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
  data () {
    return {
      snackbar: {},
      tabs: [],
      tabsLoading: true,
      selectedTab: {},
      secondaryTab: 1,
      menuOpen: false,
      constants,
      projectId: parseInt(this.$route.params.projectId),
      companyId: this.$store.state.user.details.companyId,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      displayChangeOwner: false,
      availableOwners: [],
      editAddress: false,
      statuses: [],
      project: {},
      states: [],
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
  created () {
    this.getProject()
    this.getStatuses()
    this.getProjectTabs()
  },
  methods: {
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
        window.document.title = `Project Details - ${this.project.projectName}`
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
        const {data} = await getRequestWithParams('/project/status', { params: {
          projectId: this.projectId
        }})
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
      }  catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating project status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    saveProjectAddress: async function() {
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
      if(this.states.length === 0 || this.countries.length === 0) {
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
      console.log('hello')
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
</style>


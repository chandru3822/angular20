<template>
  <v-row id="project-container">
    <v-col cols="12" class="py-0">
      <v-row>
        <v-col cols="12" class="pb-0">
          <v-row class="project-header">
            <v-col cols="10" class="text-left pl-5">
              <v-breadcrumbs :items="breadcrumbs" class="pl-0 pt-0 pb-2"></v-breadcrumbs>
              <div class="project-title">
                <router-link :to="`/project/${project.id}/details`">{{ project.projectName}}</router-link>
              </div>
              <div class="project-subtitle">
                <span v-if="!editAddress">{{ project.street1 }} - {{ project.city }}, {{ project.state }} {{ project.postalCode }}</span>
                <div v-else>
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
                    label="Postal Code"
                  ></v-text-field>
                  <v-select v-model="project.stateId"
                            :items="states"
                            label="State"
                            item-text="state"
                            item-value="id"
                  ></v-select>
                  <v-select v-model="project.countryId"
                            :items="countries"
                            label="Country"
                            item-text="country"
                            item-value="id"
                  ></v-select>
                </div>
                <v-btn x-small text @click="[editAddress = !editAddress, getStatesAndCountries()]">
                  <span v-if="editAddress">Cancel</span>
                  <v-icon v-else>edit</v-icon>
                </v-btn>
                <v-btn small color="primaryCustom" dark class="white--text" v-if="editAddress" @click="saveProjectAddress">
                  Save
                </v-btn>
              </div>
            </v-col>
            <v-col cols="2" class="lead-owner pb-2 text-right">
<!--   todo: do we actually allow a project_owner anymore? i thought we took it out -->
<!--              <div v-if="!displayChangeOwner">-->
<!--                <div v-if="project.owner && project.owner.userId">-->
<!--                  <v-avatar-->
<!--                    :tile="false"-->
<!--                    :size="25"-->
<!--                    color="grey lighten-4"-->
<!--                    class="account-img mr-2"-->
<!--                  >-->
<!--                    <img name="accountImg" src="../../../assets/user_img_placeholder.png">-->
<!--                  </v-avatar>-->
<!--                  {{project.owner.fullName}}<br/>-->
<!--                  {{project.owner.position}}-->
<!--                </div>-->
<!--              </div>-->
<!--              <div v-if="displayChangeOwner">-->
<!--                <v-autocomplete v-model="project.owner"-->
<!--                                :items="availableOwners"-->
<!--                                label="Select Owner"-->
<!--                                item-text="fullName"-->
<!--                                return-object-->
<!--                                autocomplete="off"-->
<!--                                @change="updateOwner"-->
<!--                >-->
<!--                </v-autocomplete>-->
<!--              </div>-->
<!--              <v-btn text x-small class="change-owner-button" @click="displayChangeOwner = !displayChangeOwner">-->
<!--                <span v-if="displayChangeOwner">cancel</span>-->
<!--                <span v-else-if="project.owner && project.owner.userId">change</span>-->
<!--                <span v-else>add owner</span>-->
<!--              </v-btn>-->
              <v-select
                v-model="project.companyProjectStatusTypeId"
                :items="statuses"
                item-text="projectStatusType"
                item-value="id"
                @change="updateStatus"
                label="Status"
              />
            </v-col>
          </v-row>
        </v-col>
      </v-row>
      <v-divider></v-divider>
      <v-row>
        <v-col cols="12">
          <v-toolbar flat class="app-toolbar" color="transparent">
            <v-spacer></v-spacer>
            <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
              <v-tabs background-color="transparent">
                <!--   todo: turn this into v-tabs in extension if constants.IS_MOBILE           -->
                <v-tab :to="`/project/${this.projectId}/details`">
                  Project Details
                </v-tab>
                <v-tab :to="`/project/${this.projectId}/notes`">
                  Notes & Activity Feed
                </v-tab>
              </v-tabs>
            </v-toolbar-items>
          </v-toolbar>
        </v-col>
      </v-row>

      <router-view/>
    </v-col>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-row>
</template>

<script>
import {getRequest, putRequest, postRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import constants from '@/helpers/constants'
import {getCountries} from '@/services/countryService'
import {getStates} from '@/services/stateService'

export default {
  name: 'Project',
  components: {
    Snackbar,
  },
  data () {
    return {
      snackbar: {},
      constants,
      projectId: parseInt(this.$route.params.projectId),
      companyId: this.$store.state.user.details.companyId,
      displayChangeOwner: false,
      availableOwners: [],
      editAddress: false,
      statuses: [],
      project: {},
      states: [],
      countries: [],
      breadcrumbs: [
        {
          text: 'Back',
          disabled: false,
          exact: true,
          to: `/projects`
        },
      ]
    }
  },
  created () {
    this.getProject()
    this.getAvailableOwners()
    this.getStatuses()
  },
  methods: {
    getProject: async function () {
      try {
        const {data} = await getRequest(`/project/${this.projectId}`)
        this.project = data
      } catch (e) {
        logError(e)
      }
    },
    async getAvailableOwners () {
      // this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //@TODO: @randa, pretty sure the contact list will work for process steps and projects but double checking
        const {data} = await getRequest(`/project/owners`)
        this.availableOwners = data

        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving List of Owners')
        // this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
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
    getStatuses: async function () {
      try {
        const {data} = await getRequest('/project/status')
        this.statuses = data
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching project statuses')
      }
    },
    updateStatus: async function () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await postRequest(`/project/${this.projectId}/status`, this.project)
      }  catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating project status')
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
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getStatesAndCountries: function () {
      // only load countries and states if they try to edit the project address and they haven't already been loaded
      if(this.states.length === 0 || this.countries.length === 0) {
        this.getStates()
        this.getCountries()
      }
    },
    getStates: async function () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getStates()
        this.states = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
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
</style>


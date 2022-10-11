<template>
  <v-container class="pa-0">
    <v-checkbox
      class="pt-5 ml-3"
      dense
      v-model="showCancelled"
      label="Show Cancelled"
      v-show="userCanManage"
      @change="fetchProjects(searchQuery)"
    />
    <RequestTable :headers="headers" :projects="projects" :total-items="totalItems" :feature-code="'INSTALLATION_AGREEMENT'" :is-loading="dataLoading"
                  @openRequest="openRequest($event)" @searchInput="fetchProjects($event)" @submitRequest="submitRequest">
      <template v-slot:dialogContent>
        <v-card-title>
          <span class="text-h5">Request for Installation Agreement</span>
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-col>
              <v-text-field label="Customer Name"
                            v-model="requestItem.customer_name"
                            disabled
              ></v-text-field>

              <div style="display: flex;">
                <v-text-field label="Email Address"
                              v-model="requestItem.email"
                              :disabled="!editEmail"
                ></v-text-field>
                <v-icon v-if="!editEmail" small color="primary" class="mr-3" @click="editEmail = !editEmail">
                  edit
                </v-icon>
                <v-icon v-if="editEmail" small text color="primary" class="mr-3" @click="resetEmail">
                  cancel
                </v-icon>
                <v-icon v-if="editEmail" small color="primary" class="mr-3" @click="updateEmail">
                  save
                </v-icon>
              </div>

                <v-btn color="primary" raised @click="openLoanApp()" class="white--text">
                  <span>Finance Application</span>
                </v-btn>
                <v-btn :disabled="!requestItem.proposalNbr" v-if="requestItem.sunpowerUrlExists" color="primary" raised @click="updateSunpowerApp()" class="white--text mt-5">
                  <span>Update / Renew Spwr Quote</span>
                </v-btn>
              </v-col>
              <v-col>
                <v-select attach label="Proposal Number"
                          v-model="requestItem.proposalNbr"
                          :items="requestItem.proposalNbrs"
                          item-text="proposalNbr"
                          item-value="proposalNbr"
                />
                <v-checkbox label="Send English Installation Agreement"
                            class="default-text-color"
                            v-model="requestItem.sendInstallationAgreement"
                />
                <v-checkbox label="Send Spanish Installation Agreement"
                            class="default-text-color"
                            v-model="requestItem.isSpanish"
                />
                <v-checkbox label="Send Finance Docs (Finance Products Only)"
                            class="default-text-color"
                            v-model="requestItem.sendLoanDocs"
                />
              </v-col>
            </v-row>
          </v-card-text>
      </template>
    </RequestTable>
  </v-container>
</template>

<script>

import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  getSnackbar,
  getRequestWithParams
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {AppMutations} from '@/stores/AppStore'
import RequestTable from "@/components/RequestTable";
import Snackbar from "@/components/Snackbar";

export default {
  name: 'ProjectRequests',
  components: {Snackbar, RequestTable},
  data() {
    return {
      snackbar: {},
      dataLoading: true,
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      options: {
        itemsPerPage: 100
      },
      projects: [],
      headers: [
        {text: 'Customer Name', value: 'customer_name', show: true},
        {text: 'Project ID', value: 'project_id', show: true},
        {text: 'Address', value: 'address', show: true}
      ],
      pagination: {},
      projectsSearch: '',
      searchQuery: '',
      showCancelled: false,
      userCanManage: this.$store.getters.userHasFeatureAccessLevel('INSTALLATION_AGREEMENT', 'MANAGE'),
      totalItems: 0,
      requestItem: {
        customer_name: '',
        email: '',
        proposalNbr: '',
        proposalNbrs: [],
        sendLoanDocs: true,
        sendInstallationAgreement: false,
        isSpanish: false,
        sunpowerUrlExists: false,
        projectId: ''
      },
      currentEmail: '',
      editEmail: false
    }
  },
  computed: {},
  watch: {
    options: {
      handler() {
        this.fetchProjects()
      },
      deep: true,
    },
  },
  created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    this.dataLoading = true
    Promise.all([
      this.fetchProjects()
    ]).then(() => {
      this.$store.commit(AppMutations.SET_LOADING, false);
      this.dataLoading = false;
    })
  },
  methods: {
    async fetchProjects(searchQuery) {
      if(searchQuery != undefined){
        this.searchQuery = searchQuery
      }
      try {
        this.dataLoading = true
        const {page, itemsPerPage} = this.options
        const params = {
          query: this.searchQuery,
          showCancelled: this.showCancelled,
          page: page - 1,
          size: itemsPerPage
        }

        const {data} = await getRequestWithParams(`/install-agreement/projects`, {
          params
        }, 'blueraven')

        this.projects = data.content;
        this.totalItems = data.totalElements
        this.dataLoading = false;
      } catch (e) {
        this.dataLoading = false;
        this.$store.commit(AppMutations.SET_LOADING, false)
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving installation agreements')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },

    setSearchQuery(query){
      this.searchQuery=query
    },
    async openRequest(it) {
      this.requestItem.customer_name = it.customer_name
      this.requestItem.email = it.email
      this.currentEmail = it.email
      this.requestItem.projectId = it.project_id
      this.requestItem.sunpowerUrlExists = it.sunpower_url_exists

      // get proposal numbers
      try {
        const {data, status} = await getRequest('/install-agreement/getProposalNumbers/' + it.project_id, 'blueraven')
        if (data == null) {
          this.requestItem.proposalNbrs = ['No Logs Found For Project']
          this.requestItem.proposalNbr = 'No Logs Found For Project'
        } else {
          this.requestItem.proposalNbrs = data;
        }

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving proposal numbers')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async submitRequest() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        if (!this.requestItem.proposalNbr) {
          console.error('*** ERROR ***', 'Error saving installation agreement request: No Proposal Number selected')
          this.snackbar = getSnackbar('ERROR', 'Unable to save installation agreement request without Proposal Number')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
          return
        }

        const {status} = await postRequest('/install-agreement/create', this.requestItem, 'blueraven')
        handleHidingGlobalLoader(this, status)
        this.snackbar = getSnackbar('SUCCESS', 'Installation agreement request submitted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        if (e?.data?.message.includes('locate')) {
          this.snackbar = getSnackbar('ERROR', 'Error: Unable to locate a finance application for this project')
        } else if (e?.data?.message) {
          this.snackbar = getSnackbar('ERROR', e.data.message)
        } else {
          this.snackbar = getSnackbar('ERROR', 'Error submitting installation agreement request ')
        }
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        console.error('*** ERROR ***', e)
      }
    },
    async updateSunpowerApp() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await postRequest('/install-agreement/updateSunpowerApp/' + this.requestItem.projectId + '/' + this.requestItem.proposalNbr, {}, 'blueraven')
        this.requestDialog = false;
        handleHidingGlobalLoader(this, status)
        this.snackbar = getSnackbar('SUCCESS', 'SunPower loan application updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        if (e?.data?.message) {
          this.snackbar = getSnackbar('ERROR', e.data.message)
        } else {
          this.snackbar = getSnackbar('ERROR', 'Error updating SunPower loan application')
        }
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        console.error('*** ERROR ***', e)
      }
    },
    async openLoanApp() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        if (!this.requestItem.proposalNbr) {
          console.error('*** ERROR ***', 'Error: Unable to generate Finance application without Proposal Number')
          this.snackbar = getSnackbar('ERROR', 'Unable to generate Finance application without Proposal Number')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
          return
        }

        if (!this.requestItem.email) {
          console.error('*** ERROR ***', 'Error: Unable to generate Finance application without Email Address')
          this.snackbar = getSnackbar('ERROR', 'Unable to generate Finance application without Email Address')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
          return
        }

        const {
          data,
          status
        } = await getRequest('/install-agreement/generate/' + this.requestItem.projectId + '/' + this.requestItem.proposalNbr, 'blueraven')

        // Handle case for Sunpower update
        if (data == 'Quote Updated') {
          this.snackbar = getSnackbar('SUCCESS', 'Quote Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        else {
          window.open(data);
        }

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        console.error('*** ERROR ***', e)
        if (e.data.message != null) {
          this.snackbar = getSnackbar('ERROR', e.data.message)
        } else {
          this.snackbar = getSnackbar('ERROR', 'Error generating Finance Application')
        }
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async updateEmail() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await putRequest('/install-agreement/updateEmailAddress/' + this.requestItem.projectId, {
          email: this.requestItem.email
        }, 'blueraven')

        this.currentEmail = this.requestItem.email;
        this.editEmail = false;
        this.snackbar = getSnackbar('SUCCESS', 'Email address updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error updating email address')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    resetEmail() {
      this.editEmail = false;
      this.requestItem.email = this.currentEmail;
    }
  }
}
</script>

<style lang="scss" scoped>
.v-data-table ::v-deep .v-data-table__wrapper {
  max-height: calc(100vh - 240px);
}

.name-link {
  color: var(--v-brBlue-base);
  text-decoration: none;

  &:hover {
    text-decoration: underline;
    color: var(--v-primaryText-base);
  }
}

.default-text-color .theme--light.v-label{
    color: rgba(0,0,0,0.87)
  }
</style>

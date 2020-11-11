<template>
  <v-container class="pa-0">
    <v-toolbar color="white" class="elevation-1 mt-3">
      <v-text-field
        class="mt-5 pay-search"
        prepend-inner-icon="search"
        text
        label="Search projects..."
        v-model="searchQuery"
        @input="debounceFilterProjects"
      ></v-text-field>
    </v-toolbar>

    <v-col cols="12">
      <v-data-table
        :headers="headers"
        :items="projects"
        :fixed-header="true"
        :search="projectsSearch"
        :options.sync="options"
        :footer-props="footerProps"
        :items-per-page="50"
        :server-items-length="totalItems"
        :loading="dataLoading"
        dense
        class="elevation-1"
      >

        <template #no-data>
              No requests found
        </template>

        <template #no-results>
              No requests found
        </template>

        <template #body="{ items }" class="table-body">
          <tr
            v-for="(it, index) in items"
            :key="it.id"
            :class="['text-sm-left', 'row-hover', { 'shaded-row': !(index % 2) }]"
          >
            <td class="text-left">
              <a v-if="$store.getters.userHasFeatureAccessLevel('INSTALLATION_AGREEMENT', 'ADD')"
                  @click="openRequest(it)" class="mr-3 name-link">
                {{ it.customer_name ? it.customer_name : '' }}
              </a>
              <span v-else>{{ it.customer_name ? it.customer_name : '' }}</span>
            </td>
            <td class="text-left">{{ it.address ? it.address : '' }}</td>
          </tr>
        </template>
      </v-data-table>

      <v-dialog v-model="requestDialog" max-width="700px">
          <v-card>
              <v-card-title>
                  <span class="headline">Request for Installation Agreement</span>
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
                              <v-icon v-if="!editEmail"  small class="mr-3" @click="editEmail = !editEmail">
                                  edit
                              </v-icon>
                              <v-icon v-if="editEmail"  small class="mr-3" @click="resetEmail">
                                  cancel
                              </v-icon>
                              <v-icon v-if="editEmail"  small class="mr-3" @click="updateEmail">
                                  save
                              </v-icon>
                          </div>

                          <v-btn color="primaryButton" raised @click="openLoanpalApp()" class="white--text">
                              LoanPal Application
                          </v-btn>
                      </v-col>
                      <v-col>
                          <v-select label="Proposal Number"
                                        v-model="requestItem.proposal_nbr"
                                        :items="requestItem.proposal_nbrs"
                                        item-text="proposalNbr"
                                        item-value="proposalNbr"
                          ></v-select>
                          <v-checkbox label="Send English Installation Agreement"
                                      v-model="requestItem.send_installation_agreement"
                          ></v-checkbox>
                          <v-checkbox label="Send Spanish Installation Agreement"
                                      v-model="requestItem.isSpanish"
                          ></v-checkbox>
                          <v-checkbox label="Send Loan Docs (LoanPal Only)"
                                      v-model="requestItem.send_loanpal_docs"
                          ></v-checkbox>
                      </v-col>
                  </v-row>
              </v-card-text>

              <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn color="secondaryButton" text @click="close">Back</v-btn>
                  <v-btn color="primaryButton" raised @click="submitRequest" class="white--text">
                      Submit
                  </v-btn>
              </v-card-actions>
          </v-card>
      </v-dialog>

    </v-col>

  </v-container>
</template>

<script>

  import {
      getRequest,
      deleteRequest,
      putRequest,
      postRequest,
      getSnackbar,
      getRequestWithParams
  } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import { AppMutations } from '@/stores/AppStore'
  import debounce from "lodash.debounce";

  export default {
    name: 'ProjectRequests',

    data: () => ({
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
        { text: 'Customer Name', value: 'customer_name', show: true },
        { text: 'Address', value: 'address', show: true }
      ],
      pagination: {},
      projectsSearch: '',
      searchQuery: '',
      totalItems: 0,
      requestDialog: false,
      requestItem: {
          customer_name: '',
          email: '',
          proposal_nbr: '',
          proposal_nbrs: [],
          send_loanpal_docs: true,
          send_installation_agreement: false,
          isSpanish: false,
          project_id: ''
      },
      currentEmail: '',
      editEmail: false
    }),
    computed: {
    },
    watch: {
      options: {
        handler () {
          this.fetchProjects()
        },
        deep: true,
      },
    },
    created () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.dataLoading = true
      Promise.all([
        this.fetchProjects()
      ]).then(() => {this.$store.commit(AppMutations.SET_LOADING, false); this.dataLoading = false;})
    },
    methods: {
      async fetchProjects() {
        try {
            this.dataLoading = true
            const { page, itemsPerPage } = this.options
            const {data} = await getRequestWithParams(`/install-agreement/projects`, { params: {
                    query: this.searchQuery,
                    page: page - 1,
                    size: itemsPerPage
                }}, 'blueraven')

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
      debounceFilterProjects: debounce( function () {
        this.fetchProjects()
      }, 500),
      async openRequest (it) {
          this.requestItem.customer_name = it.customer_name
          this.requestItem.email = it.email
          this.currentEmail = it.email
          this.requestItem.project_id = it.project_id

          // get proposal numbers
          try {
              const {data} = await getRequest('/install-agreement/getProposalNumbers/'+it.project_id, 'blueraven')
              if (data == null) {
                  this.requestItem.proposal_nbrs = ['No Logs Found For Project']
                  this.requestItem.proposal_nbr = 'No Logs Found For Project'
              }
              else {
                  this.requestItem.proposal_nbrs = data;
              }

              this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
              this.$store.commit(AppMutations.SET_LOADING, false)
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error retrieving proposal numbers')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }

          this.requestDialog = true;
      },
      close () {
        this.requestDialog = false
      },
      changeSort (column) {
        if (this.pagination.sortBy === column) {
          this.pagination.descending = !this.pagination.descending
        } else {
          this.pagination.sortBy = column
          this.pagination.descending = false
        }
      },
      async submitRequest() {
          try {
              this.$store.commit(AppMutations.SET_LOADING, true)
              if (!this.requestItem.proposal_nbr) {
                  console.error('*** ERROR ***', 'Error saving installation agreement request: No Proposal Number selected')
                  this.snackbar = getSnackbar('ERROR', 'Unable to save installation agreement request without Proposal Number')
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                  this.$store.commit(AppMutations.SET_LOADING, false)
                  return
              }

              await postRequest('/install-agreement/create', this.requestItem, 'blueraven')
              this.requestDialog = false;
              this.$store.commit(AppMutations.SET_LOADING, false)
              this.snackbar = getSnackbar('SUCCESS', 'Installation agreement request submitted')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } catch (e) {
              this.$store.commit(AppMutations.SET_LOADING, false)
              this.snackbar = getSnackbar('ERROR', 'Error submitting installation agreement request ')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              console.error('*** ERROR ***', e)
          }
      },
      async openLoanpalApp() {
          try {
              if (!this.requestItem.proposal_nbr) {
                  console.error('*** ERROR ***', 'Error: Unable to generate LonaPal application without Proposal Number')
                  this.snackbar = getSnackbar('ERROR', 'Unable to generate LonaPal application without Proposal Number')
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
                  return
              }
              const {data} = await getRequest('/install-agreement/generate/'+this.requestItem.project_id+'/'+this.requestItem.proposal_nbr, 'blueraven')
              window.open(data);
          } catch (e) {
              this.$store.commit(AppMutations.SET_LOADING, false)
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error generating LoanPal Application')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
      },
      async updateEmail(it) {
          try {
              this.$store.commit(AppMutations.SET_LOADING, true)
              await putRequest('/install-agreement/updateEmailAddress/'+this.requestItem.project_id, {
                  email: this.requestItem.email
              }, 'blueraven')

              this.currentEmail = this.requestItem.email;
              this.editEmail = false;
              this.snackbar = getSnackbar('SUCCESS', 'Email address updated')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
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
</style>

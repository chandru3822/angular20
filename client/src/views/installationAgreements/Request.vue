<template>
  <v-container class="pa-0">
    <v-toolbar color="white" class="elevation-1 mt-3">
      <v-text-field
        class="mt-5 pay-search"
        prepend-inner-icon="search"
        text
        label="Search payments..."
        v-model="searchQuery"
        @input="debounceFilterProjects"
      ></v-text-field>
    </v-toolbar>

    <v-col cols="12">
      <v-data-table
        :headers="headers"
        :items="filteredProjects"
        :search="projectsSearch"
        :options="pagination"
        :footer-props="footerProps"
        :items-per-page="50"
        fixed-header
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
            <td class="text-left"><a @click="openRequest(it)" class="mr-3 name-link">{{ it.customer_name ? it.customer_name : '' }}</a></td>
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

                          <v-text-field label="Email Address"
                                        v-model="requestItem.email_address"
                                        disabled
                          ></v-text-field>
                      </v-col>
                      <v-col>
                          <v-select label="Proposal Number"
                                        v-model="requestItem.proposal_nbr"
                                        :items="requestItem.proposal_nbrs"
                                        item-text="proposalNbr"
                                        item-value="proposalNbr"
                          ></v-select>
                          <v-checkbox label="Send Loan Docs (LoanPal Only)"
                                      v-model="requestItem.send_loanpal_docs"
                          ></v-checkbox>
                          <v-checkbox label="Spanish Installation Agreement"
                                      v-model="requestItem.isSpanish"
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
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import Snackbar from '@/components/Snackbar.vue'
  import { getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import { AppMutations } from '@/stores/AppStore'
  import debounce from "lodash.debounce";

  export default {
    name: 'ProjectRequests',
    components: {
      Snackbar
    },
    data: () => ({
      snackbar: {},
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      projects: [],
      filteredProjects: [],
      headers: [
        { text: 'Customer Name', value: 'customer_name', show: true },
        { text: 'Address', value: 'address', show: true }
      ],
      pagination: {},
      projectsSearch: '',
      searchQuery: '',
      requestDialog: false,
      requestItem: {
          customer_name: '',
          email_address: '',
          proposal_nbr: '',
          proposal_nbrs: [],
          send_loanpal_docs: true,
          isSpanish: false,
          project_id: ''
      },
      editEmail: false
    }),
    computed: {
    },
    watch: {
    },
    created () {
      this.$store.commit(AppMutations.SET_LOADING, true)

      Promise.all([
        this.fetchProjects()
      ]).then(() => this.$store.commit(AppMutations.SET_LOADING, false))
    },
    methods: {
      async fetchProjects() {
        try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            const {data} = await getRequest('/install-agreement/projects', 'blueraven')
            this.projects = data;
            this.filteredProjects = data;
            this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          this.$store.commit(AppMutations.SET_LOADING, false)
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving installation agreements')
        }
      },
        debounceFilterProjects: debounce( function () {
        this.filteredProjects = this.projects && this.projects.filter(p => {
          return (p['customer_name'].toLowerCase().includes(this.searchQuery.toLowerCase()) ||
              (p['address'] != null && p['address'].toString().toLowerCase().includes(this.searchQuery.toLowerCase()))
          )
        })
      }, 500),
      async openRequest (it) {
          this.requestItem.customer_name = it.customer_name
          this.requestItem.email_address = it.email_address
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
                  this.$store.commit(AppMutations.SET_LOADING, false)
                  return
              }

              this.$store.commit(AppMutations.SET_LOADING, false)
              const {data} = await postRequest('/install-agreement/create', this.requestItem, 'blueraven')
              this.requestDialog = false;
              this.snackbar = getSnackbar('SUCCESS', 'Installation agreement request submitted')
          } catch (e) {
              this.$store.commit(AppMutations.SET_LOADING, false)
              this.snackbar = getSnackbar('ERROR', 'Error submitting installation agreement request ')
              this.requestDialog = false;
              console.error('*** ERROR ***', e)
          }
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

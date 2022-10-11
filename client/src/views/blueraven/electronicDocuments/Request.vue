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
  <RequestTable :headers="headers" :projects="projects" :total-items="totalItems" :feature-code="'ELECTRONIC_DOCUMENTS'" :is-loading="dataLoading"
  @openRequest="openRequest($event)" @searchInput="fetchProjects($event)" @submitRequest="submitRequest">
    <template v-slot:dialogContent>
        <v-card-title>
          <span class="text-h5">Document generator</span>
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-col>
              <v-text-field label="Customer Name"
                            v-model="customer_name"
                            disabled
                            class="customer-name-width"
              ></v-text-field>
            </v-col>
            <v-col>
              <v-select label="Template type"
                        v-model="selectedTempType"
                        :items="templateTypes"
                        @change="fetchTemplates"
                        item-text="text"
                        item-value="text"
                        class="template-type-width"
              ></v-select>

              <v-autocomplete label="Documents"
                              v-model="selectedDocIds"
                              :items="documents"
                              multiple
                              autocomplete="off"
                              no-data-text="No documents found"
                              item-text="name"
                              item-value="id"
                              @change="populateDocName"
              ></v-autocomplete>
              <v-text-field
                  v-show="selectedDocIds.length === 1"
                  label="Document Name"
                  v-model="document_name"
              ></v-text-field>
            </v-col>
          </v-row>
        </v-card-text>
    </template>
  </RequestTable>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import Snackbar from '@/components/Snackbar.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  getSnackbar,
  getRequestWithParams
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {AppMutations} from '@/stores/AppStore'
import debounce from "lodash.debounce";
import RequestTable from "@/components/RequestTable";

export default {
  name: 'DocumentRequests',
  components: {
    RequestTable,
    Snackbar
  },
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
      userCanManage: this.$store.getters.userHasFeatureAccessLevel('ELECTRONIC_DOCUMENTS', 'MANAGE'),
      totalItems: 0,
      documents: [],
      selectedDocIds: '',
      project_id: '',
      customer_name: '',
      document_name: null,
      requestDialog: false,
      templateTypes: [
        {
          text: 'Permitting'
        },
        {
          text: 'Utility'
        },
        {
          text: 'Change Order'
        }
      ],
      selectedTempType: 'Permitting'
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
        const {data} = await getRequestWithParams(`/electronicDocument/projects`, {
          params
        })

        this.projects = data.content;
        this.totalItems = data.totalElements
        this.dataLoading = false;
      } catch (e) {
        this.dataLoading = false;
        this.$store.commit(AppMutations.SET_LOADING, false)
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving projects')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async openRequest(it) {
      this.project_id = it.project_id
      this.customer_name = it.customer_name
      await this.fetchTemplates();
      this.requestDialog = true;
    },
    async fetchTemplates() {
      try {
        this.selectedDocIds = ''
        if (this.selectedTempType == 'Permitting') {
          const {data, status} = await getRequest('/electronicDocument/getPermittingDocuments/' + this.project_id)
          if (data != null) {
            this.documents = data
          }
          handleHidingGlobalLoader(this, status)
        } else if (this.selectedTempType == 'Utility') {
          const {data, status} = await getRequest('/electronicDocument/getUtilityDocuments/' + this.project_id)
          if (data != null) {
            this.documents = data
          }
          handleHidingGlobalLoader(this, status)
        } else {
          const {data, status} = await getRequest('/electronicDocument/getChangeOrderDocuments/' + this.project_id)
          if (data != null) {
            this.documents = data
          }
          handleHidingGlobalLoader(this, status)
        }

      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving documents')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async submitRequest() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        if (this.selectedDocIds.length == 0) {
          console.error('*** ERROR ***', 'Error generating document: No document selected')
          this.snackbar = getSnackbar('ERROR', 'Error generating document: No document selected')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
          return
        }

        const {data, status} = await getRequestWithParams('/electronicDocument/generate/' + this.project_id + '/' + this.selectedDocIds, {
          params: {
            documentName: this.document_name
          }
        })

        if (data != null && data.length > 0) {
          for (let i = 0; i < data.length; i++) {
            window.open(data[i]);
          }
          this.snackbar = getSnackbar('SUCCESS', 'Electronic document generated')
        } else {
          this.snackbar = getSnackbar('ERROR', 'Error generating document')
        }

        this.requestDialog = false;
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.snackbar = getSnackbar('ERROR', 'Error generating document')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        console.error('*** ERROR ***', e)
      }
    },
    populateDocName() {
      try {
        if (this.selectedDocIds.length === 1) {
          let name = this.documents.filter(doc => doc.id === this.selectedDocIds[0])[0].name
          if (name.lastIndexOf('-') > -1) {
            this.document_name = name.substr(name.lastIndexOf('-') + 2)
          }
          else {
            this.document_name = name;
          }
        }
        else {
          this.document_name = null;
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.document_name = null;
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

.customer-name-width {
  width: 300px;
}

.template-type-width {
  width: 150px;
}
</style>

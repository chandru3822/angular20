<template>
  <v-container id="hoa-container">
    <v-row>
      <v-col cols="12"  class="pt-0 px-0">
        <v-data-table
          :headers="headers"
          :items="filteredHoas"
          :loading="dataLoading"
          :items-per-page="100"
          :mobile-breakpoint="0"
          fixed-header
          :footer-props="footerProps"
          class="elevation-1 hoa-table"
        >
          <template #header.icons="{}">
            <div class="text-right mr-2">
              <v-btn text @click="addItem" color="primary"
                     v-if="$store.getters.userHasFeatureAccessLevel('HOA', 'ADD')">
                <v-icon>add</v-icon>
                <span v-if="!constants.IS_MOBILE">Add New</span>
              </v-btn>
            </div>
          </template>

          <template #header="{ props: { headers } }">
            <tr>
              <th v-for="header in headers" :key="header.text"
                  :style="{'min-width': header.text === 'Metro Area' ? '120px' : ''}"
              >
                <div v-if="hoaFilters[header.value]" class="pt-2 table-filter">
                  <v-text-field v-if="hoaFilters[header.value].type === 'text'"
                                v-model="hoaFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                filled
                                dense
                                hide-details
                  ></v-text-field>
                  <v-autocomplete v-else-if="hoaFilters[header.value].type === 'select'"
                                  :items="states"
                                  v-model="hoaFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  filled
                                  item-text="state"
                                  dense
                                  type="search"
                                  autocomplete="off"
                                  hide-details
                  ></v-autocomplete>
                </div>
              </th>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr :class="['text-sm-left', {'shaded-row': !(index % 2)}]">
              <td class="text-left clickable" @click="$router.push({ path: `hoa/${item.id}/details` })">
                {{ item.name || '' }}
              </td>
              <td class="text-left clickable" @click="$router.push({ path: `hoa/${item.id}/details` })">
                {{ item.state || '' }}
              </td>
              <td class="text-left clickable" @click="$router.push({ path: `hoa/${item.id}/details` })">
                {{ item.managementCompany || '' }}
              </td>
              <td class="text-right">
                <v-icon v-if="$store.getters.userHasFeatureAccessLevel('HOA', 'EDIT')" small color="primary"
                        class="mr-3 feat-db-link-icon" @click="editHoa(item)">
                  edit
                </v-icon><v-icon v-if="$store.getters.userHasFeatureAccessLevel('HOA', 'DELETE')" small color="primary"
                        class="mr-3 feat-db-link-icon" @click="deleteHoa(item)">
                  delete
                </v-icon>
              </td>
            </tr>
          </template>

          <template #no-data>
            <div class="mt-2 mb-4 default-text-color">No records found</div>
          </template>

          <template #no-results>
            <div class="mt-2 mb-4 default-text-color">No records found</div>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-dialog v-model="hoaDialog" max-width="500px">
      <v-card>
        <v-card-title>
          <span class="text-h5">{{ formTitle }}</span>
        </v-card-title>

        <v-card-text>
          <v-text-field label="Name"
                        v-model="editedItem.name"
                        required
                        filled
          ></v-text-field>
          <v-autocomplete label="State"
                          :items="states"
                          v-model="editedItem.companyStateId"
                          item-text="state"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          required
                          filled
          ></v-autocomplete>
          <v-autocomplete label="Management Company"
                          v-if="!addingManagementCompany"
                          :items="managementCompanies"
                          v-model="editedItem.managementCompanyId"
                          item-text="managementCompany"
                          item-value="id"
                          type="search"
                          autocomplete="off"
                          filled
          ></v-autocomplete>
          <v-text-field label="New Management Company"
                        v-if="addingManagementCompany"
                        v-model="newManagementCompany"
                        filled
          ></v-text-field>
          <a @click="addNewManagementCompany"> {{ addNewManagementCompanyButton }} </a>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="close">Cancel</v-btn>
          <v-btn color="primary" raised @click="saveHoa" class="white--text"
                 :disabled="!editedItem.name || !editedItem.companyStateId">
            {{ btnTxt }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <ConfirmationDialog :open-dialog="!!hoaToDelete" @confirm="confirmDeleteHoa" @close-dialog="hoaToDelete=null">
    Are you sure you want to delete {{ hoaToDeleteName }}?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import constants from "@/helpers/constants";
import cloneDeep from "lodash.clonedeep";
import {FILTER_DEFAULTS, FEAT_DB_TABS} from "@/views/blueraven/featDB/FeatDbConstants";
import {AppMutations} from "@/stores/AppStore";
import {getRequest, getSnackbar, handleHidingGlobalLoader, postRequest, putRequest} from "@/helpers/helpers";
import {getActiveStates} from "@/services/stateService";
import {deleteRequest} from "../../../../helpers/helpers";
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: "hoas",
  components: {ConfirmationDialog},
  data: () => ({
    constants,
    dataLoading: true,
    hoaFilters: {
      name: {value: '', type: 'text', model: 'name'},
      state: {value: [], type: 'select', model: 'state'},
      managementCompany: {value: '', type: 'text', model: 'managementCompany'}
    },
    states: [],
    tabs: FEAT_DB_TABS,
    headers: [
      {text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 300, show: true},
      {text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 150, show: true},
      {text: 'Management Company', value: 'managementCompany', width: constants.IS_MOBILE ? 200 : 250, show: true},
      {text: null, value: 'icons', sortable: false, show: true, width: 50}
    ],
    footerProps: {
      showFirstLastPage: !constants.IS_MOBILE,
      firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
      lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
      'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
      'items-per-page-options': [25, 50, 100, 1000]
    },
    hoaDialog: false,
    editedItem: {
      name: '',
      managementCompanyId: '',
    },
    hoas: [],
    addMode: false,
    managementCompanies: [],
    addingManagementCompany: false,
    newManagementCompany: "",
    hoaToDelete: null,
  }),
  computed: {
    filteredHoas() {
      return this.hoas && this.hoas.filter(hoa => {
        return Object.keys(this.hoaFilters).every(filterName => {
          const filter = this.hoaFilters[filterName]

          if (filter.value?.length < 1) {
            return true
          }

          if (!hoa[filterName]) {
            return false
          }

          if (filter.value !== null && filter.value !== undefined) {
            return hoa[filterName].toLowerCase().includes(filter.value.toLowerCase())
          } else if (filter.value === undefined) {
            filter.value = []
          } else {
            filter.value = ''
          }
        })
      })
    },
    formTitle() {
      return this.addMode ? 'Create HOA' : 'Update HOA'
    },
    btnTxt() {
      return this.addMode ? 'Add' : 'Update'
    },
    addNewManagementCompanyButton() {
      return this.addingManagementCompany ? 'Select An Existing Management Company': 'Add New Management Company'
    },
    hoaToDeleteName(){
      return this.hoaToDelete ? this.hoaToDelete.name : ''
    }
  },
  async created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    this.currentUser = this.$store.state.user.details.id
    this.fetchStates()
    await this.fetchHoas()
  },
  methods: {
    async getActiveManagementCompanies() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/featDb/hoa/list/companies', 'blueraven')
        this.managementCompanies = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchHoas() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/featDb/hoa/list/all', 'blueraven')
        this.hoas = cloneDeep(data).filter(hoa => hoa.archived === false)
        this.dataLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.dataLoading = false
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    async fetchStates() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getActiveStates()
        this.states = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    addItem() {
      this.getActiveManagementCompanies()
      this.addMode = true
      this.hoaDialog = true
    },
    editHoa (item) {
      this.editedItem = Object.assign({}, item)
      this.getActiveManagementCompanies()
      this.addMode = false
      this.hoaDialog = true
    },
    close() {
      this.hoaDialog = false
      this.editedItem = {}
    },
    deleteHoa(item) {
      this.hoaToDelete = {
        id: item.id,
        name: item.name
      }
    },
    async confirmDeleteHoa() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/featDb/hoa/${this.hoaToDelete.id}`, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'HOA deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        await this.fetchHoas().then(() => this.fetchStates())
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting HOA')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.hoaToDelete = null
    },
    async saveHoa() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      if (this.addMode) {
        try {
          if(this.addingManagementCompany){
            const managementCompanyId = await postRequest(`/customField/managementCompany`, {companyName: this.newManagementCompany}, 'blueraven');
            if(managementCompanyId == null || managementCompanyId.data == null){
              throw 'Error adding new management company';
            }
            else{
              this.editedItem.managementCompanyId = managementCompanyId.data;
            }
          }
          const {status} = await postRequest('/featDb/hoa', this.editedItem, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'HOA created')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error creating HOA')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      } else {
        try {
          const {status} = await putRequest(`/featDb/hoa/simpleUpdate`, this.editedItem, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'HOA updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error updating HOA')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }

      this.close()
      await this.fetchHoas()
      this.editedItem = {}
    },
    async addNewManagementCompany(){
      this.addingManagementCompany = !this.addingManagementCompany
    },
  }
}
</script>

<style lang="scss" scoped>
#hoa-container {
  overflow: auto;
  padding-top: 0;
}

.feat-db-link {
  color: var(--v-brBlue-base);
  text-decoration: none;

  &:hover {
    text-decoration: underline;
    color: var(--v-primary-base);
  }
}

.feat-db-link-icon {
  &:hover {
    color: var(--v-primary-lighten1) !important;
  }
}

.hoa-table {
  margin-top: 2px;
}

.v-data-table ::v-deep .v-data-table__wrapper {
  max-height: calc(100vh - 240px);

  .table-filter {
    font-weight: normal;
    margin-bottom: 10px;

    .v-text-field,
    .v-select {
      font-size: 0.875rem;
      margin-left: 15px;
    }
  }
}

@media (min-width: 769px) {
  .v-data-table ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 202px);
  }
}
</style>

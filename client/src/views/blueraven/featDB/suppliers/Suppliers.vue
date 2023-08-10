<template>
  <v-container id="supplier-container">
    <v-row>
      <v-col cols="12"  class="pt-0 px-0">
        <v-data-table
          :headers="headers"
          :items="filteredSuppliers"
          :loading="dataLoading"
          :items-per-page="100"
          :mobile-breakpoint="0"
          fixed-header
          :footer-props="footerProps"
          class="elevation-1 supplier-table"
        >
          <template #header.icons="{}">
            <div class="text-right mr-2">
              <v-btn text @click="addItem" color="primary"
                     v-if="$store.getters.userHasFeatureAccessLevel('Supplier', 'ADD')">
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
                <div v-if="supplierFilters[header.value]" class="pt-2 table-filter">
                  <v-text-field v-if="supplierFilters[header.value].type === 'text'"
                                v-model="supplierFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                filled
                                dense
                                hide-details
                  ></v-text-field>
                  <v-autocomplete v-else-if="supplierFilters[header.value].type === 'select'"
                                  :items="states"
                                  v-model="supplierFilters[header.value].value"
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
              <td class="text-left clickable" @click="$router.push({ path: `supplier/${item.id}/details` })">
                {{ item.name || '' }}
              </td>
              <td class="text-left clickable" @click="$router.push({ path: `supplier/${item.id}/details` })">
                {{ item.state || '' }}
              </td>
              <td class="text-right">
                <v-icon v-if="$store.getters.userHasFeatureAccessLevel('Supplier', 'EDIT')" small color="primary"
                        class="mr-3 feat-db-link-icon" @click="editSupplier(item)">
                  edit
                </v-icon><v-icon v-if="$store.getters.userHasFeatureAccessLevel('Supplier', 'DELETE')" small color="primary"
                        class="mr-3 feat-db-link-icon" @click="deleteSupplier(item)">
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
<!--todo: update to ConfirmationDialog-->
    <v-dialog v-model="supplierDialog" max-width="500px">
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
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="close">Cancel</v-btn>
          <v-btn color="primary" raised @click="newSupplierDuplicateCheck" class="white--text"
                 :disabled="!editedItem.name?.trim() || !editedItem.companyStateId">
            {{ btnTxt }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <ConfirmationDialog :open-dialog="duplicateDialog" @confirm="saveSupplier" @close-dialog="[duplicateDialog = false, close()]">
      <template v-slot:title><span class="error--text">WARNING: Duplicate Supplier Data</span></template>
      <div class="pb-3 body-large">Are you sure you want to create a new Supplier?</div>
      <v-row>
        <v-col v-if="duplicateSupplierMatch">
          <div class="label-large">Existing Supplier</div>
          <div class="body-medium"><span class="label-medium">Name:</span> {{duplicateSupplierMatch.name}}</div>
          <div class="body-medium"><span class="label-medium">State:</span> {{duplicateSupplierMatch.state}}</div>
          <div class="body-medium"><span class="label-medium">Date Created:</span> {{duplicateSupplierMatch.dateCreated | formatDate('date')}}</div>
        </v-col>
        <v-col v-if="editedItem">
          <div class="label-large">New Data</div>
          <div class="body-medium"><span class="label-medium">Name:</span> {{editedItem.name}}</div>
          <div class="body-medium"><span class="label-medium">State:</span> {{editedItem.state}}</div>
        </v-col>
      </v-row>
      <template v-slot:yes>Create</template>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!supplierToDelete" @confirm="confirmDeleteSupplier" @close-dialog="supplierToDelete=null">
    Are you sure you want to delete {{ supplierToDeleteName }}?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import constants from "@/helpers/constants";
import cloneDeep from "lodash.clonedeep";
import {FEAT_DB_TABS} from "@/views/blueraven/featDB/FeatDbConstants";
import {AppMutations} from "@/stores/AppStore";
import {deleteRequest, getRequest, getSnackbar, handleHidingGlobalLoader, postRequest, putRequest} from "@/helpers/helpers";
import {getActiveStates} from "@/services/stateService";
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: "suppliers",
  components: {ConfirmationDialog},
  data: () => ({
    constants,
    dataLoading: true,
    supplierFilters: {
      name: {value: '', type: 'text', model: 'name'},
      state: {value: [], type: 'select', model: 'state'},
    },
    states: [],
    tabs: FEAT_DB_TABS,
    headers: [
      {text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 300, show: true},
      {text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 150, show: true},
      {text: null, value: 'icons', sortable: false, show: true, width: 50}
    ],
    footerProps: {
      showFirstLastPage: !constants.IS_MOBILE,
      firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',
      lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
      'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
      'items-per-page-options': [25, 50, 100, 1000]
    },
    supplierDialog: false,
    editedItem: {
      name: '',
    },
    suppliers: [],
    addMode: false,
    supplierToDelete: null,
    duplicateDialog: false,
    duplicateSupplierMatch: null
  }),
  computed: {
    filteredSuppliers() {
      return this.suppliers && this.suppliers.filter(supplier => {
        return Object.keys(this.supplierFilters).every(filterName => {
          const filter = this.supplierFilters[filterName]

          if (filter.value?.length < 1) {
            return true
          }

          if (!supplier[filterName]) {
            return false
          }

          if (filter.value !== null && filter.value !== undefined) {
            return supplier[filterName].toLowerCase().includes(filter.value.toLowerCase())
          } else if (filter.value === undefined) {
            filter.value = []
          } else {
            filter.value = ''
          }
        })
      })
    },
    formTitle() {
      return this.addMode ? 'Create Supplier' : 'Update Supplier'
    },
    btnTxt() {
      return this.addMode ? 'Add' : 'Update'
    },
    supplierToDeleteName(){
      return this.supplierToDelete ? this.supplierToDelete.name : ''
    },
  },
  async created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    this.currentUser = this.$store.state.user.details.id
    this.fetchStates()
    await this.fetchSuppliers()
  },
  methods: {
    async fetchSuppliers() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/featDb/supplier/list/all', 'blueraven')
        this.suppliers = cloneDeep(data).filter(supplier => supplier.archived === false)
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
      this.addMode = true
      this.supplierDialog = true
    },
    editSupplier (item) {
      this.editedItem = Object.assign({}, item)
      this.addMode = false
      this.supplierDialog = true
    },
    close() {
      this.supplierDialog = false
      this.editedItem = {}
    },
    deleteSupplier(item) {
      this.supplierToDelete = {
        id: item.id,
        name: item.name
      }
    },
    async confirmDeleteSupplier() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/featDb/supplier/${this.supplierToDelete.id}`, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Supplier deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        await this.fetchSuppliers().then(() => this.fetchStates())
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting Supplier')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.supplierToDelete = null
    },

    newSupplierDuplicateCheck() {
      this.duplicateSupplierMatch = this.suppliers.find(supplier => {

        return this.doNamesMatch(this.editedItem.name, supplier.name) &&
            this.editedItem.companyStateId === supplier.companyStateId
      })
      if(this.duplicateSupplierMatch){
        this.supplierDialog = false
        //add state name for display purposes
        this.editedItem.state = this.states.find(state => state.id === this.editedItem.companyStateId)?.state
        this.duplicateDialog = true
      } else {
        this.saveSupplier()
      }
    },

    doNamesMatch(name1, name2){
      //step 1: remove all punctuation and whitespaces (we don't care if those match)
      const name1Clean = this.cleanName(name1)
      const name2Clean = this.cleanName(name2)
      //step 2: check if name1 contains name2 or vice versa, if so they match
      return name2Clean && name1Clean &&
          ((name2Clean.length > 0 && name1Clean.indexOf(name2Clean) >= 0)
          || (name1Clean && name1Clean.length > 0 && name2Clean.indexOf(name1Clean) >= 0))
    },

    cleanName(name){
      return name && name.length > 0 ? name.replace(/[^\w]/g, '').toLowerCase() : name
    },

    async saveSupplier() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      if (this.addMode) {
        try {
          const {status} = await postRequest('/featDb/supplier', this.editedItem, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Supplier created')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error creating Supplier')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      } else {
        try {
          const {status} = await putRequest(`/featDb/supplier/simpleUpdate`, this.editedItem, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Supplier updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error updating Supplier')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }

      this.close()
      await this.fetchSuppliers()
      this.editedItem = {}
    },
  }
}
</script>

<style lang="scss" scoped>
#supplier-container {
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

.supplier-table {
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

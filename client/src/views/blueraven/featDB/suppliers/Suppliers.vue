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
              <a-btn
                  variant="text"
                  @click="addItem"
                  color="primary"
                  v-if="userStore.userHasFeatureAccessLevel('SUPPLIERS', 'ADD')"
                  prepend-icon="add"
                  text="Add New"
              ></a-btn>
            </div>
          </template>

          <template #header="{ props: { headers } }">
            <tr>
              <th v-for="header in headers" :key="header.text"
                  :style="{'min-width': header.text === 'Metro Area' ? '120px' : ''}"
              >
                <div v-if="supplierFilters[header.value]" class="pt-2 table-filter">
                  <a-text-field v-if="supplierFilters[header.value].type === 'text'"
                                v-model="supplierFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                filled
                                dense
                                hide-details
                  ></a-text-field>
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
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/supplier/${item.id}/details`">
                  {{ item.name || '' }}
                </router-link>
              </td>
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/supplier/${item.id}/details`">
                  {{ item.state || '' }}
                </router-link>
              </td>
              <td class="text-right">
                <a-btn
                    :to="`/database/supplier/${item.id}/details`"
                    variant="text"
                    size="x-small"
                    fab
                    color="unset"
                    prepend-icon="mdi-arrow-right"
                ></a-btn>
                <a-btn
                    v-if="userStore.userHasFeatureAccessLevel('SUPPLIERS', 'EDIT')"
                    size="small"
                    icon
                    color="primary"
                    class="mr-3 feat-db-link-icon"
                    @click="editSupplier(item)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    v-if="userStore.userHasFeatureAccessLevel('SUPPLIERS', 'DELETE')"
                    size="small"
                    color="primary"
                    icon
                    class="mr-3 feat-db-link-icon"
                    @click="deleteSupplier(item)"
                    prepend-icon="delete"
                ></a-btn>
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
          <a-text-field label="Name"
                        v-model="editedItem.name"
                        required
                        filled
          ></a-text-field>
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
          <a-btn
              color="primary"
              variant="text"
              @click="close"
              text="Cancel"
          ></a-btn>
          <a-btn
              color="primary"
              raised
              @click="newSupplierDuplicateCheck"
              :disabled="!editedItem.name?.trim() || !editedItem.companyStateId"
              :text="btnTxt"
          ></a-btn>
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

<script setup>
import constants from "@/helpers/constants";
import cloneDeep from "lodash.clonedeep";
import {FEAT_DB_TABS} from "@/views/blueraven/featDB/FeatDbConstants";

import {deleteRequest, getRequest,  handleHidingGlobalLoader, postRequest, putRequest} from "@/helpers/helpers";
import {getActiveStates} from "@/services/stateService";
import ConfirmationDialog from "@/components/ConfirmationDialog";
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const dataLoading = ref(true)
const supplierFilters = ref({name: {value: '', type: 'text', model: 'name'},state: {value: [], type: 'select', model: 'state'},})
const states = ref([])
const tabs = ref(FEAT_DB_TABS)
const headers = ref([
  {text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 300, show: true},
  {text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 150, show: true},
  {text: null, value: 'icons', sortable: false, show: true, width: 50}
])
const footerProps = ref({showFirstLastPage: !constants.IS_MOBILE,firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
  'items-per-page-options': [25, 50, 100, 1000]})
const supplierDialog = ref(false)
const editedItem = ref({name: '',})
const suppliers = ref([])
const addMode = ref(false)
const supplierToDelete = ref(null)
const duplicateDialog = ref(false)
const duplicateSupplierMatch = ref(null)


const filteredSuppliers = computed(() => {
  return suppliers.value && suppliers.value.filter(supplier => {
    return Object.keys(supplierFilters.value).every(filterName => {
      const filter = supplierFilters.value[filterName]

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
})
const formTitle = computed(() => {
  return addMode.value ? 'Create Supplier' : 'Update Supplier'
})
const btnTxt = computed(() => {
  return addMode.value ? 'Add' : 'Update'
})
const supplierToDeleteName = computed(() => {
  return supplierToDelete.value ? supplierToDelete.value.name : ''
})

onMounted(async() => {
  fetchStates()
  await fetchSuppliers()
})

const fetchSuppliers = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/featDb/supplier/list/all', 'blueraven')
    suppliers.value = cloneDeep(data).filter(supplier => supplier.archived === false)
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    dataLoading.value = false
    appStore.loading = false
  }
}
const fetchStates = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getActiveStates()
    states.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving States')

    appStore.loading = false
  }
}
const addItem = ()  => {
  addMode.value = true
  supplierDialog.value = true
}
const editSupplier =  (item)  => {
  editedItem.value = Object.assign({}, item)
  addMode.value = false
  supplierDialog.value = true
}
const close = ()  => {
  supplierDialog.value = false
  editedItem.value = {}
}
const deleteSupplier = (item)  => {
  supplierToDelete.value = {
    id: item.id,
    name: item.name
  }
}
const confirmDeleteSupplier = async() => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/featDb/supplier/${supplierToDelete.value.id}`, 'blueraven')
    snackbar('SUCCESS', 'Supplier deleted')

    await fetchSuppliers().then(() => fetchStates())
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error deleting Supplier')

    appStore.loading = false
  }
  supplierToDelete.value = null
}
const newSupplierDuplicateCheck = ()  => {
  duplicateSupplierMatch.value = suppliers.value.find(supplier => {

    return doNamesMatch(editedItem.value.name, supplier.name) &&
        editedItem.value.companyStateId === supplier.companyStateId
  })
  if(duplicateSupplierMatch.value){
    supplierDialog.value = false
    //add state name for display purposes
    editedItem.value.state = states.value.find(state => state.id === editedItem.value.companyStateId)?.state
    duplicateDialog.value = true
  } else {
    saveSupplier()
  }
}
const doNamesMatch = (name1, name2) => {
  //step 1: remove all punctuation and whitespaces (we don't care if those match)
  const name1Clean = cleanName(name1)
  const name2Clean = cleanName(name2)
  //step 2: check if name1 contains name2 or vice versa, if so they match
  return name2Clean && name1Clean &&
      ((name2Clean.length > 0 && name1Clean.indexOf(name2Clean) >= 0)
          || (name1Clean && name1Clean.length > 0 && name2Clean.indexOf(name1Clean) >= 0))
}
const cleanName = (name) => {
  return name && name.length > 0 ? name.replace(/[^\w]/g, '').toLowerCase() : name
}
const saveSupplier = async() => {
  appStore.loading = true
  if (addMode.value) {
    try {
      const {status} = await postRequest('/featDb/supplier', editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'Supplier created')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error creating Supplier')

      appStore.loading = false
    }
  } else {
    try {
      const {status} = await putRequest(`/featDb/supplier/simpleUpdate`, editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'Supplier updated')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error updating Supplier')

      appStore.loading = false
    }
  }

  close()
  await fetchSuppliers()
  editedItem.value = {}
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
  }
}

@media (min-width: 769px) {
  .v-data-table ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 202px);
  }
}
</style>

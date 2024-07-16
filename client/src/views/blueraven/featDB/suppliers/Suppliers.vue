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
                                class="mx-2"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                filled
                                dense
                                hide-details
                  ></a-text-field>
                  <a-autocomplete v-else-if="supplierFilters[header.value].type === 'select'"
                                  :items="states"
                                  v-model="supplierFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  class="mx-2"
                                  item-title="state"
                                  variant="filled"
                                  density="compact"
                                  type="search"
                                  autocomplete="off"
                                  hide-details
                  ></a-autocomplete>
                </div>
              </th>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': !(index % 2)}" class="clickable text-sm-left row-hover"
                v-if="item.archived === false || (item.archived === true && userStore.userHasFeatureAccessLevel('SUPPLIER', 'ADMIN'))"
            >
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/supplier/${item.id}/details`">
                  <v-chip
                    color="warning"
                    small
                    v-if="item.archived === true &&
                    userStore.userHasFeatureAccessLevel('SUPPLIERS', 'ADMIN')"
                    class="mr-2">
                    ARCHIVED
                  </v-chip>
                  <span :class="{'strike-thru': !item.active}">{{ item.name ? item.name : '' }}</span>
                </router-link>
              </td>
              <td class="text-left clickable" :class="{'strike-thru': !item.active}">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/supplier/${item.id}/details`">
                  {{ item.state || '' }}
                </router-link>
              </td>
              <td class="text-right" >
                <v-icon
                  v-if="userStore.userHasFeatureAccessLevel('SUPPLIERS', 'EDIT')"
                  color="primary"
                  class="mr-3"
                  @click="editSupplier(item)">
                  edit
                </v-icon>
                <v-tooltip top small>
                  <template v-slot:activator="{on, attrs}">
                    <a-btn
                      v-bind="attrs"
                      color="primary"
                      :activation-handler="on"
                      size="small"
                      variant="text"
                      @click="item.archived === false ? deleteSupplier(item) : restoreSupplier(item)"
                      v-if="userStore.userHasFeatureAccessLevel('SUPPLIERS', 'ADMIN')"
                      :append-icon="!item.archived ? 'inventory' : 'undo'"
                    ></a-btn>
                  </template>
                  <span v-if="!item.archived" class="albatross-body-3">Archive</span>
                  <span v-if="item.archived" class="albatross-body-3">Restore</span>
                </v-tooltip>
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
                        variant="filled"
                        @focus="setDirtyItems('name')"
          ></a-text-field>
          <a-autocomplete label="State"
                          :items="states"
                          v-model="editedItem.companyStateId"
                          item-title="state"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          required
                          variant="filled"
          ></a-autocomplete>
          <v-switch
            v-if="userStore.userHasFeatureAccessLevel('SUPPLIERS', 'MANAGE') && !addMode"
            :label="editedItem.active ? 'Active' : 'Inactive'"
            v-model="editedItem.active"></v-switch>
          <label v-if="userStore.userHasFeatureAccessLevel('SUPPLIERS', 'ADMIN') &&
                     editedItem.archived === true && editedItem.active === true">
            This Supplier is currently Archived. Activating this Supplier will un-archive this Supplier.
          </label>
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
  </v-container>
</template>

<script setup>
import constants from "@/helpers/constants";
import cloneDeep from "lodash.clonedeep";
import {FEAT_DB_TABS} from "@/views/blueraven/featDB/FeatDbConstants";

import {
  canRestoreDBEntry,
  deleteRequest,
  getRequest,
  handleHidingGlobalLoader,
  postRequest,
  putRequest
} from "@/helpers/helpers";
import {getActiveStates} from "@/services/stateService";
import ConfirmationDialog from "@/components/ConfirmationDialog";
import { getCurrentInstance, computed, ref, onMounted, watch, defineProps } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter, onBeforeRouteLeave} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

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
const editedItem = ref({id: '', name: '',archived:'', active:''})
const dirtyItems = ref({name: false})
const suppliers = ref([])
const addMode = ref(false)
const supplierToDelete = ref(null)
const duplicateDialog = ref(false)
const duplicateSupplierMatch = ref(null)

const setDirtyItems = (item) => {
  if (item === 'name') {
    dirtyItems.value.name = true
  }
}
const props = defineProps({
  nameSearch: String,
  showInactive: Boolean,
})

const emit = defineEmits(['updateNameSearch'])


const filteredSuppliers = computed(() => {
  return suppliers.value && suppliers.value.filter(supplier => {
    return Object.keys(supplierFilters.value).every(filterName => {
      const filter = supplierFilters.value[filterName]
      if (props.showInactive === false && supplier?.active === false) {
        return false
      }
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
  initFilters()
  fetchStates()
  await fetchSuppliers()
})

onBeforeRouteLeave((to, from, next) => {
  if (to.path.includes('database')) {
    emit('updateNameSearch', supplierFilters.value['name'].value)
  } else {
    emit('updateNameSearch', '')
  }
  next()
})

const initFilters = () => {
  supplierFilters.value['name'].value = props.nameSearch
}

const fetchSuppliers = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/featDb/supplier/list/all', 'blueraven')
    suppliers.value = cloneDeep(data)
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')

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
    appStore.showSnack('ERROR', 'Error Retrieving States')

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
const deleteSupplier = async(supplier) => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/featDb/supplier/${supplier.id}/archive`, 'blueraven')
    appStore.showSnack('SUCCESS', 'Supplier deleted')

    await fetchSuppliers().then(() => fetchStates())
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error deleting Supplier')

    appStore.loading = false
  }
  supplierToDelete.value = null
}

const restoreSupplier = async (supplier)  => {
  appStore.loading = true
  if (canRestoreDBEntry(suppliers.value, supplier)) {
    try {
      await postRequest(`/featDb/supplier/${supplier.id}/restore`, null, 'blueraven')
      close()
      initFilters()
      await fetchSuppliers().then(() => fetchStates())
      appStore.showSnack('SUCCESS', 'Supplier Has Been Restored')
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Restoring Supplier')
      appStore.loading = false
    }
  } else {
    appStore.showSnack('ERROR', `Cannot restore ${supplier.name}. An un-archived record already exists.`)
    appStore.loading = false
  }
}
const newSupplierDuplicateCheck = ()  => {
  if (dirtyItems.value.name) {
    duplicateSupplierMatch.value = suppliers.value.find(supplier => {

      return doNamesMatch(editedItem.value.name, supplier.name) &&
        editedItem.value.companyStateId === supplier.companyStateId
    })
    if (duplicateSupplierMatch.value) {
      supplierDialog.value = false
      //add state name for display purposes
      editedItem.value.state = states.value.find(state => state.id === editedItem.value.companyStateId)?.state
      duplicateDialog.value = true
    } else {
      saveSupplier()
    }
  } else {
    saveSupplier()
  }
  dirtyItems.value.name = false
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
      appStore.showSnack('SUCCESS', 'Supplier created')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error creating Supplier')

      appStore.loading = false
    }
  } else {
    try {
      const currentSupplier = cloneDeep(editedItem.value)
      const {status} = await putRequest(`/featDb/supplier/simpleUpdate`, currentSupplier, 'blueraven')
      appStore.showSnack('SUCCESS', 'Supplier updated')
      if (currentSupplier?.archived === true && currentSupplier?.active === true) {
        await restoreSupplier(currentSupplier)
      }
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error updating Supplier')

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

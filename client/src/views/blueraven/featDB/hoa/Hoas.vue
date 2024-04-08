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
              <a-btn
                  variant="text"
                  @click="addItem"
                  color="primary"
                  v-if="userStore.userHasFeatureAccessLevel('HOA', 'ADD')"
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
                <div v-if="hoaFilters[header.value]" class="pt-2 table-filter">
                  <a-text-field v-if="hoaFilters[header.value].type === 'text'"
                                v-model="hoaFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                variant="filled"
                                density="compact"
                                hide-details
                  ></a-text-field>
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
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/hoa/${item.id}/details`">
                  {{ item.name || '' }}
                </router-link>
              </td>
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/hoa/${item.id}/details`">
                  {{ item.state || '' }}
                </router-link>
              </td>
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/hoa/${item.id}/details`">
                  {{ item.managementCompany || '' }}
                </router-link>
              </td>
              <td class="text-right">
                <a-btn
                    :to="`/database/hoa/${item.id}/details`"
                    variant="text"
                    size="x-small"
                    fab
                    color="unset"
                    prepend-icon="mdi-arrow-right"
                ></a-btn>
                <a-btn
                    icon
                    v-if="userStore.userHasFeatureAccessLevel('HOA', 'EDIT')"
                    size="small"
                    color="primary"
                    class="mr-3 feat-db-link-icon"
                    @click="editHoa(item)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    icon
                    v-if="userStore.userHasFeatureAccessLevel('HOA', 'DELETE')"
                    size="small"
                    color="primary"
                    class="mr-3 feat-db-link-icon"
                    @click="deleteHoa(item)"
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
    <v-dialog v-model="hoaDialog" max-width="500px">
      <v-card>
        <v-card-title>
          <span class="text-h5">{{ formTitle }}</span>
        </v-card-title>

        <v-card-text>
          <a-text-field label="Name"
                        v-model="editedItem.name"
                        required
                        variant="filled"
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
          <a-text-field label="New Management Company"
                        v-if="addingManagementCompany"
                        v-model="newManagementCompany"
                        variant="filled"
          ></a-text-field>
          <a @click="addNewManagementCompany"> {{ addNewManagementCompanyButton }} </a>
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
              @click="newHoaDuplicateCheck"
              :disabled="!editedItem.name?.trim() || !editedItem.companyStateId"
              :text="btnTxt"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <ConfirmationDialog :open-dialog="duplicateDialog" @confirm="saveHoa" @close-dialog="[duplicateDialog = false, close()]">
      <template v-slot:title><span class="error--text">WARNING: Duplicate HOA Data</span></template>
      <div class="pb-3 body-large">Are you sure you want to create a new HOA?</div>
      <v-row>
        <v-col v-if="duplicateHoaMatch">
          <div class="label-large">Existing HOA</div>
          <div class="body-medium"><span class="label-medium">Name:</span> {{duplicateHoaMatch.name}}</div>
          <div class="body-medium"><span class="label-medium">State:</span> {{duplicateHoaMatch.state}}</div>
          <div class="body-medium"><span class="label-medium">Management Company:</span>
            <div>{{duplicateHoaMatch.managementCompany}}</div>
          </div>
          <div class="body-medium"><span class="label-medium">Date Created:</span> {{duplicateHoaMatch.dateCreated | formatDate('date')}}</div>
        </v-col>
        <v-col v-if="editedItem">
          <div class="label-large">New Data</div>
          <div class="body-medium"><span class="label-medium">Name:</span> {{editedItem.name}}</div>
          <div class="body-medium"><span class="label-medium">State:</span> {{editedItem.state}}</div>
          <div class="body-medium"><span class="label-medium">Management Company:</span>
            <div>{{editedItem.managementCompany}}</div>
          </div>
        </v-col>
      </v-row>
      <template v-slot:yes>Create</template>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!hoaToDelete" @confirm="confirmDeleteHoa" @close-dialog="hoaToDelete=null">
      Are you sure you want to delete {{ hoaToDeleteName }}?
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
const hoaFilters = ref({name: {value: '', type: 'text', model: 'name'},state: {value: [], type: 'select', model: 'state'},managementCompany: {value: '', type: 'text', model: 'managementCompany'}})
const states = ref([])
const tabs = ref(FEAT_DB_TABS)
const headers = ref([
  {text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 300, show: true},
  {text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 150, show: true},
  {text: 'Management Company', value: 'managementCompany', width: constants.IS_MOBILE ? 200 : 250, show: true},
  {text: null, value: 'icons', sortable: false, show: true, width: 50}
])
const footerProps = ref({showFirstLastPage: !constants.IS_MOBILE,firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
  'items-per-page-options': [25, 50, 100, 1000]})
const hoaDialog = ref(false)
const editedItem = ref({name: '',managementCompanyId: '',})
const hoas = ref([])
const addMode = ref(false)
const managementCompanies = ref([])
const addingManagementCompany = ref(false)
const newManagementCompany = ref("")
const hoaToDelete = ref(null)
const duplicateDialog = ref(false)
const duplicateHoaMatch = ref(null)

const filteredHoas = computed(() => {
  return hoas.value && hoas.value.filter(hoa => {
    return Object.keys(hoaFilters.value).every(filterName => {
      const filter = hoaFilters.value[filterName]

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
})
const formTitle = computed(() => {
  return addMode.value ? 'Create HOA' : 'Update HOA'
})
const btnTxt = computed(() => {
  return addMode.value ? 'Add' : 'Update'
})
const addNewManagementCompanyButton = computed(() => {
  return addingManagementCompany.value ? 'Select An Existing Management Company': 'Add New Management Company'
})
const hoaToDeleteName = computed(()=> {
  return hoaToDelete.value ? hoaToDelete.value.name : ''
})

onMounted(() => {
  fetchStates()
  fetchHoas()
})


const getActiveManagementCompanies = async()  => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/featDb/hoa/list/companies', 'blueraven')
    managementCompanies.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const fetchHoas = async()  => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/featDb/hoa/list/all', 'blueraven')
    hoas.value = cloneDeep(data).filter(hoa => hoa.archived === false)
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    dataLoading.value = false
    appStore.loading = false
  }
}
const fetchStates = async()  => {
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
const addItem = () => {
  getActiveManagementCompanies()
  addMode.value = true
  hoaDialog.value = true
}
const editHoa =  (item) => {
  editedItem.value = Object.assign({}, item)
  getActiveManagementCompanies()
  addMode.value = false
  hoaDialog.value = true
}
const close = () => {
  hoaDialog.value = false
  editedItem.value = {}
}
const deleteHoa = (item) => {
  hoaToDelete.value = {
    id: item.id,
    name: item.name
  }
}
const confirmDeleteHoa = async()  => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/featDb/hoa/${hoaToDelete.value.id}`, 'blueraven')
    snackbar('SUCCESS', 'HOA deleted')

    await fetchHoas().then(() => fetchStates())
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error deleting HOA')

    appStore.loading = false
  }
  hoaToDelete.value = null
}
const newHoaDuplicateCheck = () => {
  editedItem.value.managementCompany = !!editedItem.value.managementCompanyId ? managementCompanies.value.find(co => co.id === editedItem.value.managementCompanyId)?.managementCompany : newManagementCompany.value
  duplicateHoaMatch.value = hoas.value.find(hoa => {

    return doNamesMatch(editedItem.value.name, hoa.name) &&
        editedItem.value.companyStateId === hoa.companyStateId &&
        (doNamesMatch(editedItem.value.managementCompany, hoa.managementCompany)
            || !hoa.managementCompany || !editedItem.value.managementCompany)
  })
  if(duplicateHoaMatch.value){
    hoaDialog.value = false
    //add managementCompany name and state name for display purposes
    editedItem.value.state = states.value.find(state => state.id === editedItem.value.companyStateId)?.state
    duplicateDialog.value = true
  } else {
    saveHoa()
  }
}
const doNamesMatch = (name1, name2)=> {
  //step 1: remove all punctuation and whitespaces (we don't care if those match)
  const name1Clean = cleanName(name1)
  const name2Clean = cleanName(name2)
  //step 2: check if name1 contains name2 or vice versa, if so they match
  return name2Clean && name1Clean &&
      ((name2Clean.length > 0 && name1Clean.indexOf(name2Clean) >= 0)
          || (name1Clean && name1Clean.length > 0 && name2Clean.indexOf(name1Clean) >= 0))
}
const cleanName = (name)=> {
  return name && name.length > 0 ? name.replace(/[^\w]/g, '').toLowerCase() : name
}
const saveHoa = async()  => {
  appStore.loading = true
  if (addMode.value) {
    try {
      if(addingManagementCompany.value){
        const managementCompanyId = await postRequest(`/customField/managementCompany`, {companyName: newManagementCompany.value}, 'blueraven');
        if(managementCompanyId == null || managementCompanyId.data == null){
          throw 'Error adding new management company';
        }
        else{
          editedItem.value.managementCompanyId = managementCompanyId.data;
        }
      }
      const {status} = await postRequest('/featDb/hoa', editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'HOA created')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error creating HOA')

      appStore.loading = false
    }
  } else {
    try {
      const {status} = await putRequest(`/featDb/hoa/simpleUpdate`, editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'HOA updated')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error updating HOA')

      appStore.loading = false
    }
  }
  close()
  await fetchHoas()
  editedItem.value = {}
}
const addNewManagementCompany = async() => {
  addingManagementCompany.value = !addingManagementCompany.value
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

  }
}

@media (min-width: 769px) {
  .v-data-table ::v-deep .v-data-table__wrapper {
    max-height: calc(100vh - 202px);
  }
}
</style>

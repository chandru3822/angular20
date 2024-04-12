<template>
  <v-container id="incentive-container">
    <v-row>
      <v-col cols="12"  class="pt-0 px-0">
        <v-data-table
            :headers="headers"
            :items="filteredIncentives"
            :loading="dataLoading"
            :items-per-page="100"
            :mobile-breakpoint="0"
            fixed-header
            :footer-props="footerProps"
            class="elevation-1 incentive-table"
        >
          <template #header.icons="{}">
            <div class="text-right mr-2">
              <a-btn
                  variant="text"
                  @click="addItem"
                  color="primary"
                  v-if="userStore.userHasFeatureAccessLevel('INCENTIVE', 'ADD')"
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
                <div v-if="incentiveFilters[header.value]" class="pt-2 table-filter">
                  <a-text-field v-if="incentiveFilters[header.value].type === 'text'"
                                v-model="incentiveFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                variant="filled"
                                density="compact"
                                hide-details
                  ></a-text-field>
                  <a-autocomplete v-else-if="incentiveFilters[header.value].type === 'select' && header.value === 'state'"
                                  :items="states"
                                  v-model="incentiveFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  filled
                                  :item-title=header.value
                                  dense
                                  type="search"
                                  autocomplete="off"
                                  hide-details
                  ></a-autocomplete>
                  <a-autocomplete v-else-if="incentiveFilters[header.value].type === 'select' && header.value === 'type'"
                                  :items="types"
                                  v-model="incentiveFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  :item-title="header.value"
                                  item-value="type"
                                  variant="filled"
                                  density="compact"
                                  type="search"
                                  autocomplete="off"
                                  hide-details
                  ></a-autocomplete>
                  <a-autocomplete v-else-if="incentiveFilters[header.value].type === 'select' && header.value === 'status'"
                                  :items="statuses"
                                  v-model="incentiveFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  :item-title="header.value"
                                  item-value="status"
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
            <tr :class="['text-sm-left', {'shaded-row': !(index % 2)}]">
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/incentive/${item.id}/details`">
                  {{ item.name || '' }}
                </router-link>
              </td>
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/incentive/${item.id}/details`">
                  {{ item.state || '' }}
                </router-link>
              </td>
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/incentive/${item.id}/details`">
                  {{ item.type || '' }}
                </router-link>
              </td>
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/incentive/${item.id}/details`">
                  {{ item.status || '' }}
                </router-link>
              </td>
              <td class="text-right">
                <a-btn
                    :to="`/database/incentive/${item.id}/details`"
                    variant="text"
                    size="x-small"
                    fab
                    color="unset"
                    prepend-icon="mdi-arrow-right"
                ></a-btn>
                <a-btn
                    v-if="userStore.userHasFeatureAccessLevel('INCENTIVE', 'EDIT')"
                    size="small"
                    icon
                    color="primary"
                    class="mr-3 feat-db-link-icon"
                    @click="editIncentive(item)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    v-if="userStore.userHasFeatureAccessLevel('INCENTIVE', 'DELETE')"
                    size="small"
                    color="primary"
                    icon
                    class="mr-3 feat-db-link-icon"
                    @click="deleteIncentive(item)"
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
    <v-dialog v-model="incentiveDialog" max-width="500px">
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
          <a-autocomplete label="State"
                          :items="states"
                          v-model="editedItem.companyStateId"
                          item-title="state"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          required
                          filled
          ></a-autocomplete>
          <a-autocomplete label="Type"
                          :items="types"
                          v-model="editedItem.typeId"
                          item-title="type"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          filled
          ></a-autocomplete>
          <a-autocomplete label="Status"
                          :items="statuses"
                          v-model="editedItem.statusId"
                          item-title="status"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          variant="filled"
          ></a-autocomplete>
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
              @click="newIncentiveDuplicateCheck"
              :disabled="!editedItem.name?.trim() || !editedItem.companyStateId"
              :text="btnTxt"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <ConfirmationDialog :open-dialog="duplicateDialog" @confirm="saveIncentive" @close-dialog="[duplicateDialog = false, close()]">
      <template v-slot:title><span class="error--text">WARNING: Duplicate Incentive Data</span></template>
      <div class="pb-3 body-large">Are you sure you want to create a new Incentive?</div>
      <v-row>
        <v-col v-if="duplicateIncentiveMatch">
          <div class="label-large">Existing Incentive</div>
          <div class="body-medium"><span class="label-medium">Name:</span> {{duplicateIncentiveMatch.name}}</div>
          <div class="body-medium"><span class="label-medium">State:</span> {{duplicateIncentiveMatch.state}}</div>
          <div class="body-medium"><span class="label-medium">Type:</span> {{duplicateIncentiveMatch.type}}</div>
          <div class="body-medium"><span class="label-medium">Status:</span> {{duplicateIncentiveMatch.status}}</div>
          <div class="body-medium"><span class="label-medium">Date Created:</span> {{duplicateIncentiveMatch.dateCreated | formatDate('date')}}</div>
        </v-col>
        <v-col v-if="editedItem">
          <div class="label-large">New Data</div>
          <div class="body-medium"><span class="label-medium">Name:</span> {{editedItem.name}}</div>
          <div class="body-medium"><span class="label-medium">State:</span> {{editedItem.state}}</div>
          <div class="body-medium"><span class="label-medium">Type:</span> {{editedItem.type}}</div>
          <div class="body-medium"><span class="label-medium">Status:</span> {{editedItem.status}}</div>
        </v-col>
      </v-row>
      <template v-slot:yes>Create</template>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!incentiveToDelete" @confirm="confirmDeleteIncentive" @close-dialog="incentiveToDelete=null">
      Are you sure you want to delete {{ incentiveToDeleteName }}?
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
const incentiveFilters = ref({name: {value: '', type: 'text', model: 'name'},state: {value: [], type: 'select', model: 'state'},type: {value: [], type: 'select', model: 'type'},status: {value: [], type: 'select', model: 'status'}})
const states = ref([])
const statuses = ref([])
const types = ref([])
const tabs = ref(FEAT_DB_TABS)
const headers = ref([
  {text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 300, show: true},
  {text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 150, show: true},
  {text: 'Type', value: 'type', width: constants.IS_MOBILE ? 150 : 150, show: true},
  {text: 'Status', value: 'status', width: constants.IS_MOBILE ? 150 : 150, show: true},
  {text: null, value: 'icons', sortable: false, show: true, width: 50}
])
const footerProps = ref({showFirstLastPage: !constants.IS_MOBILE,firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
  'items-per-page-options': [25, 50, 100, 1000]})
const incentiveDialog = ref(false)
const editedItem = ref({name: '',statusId: '',typeId: '',})
const incentives = ref([])
const addMode = ref(false)
const incentiveToDelete = ref(null)
const duplicateDialog = ref(false)
const duplicateIncentiveMatch = ref(null)

const filteredIncentives = computed(() => {
  return incentives.value && incentives.value.filter(incentive => {
    return Object.keys(incentiveFilters.value).every(filterName => {
      const filter = incentiveFilters.value[filterName]

      if (filter.value?.length < 1) {
        return true
      }

      if (!incentive[filterName]) {
        return false
      }

      if (filter.value !== null && filter.value !== undefined) {
        return incentive[filterName].toLowerCase().includes(filter.value.toLowerCase())
      } else if (filter.value === undefined) {
        filter.value = []
      } else {
        filter.value = ''
        // return true here or the first row in the incentive list will disappear when you clear the filters
        return true
      }
    })
  })
})
const formTitle = computed(() =>{
  return addMode.value ? 'Create Incentive' : 'Update Incentive'
})
const btnTxt = computed(() =>{
  return addMode.value ? 'Add' : 'Update'
})
const incentiveToDeleteName = computed(()=>{
  return incentiveToDelete.value ? incentiveToDelete.value.name : ''
})

onMounted(async () => {
  await fetchStates()
  await getTypes()
  await getStatuses()
  await fetchIncentives()
})

const getTypes = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/featDb/incentive/list/type', 'blueraven')
    types.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Types')

    appStore.loading = false
  }
}
const getStatuses = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/featDb/incentive/list/status', 'blueraven')
    statuses.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Status\'')

    appStore.loading = false
  }
}
const fetchIncentives = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/featDb/incentive/list/all', 'blueraven')
    incentives.value = cloneDeep(data).filter(incentive => incentive.archived === false)
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
  getTypes()
  getStatuses()
  addMode.value = true
  incentiveDialog.value = true
}
const editIncentive =  (item)  => {
  editedItem.value = Object.assign({}, item)
  getTypes()
  getStatuses()
  addMode.value = false
  incentiveDialog.value = true
}
const close = ()  => {
  incentiveDialog.value = false
  editedItem.value = {}
}
const deleteIncentive = (item)  => {
  incentiveToDelete.value = {
    id: item.id,
    name: item.name
  }
}
const confirmDeleteIncentive = async() => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/featDb/incentive/${incentiveToDelete.value.id}`, 'blueraven')
    snackbar('SUCCESS', 'Incentive deleted')

    await fetchIncentives().then(() => fetchStates())
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error deleting Incentive')

    appStore.loading = false
  }
  incentiveToDelete.value = null
}

const newIncentiveDuplicateCheck = ()  => {
  duplicateIncentiveMatch.value = incentives.value.find(incentive => {

    return doNamesMatch(editedItem.value.name, incentive.name) &&
        editedItem.value.companyStateId === incentive.companyStateId
  })
  if(duplicateIncentiveMatch.value){
    incentiveDialog.value = false
    //add state name for display purposes
    editedItem.value.state = states.value.find(state => state.id === editedItem.value.companyStateId)?.state
    editedItem.value.type = types.value.find(type => type.id === editedItem.value.typeId)?.type
    editedItem.value.status = statuses.value.find(status => status.id === editedItem.value.statusId)?.status
    duplicateDialog.value = true
  } else {
    saveIncentive()
  }
}

const doNamesMatch = (name1, name2) => {
  //step 1: remove all punctuation and whitespaces (we don't care if those match)
  const name1Clean = cleanName(name1)
  const name2Clean = cleanName(name2)
  //step 2: check if name1 contains name2 or vice versa, if so they match.
  //This is kind of weird but blue raven requested this behavior specifically
  return name2Clean && name1Clean &&
      ((name2Clean.length > 0 && name1Clean.indexOf(name2Clean) >= 0)
          || (name1Clean && name1Clean.length > 0 && name2Clean.indexOf(name1Clean) >= 0))
}

const cleanName = (name) => {
  return name && name.length > 0 ? name.replace(/[^\w]/g, '').toLowerCase() : name
}

const saveIncentive = async() => {
  appStore.loading = true
  if (addMode.value) {
    try {
      const {status} = await postRequest('/featDb/incentive', editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'Incentive created')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error creating Incentive')

      appStore.loading = false
    }
  } else {
    try {
      const {status} = await putRequest(`/featDb/incentive/simpleUpdate`, editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'Incentive updated')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error updating Incentive')

      appStore.loading = false
    }
  }

  close()
  await fetchIncentives()
  editedItem.value = {}
}
</script>

<style lang="scss" scoped>
#incentive-container {
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

.incentive-table {
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

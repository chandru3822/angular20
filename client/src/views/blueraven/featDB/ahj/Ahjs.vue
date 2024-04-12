<template>
  <v-container id="ahj-list-container">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-data-table
            :headers="headers"
            :items="filteredAhjs"
            :loading="dataLoading"
            :items-per-page="100"
            :mobile-breakpoint="0"
            fixed-header
            :footer-props="footerProps"
            class="elevation-1 ahj-table"
        >
          <template #header.icons="{}">
            <div class="text-right mr-2">
              <a-btn
                  variant="text"
                  @click="addItem"
                  color="primary"
                  v-if="userStore.userHasFeatureAccessLevel('AHJ', 'ADD')"
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
                <div v-if="ahjFilters[header.value]" class="pt-2 table-filter">
                  <a-text-field v-if="ahjFilters[header.value].type === 'text'"
                                v-model="ahjFilters[header.value].value"
                                class="mx-2"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                density="compact"
                                variant="filled"
                                hide-details
                  ></a-text-field>
                  <a-autocomplete v-else-if="ahjFilters[header.value].type === 'select'"
                                  :items="states"
                                  v-model="ahjFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  variant="filled"
                                  density="compact"
                                  item-title="state"
                                  hide-details
                                  attach
                  ></a-autocomplete>
                </div>
              </th>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr :class="['text-sm-left', {'shaded-row': !(index % 2)}]">
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/ahj/${item.id}/permit`">
                  {{ item.name ? item.name : '' }}
                </router-link>
              </td>
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/ahj/${item.id}/permit`">
                  {{ item.metroArea ? item.metroArea : '' }}
                </router-link>
              </td>
              <td class="text-left clickable">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/ahj/${item.id}/permit`">
                  {{ item.state ? item.state : '' }}
                </router-link>
              </td>
              <td class="text-right">
                <router-link v-if="constants.IS_MOBILE" :to="'ahj/' + item.id + '/permit'" class="mr-3 ahj-link">Details</router-link>
                <span v-else>
                  <router-link :to="`ahj/${item.id}/permit`" class="mr-3 ahj-link primary--text">Permit</router-link>
                  <router-link :to="`ahj/${item.id}/inspection`" class="mr-3 ahj-link primary--text">Inspection</router-link>
                  <router-link :to="`ahj/${item.id}/design`" class="mr-3 ahj-link primary--text">Design</router-link>
                </span>
                <v-icon v-if="userStore.userHasFeatureAccessLevel('AHJ', 'EDIT')" small color="primary" class="mr-3 ahj-link-icon" @click="editAhj(item)">
                  edit
                </v-icon>
                <v-icon v-if="userStore.userHasFeatureAccessLevel('AHJ', 'DELETE')" small color="primary" class="ahj-link-icon" @click="deleteItem(item)">
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

        <v-dialog v-model="ahjDialog" max-width="500px">
          <v-card>
            <v-card-title>
              <span class="text-h5">{{ ahjFormTitle }}</span>
            </v-card-title>

            <v-card-text>
              <a-text-field label="Name"
                            v-model="editedItem.name"
                            required
                            filled
              ></a-text-field>
              <a-autocomplete label="Metro Area"
                              :items="metroAreas"
                              v-model="editedItem.metroAreaId"
                              item-title="metroArea"
                              item-value="id"
                              required
                              variant="filled"
                              attach
              ></a-autocomplete>
              <a-autocomplete label="State"
                              :items="states"
                              v-model="editedItem.companyStateId"
                              item-title="state"
                              item-value="id"
                              autocomplete="off"
                              required
                              variant="filled"
                              attach
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
                  @click="saveAhj"
                  :disabled="!editedItem.name || !editedItem.metroAreaId || !editedItem.companyStateId"
                  :text="ahjBtnTxt"
              ></a-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!ahjToDelete" @confirm="deleteAhj" @close-dialog="ahjToDelete=null">
      Are you sure you want to delete the AHJ for {{ ahjToDeleteName }}?

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import cloneDeep from 'lodash.clonedeep'
import { handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest,  } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {getActiveStates} from '@/services/stateService'

import ConfirmationDialog from "@/components/ConfirmationDialog";
import {FEAT_DB_TABS, FILTER_DEFAULTS} from "@/views/blueraven/featDB/FeatDbConstants";
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
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
const tabs = ref(FEAT_DB_TABS)
const headers = ref([
  { text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 300, show: true },
  { text: 'Metro Area', value: 'metroArea', width: constants.IS_MOBILE ? 200 : 250, show: true },
  { text: 'State', value: 'state', width: constants.IS_MOBILE ? 200 : 200, show: true },
  { text: null, value: 'icons', sortable: false, show: true, width: constants.IS_MOBILE ? 135 : 300 }
])
const ahjs = ref([])
const editedItem = ref({name: '',metroAreaId: ''
})
const ahjDialog = ref(false)
const ahjDeleteDialog = ref(false)
const addMode = ref(false)
const ahjFilters = ref([])
const states = ref([])
const metroAreas = ref([])
const ahjToDelete = ref(null)
const footerProps = ref({showFirstLastPage: !constants.IS_MOBILE,firstIcon: constants.IS_MOBILE ? '' : 'mdi-page-first',lastIcon: constants.IS_MOBILE ? '' : 'mdi-page-last',
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
  'items-per-page-options': [25, 50, 100, 1000]})


const filteredAhjs = computed( () => {
  return ahjs.value && ahjs.value.filter(ahj => {
    return Object.keys(ahjFilters.value).every(filterName => {
      const filter = ahjFilters.value[filterName]

      if (filter.value?.length < 1) {
        return true
      }

      if (!ahj[filterName]) {
        return false
      }

      if (filter.value !== null && filter.value !== undefined) {
        return ahj[filterName].toLowerCase().includes(filter.value.toLowerCase())
      } else if (filter.value === undefined) {
        filter.value = []
      } else {
        filter.value = ''
      }
    })
  })
})
const ahjFormTitle = computed( () => {
  return addMode.value ? 'Create AHJ' : 'Update AHJ'
})
const ahjBtnTxt = computed( () => {
  return addMode.value ? 'Add' : 'Update'
})
const ahjToDeleteName = computed(()=> {
  return ahjToDelete.value ? ahjToDelete.value.name : ''
})

watch(ahjDialog, (val) => {
  val || close()
})
onMounted(() => {
  appStore.loading = true
  initFilters()
  fetchAhjs().then(() => {
    if (ahjs.value.length > 0) {
      fetchStates()
    }
    appStore.loading = false
  })
})

const initFilters = () => {
  ahjFilters.value = cloneDeep(FILTER_DEFAULTS)
}
const fetchAhjs = async ()  => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/featDb/ahj', 'blueraven')
    ahjs.value = cloneDeep(data)
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    dataLoading.value = false
    appStore.loading = false
  }
}
const getActiveMetroAreas = async ()  => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/metro/getActive', 'blueraven')
    metroAreas.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}

const addItem = () => {
  getActiveMetroAreas()
  addMode.value = true
  ahjDialog.value = true
}
const editAhj = (item) => {
  editedItem.value = Object.assign({}, item)
  getActiveMetroAreas()
  addMode.value = false
  ahjDialog.value = true
}
const deleteItem = (item) => {
  ahjToDelete.value = {
    id: item.id,
    name: item.name
  }
}
const close = () => {
  ahjDialog.value = false
  ahjDeleteDialog.value = false
  editedItem.value = {}
}
const saveAhj = async ()  => {
  appStore.loading = true
  if (!editedItem.value.id) {
    try {
      const {status} = await postRequest('/featDb/ahj', editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'AHJ created')
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error creating AHJ')
      appStore.loading = false
    }
  } else {
    try {
      const {status} = await putRequest(`/featDb/ahj/${editedItem.value.id}`, editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'AHJ updated')
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error updating AHJ')
      appStore.loading = false
    }
  }

  close()
  initFilters()
  await fetchAhjs().then(() => fetchStates())
  editedItem.value = {}
}
const deleteAhj = async ()  => {
  const id = ahjToDelete.value.id
  appStore.loading = true
  try {
    await deleteRequest(`/featDb/ahj/${id}`, 'blueraven')
    close()
    initFilters()
    await fetchAhjs().then(() => fetchStates())
    snackbar('SUCCESS', 'AHJ deleted')
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error deleting AHJ')
    appStore.loading = false
  }
  ahjToDelete.value = null
}
const fetchStates = async ()  => {
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

</script>

<style lang="scss" scoped>
#ahj-list-container {
  overflow: auto;
  padding-top: 0;
}

.ahj-link {
  color: purple;
  text-decoration: none;

  &:hover {
    text-decoration: underline;
    color: var(--v-primary-base);
  }
}

.ahj-link-icon {
  &:hover {
    color: var(--v-primary-lighten1) !important;
  }
}

.ahj-table {
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

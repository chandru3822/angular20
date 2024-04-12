<template>
  <v-container id="utility-container">
    <v-row>
      <v-col cols="12"  class="pt-0 px-0">
        <v-data-table
            :headers="headers"
            :items="filteredUtilities"
            :loading="dataLoading"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            fixed-header
            hide-default-footer
            class="elevation-1 utility-table"
        >
          <template #header.icons="{}">
            <div class="text-right mr-2">
              <a-btn
                  variant="text"
                  @click="addItem"
                  color="primary"
                  v-if="userStore.userHasFeatureAccessLevel('UTILITY', 'ADD')"
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
                <div v-if="utilityFilters[header.value]" class="pt-2 table-filter">
                  <a-text-field v-if="utilityFilters[header.value].type === 'text'"
                                v-model="utilityFilters[header.value].value"
                                :placeholder="'Enter a ' + header.text.toLowerCase()"
                                clearable
                                variant="filled"
                                type="search"
                                density="compact"
                                hide-details
                                style="font-size: 14px;"
                  ></a-text-field>
                  <a-autocomplete v-else-if="utilityFilters[header.value].type === 'select'"
                                  :items="states"
                                  v-model="utilityFilters[header.value].value"
                                  :placeholder="'Select a ' + header.text.toLowerCase()"
                                  clearable
                                  type="search"
                                  item-title="state"
                                  variant="filled"
                                  density="compact"
                                  hide-details
                                  attach
                  ></a-autocomplete>
                </div>
              </th>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': !(index % 2),
                         'strike-thru': item.archived }" class="clickable text-sm-left row-hover">
              <td class="text-left" :class="{}">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/utility/${item.id}/details`">
                  {{ item.name ? item.name : '' }}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/utility/${item.id}/details`">
                  {{ item.metroArea ? item.metroArea : '' }}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card" :to="`/database/utility/${item.id}/details`">
                  {{ item.state ? item.state : '' }}
                </router-link>
              </td>
              <td class="text-right">
                <a-btn
                    :to="`/database/utility/${item.id}/details`"
                    variant="text"
                    size="x-small"
                    fab
                    color="unset"
                    prepend-icon="mdi-arrow-right"
                ></a-btn>
                <a-btn
                    icon
                    color="primary"
                    size="small"
                    class="mr-3 feat-db-link-icon"
                    @click.stop="editUtility(item)"
                    v-if="userStore.userHasFeatureAccessLevel('UTILITY', 'EDIT')"
                    prepend-icon="edit"
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

        <v-dialog v-model="utilityDialog" max-width="500px">
          <v-card>
            <v-card-title>
              <span class="text-h5">{{ utilityFormTitle }}</span>
            </v-card-title>

            <v-card-text>
              <a-text-field
                  label="Name"
                  v-model="editedItem.name"
                  required
                  type="search"
                  filled
              ></a-text-field>
              <a-autocomplete
                  label="Metro Area"
                  :items="metroAreas"
                  v-model="editedItem.metroAreaId"
                  required
                  variant="filled"
                  attach
              ></a-autocomplete>
              <a-autocomplete label="State"
                              :items="states"
                              v-model="editedItem.companyStateId"
                              item-title="state"
                              item-value="id"
                              type="search"
                              autocomplete="off"
                              required
                              variant="filled"
                              attach
              ></a-autocomplete>
              <v-checkbox
                  v-if="!addMode"
                  label="Archived"
                  v-model="editedItem.archived"
              ></v-checkbox>
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
                  @click="saveUtility"
                  :disabled="!editedItem.name || !editedItem.metroAreaId || !editedItem.companyStateId"
                  :text="utilityBtnTxt"
              ></a-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import cloneDeep from 'lodash.clonedeep'
import { handleHidingGlobalLoader, getRequest, putRequest, postRequest,  } from '@/helpers/helpers'
import constants from '@/helpers/constants'

import {getActiveStates} from '@/services/stateService'
import {FILTER_DEFAULTS, FEAT_DB_TABS} from "@/views/blueraven/featDB/FeatDbConstants";
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

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
  { text: 'Name', value: 'name', width: constants.IS_MOBILE ? 200 : 350, show: true },
  { text: 'Metro Area', value: 'metroArea', width: constants.IS_MOBILE ? 200 : 350, show: true },
  { text: 'State', value: 'state', width: constants.IS_MOBILE ? 150 : 250, show: true },
  { text: null, value: 'icons', sortable: false, show: true, width: 100 }
])
const utilities = ref([])
const states = ref([])
const editedItem = ref({utilityName: '',metroAreaId: '',archived: ''
})
const utilityDialog = ref(false)
const addMode = ref(false)
const utilityFilters = ref([])
const metroAreas = ref([])

const filteredUtilities = computed(() => {
  return utilities.value && utilities.value.filter(utility => {
    return Object.keys(utilityFilters.value).every(filterName => {
      const filter = utilityFilters.value[filterName]

      if (filter.value?.length < 1) {
        return true
      }

      if (!utility[filterName]) {
        return false
      }

      if (filter.value !== null && filter.value !== undefined) {
        return utility[filterName].toLowerCase().includes(filter.value.toLowerCase())
      } else if (filter.value === undefined) {
        filter.value = []
      } else {
        filter.value = ''
      }
    })
  })
})
const utilityFormTitle = computed(() => {
  return addMode.value ? 'Create Utility' : 'Update Utility'
})
const utilityBtnTxt = computed(() => {
  return addMode.value ? 'Add' : 'Update'
})

watch(utilityDialog, (val) => {
  val || close()
})

onMounted(() => {
  initFilters()
  fetchStates()
  fetchUtilities().then(() => appStore.loading = false)
})

const fetchStates = async () => {
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
const fetchUtilities = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/featDb/utility/list/all', 'blueraven')
    utilities.value = cloneDeep(data)
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    dataLoading.value = false
    appStore.loading = false
  }
}
const getActiveMetroAreas = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/metro/getActive', 'blueraven')
    data.forEach(item => {
      let option = {
        text: item.metroArea,
        value: item.id
      }
      metroAreas.value.push(option)
    })
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const initFilters = () => {
  utilityFilters.value = cloneDeep(FILTER_DEFAULTS)
}
const addItem = () => {
  getActiveMetroAreas()
  addMode.value = true
  utilityDialog.value = true
}
const editUtility = (item) => {
  editedItem.value = Object.assign({}, item)
  getActiveMetroAreas()
  addMode.value = false
  utilityDialog.value = true
}
const close = () => {
  utilityDialog.value = false
  editedItem.value = {}
}
const saveUtility = async () => {
  appStore.loading = true
  if (addMode.value) {
    try {
      const {status} = await postRequest('/featDb/utility', editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'Utility created')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error creating utility')

      appStore.loading = false
    }
  } else {
    try {
      const {status} = await putRequest('/featDb/utility/simpleUpdate', editedItem.value, 'blueraven')
      snackbar('SUCCESS', 'Utility updated')

      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error updating utility')

      appStore.loading = false
    }
  }

  close()
  initFilters()
  await fetchUtilities()
  editedItem.value = {}
}
const goToRoute =(id) => {
  router.push('utility/' + id + '/details')
}
</script>

<style lang="scss" scoped>
#utility-container {
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

.utility-table {
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
    max-height: calc(100vh - 162px);
  }
}
</style>

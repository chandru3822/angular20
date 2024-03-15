<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Org Filters</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn variant="text" :hide-text-on-mobile="true" :prepend-icon="addNew ? 'close' : 'add'"
                             :text="addNew ? 'Cancel' : 'Add New'"
                             @click="[addNew = !addNew, newOrgFilter = {}]">
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat>
          <h3>Add Org Filter</h3>
          <div class="mb-3">
            <v-select attach v-model="newOrgFilter.orgLevelId"
                      :items="levels"
                      label="Level"
                      item-value="id"
            >
              <template slot="selection" slot-scope="data">
                {{ data.item.level }} - {{ data.item.levelName }}
              </template>
              <template slot="item" slot-scope="data">
                {{ data.item.level }} - {{ data.item.levelName }}
              </template>
            </v-select>
            <a-text-field  v-model="newOrgFilter.rank" type="number"
                          label="Rank"/>
            <label>Show Type:</label>
            <input type="checkbox" class="ml-3" v-model="newOrgFilter.showType">
          </div>
          <a-btn variant="text" text="Cancel" @click="[addNew = !addNew, newOrgFilter = {}]"></a-btn>
          <a-btn :disabled="!newOrgFilter.orgLevelId || !newOrgFilter.rank"
                 text="Save" class="mr-2"
                 @click="saveOrgFilter(newOrgFilter, true)">
            Save
          </a-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="orgFilters"
            :fixed-header="true"
            :items-per-page="-1"
            single-expand
            :mobile-breakpoint="0"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No parameters exist for this function</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': orgFilters.indexOf(item) % 2}">
              <h3>Edit Org Filter</h3>
              <div class="mb-3">
                <v-select attach v-model="item.orgLevelId"
                          :items="levels"
                          label="Level"
                          item-value="id"
                >
                  <template slot="selection" slot-scope="data">
                    {{ data.item.level }} - {{ data.item.levelName }}
                  </template>
                  <template slot="item" slot-scope="data">
                    {{ data.item.level }} - {{ data.item.levelName }}
                  </template>
                </v-select>
                <a-text-field  v-model="item.rank" type="number"
                              label="Rank"/>
                <label>Show Type:</label>
                <input type="checkbox"  class="ml-3" v-model="item.showType">
              </div>
              <a-btn :disabled="!item.orgLevelId || !item.rank"
                     text="Save" class="mr-2"
                     @click="saveOrgFilter(item, false)">
              </a-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr class="text-left" :class="{'shaded-row': orgFilters.indexOf(item) % 2}">
              <td class="text-left">{{ item.levelName }}</td>
              <td class="text-left">{{ item.rank }}</td>
              <td class="text-left">
                <input type="checkbox" v-model="item.showType" disabled readonly>
              </td>
              <td class="text-right">
                <a-btn variant="text" size="small" prepend-icon="edit" v-if="!expanded.includes(item)" @click="expanded = [item]">
                </a-btn>
                <a-btn size="small" text="cancel" v-if="expanded.includes(item)" @click="expanded = []"></a-btn>
                <a-btn variant="text" size="small" prepend-icon="delete" @click="filterToDelete=item" />
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!filterToDelete" @confirm="deleteOrgFilter"
                        @close-dialog="filterToDelete = null">
      <div>
        <span class="error-text">WARNING:</span> This action can cause issues with many other screens.
      </div>
      Are you sure you want to delete this org filter: <b>{{ filterToDeleteName }}</b>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {getOrgFilters, getOrgLevels} from '@/services/orgService'
import {handleHidingGlobalLoader, deleteRequest, putRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import {getCurrentInstance, onMounted, computed, ref} from 'vue'
import { useUserStore } from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'
import {useRouter} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()
const router = useRouter()
const snackbar = vueInstance.$snackbar

const addNew = ref(false)
const levels = ref([])
const orgFilters = ref([])
const newOrgFilter = ref({})
const expanded = ref([])
const filterToDelete = ref(null)
const selectedOrgFilterId = ref(null)
const userId = ref(userStore.details.id)
const companyId = ref(userStore.details.companyId)
const headers = ref([
  {text: 'Org Level', value: 'levelName', show: true},
  {text: 'Rank', value: 'rank', width: 80, show: true},
  {text: 'Show Type', value: 'showType', width: 80, show: true},
  {text: null, value: 'icons', show: true, sortable: false}
])

const filterToDeleteName = computed(() => {
  return filterToDelete.value ? filterToDelete.value.levelName : ''
})
onMounted(() => {
  getOrganizationFilters()
  getOrganizationLevels()
})

const getOrganizationFilters = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getOrgFilters()
    orgFilters.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Org Filters')
    appStore.loading = false
  }
}
const saveOrgFilter = async (of, isNew) => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/org/filters`, of)
    if (isNew) {
      orgFilters.value.push(data)
      addNew.value = false
      newOrgFilter.value = {}
      snackbar('SUCCESS', 'Org Filter Added')
    } else {
      expanded.value = []
      snackbar('SUCCESS', 'Org Filter Updated')
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', isNew ? 'Error Adding Org Filter' : 'Error Updating Org Filter')
    appStore.loading = false
  }
}
const getOrganizationLevels = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getOrgLevels()
    levels.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Org Levels')
    appStore.loading = false
  }
}
const deleteOrgFilter = async () => {
  const filter = filterToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/org/filters/${filter.id}`)
    orgFilters.value = orgFilters.value.filter(ol => {
      return ol.id !== filter.id
    })
    snackbar('SUCCESS', 'Org Filter Deleted')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Org Filter')
    appStore.loading = false
  }
}
</script>

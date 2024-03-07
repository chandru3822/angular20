<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Round Robins</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newRoundRobin = {}, getCompanyTimezones()]"
                   v-if="userCanAdd">
              <span v-if="!addNew">{{ 'Add New' }}</span>
              <span v-else>{{ 'Cancel' }}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew">
            <v-text-field
                label="Round Robin Name"
                tabindex=1
                v-model="newRoundRobin.roundRobinName"
            ></v-text-field>
            <v-text-field
                label="Distribution Time Frame (Days)"
                tabindex=1
                v-model="newRoundRobin.distributionTimeFrameDays"
            ></v-text-field>
            <v-autocomplete v-model="newRoundRobin.companyTimezoneId"
                            :items="companyTimezones"
                            label="Time Zone"
                            style="width: 200px;"
                            item-text="timezone"
                            item-value="id"
                            attach
            ></v-autocomplete>
            <v-btn color="primary"
                   :disabled="!newRoundRobin.roundRobinName || !newRoundRobin.distributionTimeFrameDays || !newRoundRobin.distributionTimeFrameDays"
                   @click="addRoundRobin" class="mb-3">Save
            </v-btn>
          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <v-text-field
                  v-model="search"
                  prepend-inner-icon="search"
                  label="Search users and round robins"
                  single-line
                  hide-details
                  @input="debounceSearch"
              ></v-text-field>
            </v-card-title>
            <v-data-table
                :headers="headers"
                :items="filteredRoundRobins"
                :fixed-header="true"
                :items-per-page="-1"
                disable-sort
                :loading="dataLoading"
                @click:row="goToRoundRobin"
                hide-default-footer
                :mobile-breakpoint="770"
                class="elevation-1 round-robin-table table-striped"
            >

              <template #header.roundRobinName="{ header }">
                <th class="pa-2 text-left">
                  {{ header.text }}
                  <v-text-field outlined
                                hide-details
                                class="filter-input"
                                v-model="nameSearch"
                                @input="filterResults()">
                  </v-text-field>
                </th>
              </template>

              <template #item="{ item, index }">
                <tr class="clickable" @click="goToRoundRobin(item)">
                  <td class="text-left">
                    {{ item.roundRobinName }}
                  </td>
                  <td class="text-left">{{ item.distributionTimeFrameDays }}</td>
                  <td class="text-left">{{ item.schedulableFutureDays }}</td>
                  <td class="text-left">
                    <input type="checkbox" readonly disabled v-model="item.usesTotalLeadAllocation"/>
                  </td>

                  <td class="text-right">
                    <v-btn small icon :large="$vuetify.breakpoint.smAndDown" color="primary"
                           @click.stop="goToRoundRobin(item)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn v-if="userCanDelete" icon :large="$vuetify.breakpoint.smAndDown" color="primary"
                           @click.stop="[itemToDelete=item, showDeleteDialog=true]">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </td>
                </tr>
              </template>

            </v-data-table>
          </v-card>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog="showDeleteDialog"
        @confirm="deleteRoundRobin"
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this round robin: <strong>{{ itemToDeleteName }}</strong>

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import debounce from 'lodash.debounce'
import cloneDeep from 'lodash.clonedeep'
import {
  handleHidingGlobalLoader,
  getRequestWithParams,
  deleteRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useRouter} from "vue-router/composables";
import {useUserStore} from '@/stores/UserStorePinia.js'

const router = useRouter()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()


const addNew = ref(false)
const search = ref(null)
const newRoundRobin = ref({})
const nameSearch = ref('')
const dataLoading = ref(true)
const selectedRoundRobinId = ref(null)
const roundRobins = ref([])
const masterRoundRobins = ref([])
const companyTimezones = ref([])
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const headers = ref([
  {text: 'Round Robin Name', value: 'roundRobinName', show: true},
  {text: 'Distribution Time Frame (Days)', value: 'distributionTimeFrameDays', show: true},
  {text: 'Schedulable Future Days', value: 'schedulableFutureDays', show: true},
  {text: 'Uses Total Lead Allocation', value: 'usesTotalLeadAllocation', show: true},
  {text: '', value: 'icons', show: true},
])


const filteredRoundRobins = computed(() => {
  return roundRobins.value.filter(pcz => {
    return !pcz.archived
  })
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT')
})
const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const userId = computed(() => {
  return userStore.details.id
})
const itemToDeleteName = computed(() => {
  return itemToDelete.value ? itemToDelete.value.roundRobinName : ''
})

onMounted(() => {
  getRoundRobins()
})


const getCompanyTimezones = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequestWithParams(`/timezone`)
    companyTimezones.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Retrieving Timezones')
    store.commit(AppMutations.SET_LOADING, false)
  }
}

const debounceSearch = () => {
  debounce(function () {
    getRoundRobins()
  }, 500)
}

const goToRoundRobin = (rr) => {
  router.push({path: `/settings/roundRobin/${rr.id}/scheduleTo`})
}

const getRoundRobins = async () => {
  dataLoading.value = true
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequestWithParams(`/roundRobin`, {params: {searchQuery: search.value}})
    roundRobins.value = data
    masterRoundRobins.value = cloneDeep(data)
    dataLoading.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    getSnackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteRoundRobin = async () => {
  itemToDelete.value.archived = true
  const roundRobinId = itemToDelete.value.id
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/roundRobin/${roundRobinId}`)
    getSnackbar('SUCCESS', 'Round Robin Deleted')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Deleting Round Robin')
    store.commit(AppMutations.SET_LOADING, false)
  }
  closeDeleteDialog()
}
const addRoundRobin = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await postRequest(`/roundRobin`, newRoundRobin.value)
    getSnackbar('SUCCESS', 'Round Robin Added')
    handleHidingGlobalLoader(vueInstance, status)
    await router.push({path: `/settings/roundRobin/${data.id}/scheduleTo`})
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Adding Round Robin')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const filterResults = () => {
  roundRobins.value = masterRoundRobins.value.filter(pcz => {
    return pcz?.roundRobinName?.toLowerCase().includes(nameSearch.value.toLowerCase())
  })
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false;
  itemToDelete.value = null;
}


</script>

<style lang="scss">
#postal-codes .v-data-table__wrapper {
  height: calc(100vh - 300px);
  min-height: 300px;
  border-top: solid 1px #E0E0E0;
}
</style>


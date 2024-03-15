<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Round Robins</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="[addNew = !addNew, newRoundRobin = {}, getCompanyTimezones()]"
                v-if="userCanAdd"
                :text="addNew ? 'Cancel' : 'Add New' "
            ></a-btn>

          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card color="transparent" flat v-if="addNew">
            <a-text-field
                label="Round Robin Name"
                tabindex=1
                v-model="newRoundRobin.roundRobinName"
            ></a-text-field>
            <a-text-field
                label="Distribution Time Frame (Days)"
                tabindex=1
                v-model="newRoundRobin.distributionTimeFrameDays"
            ></a-text-field>
            <v-autocomplete v-model="newRoundRobin.companyTimezoneId"
                            :items="companyTimezones"
                            label="Time Zone"
                            style="width: 200px;"
                            item-text="timezone"
                            item-value="id"
                            attach
            ></v-autocomplete>
            <a-btn
                color="primary"
                :disabled="!newRoundRobin.roundRobinName || !newRoundRobin.distributionTimeFrameDays || !newRoundRobin.distributionTimeFrameDays"
                @click="addRoundRobin"
                class="mb-3"
                text="Save"
            ></a-btn>

          </v-card>
          <v-divider v-if="addNew"></v-divider>
          <v-card class="square-card">
            <v-card-title class="pt-0">
              <a-text-field
                  v-model="search"
                  prepend-inner-icon="search"
                  label="Search users and round robins"
                  single-line
                  hide-details
                  @input="debounceSearch"
              ></a-text-field>
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
                  <a-text-field variant="outlined"
                                hide-details
                                class="filter-input"
                                v-model="nameSearch"
                                @input="filterResults()">
                  </a-text-field>
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
                    <a-btn
                        icon
                        color="primary"
                        prevent-default
                        prepend-icon="edit"
                        :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                    ></a-btn>

                    <a-btn
                        v-if="userCanDelete"
                        icon
                        color="primary"
                        @click.native.stop="[itemToDelete=item, showDeleteDialog=true]"
                        prevent-default
                        prepend-icon="delete"
                        :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                    ></a-btn>

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
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const router = useRouter()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
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
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/timezone`)
    companyTimezones.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Timezones')
    appStore.loading = false
  }
}

const debounceSearch = debounce(() => {
  getRoundRobins()
  }, 500)

const goToRoundRobin = (rr) => {
  router.push({path: `/settings/roundRobin/${rr.id}/scheduleTo`})
}

const getRoundRobins = async () => {
  dataLoading.value = true
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/roundRobin`, {params: {searchQuery: search.value}})
    roundRobins.value = data
    masterRoundRobins.value = cloneDeep(data)
    dataLoading.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const deleteRoundRobin = async () => {
  itemToDelete.value.archived = true
  const roundRobinId = itemToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/roundRobin/${roundRobinId}`)
    snackbar('SUCCESS', 'Round Robin Deleted')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Round Robin')
    appStore.loading = false
  }
  closeDeleteDialog()
}
const addRoundRobin = async () => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/roundRobin`, newRoundRobin.value)
    snackbar('SUCCESS', 'Round Robin Added')
    handleHidingGlobalLoader(status)
    await router.push({path: `/settings/roundRobin/${data.id}/scheduleTo`})
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Round Robin')
    appStore.loading = false
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


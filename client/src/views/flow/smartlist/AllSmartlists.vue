<template>
<v-row>
  <v-col cols="12" class="py-0">
    <v-card flat class="square-card pb-3 px-3 elevation-1" color="white">
      <a-text-field
        v-model="search"
        prepend-inner-icon="mdi-magnify"
        label="Search"
        single-line
        hide-details
      ></a-text-field>
    </v-card>
    <v-divider></v-divider>
    <v-data-table
      class="elevation-1"
      :headers="headers"
      :items="smartlists"
      fixed-header
      multi-sort
      :search="search"
      :items-per-page="25"
      :footer-props="footerProps"
      :loading="isLoading"
    >
      <template #no-data>
        <span class="default-text-color">No available smartlists</span>
      </template>

      <template #no-results>
        <span class="default-text-color">No available smartlists</span>
      </template>

      <template #item="{item: smartlist}">
        <tr class="clickable" @click="editSmartlist(smartlist)">
          <td class="text-left td-name">{{ smartlist.name }}</td>
          <td class="text-left">{{ smartlist.owner }}</td>
          <td>{{ smartlist.dateModified | formatDate('timestamp') }}</td>
          <td class="d-flex align-center">
            {{ smartlist.dateLastExported | formatDate('date') }}

            <v-btn
              v-if="smartlist.dateLastExported"
              text
              icon
              class="btn-metrics pa-5"
              @click.stop="[showMetricsDialog = true, getMetrics(smartlist.id)]"
            >
              <v-icon>mdi-information</v-icon>
            </v-btn>
          </td>
          <td class="td-action">
            <smartlist-copy
              :smartlist="smartlist" v-if="userCanAdd"
              @copied="(newSmartlist) => smartlists = [newSmartlist, ...smartlists]"
            />
          </td>
          <td class="td-action">
            <smartlist-share
              :smartlist="smartlist"
              @updated-public="(isPublic) => smartlist.public = isPublic"
              @updated-owner="updateOwnerInfo"
            />
          </td>
          <td class="td-action">
            <smartlist-export
              :smartlist="smartlist"
              @exported="updateExportHistory(smartlist)"
            />
          </td>
          <td class="td-action">
            <smartlist-delete
              v-if="userCanDelete"
              :smartlist-id="smartlist.id"
              @deleted="smartlists = smartlists.filter(s => s.id !== smartlist.id)"
            />
          </td>
        </tr>
      </template>
    </v-data-table>

    <v-dialog
      v-model="showMetricsDialog"
      width="500"
    >
      <v-card>
        <v-card-title>Export History</v-card-title>

        <v-card-text>
          <v-simple-table
            fixed-header
            height="500px"
          >
            <template #default>
              <thead>
                <tr>
                  <th>Date</th>
                  <th>User</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="metric in metrics"
                >
                  <td>{{ metric.dateCreated | formatDate('timestamp') }}</td>
                  <td>{{ metric.createdBy }}</td>
                </tr>
              </tbody>
            </template>
          </v-simple-table>
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer/>
          <v-btn
            color="primary"
            class="white--text elevation-2 text-capitalize mr-2 mb-2"
            @click="[showMetricsDialog = false, metrics = []]"
          >
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-col>
</v-row>
</template>

<script setup>
import { ref, onMounted, getCurrentInstance } from 'vue'
import { getRequest, logError } from '@/helpers/helpers'
import SmartlistExport from '@/views/flow/smartlist/SmartlistExport.vue'
import SmartlistCopy from '@/views/flow/smartlist/SmartlistCopy.vue'
import SmartlistDelete from '@/views/flow/smartlist/SmartlistDelete.vue'
import SmartlistShare from '@/views/flow/smartlist/SmartlistShare.vue'
import constants from '@/helpers/constants'
import { useUserStore } from '@/stores/UserStorePinia.js'

const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})

const headers = ref([
  {text: 'Name', value: 'name'},
  {text: 'Owner', value: 'owner'},
  {text: 'Last Modified', value: 'dateModified'},
  {text: 'Last Export', value: 'dateLastExported'},
  {text: 'Duplicate'},
  {text: 'Share'},
  {text: 'Export'},
  {text: 'Delete'}
])

const search = ref('')
const isLoading = ref(false)

const vueInstance = getCurrentInstance().proxy
const userStore = useUserStore()

const router = vueInstance.$router
const userCanAdd = userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
const userCanEdit = userStore.userHasFeatureAccessLevel('SMARTLIST', 'EDIT')
const userCanDelete = userStore.userHasFeatureAccessLevel('SMARTLIST', 'DELETE')

let smartlists = ref([])
let metrics = ref([])
let showMetricsDialog = ref(false)

onMounted(async () => await getSmartlists())

const getSmartlists = async () => {
  try {
    isLoading.value = true
    const {data} = await getRequest(`/smartlist/all`)
    smartlists.value = data
  } catch (e) {
    logError(e)
  } finally {
    isLoading.value = false
  }
}

let editSmartlist = (smartlist) => {
  if(userCanEdit) {
    router.push({name: 'smartlistEditor', params: {smartlistId: smartlist.id}})
  }
}

const updateOwnerInfo = (newOwner) => {
  const index = smartlists.value.findIndex(i => i.id === newOwner.smartlistId)
  smartlists.value[index].owner = newOwner.name
}

const getMetrics = async (smartlistId) => {
  try {
    const {data} = await getRequest(`/smartlist/${smartlistId}/metrics`)
    metrics.value = data
  } catch (e) {
    logError(e)
    vueInstance.$snackbar('ERROR', 'Unable to fetch smartlist metrics')
  }
}

const updateExportHistory = (smartlist) => {
  const index = smartlists.value.findIndex(i => i.id === smartlist.id)
  smartlists.value[index].dateLastExported = new Date().toISOString()
}
</script>

<style scoped lang="scss">
.btn-metrics {
  color: var(--v-primary-base) !important;
}
</style>

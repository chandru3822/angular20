<template>
  <v-container id="last-chance-pool-container">
    <v-dialog v-model="showModal" class="square-card">
      <ScoreDrilldown :tournament-id="parseInt(tournamentId)"
                      :start-date="pool.startDate"
                      :end-date="pool.endDate"
                      :user="showScoreUser.fullName"
                      :user-id="showScoreUser.userId"
                      @scoreDialogClosed="showModal = false"
      />
    </v-dialog>

    <v-card color="white" flat class="square-card">
      <v-toolbar flat class="app-toolbar">
        {{pool.customName || 'Last Chance'}} <br/>
        {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <a-btn
              v-if="userCanEdit && !dataLoading && selectedUsers.length > 0"
              color="primary"
              @click="moveUsersToWinnersPool()"
              text="Advance Users To Next Round"
          ></a-btn>
        </v-toolbar-items>
      </v-toolbar>
      <a-text-field
          v-model="search"
          class="mb-2 px-4 py-2"
          prepend-inner-icon="search"
          label="Search"
          single-line
          hide-details
      ></a-text-field>
      <v-divider></v-divider>
      <v-data-table
          :headers="headers"
          :items="poolUsers"
          :search="search"
          :fixed-header="true"
          :items-per-page="100"
          :footer-props="footerProps"
          disable-sort
          class="elevation-1 square-card"
      >
        <template #no-data>
          <span class="default-text-color">No available users</span>
        </template>

        <template #no-results>
          <span class="default-text-color">No available users</span>
        </template>

        <template #header.score="{ header }">
          <div class="text-center">
            {{header.text}}
          </div>
        </template>

        <template #item="{ item, index }">
          <tr :class="{'shaded-row': index % 2}">
            <td :key="selectRerender">
              <input type="checkbox" v-if="!item.qualified" v-model="item.selected" @change="toggleSingleSelect(item)">
              <v-icon v-else color="green" size="15">mdi-check-decagram</v-icon>
            </td>
            <td class="text-left">
              {{item.fullName}}
            </td>
            <td class="text-center">
              <span v-if="item.score == null">--</span>
              <span v-else>{{item.score}}</span>
            </td>
            <td class="text-right">
              <a-btn
                  variant="text"
                  size="small"
                  color="primary"
                  class="clickable"
                  @click="[showModal = true, showScoreUser = item]"
                  prepend-icon="mdi-format-list-bulleted"
              ></a-btn>
            </td>
          </tr>
        </template>
      </v-data-table>
    </v-card>
  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, logError, postRequest, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ScoreDrilldown from "./component/ScoreDrilldown"
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

const poolTypeId = ref(2)
const search = ref('')
const showScoreUser = ref({})
const showModal = ref(false)
const dataLoading = ref(true)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],})
const selectRerender = ref(1)
const pool = ref({})
const poolUsers = ref([])
const selectedUsers = ref([])
const headers = ref([
  { text: '', value: 'checkbox', show: true, width: '50px' },
  { text: 'User', value: 'fullName', show: true },
  { text: 'Score', value: 'score', show: true },
  {text: '', value: 'details', show: true},
])

onMounted(() => {
  getPool()
  getPoolUsers()
})

const tournamentId = computed(() => {
  return route.params.id
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')
})

const toggleSingleSelect = (item) => {
  if (item.selected) {
    selectedUsers.value.push(item.userId)
  } else {
    selectedUsers.value = selectedUsers.value.filter(u => u !== item.userId)
  }
}
const getPool = async () => {
  appStore.loading = true
  dataLoading.value = true
  try {
    const {data, status} = await getRequest(`/tournament/${tournamentId.value}/pool/byType/${poolTypeId.value}`, 'blueraven')
    dataLoading.value = false
    pool.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching pool details')

    appStore.loading = false
  }
}
const moveUsersToWinnersPool = async () => {
  appStore.loading = true
  try {
    const {status} = await postRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/advanceUsersToWinnerPool`, selectedUsers.value, 'blueraven')
    snackbar('SUCCESS', 'Selected Users Advanced')

    router.push({name: 'tournamentWinners', params: { id: tournamentId.value }})
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Advancing Users')

    appStore.loading = false
  }
}
const getPoolUsers = async() => {
  try {
    const {data} = await getRequest(`/tournament/${tournamentId.value}/pool/usersByType/${poolTypeId.value}`, 'blueraven', [])
    poolUsers.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching pool user details')

  }
}
</script>

<style lang="scss">
#last-chance-pool-container .v-data-table__wrapper {
  max-height: calc(100vh - 375px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
#last-chance-pool-container {
  padding: 50px;
}
</style>


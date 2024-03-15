<template>
  <v-container id="winners-pool-container" v-if="!poolLoading" :class="{'padded-pool': !showWinners}">
    <v-dialog v-model="showModal" class="square-card">
      <ScoreDrilldown :tournament-id="parseInt(tournamentId)"
                      :start-date="pool.startDate"
                      :end-date="pool.endDate"
                      :user="showScoreUser.fullName"
                      :user-id="showScoreUser.userId"
                      @scoreDialogClosed="showModal = false"
      />
    </v-dialog>

    <v-card color="white" flat class="square-card ma-4" v-if="!showWinners">
      <v-toolbar flat class="app-toolbar">
        {{pool.customName || 'Winners'}} <br/>
        {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <a-btn
              variant="text"
              color="primary"
              v-if="tournamentOver"
              @click="showWinners = !showWinners"
              prepend-icon="mdi-party-popper"
          ></a-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-text-field
          v-model="search"
          class="mb-2 px-4 py-2"
          prepend-inner-icon="search"
          label="Search"
          single-line
          hide-details
      ></v-text-field>
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
            <td class="text-left">
              <v-icon v-if="isWinner(item)" class="mr-2" color="green">mdi-seal</v-icon>
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
    <v-card v-else
            class="square-card pa-4 congrats-card"
            align="center" justify="center"
            :style="{'background-image': null != pool.backgroundAttachmentPresignedUrl
                  ? `url(${pool.backgroundAttachmentPresignedUrl})` : ''}"
    >
      <v-card color="white" class="square-card pa-5 congrats-inner-container">
        <div class="congrats-header mb-3">
          Congratulations to our Winner{{winners.length > 1 ? 's' : ''}}!
        </div>
        <div v-for="w in winners" class="congrats-winner">
          {{w.fullName}}
        </div>
      </v-card>
      <a-btn
          size="x-small"
          fab
          @click="showWinners = !showWinners"
          class="show-score-button"
          prepend-icon="mdi-format-list-bulleted-square"
      ></a-btn>
    </v-card>
  </v-container>
</template>

<script setup>

import {getRequest, logError, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import moment from 'moment'
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

const search = ref('')
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],})
const showScoreUser = ref({})
const showModal = ref(false)
const poolTypeId = ref(3)
const poolLoading = ref(false)
const tournamentId = ref(route.params.id)
const pool = ref({})
const poolUsers = ref([])
const tournamentOver = ref(false)
const winners = ref([])
const showWinners = ref(false)
const headers = ref([
  {text: 'User', value: 'fullName', show: true},
  {text: 'Score', value: 'score', show: true},
  {text: '', value: 'details', show: true},
])
onMounted(() => {
  getPool()
  getPoolUsers()
})

const isWinner = (poolUser) => {
  if (tournamentOver.value) {
    let topScore = poolUsers.value[0]?.score || 0
    return (poolUser.score || 0) === topScore
  }
}
const getPool = async() => {
  poolLoading.value = true
  try {
    const {data} = await getRequest(`/tournament/${tournamentId.value}/pool/byType/${poolTypeId.value}`, 'blueraven')
    pool.value = data
    tournamentOver.value = moment() > moment(pool.value.endDate).endOf('day')
    if(tournamentOver.value) {
      showWinners.value = true
    }
    poolLoading.value = false
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching pool details')

  }
}
const getPoolUsers = async() => {
  try {
    const {data} = await getRequest(`/tournament/${tournamentId.value}/pool/usersByType/${poolTypeId.value}`, 'blueraven')
    poolUsers.value = data
    poolUsers.value.forEach(u => {
      if (isWinner(u)) {
        winners.value.push(u)
      }
    })
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching pool user details')

  }
}
</script>

<style lang="scss">
#winners-pool-container .v-data-table__wrapper {
  max-height: calc(100vh - 375px);
  min-height: 300px;
}

.tourney-winning-row {
  background-color: #FFD700 !important;
}
</style>

<style lang="scss" scoped>
#winners-pool-container {
  padding: 0;
  height: calc(100vh - 110px);
}

.padded-pool {
  padding: 50px !important;
}

.congrats-card {
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
  min-height: 300px;
  height: calc(100vh - 104px);
  display: flex;
  position: relative;
  align-items: center;
  justify-content: center;
}

.congrats-inner-container {
  min-height: 200px;
}

.congrats-header {
  font-family: "Congrats", sans-serif;
  font-size: 50px;
}

.congrats-winner {
  font-size: 30px;
}

.show-score-button {
  position: absolute;
  bottom: 10px;
  right: 10px;
}

</style>


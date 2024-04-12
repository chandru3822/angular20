<template>
  <v-container id="qualifying-pool-container" v-if="!dataLoading">

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
        {{pool.customName || 'Qualifying'}}<br/>
        {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <a-btn
              variant="text"
              :disabled="bracketsEmpty"
              @click="toggleSelectAllQualifying()"
              v-if="userCanEdit && !pool.advanced"
              color="unset"
              text="Select All Qualifying"
          ></a-btn>
          <a-btn
              v-if="userCanEdit"
              :disabled="selectedUsers.length !== tournamentUserCount || pool.advanced || bracketsEmpty || matchesNotGenerated"
              color="primary"
              @click="advanceSelectedToBracket()"
              :text="matchesNotGenerated ? 'Must Generate Matches' : !pool.advanced ? 'Advance Selected to Bracket' : 'Pool Has Been Advanced'"
          ></a-btn>
          <a-btn
              v-if="userCanEdit"
              :disabled="selectedUsers.length !== tournamentUserCount || pool.advanced || bracketsEmpty || matchesNotGenerated"
              color="primary"
              @click="advanceSelectedToBracket()"
              :text="matchesNotGenerated ? 'Must Generate Matches' : !pool.advanced ? 'Advance Selected to Bracket' : 'Pool Has Been Advanced'"
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
          :fixed-header="true"
          :search="search"
          dense
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
          <tr :class="{'on-fence-row': !pool.advanced && item.score === lastQualifiedUserScore,'qualified-row': !pool.advanced && poolUsers.indexOf(item) < tournamentUserCount,'shaded-row': index % 2}">
            <td :key="selectRerender">
              <input type="checkbox" :disabled="bracketsEmpty"
                     v-if="!pool.advanced" v-model="item.selected" @change="toggleSingleSelect(item)">
              <v-icon color="green" v-else-if="item.qualified">mdi-check-decagram</v-icon>
            </td>
            <td class="text-left">
              {{item.fullName}}
            </td>
            <td class="text-center">
              <span v-if="item.score == null">Org Requires Timezone</span>
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
import orderBy from "lodash.orderby"
import ScoreDrilldown from "./component/ScoreDrilldown";
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

const tournamentId = computed(() => {
  return route.params.id
})

const poolTypeId = ref(1)
const finalMatches = ref([])
const showScoreUser = ref({})
const showModal = ref(false)
const bracketsEmpty = ref(false)
const selectRerender = ref(1)
const search = ref('')
const tournament = ref({})
const lastQualifiedUserScore = ref(null)
const tournamentUserCount = ref(0)
const matchesNotGenerated = ref(false)
const minRowsPerPage = ref(0)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],})
const dataLoading = ref(true)
const pool = ref({})
const poolUsers = ref([])
const ordered = ref([])
const selectedUsers = ref([])
const seededUserIds = ref([])
const headers = ref([
  {text: '', value: 'checkbox', show: true, width: '50px'},
  {text: 'User', value: 'fullName', show: true},
  {text: 'Score', value: 'score', show: true, width: '185px'},
  {text: '', value: 'details', show: true},
])

watch(tournamentId, async() => {
  // reset the selected group when the tournament changes
  tournament.value = {}
  pool.value = {}
  poolUsers.value = []
  selectedUsers.value = []
  matchesNotGenerated.value = false
  tournamentUserCount.value = 0
  await getTournament()
  getPool()
  getPoolUsers()
})

onMounted(async () => {
  //need the tournament first so i can see how many users can qualify
  await getTournament()
  getPool()
  getPoolUsers()
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')
})

const toggleSingleSelect = (item) => {
  if (item.selected) {
    selectedUsers.value.push(item)
  } else {
    selectedUsers.value = selectedUsers.value.filter(u => u.userId !== item.userId)
  }
}
const toggleSelectAllQualifying = () => {
  selectedUsers.value = []
  //get the score of the last qualified user based on index so we can compare others to it later
  poolUsers.value.forEach((pu, idx) => {
    if (idx < tournamentUserCount.value) {
      pu.selected = true
      selectedUsers.value.push(pu)
    } else if (pu.score === lastQualifiedUserScore.value) {
      //if a user has the same score as the final qualified user then select them also so that they have to manual decide who advances
      pu.selected = true
      selectedUsers.value.push(pu)
      minRowsPerPage.value++
      snackbar('ERROR', 'The final qualifying user is tied with other users. You will have to manually select who advances.')

    } else {
      pu.selected = false
    }
  })
  //force checkbox to rerender as selected
  selectRerender.value++
}
const advanceSelectedToBracket = async() => {
  let seededUsers = orderBy(selectedUsers.value, ['score', su => su.fullName.toLowerCase()], ['desc', 'asc'])
  seededUserIds.value = seededUsers?.map(u => u.userId)

  populateSeededMatches()

  if(seededUserIds.value?.length > 0 && finalMatches.value.length === tournamentUserCount.value / 2) {
    appStore.loading = true
    try {
      const {status} = await postRequest(`/tournament/${tournamentId.value}/pool/${pool.value.id}/assignUsersToMatches`, finalMatches.value, 'blueraven')
      pool.value.advanced = true
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Advancing Users')

      appStore.loading = false
    }
  } else {
    snackbar('ERROR', 'Error Advancing Users')

  }
}
const populateSeededMatches =  () => {
  //todo: this could probably be cleaned up a little but I got it working and that is all i care about at this point
  //reset these values every time
  ordered.value = []
  finalMatches.value = []

  let ind = []

  //populate a blank array of zeroes for the total number of users
  // (not sure why but that's how they coded the formula to work and it doesn't work if this isn't done this way)
  for(let i = 0; i < tournamentUserCount.value; i++) {
    ind.push(0)
  }

  //this creates the total number of users game indexes that i dont fully understand
  for (let i = 0; i <= (Math.log(tournamentUserCount.value) / Math.log(2)); i++) {
    for(let N = 1; N <= tournamentUserCount.value; N++)
    {
      let myRank = Math.floor((N - 1) / Math.pow(2, i) + 1);
      ind[N - 1] += Math.floor(((myRank % 4)/2)) * Math.pow(2, ( (Math.log(tournamentUserCount.value) / Math.log(2)) -  i - 1));
    }
  }

  //make an array of the games so i can order them by the game number
  //again i dont fully understand the ind[N-1]+1 stuff but i know it works cuz they coded that part
  let games = []
  for (let N = 1; N <= tournamentUserCount.value; N++){
    let gameNumber = ind[N - 1] + 1;
    let game = {
      seed: N,
      gameNumber
    }
    games.push(game)
  }

  //order them by game number
  ordered.value = orderBy(games, g => g.gameNumber);

  //the game numbers go 1,2,3,4,5,6 etc
  //i need them to go 1,1,2,2,3,3,4,4
  //this changes the game numbers accordingly
  let count = 1
  ordered.value.forEach((o, idx) => {
    o.gameNumber = count
    if(idx % 2 !== 0) {
      count++
    }
  })


  let params = {}
  for(let i = 1; i <= tournamentUserCount.value / 2; i++) {
    //find both the matches where the gameNumber === i
    let matches = ordered.value.filter(o => o.gameNumber === i)
    //turn the 2 rows into 1 object for sending to the backend
    // seededUserIds is indexed at zero and match seeds start at 1, so have to subtract 1
    params = {
      matchNumber: i,
      user1Id: seededUserIds.value[(matches[0].seed - 1)],
      user2Id: seededUserIds.value[(matches[1].seed -1)]
    }
    //populate the final results to be sent
    finalMatches.value.push(params)

    //just a quick String to display the magic on the screen in a more friendly format
    // let game = 'Game ' + i + ': ' + matches[0].seed + ' vs ' + matches[1].seed + '\n'
    // gamesString.value += game
  }
  //log it out
  // console.log('final matches', finalMatches.value)


}
const getTournament = async() => {
  try {
    const {data} = await getRequest(`/tournament/${tournamentId.value}`, 'blueraven')
    tournament.value = data
    if(tournament.value?.brackets?.length === 0) {
      bracketsEmpty.value = true
    } else {
      tournament.value?.brackets?.forEach(b => {
        tournamentUserCount.value += b.numberOfUsers
        if(!b.matchesGenerated) {
          matchesNotGenerated.value = true
        }
      })
      minRowsPerPage.value = tournamentUserCount.value > 100 ? tournamentUserCount.value : 100
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Tournament')

  }
}
const getPool = async() => {
  try {
    const {data} = await getRequest(`/tournament/${tournamentId.value}/pool/byType/${poolTypeId.value}`, 'blueraven')
    dataLoading.value = false
    pool.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching pool details')

  }
}
const getPoolUsers = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/tournament/${tournamentId.value}/pool/usersByType/${poolTypeId.value}`, 'blueraven')
    poolUsers.value = data
    if(!bracketsEmpty.value) {
      lastQualifiedUserScore.value = poolUsers.value[tournamentUserCount.value - 1].score
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching pool user details')

    appStore.loading = false
  }
}
</script>

<style lang="scss">
#qualifying-pool-container .v-data-table__wrapper {
  max-height: calc(100vh - 375px);
  min-height: 300px;
}

.qualified-row {
  /*background-color: var(--v-brGreen-base) !important;;*/
  background-color: lightgreen !important;
}

.on-fence-row {
  /*background-color: var(--v-brGreen-base) !important;;*/
  background-color: #cdfacd !important;
}
</style>

<style lang="scss" scoped>
#qualifying-pool-container {
  padding: 50px;
}
</style>


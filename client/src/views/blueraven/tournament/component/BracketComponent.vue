<template>
  <section id="bracket" :class="{'opposite': reverse}">
    <v-dialog v-model="showModal" class="square-card">
      <ScoreDrilldown :tournament-id="bracket.tournamentId"
                      :start-date="showScoreData.round.startDate"
                      :end-date="showScoreData.round.endDate"
                      :user="showScoreData.user"
                      :user-id="showScoreData.userId"
                      @scoreDialogClosed="showModal = false"
      ></ScoreDrilldown>
    </v-dialog>

    <v-dialog v-model="showOverrideModal" class="square-card" width="500">
      <v-card>
        <v-card-title
            class="text-h5 grey lighten-2"
            primary-title>
          Bracket User Override
        </v-card-title>
        <v-card-text class="pt-4">
          <a-autocomplete
              v-model="overrideUser"
              :items="overrideUsers"
              label="Select a user"
              item-title="fullName"
              return-object
              attach
          ></a-autocomplete>

          <div v-if="overrideUser.id">
            <strong>{{ showScoreData.user }} will be replaced by {{ overrideUser.fullName }}</strong>
          </div>
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <a-btn
              @click="[overrideUser = {}, showOverrideModal = false]"
              color="unset"
              text="Cancel"
          ></a-btn>
          <a-btn
              @click="overrideMatchUser"
              :disabled="!overrideUser.id"
              color="primary"
              text="Save"
          ></a-btn>
        </v-card-actions>

      </v-card>
    </v-dialog>

    <div class="container">
      <div class="split split-one">
        <div class="round"
             :class="`round-${r.roundNumber}`"
             v-for="(r, idx) in reverse ? itemsReverse : bracket.rounds">
          <div class="round-details"
               :key="roundRerenderKey"
               :class="{'current': isCurrentRound(r),
                          'bold': isCurrentRound(r)}">
            <v-icon v-if="canEditRound(r)" class="edit-button clickable"
                    size="15" @click="rerender(r)">edit</v-icon>
            <v-icon v-if="userCanEdit && r.edit" class="edit-button clickable"
                    size="15" @click="rerender(r)">close</v-icon>
            <v-icon v-if="userCanEdit && r.edit" class="save-button clickable"
                    size="15" @click="advanceMatches(r)">save</v-icon>
            <v-icon size="15" color="green"
                    v-if="r.advanced && r.roundNumber === bracket.rounds.length"
                    class="advance-button">
              mdi-check-decagram
            </v-icon>
            <v-dialog
                v-if="canAdvanceWinners(r)"
                class="advance-button-container"
                v-model="r.advanceConfirm"
                width="500">
              <template v-slot:activator="{ on }">
                <a-btn
                    variant="text"
                    size="x-small"
                    :activation-handler="on"
                    class="advance-button"
                    color="unset"
                    prepend-icon="mdi-arrow-top-right"
                ></a-btn>
              </template>
              <v-card>
                <v-card-title
                    class="text-h5 grey lighten-2"
                    primary-title
                >
                  Confirm
                </v-card-title>

                <v-card-text>
                  Are you sure you want to advance these users to the final pool?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <a-btn
                      @click="r.advanceConfirm = false"
                      color="unset"
                      text="No"
                  ></a-btn>
                  <a-btn
                      color="primary"
                      variant="text"
                      @click="[r.advanceConfirm = true, advanceWinners(r)]"
                      text="Yes"
                  ></a-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
            <div v-if="r.roundNumber === bracket.rounds.length">
              FINALISTS
            </div>
            <div v-else>
              Round {{r.roundNumber}}<br/>
              <span class="date">
                  {{r.startDate | formatDate('date', 'M/D')}} -
                  {{r.endDate | formatDate('date', 'M/D')}}
                </span>
            </div>
          </div>
          <ul class="matchup" v-for="(m, i) in r.matches" :class="{'mb-4': getSpacingByIndex(idx, i)}">
            <v-radio-group v-model="m.winnerUserId">
              <li class="team team-top" :class="{'current': isCurrentRound(r)}">
                <v-radio v-if="r.edit && m.user1Id && m.user2Id" :value="m.user1Id" class="d-inline-block"></v-radio>
                <div class="d-inline-block one-hunned" @click="handleMatchUserClick(r, m, true)">
                  {{m.user1Name}}
                  <span class="score" v-if="r.roundNumber !== bracket.rounds.length">{{m.user1Score}}</span>
                </div>
              </li>
              <li class="team team-bottom" :class="{'current': isCurrentRound(r)}">
                <v-radio small v-if="r.edit && m.user1Id && m.user2Id" :value="m.user2Id" class="d-inline-block"></v-radio>
                <div class="d-inline-block one-hunned" @click="handleMatchUserClick(r, m, false)">
                  {{m.user2Name}}
                  <span class="score" v-if="r.roundNumber !== bracket.rounds.length">{{m.user2Score}}</span>
                </div>
              </li>

            </v-radio-group>
          </ul>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, putRequest, putRequestWithRequestParams, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ScoreDrilldown from "./ScoreDrilldown"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'


const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  bracket: {type: Object},
  bracketCount: {type: Number},
  rowNumber: {type: Number},
  reverse: {type: Boolean}
})
const { bracket, bracketCount, rowNumber, reverse } = toRefs(props)

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')
})
const itemsReverse = computed(() => {
  return [...bracket.value?.rounds].reverse()
})

const showModal = ref(false)
const overrideUser = ref({})
const overrideUsers = ref([])
const showOverrideModal = ref(false)
const showScoreData = ref({userId: null,user: null,isUser1: null,matchId: null,round: {}})
const roundRerenderKey = ref(0)
const firstNonAdvancedRound = ref({})

const getOverrideUsers = async() => {
  try {
    const {data, status} = await getRequest(`/user/active`)
    overrideUsers.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Users')

    appStore.loading = false
  }
}
const overrideMatchUser = async() => {
  appStore.loading = true
  try {
    await putRequestWithRequestParams(`/tournament/match/${showScoreData.value.matchId}/userOverride`, null, { userId: overrideUser.value.id , overrideUser1: showScoreData.value.isUser1 }, 'blueraven')
    roundRerenderKey.value++
    //maybe we dont have to do this but i am doing it for v1
    window.location.reload(true)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    appStore.showSnack('ERROR', 'Error Saving Data')

    appStore.loading = false
  }
}
const handleMatchUserClick = async(r, m, user1) => {
  if(r.edit) {

    await getOverrideUsers(user1)
    showScoreData.value.user = user1 ? m.user1Name : m.user2Name
    showScoreData.value.userId = user1 ? m.user1Id : m.user2Id
    showScoreData.value.matchId = m.id
    showScoreData.value.isUser1 = user1
    showOverrideModal.value = true
  } else {
    showScoreData.value.user = user1 ? m.user1Name : m.user2Name
    showScoreData.value.userId = user1 ? m.user1Id : m.user2Id
    showScoreData.value.round = r
    showModal.value = true
  }
}
const getSpacingByIndex = (roundIndex, matchIndex) => {
  return reverse.value ? roundIndex === bracket.value?.rounds?.length - 1 && matchIndex % 2 !== 0 : roundIndex === 0 && matchIndex % 2 !== 0
}
const isCurrentRound = (r) => {
  bracket.value.firstNonAdvancedRound = bracket.value?.rounds.find(r => !r.advanced)
  return r.id === bracket.value?.firstNonAdvancedRound?.id
}
const canAdvanceWinners = (r) => {
  let allMatchesHaveUsers = !!(r.matches && r.matches.length !== 0)
  r.matches.forEach(m => {
    if(!m.user1Id || !m.user2Id) {
      allMatchesHaveUsers = false
    }
  })
  return allMatchesHaveUsers && !r.advanced && r.roundNumber === bracket.value.rounds.length && userCanEdit.value
}
const canEditRound = (r) => {
  let allMatchesHaveUsers = true
  r.matches.forEach(m => {
    if(!m.user1Id || !m.user2Id) {
      allMatchesHaveUsers = false
    }
  })
  return allMatchesHaveUsers && !r.advanced && r.roundNumber !== bracket.value.rounds.length && userCanEdit.value && !r.edit
}
const advanceWinners = async(round) => {
  round.advanced = true
  round.advanceConfirm = false
  appStore.loading = true
  try {
    const {status} = await putRequest(`/tournament/${bracket.value.tournamentId}/round/${round.id}/advanceWinners`, round.matches, 'blueraven')
    appStore.showSnack('SUCCESS', 'Finalists Advanced')

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    appStore.showSnack('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const rerender = (r) => {
  //i hate this crap
  r.edit = !r.edit
  //pre-populate the winner if not tied
  r?.matches.forEach(m => {
    if(m.user1Score > m.user2Score) {
      m.winnerUserId = m.user1Id
    } else if (m.user2Score > m.user1Score){
      m.winnerUserId = m.user2Id
    }
  })
  roundRerenderKey.value++
}
const advanceMatches = async(round) => {
  let allMatchesHaveWinners = true
  round?.matches.forEach(m => {
    if(!m.winnerUserId) {
      allMatchesHaveWinners = false
      appStore.showSnack('ERROR', 'All matches must have a winner selected')

      return
    }
  })
  if(allMatchesHaveWinners) {
    appStore.loading = true
    try {
      await putRequest(`/tournament/${bracket.value.tournamentId}/advance`, round.matches, 'blueraven')
      round.edit = false
      roundRerenderKey.value++
      //maybe we dont have to do this but i am doing it for v1
      window.location.reload(true)
    } catch (e) {
      console.error('*** ERROR ***', e)
      dataLoading.value = false
      appStore.showSnack('ERROR', 'Error Retrieving Data')

      appStore.loading = false
    }
  }
}
</script>

<style lang="scss" scoped>

#bracket {
  font-size: 12px;
  padding: 8px 0;
}

.opposite {
  float: right !important;
  padding-right: 20px !important;
}

.split {
  display: flex;
  width: 100%;
  -webkit-flex-direction: row;
  -moz-flex-direction: row;
  flex-direction: row;
}

.round {
  --round-width: 150px;
  display: flex;
  -webkit-flex-direction: column;
  flex-direction: column;
  width: var(--round-width);
}

.split-one .round {
  margin: 0 2.5% 0 0;
}

.matchup {
  margin: 0 0 5px 0;
  width: var(--round-width);
  padding: 0;
  height: 60px;
  -webkit-transition: all 0.2s;
  transition: all 0.2s;
}

.score {
  font-size: 11px;
  text-transform: uppercase;
  float: right;
  color: var(--v-primaryText-base) !important;
  font-weight: bold;
  font-family: 'Roboto Condensed', sans-serif;
  position: absolute;
  right: 5px;
}

.team {
  display: flex;
  padding: 0 5px;
  margin: 3px 0;
  height: 25px;
  line-height: 25px;
  white-space: nowrap;
  overflow: hidden;
  position: relative;
}

.round-2 .matchup {
  margin: 0;
  height: 141px;
  padding: 32px 0;
}

.round-3 .matchup {
  margin: 0;
  height: 280px;
  padding: 100px 0;
}

.round-4 .matchup {
  margin: 0;
  height: 560px;
  padding: 240px 0;
}

.round-5 .matchup {
  margin: 0;
  height: 1120px;
  padding: 520px 0;
}

.round-details {
  font-family: 'Roboto Condensed', sans-serif;
  font-size: 13px;
  width: var(--round-width);
  position: relative;
  height: 75px;
  color: var(--v-primaryText-base) !important;
  background-color: #fff;
  text-transform: uppercase;
  text-align: center;
  border: solid 2px #F0F0F0;
  display: flex;
  align-items: center;
  justify-content: center;

}

.current{
  opacity: 1 !important;
  background-color: #FFF !important;

}

.team, .round-details {
  background-color: #F0F0F0;
  /*background-color: #;*/
  font-size: 12px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
  opacity: .95;
}

.date {
  font-size: 10px;
  letter-spacing: 2px;
  font-family: 'Istok Web', sans-serif;
  color: var(--v-success-base);
}

.edit-button {
  position: absolute;
  bottom: 0;
  left: 0;
  padding: 0;
}

.save-button {
  position: absolute;
  bottom: 0;
  left: 20px;
  padding: 0;
}

.advance-button-container {
  position: relative;
}

.advance-button {
  position: absolute;
  bottom: 0;
  right: 0;
  padding: 0;
}



</style>


<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="title-large">Brackets</v-toolbar-title>
          <v-spacer></v-spacer>
          <AlbatrossButton
              icon
              color="primary"
              @click="addBracket = !addBracket"
              :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
              prepend-icon="add"
          />
        </v-toolbar>
        <v-card flat v-if="addBracket">
          <v-text-field text
                        label="Number of Users"
                        class="mb-2"
                        type="number"
                        hint="[2, 4, 8, 16, 32, 64, 128]"
                        persistent-hint
                        v-model.number="newBracket.numberOfUsers"></v-text-field>
          <div class="error-text" v-if="bracketError">{{ bracketErrorMsg }}</div>
          <AlbatrossButton
              color="primary"
              :disabled="!newBracket.numberOfUsers"
              @click="addNewBracket"
              text="Save"/>
          <AlbatrossButton
              color="primary"
              v-if="edit"
              @click="[addBracket = !addBracket, newBracket = {}]"
              text="Cancel"/>
        </v-card>
        <div :key="bracketRerenderKey">
          <v-card flat
                  :class="{'shaded-row': index % 2}" class="pa-3 square-card"
                  v-for="(b, index) in filteredBrackets" :key="index">
            <v-toolbar flat color="transparent">
              <v-toolbar-title class="title-large text-wrap">
                Bracket #{{ index + 1 }}: {{ b.numberOfUsers }} Users
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <AlbatrossButton
                  variant="text"
                  color="primary"
                  :class="{'no-display': b.matchesGenerated && $vuetify.breakpoint.xsOnly}"
                  :disabled="b.matchesGenerated || b.rounds.length === 0"
                  @click="bracketForMatches = b">
                <template v-slot:default>
                  <v-icon large v-if="!b.matchesGenerated && $vuetify.breakpoint.smAndDown">mdi-tournament</v-icon>
                  <span v-else-if="!b.matchesGenerated">Generate Matches</span>
                  <span v-else>MATCHES CREATED</span>
                </template>
              </AlbatrossButton>

              <AlbatrossButton v-if="b.maxRounds"
                               variant="text"
                               disabled
                  color="primary"
                  :disabled="b.matchesGenerated || b.rounds.length === 0"
              :text="$vuetify.breakpoint.smAndDown ? 'Max' : 'Max Rounds Reached'"/>

              <AlbatrossButton
                  v-else-if="!b.matchesGenerated"
                  variant="text"
                  color="primary"
                  @click="[b.addRound = !b.addRound, rerenderBracket()]">
                <template v-slot:default>
                  <v-icon large v-if="!b.addRound && $vuetify.breakpoint.smAndDown">add</v-icon>
                  <span v-else-if="!b.addRound">Add Round</span>
                  <span v-else>Cancel</span>
                </template>
              </AlbatrossButton>

              <AlbatrossButton
                  v-if="userCanEdit"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                  class="mx-3"
                  icon
                  color="primary"
                  prepend-icon="mdi-content-copy"
                  @click="bracketToCopy=b">
              </AlbatrossButton>

              <AlbatrossButton
                  v-if="userCanDelete"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                  class="mx-3"
                  icon
                  color="primary"
                  prepend-icon="delete"
                  @click="bracketToDelete=b">
              </AlbatrossButton>
            </v-toolbar>
            <v-card flat v-if="b.addRound">
              <DatetimePickerInput
                  v-model="newRound.startDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Start Date"
              />
              <DatetimePickerInput
                  v-model="newRound.endDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="End Date"
              />
              <AlbatrossButton
                  color="primary"
                  :disabled="!newRound.startDate || !newRound.endDate || newRound.startDate > newRound.endDate"
                  @click="saveRound(b, newRound)"
                  text="Save"/>
            </v-card>
            <v-data-table
                :key="rerenderKey"
                :headers="headers"
                :items="filterRounds(b)"
                hide-default-footer
                :items-per-page="-1"
                disable-sort
                class="elevation-1 square-card table-striped"
            >
              <template #no-data>
                <span class="default-text-color">No available rounds</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No available rounds</span>
              </template>


              <template #item.users="{item}" class="text-left">
                {{ getNumberOfUsers(b, item) }}
              </template>
              <template #item.matches="{item}" class="text-left">
                {{ getNumberOfMatches(b, item) }}
              </template>
              <template #item.startDate="{item}" class="text-left">
                <span v-if="!item.edit">{{ item.startDate | formatDate('date', 'MM/DD/YYYY') }}</span>
                <DatetimePickerInput
                    v-else
                    v-model="item.startDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MMMM DD, YYYY'"
                    label="Start Date"
                />
              </template>
              <template #item.endDate="{item}" class="text-left">
                <span v-if="!item.edit">{{ item.endDate | formatDate('date', 'MM/DD/YYYY') }}</span>
                <DatetimePickerInput
                    v-else
                    v-model="item.endDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MMMM DD, YYYY'"
                    label="End Date"
                />
              </template>
              <template #item.notes="{item, index}">
                <div v-if="index === b.rounds.length - 1">
                  NOTE: This is the final round, it is for displaying the finalists. It will not actually be played.
                </div>
              </template>
              <template #item.icons="{item}" class="text-right">
                <AlbatrossButton
                    v-if="userCanEdit"
                    variant="text"
                    size="small"
                    color="primary"
                    prepend-icon="mdi-content-copy"
                    @click="[item.edit = !item.edit, rerenderKey++]"
                    :prepend-icon="!item.edit ? 'edit' : ''"
                  :text="item.edit ? 'cancel' : ''">
                </AlbatrossButton>

                <AlbatrossButton
                    v-if="item.edit"
                    variant="text"
                    icon
                    size="small"
                    :class="{'mx-4': $vuetify.breakpoint.smAndDown}"
                    color="primary"
                    :disabled="!item.startDate || !item.endDate || item.startDate > item.endDate"
                    @click="saveRound(b, item)"
                    text="Save">
                </AlbatrossButton>


                <AlbatrossButton
                    v-if="!b.matchesGenerated && userCanDelete"
                    variant="text"
                    icon
                    :class="{'mx-4': $vuetify.breakpoint.smAndDown}"
                    color="primary"
                    prepend-icon="delete"
                    @click="[roundToDelete = item, bracketToDeleteRoundFrom = b]">
                </AlbatrossButton>
              </template>
            </v-data-table>
          </v-card>
        </div>
      </v-col>

    </v-row>
    <ConfirmationDialog :open-dialog="!!roundToDelete" @confirm="deleteRound" @close-dialog="roundToDelete = null">
      Are you sure you want to delete this round?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!bracketToDelete" @confirm="deleteBracket"
                        @close-dialog="bracketToDelete = null">
      Are you sure you want to delete this bracket?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!bracketToCopy" @confirm="replicateBracket" @close-dialog="bracketToCopy = null">
      <template v-slot:title>Replicate Bracket</template>
      Are you sure you want to replicate this bracket?
      <template v-slot:yes>Replicate</template>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!bracketForMatches" @confirm="generateMatches"
                        @close-dialog="bracketForMatches = null">
      <template v-slot:title>Create Matches</template>
      <span class="error--text"><strong>WARNING: This can only be done once. </strong></span><br/>
      Please ensure that your rounds are created correctly in this bracket before generating matches.
      Would you like to continue creating matches?
      <template v-slot:yes>Create Matches</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {getCurrentInstance, computed, ref, onMounted} from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
import {useRoute} from "vue-router/composables";
import {useUserStore} from '@/stores/UserStorePinia.js'
import constants from "@/helpers/constants.js";
const userStore = useUserStore()

const route = useRoute()

const edit = ref(false)
const rerenderKey = ref(0)
const validNumUsers = [2, 4, 8, 16, 32, 64]
const bracketRerenderKey = ref(0)
const tournament = ref({})
const newBracket = ref({})
const addBracket = ref(false)
const bracketError = ref(false)
const bracketErrorMsg = ref('')
const newRound = ref({})
const addRound = ref(false)
const ownerTypes = ref([])
const bracketToDelete = ref(null)
const bracketToCopy = ref(null)
const bracketForMatches = ref(null)
const roundToDelete = ref(null)
const bracketToDeleteRoundFrom = ref(null)
const headers = ref([
  {text: 'Round', value: 'roundNumber', show: true},
  {text: 'Users', value: 'users', show: true},
  {text: 'Matches', value: 'matches', show: true},
  {text: 'Start Date', value: 'startDate', show: true},
  {text: 'End Date', value: 'endDate', show: true},
  {text: null, value: 'notes', show: true},
  {text: null, value: 'icons', show: true}
])

const tournamentId = computed(() => {
  return route.params.id
})
const userId = computed(() => {
  return userStore.details.id
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')
})

const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('TOURNAMENTS', 'DELETE')
})

const timezone = computed(() => {
  return userStore.details.timezone?.value
})

onMounted(() => {
  getTournamentOwnerTypes()
  getTournament()
})

const filteredBrackets = computed(() => {
  return tournament.value?.brackets?.filter(b => !b.archived)
})

const rerenderBracket = () => {
  bracketRerenderKey.value++
}

const getNumberOfUsers = (bracket, round) => {
  if (round.roundNumber === 1) {
    return bracket.numberOfUsers
  } else {
    let counter = bracket.numberOfUsers
    for (let i = 1; i < round.roundNumber; i++) {
      counter = counter / 2
    }
    return counter
  }
}
const getNumberOfMatches = (bracket, round) => {
  let numUsers = getNumberOfUsers(bracket, round)
  if (numUsers <= 1) {
    bracket.maxRounds = true
  }
  return numUsers > 1 ? numUsers / 2 : 'None'
}
const replicateBracket = async () => {
  let b = bracketToCopy.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await postRequest(`/tournament/bracket/replicate`, b, 'blueraven')
    // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
    data.maxRounds = false
    tournament.value.brackets.push(data)
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Bracket')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getTournamentOwnerTypes = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
    ownerTypes.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getTournament = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/tournament/${tournamentId.value}`, 'blueraven')
    // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
    data?.brackets?.forEach(b => {
      b.maxRounds = false
    })
    tournament.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Tournament')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const updateTournament = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await putRequest(`/tournament`, tournament.value, 'blueraven')
    tournament.value = data
    edit.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Tournament')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const addNewBracket = async () => {
  if (validNumUsers.includes(newBracket.value.numberOfUsers)) {
    bracketError.value = false
    bracketErrorMsg.value = ''
    store.commit(AppMutations.SET_LOADING, true)
    try {
      let param = {
        numberOfUsers: newBracket.value.numberOfUsers,
        tournamentId: tournament.value.id
      }
      const {data, status} = await postRequest(`/tournament/bracket`, param, 'blueraven')
      // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
      data.maxRounds = false
      tournament.value.brackets.push(data)
      addBracket.value = false
      newBracket.value = {}
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Bracket')
      store.commit(AppMutations.SET_LOADING, false)
    }
  } else {
    bracketError.value = true
    bracketErrorMsg.value = 'Number of Users must be 2, 4, 8, 16, 32, or 64'
  }
}
const deleteBracket = async () => {
  let id = bracketToDelete.value.id
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/tournament/bracket/${id}`, 'blueraven')
    snackbar('SUCCESS', 'Bracket Deleted')
    tournament.value.brackets.splice(tournament.value.brackets.indexOf(bracketToDelete.value))
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Bracket')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveRound = async (bracket, round) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    let param = {
      id: round?.id,
      tournamentBracketId: bracket.id,
      startDate: round.startDate,
      endDate: round.endDate
    }
    const {data, status} = await putRequest(`/tournament/round`, param, 'blueraven')
    bracket.rounds = data.rounds
    if (round.id) {
      round.edit = false
    } else {
      bracket.addRound = false
      newRound.value = {}
    }
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Round')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteRound = async () => {
  let bracket = bracketToDeleteRoundFrom.value
  let roundId = roundToDelete.value.id
  store.commit(AppMutations.SET_LOADING, true)
  try {
    let param = {
      id: roundId,
      tournamentBracketId: bracket.id
    }
    const {data, status} = await putRequest(`/tournament/round/${roundId}/delete`, param, 'blueraven')
    bracket.rounds = data.rounds
    // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
    bracket.maxRounds = false
    snackbar('SUCCESS', 'Round Deleted')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Round')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const generateMatches = async () => {
  let bracket = bracketForMatches.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/tournament/bracket/${bracket.id}/generateMatches`, {}, 'blueraven')
    //disable the button
    bracket.matchesGenerated = true
    snackbar('SUCCESS', 'Matches Generated')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Generating Matches')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const filterRounds = (bracket) => {
  return bracket?.rounds.filter(r => {
    return !r.archived
  })
}

</script>

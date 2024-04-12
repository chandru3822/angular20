<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="title-large">Brackets</v-toolbar-title>
          <v-spacer></v-spacer>
          <a-btn
              icon
              color="primary"
              @click="addBracket = !addBracket"
              :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
              prepend-icon="add"
          />
        </v-toolbar>
        <v-card flat v-if="addBracket">
          <a-text-field
                        label="Number of Users"
                        class="mb-2"
                        type="number"
                        hint="[2, 4, 8, 16, 32, 64, 128]"
                        persistent-hint
                        v-model.number="newBracket.numberOfUsers"></a-text-field>
          <div class="error-text" v-if="bracketError">{{ bracketErrorMsg }}</div>
          <a-btn
              color="primary"
              :disabled="!newBracket.numberOfUsers"
              @click="addNewBracket"
              text="Save"/>
          <a-btn
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
              <a-btn
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
              </a-btn>

              <a-btn v-if="b.maxRounds"
                               variant="text"
                               disabled
                  color="primary"
                  :disabled="b.matchesGenerated || b.rounds.length === 0"
              :text="$vuetify.breakpoint.smAndDown ? 'Max' : 'Max Rounds Reached'"/>

              <a-btn
                  v-else-if="!b.matchesGenerated"
                  variant="text"
                  color="primary"
                  @click="[b.addRound = !b.addRound, rerenderBracket()]">
                <template v-slot:default>
                  <v-icon large v-if="!b.addRound && $vuetify.breakpoint.smAndDown">add</v-icon>
                  <span v-else-if="!b.addRound">Add Round</span>
                  <span v-else>Cancel</span>
                </template>
              </a-btn>

              <a-btn
                  v-if="userCanEdit"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                  class="mx-3"
                  icon
                  color="primary"
                  prepend-icon="mdi-content-copy"
                  @click="bracketToCopy=b">
              </a-btn>

              <a-btn
                  v-if="userCanDelete"
                  :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
                  class="mx-3"
                  icon
                  color="primary"
                  prepend-icon="delete"
                  @click="bracketToDelete=b">
              </a-btn>
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
              <a-btn
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
                <a-btn
                    v-if="userCanEdit"
                    variant="text"
                    size="small"
                    color="primary"
                    prepend-icon="mdi-content-copy"
                    @click="[item.edit = !item.edit, rerenderKey++]"
                    :prepend-icon="!item.edit ? 'edit' : ''"
                  :text="item.edit ? 'cancel' : ''">
                </a-btn>

                <a-btn
                    v-if="item.edit"
                    variant="text"
                    icon
                    size="small"
                    :class="{'mx-4': $vuetify.breakpoint.smAndDown}"
                    color="primary"
                    :disabled="!item.startDate || !item.endDate || item.startDate > item.endDate"
                    @click="saveRound(b, item)"
                    text="Save">
                </a-btn>


                <a-btn
                    v-if="!b.matchesGenerated && userCanDelete"
                    variant="text"
                    icon
                    :class="{'mx-4': $vuetify.breakpoint.smAndDown}"
                    color="primary"
                    prepend-icon="delete"
                    @click="[roundToDelete = item, bracketToDeleteRoundFrom = b]">
                </a-btn>
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
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
import {useRoute} from "vue-router/composables";
import {useUserStore} from '@/stores/UserStore.js'
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
  return userStore.timezone.value
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
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/tournament/bracket/replicate`, b, 'blueraven')
    // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
    data.maxRounds = false
    tournament.value.brackets.push(data)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Bracket')
    appStore.loading = false
  }
}
const getTournamentOwnerTypes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
    ownerTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getTournament = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/tournament/${tournamentId.value}`, 'blueraven')
    // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
    data?.brackets?.forEach(b => {
      b.maxRounds = false
    })
    tournament.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Tournament')
    appStore.loading = false
  }
}
const updateTournament = async () => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/tournament`, tournament.value, 'blueraven')
    tournament.value = data
    edit.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Tournament')
    appStore.loading = false
  }
}
const addNewBracket = async () => {
  if (validNumUsers.includes(newBracket.value.numberOfUsers)) {
    bracketError.value = false
    bracketErrorMsg.value = ''
    appStore.loading = true
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
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Bracket')
      appStore.loading = false
    }
  } else {
    bracketError.value = true
    bracketErrorMsg.value = 'Number of Users must be 2, 4, 8, 16, 32, or 64'
  }
}
const deleteBracket = async () => {
  let id = bracketToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/tournament/bracket/${id}`, 'blueraven')
    snackbar('SUCCESS', 'Bracket Deleted')
    tournament.value.brackets.splice(tournament.value.brackets.indexOf(bracketToDelete.value))
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Bracket')
    appStore.loading = false
  }
}
const saveRound = async (bracket, round) => {
  appStore.loading = true
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
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Round')
    appStore.loading = false
  }
}
const deleteRound = async () => {
  let bracket = bracketToDeleteRoundFrom.value
  let roundId = roundToDelete.value.id
  appStore.loading = true
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
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Round')
    appStore.loading = false
  }
}
const generateMatches = async () => {
  let bracket = bracketForMatches.value
  appStore.loading = true
  try {
    const {status} = await putRequest(`/tournament/bracket/${bracket.id}/generateMatches`, {}, 'blueraven')
    //disable the button
    bracket.matchesGenerated = true
    snackbar('SUCCESS', 'Matches Generated')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Generating Matches')
    appStore.loading = false
  }
}
const filterRounds = (bracket) => {
  return bracket?.rounds.filter(r => {
    return !r.archived
  })
}

</script>

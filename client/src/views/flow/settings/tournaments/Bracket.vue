<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Brackets</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn text color="primary" @click="addBracket = !addBracket">
            <v-icon>add</v-icon>
          </v-btn>
        </v-toolbar>
        <v-card flat v-if="addBracket">
          <v-text-field text
                        label="Number of Users"
                        class="mb-2"
                        type="number"
                        hint="[2, 4, 8, 16, 32, 64, 128]"
                        persistent-hint
                        v-model.number="newBracket.numberOfUsers"></v-text-field>
          <div class="error-text" v-if="bracketError">{{bracketErrorMsg}}</div>
          <v-btn color="primary"
                 class="white--text"
                 :disabled="!newBracket.numberOfUsers"
                 @click="addNewBracket">
            Save
          </v-btn>
          <v-btn text color="primary" @click="[addBracket = !addBracket, newBracket = {}]">
            Cancel
          </v-btn>
        </v-card>
        <div :key="bracketRerenderKey">
          <v-card flat

                  :class="{'shaded-row': index % 2}" class="pa-3 square-card"
                  v-for="(b, index) in filterBy(tournament.brackets, false, 'archived')" :key="index">
            <v-toolbar flat color="transparent">
              <v-toolbar-title class="app-title">
                Bracket #{{index + 1}}: {{ b.numberOfUsers }} Users
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <v-btn color="primary"
                     @click="bracketForMatches = b"
                     :disabled="b.matchesGenerated || b.rounds.length === 0">
                <span v-if="!b.matchesGenerated">Generate Matches</span>
                <span v-else>Matches Created</span>
              </v-btn>
              <v-btn v-if="b.maxRounds" text disabled color="primary" class="white--text">
                <span>Max Rounds Reached</span>
              </v-btn>
              <v-btn text color="primary" v-else-if="!b.matchesGenerated" class="white--text"
                     @click="[b.addRound = !b.addRound, rerenderBracket()]">
                <span v-if="!b.addRound">Add Round</span>
                <span v-else>Cancel</span>
              </v-btn>
              <v-btn small text color="primary" @click="bracketToCopy=b"
                     v-if="$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')">
                <v-icon>mdi-content-copy</v-icon>
              </v-btn>
              <v-btn small color="primary" text v-if="$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'DELETE')" @click="bracketToDelete=b"><v-icon>delete</v-icon></v-btn>
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
              <v-btn color="primary"
                     class="white--text mb-3"
                     :disabled="!newRound.startDate || !newRound.endDate || newRound.startDate > newRound.endDate"
                     @click="saveRound(b, newRound)">Save
              </v-btn>
            </v-card>
            <v-data-table
              :key="rerenderKey"
              :headers="headers"
              :items="filterRounds(b)"
              hide-default-footer
              :items-per-page="-1"
              disable-sort
              class="elevation-1 square-card"
            >
              <template #no-data>
                <span class="default-text-color">No available rounds</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No available rounds</span>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">
                    {{item.roundNumber}}
                  </td>
                  <td class="text-left">
                    {{ getNumberOfUsers(b, item) }}
                  </td>
                  <td class="text-left">
                    {{ getNumberOfMatches(b, item) }}
                  </td>
                  <td class="text-left">
                    <span v-if="!item.edit">{{item.startDate | formatDate('date', 'MM/DD/YYYY')}}</span>
                    <DatetimePickerInput
                      v-else
                      v-model="item.startDate"
                      :timezone="timezone"
                      :type="'date'"
                      :format="'MMMM DD, YYYY'"
                      label="Start Date"
                    />
                  </td>
                  <td class="text-left">
                    <span v-if="!item.edit">{{item.endDate | formatDate('date', 'MM/DD/YYYY')}}</span>
                    <DatetimePickerInput
                      v-else
                      v-model="item.endDate"
                      :timezone="timezone"
                      :type="'date'"
                      :format="'MMMM DD, YYYY'"
                      label="End Date"
                    />
                  </td>
                  <td>
                    <div v-if="index === b.rounds.length - 1">
                      NOTE: This is the final round, it is for displaying the finalists. It will not actually be played.
                    </div>
                  </td>
                  <td class="text-right">
                    <v-btn small text color="primary" @click="[item.edit = !item.edit, rerenderKey++]">
                      <v-icon v-if="!item.edit">edit</v-icon>
                      <span v-else>cancel</span>
                    </v-btn>
                    <v-btn v-if="item.edit" text color="primary"
                           :disabled="!item.startDate || !item.endDate || item.startDate > item.endDate"
                           @click="saveRound(b, item)">Save
                    </v-btn>
                    <v-btn text color="primary" @click="[roundToDelete = item, bracketToDeleteRoundFrom = b]"
                           v-if="!b.matchesGenerated && $store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'DELETE')">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-card>
        </div>
      </v-col>

    </v-row>
    <ConfirmationDialog :open-dialog="!!roundToDelete" @confirm="deleteRound" @close-dialog="roundToDelete = null">
      Are you sure you want to delete this round?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!bracketToDelete" @confirm="deleteBracket" @close-dialog="bracketToDelete = null">
      Are you sure you want to delete this bracket?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!bracketToCopy" @confirm="replicateBracket" @close-dialog="bracketToCopy = null">
      <template v-slot:title>Replicate Bracket</template>
      Are you sure you want to replicate this bracket?
      <template v-slot:yes>Replicate</template>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!bracketForMatches" @confirm="generateMatches" @close-dialog="bracketForMatches = null">
      <template v-slot:title>Create Matches</template>
      <span class="error--text"><strong>WARNING: This can only be done once. </strong></span><br/>
      Please ensure that your rounds are created correctly in this bracket before generating matches.
      Would you like to continue creating matches?
      <template v-slot:yes>Create Matches</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {
    handleHidingGlobalLoader,
    getRequest,
    deleteRequest,
    putRequest,
    postRequest,
    getSnackbar
  } from '@/helpers/helpers'
  import ConfirmationDialog from "../../../../ConfirmationDialog";

  export default {
    name: 'BracketAdmin',
    mixins: [Vue2Filters.mixin],
    components: {
      ConfirmationDialog,
      DatetimePickerInput
    },
    data() {
      return {
        snackbar: {},
        edit: false,
        rerenderKey: 0,
        validNumUsers: [2, 4, 8, 16, 32, 64],
        bracketRerenderKey: 0,
        tournament: {},
        newBracket: {},
        addBracket: false,
        bracketError: false,
        bracketErrorMsg: '',
        newRound: {},
        timezone: this.$store.state.user.details.timezone.value,
        addRound: false,
        ownerTypes: [],
        tournamentId: this.$route.params.id,
        userId: this.$store.state.user.details.id,
        headers: [
          {text: 'Round', value: 'roundNumber', show: true},
          {text: 'Users', value: 'users', show: true},
          {text: 'Matches', value: 'matches', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
          {text: null, value: 'notes', show: true},
          {text: null, value: 'icons', show: true}
        ],
        bracketToDelete: null,
        bracketToCopy: null,
        bracketForMatches: null,
        roundToDelete: null,
        bracketToDeleteRoundFrom: null
      }
    },
    computed: {},
    methods: {
      rerenderBracket() {
        this.bracketRerenderKey++
      },
      getNumberOfUsers(bracket, round) {
        if(round.roundNumber === 1) {
          return bracket.numberOfUsers
        } else {
          let counter = bracket.numberOfUsers
          for(let i = 1; i < round.roundNumber; i++) {
            counter = counter / 2
          }
          return counter
        }
      },
      getNumberOfMatches(bracket, round) {
        let numUsers = this.getNumberOfUsers(bracket, round)
        if(numUsers <= 1) {
          bracket.maxRounds = true
        }
        return numUsers > 1 ? numUsers / 2 : 'None'
      },
      async replicateBracket() {
        let b = this.bracketToCopy
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/tournament/bracket/replicate`, b, 'blueraven')
          // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
          data.maxRounds = false
          this.tournament.brackets.push(data)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Bracket')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournamentOwnerTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
          this.ownerTypes = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
          data?.brackets?.forEach(b => {
            b.maxRounds = false
          })
          this.tournament = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await putRequest(`/tournament`, this.tournament, 'blueraven')
          this.tournament = data
          this.edit = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addNewBracket() {
        if(this.validNumUsers.includes(this.newBracket.numberOfUsers)) {
          this.bracketError = false
          this.bracketErrorMsg = ''
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            let param = {
              numberOfUsers: this.newBracket.numberOfUsers,
              tournamentId: this.tournament.id
            }
            const {data, status} = await postRequest(`/tournament/bracket`, param, 'blueraven')
            // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
            data.maxRounds = false
            this.tournament.brackets.push(data)
            this.addBracket = false
            this.newBracket = {}
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Bracket')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.bracketError = true
          this.bracketErrorMsg = 'Number of Users must be 2, 4, 8, 16, 32, or 64'
        }
      },
      async deleteBracket() {
        let id = this.bracketToDelete.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/tournament/bracket/${id}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Bracket Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.tournament.brackets.splice(this.tournament.brackets.indexOf(this.bracketToDelete))
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Bracket')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveRound(bracket, round) {
        this.$store.commit(AppMutations.SET_LOADING, true)
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
            this.newRound = {}
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Round')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteRound() {
        let bracket = this.bracketToDeleteRoundFrom
        let roundId = this.roundToDelete.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let param = {
            id: roundId,
            tournamentBracketId: bracket.id
          }
          const {data, status} = await putRequest(`/tournament/round/${roundId}/delete`, param, 'blueraven')
          bracket.rounds = data.rounds
          // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
          bracket.maxRounds = false
          this.snackbar = getSnackbar('SUCCESS', 'Round Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Round')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async generateMatches() {
        let bracket = this.bracketForMatches
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/tournament/bracket/${bracket.id}/generateMatches`, {}, 'blueraven')
          //disable the button
          bracket.matchesGenerated = true
          this.snackbar = getSnackbar('SUCCESS', 'Matches Generated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Generating Matches')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterRounds(bracket) {
        return bracket?.rounds.filter(r => {
          return !r.archived
        })
      },
    },
    async created() {
      this.getTournamentOwnerTypes()
      this.getTournament()
    }
  }
</script>

<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Brackets</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn text @click="addBracket = !addBracket">
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
          <v-btn text @click="[addBracket = !addBracket, newBracket = {}]">
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
              <v-dialog
                v-model="b.generateMatches"
                width="500">
                <template v-slot:activator="{ on }">
                  <v-btn color="primary"
                         class="white--text"
                         v-on="on"
                         :disabled="b.matchesGenerated || b.rounds.length === 0">
                    <span v-if="!b.matchesGenerated">Generate Matches</span>
                    <span v-else>Matches Created</span>
                  </v-btn>
                </template>
                <v-card>
                  <v-card-title
                    class="headline grey lighten-2"
                    primary-title
                  >
                    Confirm
                  </v-card-title>

                  <v-card-text class="mt-5">
                    <strong>WARNING: This can only be done once. </strong><br/>
                    Please ensure that your rounds are created correctly in this bracket before generating matches.
                    Would you like to continue creating matches?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                      @click="b.generateMatches = false">
                      No
                    </v-btn>
                    <v-btn
                      color="primaryCustom"
                      text
                      @click="[b.generateMatches = false, generateMatches(b)]">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>

              <v-btn v-if="b.maxRounds" text disabled color="primary" class="white--text">
                <span>Max Rounds Reached</span>
              </v-btn>
              <v-btn text color="primary" v-else-if="!b.matchesGenerated" class="white--text"
                     @click="[b.addRound = !b.addRound, rerenderBracket()]">
                <span v-if="!b.addRound">Add Round</span>
                <span v-else>Cancel</span>
              </v-btn>
              <v-dialog
                v-if="$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT')"
                v-model="b.replicateConfirm"
                width="500">
                <template v-slot:activator="{ on }">
                  <v-btn small text v-on="on">
                    <v-icon>mdi-content-copy</v-icon>
                  </v-btn>
                </template>
                <v-card>
                  <v-card-title
                    class="headline grey lighten-2"
                    primary-title
                  >
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to replicate this bracket?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                      @click="b.replicateConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                      color="primaryCustom"
                      text
                      @click="[b.replicateConfirm = false, replicateBracket(b)]">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
              <v-dialog
                v-if="$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'DELETE')"
                v-model="b.deleteConfirm"
                width="500">
                <template v-slot:activator="{ on }">
                  <v-list-item-action class="clickable" v-on="on">
                    <v-icon>delete</v-icon>
                  </v-list-item-action>
                </template>
                <v-card>
                  <v-card-title
                    class="headline grey lighten-2"
                    primary-title
                  >
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to delete this bracket?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                      @click="b.deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                      color="primaryCustom"
                      text
                      @click="[b.archived = true, deleteBracket(b.id)]">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
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
                No available rounds
              </template>

              <template #no-results>
                No available rounds
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
                    <v-btn small text @click="[item.edit = !item.edit, rerenderKey++]">
                      <v-icon v-if="!item.edit">edit</v-icon>
                      <span v-else>cancel</span>
                    </v-btn>
                    <v-btn v-if="item.edit" text
                           :disabled="!item.startDate || !item.endDate || item.startDate > item.endDate"
                           @click="saveRound(b, item)">Save
                    </v-btn>
                    <v-dialog
                      v-if="!b.matchesGenerated && $store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'DELETE')"
                      v-model="item.deleteConfirm"
                      width="500">
                      <template v-slot:activator="{ on }">
                        <v-btn text v-on="on">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title
                          class="headline grey lighten-2"
                          primary-title
                        >
                          Confirm
                        </v-card-title>

                        <v-card-text>
                          Are you sure you want to delete this round?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="item.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                            color="primaryCustom"
                            text
                            @click="[item.archived = true, deleteRound(b, item.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-card>
        </div>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {
    getRequest,
    deleteRequest,
    putRequest,
    postRequest,
    getSnackbar
  } from '@/helpers/helpers'

  export default {
    name: 'BracketAdmin',
    mixins: [Vue2Filters.mixin],
    components: {
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
        ]
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
      async replicateBracket(b) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/tournament/bracket/replicate`, b, 'blueraven')
          // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
          data.maxRounds = false
          this.tournament.brackets.push(data)
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getRequest(`/tournament/ownerTypes`, 'blueraven')
          this.ownerTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
          data?.brackets?.forEach(b => {
            b.maxRounds = false
          })
          this.tournament = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await putRequest(`/tournament`, this.tournament, 'blueraven')
          this.tournament = data
          this.edit = false
          this.$store.commit(AppMutations.SET_LOADING, false)
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
            const {data} = await postRequest(`/tournament/bracket`, param, 'blueraven')
            // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
            data.maxRounds = false
            this.tournament.brackets.push(data)
            this.addBracket = false
            this.newBracket = {}
            this.$store.commit(AppMutations.SET_LOADING, false)
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
      async deleteBracket(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/tournament/bracket/${id}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Bracket Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await putRequest(`/tournament/round`, param, 'blueraven')
          bracket.rounds = data.rounds
          if (round.id) {
            round.edit = false
          } else {
            bracket.addRound = false
            this.newRound = {}
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Round')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteRound(bracket, roundId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let param = {
            id: roundId,
            tournamentBracketId: bracket.id
          }
          const {data} = await putRequest(`/tournament/round/${roundId}/delete`, param, 'blueraven')
          bracket.rounds = data.rounds
          // this is dumb but i am getting an infinite loop error if i try to use the increment render key solution
          bracket.maxRounds = false
          this.snackbar = getSnackbar('SUCCESS', 'Round Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Round')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async generateMatches(bracket) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/tournament/bracket/${bracket.id}/generateMatches`, {}, 'blueraven')
          //disable the button
          bracket.matchesGenerated = true
          this.snackbar = getSnackbar('SUCCESS', 'Matches Generated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
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

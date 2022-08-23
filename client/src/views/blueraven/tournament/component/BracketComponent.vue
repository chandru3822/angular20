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
            <v-autocomplete
              v-model="overrideUser"
              :items="overrideUsers"
              label="Select a user"
              item-text="fullName"
              return-object
              attach
            ></v-autocomplete>

            <div v-if="overrideUser.id">
              <strong>{{ showScoreData.user }} will be replaced by {{ overrideUser.fullName }}</strong>
            </div>
          </v-card-text>

          <v-divider></v-divider>

          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn @click="[overrideUser = {}, showOverrideModal = false]">
              Cancel
            </v-btn>
            <v-btn @click="overrideMatchUser"
                   :disabled="!overrideUser.id"
                   color="primary" class="white--text">
              Save
            </v-btn>
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
                  <v-btn text x-small v-on="on" class="advance-button">
                    <v-icon size="15">mdi-arrow-top-right</v-icon>
                  </v-btn>
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
                    <v-btn
                      @click="r.advanceConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                      color="primary"
                      text
                      @click="[r.advanceConfirm = true, advanceWinners(r)]">
                      Yes
                    </v-btn>
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

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, putRequest, putRequestWithRequestParams, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ScoreDrilldown from "./ScoreDrilldown"

  export default {
    name: 'BracketComponent',
    components: {
      ScoreDrilldown
    },
    props: {
      bracket: {type: Object},
      bracketCount: {type: Number},
      rowNumber: {type: Number},
      reverse: {type: Boolean}

    },
    computed: {
      itemsReverse() {
        return [...this.bracket?.rounds].reverse()
      }
    },
    data() {
      return {
        constants,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT'),
        snackbar: {},
        showModal: false,
        overrideUser: {},
        overrideUsers: [],
        showOverrideModal: false,
        showScoreData: {
          userId: null,
          user: null,
          isUser1: null,
          matchId: null,
          round: {}
        },
        roundRerenderKey: 0,
        firstNonAdvancedRound: {}
      }
    },
    async created() {

    },
    methods: {
      async getOverrideUsers() {
        try {
          const {data, status} = await getRequest(`/user/active`)
          this.overrideUsers = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async overrideMatchUser() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequestWithRequestParams(`/tournament/match/${this.showScoreData.matchId}/userOverride`, null, { userId: this.overrideUser.id , overrideUser1: this.showScoreData.isUser1 }, 'blueraven')
          this.roundRerenderKey++
          //maybe we dont have to do this but i am doing it for v1
          window.location.reload(true)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Saving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async handleMatchUserClick(r, m, user1) {
        if(r.edit) {

          await this.getOverrideUsers(user1)
          this.showScoreData.user = user1 ? m.user1Name : m.user2Name
          this.showScoreData.userId = user1 ? m.user1Id : m.user2Id
          this.showScoreData.matchId = m.id
          this.showScoreData.isUser1 = user1
          this.showOverrideModal = true
        } else {
          this.showScoreData.user = user1 ? m.user1Name : m.user2Name
          this.showScoreData.userId = user1 ? m.user1Id : m.user2Id
          this.showScoreData.round = r
          this.showModal = true
        }
      },
      getSpacingByIndex(roundIndex, matchIndex) {
        return this.reverse ? roundIndex === this.bracket?.rounds?.length - 1 && matchIndex % 2 !== 0 : roundIndex === 0 && matchIndex % 2 !== 0
      },
      isCurrentRound(r) {
        this.bracket.firstNonAdvancedRound = this.bracket?.rounds.find(r => !r.advanced)
        return r.id === this.bracket?.firstNonAdvancedRound?.id
      },
      canAdvanceWinners(r) {
        let allMatchesHaveUsers = !!(r.matches && r.matches.length !== 0)
        r.matches.forEach(m => {
          if(!m.user1Id || !m.user2Id) {
            allMatchesHaveUsers = false
          }
        })
        return allMatchesHaveUsers && !r.advanced && r.roundNumber === this.bracket.rounds.length && this.userCanEdit
      },
      canEditRound(r) {
        let allMatchesHaveUsers = true
        r.matches.forEach(m => {
          if(!m.user1Id || !m.user2Id) {
            allMatchesHaveUsers = false
          }
        })
        return allMatchesHaveUsers && !r.advanced && r.roundNumber !== this.bracket.rounds.length && this.userCanEdit && !r.edit
      },
      async advanceWinners(round) {
        round.advanced = true
        round.advanceConfirm = false
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/tournament/${this.bracket.tournamentId}/round/${round.id}/advanceWinners`, round.matches, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Finalists Advanced')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      rerender(r) {
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
        this.roundRerenderKey++
      },
      async advanceMatches(round) {
        let allMatchesHaveWinners = true
        round?.matches.forEach(m => {
          if(!m.winnerUserId) {
            allMatchesHaveWinners = false
            this.snackbar = getSnackbar('ERROR', 'All matches must have a winner selected')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            return
          }
        })
        if(allMatchesHaveWinners) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            await putRequest(`/tournament/${this.bracket.tournamentId}/advance`, round.matches, 'blueraven')
            round.edit = false
            this.roundRerenderKey++
            //maybe we dont have to do this but i am doing it for v1
            window.location.reload(true)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.dataLoading = false
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
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


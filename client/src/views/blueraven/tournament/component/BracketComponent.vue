<template>
    <section id="bracket" :class="{'float-right': reverse}">
      <div class="container">
        <div class="split split-one">
          <div class="round"
               :class="`round-${r.roundNumber}`"
               v-for="(r, idx) in reverse ? itemsReverse : bracket.rounds">
            <div class="round-details"
                 :key="roundRerenderKey"
                 :class="{'current': r.currentRound,
                          'bold': r.currentRound}">
              <v-icon v-if="!r.advanced && r.roundNumber !== bracket.rounds.length && userCanEdit && !r.edit" class="edit-button clickable"
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
                v-if="!r.advanced && r.roundNumber === bracket.rounds.length && userCanEdit"
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
                    class="headline grey lighten-2"
                    primary-title
                  >
                    Confirm
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to advance these winners to the Winner Pool?
                  </v-card-text>

                  <v-divider></v-divider>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                      @click="r.advanceConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                      color="primaryCustom"
                      text
                      @click="[r.advanceConfirm = true, advanceWinners(r)]">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
              <div v-if="r.roundNumber === bracket.rounds.length">
                WINNERS
              </div>
              <div v-else>
                Round {{r.roundNumber}}<br/>
                <span class="date">
                  {{r.startDate | formatDate('date', 'M/D')}} -
                  {{r.endDate | formatDate('date', 'M/D')}}
                </span>
              </div>
            </div>
            <ul class="matchup" v-for="(m, i) in r.matches" :class="{'mb-4': idx === 0 && i % 2 !== 0}">
              <v-radio-group v-model="m.winnerUserId">
                <li class="team team-top" :class="{'current': r.currentRound}">
                  <v-radio v-if="r.edit && m.user1Id && m.user2Id" :value="m.user1Id" class="d-inline-block"></v-radio>
                  {{m.user1Name}}
                  <span class="score">{{m.user1Score || 0}}</span>
                </li>
                <li class="team team-bottom" :class="{'current': r.currentRound}">
                  <v-radio small v-if="r.edit && m.user1Id && m.user2Id" :value="m.user2Id" class="d-inline-block"></v-radio>
                  {{m.user2Name}}
                  <span class="score">{{m.user2Score || 0}}</span></li>
              </v-radio-group>
            </ul>
          </div>
        </div>
      </div>
    </section>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'BracketComponent',
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
        roundRerenderKey: 0,
      }
    },
    async created() {

    },
    methods: {
      async advanceWinners(round) {
        round.advanced = true
        round.advanceConfirm = false
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/tournament/${this.bracket.tournamentId}/round/${round.id}/advanceWinners`, round.matches, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Winners Advanced')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
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
            await putRequest(`/tournament/advance`, round.matches, 'blueraven')
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

<style lang="scss">
</style>

<style lang="scss" scoped>

  #bracket {
    font-size: 12px;
    padding: 8px 0;
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

  .split-two {}

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
    height: 60px;
    padding: 240px 0;
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
    color: #3F915F;
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


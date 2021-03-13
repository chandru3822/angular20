<template>
    <section id="bracket" :class="{'float-right': reverse}">
      <div class="container">
        <div class="split split-one">
          <div class="round"
               v-if="renderHack"
               :class="`round-${r.roundNumber}`"
               v-for="(r, idx) in reverse ? itemsReverse : bracket.rounds">
            <div class="round-details"
                 :class="{'current': r.currentRound,
                          'bold': r.currentRound}">
<!--              <v-btn x-small text @click="r.edit = !r.edit" class="edit-button">-->
              <v-icon v-if="roundCanBeEdited(r)" class="edit-button clickable"
                      size="15" @click="rerender(r)">edit</v-icon>
              <v-icon v-if="userCanEdit && r.edit" class="edit-button clickable"
                      size="15" @click="rerender(r)">close</v-icon>
              <v-icon v-if="userCanEdit && r.edit" class="save-button clickable"
                      size="15" @click="advanceMatches(r)">save</v-icon>
<!--              </v-btn>-->
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
                  <v-radio v-if="r.edit" :value="m.user1Id" class="d-inline-block"></v-radio>
                  {{m.user1Name}}
                  <span class="score">{{m.user1Score || 0}}</span>
                </li>
                <li class="team team-bottom" :class="{'current': r.currentRound}">
                  <v-radio small v-if="r.edit" :value="m.user2Id" class="d-inline-block"></v-radio>
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
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTDS', 'EDIT'),
        snackbar: {},
        renderHack: true,
      }
    },
    async created() {

    },
    methods: {
      roundCanBeEdited(r) {
        let alreadyAdvanced = false
        r?.matches.forEach(m => {
          if(m.matchAdvanced) {
            alreadyAdvanced = true
          }
        })
        return !alreadyAdvanced && r.roundNumber !== this.bracket.rounds.length && this.userCanEdit && !r.edit
      },
      rerender(r) {
        //i hate this crap
        r.edit = !r.edit
        this.renderHack = false;
        this.$nextTick(() => {
          // Add the component back in
          this.renderHack = true
        });
        //pre-populate the winner if not tied
        r?.matches.forEach(m => {
          if(m.user1Score > m.user2Score) {
            m.winnerUserId = m.user1Id
          } else if (m.user2Score > m.user1Score){
            m.winnerUserId = m.user2Id
          }
        })
      },
      async advanceMatches(round) {
        let allMatchesHaveWinners = true
        round?.matches.forEach(m => {
          if(!m.winnerUserId) {
            allMatchesHaveWinners = false
            this.snackbar = getSnackbar('ERROR', 'All matches must have a winner selected')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        })
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


</style>


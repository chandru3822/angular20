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
          <v-btn text @click="toggleSelectAllQualifying()" v-if="userCanEdit && !pool.advanced">
            Select All Qualifying
          </v-btn>
          <v-btn v-if="userCanEdit"
                 :disabled="selectedUsers.length !== tournamentUserCount || pool.advanced || matchesNotGenerated"
                 color="primary" class="white--text" @click="advanceSelectedToBracket()">
            <span v-if="matchesNotGenerated">Must Generate Matches</span>
            <span v-else-if="!pool.advanced">Advance Selected to Bracket</span>
            <span v-else>Pool Has Been Advanced</span>
          </v-btn>
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
        :fixed-header="true"
        :search="search"
        dense
        :items-per-page="minRowsPerPage"
        disable-sort
        class="elevation-1 square-card"
      >
        <template #no-data>
          No available users
        </template>

        <template #no-results>
          No available users
        </template>

        <template #header.score="{ header }">
            <div class="text-center">
              {{header.text}}
            </div>
        </template>




        <template #item="{ item, index }">
          <tr :class="{'on-fence-row': !pool.advanced && item.score === lastQualifiedUserScore,'qualified-row': !pool.advanced && poolUsers.indexOf(item) < tournamentUserCount,'shaded-row': index % 2}">
            <td :key="selectRerender">
              <input type="checkbox" v-if="!pool.advanced" v-model="item.selected" @change="toggleSingleSelect(item)">
              <v-icon color="green" v-else-if="item.qualified">mdi-check-decagram</v-icon>
            </td>
            <td class="text-left">
              {{item.fullName}}
            </td>
            <td class="text-center">
              <span v-if="item.score == null">--</span>
              <span v-else>{{item.score}}</span>
            </td>
            <td class="text-right">
              <v-btn text small class="clickable" @click="[showModal = true, showScoreUser = item]">
                <v-icon>mdi-format-list-bulleted</v-icon>
              </v-btn>
            </td>
          </tr>
        </template>


      </v-data-table>
    </v-card>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, logError, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import orderBy from "lodash.orderby"
  import ScoreDrilldown from "./component/ScoreDrilldown";

  export default {
    name: 'Qualifying',
    components: {
      ScoreDrilldown
    },
    data() {
      return {
        constants,
        snackbar: {},
        tournamentId: this.$route.params.id,
        poolTypeId: 1,
        finalMatches: [],
        showScoreUser: {},
        showModal: false,
        selectRerender: 1,
        search: '',
        tournament: {},
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT'),
        lastQualifiedUserScore: null,
        tournamentUserCount: 0,
        matchesNotGenerated: false,
        minRowsPerPage: 0,
        dataLoading: true,
        pool: {},
        poolUsers: [],
        ordered: [],
        selectedUsers: [],
        seededUserIds: [],
        headers: [
          {text: '', value: 'checkbox', show: true, width: '50px'},
          {text: 'User', value: 'fullName', show: true},
          {text: 'Score', value: 'score', show: true, width: '75px'},
          {text: '', value: 'details', show: true},
        ],
      }
    },
    watch: {
      // whenever tournament_id changes, this function will run
      '$route.params.id': async function () {
        // reset the selected group when the object type changes
        this.tournamentId = this.$route.params.id
        this.tournament = {}
        this.pool = {}
        this.poolUsers = []
        this.selectedUsers = []
        this.matchesNotGenerated = false
        this.tournamentUserCount = 0
        await this.getTournament()
        this.getPool()
        this.getPoolUsers()
      }
    },
    async created() {
      this.getPool()
      this.getPoolUsers()
      //need the tournament so i can see how many users can qualify
      this.getTournament()
    },
    methods: {
      toggleSingleSelect(item) {
        if (item.selected) {
          this.selectedUsers.push(item)
        } else {
          this.selectedUsers = this.selectedUsers.filter(u => u.userId !== item.userId)
        }
      },
      toggleSelectAllQualifying() {
        this.selectedUsers = []
        //get the score of the last qualified user based on index so we can compare others to it later
        this.poolUsers.forEach((pu, idx) => {
          if (idx < this.tournamentUserCount) {
            pu.selected = true
            this.selectedUsers.push(pu)
          } else if (pu.score === this.lastQualifiedUserScore) {
            //if a user has the same score as the final qualified user then select them also so that they have to manual decide who advances
            pu.selected = true
            this.selectedUsers.push(pu)
            this.minRowsPerPage++
            this.snackbar = getSnackbar('ERROR', 'The final qualifying user is tied with other users. You will have to manually select who advances.')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            pu.selected = false
          }
        })
        //force checkbox to rerender as selected
        this.selectRerender++
      },
      async advanceSelectedToBracket() {
        let seededUsers = orderBy(this.selectedUsers, ['score', su => su.fullName.toLowerCase()], ['desc', 'asc'])
        this.seededUserIds = seededUsers?.map(u => u.userId)

        this.populateSeededMatches()

        if(this.seededUserIds?.length > 0 && this.finalMatches.length === this.tournamentUserCount / 2) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {status} = await postRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/assignUsersToMatches`, this.finalMatches, 'blueraven')
            this.pool.advanced = true
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Advancing Users')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.snackbar = getSnackbar('ERROR', 'Error Advancing Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      populateSeededMatches () {
        //todo: this could probably be cleaned up a little but I got it working and that is all i care about at this point
        //reset these values every time
        this.ordered = []
        this.finalMatches = []

        let ind = []

        //populate a blank array of zeroes for the total number of users
        // (not sure why but that's how they coded the formula to work and it doesn't work if this isn't done this way)
        for(let i = 0; i < this.tournamentUserCount; i++) {
          ind.push(0)
        }

        //this creates the total number of users game indexes that i dont fully understand
        for (let i = 0; i <= (Math.log(this.tournamentUserCount) / Math.log(2)); i++) {
          for(let N = 1; N <= this.tournamentUserCount; N++)
          {
            let myRank = Math.floor((N - 1) / Math.pow(2, i) + 1);
            ind[N - 1] += Math.floor(((myRank % 4)/2)) * Math.pow(2, ( (Math.log(this.tournamentUserCount) / Math.log(2)) -  i - 1));
          }
        }

        //make an array of the games so i can order them by the game number
        //again i dont fully understand the ind[N-1]+1 stuff but i know it works cuz they coded that part
        let games = []
        for (let N = 1; N <= this.tournamentUserCount; N++){
          let gameNumber = ind[N - 1] + 1;
          let game = {
            seed: N,
            gameNumber
          }
          games.push(game)
        }

        //order them by game number
        this.ordered = orderBy(games, g => g.gameNumber);

        //the game numbers go 1,2,3,4,5,6 etc
        //i need them to go 1,1,2,2,3,3,4,4
        //this changes the game numbers accordingly
        let count = 1
        this.ordered.forEach((o, idx) => {
          o.gameNumber = count
          if(idx % 2 !== 0) {
            count++
          }
        })


        let params = {}
        for(let i = 1; i <= this.tournamentUserCount / 2; i++) {
          //find both the matches where the gameNumber === i
          let matches = this.ordered.filter(o => o.gameNumber === i)
          //turn the 2 rows into 1 object for sending to the backend
          // seededUserIds is indexed at zero and match seeds start at 1, so have to subtract 1
          params = {
            matchNumber: i,
            user1Id: this.seededUserIds[(matches[0].seed - 1)],
            user2Id: this.seededUserIds[(matches[1].seed -1)]
          }
          //populate the final results to be sent
          this.finalMatches.push(params)

          //just a quick String to display the magic on the screen in a more friendly format
          // let game = 'Game ' + i + ': ' + matches[0].seed + ' vs ' + matches[1].seed + '\n'
          // this.gamesString += game
        }
        //log it out
        // console.log('final matches', this.finalMatches)


      },
      async getTournament() {
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          this.tournament = data
          this.tournament?.brackets?.forEach(b => {
            this.tournamentUserCount += b.numberOfUsers
            if(!b.matchesGenerated) {
              this.matchesNotGenerated = true
            }
          })
          this.minRowsPerPage = this.tournamentUserCount > 100 ? this.tournamentUserCount : 100
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getPool() {
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/byType/${this.poolTypeId}`, 'blueraven')
          this.dataLoading = false
          this.pool = data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching pool details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getPoolUsers() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/tournament/${this.tournamentId}/pool/usersByType/${this.poolTypeId}`, 'blueraven')
          this.poolUsers = data
          this.lastQualifiedUserScore = this.poolUsers[this.tournamentUserCount - 1].score
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching pool user details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
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


<template>
  <v-container id="winners-pool-container" v-if="!poolLoading" :class="{'padded-pool': !showWinners}">
    <v-dialog v-model="showModal" class="square-card">
      <ScoreDrilldown :tournament-id="parseInt(tournamentId)"
                      :start-date="pool.startDate"
                      :end-date="pool.endDate"
                      :user="showScoreUser.fullName"
                      :user-id="showScoreUser.userId"
                      @scoreDialogClosed="showModal = false"
      />
    </v-dialog>

    <v-card color="white" flat class="square-card ma-4" v-if="!showWinners">
      <v-toolbar flat class="app-toolbar">
        {{pool.customName || 'Winners'}} <br/>
        {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text color="primary" v-if="tournamentOver" @click="showWinners = !showWinners">
            <v-icon>mdi-party-popper</v-icon>
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
        :search="search"
        :fixed-header="true"
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
          <tr :class="{'shaded-row': index % 2}">
            <td class="text-left">
              <v-icon v-if="isWinner(item)" class="mr-2" color="green">mdi-seal</v-icon>
              {{item.fullName}}
            </td>
            <td class="text-center">
              <span v-if="item.score == null">--</span>
              <span v-else>{{item.score}}</span>
            </td>
            <td class="text-right">
              <v-btn text small color="primary" class="clickable" @click="[showModal = true, showScoreUser = item]">
                <v-icon>mdi-format-list-bulleted</v-icon>
              </v-btn>
            </td>
          </tr>
        </template>

      </v-data-table>
    </v-card>
    <v-card v-else
            class="square-card pa-4 congrats-card"
            align="center" justify="center"
            :style="{'background-image': null != pool.backgroundAttachmentPresignedUrl
                  ? `url(${pool.backgroundAttachmentPresignedUrl})` : ''}"
    >
      <v-card color="white" class="square-card pa-5 congrats-inner-container">
        <div class="congrats-header mb-3">
          Congratulations to our Winner{{winners.length > 1 ? 's' : ''}}!
        </div>
        <div v-for="w in this.winners" class="congrats-winner">
          {{w.fullName}}
        </div>
      </v-card>
      <v-btn x-small fab @click="showWinners = !showWinners" class="show-score-button">
        <v-icon color="primary">mdi-format-list-bulleted-square</v-icon>
      </v-btn>
    </v-card>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, logError, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import moment from 'moment'
  import ScoreDrilldown from "./component/ScoreDrilldown"

  export default {
    name: 'Winners',
    components: {
      ScoreDrilldown
    },
    data() {
      return {
        constants,
        snackbar: {},
        search: '',
        footerProps: {
          'items-per-page-options': [25, 50, 100],
        },
        showScoreUser: {},
        showModal: false,
        poolTypeId: 3,
        poolLoading: false,
        tournamentId: this.$route.params.id,
        pool: {},
        poolUsers: [],
        tournamentOver: false,
        winners: [],
        showWinners: false,
        headers: [
          {text: 'User', value: 'fullName', show: true},
          {text: 'Score', value: 'score', show: true},
          {text: '', value: 'details', show: true},
        ],
      }
    },
    async created() {
      this.getPool()
      this.getPoolUsers()
    },
    methods: {
      isWinner(poolUser) {
        if (this.tournamentOver) {
          let topScore = this.poolUsers[0]?.score || 0
          return (poolUser.score || 0) === topScore
        }
      },
      async getPool() {
        this.poolLoading = true
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/byType/${this.poolTypeId}`, 'blueraven')
          this.pool = data
          this.tournamentOver = moment() > moment(this.pool.endDate).endOf('day')
          if(this.tournamentOver) {
            this.showWinners = true
          }
          this.poolLoading = false
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching pool details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getPoolUsers() {
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/usersByType/${this.poolTypeId}`, 'blueraven')
          this.poolUsers = data
          this.poolUsers.forEach(u => {
            if (this.isWinner(u)) {
              this.winners.push(u)
            }
          })
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching pool user details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
    }
  }
</script>

<style lang="scss">
  #winners-pool-container .v-data-table__wrapper {
    max-height: calc(100vh - 375px);
    min-height: 300px;
  }

  .tourney-winning-row {
    background-color: #FFD700 !important;
  }
</style>

<style lang="scss" scoped>
  #winners-pool-container {
    padding: 0;
    height: calc(100vh - 110px);
  }

  .padded-pool {
    padding: 50px !important;
  }

  .congrats-card {
    background-repeat: no-repeat;
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    min-height: 300px;
    height: calc(100vh - 104px);
    display: flex;
    position: relative;
    align-items: center;
    justify-content: center;
  }

  .congrats-inner-container {
    min-height: 200px;
  }

  .congrats-header {
    font-family: "Congrats", sans-serif;
    font-size: 50px;
  }

  .congrats-winner {
    font-size: 30px;
  }

  .show-score-button {
    position: absolute;
    bottom: 10px;
    right: 10px;
  }

</style>


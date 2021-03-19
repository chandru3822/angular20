<template>
  <v-container id="winners-pool-container" v-if="!poolLoading">
    <v-card color="white" flat class="square-card ma-4" v-if="!showWinners">
      <v-toolbar flat class="app-toolbar">
        {{pool.customName || 'Winners'}} <br/>
        {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text v-if="tournamentOver" @click="showWinners = !showWinners">
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
        :items="pool.users"
        :search="search"
        :fixed-header="true"
        :items-per-page="100"
        disable-sort
        class="elevation-1 square-card"
      >
        <template #no-data>
          No available users
        </template>

        <template #no-results>
          No available users
        </template>

        <template #item="{ item, index }">
          <tr :class="{'shaded-row': index % 2}">
            <td class="text-left">
              <v-icon v-if="isWinner(item)" class="mr-2" color="green">mdi-seal</v-icon>
              {{item.fullName}}
            </td>
            <td>{{item.score || 0}}</td>
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
      <v-card color="white" class="square-card pa-4">
        <div class="congrats-header">
          Congratulations to our Winner{{winners.length > 1 ? 's' : ''}}!
        </div>
        <div v-for="w in this.winners" class="congrats-winner">
          {{w.fullName}}
        </div>
      </v-card>
      <v-btn x-small fab @click="showWinners = !showWinners" class="show-score-button">
        <v-icon>mdi-format-list-bulleted-square</v-icon>
      </v-btn>
    </v-card>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, deleteRequest, logError, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import moment from 'moment'

  export default {
    name: 'Winners',
    data() {
      return {
        constants,
        snackbar: {},
        search: '',
        poolTypeId: 3,
        poolLoading: false,
        tournamentId: this.$route.params.id,
        pool: {},
        tournamentOver: false,
        winners: [],
        showWinners: false,
        headers: [
          {text: 'User', value: 'fullName', show: true},
          {text: 'Score', value: 'score', show: true},
        ],
      }
    },
    async created() {
      this.getPool()
    },
    methods: {
      isWinner(poolUser) {
        if (this.tournamentOver) {
          let topScore = this.pool?.users[0]?.score || 0
          return (poolUser.score || 0) === topScore
        }
      },
      async getPool() {
        this.poolLoading = true
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/byType/${this.poolTypeId}`, 'blueraven')
          this.pool = data
          this.tournamentOver = moment() > moment(this.pool.endDate)
          if(this.tournamentOver) {
            this.pool.users.forEach(u => {
              if (this.isWinner(u)) {
                this.winners.push(u)
              }
            })
            this.showWinners = true
          }
          this.poolLoading = false
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching pool details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
    }
  }
</script>

<style lang="scss">
  #winners-pool-container .v-data-table__wrapper {
    max-height: calc(100vh - 300px);
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

  .congrats-header {
    font-family: "Congrats", sans-serif;
    font-size: 50px;
  }

  .congrats-winner {
    font-size: 20px;
  }

  .show-score-button {
    position: absolute;
    bottom: 10px;
    right: 10px;
  }

</style>


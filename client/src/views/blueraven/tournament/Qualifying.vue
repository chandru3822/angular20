<template>
  <v-container id="pool-container">

    <v-toolbar flat class="app-toolbar">
      Qualifying Pool <br/>
      {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text @click="toggleSelectAllQualifying()" v-if="userCanEdit && !pool.advanced && !dataLoading">
          Select All Qualifying
        </v-btn>
        <v-btn v-if="userCanEdit && !dataLoading"
               :disabled="selectedUsers.length !== tournamentUserCount || pool.advanced"
               color="primary" class="white--text" @click="advanceSelectedToBracket()">
          <span v-if="!pool.advanced">Advance Selected to Bracket</span>
          <span v-else>Pool Has Been Advanced</span>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>

    <v-data-table
      :headers="headers"
      :items="poolUsers"
      :fixed-header="true"
      dense
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
        <tr :class="{'qualified-row': index < tournamentUserCount,'shaded-row': index % 2}">
          <td :key="selectRerender">
            <input type="checkbox" v-if="!pool.advanced" v-model="item.selected" @change="toggleSingleSelect(item)">
          </td>
          <td class="text-left">
            {{item.fullName}}
          </td>
          <td>{{item.score || 0}}</td>
        </tr>
      </template>


    </v-data-table>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, logError, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'Qualifying',
    data() {
      return {
        constants,
        snackbar: {},
        tournamentId: this.$route.params.id,
        poolTypeId: 1,
        selectRerender: 1,
        tournament: {},
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT'),
        tournamentUserCount: 0,
        dataLoading: true,
        pool: {},
        poolUsers: [],
        selectedUsers: [],
        headers: [
          { text: '', value: 'checkbox', show: true, width: '50px' },
          { text: 'User', value: 'fullName', show: true },
          { text: 'Score', value: 'score', show: true },
        ],
      }
    },
    watch: {
      // whenever tournament_id changes, this function will run
      '$route.params.id': function () {
        // reset the selected group when the object type changes
        this.tournamentId = this.$route.params.id
        this.tournament = {}
        this.pool = {}
        this.poolUsers = []
        this.selectedUsers = []
        this.tournamentUserCount = 0
        this.getPool()
        this.getPoolUsers()
        this.getTournament()
      }
    },
    async created () {
      this.getPool()
      this.getPoolUsers()
      //need the tournament so i can see how many users can qualify
      this.getTournament()
    },
    methods: {
      toggleSingleSelect(item) {
        if (item.selected) {
          this.selectedUsers.push(item.userId)
        } else {
          this.selectedUsers = this.selectedUsers.filter(u => u !== item.userId)
        }
      },
      toggleSelectAllQualifying () {
        this.selectedUsers = []
        this.poolUsers.forEach((pu, idx) => {
          if(idx < this.tournamentUserCount) {
            pu.selected = true
            this.selectedUsers.push(pu.userId)
          } else {
            pu.selected = false
          }
        })
        //force checkbox to rerender as selected
        this.selectRerender++
      },
      async advanceSelectedToBracket () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/assignUsersToMatches`, this.selectedUsers, 'blueraven')
          this.pool.advanced = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Advancing Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getTournament() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}`, 'blueraven')
          this.tournament = data
          this.tournament?.brackets?.forEach(b => {
            this.tournamentUserCount += b.numberOfUsers
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Tournament')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPool () {
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
      async getPoolUsers () {
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/usersByType/${this.poolTypeId}`, 'blueraven')
          this.poolUsers = data
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
  #pool-container .v-data-table__wrapper {
    height: calc(100vh - 250px);
    min-height: 300px;
  }

  .qualified-row {
    background-color: var(--v-brGreen-base) !important;;
  }
</style>

<style lang="scss" scoped>
</style>

